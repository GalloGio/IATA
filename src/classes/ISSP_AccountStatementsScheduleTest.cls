@isTest
private class ISSP_AccountStatementsScheduleTest {

	// CRON expression: midnight on March 2050.
	// Because this is a test, job executes
	// immediately after Test.stopTest().

	@isTest static void testISSP_AccountStatementsSchedule() {

		generateData();

		Test.startTest();

		// Schedule the job
		String jobId = System.schedule('ISSP_AccountStatementsSchedule','0 0 0 1 1 ? 2050', new ISSP_AccountStatementsSchedule());

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		// Verify the expressions are the same
		System.assertEquals('0 0 0 1 1 ? 2050', ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		// Verify the next time the job will run
		System.assertEquals('2050-01-01 00:00:00', String.valueOf(ct.NextFireTime));

		Test.stopTest();
	}

	private static void generateData(){

		Notification_template__c notificationTemp = new Notification_template__c(Type__c = 'Information', Subject__c = 'test subject', Notification_color__c = '#007FFF', Expire_in_days__c = 10, Admins_Users__c = 'User');
		insert notificationTemp;

		ISSP_Notifications_Trigger__c notificationsSetting = new ISSP_Notifications_Trigger__c();
		notificationsSetting.name = 'Account Statements';
		notificationsSetting.Notification_Template_Id__c = notificationTemp.Id;
		insert notificationsSetting;

		List<IATA_ISO_Country__c> countries = TestDataGenerator.generateISOCountryState();

		List<Account> accs = TestDataGenerator.generateAccounts(1,true);

		List<Contact> conts = TestDataGenerator.generateContacts(accs[0].id, 1, true);

		Account_Statement__c accStatement = new Account_Statement__c();
		accStatement.Name = 'testStatement';
		accStatement.Key__c = 'testStatement';
		accStatement.Account__c = accs[0].id;
		accStatement.Period__c = 'Period';
		accStatement.Operation__c = 'Operation';
		accStatement.Remittance_Date__c = Date.today().addDays(1);
		insert accStatement;

		Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'Account Statements'); //ServiceName__c = 'Account Statements'
		insert portalApp;


		Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = conts[0].Id, Portal_Application__c = portalApp.Id, Right__c = 'Access Granted');
		insert appRight;
	}

}
