@isTest
private class IDCard_Account_Renewal_Updater_SchdlrTst {

	// CRON expression: midnight on March 2050.
	// Because this is a test, job executes
	// immediately after Test.stopTest().
	public static String CRON_EXP = '0 0 0 15 3 ? 2050';

	@isTest static void testRenewal() {

		//generate data for Test
		generateData();

		Test.startTest();

		// Schedule the test job
		String jobId = System.schedule('IDCard_Account_Renewal_Updater_Scheduler', CRON_EXP, new IDCard_Account_Renewal_Updater_Scheduler());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		// Verify the expressions are the same
		System.assertEquals(CRON_EXP, ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		// Verify the next time the job will run
		System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

		Date todayDate = Date.today();
		Date valDate = todayDate.addDays(2);

		// Verify the scheduled job hasn't run yet.
		List<Account> accountToUpdate = [SELECT Id, ID_Card_Corporate_Validation_Date__c, ID_Card_KeyAccount_features__c
										FROM Account
										WHERE ID_Card_Corporate_Validation_Date__c!=null and ID_Card_Corporate_Validation_Date__c > TODAY
										and ID_Card_Corporate_Validation_Date__c = :valDate ];

		System.assertEquals(accountToUpdate.size(), 2);

		Test.stopTest();

	}

	private static void generateData(){

		IATA_ISO_Country__c isoCountryCA = new  IATA_ISO_Country__c();
		isoCountryCA.Name = 'Canada';
		isoCountryCA.ISO_Code__c = 'CA';
		isoCountryCA.ISO_Code_Numeric__c = 888; //not real code
		isoCountryCA.CurrencyIsoCode = 'CAD';
		isoCountryCA.AIMS_Area_ID__c = '1'; //not real code
		isoCountryCA.VAT_Validation_Required__c = true;
		isoCountryCA.Tax_ID_Mandatory__c = false;
		isoCountryCA.AIMS_Area_Name__c = 'CANADA';
		insert isoCountryCA;

		//List of Account Data
		Id rtidca = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		List<Account> accs = new List<Account>();

		Account acc1 = new Account();
		acc1.RecordTypeId = rtidca;
		acc1.Name = 'KeyAccount Limited.';
		acc1.IATACode__c = '01254785';
		acc1.Industry = 'Travel Agent';
		acc1.IDCard_Key_Account__c = true;
		acc1.ID_Card_Key_Account_Discount__c = 10;
		acc1.ID_Card_KeyAccount_features__c = IDCardUtil.Key_Account_Feature_Only_KC_Purchase;
		acc1.ID_Card_Corporate_Validation_Date__c = System.today()+2;
		acc1.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
		acc1.Status__c = 'Approved';
		acc1.BillingStreet = '5056 FAIRVIEW STREET';
		acc1.BillingCity = 'BURLINGTON';
		acc1.BillingCountry = 'CANADA';
		acc1.BillingPostalCode = ' L7L 0B4';
		acc1.Is_AIMS_Account__c = true;
		accs.add(acc1);

		Account acc2 = new Account();
		acc2.RecordTypeId = rtidca;
		acc2.Name = 'KeyAccount Limited.';
		acc2.IATACode__c = '01254786';
		acc2.Industry = 'Travel Agent';
		acc2.IDCard_Key_Account__c = true;
		acc2.ID_Card_Key_Account_Discount__c = 10;
		acc2.ID_Card_KeyAccount_features__c = IDCardUtil.Key_Account_Feature_2_Years_validity;
		acc2.ID_Card_Corporate_Validation_Date__c = System.today()+2;
		acc2.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
		acc2.Status__c = 'Approved';
		acc2.BillingStreet = '5056 FAIRVIEW STREET';
		acc2.BillingCity = 'BURLINGTON';
		acc2.BillingCountry = 'CANADA';
		acc2.BillingPostalCode = ' L7L 0B4';
		acc2.Is_AIMS_Account__c = true;
		accs.add(acc2);

		insert accs;
	}


}