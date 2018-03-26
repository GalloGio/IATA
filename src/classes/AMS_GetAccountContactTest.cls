@isTest
private class AMS_GetAccountContactTest {
	
	static testMethod void testGetContact1() {
		DateTime dt = system.now()+90;
		Date d = date.newinstance(dt.year(), dt.month(), dt.day());
		System.debug('d: ' + d);

		

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Americas');
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Account a1 = new Account(Name='Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', Location_Class__c = 'P',
			Is_PCI_compliant__c = 'yes', ANG_PCI_compliance_expiry_date__c = d);
		agencylist.add(a1);
		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin');
		Contact co2 = new Contact(AccountId = a1.id, Firstname = 'teste2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin');
		Contact co3 = new Contact(AccountId = a1.id, Firstname = 'teste3', Lastname='test3', Phone = '911111113', MobilePhone = '911111113', Email = 'test3@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved');
		
		List<Contact> cos = new List<Contact>{co1,co2}; 
		insert cos;

		Test.startTest();
		AMS_GetAccountContact.getContactId(new List<Id> {a1.Id});
		Test.stopTest();
	}

	static testMethod void testGetContact2() {
		DateTime dt = system.now()+90;
		Date d = date.newinstance(dt.year(), dt.month(), dt.day());
		System.debug('d: ' + d);

		

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Americas');
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Account a1 = new Account(Name='Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', Location_Class__c = 'P',
			Is_PCI_compliant__c = 'yes', ANG_PCI_compliance_expiry_date__c = d);
		insert a1;

		Account a2 = new Account(Name='Test2 Agency',
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '214214', Location_Class__c = 'P',
			Is_PCI_compliant__c = 'yes', ANG_PCI_compliance_expiry_date__c = d, Top_Parent__c = a1.Id);
		insert a2;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved');
		Contact co2 = new Contact(AccountId = a1.id, Firstname = 'teste2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved');
		
		List<Contact> cos = new List<Contact>{co1,co2}; 
		insert cos;

		Test.startTest();
		AMS_GetAccountContact.getContactId(new List<Id> {a2.Id});
		Test.stopTest();
	}
	
	
}