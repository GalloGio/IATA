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

        if(Region.equalsIgnoreCase('AIMS1')){
            CRON_EXP = AMS_SAP_Settings__c.getOrgDefaults().AIMS1_CRON_EXP__c;
        }else if(Region.equalsIgnoreCase('AIMS2')){
            CRON_EXP = AMS_SAP_Settings__c.getOrgDefaults().AIMS2_CRON_EXP__c;
        }else if(Region.equalsIgnoreCase('AIMS3')){
            CRON_EXP = AMS_SAP_Settings__c.getOrgDefaults().AIMS3_CRON_EXP__c;
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

       


        if(localRegion.equalsIgnoreCase('AIMS1')){
            setAIMSRegion.add('Americas');
        }else if(localRegion.equalsIgnoreCase('AIMS2')){
            setAIMSRegion.add('Europe');
            setAIMSRegion.add('Africa & Middle East');
        }else if(localRegion.equalsIgnoreCase('AIMS3')){
            setAIMSRegion.add('China & North Asia');
            setAIMSRegion.add('Asia & Pacific');
        } 

        //Batch Call by Country and Agency RecordType (Passenger and Cargo) 

        //doens't work because of governor limits!!!
        //List<IATA_ISO_Country__c> lIsoCountry = [SELECT id,Name,ISO_Code__c FROM IATA_ISO_Country__c order by Name];

        //query to get the countries of the agencies to be updates
        //only brings countries that are marked to be integrated with MDM
        //it's limited to 50 because of governor limits (limit of 100 batch jobs).

        //List<AggregateResult> lIsoCountry = [SELECT country__c FROM AMS_Agency__c 
        //        where id in (SELECT Agency__c 
        //                        FROM AMS_Agency_Updates__c 
        //                        where Update_Type__c = 'Update' 
        //                        AND Agency__c != null) 
        //        AND country__r.MDM_Integration__c = true
        //        group by country__c limit 50];

        List<IATA_ISO_Country__c> lIsoCountry = [SELECT ID FROM IATA_ISO_Country__c WHERE Region__c in :setAIMSRegion];

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

            //String sQueryPassenger = 'SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c ' +
            //        'FROM AMS_Agency_Updates__c ' +
            //            'where Update_Type__c = \'Update\' AND Agency__c != null ' +
            //        'and Agency__r.Country__c = \''+ isoCountry.get('country__c') + '\' ' +
            //        'and Agency__r.RecordType.name in (\'PASSENGER\') ' +
            //        'and Agency__r.Agency_Status__c not in (\'New application pending\') ' +
            //        'limit 8000' ; 

            //String sQueryCargo = 'SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c ' +
            //        'FROM AMS_Agency_Updates__c ' +
            //            'where Update_Type__c = \'Update\' AND Agency__c != null ' +
            //        'and Agency__r.Country__c = \''+ isoCountry.get('country__c') + '\' ' +
            //        'and Agency__r.RecordType.name in (\'CARGO\') ' +
            //        'and Agency__r.Agency_Status__c not in (\'New application pending\') ' +
            //        'limit 8000' ; 

            //String sQueryPassenger = 'SELECT Account__c,Account__r.location_class__c,Active__c,Change_Code__c,Sent_to_external_system__c ' +
            //        'FROM Agency_Applied_Change_code__c ' +
            //            'where Active__c = true ' +
            //            'and Change_Code__c <> null' +
            //            'and Sent_to_external_system__c = false ' +
            //            'and Change_Code__c in (' + changeCodeString + ')' +
            //        'and Agency__r.Country__c in (' + countryString + ')' +
            //        'limit 8000' ;

            //Ignore the "Active" field, since it only inform on the last change code used!
            String sQueryPassenger = 'SELECT Change_Code__c, Account__c, Account__r.IATACode__c, Account__r.Location_Class__c, Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c ' +
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

            
        
        

       // //Batch Call by Settlements - BSP and DPC used
       // String sSettlements = '';
       
       // List<AggregateResult> lSettlement = [SELECT Operation__r.Settlement__c
       //                         FROM AMS_Agency_Operations__c
       //                         where Agency__c in (SELECT Agency__c 
       //                                             FROM AMS_Agency_Updates__c 
       //                                             where Update_Type__c = 'Update' 
       //                                             AND Agency__c != null) 
       //                         group by Operation__r.Settlement__c];
    
       
       // for(AggregateResult sett : lSettlement){
      
       //     //for agencies without settlement
       //     if(sSettlements.equalsIgnoreCase('')){
       //         sSettlements = '\'' + (String)sett.get('Settlement__c') + '\'';
       //     }else{
       //         sSettlements = sSettlements + ',\'' + (String)sett.get('Settlement__c') + '\'';
       //     } 
            
       //     String sQuery = 'SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c ' +
       //             'FROM AMS_Agency_Updates__c ' +
       //                 'where Update_Type__c = \'Update\' AND Agency__c != null ' +
       //             'and Agency__c in (select Agency__c from AMS_Agency_Operations__c where Operation__r.Settlement__c = \''+ sett.get('Settlement__c') + '\') ' +
       //             'limit 8000' ; 
        
       //     System.debug('teste1: ' + sQuery);
       //     AMS_2_MDM_Batch b = new AMS_2_MDM_Batch(sQuery); 
            
       //     //Parameters of ExecuteBatch(context,BatchSize)
       //     database.executebatch(b,2000);
       // } 
       
       ////Get agencies without settlement
       //String sQuery = 'SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c ' +
       //             'FROM AMS_Agency_Updates__c ' +
       //                 'where Update_Type__c = \'Update\' AND Agency__c != null ' +
       //             'and Agency__c not in (select Agency__c from AMS_Agency_Operations__c where Operation__r.Settlement__c in ('+ sSettlements + ')) ' +
       //             'limit 8000' ; 
       //System.debug('teste2: ' + sQuery); 
       //AMS_2_MDM_Batch b = new AMS_2_MDM_Batch(sQuery); 
            
       ////Parameters of ExecuteBatch(context,BatchSize)
       //database.executebatch(b,2000);
        
    }
}