/**
 * Processes the SAP PPA Remote Invocation
 *
 */
public without sharing class ANG_SAP_PPA_RemoteInvocation implements ANG_RemoteInvocationINT {

	@TestVisible
	private static final String NEW_INTERACTION_ATTACHMENT = 'New Attachment';

	Map<ID,Remote_Invocation__c> mapRemoteInvocations = new Map<ID,Remote_Invocation__c>();
	Map<ID, Remote_Invocation_Artefact__c> mapRemoteInvocationArtifacts = new Map<ID, Remote_Invocation_Artefact__c>();
	Set<String> remoteInvocationsWithoutArtifcts = new Set<String>();

	List<Remote_Invocation_Artefact__c> rmtInvocationArtListToUpdate = new List<Remote_Invocation_Artefact__c>();

	public ANG_SAP_PPA_RemoteInvocation() {}

	public void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){

		System.debug(LoggingLevel.FINE, '____ [cls ANG_SAP_PPA_RemoteInvocation - doSanityCheck] Start ');
		System.debug(LoggingLevel.FINE, '____ [cls ANG_SAP_PPA_RemoteInvocation - doSanityCheck] remoteInvocationsIdToProcess: ' + remoteInvocationsIdToProcess);

		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){

			if(ri.Request_Type__c == RemoteInvocationTriggerHandler.NEWGEN_SAP_PPA ){ //otherwise, it's not a remote invocation to be process in this interface	
				mapRemoteInvocations.put(ri.id,ri);
				remoteInvocationsWithoutArtifcts.add(ri.ID); //to later thow error
			}
		}

		//No SPA PPA Remote Invocations to process
		if(mapRemoteInvocations.isEmpty()) return;

		System.debug(LoggingLevel.FINE, '____ [cls ANG_SAP_PPA_RemoteInvocation - doSanityCheck] Map at start: ' + remoteInvocationsWithoutArtifcts);

		for(Remote_Invocation_Artefact__c artifact : [SELECT ID, Remote_Invocation__c, Internal_ID__c, External_Id__c, Payment_type__c
													  FROM Remote_Invocation_Artefact__c WHERE Remote_Invocation__c IN :mapRemoteInvocations.keySet()]){
			
			System.debug(LoggingLevel.FINE, '____ [cls ANG_SAP_PPA_RemoteInvocation - doSanityCheck] current Remote_Invocation_Artefact__c: ' + artifact);
			//remove from the list the parent of the artifact
			remoteInvocationsWithoutArtifcts.remove(artifact.Remote_Invocation__c);
			System.debug(LoggingLevel.FINE, '____ [cls ANG_SAP_PPA_RemoteInvocation - doSanityCheck] Removing from map: ' + artifact.Remote_Invocation__c);

			Remote_Invocation__c ri = mapRemoteInvocations.get(artifact.Remote_Invocation__c);

			//Check if the Remote Invocation.Internal ID is the same of the Remote Invocation Artefact 
			if(ri.Internal_ID__c == artifact.Internal_ID__c){

				if(!String.isBlank(artifact.Payment_type__c)){
					//Going to be processed
					mapRemoteInvocationArtifacts.put(artifact.Internal_ID__c, artifact);
				}else{
					ri.Status_Detail__c = 'Remote Invocation Artefact IATA code ('+ ri.Internal_ID__c+') must have a Payment Type';
					artifact.Status_Detail__c = 'Remote Invocation Artefact IATA code ('+ ri.Internal_ID__c+') must have a Payment Type';
					ri.Status__c = AMS_Utils.FAILED;
					artifact.Request_Result__c = AMS_Utils.FAILED;
					rmtInvocationArtListToUpdate.add(artifact);
				}
			}
			else{
				ri.Status_Detail__c = 'Remote Invocation IATA code ('+ ri.Internal_ID__c+') doesn\'t match the Artifact IATA code ('+ artifact.Internal_ID__c+')';
				artifact.Status_Detail__c = 'Remote Invocation IATA code ('+ ri.Internal_ID__c+') doesn\'t match the Artifact IATA code ('+ artifact.Internal_ID__c+')';
				ri.Status__c = AMS_Utils.FAILED;
				artifact.Request_Result__c = AMS_Utils.FAILED;
				rmtInvocationArtListToUpdate.add(artifact);
			}
		}

		//Check if there are any Remote Invocation without Artifact
		for(String remoteInvocationID : remoteInvocationsWithoutArtifcts){
			Remote_Invocation__c ri = mapRemoteInvocations.get(remoteInvocationID);
			ri.Status_Detail__c = 'Remote Invocation IATA code (' + ri.Internal_ID__c + ') doesn\'t have a artifact.';
			ri.Status__c = AMS_Utils.FAILED;
		}

		//Update Remote Invocation Artefact Status
		if(!rmtInvocationArtListToUpdate.isEmpty()) update rmtInvocationArtListToUpdate;
	}


	public void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){

		System.debug(LoggingLevel.FINE, '____ [cls ANG_SAP_PPA_RemoteInvocation - doProcess] mapRemoteInvocationArtifacts: ' + mapRemoteInvocationArtifacts);
 
		//No SPA PPA Remote Invocations to process
		if(remoteInvocationsIdToProcess.isEmpty()) return;

		if(!mapRemoteInvocationArtifacts.isEmpty()){

			Map<Id, Case> caseMap = new Map<Id, Case>(
				[SELECT Id, OSCAR__r.Name, OSCAR__r.Invoice_number__c, OSCAR__r.Endorsement_Requested__c, 
					OSCAR__r.Endorsement_requested_date__c, OSCAR__r.STEP47__c, OSCAR__r.STEP9__c, OSCAR__r.STEP49__c 
				 FROM Case WHERE Id IN :mapRemoteInvocationArtifacts.keySet()]);

			Map<ID, AMS_OSCAR__c> mapCaseIdWithRemoteInternalID = new Map<ID, AMS_OSCAR__c>();

			for(Case cse : caseMap.values()){
				AMS_OSCAR__c oscar = (AMS_OSCAR__c) cse.getSObject('OSCAR__r');
				mapCaseIdWithRemoteInternalID.put(cse.Id, oscar);
			}
							
			Remote_Invocation__c ri;
			List<Case> casesToUpdate = new List<Case>();
			List<AMS_OSCAR__c> oscarsToUpdate = new List<AMS_OSCAR__c>();

			for(Remote_Invocation_Artefact__c remoteInovArt : mapRemoteInvocationArtifacts.values()){

				ri = mapRemoteInvocations.get(remoteInovArt.Remote_Invocation__c);

				//To prevent the 15 character ID - to ensure all the ID have 18 characters.
				Id caseIdToCompare = remoteInovArt.Internal_ID__c;
				Case cse = caseMap.get(caseIdToCompare);
				AMS_OSCAR__c osc = mapCaseIdWithRemoteInternalID.get(caseIdToCompare);

				if(remoteInovArt.Payment_type__c == AMS_Utils.SAP_PAYMENT_TYPE_PPA && String.isBlank(remoteInovArt.External_Id__c)){
					ri.Status_Detail__c = 'Remote Invocation Artefact must have an External ID';
					ri.Status__c = AMS_Utils.FAILED;
					remoteInovArt.Request_Result__c = AMS_Utils.FAILED;
					remoteInovArt.Status_Detail__c = 'Remote Invocation Artefact must have an External ID';
					rmtInvocationArtListToUpdate.add(remoteInovArt);
					break;
				}

				osc.Payment_Type__c = remoteInovArt.Payment_type__c;
				osc.Billing_Document_Number__c = remoteInovArt.External_Id__c;
				cse.New_interaction__c = NEW_INTERACTION_ATTACHMENT;

				//NEWGEN-5450-BugFix - Fill the Object_Id_Created__c with the value of the Internal_ID__c
				remoteInovArt.Object_Id_Created__c = remoteInovArt.Internal_ID__c;

				ri.Status__c = AMS_Utils.COMPLETED;
				ri.Status_Detail__c = '';
				remoteInovArt.Request_Result__c = AMS_Utils.COMPLETED;
				remoteInovArt.Status_Detail__c = '';
				rmtInvocationArtListToUpdate.add(remoteInovArt);
				oscarsToUpdate.add(osc);
				casesToUpdate.add(cse);

			}

			System.debug(LoggingLevel.FINE, '____ [cls ANG_SAP_PPA_RemoteInvocation - doProcess] Before Update oscarsToUpdate: ' + oscarsToUpdate);

			//Update Oscar list
			if(!oscarsToUpdate.isEmpty()) update oscarsToUpdate;

			if(!casesToUpdate.isEmpty()) update casesToUpdate;

			//Update Remote Invocation Artefact Status
			if(!rmtInvocationArtListToUpdate.isEmpty()) update rmtInvocationArtListToUpdate;
		}
	}
}