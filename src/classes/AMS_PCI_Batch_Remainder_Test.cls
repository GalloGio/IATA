@isTest
private class AMS_PCI_Batch_Remainder_Test {

	@testSetup static void setup() {
		/*** Set IATA ISO Country ***/
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Wakanda';
		country.ISO_Code__c = 'XW';
		country.ISO_Code_Numeric__c = 11;
		insert country;

		/*** Set IATA ISO State ***/
		IATA_ISO_State__c state = new IATA_ISO_State__c();
		state.Name = 'WAKA';
		state.ISO_Code__c = 'XW';
		state.IATA_ISO_Country__c = country.Id;
		insert state;

		Account agency = new Account(Name= 'Agency');		
		agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		agency.Location_Type__c = 'P';
		agency.Location_Class__c = 'HO';
		agency.Status__c = 'Approved';
		agency.IATACode__c = 'XW123456';
		agency.Sector__c = 'Travel Agent';
		agency.Category__c = 'IATA Passenger Sales Agent';
		insert agency;

		Contact admin = new Contact(FirstName= 'Admin', LastName= 'Contact', AccountId= agency.Id, Email= 'admin.contact@agency.xw');
		admin.Preferred_Language__c = 'English';
		insert admin;

		User usr = new User(ContactId= admin.Id, LastName= 'Contact', Alias= 'testA', Email= 'admin.contact@agency.xw', Username= 'admin.contact@test.xw');
		usr.EmailEncodingKey = 'UTF-8';
		usr.LanguageLocaleKey = 'en_US'; 
        usr.LocaleSidKey = 'en_US';
        usr.TimeZoneSidKey = 'Asia/Dubai'; 
        usr.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User' LIMIT 1].Id;
		insert usr;

		Case cse = new Case();
		cse.Subject = 'PCI DSS Compliant';
		cse.Reason1__c = 'PCI DSS Compliant';
		cse.ContactId = admin.Id;
		cse.AccountId = agency.Id;
		cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		insert cse;
		Test.setCreatedDate(cse.Id, DateTime.now().addDays(-30));
	}

	static testMethod void testStartAndStop() {
		Test.startTest();
		AMS_PCI_Batch_Remainder.start('0 1 * * * ?', 1);
		AMS_PCI_Batch_Remainder.stop();
		Test.stopTest();
	}

	static testMethod void testBatch_1() {
		Test.startTest();
		AMS_PCI_Batch_Remainder ctrl = new AMS_PCI_Batch_Remainder();
		Database.executeBatch(ctrl, 1);
		Test.stopTest();
	}

	static testMethod void testBatch_2() {
		Account agency = [SELECT Id, ANG_PCI_compliance_expiry_date__c FROM Account LIMIT 1];
		agency.ANG_PCI_compliance_expiry_date__c = Date.today().addDays(15);
		update agency;

		Test.startTest();
		AMS_PCI_Batch_Remainder ctrl = new AMS_PCI_Batch_Remainder();
		Database.executeBatch(ctrl, 1);
		Test.stopTest();
	}

	static testMethod void testBatch_3() {
		Case cse = [SELECT Id, ContactId FROM Case LIMIT 1];
		cse.ContactId = null;
		update cse;

		Test.startTest();
		AMS_PCI_Batch_Remainder ctrl = new AMS_PCI_Batch_Remainder();
		Database.executeBatch(ctrl, 1);
		Test.stopTest();
	}

	static testMethod void testBatch_4() {
		Account agency = [SELECT Id FROM Account LIMIT 1];
		Contact admin = new Contact(FirstName= 'Admin', LastName= 'Contact', AccountId= agency.Id, Email= 'admin2.contact@agency.xw');
		admin.Preferred_Language__c = 'English';
		insert admin;

		Case cse = [SELECT Id, ContactId FROM Case LIMIT 1];
		cse.ContactId = admin.Id;		
		update cse;

		Test.startTest();
		AMS_PCI_Batch_Remainder ctrl = new AMS_PCI_Batch_Remainder();
		Database.executeBatch(ctrl, 1);
		Test.stopTest();
	}

	static testMethod void testBatch_5() {
		Contact admin = [SELECT Id, Preferred_Language__c FROM Contact LIMIT 1];
		admin.Preferred_Language__c = 'AAAA';		
		update admin;

		Test.startTest();
		AMS_PCI_Batch_Remainder ctrl = new AMS_PCI_Batch_Remainder();
		Database.executeBatch(ctrl, 1);
		Test.stopTest();
	}	

}