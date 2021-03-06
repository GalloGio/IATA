public with sharing class CaseCommentHandler {
	public static final String CASE_COMMENT_ACTION = 'Public Case Comment';
	
	public static List<KPI_Value__c> kpiValuesToInsert = new List<KPI_Value__c>();
	public static Boolean caseCommentKPI = false;
	public CaseCommentHandler(){}

	public static void doBeforeInsert(list<CaseComment> listComments) {
		// check if the incoming casecomment comes from E2CP process
		if (getE2cpRunUsers().contains(UserInfo.getUSerId())) {
			preventInsertionInClosedCases(listComments);
		}
	}
	
	//creates a map of CaseId and CaseCommentId for Cases with CaseComments
	private static Map<Id,Id> getCaseCommentsForCases(List<CaseComment> listOfComments){
		Map<Id,Id> caseCommentIdToCaseIdMap = new Map<Id,Id>();
		for(CaseComment caseComment : listOfComments){
			caseCommentIdToCaseIdMap.put(caseComment.Id, caseComment.ParentId);
		}
		return caseCommentIdToCaseIdMap;
	}

	public static void doAfterInsert(Set<Id> CaseCommentIds) {
		//only fire integration if user making the insert is not integration user
		//1. if case comment is for a case with a case item then fire platform event

		List<CaseComment> fullCaseComments = [SELECT id, isPublished, ParentId, Parent.Portal_Closure_Status__c, Parent.RecordTypeId, Parent.RecordType.DeveloperName
											  FROM CaseComment WHERE Id IN :CaseCommentIds];
		
		if(fullCaseComments.isEmpty()) return;

		List<ISSP_KPI_Reporting__mdt> config = new List<ISSP_KPI_Reporting__mdt>();
		Map<String, ISSP_KPI_Reporting__mdt> rtToConfigMap = new Map<String, ISSP_KPI_Reporting__mdt>();
		Set<Id> recordTypesToProcess = new Set<Id>();
		
		config = getKPIConfig(CASE_COMMENT_ACTION);

		if(config.isEmpty()) {return;}

		List<FDS_KPI_Reporting__c> kpiReporting = [SELECT Id, Type_Of_Action__c 
												   FROM FDS_KPI_Reporting__c 
												   WHERE Name =: CASE_COMMENT_ACTION 
												   AND Type_Of_Action__c =: CASE_COMMENT_ACTION FOR UPDATE];
		if(kpiReporting.isEmpty()) {return;}

		for(ISSP_KPI_Reporting__mdt cfg : config){
			recordTypesToProcess.add(RecordTypeSingleton.getInstance().getRecordType('Case', cfg.Case_Record_Type__c).Id);
			rtToConfigMap.put(cfg.Case_Record_Type__c, cfg);
		}
		
		Id kpiReportingId = kpiReporting.get(0).Id;
		
		for (CaseComment cc : fullCaseComments) {
			if (UserInfo.getUserType() == 'Standard' && rtToConfigMap.containsKey(cc.Parent.RecordType.DeveloperName) && !(cc.Parent.Portal_Closure_Status__c != null && CaseCommentAutoReply.AUTO_REPLY_ELIGIBLE_STATUS.contains(cc.Parent.Portal_Closure_Status__c))) {
				createKPIReportingValue(cc, Integer.valueOf(rtToConfigMap.get(cc.Parent.RecordType.DeveloperName).Points__c), kpiReportingId);
			}
		}
		
		if(kpiValuesToInsert.size() > 0 ) {
			insert kpiValuesToInsert;
			caseCommentKPI = true;
		}
	}

	@future
	public static void doAfterInsertFuture(Set<Id> CaseCommentIds){
		doAfterInsert(CaseCommentIds);
	}

	public void processCaseItems(List<CaseComment> listOfComments){
		//only fire integration if user making the insert is not integration user
		////1. if case comment is for a case with a case item then fire platform event
		Map<Id,Id> caseCommentIdToCaseIdMap = getCaseCommentsForCases(listOfComments);
		//get case item records with a case that has an inserted comment
		Map<Id,Case_Item__c> caseItemsWithCaseComments = new Map<Id,Case_Item__c> ([SELECT Id, RecordTypeId FROM Case_Item__c WHERE Case__c IN :caseCommentIdToCaseIdMap.values()]);
		//call update on related case items to fire integration
		CaseItems caseItems = new CaseItems(caseItemsWithCaseComments);
		caseItems.onAfterUpdate();
	}

	public void doAfterUpdate(Map<Id, CaseComment> updatedCaseCommentMap, Map<Id, CaseComment> originalCaseCommentMap){
		//1. if case comment is for a case with a case item then fire platform event
		//1.1 create map with CaseId and CommentId
		Map<Id,Id> caseCommentIdToCaseIdMap = getCaseCommentsForCases(updatedCaseCommentMap.values());
		//get case item records with a case that has an inserted comment
		Map<Id,Case_Item__c> caseItemsWithCaseComments = new Map<Id,Case_Item__c> ([SELECT Id, RecordTypeId FROM Case_Item__c WHERE Case__c IN :caseCommentIdToCaseIdMap.values()]);
		//call update on related case items to fire integration
		CaseItems caseItems = new CaseItems(caseItemsWithCaseComments);
		caseItems.onAfterUpdate();
	}

	public void doAfterDelete(Map<Id, CaseComment> deletedCaseCommentMap){
		//1. if case comment is for a case with a case item then fire platform event
		//1.1 create map with CaseId and CommentId
		Map<Id,Id> caseCommentIdToCaseIdMap = getCaseCommentsForCases(deletedCaseCommentMap.values());
		//get case item records with a case that has an inserted comment
		Map<Id,Case_Item__c> caseItemsWithCaseComments = new Map<Id,Case_Item__c> ([SELECT Id, RecordTypeId FROM Case_Item__c WHERE Case__c IN :caseCommentIdToCaseIdMap.values()]);
		//call update on related case items to fire integration
		CaseItems caseItems = new CaseItems(caseItemsWithCaseComments);
		caseItems.onAfterUpdate();
	}

	public void doAfterUndelete(Map<Id, CaseComment> unDeletedCaseCommentMap){
		//1. if case comment is for a case with a case item then fire platform event
		//1.1 create map with CaseId and CommentId
		Map<Id,Id> caseCommentIdToCaseIdMap = getCaseCommentsForCases(unDeletedCaseCommentMap.values());
		//get case item records with a case that has an inserted comment
		Map<Id,Case_Item__c> caseItemsWithCaseComments = new Map<Id,Case_Item__c> ([SELECT Id, RecordTypeId FROM Case_Item__c WHERE Case__c IN :caseCommentIdToCaseIdMap.values()]);
		//call update on related case items to fire integration
		CaseItems caseItems = new CaseItems(caseItemsWithCaseComments);
		caseItems.onAfterUpdate();
	}

	/**
	* @description used to retreive KPI Configuration from custom metadata: ISSP_KPI_Reporting__mdt
	*
	* @param null
	* @return List<ISSP_KPI_Reporting__mdt> - list of configs
	*/
	private static List<ISSP_KPI_Reporting__mdt> getKPIConfig(String actionType) {
		return [SELECT Action__c, Case_Record_Type__c, DeveloperName, Id, Points__c FROM ISSP_KPI_Reporting__mdt WHERE Action__c =: actionType];
	}

	/**
	* @description method will create KPI_Value__c record in database for existing FDS_KPI_Reporting__c
	*              with Type_Of_Action == 'Case Comment'. If not exists, then FDS_KPI_Reporting
	*              will be created with Type_Of_Action == 'Case Comment'
	*
	* @param comment - CaseComment record
	*
	* @return void
	*/
	private static void createKPIReportingValue(CaseComment comment, Integer points, String kpiReportingId){
		KPI_Value__c valueToAdd = new KPI_Value__c();
		
		valueToAdd.Name = 'Value_' + comment.ParentId + '_' + System.now().format('hh_mm_ss');
		valueToAdd.FDS_KPI_Reporting__c = kpiReportingId;
		valueToAdd.CaseNumber__c = comment.ParentId;
		valueToAdd.Month__c = System.now().format('MMMM');
		valueToAdd.Year__c = String.valueOf(Date.today().year());
		valueToAdd.KPI_Value__c = points;
		valueToAdd.Responsible__c = UserInfo.getUserId();
		
		kpiValuesToInsert.add(valueToAdd);
	}

	/**
	If an input case comment tries to insert then it is blocked, but only if:
	- case belongs to a list of RTs
	- Case is closed for more than 2 weeks
	- Incoming case comment is public
	**/
	private static void preventInsertionInClosedCases(list<CaseComment> listComments) {
		Set<Id> caseIds = new Set<Id>();
		for (CaseComment caseComment : listComments) {
			caseIds.add(caseComment.parentId);
		}
		
		Map<Id, Case> casesMap = new Map<Id, Case>([
			SELECT Id, ClosedDate
			FROM Case
			WHERE Id IN :caseIds
			AND RecordType.DeveloperName IN :EmailMessageHandler.LIST_VALID_RT]);
		
		List<CaseComment> caseComments = new List<CaseComment>();
		for (CaseComment caseComment : listComments) {
			Case parentCase = casesMap.get(caseComment.ParentId);
			if (caseComment.IsPublished && parentCase!=null && parentCase.ClosedDate < Date.today().addDays(-14)) {
				caseComment.addError('Case Comment ignored because the parent case is closed for more than 2 weeks'); // prevent insertion
			}
		}
	}
		
	/**
	Get an id list of all users runing the E2CP email service
	To check this manually go to:
	Setup->EmailService->select 'ProcessMessage' service->Check run users
	**/
	public static set<Id> TEST_E2CPRUNUSERS = new set<id>();
	private static set<Id> getE2cpRunUsers() {
		set<Id> listRunUsers = new set<Id>();
		// Apex class in Email to Case Premium used to process incoming emails
		list<ApexClass> listClasses = [Select Id  from ApexClass where Name = 'ProcessMessage'];
		//Find run as users related to the E2CP service
		for (EmailServicesAddress serviceAddress: [
			SELECT Id, RunAsUserId
			FROM EmailServicesAddress
			WHERE Function.ApexClassId IN :listClasses])
		{
			listRunUsers.add(serviceAddress.RunAsUserId);
		}
		return Test.isRunningTest()? TEST_E2CPRUNUSERS: listRunUsers;
	}
}