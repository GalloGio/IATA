public with sharing class ANG_DGIRemoteInvocation implements ANG_RemoteInvocationINT{

	private static Map<ID,Remote_Invocation_Artefact__c> artifactsWithParents;
	private static Map<string,Account> mapIATACodeAccs;

	private static Financial_Institution__c dfltFI;
	private static pricebook2 pb;
	private static PricebookEntry pbe;

	public void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){

		Set<Remote_Invocation__c> remoteInvocationsGDI = new Set<Remote_Invocation__c>();

		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess)
			if(ri.Request_Type__c == 'GDI')	remoteInvocationsGDI.add(ri);

		if(remoteInvocationsGDI.isEmpty()) return;

		artifactsWithParents = new Map<Id,Remote_Invocation_Artefact__c>();

		Map<Id,Remote_Invocation_Artefact__c> artefacts = new Map<ID,Remote_Invocation_Artefact__c>([SELECT ID, External_ID__c, Format__c, Internal_ID__c, Name__c, Previous_Version__c, Remote_Invocation__c, 
															Request_Result__c, Source__c, Status__C, Status_Detail__c, Valid_From__c, Valid_To__c, Version__c, Version_Notes__c
															FROM Remote_Invocation_Artefact__c WHERE Remote_Invocation__c IN :remoteInvocationsGDI]);								
		
		Set<String> keysForsBojects;

		for(Remote_Invocation_Artefact__c artifact: artefacts.values()){

			keysForsBojects.add(artifact.Internal_ID__c);
			artifactsWithParents.put(artifact.Remote_Invocation__c,artifact);
		}

		// let's take the orpahs and put them in error.

		for(Remote_Invocation__c ri : remoteInvocationsGDI){

			if(artifactsWithParents.get(ri.Id) == null){
				ri.addError('The Remote invocation does not have a match for a remote invocation artifact. [Id:'+ri.Id+'].');
				remoteInvocationsIdToProcess.remove(ri); // one less to process
				remoteInvocationsGDI.remove(ri);
				artifactsWithParents.remove(ri.Id);
			}
		}

/*		
		// let's understand if the keys are all valid.
		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){

			String sobjectType = Id.valueOf(ri.Internal_ID__c).getSObjectType().getDescribe().getName();

			switch on sobjectType {
				when 'Account' {
					iatacodesToFetch.add(ri.Internal_ID__c);
				}	
				when 'Quote' {
					
				}
				when else {		  
				// not prepared for this.At.All.
				ri.addError('The Remote invocation Id does not have a match for valid sObject in Salesforce ('+sobjectType+'). [Id:'+ri.Id+'].');
				remoteInvocationsIdToProcess.remove(ri); // one less to process
				}
			}

		}
*/

		mapIATACodeAccs = new Map<String, Account>();

		for(Account acc : [SELECT ID, name, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c, IATACode__c, RecordTypeId FROM Account WHERE iataCode__c IN :keysForsBojects])
			mapIATACodeAccs.put(acc.IATACode__c,acc);
		
		// let's understand if the keys are all valid.
		for(Remote_Invocation__c ri : remoteInvocationsGDI){

			if(mapIATACodeAccs.get(ri.Internal_ID__c) == null){
				ri.addError('The Remote invocation does not have a match for the IATA Code provided ('+ri.Internal_ID__c+') invocation artifact. [Id:'+ri.Id+'].');
				remoteInvocationsIdToProcess.remove(ri); // one less to process
				remoteInvocationsGDI.remove(ri); 
			}
		}

		// so we're good, let's process

	}

	public void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		
		list<Remote_Invocation__c> remoteInvocationsGDI = new List<Remote_Invocation__c>();
		
		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess)
			if(ri.Request_Type__c == 'GDI') remoteInvocationsGDI.add(ri);	

		if(remoteInvocationsGDI.isEmpty()) return;

		//We have data, lets start processing...

		Map<String,AMS_Oscar__c> mapIATACodeOSCARs = new Map<String,AMS_OSCAR__c>();
		Map<String,Opportunity> opportunitiesMap = new Map<String,Opportunity>(); //key -> iata code
		Map<String,Financial_Security__c> financialSecuritiesMap = new Map<String,Financial_Security__c>(); //key -> iata code
		Set<ID> oscarIDs = new Set<ID>(); //used to fetch the opportunities

		//Opportunities to update
		List<Opportunity> updatedOpportunities = new List<Opportunity>();
		//the new Staging Financial Securities to be inserted
		List<Opportunitylineitem> stagingFSs = new List<Opportunitylineitem>();
		


		dfltFI = [Select id from Financial_Institution__c where name = 'GDI - Euler Hermes'];
		pb = [select id from pricebook2 where name = 'NewGen Generic'];
		pbe = [select id,unitprice,product2id,product2.name from pricebookentry where pricebook2id = :pb.id limit 1];



		//fetch and store OSCARS by iata code (FALTA VALIDAR PELA POIA DO TIPO GDI)
		
		for (AMS_OSCAR__c oscar : [SELECT ID, name, Account__r.IATACode__c FROM AMS_OSCAR__c WHERE Account__c IN :mapIATACodeAccs.values() ]){
			mapIATACodeOSCARs.put(oscar.Account__r.IATACode__c, oscar);
			oscarIDs.add(oscar.id);
		}

        //fetch and store opportunities by iata code
        for (Opportunity opp : [SELECT Id, currencyIsoCode, Account.Region_formula__c, Account.IATACode__c FROM Opportunity WHERE Related_Oscar__c IN :oscarIDs]){
			opportunitiesMap.put(opp.Account.IATACode__c, opp);
		}
		
		//List<Financial_Security__c> fsList = [Select Id, Amount__c, Security_Type__c,Reception_Case__c from Financial_Security__c where Account__c = :stagingFs.OSCAR_GDI__r.Account__c and Security_Type__c = 'GDI' and Security_Status__c in ('Active','Close to Expiry Date') ORDER BY CREATEDDATE DESC LIMIT 1];
		for (Financial_Security__c fs : [SELECT Id, Amount__c, Security_Type__c,Reception_Case__c FROM Financial_Security__c WHERE Account__r.IATACode__c IN :mapIATACodeOSCARs.keyset() AND Security_Type__c = 'GDI' AND Security_Status__c IN ('Active','Close to Expiry Date') ORDER BY CREATEDDATE DESC LIMIT 1]){
			financialSecuritiesMap.put(fs.Account__.IATACode__c, fs);
		}
		


		//and finally lets start creating staging areas
		for(Remote_Invocation__c ri : remoteInvocationsGDI){

			AMS_OSCAR__c oscar = mapIATACodeOSCARs.get(ri.Internal_ID__c);
			Opportunity opp = opportunitiesMap.get(ri.Internal_ID__c);
			Financial_Security__c fs = financialSecuritiesMap.get(ri.Internal_ID__c);

			//if tenho que mudar a cena na opportunidade


			stagingFSs.add(createStagingArea(oscar,ri,opp,fs));
		}

		update updatedOpportunities;
		insert stagingFSs;
	}

	//aqui vai ter que receber a oportunidade e o financial security
	public Opportunitylineitem createStagingArea(AMS_Oscar__c oscar, Remote_Invocation__c ri, Opportunity opp, Financial_Security__c fsList){
	    
		Opportunitylineitem stagingFs;

		try{
        
            //Opportunity opp = [Select Id, currencyIsoCode, Account.Region_formula__c from Opportunity where Related_Oscar__c = :oscar.Id];
            
			stagingFs = new Opportunitylineitem();

			//List<Financial_Security__c> fsList = [Select Id, Amount__c, Security_Type__c,Reception_Case__c from Financial_Security__c where Account__c = :stagingFs.OSCAR_GDI__r.Account__c and Security_Type__c = 'GDI' and Security_Status__c in ('Active','Close to Expiry Date') ORDER BY CREATEDDATE DESC LIMIT 1];
			
            stagingFs.OpportunityId = opp.Id;
            stagingFs.OSCAR_GDI__c = oscar.Id;
            stagingFs.Security_Type__c = 'GDI';
            stagingFs.Security_Status__c = 'Draft';
            stagingFs.Reception_Case__c = oscar.Oscar_Communication_Case_Id__c;

            if(fsList != null) stagingFs.Financial_Security__c = fsList.Id;
            
            stagingFs.Quantity = 1;
            stagingFs.Region__c = opp.Account.Region_formula__c;
            stagingFs.Financial_Institution__c = dfltFI.Id; 
            stagingFs.TotalPrice = 1;
            stagingFs.pricebookentryid = pbe.id;

        
        }catch(Exception e){
            System.debug(e.getStackTraceString());
			ri.addError('Unable to create staging are for the certificate of endorsment [Id:'+ri.Id+'] - Reason:'+e.getStackTraceString());
        }

		return stagingFs;
	}
}