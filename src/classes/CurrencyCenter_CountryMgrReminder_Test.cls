@isTest
private class CurrencyCenter_CountryMgrReminder_Test {

	@isTest
	private static void testSchedule() {
		test.startTest();
		CurrencyCenter_CountryManagerReminder m = new CurrencyCenter_CountryManagerReminder();
		String sch = '01 01 * * * ?';
		String jobID = system.schedule('Test CurrencyCenter_CountryManagerReminder', sch, m);
		test.stopTest();
	}

	@isTest
	private static void testBatch() {
		test.startTest();
		CurrencyCenter_CountryManagerReminder batch = new CurrencyCenter_CountryManagerReminder();
		Database.executeBatch(batch);
		test.stopTest();
	}

	@isTest
	private static void testSendEmails() {
		//ISO Country
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.name = 'Portugal';
		country.ISO_Code__c = 'PT';
		country.Case_BSP_Country__c = 'Portugal';
		country.Region__c = 'Europe';
		country.LVA_CountryLanguage__c = 'pt';
		country.Country_Manager__c = UserInfo.getUserId();
		insert country;

		//Country Profile
		Country_Profile__c cp = new Country_Profile__c(
			Name=country.Name,
			IATA_ISO_Country__c = country.Id,
			Listed_In__c = 'Blocked Funds');
		insert cp;
		list<Country_Profile__c> listCP = new list<Country_Profile__c>{cp};

		test.startTest();
		CurrencyCenter_CountryManagerReminder batch = new CurrencyCenter_CountryManagerReminder();
		batch.sendEmails(listCP);
		test.stopTest();
	}
}
