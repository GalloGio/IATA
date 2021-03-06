public with sharing class ISSP_AMC_FlowDAO {
	//For getting users list from custom settings object

	@AuraEnabled
	public static Map<Id, String> getUsersCustomSettingList(){
		Map<Id, String> picklistUserInfo = new Map<Id, String>();
		for (ISSP_AMC_Approval_Process__c setting : ISSP_AMC_Approval_Process__c.getAll().values()){

			id userId = UserInfo.getUserId();

			if(setting.Id_user__c != userId){

				picklistUserInfo.put(setting.Id_user__c, setting.Name);
			}

		}
		return picklistUserInfo;
	}

	@AuraEnabled
	public static void updateStepActionApprovelProcessUser(Id stepActionId, Id approvelUserId){
		IATA_Process_Orchestrator_Step_Action__c stepAction = new IATA_Process_Orchestrator_Step_Action__c();
		stepAction.Id = stepActionId;
		stepAction.Approver__c = approvelUserId;
		update stepAction;
	}

	@AuraEnabled
	public static Map <String, String> getStageWithStatusMap(Id processOrchestratorId){
		Map <String, String> stageWithStatusMap = new Map <String, String> ();

		List <IATA_Process_Orchestrator__c> processList = new List <IATA_Process_Orchestrator__c>([
				SELECT  Id, Status__c, Process_Step_Name__c, Process_Step_Stage__c, Associated_Case__c
				FROM    IATA_Process_Orchestrator__c
				WHERE   IATA_Orchestrator_Process__c = :processOrchestratorId AND Process_Step_Stage__c != null
		ORDER BY Process_Step_Stage__c
		]);

		if(!processList.isEmpty()){
			for(IATA_Process_Orchestrator__c process : processList){
				stageWithStatusMap.put(process.Process_Step_Stage__c.replace('_', ' ') + '#' + process.Process_Step_Name__c, process.Status__c);
				//stageWithStatusMap.put(process.Process_Step_Stage__c + '#' + process.Process_Step_Name__c, process.Status__c);
				//System.debug('TESTE ' + process.Process_Step_Stage__c + '#' + process.Process_Step_Name__c);
			}

		}


		return stageWithStatusMap;
	}

	@AuraEnabled
	public static Boolean disableButton(Id caseId){
		Case caseFromConsole = [SELECT id, Coding_Application_ID__c, (SELECT Id, RecordType.DeveloperName FROM Participation_Online_Applications__r) FROM Case WHERE id =: caseId];
		if(caseFromConsole.Participation_Online_Applications__r[0].RecordType.DeveloperName == 'Location_Code' || caseFromConsole.Participation_Online_Applications__r[0].RecordType.DeveloperName == 'Baggage_Code'){
			caseFromConsole.Coding_Application_ID__c = 'Not Applicable';
			update caseFromConsole;

			return true;
		}

		if(caseFromConsole.Coding_Application_ID__c != null){
			return true;
		}

		return false;
	}

	@AuraEnabled
	public static List <PicklistInfo> getPicklistsFromProcessOrchestrator(Id processOrchestratorId, String stage){
		List <PicklistInfo> picklistInfoList = new List <PicklistInfo>();
		List <IATA_Process_Orchestrator_Step_Action__c> stepActionList = new List <IATA_Process_Orchestrator_Step_Action__c>([
				SELECT  Id, Action_name__c, IATA_Process_Orchestrator__r.Process_Step_Name__c, IATA_Process_Orchestrator__r.Process_Step_Stage__c, Status__c
				FROM    IATA_Process_Orchestrator_Step_Action__c
				WHERE   IATA_Process_Orchestrator__r.IATA_Orchestrator_Process__c = :processOrchestratorId
		AND     IATA_Process_Orchestrator__r.Process_Step_Stage__c = :stage
		]);

		if(!stepActionList.isEmpty()){
			Schema.DescribeFieldResult fieldResult = IATA_Process_Orchestrator_Step_Action__c.Status__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

			PicklistInfo picklistInfo;
			for(IATA_Process_Orchestrator_Step_Action__c stepActionItem : stepActionList){
				picklistInfo = new PicklistInfo();
				picklistInfo.stepActionId = stepActionItem.Id;
				picklistInfo.stepActionName = stepActionItem.Action_name__c;
				picklistInfo.stepStatus = stepActionItem.Id + '#' + stepActionItem.Status__c;

				picklistInfo.pickListValueMap = new Map <String, String>();
				for( Schema.PicklistEntry pickListVal : ple){
					picklistInfo.pickListValueMap.put(stepActionItem.Id + '#' + pickListVal.getLabel(), pickListVal.getLabel());
				}

				picklistInfoList.add(picklistInfo);
			}
		}

		return picklistInfoList;
	}

	@AuraEnabled
	public static Map<String, String> sendCaseCtr(Id caseId){
		Map<String, String> errorMessageByStatus;
		HttpResponse res = new HttpResponse();
		try {
			/*List<Case> casesToSendList = new List<Case>([SELECT id FROM Case WHERE id =: caseId]);
			if(!casesToSendList.isEmpty()){*/
			res = ISSP_AMC_Integration.doPost(caseId);
			ISSP_AMC_Integration.ACLIResponse acliResponse = (ISSP_AMC_Integration.ACLIResponse)JSON.deserialize(res.getBody(),ISSP_AMC_Integration.ACLIResponse.class);

			if(acliResponse.errors != null && !acliResponse.errors.isEmpty()){
				errorMessageByStatus = new Map<String, String>();
				for(ISSP_AMC_Integration.Error error : acliResponse.errors){
					errorMessageByStatus.put(error.status, error.detail);
				}
			}

			if(!String.isEmpty(acliResponse.error)){
				if(errorMessageByStatus == null){
					errorMessageByStatus = new Map<String, String>();
				}
				errorMessageByStatus.put(String.valueOf(res.getStatusCode()), acliResponse.error);
			}

		}catch(Exception e){
			System.debug(LoggingLevel.ERROR,
					'Error trying to send case');
		}

		return errorMessageByStatus;
	}

	@AuraEnabled
	public static ACLI_Process__mdt loadURL(){
		ACLI_Process__mdt configs = new ACLI_Process__mdt();

		try{
			configs = [SELECT Generate_Letter_del__c FROM ACLI_Process__mdt LIMIT 1][0];
		} catch(Exception e){
			System.debug(LoggingLevel.ERROR,
					'ERROR when trying to get URL');
		}

		return configs;
	}

	/*@AuraEnabled
public static void apiCall(){
ISSP_AMC_ApiCallLightningComponent.makeAPICall();
}*/

	@AuraEnabled
	public static void requestForApproval(Id processOrchestratorId, String stage){

		stage = stage.replace(' ', '_');

		List <IATA_Process_Orchestrator_Step_Action__c> stepActionList = new List <IATA_Process_Orchestrator_Step_Action__c>([
				SELECT  Id, Action_name__c, IATA_Process_Orchestrator__r.Process_Step_Name__c, IATA_Process_Orchestrator__r.Process_Step_Stage__c, Status__c , Approver__c
				FROM    IATA_Process_Orchestrator_Step_Action__c
				WHERE   IATA_Process_Orchestrator__r.IATA_Orchestrator_Process__c = :processOrchestratorId
		AND     IATA_Process_Orchestrator__r.Process_Step_Stage__c = :stage
		]);

		if(stepActionList != null && !stepActionList.isEmpty()){
			// Create an approval request for the case
			Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
			request.setComments('Submitting request for approval.');
			request.setObjectId(stepActionList.get(0).Id);

			// Submit the record to specific process
			request.setProcessDefinitionNameOrId('ACLI_Approve_Code_Assignment2');

			// set nex approver ids (mandatory)
			//request.setNextApproverIds(new Id[] {UserInfo.getUserId()});

			request.setNextApproverIds(new Id[] { stepActionList.get(0).Approver__c });

			// Submit on behalf of a specific submitter
			//request.setSubmitterId(user1.Id);

			// Submit the approval request for the case

			Approval.ProcessResult result = Approval.process(request);
		}
	}


	/*public static Map<String, RecordType> getRecordTypesForObject(String sobjectName) {
Map<String, RecordType> recordTypes = new Map<String, RecordType>();
for (RecordType rt : [  SELECT  Id,Name,SobjectType,DeveloperName
FROM    RecordType
WHERE   SobjectType = :sobjectName AND IsActive = true]){
recordTypes.put(rt.DeveloperName, rt);
}
return recordTypes;
}*/

	@AuraEnabled
	public static void createRelatedCases(Id caseId, String stage){
		Case relatedCase = new Case();

		Id recordTypeIdStageC = Schema.SObjectType.Case.RecordTypeInfosByName.get('Invoicing Collection Cases').RecordTypeId;
		Id recordTypeIdStageB = Schema.SObjectType.Case.RecordTypeInfosByName.get('Internal Cases (IDFS ISS)').RecordTypeId;
		Id recordTypeIdStageF = Schema.SObjectType.Case.RecordTypeInfosByName.get('IDFS Airline Participation Process').RecordTypeId;
		//Id recordTypeId = getRecordTypesForObject('Case').get('Airline_Coding_Application').Id;
		List<Case> parentCases = [Select id, RecordTypeId, Type, Subject, ParentId, CaseArea__c, Region__c,
				Reason, Status, BSPCountry__c, Description, Account.Name, Account.ACLI_SAP_Id__c,
				ContactEmail, AccountId, ContactId, Coding_Application_Status__c, Priority, Origin, Account.Site,
				(SELECT SIS_First_Name__c, SIS_Last_Name__c, SIS_Email__c, SIS_Phone__c FROM Participation_Online_Applications__r)
				FROM Case WHERE id  =: caseId
		AND RecordType.DeveloperName = 'Airline_Coding_Application'];

		//Map <String, String> stageWithStatusMap = getStageWithStatusMap(processOrchestratorId);

		if(!parentCases.isEmpty()){
			Case parentCase = parentCases[0];
			relatedCase.ParentId  = caseId;
			relatedCase.Region__c = parentCase.Region__c;
			relatedCase.BSPCountry__c = parentCase.BSPCountry__c;
			relatedCase.Coding_Application_Status__c = parentCase.Coding_Application_Status__c;
			relatedCase.Priority = parentCase.Priority;
			relatedCase.Origin = parentCase.Origin;
			relatedCase.Assign__c = true;
			//relatedCase.Account.Site = parentCase.Account.Site;
			relatedCase.AccountId = parentCase.AccountId;
			relatedCase.ContactId = parentCase.ContactId;
			string descriptionB = 'Dear Team,' + '\n' + 'Please process DD for new applicant. Attached you will find usual documentation.' + '\n' + 'Thank you,' + '\n' + 'Coding Team';
			string descriptionC = 'Dear Colleagues,' + '\n' + 'Would you please raise a PPA for this customer with the following items (using current year price list):' + '\n' + 'Application Fee x 1' + '\n' + 'Assignment Fee x 1' + '\n' + 'BRgds,' + '\n' + 'Coding Team';
			string descriptionF = '';
			if(parentCase.Participation_Online_Applications__r != null && parentCase.Participation_Online_Applications__r[0] != null){
				descriptionF = 'Dear Team,' + '\n' + 'Kindly find below information required to create the SIS Registration:' + '\n' + 'Name: ' + parentCase.Participation_Online_Applications__r[0].SIS_First_Name__c + '\n' + 'Last Name: ' + parentCase.Participation_Online_Applications__r[0].SIS_Last_Name__c + '\n' + 'Email Address : ' + parentCase.Participation_Online_Applications__r[0].SIS_Email__c + '\n' + 'Phone Number: ' + parentCase.Participation_Online_Applications__r[0].SIS_Phone__c + '\n' + 'Thank you,' + '\n' + 'Coding Team';
			}

			//Fetching the assignment rules on case
			AssignmentRule AR = new AssignmentRule();
			AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
			//Creating the DMLOptions for "Assign using active assignment rules" checkbox
			Database.DMLOptions dmlOpts = new Database.DMLOptions();
			dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

			if(stage == 'Stage B'){
				relatedCase.CaseArea__c = 'Corporate Compliance';
				relatedCase.Reason = 'New Coding Assignment';
				relatedCase.Reason1__c = 'New Coding Assignment';
				relatedCase.Subject = 'Due Diligence – ' + parentCase.Account.Name;
				relatedCase.Status = 'Open';
				relatedCase.Description = descriptionB;
				relatedCase.RecordTypeId = recordTypeIdStageB;
			}else if(stage == 'Stage C'){
				if(parentCase.Account.ACLI_SAP_Id__c == null){
					parentCase.Account.ACLI_SAP_Id__c = 'No value';
				}
				relatedCase.CaseArea__c = 'Invoicing';
				//relatedCase.Reason = 'Customer Charge Request';
				relatedCase.Reason = 'Customer Charge Request';
				relatedCase.Reason1__c = 'Customer Charge Request';
				relatedCase.Subject = 'PPA - Charge Request for ' + parentCase.Account.Name + ' – ' + parentCase.Account.ACLI_SAP_Id__c;
				relatedCase.Status = 'Open';
				relatedCase.Description = descriptionC;
				relatedCase.RecordTypeId = recordTypeIdStageC;
			}else if(stage == 'Stage F'){
				relatedCase.CaseArea__c = 'Airline Change';
				relatedCase.Reason = 'SIS Client';
				relatedCase.Reason1__c = 'SIS Client';
				relatedCase.Subject = 'SIS New Register – ' + parentCase.Account.Name;
				relatedCase.Status = 'Open';
				relatedCase.Type = 'SIS Internal Case';
				relatedCase.Description = descriptionF;
				relatedCase.RecordTypeId = recordTypeIdStageF;
			}

			try{
				//Setting the DMLOption on Case instance
				relatedCase.setOptions(dmlOpts);
				insert relatedCase;
			}catch(Exception e){
				System.debug(LoggingLevel.ERROR,
						'ERROR when trying to insert a related case');
			}
		}
	}

	@AuraEnabled
	public static void updateStepAction(Id stepActionId, String stepStatus){
		IATA_Process_Orchestrator_Step_Action__c stepAction = new IATA_Process_Orchestrator_Step_Action__c();
		stepAction.Id = stepActionId;
		stepAction.Status__c = stepStatus;
		update stepAction;
	}

	public class PicklistInfo {
		@AuraEnabled
		public Id stepActionId {get;set;}
		@AuraEnabled
		public String stepActionName {get;set;}
		@AuraEnabled
		public String stepStatus {get;set;}
		@AuraEnabled
		public Map <String, String> pickListValueMap {get;set;}

	}

	public class customException extends Exception {}
}
