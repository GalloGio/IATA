public class ANG_IEPRemoteInvocation implements ANG_RemoteInvocationINT {
	
	public static final String RECTYPE_IATAAGENCY   = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

	//Map<id,Remote_Invocation__c> mapRemoteInvocations = new Map<id,Remote_Invocation__c>(new List<Remote_Invocation__c>(remoteInvocationsIdToProcess));
	Map<String,Remote_Invocation__c> mapRemoteInvocations = new Map<String,Remote_Invocation__c>();
	Map<String, Remote_Invocation_Artefact__c> mapRemoteInvocationArtifacts = new Map<String, Remote_Invocation_Artefact__c>();
	Map<String, Account> mapIATACodeAccs = new Map<String, Account>();
	Map<Id, Account> mapIdAccs = new Map<Id, Account>();
	Set<String> iataCodesToFetch = new Set<String>();
	Set<String> remoteInvocationsWithoutArtifcts = new Set<String>();

	public void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		
		
		

		for (Remote_Invocation__c ri : remoteInvocationsIdToProcess){
			if(ri.Request_Type__c == RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY ){ //otherwise, it's not a remote invocation to be process in this interface	
				mapRemoteInvocations.put(ri.id,ri);
				iataCodesToFetch.add(ri.Internal_ID__c);
				
				remoteInvocationsWithoutArtifcts.add(ri.ID); //to later thow error
			}
		}
		if(mapRemoteInvocations.isEmpty()) return; //nothing to do here

		for(Account acc : [SELECT ID, name, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c, IATACode__c, RecordTypeId FROM Account WHERE iataCode__c IN :iataCodesToFetch])	
			mapIATACodeAccs.put(acc.IATACode__c,acc);

		system.debug('## map at start: ' + remoteInvocationsWithoutArtifcts);
		for(Remote_Invocation_Artefact__c artifact : [SELECT ID, Remote_Invocation__c, Internal_ID__c FROM Remote_Invocation_Artefact__c WHERE Remote_Invocation__c IN :remoteInvocationsIdToProcess]){
			system.debug('## artifact: ' + artifact);
			//remove from the list the parent of the artifact
			remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
			system.debug('## removing from map: ' + artifact.Remote_Invocation__c);
			

			Remote_Invocation__c ri = mapRemoteInvocations.get(artifact.Remote_Invocation__c);
			Account parentAccount = mapIATACodeAccs.get(ri.Internal_ID__c);

			if( parentAccount != null){

				if( parentAccount.recordtypeid == RECTYPE_IATAAGENCY){	
					if(ri.Internal_ID__c == artifact.Internal_ID__c){
				
						//Going to be processed
						mapRemoteInvocationArtifacts.put(artifact.Internal_ID__c, artifact);
						mapIdAccs.put(parentAccount.id, parentAccount);

					}else{

						ri.addError('Remote Invocation IATA code ('+ ri.Internal_ID__c+') doesn\'t match the Artifact IATA Code ('+ artifact.Internal_ID__c+').');

						//not required anymore, remove from all places
						mapRemoteInvocations.remove(artifact.Remote_Invocation__c);
						remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
						remoteInvocationsIdToProcess.remove(ri);	
					}		

				}else{

					ri.addError('Parent account with the IATA code ' + ri.Internal_ID__c + ' is not an IATA Agency.');

					//not required anymore, remove from all places
					mapRemoteInvocations.remove(artifact.Remote_Invocation__c);
					remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
					remoteInvocationsIdToProcess.remove(ri);	
				}				

			}else{
				
				
				ri.addError('Parent account with the IATA code ' + ri.Internal_ID__c + ' not found.');

				//not required anymore, remove from all places
				mapRemoteInvocations.remove(artifact.Remote_Invocation__c);
				remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
				remoteInvocationsIdToProcess.remove(ri);	
			}
		}

		system.debug('## map at end: ' + remoteInvocationsWithoutArtifcts);
		for(String remoteInvocationID : remoteInvocationsWithoutArtifcts){
			Remote_Invocation__c ri = mapRemoteInvocations.get(remoteInvocationID);
			ri.addError('Remote Invocation (' + ri.Internal_ID__c + ') doesn\'t have a artifact.');

			//not required anymore, remove from all places
			mapRemoteInvocations.remove(remoteInvocationID);
			remoteInvocationsWithoutArtifcts.remove(remoteInvocationID);
			remoteInvocationsIdToProcess.remove(ri);
		}
	}
	

	public void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		
		system.debug('##remoteInvocationsIdToProcess: ' + remoteInvocationsIdToProcess);

		if(remoteInvocationsIdToProcess.isEmpty()) return; //nothing to do here
		


		/*
		1.	Fetch Account ID from IATA Code received
		2.	Fetch Active, Authorized signatory Contact associated to Account
		3.	Create OSCAR Communication case
		4.	Create Staging Area ???? 
		5.	Create Oscar

		(just calling the method to create IEP accounts in the ANG_OSCARProcessHelper class )
		*/ 

		List<Remote_Invocation_Artefact__c> artifactRequestsToUpdate = new List<Remote_Invocation_Artefact__c>();
		List<Remote_Invocation__c> requestsToUpdate = new List<Remote_Invocation__c>();
		
		try{
			system.debug('##mapIdAccs: ' + mapIDAccs);
			List<AMS_OSCAR__c> listOSCARs = ANG_OSCARProcessHelper.createIEPAccountOscar(mapIDAccs,'setup'); //mudar o metodo para devolver a lista de oscars
			system.debug('##listOSCARs: ' + listOSCARs);
			if(listOSCARs !=null && !listOSCARs.isEmpty()) 
				for(AMS_OSCAR__c oscar : listOSCARs){
					String iataCode = mapIDAccs.get(oscar.Account__c).IATACode__c;
					system.debug('##iata code: ' + iatacode);
					mapRemoteInvocationArtifacts.get(iataCode).Request_Result__c = 'Completed';
					mapRemoteInvocationArtifacts.get(iataCode).Object_ID_Created__c = oscar.id;
					artifactRequestsToUpdate.add(mapRemoteInvocationArtifacts.get(iataCode));	
					mapRemoteInvocationArtifacts.remove(iataCode);
				}
		}catch(Exception e){
			for(Remote_Invocation_Artefact__c artifact : mapRemoteInvocationArtifacts.values()){
				artifact.Request_Result__c = 'Failed';
				
				//mark parent with error
				mapRemoteInvocations.get(artifact.Remote_Invocation__c).Status__c = 'Failed';
				mapRemoteInvocations.get(artifact.Remote_Invocation__c).Status_detail__c = e.getMessage();
				requestsToUpdate.add(mapRemoteInvocations.get(artifact.Remote_Invocation__c));
				//status details should be filled with error description but...
				
				artifactRequestsToUpdate.add(artifact);
				mapRemoteInvocationArtifacts.remove(artifact.Internal_Id__c);
			}	
		}

		/*After processing all OSCAR's, the mapRemoteInvocationArtifacts should be empty 
		and all the requests should now be in the artifactRequestsToUpdate List
		. 
		The existence of records in this map means that some error occur. */ 

		if(!mapRemoteInvocationArtifacts.isEmpty()){
			for(Remote_Invocation_Artefact__c artifact : mapRemoteInvocationArtifacts.values()){
				artifact.Request_Result__c = 'Failed';
				artifactRequestsToUpdate.add(artifact);
				mapRemoteInvocationArtifacts.remove(artifact.Internal_Id__c);
				
				//mark parent with error
				mapRemoteInvocations.get(artifact.Remote_Invocation__c).Status__c = 'Failed';
				mapRemoteInvocations.get(artifact.Remote_Invocation__c).Status_detail__c = 'Unknown Error occurred';
				//status details should be filled with error description but...
				requestsToUpdate.add(mapRemoteInvocations.get(artifact.Remote_Invocation__c));

			}
		}

		update artifactRequestsToUpdate;
		//update requestsToUpdate;
	}

	
}