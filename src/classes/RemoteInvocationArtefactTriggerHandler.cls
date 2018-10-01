public with sharing class RemoteInvocationArtefactTriggerHandler {

	public static List<Remote_Invocation_Artefact__c> triggerNew = (List<Remote_Invocation_Artefact__c>) Trigger.new;
	public static List<Remote_Invocation_Artefact__c> triggerOld = (List<Remote_Invocation_Artefact__c>) Trigger.old;

	public static Map<Id, Remote_Invocation_Artefact__c> newMap = (Map<Id,Remote_Invocation_Artefact__c>) Trigger.newMap;
	public static Map<Id, Remote_Invocation_Artefact__c> oldMap = (Map<Id,Remote_Invocation_Artefact__c>) Trigger.oldMap;

	public static Map<ID, Remote_Invocation__c> remoteInvocationParents;
	public static Set<ID> remoteInvocationWithErrors;

	public static Map<String,Account> mapIATACodeAccs;
	public static Map<ID,Account> mapAccsWithIDs; //for the call to the method to create the IEP back account 


	public static void handleBeforeInsert(){
	//	assignRecordtypeToRequest();
		populateLists();
		performSanityCheck();
	}

	public static void populateLists(){

		Set<ID> parentIDs = new Set<ID>();
		Set<String> iataCodes = new Set<String>();
		remoteInvocationParents = new Map<ID, Remote_Invocation__c>();
		mapIATACodeAccs = new Map<String,Account>();
		for(Remote_Invocation_Artefact__c artifact : triggerNew){
			parentIDs.add(artifact.Remote_Invocation__c);
			iatacodes.add(artifact.External_id__c);			
		} 

		//fetch Remote Invocations
		remoteInvocationParents = new Map<Id, Remote_Invocation__c>([SELECT ID, request_type__c, Internal_ID__c FROM Remote_Invocation__c WHERE ID IN :parentIDs]);

		//fetch accounts
		for(Account a : [SELECT ID, IATACode__c FROM Account WHERE iataCode__c IN :iataCodes]){
			mapIATACodeAccs.put(a.IATACode__c,a);
		}


	}

	public static void performSanityCheck(){

		remoteInvocationWithErrors = new Set<ID>();
		List<Remote_Invocation_Artefact__c> reqsWithError = new List<Remote_Invocation_Artefact__c>(); 
		Map<String,Remote_Invocation_Artefact__c> mapNewgenIATAcodeReqsToProcess = new Map<String,Remote_Invocation_Artefact__c>();		
		
		mapAccsWithIDs = new Map<ID,Account>(); //to pass to the method to create the IEP accounts for NewGen

		//-----RUN VALIDATIONS--------
		for(Remote_Invocation_Artefact__c artifact : triggerNew){

			Remote_Invocation__c parent = remoteInvocationParents.get(artifact.Remote_Invocation__c);
			Account acc = mapIATACodeAccs.get(parent.Internal_ID__c);
			
			if(parent != null && acc != null){
				
				//NEWGEN validations
				if(parent.Request_Type__c == RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY && acc.recordtypeid == AMS_Utils.RECTYPE_IATAAGENCY){
					mapNewgenIATAcodeReqsToProcess.put(artifact.External_Id__c,artifact);
					mapAccsWithIDs.put(acc.id,acc);
				}
				
				//else if (TIP validations)

				else{
					reqsWithError.add(artifact);
					artifact.Status__c = 'Failed';

				//mark parent with error
				remoteInvocationParents.get(artifact.Remote_Invocation__c).Status__c = 'Failed';
				remoteInvocationParents.get(artifact.Remote_Invocation__c).Status_detail__c = 'Completed with failure';
					remoteInvocationWithErrors.add(artifact.Remote_Invocation__c);
				}
				
			}
			else{
				reqsWithError.add(artifact);
				artifact.Status__c = 'Failed';

				//mark parent with error
				remoteInvocationParents.get(artifact.Remote_Invocation__c).Status__c = 'Failed';
				remoteInvocationParents.get(artifact.Remote_Invocation__c).Status_detail__c = 'Completed with failure';
				remoteInvocationWithErrors.add(artifact.Remote_Invocation__c);
			}
		}

		if(!mapNewgenIATAcodeReqsToProcess.isEmpty()) process_NewGen_Model_A(mapNewgenIATAcodeReqsToProcess, mapAccsWithIDs);
		if(!reqsWithError.isEmpty()) update reqsWithError;
		



		/*after processing all, update Remote Invocations (Parents) with results 
		Mark parents as pass thoose wich id is not in the list of remoteInvocationWithErrors*/

		for(Remote_Invocation__c re :remoteInvocationParents.values())			
			if(!remoteInvocationWithErrors.contains(re.id)) //otherwise it's already populated when the error occurred
				re.Status__c = 'Completed successfully';
		update remoteInvocationParents.values();

	}


	public static void process_NewGen_Model_A(Map<String,Remote_Invocation_Artefact__c> reqsToCreateOSCAR, Map<ID,Account> mapIDAccs){

		/*
		1.	Fetch Account ID from IATA Code received
		2.	Fetch Active, Authorized signatory Contact associated to Account
		3.	Create OSCAR Communication case
		4.	Create Staging Area ???? 
		5.	Create Oscar

		(just calling the method to create IEP accounts in the ANG_OSCARProcessHelper class )
		*/ 

		List<Remote_Invocation_Artefact__c> requestToUpdate = new List<Remote_Invocation_Artefact__c>();
		List<AMS_OSCAR__c> listOSCARs = ANG_OSCARProcessHelper.createIEPAccountOscar(mapIDAccs,'A'); //mudar o metodo para devolver a lista de oscars
		
		for(AMS_OSCAR__c oscar : listOSCARs){
			String iataCode = mapIDAccs.get(oscar.Account__c).IATACode__c;
			
			reqsToCreateOSCAR.get(iataCode).Status__c = 'Success';
			reqsToCreateOSCAR.get(iataCode).Object_ID_Created__c = oscar.id;

			requestToUpdate.add(reqsToCreateOSCAR.get(iataCode));
			reqsToCreateOSCAR.remove(iataCode);
		}



		/*After processing all OSCAR's, the reqsToCreateOSCAR should be empty 
		and all the requests should now be in the requestToUpdate List
		. 
		The existence of records in this map means that some error occur. */ 

		if(!reqsToCreateOSCAR.isEmpty()){
			for(Remote_Invocation_Artefact__c artifact : reqsToCreateOSCAR.values()){
				artifact.Status__c = 'Failed';

				//mark parent with error
				remoteInvocationParents.get(artifact.Remote_Invocation__c).Status__c = 'Failed';
				remoteInvocationParents.get(artifact.Remote_Invocation__c).Status_detail__c = 'Completed with failure';
				//status details should be filled with error description but...
				remoteInvocationWithErrors.add(artifact.Remote_Invocation__c);
				
				requestToUpdate.add(artifact);
				reqsToCreateOSCAR.remove(artifact.External_Id__c);
			}
		}

		update requestToUpdate;

	}

}