@isTest
private class AMS_OscarMigrationFromCaseTest {
	
    static testmethod void AMS_OscarMigrationFromCaseTestCase1() {
      
      	Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account';
		account1.IATACode__c = '4242424';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		insert account1;

		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = account1.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = account1.Id;
		saamCase.Subject = 'Test SAAM case';
		saamCase.Description = 'Test SAAM case';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = SAAMcaseRecordTypeId;
		saamCase.Reason1__c = 'New HO';
		insert saamCase;

      	Test.startTest();

        Map<String,Object> inputParams = new Map<String,Object>();

        inputParams.put('caseId', saamCase.Id);
        inputParams.put('processType', 'NEW.HO.1.0');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        AMS_OscarMigrationFromCase plugin = new AMS_OscarMigrationFromCase();
        plugin.invoke(request);

        plugin.describe();

    	Test.stopTest();
      	
    }

        static testmethod void AMS_OscarMigrationFromCaseTestCaseError1() {
      
      	Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account';
		account1.IATACode__c = '4242424';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		insert account1;

		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = account1.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = account1.Id;
		saamCase.Subject = 'Test SAAM case';
		saamCase.Description = 'Test SAAM case';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = SAAMcaseRecordTypeId;
		saamCase.Reason1__c = 'New HO wrong';
		insert saamCase;

      	Test.startTest();

        Map<String,Object> inputParams = new Map<String,Object>();

        inputParams.put('caseId', saamCase.Id);
        inputParams.put('processType', null); // wrong process Type

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        AMS_OscarMigrationFromCase plugin = new AMS_OscarMigrationFromCase();
        plugin.invoke(request);

        plugin.describe();

    	Test.stopTest();
      	
    }
	
	static testmethod void AMS_OscarMigrationFromCaseTestCaseError2() {
      
      	Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account';
		account1.IATACode__c = '4242424';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		insert account1;

		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = account1.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = account1.Id;
		saamCase.Subject = 'Test SAAM case';
		saamCase.Description = 'Test SAAM case';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = SAAMcaseRecordTypeId;
		saamCase.Reason1__c = 'New HO wrong';
		insert saamCase;

      	Test.startTest();

        Map<String,Object> inputParams = new Map<String,Object>();

        inputParams.put('caseId', '123123123');
        inputParams.put('processType', null); // wrong process Type

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        AMS_OscarMigrationFromCase plugin = new AMS_OscarMigrationFromCase();
        plugin.invoke(request);

        plugin.describe();

    	Test.stopTest();
      	
    }


    static testmethod void AMS_OscarMigrationFromCaseTestCaseBankChanges() {
    	insert new ISSP_CS__c(Name = 'No Notification Email Contact Id',Value__c = null);
    	Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

    	IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                                    Enable_Minor_Changes_from_Portal__c = true,
                                    Local_language_Agency_details_required__c = true);
        insert country;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
		parent.BillingCountry = 'Canada';
		parent.BillingStreet = 'some street';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
		parent.Type = 'IATA Passenger Sales Agent';
        parent.IATA_ISO_Country__c = country.Id;
        insert parent;       

        Account child = ISSP_ObjectFactory.createNewAccount();
		child.BillingCountry = 'Canada';
		child.BillingStreet = 'some street';
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
		child.Type = 'IATA Passenger Sales Agent';
        child.Location_Type__c = 'BR';
        insert child;


		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = parent.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = parent.Id;
		saamCase.Subject = 'Test SAAM case';
		saamCase.Description = 'Test SAAM case';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = SAAMcaseRecordTypeId;
		saamCase.Reason1__c = 'New HO';
		saamCase.OwnerId = UserInfo.getUserId();
		insert saamCase;

      	Test.startTest();

        Map<String,Object> inputParams = new Map<String,Object>();

        inputParams.put('caseId', saamCase.Id);
        inputParams.put('processType', 'BANK.ACCOUNT.CHANGES');
        inputParams.put('scopeOfChange', 'HO - Selected Branches');
        inputParams.put('concernedAgencyCodes', '2000000');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        AMS_OscarMigrationFromCase plugin = new AMS_OscarMigrationFromCase();
        plugin.invoke(request);

        plugin.describe();

    	Test.stopTest();

    	saamCase = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id = :saamCase.Id];
    	system.assertEquals('OSCAR_Communication', saamCase.RecordType.DeveloperName);

    	list<AMS_OSCAR__c> lstOscars = [SELECT Id FROM AMS_OSCAR__c];
    	system.assertEquals(2, lstOscars.size());


    }

    static testmethod void testIEPBankAccountSetupMigrationProcess() {
    	//insert new ISSP_CS__c(Name = 'No Notification Email Contact Id',Value__c = null);
    	Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

    	IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                                    Enable_Minor_Changes_from_Portal__c = true,
                                    Local_language_Agency_details_required__c = true);
        insert country;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account agency = ISSP_ObjectFactory.createNewAccount();
        agency.BillingCity = 'test';
		agency.BillingCountry = 'Canada';
		agency.BillingStreet = 'some street';
        agency.Name = 'test';
        agency.sector__c = 'Travel Agent';
        agency.Location_Type__c = 'HO';
        agency.RecordTypeId = rtIdBr ;
        agency.IATACode__c = '1000000';
		agency.Type = 'IATA Passenger Sales Agent';
        agency.IATA_ISO_Country__c = country.Id;
        insert agency;       

        Account iepVendor = ISSP_ObjectFactory.createNewAccount();
        iepVendor.Sector__C = 'Financial Institution';
        iepVendor.Category__c = 'Card Brand';
		iepVendor.BillingCountry = 'Canada';
		iepVendor.BillingStreet = 'some street';
        iepVendor.BillingCity = 'test2';
        iepVendor.Name = 'test2';
        iepVendor.Site = 'headSite';
        iepVendor.Sector__c = 'Travel Agent';
        iepVendor.IATA_ISO_Country__c = country.Id;
        iepVendor.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others');
        insert iepVendor;


		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = agency.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = iepVendor.Id;
		saamCase.Account_Concerned__c = agency.Id;
		saamCase.Subject = 'Test SAAM case';
		saamCase.Description = 'Test SAAM case';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = SAAMcaseRecordTypeId;
		saamCase.Type_of_customer__c = 'Auditors';
		saamCase.OwnerId = UserInfo.getUserId();
		saamCase.Origin = 'Email';
		saamCase.Region__c = 'Europe';

		insert saamCase;

      	Test.startTest();

        Map<String,Object> inputParams = new Map<String,Object>();

        inputParams.put('caseId', saamCase.Id);
        inputParams.put('processType', AMS_RecordCreatorWebservice.IEP_BANK_ACCOUNT_SETUP);
        inputParams.put('scopeOfChange', 'HO - Selected Branches');
        inputParams.put('concernedAgencyCodes', '2000000');
        inputParams.put('concernedContact',contact1.Id );


        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        AMS_OscarMigrationFromCase plugin = new AMS_OscarMigrationFromCase();
        plugin.invoke(request);

        plugin.describe();

    	Test.stopTest();

    	saamCase = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id = :saamCase.Id];
    	System.assertEquals('OSCAR_Communication', saamCase.RecordType.DeveloperName);

    	list<AMS_OSCAR__c> lstOscars = [SELECT Id, RecordType.Name FROM AMS_OSCAR__c LIMIT 1];
    	System.assertEquals('BANK ACCOUNT SETUP', lstOscars[0].RecordType.Name);

    }

}
