@isTest 
private class clsMassCaseCreationNonComplianceBatchTst {
	

	static testMethod void testClsMassCaseCreationNonComplianceBatch(){

		//Data test preparation

		//create Iata_Iso_Country
		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name='United States', ISO_Code__c='US', AIMS_Area_Name__c = 'United States',
															Case_BSP_Country__c = 'United States', Region__c = 'Americas');
		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='PT', AIMS_Area_Name__c = 'Portugal', Region__c = 'Europe');
		countries.add(country);
		countries.add(country2);
		insert countries;

		Account account = new Account(IATACode__c = '1234567');
        account.Name = 'Test account';
        account.BillingCountry = 'United States';
        account.Type = 'IATA Cargo Agent';
        account.IATA_ISO_Country__c = country.ID;
        insert account;

        Contact aContact = new Contact();
        aContact.AccountId = account.ID;
        aContact.FirstName = 'Test';
        acontact.LastName = 'Contact 1';
        aContact.Email = 'testemail@blablaemail.com';
        aContact.Phone = '5151515151';
        insert aContact;

        List<Case> listToBatch = new List<Case>();
        Id SIDRARecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');

		for(Integer i=1; i<=9; i++){
			Case c = new Case(AccountID = account.ID, Account = account, ContactID = aContact.ID, Contact = aContact, RecordTypeid = SIDRARecordTypeId, 
							BSP_CASS__c = 'BSP', Status = 'Open', Subject = 'subject' + i);
			listToBatch.add(c);
		}

		Account account2 = new Account(IATACode__c = '1234567');
        account2.Name = 'Test account';
        account2.BillingCountry = 'Portugal';
        account2.Type = 'IATA test';
        account2.IATA_ISO_Country__c = country2.ID;
        insert account2;

		Case c2 = new Case(accountID = account2.ID , Account = account2, Contact = aContact, ContactID = aContact.ID, SCF_Reason_IFAP__c = 'reason10');
		listToBatch.add(c2);

		insert listToBatch;

		Test.startTest();

		clsMassCaseCreationNonComplianceBatch massCaseBatch = new clsMassCaseCreationNonComplianceBatch();
		massCaseBatch.caseList = listToBatch;
		massCaseBatch.Description = 'Batch test description';
		massCaseBatch.Subject = 'Batch test Subject';
		massCaseBatch.Deadline = Date.today();

		Database.executeBatch(massCaseBatch, 200);

		Test.stopTest();

		List<Case> caseListAfterBatch = [SELECT ID FROM Case];
         
		System.assertEquals(20, caseListAfterBatch.size());

		/*
		Id recordType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

		Case case1 = [SELECT ID, New_IFAP_Deadline_date__c, BSPCountry__c, Region__c,Subject,CaseArea__c FROM Case Where Subject = 'subject1' AND RecordTypeId =:recordType];
		System.assertEquals(Date.today(), case1.New_IFAP_Deadline_date__c);
		System.assertEquals(country.Case_BSP_Country__c, case1.BSPCountry__c);
		System.assertEquals(country.Region__c, case1.Region__c);

		Case case2 = [SELECT ID, New_IFAP_Deadline_date__c, BSPCountry__c FROM Case Where Subject = 'reason10' AND RecordTypeId =:recordType];
		System.assertEquals(null, case2.New_IFAP_Deadline_date__c);
		System.assertEquals(account2.BillingCountry, case2.BSPCountry__c);
		*/

	}

}