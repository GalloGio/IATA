@isTest
private class AMS_2_MDM_ScheduleTest{

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';


  static String localRegion = '';
  static SET<String> setAIMSRegion = new SET<String>();
  static List<IATA_ISO_Country__c> lIsoCountry;
  static List<AMS_ChangeCodes__c> lBillableChangeCodes;
  static String sQuery;
  
  private static void test_config(String Region){

      List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
      IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Americas');
      IATA_ISO_Country__c isoc2 = new IATA_ISO_Country__c(Name = 'Test2', ISO_Code__c = 'LS', Region__c = 'Europe');
      IATA_ISO_Country__c isoc3 = new IATA_ISO_Country__c(Name = 'Test3', ISO_Code__c = 'PS', Region__c = 'China & North Asia');
      countrylist.add(isoc1);
      countrylist.add(isoc2);
      countrylist.add(isoc3);
      insert countrylist;

      

      List<Account> agencylist = new List<Account>();
      Account a1 = new Account(Name='Test1 Agency',IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, IATACode__c = '12345678');
      Account a2 = new Account(Name='Test2 Agency',IATA_ISO_Country__c = isoc2.id, Sent_to_external_system__c = true, IATACode__c = '12345678');
      Account a3 = new Account(Name='Test3 Agency',IATA_ISO_Country__c = isoc3.id, Sent_to_external_system__c = true, IATACode__c = '12345678');
      agencylist.add(a1);
      agencylist.add(a2);
      agencylist.add(a3);
      insert agencylist;


      AMS_SAP_Settings__c sapSett = new AMS_SAP_Settings__c(Sales_Order_Batch_Size__c = 500, Batch_Size__c = '3',
                                                            REGION1_CRON_EXP__c = '0 0 0 15 3 ? 2022',
                                                           	REGION2_CRON_EXP__c = '0 0 0 15 3 ? 2022',
                                                            REGION3_CRON_EXP__c = '0 0 0 15 3 ? 2022',
                                                            REGION4_CRON_EXP__c = '0 0 0 15 3 ? 2022',
                                                            REGION5_CRON_EXP__c = '0 0 0 15 3 ? 2022',
                                                            Web_Service_endpoint__c = 'https://pixid.iata.org/XISOAPAdapter/MessageServlet');
      insert sapSett;

      AMS_ChangeCodes__c cc = new AMS_ChangeCodes__c(Name = 'test', Change_Code__c = 'TST', Billable__c = true, Integration_RecId__c='C');
      insert cc;

      List<Agency_Applied_Change_code__c> aacclist = new List<Agency_Applied_Change_code__c>();
      Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = a1.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
      Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Account__c = a2.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
      Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Account__c = a3.Id, Change_Code__c = 'TST',  Sent_to_external_system__c = false);
      aacclist.add(aacc1);
      aacclist.add(aacc2);
      aacclist.add(aacc3);
      insert aacclist;


      setAIMSRegion = new SET<String>();

      if(localRegion.equalsIgnoreCase('MIA')){
          setAIMSRegion.add('Americas');
      }else if(localRegion.equalsIgnoreCase('MAD')){
          setAIMSRegion.add('Europe');
      }else if(localRegion.equalsIgnoreCase('AMM')){
          setAIMSRegion.add('Africa & Middle East');
      }else if(localRegion.equalsIgnoreCase('SIN')){
          setAIMSRegion.add('Asia & Pacific');
      }else if(localRegion.equalsIgnoreCase('BJS')){
          setAIMSRegion.add('China & North Asia');
      } 

      lIsoCountry = [SELECT ID FROM IATA_ISO_Country__c WHERE Region__c in :setAIMSRegion];
      lBillableChangeCodes = [SELECT Change_Code__c FROM AMS_ChangeCodes__c where Billable__c = true];

      String[] tmp1 = New String[]{};
      String[] tmp1Country = New String[]{};
      String changeCodeString;
      String countryString;

      for(AMS_ChangeCodes__c c : lBillableChangeCodes){
        tmp1.add(c.Change_Code__c);
      }

      changeCodeString = string.join(tmp1,'\',\'');
      changeCodeString = '\'' + changeCodeString + '\'';


      //for(AggregateResult isoCountry : lIsoCountry){
      for(IATA_ISO_Country__c isoCountry : lIsoCountry){
        tmp1Country.add(isoCountry.id);
      } 

      countryString = string.join(tmp1Country,'\',\'');
      countryString = '\'' + countryString + '\'';

      sQuery = 'SELECT Change_Code__c, Account__c, Account__r.IATACode__c, Account__r.Location_Class__c, Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c ' +
                    'FROM Agency_Applied_Change_code__c ' +
                        'where Change_Code__c <> null ' +
                        'and Account__r.IATACode__c <> null ' +
                        'and Sent_to_external_system__c = false ' +
                        'and Account__r.Sent_to_External_System__c = true ' +
                        'and Change_Code__c in (' + changeCodeString + ') ' +
                        'and Account__r.IATA_ISO_Country__c in (' + countryString + ') ' +
                        'limit 8000' ; 


      
  }



   static testmethod void test() {
    
      

      Integer initialCount = 0; 
      
      Integer i1 = [SELECT COUNT() FROM Agency_Applied_Change_code__c 
                        where Change_Code__c <> null 
                        and Account__r.IATACode__c <> null 
                        and Sent_to_external_system__c = false 
                        and Account__r.Sent_to_External_System__c = true 
                        and Change_Code__c = 'TST'
                        and Account__r.IATA_ISO_Country__r.name = 'Test1' ];
      
      initialCount = i1;

      test_config('AIMS1');

      Test.startTest();

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
      Integer i2 = [SELECT COUNT() FROM Agency_Applied_Change_code__c 
                        where Change_Code__c <> null 
                        and Account__r.IATACode__c <> null 
                        and Sent_to_external_system__c = false 
                        and Account__r.Sent_to_External_System__c = true 
                        and Change_Code__c = 'TST'
                        and Account__r.IATA_ISO_Country__r.name = 'Test1' ];
   	  testCount = i2;
      System.assertEquals(testCount,1); 
      Test.stopTest();

     

   }
    
    
    static testmethod void test_start_stop() {
        test_config('AIMS1');
        
        integer i1 = [SELECT Count() FROM CronTrigger where CronJobDetail.Name = 'AMS 2 MDM Sales Orders TEST']; 
        
        
        AMS_2_MDM_Schedule.start();
           
        integer i2 = [SELECT Count() FROM CronTrigger where CronJobDetail.Name = 'AMS 2 MDM Sales Orders TEST']; 
        System.assertEquals(i2,1);
        
        AMS_2_MDM_Schedule.stop();
        
        integer i3 = [SELECT Count() FROM CronTrigger where CronJobDetail.Name = 'AMS 2 MDM Sales Orders TEST']; 
        System.assertEquals(i3,0);
        
    }
    
    static testmethod void test_start_stop_region() {
        
        test_config('AIMS1');
        
        integer i1 = [SELECT Count() FROM CronTrigger where CronJobDetail.Name like 'AMS 2 MDM Sales Orders TEST%']; 
        
        AMS_2_MDM_Schedule.start_region('MIA');
        AMS_2_MDM_Schedule.start_region('MAD');
        AMS_2_MDM_Schedule.start_region('AMM');
        AMS_2_MDM_Schedule.start_region('SIN');
        AMS_2_MDM_Schedule.start_region('BJS');
           
        integer i2 = [SELECT Count() FROM CronTrigger where CronJobDetail.Name like 'AMS 2 MDM Sales Orders TEST%']; 
        System.assertEquals(i2,5);
        
        AMS_2_MDM_Schedule.stop();
        AMS_2_MDM_Schedule.stop_region('MIA');
        AMS_2_MDM_Schedule.stop_region('MAD');
        AMS_2_MDM_Schedule.stop_region('AMM');
        AMS_2_MDM_Schedule.stop_region('SIN');
        AMS_2_MDM_Schedule.stop_region('BJS');
        
        integer i3 = [SELECT Count() FROM CronTrigger where CronJobDetail.Name like 'AMS 2 MDM Sales Orders TEST%']; 
        System.assertEquals(i3,0);
        
    }
    
}