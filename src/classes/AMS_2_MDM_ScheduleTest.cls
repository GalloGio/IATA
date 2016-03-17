@isTest
private class AMS_2_MDM_ScheduleTest{

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void test() {
    
       Integer initialCount = 0; 
      List<AMS_Agency_Updates__c> lInitialList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  initialCount = lInitialList.size();
   
      Test.startTest();

       List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

		a1.Name='Update Agency 1';
        a2.Name='Update Agency 2';
        a3.Name='Update Agency 3';
        a4.Name='Update Agency 4';
        update agencylist;    
       
      // Schedule the test job
      String jobId = System.schedule('AMS_2_MDM_ScheduleTest',
                        CRON_EXP, 
                        new AMS_2_MDM_Schedule());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      //Merchandise__c[] ml = [SELECT Id FROM Merchandise__c 
      //                       WHERE Name = 'Scheduled Job Item'];
      //System.assertEquals(ml.size(),0);
      Integer testCount = 0; 
      List<AMS_Agency_Updates__c> lTestList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  testCount = lTestList.size();
      System.assertEquals(testCount,4); 
      Test.stopTest();

     

   }
    
   static testmethod void test_AIMS1() {
    
       Integer initialCount = 0; 
      List<AMS_Agency_Updates__c> lInitialList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  initialCount = lInitialList.size();
   
      Test.startTest();

       List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

		a1.Name='Update Agency 1';
        a2.Name='Update Agency 2';
        a3.Name='Update Agency 3';
        a4.Name='Update Agency 4';
        update agencylist;    
       
      // Schedule the test job
      String jobId = System.schedule('AMS_2_MDM_ScheduleTest_AIMS1',
                        CRON_EXP, 
                        new AMS_2_MDM_Schedule_AIMS1());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      //Merchandise__c[] ml = [SELECT Id FROM Merchandise__c 
      //                       WHERE Name = 'Scheduled Job Item'];
      //System.assertEquals(ml.size(),0);
      Integer testCount = 0; 
      List<AMS_Agency_Updates__c> lTestList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  testCount = lTestList.size();
      System.assertEquals(testCount,4); 
      Test.stopTest();

     

   } 
    
   static testmethod void test_AIMS2_EUR() {
    
       Integer initialCount = 0; 
      List<AMS_Agency_Updates__c> lInitialList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  initialCount = lInitialList.size();
   
      Test.startTest();

       List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

		a1.Name='Update Agency 1';
        a2.Name='Update Agency 2';
        a3.Name='Update Agency 3';
        a4.Name='Update Agency 4';
        update agencylist;    
       
      // Schedule the test job
      String jobId = System.schedule('AMS_2_MDM_ScheduleTest_AIMS2_EUR',
                        CRON_EXP, 
                        new AMS_2_MDM_Schedule_AIMS2_EUR());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      //Merchandise__c[] ml = [SELECT Id FROM Merchandise__c 
      //                       WHERE Name = 'Scheduled Job Item'];
      //System.assertEquals(ml.size(),0);
      Integer testCount = 0; 
      List<AMS_Agency_Updates__c> lTestList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  testCount = lTestList.size();
      System.assertEquals(testCount,4); 
      Test.stopTest();

     

   } 
    
   static testmethod void test_AIMS2_MEA() {
    
       Integer initialCount = 0; 
      List<AMS_Agency_Updates__c> lInitialList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  initialCount = lInitialList.size();
   
      Test.startTest();

       List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

		a1.Name='Update Agency 1';
        a2.Name='Update Agency 2';
        a3.Name='Update Agency 3';
        a4.Name='Update Agency 4';
        update agencylist;    
       
      // Schedule the test job
      String jobId = System.schedule('AMS_2_MDM_ScheduleTest_AIMS2_MEA',
                        CRON_EXP, 
                        new AMS_2_MDM_Schedule_AIMS2_MEA());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      //Merchandise__c[] ml = [SELECT Id FROM Merchandise__c 
      //                       WHERE Name = 'Scheduled Job Item'];
      //System.assertEquals(ml.size(),0);
      Integer testCount = 0; 
      List<AMS_Agency_Updates__c> lTestList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  testCount = lTestList.size();
      System.assertEquals(testCount,4); 
      Test.stopTest();

     

   } 
    
   static testmethod void test_AIMS3() {
    
       Integer initialCount = 0; 
      List<AMS_Agency_Updates__c> lInitialList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  initialCount = lInitialList.size();
   
      Test.startTest();

       List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;

		a1.Name='Update Agency 1';
        a2.Name='Update Agency 2';
        a3.Name='Update Agency 3';
        a4.Name='Update Agency 4';
        update agencylist;    
       
      // Schedule the test job
      String jobId = System.schedule('AMS_2_MDM_ScheduleTest_AIMS3',
                        CRON_EXP, 
                        new AMS_2_MDM_Schedule_AIMS3());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      //Merchandise__c[] ml = [SELECT Id FROM Merchandise__c 
      //                       WHERE Name = 'Scheduled Job Item'];
      //System.assertEquals(ml.size(),0);
      Integer testCount = 0; 
      List<AMS_Agency_Updates__c> lTestList= [SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c 
                    						FROM AMS_Agency_Updates__c 
                    						where Update_Type__c = 'Update' AND Agency__c != null];
   	  testCount = lTestList.size();
      System.assertEquals(testCount,4); 
      Test.stopTest();

     

   }  
}