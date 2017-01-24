@isTest
private class AMS_OscarMigrationFromCaseTest {
	
    static testmethod void AMS_OscarMigrationFromCaseTestCase1() {
      
      	RecordType SAAMcaseRecordType = [Select r.Id, r.Name from RecordType r where r.Name = 'SAAM' limit 1];

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
		saamCase.RecordTypeId = SAAMcaseRecordType.Id;
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
      
      	RecordType SAAMcaseRecordType = [Select r.Id, r.Name from RecordType r where r.Name = 'SAAM' limit 1];

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
		saamCase.RecordTypeId = SAAMcaseRecordType.Id;
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
      
      	RecordType SAAMcaseRecordType = [Select r.Id, r.Name from RecordType r where r.Name = 'SAAM' limit 1];

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
		saamCase.RecordTypeId = SAAMcaseRecordType.Id;
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
}