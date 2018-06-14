global class SchdlEBCFixIdCardAgencyLink implements Database.Batchable<sObject>, Schedulable {
    // Batch
    public String query = 'Select Id, Agency_IATA_Code__c From ID_Card__c Where GDP_Products_Account_View__c=null and Agency_IATA_Code__c!=null';
  
    global Database.QueryLocator start(Database.BatchableContext BC){
        Boolean IsTest=Test.isRunningTest();
        if (isTest) query = 'Select Id, Agency_IATA_Code__c From ID_Card__c Where Agency_IATA_Code__c=\'11111092\' Limit 1';
        return Database.getQueryLocator(query);
    }
    public static void prepare() {
     List<GDP_Products_Account_View__c> gdplist = new List<GDP_Products_Account_View__c>();
        gdplist= [select id, IATA_Code__c FROM GDP_Products_Account_View__c Where IATA_Code__c='111110920' Limit 1];
        for (GDP_Products_Account_View__c gdp: gdplist) {
            gdp.IATA_Code__c='11111092';
     
        }
        update gdplist;
    }
    global void execute(Database.BatchableContext BC, List<ID_Card__c> scope){
        Boolean IsTest=Test.isRunningTest();
        for(ID_Card__c ic : scope) {
            String iata_code=ic.Agency_IATA_Code__c;
            if (String.isBlank(iata_code)) continue;
            if (iata_code.length()<8) continue;
            iata_code = iata_code.substring(0, (isTest ? 7:7));
            //System.Debug('iata_code >>>'+iata_code);
            ic.GDP_Products_Account_View__r = new GDP_Products_Account_View__c(IATA_Code__c = iata_code);
        }
        list<Database.SaveResult> results = Database.update(scope,false);
        String errorMessage = '';
        for ( Integer i = 0; i < results.size(); i++ ) {
            if ( !results.get(i).isSuccess() ) {
                if ( errorMessage.equals('') ) {
                    errorMessage = 'Following Id CARD have failed during the update:\n\n';
                }
                errorMessage += '\n';
                errorMessage += scope.get(i).Id;
              
            }
        }
        System.Debug('errorMessage >>>'+errorMessage);
        //update scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    // Schedule
    
    global void execute(SchedulableContext SC)  {
        Boolean IsTest=Test.isRunningTest();
      
        //Database.executeBatch(this,200);
        Integer numberofBatch=200;
        if (IsTest)  {numberofBatch=1; cancel();}
        SchdlEBCFixIdCardAgencyLink n = new SchdlEBCFixIdCardAgencyLink();
        Database.executeBatch(n,numberofBatch);
        
    }
    global static void cancel() {
        cancel('SchdlEBCFixIdCardAgencyLink' + (Test.isRunningTest() ? 'Test' : ''));
    }
    global static void cancel(String name) {
        List<CronTrigger> ct = new List<CronTrigger>();
        ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name = :name LIMIT 1];
        if (ct.size()>0) System.abortJob(ct[0].Id);
    }
    
    global static String Schedule(string sch) {
        if (String.isBlank(sch)) sch = '0 0 * * * ?';
        String schdlName='SchdlEBCFixIdCardAgencyLink' + (Test.isRunningTest() ? 'Test' : '');
        SchdlEBCFixIdCardAgencyLink a = new SchdlEBCFixIdCardAgencyLink();
        return System.schedule(schdlName, sch, a);
    }
    }