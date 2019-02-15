public without sharing class ANG_GDIRemoteInvocation implements ANG_RemoteInvocationINT{

	public void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		map<string, string> mapOfferIdIataCode = new map<string,string>();	//Map index: offer Id. Value: related IATA Code. Arriving from interface.
		Map<String, PricebookEntry> mapCurrencyISOCodePBE = new map<String,pricebookentry>();
		map<id, Remote_Invocation__c> mapRemoteInvocationToUpdates = new map<id, Remote_Invocation__c>();
		List<Remote_Invocation_Artefact__c> listArtifactsToUpdate = new List<Remote_Invocation_Artefact__c>();
		map<id, Remote_Invocation_Artefact__c> mapValidArtefacts = new map<id, Remote_Invocation_Artefact__c>();
		Set<Remote_Invocation__c> setValidRemoteInvocation = new Set<Remote_Invocation__c>();
		Set<String> currencyIsoCodeToFetch = new Set<String>();

		Financial_Institution__c dfltFI;
		Id pb;

		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){

			if(ri.Request_Type__c == RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO){
			//let's see if the source and request type are consistent
			if(ri.Source__c=='GDI'){
					setValidRemoteInvocation.add(ri);
					currencyIsoCodeToFetch.add(ri.CurrencyISOCode);
				
			}else{
				//ri.Status__c = 'Failed';
				//ri.Status_detail__c = 'Invalid Request Type';
				mapRemoteInvocationToUpdates.put(ri.id, new Remote_Invocation__c(Id = ri.id, Status__c = 'Failed', Status_detail__c = 'Invalid Request Type'));
			}
			}
			
		}

		//there is no consistent request. Update them with failure and exit
		if(setValidRemoteInvocation.isEmpty()){
			update mapRemoteInvocationToUpdates.values();
			return;
		} 

		//Fetch the priceBook along with all entries
		try{
			dfltFI = [Select id from Financial_Institution__c where name = 'GDI - Euler Hermes'];

			if(!Test.isRunningTest()) pb = [select id from pricebook2 where name = 'NewGen Generic'].id;
			else pb = Test.getStandardPricebookId();

			for(pricebookentry pbe : [SELECT id,unitprice,product2id,product2.name,CurrencyIsoCode FROM pricebookentry WHERE pricebook2id = :pb AND currencyISOCode in :currencyIsoCodeToFetch])
				mapCurrencyISOCodePBE.put(pbe.CurrencyISOCode, pbe);
		}
		catch(Exception e){
			for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){
				/*ri.Status__c = 'Failed';
				ri.Status_Detail__c = 'Exception while fetching products ' + e.getMessage();
				mapRemoteInvocationToUpdates.put(ri.id, ri);*/
				mapRemoteInvocationToUpdates.put(ri.id, new Remote_Invocation__c(Id = ri.id, Status__c = 'Failed', Status_detail__c = 'Exception while fetching products ' + e.getMessage()));
			}
			update mapRemoteInvocationToUpdates.values();
			return;
		}

		//Query artefacts
		list<Remote_Invocation__c> lsRI = [select ID, Status__c, Status_Detail__c, CurrencyISOCode
											,(select id, External_ID__c, Internal_ID__c, Remote_Invocation__c, Remote_Invocation__r.CurrencyISOCode,
												Request_Result__c, Source__c, Status_Detail__c, Valid_From__c, Valid_To__c, CurrencyIsoCode, Amount__c
												from Remote_Invocation_Artefacts__r)
											from Remote_Invocation__c where id in :setValidRemoteInvocation];

		//Validations
		for(Remote_Invocation__c ri: lsRI){
			//Check if there is any artefact related to the remote invocation
			if(ri.Remote_Invocation_Artefacts__r.size()==0){
				/*ri.Status__c = 'Failed';
				ri.Status_detail__c = 'The Remote invocation does not have a match for a remote invocation artifact.';
				mapRemoteInvocationToUpdates.put(ri.id, ri);*/
				mapRemoteInvocationToUpdates.put(ri.id, new Remote_Invocation__c(Id = ri.id, Status__c = 'Failed', Status_detail__c = 'The Remote invocation does not have a match for a remote invocation artifact. '));
			}else{
				//Check to see if pricebook with given currency exists
				if(!mapCurrencyISOCodePBE.containsKey(ri.CurrencyISOCode)){
					ri.Status__c = 'Failed';
					ri.Status_detail__c = 'Product with currency ' + ri.CurrencyISOCode + ' not found';
					mapRemoteInvocationToUpdates.put(ri.id, ri);
				}else{
					for(Remote_Invocation_Artefact__c artifact: ri.Remote_Invocation_Artefacts__r){
						//Check all necessary fields are populated
						if(string.isBlank(artifact.Internal_ID__c) || string.isBlank(artifact.External_ID__c) || string.isBlank(string.valueOf(artifact.Valid_From__c)) || string.isBlank(string.valueOf(artifact.Amount__c))){
							artifact.Request_Result__c = 'Failed';
							artifact.Status_Detail__c = 'Missing mandatory fields';
							listArtifactsToUpdate.add(artifact);
						}else{
							mapOfferIdIataCode.put(artifact.External_ID__c, artifact.Internal_ID__c);
							mapValidArtefacts.put(artifact.id, artifact);
						}
					}
				}
			}
		}

		if(mapValidArtefacts.isEmpty()){
			update mapRemoteInvocationToUpdates.values();
			update listArtifactsToUpdate;
			return;
		}

		//fetch all opportunities related to offerIds received
		map<string, Opportunity> mapOpty = new map<string, Opportunity>();
		for(opportunity opty:[select id, AccountId, GDI_Offer_Id__c, Related_Oscar__c, Related_Oscar__r.Oscar_Communication_Case_Id__c from Opportunity where GDI_Offer_Id__c in:mapOfferIdIataCode.keyset()])
			mapOpty.put(opty.GDI_Offer_Id__c, opty);

		//fetch all accounts related to IATAcodes received
		map<string, id> mapIATACodeId = new map<string, id>();
		for(Account accnt:[select id, IATACode__c from Account where IATACode__c in:mapOfferIdIataCode.values() and recordtype.developerName='IATA_Agency'])
			mapIATACodeId.put(accnt.IATACode__c, accnt.id);

		//Check that
		// 1) IATACode received exists
		// 2) OfferID received Exists
		// 3) if both exists, IATA Code is associated to OfferId received
		for(Remote_Invocation_Artefact__c artifact: mapValidArtefacts.values()){
			if(!mapIATACodeId.containsKey(artifact.Internal_ID__c)){
				artifact.Request_Result__c = 'Failed';
				artifact.Status_Detail__c = 'Account not found!';
				listArtifactsToUpdate.add(artifact);
				mapValidArtefacts.remove(artifact.Id);
				continue;
			}

			if(!mapOpty.containsKey(artifact.External_ID__c)){
				artifact.Request_Result__c = 'Failed';
				artifact.Status_Detail__c = 'Offer ID not found';
				listArtifactsToUpdate.add(artifact);
				mapValidArtefacts.remove(artifact.Id);
				continue;
			}

			if(mapOpty.containsKey(artifact.External_ID__c)){
				if(mapOpty.get(artifact.External_ID__c).AccountId != mapIATACodeId.get(artifact.Internal_ID__c)){
					artifact.Request_Result__c = 'Failed';
					artifact.Status_Detail__c = 'Offer ID is associated to a different IATA Code';
					listArtifactsToUpdate.add(artifact);
					mapValidArtefacts.remove(artifact.Id);
					continue;
				}
			}
		}

		if(!mapValidArtefacts.isEmpty()){
			//Yippee ki-yay! Let's process the artefacts
			list<case> lsCaseToUpd = new list<case>();
			list<AMS_Oscar__c> lsOscarToUpdate = new list<AMS_OSCAR__c>();
			List<Opportunitylineitem> stagingFSs = new List<Opportunitylineitem>();

			for(opportunity opty:[select id, CurrencyISOCode, AccountId, Account.Region_formula__c, GDI_Offer_Id__c, Related_Oscar__c, Related_Oscar__r.Oscar_Communication_Case_Id__c from Opportunity where GDI_Offer_Id__c in:mapOfferIdIataCode.keyset()])
				mapOpty.put(opty.GDI_Offer_Id__c, opty);

			for(Remote_Invocation_Artefact__c artifact: mapValidArtefacts.Values()){
				Opportunity opp = mapOpty.get(artifact.External_ID__c);

				lsCaseToUpd.add(new Case(New_interaction__c = 'New Attachment', ID = opp.Related_Oscar__r.Oscar_Communication_Case_Id__c));
				lsOscarToUpdate.add(new AMS_OSCAR__c(id=opp.Related_Oscar__c, Financial_Security_Received__c = system.today()));

				Opportunitylineitem stagingFs = new Opportunitylineitem();

				stagingFs.OpportunityId = opp.Id;
				stagingFs.OSCAR_GDI__c = opp.Related_Oscar__c;
				stagingFs.Security_Type__c = 'GDI';
				stagingFs.Security_Status__c = 'Draft';
				stagingFs.Quantity = 1;

				//if(fsList != null) stagingFs.Financial_Security__c = fsList.Id;
				stagingFs.Region__c = opp.Account.Region_formula__c;
				stagingFs.Financial_Institution__c = dfltFI.Id; 
				stagingFs.TotalPrice = artifact.Amount__c;
				opp.CurrencyISOCode = artifact.Remote_Invocation__r.CurrencyISOCode;
				stagingFS.FS_Currency__c = artifact.CurrencyISOCode;
				stagingFS.Amount__c = artifact.Amount__c;
				stagingFS.Validity_Start_Date__c = artifact.Valid_From__c;
				stagingFS.Expiry_Date__c = artifact.Valid_To__c;

				stagingFs.pricebookentryid = mapCurrencyISOCodePBE.get(artifact.Remote_Invocation__r.currencyISOCode).id;

				stagingFs.Reception_Case__c = opp.Related_Oscar__r.Oscar_Communication_Case_Id__c;
				stagingFs.SourceId__c = artifact.id;
				stagingFSs.add(stagingFS);
			}

			if(!lsCaseToUpd.isEmpty()) update lsCaseToUpd;
			if(!lsOscarToUpdate.isEmpty()) update lsOscarToUpdate;
			update mapOpty.values();
			if(!stagingFSs.isEmpty()) insert stagingFSs;

			//weird what I'm doing, but is needed
			map<string,id> mapIdCreated = new map<string,id>();
			for(Opportunitylineitem oli:stagingFSs)
				mapIdCreated.put(string.valueOf(oli.SourceId__c), oli.Id);

			for(Remote_Invocation_Artefact__c artifact: mapValidArtefacts.Values()){
				artifact.Request_Result__c = 'Completed';
				artifact.Status_Detail__c = '';
				artifact.Object_ID_Created__c = mapIdCreated.get(artifact.Id);
				listArtifactsToUpdate.add(artifact);

				if(!mapRemoteInvocationToUpdates.containsKey(artifact.Remote_Invocation__c))
				mapRemoteInvocationToUpdates.put(artifact.Remote_Invocation__c, new Remote_Invocation__c(id=artifact.Remote_Invocation__c, Status__c = 'Completed'));
			}
		}else{
			for(Remote_Invocation__c ri: lsRI){
				mapRemoteInvocationToUpdates.put(ri.Id, new Remote_Invocation__c(id=ri.Id, Status__c = 'Failed', Status_detail__c='Verify related artefacts for details'));
			}
		}
	
		update listArtifactsToUpdate;
		update mapRemoteInvocationToUpdates.values();
	}

	public void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){}
}