@isTest
public class RecordUpdaterTest {
	
	public static testmethod void test1(){
		Test.startTest();
        List<Account> acctList = new List<Account>();
        Account acct1=new Account(Name = 'AccountTest1');
        Account acct2=new Account(Name = 'AccountTest2');
        Account acct3=new Account(Name = 'AccountTest3');
        acctList.add(acct1);
        acctList.add(acct2);
        acctList.add(acct3);
        insert acctList;

       // This test runs a scheduled job at midnight Sept. 3rd. 2022
        String CRON_EXP = '0 0 0 3 9 ? 2022';
       // Schedule the test job
       	String jobId = System.schedule('RecordUpdaterTest', CRON_EXP, new RecordUpdater(acctList));
      // Get the information from the CronTrigger API object 
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
       // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
      // Verify the job has not run 
     	 System.assertEquals(0, ct.TimesTriggered); 
      // Verify the next time the job will run 
      	System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));   

        Datetime nextSchedule = DateTime.newInstance(2022, 3, 16, 12, 6, 13);

        RecordUpdater updater = new RecordUpdater(acctList);
        updater.schedule(nextSchedule);

      	Test.stopTest();  

	}
    // cover the exception
    public static testmethod void test2(){
    Test.startTest();
        List<Account> acctList;

       // This test runs a scheduled job at midnight Sept. 3rd. 2022
        String CRON_EXP = '0 0 0 3 9 ? 2022';
       // Schedule the test job
        String jobId = System.schedule('RecordUpdaterTest', CRON_EXP, new RecordUpdater(acctList));
      // Get the information from the CronTrigger API object 
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
       // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
      // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered); 
      // Verify the next time the job will run 
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));   
        Test.stopTest();  

  }

	
}

