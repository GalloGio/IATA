public with sharing class ANG_DGIRemoteInvocation {

	private static Map<ID,Remote_Invocation_Artefact__c> artifactsWithParents;

	private static Map<string,Account> mapIATACodeAccs;

	public void doSanityCheck(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		
		if(remoteInvocationsIdToProcess.isEmpty())
			return;

		artifactsWithParents = new Map<Id,Remote_Invocation_Artefact__c>();

		Map<Id,Remote_Invocation_Artefact__c> artefacts = new Map<ID,Remote_Invocation_Artefact__c>([SELECT ID, External_ID__c, Format__c, Internal_ID__c, Name__c, Previous_Version__c, Remote_Invocation__c, 
															Request_Result__c, Source__c, Status__C, Status_Detail__c, Valid_From__c, Valid_To__c, Version__c, Version_Notes__c
															FROM Remote_Invocation_Artefact__c WHERE Remote_Invocation__c IN :remoteInvocationsIdToProcess]);								
		
		Set<String> keysForsBojects;

		for(Remote_Invocation_Artefact__c artifact: artefacts.values()){
			keysForsBojects.add(artifact.Internal_ID__c);
			artifactsWithParents.put(artifact.Remote_Invocation__c,artifact);
		}

		// let's take the orpahs and put them in error.

		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){
			if(artifactsWithParents.get(ri.Id) == null){
				ri.addError('The Remote invocation does not have a match for a remote invocation artifact. [Id:'+ri.Id+'].');
				remoteInvocationsIdToProcess.remove(ri); // one less to process
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
		for(Remote_Invocation__c ri : remoteInvocationsIdToProcess){
			if(mapIATACodeAccs.get(ri.Internal_ID__c) == null){
				ri.addError('The Remote invocation does not have a match for the IATA Code provided ('+ri.Internal_ID__c+') invocation artifact. [Id:'+ri.Id+'].');
				remoteInvocationsIdToProcess.remove(ri); // one less to process
			}
		}

		// so we're good, let's process

	}

	public void doProcess(Set<Remote_Invocation__c> remoteInvocationsIdToProcess){
		
		if(remoteInvocationsIdToProcess.isEmpty())
			return;
		


	}

	public Opportunitylineitem createStagingArea(AMS_Oscar__c oscar, Remote_Invocation__c ri){
	    
		Opportunitylineitem stagingFs;

		try{
        
            Opportunity opp = [Select Id, currencyIsoCode, Account.Region_formula__c from Opportunity where Related_Oscar__c = :oscar.Id];
            
            pricebook2 pb = [select id from pricebook2 where name = 'NewGen Generic'];
            PricebookEntry pbe = [select id,unitprice,product2id,product2.name from pricebookentry where pricebook2id = :pb.id limit 1];

			stagingFs = new Opportunitylineitem();

			List<Financial_Security__c> fsList = [Select Id, Amount__c, Security_Type__c,Reception_Case__c from Financial_Security__c where Account__c = :stagingFs.OSCAR_GDI__r.Account__c and Security_Type__c = 'GDI' and Security_Status__c in ('Active','Close to Expiry Date') ORDER BY CREATEDDATE DESC LIMIT 1];
			Financial_Institution__c dfltFI = [Select id from Financial_Institution__c where name = 'GDI - Euler Hermes'];
			
            stagingFs.OpportunityId = opp.Id;
            stagingFs.OSCAR_GDI__c = oscar.Id;
            stagingFs.Security_Type__c = 'GDI';
            stagingFs.Security_Status__c = 'Draft';
            stagingFs.Reception_Case__c = oscar.Oscar_Communication_Case_Id__c;
            if(!fsList.isEmpty())
                stagingFs.Financial_Security__c = fsList.get(0).Id;
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