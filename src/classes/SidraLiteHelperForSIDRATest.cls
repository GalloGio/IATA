@isTest
private class SidraLiteHelperForSIDRATest {
	
	@testSetup
	static void setup(){
		Account acct = new Account();
		acct.Name = 'Sidra Lite Account Test';
		acct.Status__c = 'Approved';
		insert acct;

		Contact cont = new Contact();
		cont.AccountId = acct.Id;
		cont.LastName = 'Sidra Lite Contact';
		insert cont;

		Case parentCase = new Case();
		parentCase.Region__c = 'Europe';
		parentCase.BSPCountry__c = 'Portugal';
		parentCase.AccountId = acct.Id;
		parentCase.ContactId = cont.Id;
		parentCase.GDI_Premium__c = 1;
		insert parentCase;
	}

	@isTest
	static void createCaseFirstNonComplianceTest(){

		Case parentCase = 
			[SELECT 
				Id, 
				AccountId, 
				ContactId,
				Region__c, 
				BSPCountry__c 
			 FROM 
			 	Case
			];

		Case newCase = SidraLiteHelperForSIDRA.createDummyCaseFirstNonCompliance(parentCase);

		System.assertEquals(newCase.Origin, 'IATA Internal User');
		System.assertEquals(newCase.Status, 'Open');
		System.assertEquals(newCase.Subject, 'SIDRA Lite – Financial Security Non-compliance');
		System.assertEquals(newCase.Priority, 'Normal');
		System.assertEquals(newCase.ParentId, parentCase.Id);
		System.assertEquals(newCase.RecordTypeId, SidraLiteManager.RECORDTYPE_SIDRA_LITE);
		System.assertEquals(newCase.AccountId, parentCase.AccountId);
		System.assertEquals(newCase.ContactId, parentCase.ContactId);
		System.assertEquals(newCase.Region__c, parentCase.Region__c);
		System.assertEquals(newCase.BSP_CASS__c, 'BSP');
		System.assertEquals(newCase.BSPCountry__c, parentCase.BSPCountry__c);
		System.assertEquals(newCase.SIDRA_Lite_Reason__c, 'Financial Security Non-compliance');
		System.assertEquals(newCase.Reason_for_Default__c, 'Suspension - FS Non Compliance');
		System.assertEquals(newCase.SIDRA_Lite_Default_Date__c, System.today());
		
	}

	@isTest
	static void checkBusinessRulesTest(){

		Case parentCase = 
			[SELECT 
				Id, 
				AccountId, 
				ContactId,
				Region__c, 
				BSPCountry__c,
				Agency_Fees__c,
				GDI_Premium__c,
				IATA_Charges__c,
				Account.Status__c,
				Short_Payment_Amount__c
			 FROM 
			 	Case
			];

		try {
			parentCase.GDI_Premium__c = 0;
			SidraLiteHelperForSIDRA.checkBussinessRules(parentCase);
		}
		catch(Exception e){
			System.assertEquals(e.getMessage(), 'Conditions are not met to create a Financial security non-compliance case: GDI Premium cannot be 0.');
		}

		try {
			parentCase.GDI_Premium__c = 1;
			SidraLiteHelperForSIDRA.checkBussinessRules(parentCase);
		}
		catch(Exception e){
			System.assertEquals(e.getMessage(), 'Conditions are not met to create a Financial security non-compliance case: A value is required for fields: Short Payment Amount, IATA Charges, Agency Fees, IATA Country, Contact Name and Region.');
		}
		
		try {
			parentCase.IATA_Charges__c = 0.0;
			parentCase.Short_Payment_Amount__c = 4.0;
			parentCase.Agency_Fees__c = 0.0;
			SidraLiteHelperForSIDRA.checkBussinessRules(parentCase);
		}
		catch(Exception e){
			System.assertEquals(e.getMessage(), 'Conditions are not met to create a Financial security non-compliance case: Short Payment Amount cannot exceed GDI Premium + IATA Charges + Agency Fees.');
		}

		try {
			parentCase.Short_Payment_Amount__c = 1;
			SidraLiteHelperForSIDRA.checkBussinessRules(parentCase);
		}
		catch(Exception e){
			System.assertEquals(e.getMessage(), 'Conditions are not met to create a Financial security non-compliance case: Invalid Account Status: ' + parentCase.Account.Status__c + '.');
		}

	}
	
}