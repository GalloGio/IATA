public with sharing class RemoteInvocationTriggerHandler {

	//Trigger variables
	public List<Remote_Invocation__c> triggerNew = (List<Remote_Invocation__c>) Trigger.new;
	public List<Remote_Invocation__c> triggerOld = (List<Remote_Invocation__c>) Trigger.old;
	public Map<Id, Remote_Invocation__c> newMap = (Map<Id,Remote_Invocation__c>) Trigger.newMap;
	public Map<Id, Remote_Invocation__c> oldMap = (Map<Id,Remote_Invocation__c>) Trigger.oldMap;

	//Remote Invocation Request Types
	public static final String NEWGEN_EASY_PAY = 'ANG_IEP_MODEL_A';
	public static final String TIP_IFG_REPORT  = 'TIP_IFG_REPORT';

	//Remote Invocation Status
	public static final String REMOTE_INVOCATION_STATUS_INITIALIZING = 'Initializing';
	public static final String REMOTE_INVOCATION_STATUS_PROGRESS     = 'In Progress';

	//Remote Invocation Recordtypes
	public static final ID RECTYPE_NEWGEN = RecordTypeSingleton.getInstance().getRecordTypeId('Remote_Invocation__c', NEWGEN_EASY_PAY);
	public static final ID RECTYPE_TIP    = RecordTypeSingleton.getInstance().getRecordTypeId('Remote_Invocation__c', TIP_IFG_REPORT);

	//to store the remote invocations with errors
	public Set<ID> remoteInvocationWithErrors;

	private Map<String,Account> mapIATACodeAccs;

	public RemoteInvocationTriggerHandler(){
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

	public void processInvocationsInProgress(){
		Set<ID> parentIDs = new Set<ID>();
		Set<String> iatacodesToFetch = new Set<String>();
		Map<string,Account> mapIATACodeAccs = new Map<String, Account>();

		for(Remote_Invocation__c re :  triggerNew){
			if(re.Status__c == REMOTE_INVOCATION_STATUS_PROGRESS && oldMap.get(re.Id).Status__c == REMOTE_INVOCATION_STATUS_INITIALIZING){
				parentIDs.add(re.id);
			}
		}
		Map<ID,Remote_Invocation_Artefact__c> artefacts = new Map<ID,Remote_Invocation_Artefact__c>([SELECT ID, External_ID__c, Format__c, Internal_ID__c, Name__c, Previous_Version__c, Remote_Invocation__c, 
															Request_Result__c, Source__c, Status__C, Status_Detail__c, Valid_From__c, Valid_To__c, Version__c, Version_Notes__c
															FROM Remote_Invocation_Artefact__c WHERE Remote_Invocation__c IN :parentIDs]);
		for(Remote_Invocation_Artefact__c artifact : artefacts.values())
			iatacodesToFetch.add(artifact.Internal_ID__c);


		for(Account acc : [SELECT ID, name, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c, IATACode__c, recordtypeid FROM Account WHERE iataCode__c IN :iatacodesToFetch])
			mapIATACodeAccs.put(acc.IATACode__c,acc);

		if(!mapIATACodeAccs.isEmpty()) performSanityCheck(artefacts, mapIATACodeAccs);		
	}

	public void performSanityCheck(Map<ID,Remote_Invocation_Artefact__c> remoteInvocationToProcess, Map<string,Account> mapIATACodeAccs){

		remoteInvocationWithErrors = new Set<ID>();
		List<Remote_Invocation_Artefact__c> reqsWithError = new List<Remote_Invocation_Artefact__c>(); 
		Map<String,Remote_Invocation_Artefact__c> mapNewgenIATAcodeReqsToProcess = new Map<String,Remote_Invocation_Artefact__c>();		
		
		Map<ID,Account> mapAccsWithIDs = new Map<ID,Account>(); //to pass to the method to create the IEP accounts for NewGen


		//-----RUN VALIDATIONS--------
		for(Remote_Invocation_Artefact__c artifact : remoteInvocationToProcess.values()){
			Remote_Invocation__c parent = newMap.get(artifact.Remote_Invocation__c);
			Account acc = mapIATACodeAccs.get(parent.Internal_ID__c);
			if(parent != null && acc != null){
				
				//NEWGEN validations
				if(parent.Request_Type__c == RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY && acc.recordtypeid == AMS_Utils.RECTYPE_IATAAGENCY){
					mapNewgenIATAcodeReqsToProcess.put(artifact.Internal_Id__c,artifact);
					mapAccsWithIDs.put(acc.id,acc);
				}
				//else if (TIP validations)

				else{
					reqsWithError.add(artifact);
					artifact.Request_Result__c = 'Failed';

					//mark parent with error
					parent.Status__c = 'Failed';
					parent.Status_detail__c = 'Fail to Passed the validations for NewGen';
					remoteInvocationWithErrors.add(artifact.Remote_Invocation__c);
				}
				
			}
			else{
				reqsWithError.add(artifact);
				artifact.Request_Result__c = 'Failed';

				//mark parent with error
				parent.Status__c = 'Failed';
				parent.Status_detail__c = 'Fail to Passed the general validations';
				remoteInvocationWithErrors.add(artifact.Remote_Invocation__c);
			}
		}
	
		if(!mapNewgenIATAcodeReqsToProcess.isEmpty()) process_NewGen_Model_A(mapNewgenIATAcodeReqsToProcess, mapAccsWithIDs);
		if(!reqsWithError.isEmpty()) update reqsWithError;
		

		/*after processing all, update Remote Invocations (Parents) with results 
		Mark parents as pass thoose wich id is not in the list of remoteInvocationWithErrors*/

		for(Remote_Invocation__c re :newMap.values())			
			if(!remoteInvocationWithErrors.contains(re.id)) //otherwise it's already populated when the error occurred
				re.Status__c = 'Completed';
		//update newMap.values();
	}


	public void process_NewGen_Model_A(Map<String,Remote_Invocation_Artefact__c> reqsToCreateOSCAR, Map<ID,Account> mapIDAccs){

		/*
		1.	Fetch Account ID from IATA Code received
		2.	Fetch Active, Authorized signatory Contact associated to Account
		3.	Create OSCAR Communication case
		4.	Create Staging Area ???? 
		5.	Create Oscar

		(just calling the method to create IEP accounts in the ANG_OSCARProcessHelper class )
		*/ 
		List<Remote_Invocation_Artefact__c> requestToUpdate = new List<Remote_Invocation_Artefact__c>();
		
		try{
			List<AMS_OSCAR__c> listOSCARs = ANG_OSCARProcessHelper.createIEPAccountOscar(mapIDAccs,'setup'); //mudar o metodo para devolver a lista de oscars
			if(listOSCARs !=null && !listOSCARs.isEmpty()) 
				for(AMS_OSCAR__c oscar : listOSCARs){
					String iataCode = mapIDAccs.get(oscar.Account__c).IATACode__c;
					reqsToCreateOSCAR.get(iataCode).Request_Result__c = 'Completed';
					reqsToCreateOSCAR.get(iataCode).Object_ID_Created__c = oscar.id;
					requestToUpdate.add(reqsToCreateOSCAR.get(iataCode));	
					reqsToCreateOSCAR.remove(iataCode);
				}
		}catch(Exception e){
			for(Remote_Invocation_Artefact__c artifact : reqsToCreateOSCAR.values()){
				artifact.Request_Result__c = 'Failed';
				
				//mark parent with error
				newMap.get(artifact.Remote_Invocation__c).Status__c = 'Failed';
				newMap.get(artifact.Remote_Invocation__c).Status_detail__c = e.getMessage();
				//status details should be filled with error description but...
				remoteInvocationWithErrors.add(artifact.Remote_Invocation__c);
				
				requestToUpdate.add(artifact);
				reqsToCreateOSCAR.remove(artifact.Internal_Id__c);
			}
		}

		/*After processing all OSCAR's, the reqsToCreateOSCAR should be empty 
		and all the requests should now be in the requestToUpdate List
		. 
		The existence of records in this map means that some error occur. */ 

		if(!reqsToCreateOSCAR.isEmpty()){
			for(Remote_Invocation_Artefact__c artifact : reqsToCreateOSCAR.values()){
				artifact.Request_Result__c = 'Failed';
				
				//mark parent with error
				newMap.get(artifact.Remote_Invocation__c).Status__c = 'Failed';
				newMap.get(artifact.Remote_Invocation__c).Status_detail__c = 'Unknown Error occurred';
				//status details should be filled with error description but...
				remoteInvocationWithErrors.add(artifact.Remote_Invocation__c);
				
				requestToUpdate.add(artifact);
				reqsToCreateOSCAR.remove(artifact.Internal_Id__c);
			}
		}
		update requestToUpdate;
	}

}