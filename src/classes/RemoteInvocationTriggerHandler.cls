public with sharing class RemoteInvocationTriggerHandler {

	//Trigger variables
	public List<Remote_Invocation__c> triggerNew = (List<Remote_Invocation__c>) Trigger.new;
	public List<Remote_Invocation__c> triggerOld = (List<Remote_Invocation__c>) Trigger.old;
	public Map<Id, Remote_Invocation__c> newMap = (Map<Id,Remote_Invocation__c>) Trigger.newMap;
	public Map<Id, Remote_Invocation__c> oldMap = (Map<Id,Remote_Invocation__c>) Trigger.oldMap;

	//Remote Invocation Request Types
	public static final String NEWGEN_EASY_PAY = 'ANG_IEP_MODEL_A';
	public static final String TIP_IFG_REPORT  = 'TIP_IFG_REPORT';
	public static final String NEWGEN_GDI_ENDO  = 'TIP_IFG_REPORT';

	//Remote Invocation Status
	public static final String REMOTE_INVOCATION_STATUS_INITIALIZING = 'Initializing';
	public static final String REMOTE_INVOCATION_STATUS_PROGRESS     = 'In Progress';

	//Remote Invocation Recordtypes
	public static final ID RECTYPE_NEWGEN = RecordTypeSingleton.getInstance().getRecordTypeId('Remote_Invocation__c', NEWGEN_EASY_PAY);
	public static final ID RECTYPE_TIP    = RecordTypeSingleton.getInstance().getRecordTypeId('Remote_Invocation__c', TIP_IFG_REPORT);
	public static final ID RECTYPE_GDI    = RecordTypeSingleton.getInstance().getRecordTypeId('Remote_Invocation__c', NEWGEN_GDI_ENDO);

	//to store the remote invocations with errors
	public Set<ID> remoteInvocationWithErrors;

	private Map<String,Account> mapIATACodeAccs;

	private Map<String,String> mapTypeRecordtype = new Map<String,String>{	NEWGEN_EASY_PAY => RECTYPE_NEWGEN,
																			TIP_IFG_REPORT  => RECTYPE_TIP,
																			NEWGEN_GDI_ENDO => RECTYPE_GDI};



	private final List<String> typesToProcess = new List<String>{'ANG_IEPRemoteInvocation','ANG_DGIRemoteInvocation'};

	public RemoteInvocationTriggerHandler(){
	}

	public void handleAfterInsert(){
		handlePlatformEvent();
	}

	public void handleAfterUpdate(){
		handlePlatformEvent();
	}

	public void handleAfterDelete(){
		handlePlatformEvent();
	}

	public void handleAfterUndelete(){
		handlePlatformEvent();
	}

	public void handleBeforeInsert(){
		assignRecordtypeToRequest();
	}

	public void handleBeforeUpdate(){
		processInvocationsInProgress();
	}


	public void assignRecordtypeToRequest(){
		for(Remote_Invocation__c er : triggerNew){
			er.recordtypeid = (er.Request_Type__c == NEWGEN_EASY_PAY ? RECTYPE_NEWGEN : RECTYPE_TIP);
		}
	}

	public void handlePlatformEvent(){
		for(Remote_Invocation__c re : triggerNew){

			//if oldmap doesn't contain id, trigger is insert. Note: this method only runs on after, id is allways populated 
			if((oldMap == null || ( oldMap != null && oldMap.get(re.id).Status__c != re.Status__c)) && (re.Status__c == 'Completed' || re.Status__c == 'Failed'))
				PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'RemoteInvocation__e', 'Remote_Invocation__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
		}
	}

	public void processInvocationsInProgress(){
		
		Set<Remote_Invocation__c> remoteInvocationsIdToProcess = new Set<Remote_Invocation__c>();
		
		for(Remote_Invocation__c re :  triggerNew){
			if(re.Status__c == REMOTE_INVOCATION_STATUS_PROGRESS && oldMap.get(re.Id).Status__c == REMOTE_INVOCATION_STATUS_INITIALIZING){
				remoteInvocationsIdToProcess.add(re);
			}
		}
		
		if(remoteInvocationsIdToProcess.isEmpty()) return; // move along, nothing to see here ...

		for(String classType: typesToProcess){
			
			// Get the Type corresponding to the class name
			Type t = Type.forName(classType);

			ANG_RemoteInvocationINT processor = (ANG_RemoteInvocationINT)t.newInstance();

			processor.doSanityCheck(remoteInvocationsIdToProcess);

			processor.doProcess(remoteInvocationsIdToProcess);

		}

	}


}
