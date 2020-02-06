public without sharing class ANG_GDIEndorsementPdfRemoteInvocation implements ANG_RemoteInvocationINT{

	@TestVisible
	private static final String MISSING_MANDATORY_FIELDS = 'Missing mandatory fields';
	@TestVisible
	private static final String ACCOUNT_NOT_FOUND = 'Account not found!';
	@TestVisible
	private static final String OFFER_ID_NOT_FOUND = 'Offer ID not found';
	@TestVisible
	private static final String OFFER_ID_DIFFERENT_IATA_CODE = 'Offer ID is associated to a different IATA Code';
	@TestVisible
	private static final String FINANCIAL_SECURITY_NOT_ASSOCIATED_WITH_OPPLINEITEM = 'Financial Security is not associated with the Opportunity Line Item';
	@TestVisible
	private static final String NO_ARTEFACT_MATCH = 'The Remote invocation does not have a match for a remote invocation artifact.';
	@TestVisible
	private static final String INVALID_REQUEST_TYPE = 'Invalid Request Type';
	@TestVisible
	private static final String VERIFY_RELATED_ARTEFACTS = 'Verify related artefacts for details';
	@TestVisible
	private static final String OPPORTUNITY_LINE_ITEM_DOES_NOT_EXIST = 'Opportunity Line Item does not exist';

	private Map<String, Opportunity> offerIdByOpportunityMap = new Map<String, Opportunity>();
	private Map<Id, Remote_Invocation__c> mapRemoteInvocationToUpdate = new Map<Id, Remote_Invocation__c>();
	private List<Remote_Invocation_Artefact__c> listArtifactsToUpdate = new List<Remote_Invocation_Artefact__c>();
	private Map<Id, Remote_Invocation_Artefact__c> mapValidArtefacts = new Map<Id, Remote_Invocation_Artefact__c>();

	public void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){

		Set<Remote_Invocation__c> setValidRemoteInvocation = new Set<Remote_Invocation__c>();

		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){
			//let's see if the source and request type are consistent
			if(ri.Source__c == RemoteInvocationTriggerHandler.SOURCE_GDI && ri.request_type__c == RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF){
				setValidRemoteInvocation.add(ri);
			}else{
				this.mapRemoteInvocationToUpdate.put(ri.id, new Remote_Invocation__c(Id = ri.id, Status__c = AMS_Utils.FAILED, Status_detail__c = INVALID_REQUEST_TYPE));
			}
		}

		if(setValidRemoteInvocation.isEmpty()){
			return;
		}

		//Query artefacts
		list<Remote_Invocation__c> remoteInvocationArtifactsLst = new List<Remote_Invocation__c>(
			[SELECT 
				Id,
				Status__c,
				Status_Detail__c,
				(SELECT
					Id,
					Source__c,
					External_ID__c,
					Internal_ID__c,
					Status_Detail__c,
					Request_Result__c,
					Remote_Invocation__c
				 FROM Remote_Invocation_Artefacts__r)
			 FROM Remote_Invocation__c 
			 WHERE Id IN :setValidRemoteInvocation
			]
		);

		Map<String, String> offerIdByIataCodeMap = new Map<String, String>();	

		for(Remote_Invocation__c ri : remoteInvocationArtifactsLst){
			//Check if there is any artefact related to the remote invocation
			if(ri.Remote_Invocation_Artefacts__r.isEmpty()){
				this.mapRemoteInvocationToUpdate.put(ri.id, new Remote_Invocation__c(Id = ri.id, Status__c = AMS_Utils.FAILED, Status_detail__c = NO_ARTEFACT_MATCH));
			}else{
				for(Remote_Invocation_Artefact__c artifact : ri.Remote_Invocation_Artefacts__r){
					String validationDetail = runValidations(artifact, null, null);
					if(String.isNotBlank(validationDetail)){
						artifact.Request_Result__c = AMS_Utils.FAILED;
						artifact.Status_Detail__c = validationDetail;
						this.listArtifactsToUpdate.add(artifact);
					}
					else {
						offerIdByIataCodeMap.put(artifact.External_ID__c, artifact.Internal_ID__c);
						this.mapValidArtefacts.put(artifact.id, artifact);
					}
				}
			}
		}

		if(this.mapValidArtefacts.isEmpty()){
			return;
		}

		for(opportunity opty : [SELECT Id, AccountId, GDI_Offer_Id__c, StageName, (select id, Financial_Security__c From OpportunityLineItems limit 1) FROM Opportunity WHERE GDI_Offer_Id__c IN :offerIdByIataCodeMap.keyset()]){
			this.offerIdByOpportunityMap.put(opty.GDI_Offer_Id__c, opty);
		}

		Map<String, Id> mapIATACodeId = new Map<String, Id>();
		
		for(Account accnt : [SELECT Id, IATACode__c FROM Account WHERE IATACode__c IN :offerIdByIataCodeMap.values() AND RecordType.DeveloperName = 'IATA_Agency']){
			mapIATACodeId.put(accnt.IATACode__c, accnt.id);
		}

		for(Remote_Invocation_Artefact__c artifact : this.mapValidArtefacts.values()){
			String validationDetail = runValidations(artifact, this.offerIdByOpportunityMap, mapIATACodeId);

			if(String.isNotBlank(validationDetail)){
				artifact.Request_Result__c = AMS_Utils.FAILED;
				artifact.Status_Detail__c = validationDetail;
				this.listArtifactsToUpdate.add(artifact);
				this.mapValidArtefacts.remove(artifact.Id);
			}
		}

	}


	// 1) Check all necessary fields are populated
	// 2) IATACode received exists
	// 3) OfferID received Exists
	// 4) if both exists, IATA Code is associated to OfferId received
	private String runValidations(Remote_Invocation_Artefact__c artifact, Map<String, Opportunity> mapOpty, Map<String, Id> mapIATACodeId){

		if(String.isBlank(artifact.Internal_ID__c) || String.isBlank(artifact.External_ID__c)){
			return MISSING_MANDATORY_FIELDS;
		}

		if(mapIATACodeId != null && mapOpty != null){
			if(!mapIATACodeId.containsKey(artifact.Internal_ID__c)){
				return ACCOUNT_NOT_FOUND;
			}

			if(!mapOpty.containsKey(artifact.External_ID__c)){
				return OFFER_ID_NOT_FOUND;
			}

			if(mapOpty.containsKey(artifact.External_ID__c)){
				if(mapOpty.get(artifact.External_ID__c).AccountId != mapIATACodeId.get(artifact.Internal_ID__c)){
					return OFFER_ID_DIFFERENT_IATA_CODE;
				}
			}
		}

		return null;

	}

	public void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		
		if(!this.mapValidArtefacts.isEmpty()){

			Map<String, Id> objectIdResultMap = new Map<String, Id>();

			for(Remote_Invocation_Artefact__c artifact : this.mapValidArtefacts.values()){

				Opportunity opp = this.offerIdByOpportunityMap.get(artifact.External_ID__c);
				
				if(!opp.OpportunityLineItems.isEmpty()){
					OpportunityLineItem oli = opp.OpportunityLineItems[0];

					if(opp.StageName == AMS_Utils.OPPORTUNITY_CLOSED_WON && oli.Financial_Security__c == null){
						artifact.Request_Result__c = AMS_Utils.FAILED;
						artifact.Status_Detail__c = FINANCIAL_SECURITY_NOT_ASSOCIATED_WITH_OPPLINEITEM;
						this.listArtifactsToUpdate.add(artifact);
						this.mapValidArtefacts.remove(artifact.Id);
					}
					else {
						objectIdResultMap.put(
							artifact.Id, 
							opp.StageName == AMS_Utils.OPPORTUNITY_CLOSED_WON ? 
								oli.Financial_Security__c : 
								oli.Id
						);
					}
				}
				else {
					artifact.Request_Result__c = AMS_Utils.FAILED;
					artifact.Status_Detail__c = OPPORTUNITY_LINE_ITEM_DOES_NOT_EXIST;
					this.listArtifactsToUpdate.add(artifact);
					this.mapValidArtefacts.remove(artifact.Id);
				}
				
			}

			for(Remote_Invocation_Artefact__c artifact : this.mapValidArtefacts.values()){
				artifact.Request_Result__c = AMS_Utils.COMPLETED;
				artifact.Status_Detail__c = '';
				artifact.Object_ID_Created__c = objectIdResultMap.get(artifact.Id);
				this.listArtifactsToUpdate.add(artifact);

				if(!this.mapRemoteInvocationToUpdate.containsKey(artifact.Remote_Invocation__c)){
					this.mapRemoteInvocationToUpdate.put(artifact.Remote_Invocation__c, new Remote_Invocation__c(Id = artifact.Remote_Invocation__c, Status__c = AMS_Utils.COMPLETED));
				}
			}

		}

		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){
			if(!this.mapRemoteInvocationToUpdate.containsKey(ri.Id)){
				this.mapRemoteInvocationToUpdate.put(ri.Id, new Remote_Invocation__c(Id = ri.Id, Status__c = AMS_Utils.FAILED, Status_detail__c = VERIFY_RELATED_ARTEFACTS));
			}
		}

		if(!this.listArtifactsToUpdate.isEmpty()){
			update this.listArtifactsToUpdate;
		}

		if(!this.mapRemoteInvocationToUpdate.isEmpty()){
			update this.mapRemoteInvocationToUpdate.values();
		}

	}

}