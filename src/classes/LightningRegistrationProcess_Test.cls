@isTest
private class LightningRegistrationProcess_Test {
	
	static testMethod void testAuraMethods() {
		
		Account oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;
		Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
		
		
		LightningRegistrationProcess.createcontact();
		LightningRegistrationProcess.checkemail('test@test1.it');
		LightningRegistrationProcess.GetContactSalutationValues();
		LightningRegistrationProcess.GetContactJobFunctionValues();
		//LightningRegistrationProcess.GetAccountSectorValues();
		LightningRegistrationProcess.GetAccountCategoryValues();
		LightningRegistrationProcess.GetContactLabels();
		LightningRegistrationProcess.GetAccountLabels();
		LightningRegistrationProcess.GetFieldPicklistValuesCountry();
		
		LightningRegistrationProcess.SearchCompany('Airline','12345','123','Switzerland','Test',null);
		LightningRegistrationProcess.SearchCompany('Airline',null,null,'Switzerland','Test',null);
		LightningRegistrationProcess.SearchCompany('GSA',null,null,'Switzerland','Test',null);
		LightningRegistrationProcess.SearchCompany('Agency',null,null,'Switzerland','Test','Cargo');
		LightningRegistrationProcess.SearchCompany('Agency',null,null,'Switzerland','Test','Travel');
		LightningRegistrationProcess.SearchCompany('Other Company',null,null,'Switzerland','Test',null);
		LightningRegistrationProcess.SearchCompany('General Public',null,null,'Switzerland','Test',null);
		
		LightningRegistrationProcess.createContactAndAccount(new Contact(), new Account(), 'Airline');
		LightningRegistrationProcess.createContactAndAccount(oContact, oAccount, 'Airline');

		
	}
    
}