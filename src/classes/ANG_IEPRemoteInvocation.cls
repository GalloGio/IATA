public class ANG_IEPRemoteInvocation implements ANG_RemoteInvocationINT {
	
	//Map<id,Remote_Invocation__c> mapRemoteInvocations = new Map<id,Remote_Invocation__c>(new List<Remote_Invocation__c>(remoteInvocationsIdToProcess));
	Map<id,Remote_Invocation__c> mapRemoteInvocations = new Map<id,Remote_Invocation__c>();
	Map<String, Account> mapIATACodeAccs = new Map<String, Account>();
	Set<String> iataCodesToFetch = new Set<String>();
	Set<ID> remoteInvocationsWithoutArtifcts = new Set<ID>();
	//if it's required to identify the remote invocations that dont have artifacts (probably yes), set of all remoteInvocations IDs
		//remove the id when iterating, the arficats. in the end, if theres remote invocations, iterate, remove from list (remoteInvocationsIdToProcess) and add error


	public void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		
		
		if(remoteInvocationsIdToProcess.isEmpty()) return; //nothing to do here
		

		for (Remote_Invocation__c ri : remoteInvocationsIdToProcess){
			if(ri.Request_Type__c == RemoteInvocationTriggerHandler.NEWGEN_EASY_PAY ){ //otherwise, not remote invocations to process here	
				mapRemoteInvocations.put(ri.id,ri);
				iataCodesToFetch.add(ri.Internal_ID__c);
				remoteInvocationsWithoutArtifcts.add(ri.Id);
			}
		}

		for(Account acc : [SELECT ID, name, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c, IATACode__c, RecordTypeId FROM Account WHERE iataCode__c IN :iataCodesToFetch]) mapIATACodeAccs.put(acc.IATACode__c,acc);

		for(Remote_Invocation_Artefact__c artifact : [SELECT ID, Remote_Invocation__c, Remote_Invocation__r.Request_Type__c FROM Remote_Invocation_Artefact__c WHERE Remote_Invocation__c IN :mapRemoteInvocations.keyset()]){
			
			//remove from the list the parent of the artifact
			remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
			
			Account parentAccount = mapIATACodeAccs.get(artifact.Internal_ID__c);
			if(artifact.Remote_Invocation__c == null || parentAccount == null){

				if( parentAccount.recordtypeid == AMS_Utils.RECTYPE_IATAAGENCY){				
					artifact.addError('');
					remoteInvocationsIdToProcess.remove(mapRemoteInvocations.get(artifact.Remote_Invocation__c));
				
				}else{

					Remote_Invocation__c ri = mapRemoteInvocations.get(artifact.Remote_Invocation__c);
					ri.addError('Parent account with the IATA code ' + ri.Internal_ID__c + ' is not an IATA Agency.');

					//not required anymore, remove from all places
					mapRemoteInvocations.remove(artifact.Remote_Invocation__c);
					remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
					remoteInvocationsIdToProcess.remove(ri);
				}				

			}else{
				
				Remote_Invocation__c ri = mapRemoteInvocations.get(artifact.Remote_Invocation__c);
				ri.addError('Parent account with the IATA code ' + ri.Internal_ID__c + ' not found .');

				//not required anymore, remove from all places
				mapRemoteInvocations.remove(artifact.Remote_Invocation__c);
				remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
				remoteInvocationsIdToProcess.remove(ri);	
			}
		}

		for(ID remoteInvocationID : remoteInvocationsWithoutArtifcts){
			Remote_Invocation__c ri = mapRemoteInvocations.get(remoteInvocationID);
			ri.addError('Remote Invocation doesn\'t have a artifact.');

			//not required anymore, remove from all places
			mapRemoteInvocations.remove(remoteInvocationID);
			remoteInvocationsWithoutArtifcts.remove(remoteInvocationID);
			remoteInvocationsIdToProcess.remove(ri);
		}
	}
	

	public void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		

		if(remoteInvocationsIdToProcess.isEmpty()) return; //nothing to do here
		
	}

	
}