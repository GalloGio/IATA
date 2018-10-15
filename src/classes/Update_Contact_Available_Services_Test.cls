@isTest
private class Update_Contact_Available_Services_Test {
	
	@testSetup static void setup() {
		DateTime dt = system.now()+90;
		Date d = date.newinstance(dt.year(), dt.month(), dt.day());

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Americas');
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeID('Account','IATA_Agency');
		Account a1 = new Account(Name='Test1 Agency', RecordtypeId=agencyRT,
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED, 
			Is_PCI_compliant__c = 'No', ANG_PCI_compliance_expiry_date__c = d);
		agencylist.add(a1);
		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin', Available_Services__c = null);
		Contact co2 = new Contact(AccountId = a1.id, Firstname = 'teste2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin',Available_Services__c = null);
		Contact co3 = new Contact(AccountId = a1.id, Firstname = 'teste3', Lastname='test3', Phone = '911111113', MobilePhone = '911111113', Email = 'test3@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved', Available_Services__c = null);
		
		List<Contact> cos = new List<Contact>{co1,co2,co3}; 
		insert cos;

		Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal'];

        User testeUser1 = new User (
                Alias = 'newUser1',
                Email='newuser1@testorg.com',
                EmailEncodingKey='UTF-8',
                LastName='Testing1',
                LanguageLocaleKey='en_US',
                ContactId = co1.id,
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='newuser1@testorg.com',
                Mgmt_Report_Team__c = true
            );

        User testeUser2 = new User (
                Alias = 'newUser2',
                Email='newuser2@testorg.com',
                EmailEncodingKey='UTF-8',
                LastName='Testing1',
                LanguageLocaleKey='en_US',
                ContactId = co2.id,
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='newuser2@testorg.com',
                Mgmt_Report_Team__c = true
            );

        User testeUser3 = new User (
                Alias = 'newUser3',
                Email='newuser3@testorg.com',
                EmailEncodingKey='UTF-8',
                LastName='Testing1',
                LanguageLocaleKey='en_US',
                ContactId = co3.id,
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='newuser3@testorg.com',
                Mgmt_Report_Team__c = true
            );

        List<User> us = new List<User>{testeUser1,testeUser2,testeUser3}; 
		insert us;
	}

	@isTest static void test_method_one() {
		Test.startTest();
		Update_Contact_Available_Services_Batch batch = new Update_Contact_Available_Services_Batch();
        Database.executeBatch(batch, 10);
		Test.stopTest();
	}
	
	
	
}