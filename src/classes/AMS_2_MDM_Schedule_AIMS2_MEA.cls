global class AMS_2_MDM_Schedule_AIMS2_MEA implements Schedulable {

    global static void start(){
        // Cron EXP for hourly schedule
        String CRON_EXP = '0 0 * * * ?';
        AMS_2_MDM_Schedule sch = new AMS_2_MDM_Schedule();
        system.schedule('AMS 2 MDM Hourly', CRON_EXP, sch);
    }

    global static void stop(){
        List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = 'AMS 2 MDM Hourly' limit 1]; 
        
        if(SCHEDULE_ID.size() > 0){
            System.abortJob(SCHEDULE_ID[0].Id);
        }
    }

    global void execute(SchedulableContext sc) {
    
        //Batch Call by Country and Agency RecordType (Passenger and Cargo) 

        //doens't work because of governor limits!!!
        //List<IATA_ISO_Country__c> lIsoCountry = [SELECT id,Name,ISO_Code__c FROM IATA_ISO_Country__c order by Name];

        //query to get the countries of the agencies to be updates
        //only brings countries that are marked to be integrated with MDM
        //it's limited to 50 because of governor limits (limit of 100 batch jobs).
        List<AggregateResult> lIsoCountry = [SELECT country__c FROM AMS_Agency__c 
                where id in (SELECT Agency__c 
                                FROM AMS_Agency_Updates__c 
                                where Update_Type__c = 'Update' 
                                AND Agency__c != null) 
                                AND country__r.Region__c in ('Africa & Middle East')
                          group by country__c limit 50];

    
        for(AggregateResult isoCountry : lIsoCountry){
       
            String sQueryPassenger = 'SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c ' +
                    'FROM AMS_Agency_Updates__c ' +
                        'where Update_Type__c = \'Update\' AND Agency__c != null ' +
                    'and Agency__r.Country__c = \''+ isoCountry.get('country__c') + '\' ' +
                    'and Agency__r.RecordType.name in (\'PASSENGER\') ' +
                    'and Agency__r.Agency_Status__c not in (\'New application pending\') ' +
                    'limit 8000' ; 

            String sQueryCargo = 'SELECT Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c ' +
                    'FROM AMS_Agency_Updates__c ' +
                        'where Update_Type__c = \'Update\' AND Agency__c != null ' +
                    'and Agency__r.Country__c = \''+ isoCountry.get('country__c') + '\' ' +
                    'and Agency__r.RecordType.name in (\'CARGO\') ' +
                    'and Agency__r.Agency_Status__c not in (\'New application pending\') ' +
                    'limit 8000' ; 

        
            System.debug('sQueryPassenger: ' + sQueryPassenger);
            System.debug('sQueryCargo: ' + sQueryCargo);
            
            AMS_2_MDM_Batch bPassenger = new AMS_2_MDM_Batch(sQueryPassenger); 
            database.executebatch(bPassenger,2000);  //Parameters of ExecuteBatch(context,BatchSize)

            AMS_2_MDM_Batch bCargo = new AMS_2_MDM_Batch(sQueryCargo); 
            database.executebatch(bCargo,2000);  //Parameters of ExecuteBatch(context,BatchSize)
        } 
    }
}