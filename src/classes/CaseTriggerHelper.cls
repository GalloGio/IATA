/**
* IATA CS Portal extension | Vanja Djurdjevic
* Class created as helper to keep logic separated from the CaseAfterTrigger.
*
* unit test class: FDSKPIReportingTest
*/
public with sharing class CaseTriggerHelper {

	public static Boolean isDone = false;

	public static final String CASE_STATUS_PENDING_CLOSURE = 'Pending Closure';
	public static final String CASE_STATUS_ACTION_NEEDED = 'Action Needed';
	public static final String CASE_STATUS_CLOSED = 'Closed';
	public static final String CASE_STATUS_ESCALATED_INTERNALLY = 'Escalated Internally';
	public static final String CASE_STATUS_ESCALATED_EXTERNALLY = 'Escalated Externally';
	public static final String CASE_STATUS_REOPEN = 'Reopen';

	public static final String CASE_ACTION_CASE_CLOSURE = 'Case Closure';
	public static final String CASE_ACTION_CASE_ESCALATION = 'Case Escalation';
	public static final String CASE_ACTION_CASE_REOPENING = 'Case Reopening';
	public static final String CASE_ACTION_SEND_NOI = 'Send NOI';

	public static final String EMPTY_KEYWORD = '[EMPTY]'; // used in ISSP KPI Reporting metadata, in field status_from__c, to be used when the field is empty because the record is being inserted

	public static List<String> actionTypes = new List<String>{CASE_ACTION_CASE_CLOSURE, CASE_ACTION_CASE_ESCALATION, CASE_ACTION_CASE_REOPENING, CASE_ACTION_SEND_NOI};

	public static final List<String> PORTAL_PENDING_CLOSURE_RECORD_TYPES = new List<String> {
		'CasesMENA', 'CasesAmericas', 'Cases_China_North_Asia', 'CasesEurope', 'Cases_Global', 'ExternalCasesIDFSglobal'
	};
	public static final List<String> reopening_reasons = new List<String> {'same query'};
	private static final string complaintRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ComplaintIDFS');
	private static List<Id> portalPendingClosureRecordTypes;

	public static Map<String, FDS_KPI_Reporting__c> MAP_ACTION_TO_KPI_REPORTING {
		get{
			if (MAP_ACTION_TO_KPI_REPORTING == null) {
				MAP_ACTION_TO_KPI_REPORTING = new Map<String, FDS_KPI_Reporting__c>();
				for(FDS_KPI_Reporting__c rep :
						[SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Name IN: actionTypes AND Type_Of_Action__c IN: actionTypes]) {
							MAP_ACTION_TO_KPI_REPORTING.put(rep.Type_Of_Action__c, rep);
				}
			}
			return MAP_ACTION_TO_KPI_REPORTING;
		}
		set;
	}

	public static void publishPlatformEvent(Map<Id,sObject> sObjectMap, string platformEventName, string objectSource, boolean isInsert, boolean isUpdate, boolean isDelete, boolean isUndelete){
		if((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0 && !System.isFuture() && !System.isBatch()) {
			System.enqueueJob(new PlatformEvents_Helper(sObjectMap, platformEventName, objectSource, isInsert, isUpdate, isDelete, isUndelete));
		} else {
			PlatformEvents_Helper.publishEvents(sObjectMap, platformEventName, objectSource, isInsert, isUpdate, isDelete, isUndelete);
		}
	}

	public static void createKPIValues(Map<Id, Case> oldMap, Map<Id, Case> newMap, List<Case> newList) {
		if(isDone) return;
		Map<String, Map<String, ISSP_KPI_Reporting__mdt>> configsMap = new Map<String, Map<String, ISSP_KPI_Reporting__mdt>>();
		// initialize configs map
		for(String at: actionTypes)
				configsMap.put(at, new Map<String, ISSP_KPI_Reporting__mdt>());

		// get all configs since they are needed for filtering
		List<ISSP_KPI_Reporting__mdt> configs = getKPIConfig(actionTypes);
		if(configs.size() == 0) {
				System.debug('CaseTriggerHelper: missing mdt config, exiting');
				return;
		}

		List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();

		if(actionTypes.size() != MAP_ACTION_TO_KPI_REPORTING.size()) {
			// a KPI reporting for an action type is missing, abort, they all should be present
			System.debug('CaseTriggerHelper: KPI report for one of action types not present, aborting.');
			return;
		}

		String kpiReportingClosureId = MAP_ACTION_TO_KPI_REPORTING.get(CASE_ACTION_CASE_CLOSURE).Id;
		String kpiReportingEscalationId = MAP_ACTION_TO_KPI_REPORTING.get(CASE_ACTION_CASE_ESCALATION).Id;
		String kpiReportingReopeningId = MAP_ACTION_TO_KPI_REPORTING.get(CASE_ACTION_CASE_REOPENING).Id;
		String kpiReportingNOIId = MAP_ACTION_TO_KPI_REPORTING.get(CASE_ACTION_SEND_NOI).Id;

		Set<Id> allConsidered = new Set<Id>();
		Set<Id> consideredForClosure = new Set<Id>();
		Set<Id> consideredForEscInt = new Set<Id>();
		Set<Id> consideredForReopen = new Set<Id>();
		Set<Id> consideredForNOI = new Set<Id>();

		List<String> closure_fromStatus;
		List<String> closure_toStatus;
		List<String> escalation_fromStatus;
		List<String> escalation_toStatus;
		List<String> reopening_fromStatus;
		List<String> reopening_toStatus;
		List<String> noi_fromStatus;
		List<String> noi_toStatus;

		for(ISSP_KPI_Reporting__mdt cfg : configs) {
			if(cfg.Action__c == CASE_ACTION_CASE_CLOSURE) {
				configsMap.get(CASE_ACTION_CASE_CLOSURE).put(cfg.Case_Record_Type__c, cfg);
			}else if(cfg.Action__c == CASE_ACTION_CASE_ESCALATION) {
				configsMap.get(CASE_ACTION_CASE_ESCALATION).put(cfg.Case_Record_Type__c, cfg);
			} else if(cfg.Action__c == CASE_ACTION_CASE_REOPENING) {
				configsMap.get(CASE_ACTION_CASE_REOPENING).put(cfg.Case_Record_Type__c, cfg);
			} else if(cfg.Action__c == CASE_ACTION_SEND_NOI) {
				configsMap.get(CASE_ACTION_SEND_NOI).put(cfg.Case_Record_Type__c, cfg);
			}
		}

		// filter out the cases that need to be treated
		for(Case newCase: newList) {
			Case oldCase = oldMap==null? null: oldMap.get(newCase.Id); // oldmap is only available for update trigger, for insert oldCase is null
			String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', newCase.RecordTypeId).DeveloperName;
			//Exclude All TIDS Cases from KPI processing
			if (cRTDevName=='TIDS'){ continue;}

			if(configsMap.get(CASE_ACTION_CASE_CLOSURE).keySet().contains(cRTDevName)) {
				closure_fromStatus = configsMap.get(CASE_ACTION_CASE_CLOSURE).get(cRTDevName).Status_From__c.split(',');
				closure_toStatus = configsMap.get(CASE_ACTION_CASE_CLOSURE).get(cRTDevName).Status_To__c.split(',');
			}
			if(configsMap.get(CASE_ACTION_CASE_ESCALATION).keySet().contains(cRTDevName)) {
				escalation_fromStatus = configsMap.get(CASE_ACTION_CASE_ESCALATION).get(cRTDevName).Status_From__c.split(',');
				escalation_toStatus = configsMap.get(CASE_ACTION_CASE_ESCALATION).get(cRTDevName).Status_To__c.split(',');
			}
			if(configsMap.get(CASE_ACTION_CASE_REOPENING).keySet().contains(cRTDevName)) {
				reopening_fromStatus = configsMap.get(CASE_ACTION_CASE_REOPENING).get(cRTDevName).Status_From__c.split(',');
				reopening_toStatus = configsMap.get(CASE_ACTION_CASE_REOPENING).get(cRTDevName).Status_To__c.split(',');
			}

			String oldStatus = oldCase==null? EMPTY_KEYWORD: oldCase.Status;

			// case closure
			if(configsMap.get(CASE_ACTION_CASE_CLOSURE).keySet().contains(cRTDevName) && closure_fromStatus.contains(oldStatus) && closure_toStatus.contains(newCase.Status)) {
				consideredForClosure.add(newCase.Id);
				allConsidered.add(newCase.Id);
			}

			// case reopening
			if(configsMap.get(CASE_ACTION_CASE_REOPENING).keySet().contains(cRTDevName) && reopening_fromStatus.contains(oldStatus) && reopening_toStatus.contains(newCase.Status) && reopening_reasons.contains(newCase.Reopening_Reason__c)) {
				consideredForReopen.add(newCase.Id);
				allConsidered.add(newCase.Id);
			}

			// escalation
			if(configsMap.get(CASE_ACTION_CASE_ESCALATION).keySet().contains(cRTDevName) && escalation_fromStatus.contains(oldStatus) && escalation_toStatus.contains(newCase.Status)) {
				consideredForEscInt.add(newCase.Id);
				allConsidered.add(newCase.Id);
			}

			// NOI sent
			if(newMap.get(newCase.Id).NOI_sent__c != null && oldCase != null && oldCase.NOI_sent__c == null && configsMap.get(CASE_ACTION_SEND_NOI).keySet().contains(cRTDevName)){
				consideredForNOI.add(newCase.Id);
				allConsidered.add(newCase.Id);
			}
		}

		if(allConsidered.size() == 0) {
			System.debug('+++CaseTriggerHelper: no cases to consider');
			return;
		}

		Map<Id, List<KPI_Value__c>> typeOfActionClosureMap = new Map<Id, List<KPI_Value__c>>();

		if(!consideredForClosure.isEmpty()) {
			// find registered case closures from past
			List<KPI_Value__c> claimingClosures = [SELECT Id, Responsible__c, CaseNumber__c,CaseNumber__r.RecordTypeId, FDS_KPI_Reporting__c, FDS_KPI_Reporting__r.Type_Of_Action__c, CreatedById, KPI_Value__c FROM KPI_Value__c WHERE CaseNumber__c IN :consideredForClosure AND FDS_KPI_Reporting__r.Type_Of_Action__c=:CASE_ACTION_CASE_CLOSURE];
			
			for(KPI_Value__c cc: claimingClosures) {
				if(typeOfActionClosureMap.get(cc.CaseNumber__c) == null){
					typeOfActionClosureMap.put(cc.CaseNumber__c, new List<KPI_Value__c>());
					typeOfActionClosureMap.get(cc.CaseNumber__c).add(cc);
				} else {
					typeOfActionClosureMap.get(cc.CaseNumber__c).add(cc);
				}
			}
		}

		// closure
		for(Id cId: consideredForClosure) {
			Case newCase = newMap.get(cId);
			Case oldCase = oldMap==null? null: oldMap.get(cId);
			String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', newCase.RecordTypeId).DeveloperName;

			String oldStatus = oldCase==null? EMPTY_KEYWORD: oldCase.Status;

			// sprint6 if a case is close as part of same query
			// substract from original user while awarding the new one
			Integer points = configsMap.get(CASE_ACTION_CASE_CLOSURE).get(cRTDevName).Points__c.intValue();
			Boolean flagKPI = false;
			if(String.isNotBlank(newCase.Reopening_reason__c) && newCase.Status=='Closed' && oldStatus=='Reopen' && !reopening_reasons.contains(newCase.Reopening_Reason__c)){
				points = 0;
			} else if(newCase.Status=='Closed' && oldStatus!='Reopen' && typeOfActionClosureMap.get(cId) != null){
				List<KPI_Value__c> caseKpiValues = typeOfActionClosureMap.get(cId);
				
				for(KPI_Value__c kpiValue : caseKpiValues) {
					if((kpiValue.CreatedById == UserInfo.getUserId() && kpiValue.CaseNumber__r.RecordTypeId == complaintRT && kpiValue.KPI_Value__c == points))
						flagKPI = true;
				}
			}
			if(!flagKPI) {
				KPI_Value__c valueToInsert = createKPIReportingValue(newCase, points, kpiReportingClosureId, UserInfo.getUserId());
				kpiValuesToInsert.add(valueToInsert);
			}
		}

		// case internal escalation
		for(Id cId: consideredForEscInt) {
			Case newCase = newMap.get(cId);
			String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', newCase.RecordTypeId).DeveloperName;
			KPI_Value__c valueToInsert = createKPIReportingValue(newCase, Integer.valueOf(configsMap.get(CASE_ACTION_CASE_ESCALATION).get(cRTDevName).Points__c.intValue()), kpiReportingEscalationId, UserInfo.getUserId());
			kpiValuesToInsert.add(valueToInsert);
		}

		// case reopen
		if(!consideredForReopen.isEmpty()) {
			Map<Id, KPI_Value__c> typeOfActionReopenedMap = new Map<Id, KPI_Value__c>();

			// find registered case reopened from past
			List<KPI_Value__c> claimingForReopen = [SELECT Id, Responsible__c, CaseNumber__c FROM KPI_Value__c WHERE CaseNumber__c IN :consideredForReopen AND FDS_KPI_Reporting__r.Type_Of_Action__c=:CASE_ACTION_CASE_CLOSURE order by createdDate desc];
			
			for(KPI_Value__c cr: claimingForReopen) {
				if(typeOfActionReopenedMap.get(cr.CaseNumber__c) == null){
					typeOfActionReopenedMap.put(cr.CaseNumber__c, cr);
				}
			}
			for(Id cId: consideredForReopen) {
				Case newCase = newMap.get(cId);
				KPI_Value__c kpv = typeOfActionReopenedMap.get(cId);
				String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', newCase.RecordTypeId).DeveloperName;
				Integer points = Integer.valueOf(configsMap.get(CASE_ACTION_CASE_REOPENING).get(cRTDevName).Points__c.intValue());
				
				if(!reopening_reasons.contains(newCase.Reopening_Reason__c))
					points = 0;
				KPI_Value__c valueToInsert = createKPIReportingValue(newCase, points,kpiReportingReopeningId, (kpv != null ? kpv.Responsible__c : UserInfo.getUserId()));
				kpiValuesToInsert.add(valueToInsert);
			}
		}
		
		

		// NOI sent
		for(Id cId: consideredForNOI) {
			Case newCase = newMap.get(cId);
			String cRTDevName = RecordTypeSingleton.getInstance().getRecordTypeById('Case', newCase.RecordTypeId).DeveloperName;
			KPI_Value__c valueToInsert = createKPIReportingValue(newCase, Integer.valueOf(configsMap.get(CASE_ACTION_SEND_NOI).get(cRTDevName).Points__c.intValue()),kpiReportingNOIId, UserInfo.getUserId());
			kpiValuesToInsert.add(valueToInsert);
		}

		try{
			if(kpiValuesToInsert.size() > 0 ){
				insert kpiValuesToInsert;
			}
		} catch(DmlException e) {
			system.debug('LW insert error: ' + e.getMessage());
		}

		CaseTriggerHelper.isDone = true;
	}


	public static List<ISSP_KPI_Reporting__mdt> getKPIConfig(List<String> actionTypes) {
		return [SELECT Id, Action__c, Case_Record_Type__c, Field_API_Name__c, Value_To__c, Points__c, Reopening_Reason__c,  Status_From__c, Status_To__c, Type_of_Task__c, Value_From__c FROM ISSP_KPI_Reporting__mdt WHERE Action__c IN :actionTypes];
	}

	public static KPI_Value__c createKPIReportingValue(Case caseToProcess, Integer points, String kpiReportingId, Id responsible){
		KPI_Value__c valueToAdd = new KPI_Value__c();

		valueToAdd.Name = 'Value_' + caseToProcess.Id + '_' + System.now().format('hh_mm_ss');
		valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
		valueToAdd.CaseNumber__c = caseToProcess.Id;
		valueToAdd.Month__c = System.now().format('MMMM');
		valueToAdd.Year__c = String.valueOf(Date.today().year());
		valueToAdd.KPI_Value__c = points;
		valueToAdd.Responsible__c = responsible;

		return valueToAdd;
	}

	public static void avoidSavingLastAutoCommentsInCase(List<Case> cases, Map<Id, Case> oldCases) {
		for (Case current : cases) {
			Case old = oldCases == null ? null : oldCases.get(current.Id);
			if(old != null && current.E2CP__Most_Recent_Public_Comment__c != null && current.E2CP__Most_Recent_Public_Comment__c != old.E2CP__Most_Recent_Public_Comment__c && 
				(current.E2CP__Most_Recent_Public_Comment__c.startsWith(CaseCommentAutoReply.AUTO_REPLY_ID) || current.E2CP__Most_Recent_Public_Comment__c.startsWith(CaseCommentAutoReply.USER_ANSWER_ID))) {
					current.E2CP__Most_Recent_Public_Comment__c = old.E2CP__Most_Recent_Public_Comment__c;
			}
			else if(old == null && current.E2CP__Most_Recent_Public_Comment__c != null &&
				(current.E2CP__Most_Recent_Public_Comment__c.startsWith(CaseCommentAutoReply.AUTO_REPLY_ID) || current.E2CP__Most_Recent_Public_Comment__c.startsWith(CaseCommentAutoReply.USER_ANSWER_ID))) {
					current.E2CP__Most_Recent_Public_Comment__c = '';
				}
		}
	}

	public static void handleClosureStatus(List<Case> cases, Map<Id, Case> oldCases) {
		for (Case current : cases) {
			if(getPortalCaseClosureAvailableRecordTypes().contains(current.RecordTypeId)) {
				Case old = oldCases == null ? null : oldCases.get(current.Id);
				
				if ((old == null || old.Status != current.Status)
					&& current.Status == CASE_STATUS_PENDING_CLOSURE && current.Visible_on_ISS_Portal__c) {
						current.Portal_Closure_Status__c = CaseCommentAutoReply.CLOSURE_STATUS_STARTED;
						PortalCaseClosureController.CloseCaseLinkParams params = new PortalCaseClosureController.CloseCaseLinkParams(current.Id, current.contactId);
						current.Portal_Closure_Link__c = PortalCaseClosureController.getCloseCaseLink(params);
				}
				else if(old != null && current.Visible_on_ISS_Portal__c && old.Portal_Closure_Status__c != current.Portal_Closure_Status__c) {
					if(String.isBlank(current.Portal_Closure_Status__c) || current.Portal_Closure_Status__c == CaseCommentAutoReply.CLOSURE_STATUS_CLOSURE_DECLINED) {
						current.Status = CASE_STATUS_ACTION_NEEDED;
					}
					else if(CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_VALUES.contains(current.Portal_Closure_Status__c)) {
						current.Status = CASE_STATUS_CLOSED;
					}
				}
			}
		}
	}

	public static void handleAutoReplies(Map<Id, Case> cases, Map<Id, Case> oldCases) {
		List<Id> casesToGenerateComments = new List<Id>();
		for (Id caseId : cases.keySet()) {
			Case current = cases.get(caseId);
			if(getPortalCaseClosureAvailableRecordTypes().contains(current.RecordTypeId)) {
				Case old = oldCases == null ? null : oldCases.get(caseId);
				if (((old == null && current.Status == CASE_STATUS_PENDING_CLOSURE) ||
					(old != null && (old.Status != current.Status || old.Portal_Closure_Status__c != current.Portal_Closure_Status__c) &&
						(current.Status == CASE_STATUS_PENDING_CLOSURE || current.Status == CASE_STATUS_CLOSED ||
							(current.Status == CASE_STATUS_ACTION_NEEDED && current.Portal_Closure_Status__c == CaseCommentAutoReply.CLOSURE_STATUS_CLOSURE_DECLINED)
						) && current.Visible_on_ISS_Portal__c)
					) && !CaseCommentAutoReply.isProcessed(current.Id)) {
						casesToGenerateComments.add(current.Id);
				}
			}
		}
		if (!casesToGenerateComments.isEmpty()) {
			CaseCommentAutoReply autoReplies = new CaseCommentAutoReply(casesToGenerateComments);
			if(PortalCasesCtrl.updatingClosureStatus) {
				autoReplies.execute(null);
			}
			else {
				System.enqueueJob(autoReplies);
			}
		}
	}

	public static List<Id> getPortalCaseClosureAvailableRecordTypes() {
		if(portalPendingClosureRecordTypes == null) {
			portalPendingClosureRecordTypes = RecordTypeSingleton.getInstance().getRecordTypeObjIdListForSpecfifiedNames('Case', PORTAL_PENDING_CLOSURE_RECORD_TYPES);
		}
		return portalPendingClosureRecordTypes;
	}

}