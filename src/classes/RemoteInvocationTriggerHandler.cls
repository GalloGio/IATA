public with sharing class RemoteInvocationTriggerHandler {

	//Trigger variables
	public static List<Remote_Invocation__c> triggerNew = (List<Remote_Invocation__c>) Trigger.new;
	public static List<Remote_Invocation__c> triggerOld = (List<Remote_Invocation__c>) Trigger.old;
	public static Map<Id, Remote_Invocation__c> newMap = (Map<Id,Remote_Invocation__c>) Trigger.newMap;
	public static Map<Id, Remote_Invocation__c> oldMap = (Map<Id,Remote_Invocation__c>) Trigger.oldMap;

	//Remote Invocation Request Types
	public static final String NEWGEN_EASY_PAY = 'ANG_IEP_MODEL_A';
	public static final String TIP_IFG_REPORT  = 'TIP_IFG_REPORT';

	//Remote Invocation Status
	public static final String REMOTE_INVOCATION_STATUS_INITIALIZING = 'Initializing';
	public static final String REMOTE_INVOCATION_STATUS_PROGRESS = 'Progress';

	//Remote Invocation Recordtypes
	public static final String RECTYPE_NEWGEN = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Remote_Invocation_Artefact__c').get(NEWGEN_EASY_PAY);
	public static final String RECTYPE_TIP    = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Remote_Invocation_Artefact__c').get(TIP_IFG_REPORT);


	private static Map<String,Account> mapIATACodeAccs;

	public static void handleBeforeInsert(){
		assignRecordtypeToRequest();
	}

	public static void handleAfterUpdate(){
		processInvocationsInProgress();
	}


	public static void assignRecordtypeToRequest(){
		
		for(Remote_Invocation__c er : triggerNew){
			er.recordtype = (er.Request_Type__c == NEWGEN_EASY_PAY ? RECTYPE_NEWGEN : RECTYPE_TIP);
		}
	}

	public static void processInvocationsInProgress(){
		Set<ID> parentIDs = new Set<ID>();
		for(Remote_Invocation__c re :  triggerNew){
			if(re.Status__c == REMOTE_INVOCATION_STATUS_PROGRESS && oldMap.get(re.Id).Status__c == REMOTE_INVOCATION_STATUS_INITIALIZING){
				parentIDs.add(re.id);
			}
		}
		List<Remote_Invocation_Artefact__c> artefacts = [SELECT ID, External_Id__c, Format__c, Internal_ID__c, Name__c, Previous_Version__c, Remote_Invocation__c, 
															Request_Result__c, Source__c, Status__C, Status_Detail__c, Valid_From__c, Valid_To__c, Version__c, Version_Notes__c
															FROM Remote_Invocation_Artefact__c WHERE Remote_Invocation__c IN :parentIDs];
		//if(!artefacts.isEmpty()) 

		//sendRequestToMulesoft(reqsToProcess);
	}
	
	//@future
	public static void sendRequestToMulesoft(list<Remote_Invocation__c> reqsToProcess){
		//TODO
	}
}