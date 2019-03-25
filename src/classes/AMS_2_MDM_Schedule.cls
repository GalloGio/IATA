global class AMS_2_MDM_Schedule implements Schedulable {

    String localRegion = '';
    SET<String> setAIMSRegion = new SET<String>();

    global static void start(){ 
        // Cron EXP for hourly schedule
        String CRON_EXP = '0 0 * * * ?';
        AMS_2_MDM_Schedule sch = new AMS_2_MDM_Schedule();
        if(!Test.isRunningTest()) {
            system.schedule('AMS 2 MDM Sales Orders', CRON_EXP, sch);
        }else{
            system.schedule('AMS 2 MDM Sales Orders TEST', CRON_EXP, sch);
        }
    }

    global static void start_region(String Region){
        // Cron EXP for hourly schedule
        String CRON_EXP = '';

        if(Region.equalsIgnoreCase('MIA')){
            CRON_EXP = AMS_SAP_Settings__c.getOrgDefaults().REGION1_CRON_EXP__c;
        }else if(Region.equalsIgnoreCase('MAD')){
            CRON_EXP = AMS_SAP_Settings__c.getOrgDefaults().REGION2_CRON_EXP__c;
        }else if(Region.equalsIgnoreCase('AMM')){
            CRON_EXP = AMS_SAP_Settings__c.getOrgDefaults().REGION3_CRON_EXP__c;
        }else if(Region.equalsIgnoreCase('SIN')){
            CRON_EXP = AMS_SAP_Settings__c.getOrgDefaults().REGION4_CRON_EXP__c;
        }else if(Region.equalsIgnoreCase('BJS')){
            CRON_EXP = AMS_SAP_Settings__c.getOrgDefaults().REGION5_CRON_EXP__c;
        } 

        AMS_2_MDM_Schedule sch = new AMS_2_MDM_Schedule(Region);
        if(!Test.isRunningTest()) {
            system.schedule('AMS 2 MDM Sales Orders - ' + Region, CRON_EXP, sch);
        }else{
            system.schedule('AMS 2 MDM Sales Orders TEST - ' + Region, CRON_EXP, sch);
        }
    }

    public AMS_2_MDM_Schedule(){
      localRegion = '';
    }

    public AMS_2_MDM_Schedule(String Region){
      localRegion = Region;
    }

    global static void stop(){
        String sJobName = '';
        if(!Test.isRunningTest()) {
            sJobName = 'AMS 2 MDM Sales Orders';
        }else{
            sJobName = 'AMS 2 MDM Sales Orders TEST';
        }
        
        List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :sJobName limit 1]; 
        
        if(SCHEDULE_ID.size() > 0){
            System.abortJob(SCHEDULE_ID[0].Id);
        }
    }

    global static void stop_region(String Region){
        String sJobName = '';
        
        if(!Test.isRunningTest()) {
            sJobName = 'AMS 2 MDM Sales Orders - ' + Region;
        }else{
            sJobName = 'AMS 2 MDM Sales Orders TEST - ' + Region;
        }
            
        List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :sJobName limit 1]; 
        
        if(SCHEDULE_ID.size() > 0){
            System.abortJob(SCHEDULE_ID[0].Id);
        }
    }

    global void execute(SchedulableContext sc) {
    
        CronTrigger ct = [SELECT CronJobDetail.name FROM CronTrigger WHERE Id = :sc.getTriggerId()];

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

        List<IATA_ISO_Country__c> lIsoCountry = IATAIsoCountryDAO.getIsoCountriesByRegion(setAIMSRegion);

        System.debug('lIsoCountry: ' + lIsoCountry);
          
    
        //Initiate Log
        Technical_Logs__c tlog = new Technical_Logs__c();
        tlog.Status__c = 'Region: ' + localRegion;
        tlog.Operation__c = 'Schedule Job - '+ ct.CronJobDetail.name;
        DateTime dtStart = system.now();
        tlog.start_date__c = dtStart;
        String sLog = '';
        String sLogRecord = 'lIsoCountry: ' + lIsoCountry;
        insert tlog;

        List<AMS_ChangeCodes__c> lBillableChangeCodes = [SELECT Change_Code__c FROM AMS_ChangeCodes__c where Billable__c = true];

        String[] tmp1 = New String[]{};
        String[] tmp1Country = New String[]{};
        List<String> lstBillable_Countries_To_Exclude = new List<String>(); 
        List<String> lstBillable_Location_Class_To_Exclude = new List<String>();
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

            //Ignore the "Active" field, since it only inform on the last change code used!
            String sQueryPassenger = 'SELECT Change_Code__c, Account__c, Account__r.IATACode__c, Account__r.Location_Class__c, ' +
                        'Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c, ' +
                        'Account__r.IATA_ISO_Country__r.Iso_code__c, OSCAR__c, OSCAR__r.Oscar_Communication_Case_Id__c, ' +
                        'Account__r.ANG_Accreditation_Model__c, Account__r.ANG_IsNewGenAgency__c ' +
                        'Account__r.Special_remarks__c ' + //WMO-456
                        'FROM Agency_Applied_Change_code__c ' +
                        'where Change_Code__c <> null ' +
                        'and Account__r.IATACode__c <> null ' +
                        'and Sent_to_external_system__c = false ' +
                        'and Account__r.Sent_to_External_System__c = true ' +
                        'and Change_Code__c in (' + changeCodeString + ') ' +
                        'and Account__r.IATA_ISO_Country__c in (' + countryString + ') ' +
                        'limit 8000' ; 


            System.debug('sQueryPassenger: ' + sQueryPassenger);
            

            AMS_2_MDM_Batch bPassenger = new AMS_2_MDM_Batch(sQueryPassenger); 
            database.executebatch(bPassenger,(Integer)AMS_SAP_Settings__c.getOrgDefaults().Sales_Order_Batch_Size__c);  //Parameters of ExecuteBatch(context,BatchSize)

       
    }
}
