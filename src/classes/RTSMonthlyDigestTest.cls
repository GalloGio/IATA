@istest
public class RTSMonthlyDigestTest {
	
	 static testmethod void testMonthlyDigest() {
        insert new RTS_Senior_Manager__c(Name = 'Test', Email__c = 'test.2005@yopmail.com');
   	    Test.startTest();
            String jobId = System.schedule('testRTSMonthlyDigest',
                RTSMonthlyDigest.CRON_EXP, 
                new RTSMonthlyDigest());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                NextFireTime
                FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(RTSMonthlyDigest.CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
   }
}