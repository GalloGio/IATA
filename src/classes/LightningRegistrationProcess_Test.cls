@isTest
private class LightningRegistrationProcess_Test {
    
    static testMethod void testAuraMethods() {
        
        Account oAccount = IECTestUtil.createSampleAccount();
        insert oAccount;
        Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
        
        User anUser = TestDataGenerator.generateUser('System Administrator', true);
        
        LightningRegistrationProcess.createcontact();
        LightningRegistrationProcess.checkemail('test@test1.it');
        LightningRegistrationProcess.checkemail(anUser.email);
        LightningRegistrationProcess.GetContactSalutationValues();
        LightningRegistrationProcess.GetContactJobFunctionValues();
        //LightningRegistrationProcess.GetAccountSectorValues();
//        LightningRegistrationProcess.GetAccountCategoryValues();
        LightningRegistrationProcess.GetContactLabels();
        LightningRegistrationProcess.GetAccountLabels();
        
        LightningRegistrationProcess.GetFieldPicklistValuesCountry();
        
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;        
        LightningRegistrationProcess.GetFieldPicklistValuesCountry();
                
       /* LightningRegistrationProcess.SearchCompany('Airline','12345','123','Switzerland','Test',null);
        LightningRegistrationProcess.SearchCompany('Airline',null,null,'Switzerland','Test',null);
        LightningRegistrationProcess.SearchCompany('GSA',null,null,'Switzerland','Test',null);
        LightningRegistrationProcess.SearchCompany('Agency',null,null,'Switzerland','Test','Cargo');
        LightningRegistrationProcess.SearchCompany('Agency',null,null,'Switzerland','Test','Travel');
        LightningRegistrationProcess.SearchCompany('Other Company',null,null,'Switzerland','Test',null);
        LightningRegistrationProcess.SearchCompany('General Public',null,null,'Switzerland','Test',null);
        */
        Account nc = new Account();
        nc.BillingCountry='test';
        nc.Iata_Iso_Country__c=ISO_Country.id;        
        LightningRegistrationProcess.createContactAndAccount(new Contact(), nc, 'Airline');
        oAccount.BillingCountry='test';
        oAccount.Iata_Iso_Country__c=ISO_Country.id;
        update oAccount;
        LightningRegistrationProcess.createContactAndAccount(oContact, oAccount, 'Airline');
        LightningRegistrationProcess.getHostURL();
        LightningRegistrationProcess.setFederationId(anUser.id, anUser.email);
        LightningRegistrationProcess.getCommunityName();

        
    }
    
}