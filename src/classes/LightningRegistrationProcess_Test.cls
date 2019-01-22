@isTest
private class LightningRegistrationProcess_Test {
    
    static testMethod void testAuraMethods() {
        
		Test.startTest();
        Account oAccount = IECTestUtil.createSampleAccount();
        insert oAccount;
        Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
        
        User anUser = TestDataGenerator.generateUser('System Administrator', true);
        
        LightningRegistrationProcess.createcontact();
        LightningRegistrationProcess.checkemail('test@test1.it');
        String checkedEmail = LightningRegistrationProcess.checkemail(anUser.email);
        System.assertEquals('user_exists', checkedEmail);
        
        LightningRegistrationProcess.GetContactSalutationValues();
        LightningRegistrationProcess.GetContactJobFunctionValues();
        LightningRegistrationProcess.GetContactLabels();
        LightningRegistrationProcess.GetAccountLabels();
        
        LightningRegistrationProcess.GetFieldPicklistValuesCountry();
        
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;        
        LightningRegistrationProcess.GetFieldPicklistValuesCountry();
                
        Account nc = new Account();
        nc.BillingCountry='test';
        nc.Iata_Iso_Country__c=ISO_Country.id;        
        LightningRegistrationProcess.createContactAndAccount(new Contact(), nc, 'Airline');
        oAccount.BillingCountry='test';
        oAccount.Iata_Iso_Country__c=ISO_Country.id;
        update oAccount;
		Test.stopTest();
		
        LightningRegistrationProcess.createContactAndAccount(oContact, oAccount, 'Airline');
        LightningRegistrationProcess.getHostURL();
        LightningRegistrationProcess.setFederationId(anUser.id, anUser.email);
        LightningRegistrationProcess.getCommunityName();
        
        String orgUrl = URL.getSalesforceBaseUrl().getHost();
        String comunityUrl=Site.getBaseUrl();
        
        LightningRegistrationProcess.createUserFromExistingContact(oContact.Email);
        LightningRegistrationProcess.assignIdentityPermissionSet(anUser.id);
        
        LightningRegistrationProcess.getLanguageFromURL();
        
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'firstName', LastName = 'L', Email = 'test@test.com', phone='(514) 111 2222',AccountId=oAccount.Id, RecordTypeId= rtId);
        insert c;
                
        checkedEmail = LightningRegistrationProcess.checkemail(c.email);
        
        String userId = LightningRegistrationProcess.createUserFromExistingContact(c.Email);
        System.assertEquals(null, userId);
        
        rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'IATA_Service_Provider_Contact');
        
        Contact c1 = new Contact(FirstName = 'firstName1', LastName = 'L2', Email = 'test2@test.com', phone='(513) 141 2125',AccountId=oAccount.Id, RecordTypeId= rtId);
        insert c1;
        
        checkedEmail = LightningRegistrationProcess.checkemail(c1.email);
        System.assertEquals('create_contactanduser', checkedEmail);
        
        userId = LightningRegistrationProcess.createContactAndAccount(c1, oAccount, 'Airline');
        
        LightningRegistrationProcess.checkConAvailable(new Contact(FirstName = 'firstName2', LastName = 'L3', Email = 'test3@test.com', phone='(515) 146 2178',AccountId=oAccount.Id, RecordTypeId= rtId));
        
    }
    
}