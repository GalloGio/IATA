@istest
public class RTSMonthlyDigestTest {

	@istest
	static void testMonthlyDigest() {
		insert new RTS_Senior_Manager__c(Name = 'Test', Email__c = 'test.2005@yopmail.com', User_Id__c = UserInfo.getUserId(), Active__c = true);
		
		Test.startTest();
			String jobId = System.schedule('testRTSMonthlyDigest', RTSMonthlyDigest.CRON_EXP, new RTSMonthlyDigest());
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(RTSMonthlyDigest.CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
	}

	@istest
	static void EmptytoAddressesUsersTest() {

		RTS_Senior_Manager__c rts = new RTS_Senior_Manager__c(
			Name = 'test',
			Email__c = 'test.test@test.com'
		);
		insert rts;

		Test.startTest();
			String jobId = System.schedule('testRTSMonthlyDigest', RTSMonthlyDigest.CRON_EXP, new RTSMonthlyDigest());
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(RTSMonthlyDigest.CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
	}

	@istest
	static void EmptyEmailsTest() {

		Test.startTest();
			String jobId = System.schedule('testRTSMonthlyDigest', RTSMonthlyDigest.CRON_EXP, new RTSMonthlyDigest());
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(RTSMonthlyDigest.CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
	}
}