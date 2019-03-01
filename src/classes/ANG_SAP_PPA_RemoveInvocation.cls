/**
 * Processes the SAP PPA Remote Invocation
 *
 */
public with sharing class ANG_SAP_PPA_RemoveInvocation implements ANG_RemoteInvocationINT {

	Map<String,Remote_Invocation__c> mapRemoteInvocations = new Map<String,Remote_Invocation__c>();
	Map<String, Remote_Invocation_Artefact__c> mapRemoteInvocationArtifacts = new Map<String, Remote_Invocation_Artefact__c>();
	Set<String> remoteInvocationsWithoutArtifcts = new Set<String>();

	List<Remote_Invocation_Artefact__c> rmtInvocationArtListToUpdate = new List<Remote_Invocation_Artefact__c>();

	public ANG_SAP_PPA_RemoveInvocation() {}

	public void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){

		System.debug('[ANG_SAP_PPA_RemoveInvocation] Start doSanityCheck ' );

		System.debug('[ANG_SAP_PPA_RemoveInvocation] remoteInvocationsIdToProcess: ' + remoteInvocationsIdToProcess );

		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){

			if(ri.Request_Type__c == RemoteInvocationTriggerHandler.NEWGEN_SAP_PPA ){ //otherwise, it's not a remote invocation to be process in this interface	
				mapRemoteInvocations.put(ri.id,ri);
				remoteInvocationsWithoutArtifcts.add(ri.ID); //to later thow error
			}
		}

		//No SPA PPA Remote Invocations to process
		if(mapRemoteInvocations.isEmpty()) return;

		System.debug('[ANG_SAP_PPA_RemoveInvocation] Map at start: ' + remoteInvocationsWithoutArtifcts);

		for(Remote_Invocation_Artefact__c artifact : [SELECT ID, Remote_Invocation__c, Internal_ID__c, External_Id__c, Payment_type__c
													  FROM Remote_Invocation_Artefact__c WHERE Remote_Invocation__c IN :mapRemoteInvocations.keySet()]){
			
			System.debug('[ANG_SAP_PPA_RemoveInvocation] current Remote_Invocation_Artefact__c: ' + artifact);

			//remove from the list the parent of the artifact
			remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
			system.debug('[ANG_SAP_PPA_RemoveInvocation] Removing from map: ' + artifact.Remote_Invocation__c);

			Remote_Invocation__c ri = mapRemoteInvocations.get(artifact.Remote_Invocation__c);

			//Check if the Remote Invocation.Internal ID is the same of the Remote Invocation Artefact 
			if(ri.Internal_ID__c == artifact.Internal_ID__c){

				if(!String.isBlank(artifact.Payment_type__c)){
					//Going to be processed
					mapRemoteInvocationArtifacts.put(artifact.Internal_ID__c, artifact);
				}else{
					ri.Status_Detail__c = 'Remote Invocation Artefact IATA code ('+ ri.Internal_ID__c+') must have a Payment Type';
					artifact.Status_Detail__c = 'Remote Invocation Artefact IATA code ('+ ri.Internal_ID__c+') must have a Payment Type';
					ri.Status__c = 'Failed';
					artifact.Request_Result__c = 'Failed';
					rmtInvocationArtListToUpdate.add(artifact);
				}
			}
			else{
				ri.Status_Detail__c = 'Remote Invocation IATA code ('+ ri.Internal_ID__c+') doesn\'t match the Artifact IATA code ('+ artifact.Internal_ID__c+')';
				artifact.Status_Detail__c = 'Remote Invocation IATA code ('+ ri.Internal_ID__c+') doesn\'t match the Artifact IATA code ('+ artifact.Internal_ID__c+')';
				ri.Status__c = 'Failed';
				artifact.Request_Result__c = 'Failed';
				rmtInvocationArtListToUpdate.add(artifact);
			}
		}

		//Check if there are any Remote Invocation without Artifact
		for(String remoteInvocationID : remoteInvocationsWithoutArtifcts){
			Remote_Invocation__c ri = mapRemoteInvocations.get(remoteInvocationID);
			ri.Status_Detail__c = 'Remote Invocation IATA code (' + ri.Internal_ID__c + ') doesn\'t have a artifact.';
			ri.Status__c = 'Failed';
		}

		//Update Remote Invocation Artefact Status
		if(!rmtInvocationArtListToUpdate.isEmpty()) update rmtInvocationArtListToUpdate;
	}


	public void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){

		System.debug('[ANG_SAP_PPA_RemoveInvocation] Start doProcess mapRemoteInvocationArtifacts: ' + mapRemoteInvocationArtifacts);
 
		//No SPA PPA Remote Invocations to process
		if(remoteInvocationsIdToProcess.isEmpty()) return;

		if(!mapRemoteInvocationArtifacts.isEmpty()){

			List<AMS_OSCAR__c> oscarList = [SELECT ID, Name, Invoice_number__c, Endorsement_Requested__c, Endorsement_requested_date__c, 
											STEP47__c, STEP9__c, STEP49__c, Oscar_Communication_Case_Id__c
											FROM AMS_OSCAR__c WHERE Oscar_Communication_Case_Id__c IN :mapRemoteInvocationArtifacts.keySet()]; 

			System.debug('[ANG_SAP_PPA_RemoveInvocation] doProcess - Oscar list to Process: ' + oscarList);
							
			Remote_Invocation__c ri;
			for(Remote_Invocation_Artefact__c remoteInovArt : mapRemoteInvocationArtifacts.values()){

				ri = mapRemoteInvocations.get(remoteInovArt.Remote_Invocation__c);

				for(AMS_OSCAR__c osc : oscarList){

					//Process Payment_Type == 'PPA'
					if(remoteInovArt.Payment_type__c == 'PPA' && String.isBlank(mapRemoteInvocationArtifacts.get(osc.Oscar_Communication_Case_Id__c).External_Id__c)){
						ri.Status_Detail__c = 'Remote Invocation Artefact must have an External ID';
						ri.Status__c = 'Failed';
						remoteInovArt.Request_Result__c = 'Failed';
						remoteInovArt.Status_Detail__c = 'Remote Invocation Artefact must have an External ID';
						rmtInvocationArtListToUpdate.add(remoteInovArt);
					}
					//Process Payment_Type == 'SPDR'
					else if(remoteInovArt.Payment_type__c == 'SPDR') {

						if(!osc.Endorsement_Requested__c){
							osc.Endorsement_Requested__c = true;
							osc.Endorsement_requested_date__c = Date.today();
							osc.STEP49__c = 'Passed';
						}

						//2 - Set Issue billing doc and Confirm Payment Received Steps as "Not Applicable"
						osc.STEP47__c = 'Not Applicable';
						osc.STEP9__c = 'Not Applicable';
					}

					osc.Payment_Type__c = remoteInovArt.Payment_type__c;
					osc.Billing_Document_Number__c = mapRemoteInvocationArtifacts.get(osc.Oscar_Communication_Case_Id__c).External_Id__c;
				}

				ri.Status__c = 'Completed';
				remoteInovArt.Request_Result__c = 'Completed';
				rmtInvocationArtListToUpdate.add(remoteInovArt);
			}

			System.debug('[ANG_SAP_PPA_RemoveInvocation] - doProcess - Before Update OscarList: ' + oscarList);

			//Update Oscar list
			if(!oscarList.isEmpty()) update oscarList;

			//Update Remote Invocation Artefact Status
			if(!rmtInvocationArtListToUpdate.isEmpty()) update rmtInvocationArtListToUpdate;
		}
	}
}