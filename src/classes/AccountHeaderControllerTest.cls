@isTest
private class AccountHeaderControllerTest {

	@testSetup static void setup(){

		// create test account1
		Account account1 = new Account(
			Name = 'Test account 1',
			IATACode__c = '1234567',
			Type = AMS_Utils.SECTOR_PASSENGER,
			Sector__c = AMS_Utils.SECTOR_PASSENGER,
			Category__c = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT,
			BillingCity = 'Lisboa',
			BillingCountry = 'Portugal',
			BillingStreet = 'some street',
			Location_Type__c = 'HO',
			Location_Class__c = 'C',
			Purge_Flag__c = false
		);
		insert account1;

	}

	@isTest static void testMethods() {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = New User(

			Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);
		System.runAs(testUser) {
		List<Account> accts = [SELECT Id, Name, Accreditation_date__c, Status__c , Location_Class__c, IATACode__c from Account];
		List<Boolean> editList = new List<Boolean>();
		ApexPages.StandardController stdController = new ApexPages.StandardController(accts[0]);
		AccountHeaderController controller = new AccountHeaderController(stdController);
		editList = AccountHeaderController.getCanEdit();
		system.assertEquals(true, editList[0]);
		Account acc = AccountHeaderController.saveRecord(accts[0]);
		}
	}

}
