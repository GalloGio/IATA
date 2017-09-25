global class ANG_ActivateDeactivateRiskEventsBatch implements Database.Batchable<sObject>, Schedulable{
    private String query;
    
    public ANG_ActivateDeactivateRiskEventsBatch(List<string> regionList){
        query='select id,ANG_Issued_Date__c,ANG_Expiration_Date__c,ANG_Event_Status__c,ANG_Expired__c from ANG_Agency_Risk_Event__c where ANG_AccountId__r.Region_formula__c  IN '+regionList+' AND ((ANG_Issued_Date__c <= TODAY AND ANG_Expiration_Date__c> TODAY AND ANG_Event_Status__c =\'' + ANG_Risk_Helper.STATUS_INACTIVE+'\') OR (ANG_Expiration_Date__c<=TODAY AND ANG_Event_Status__c=\'' + ANG_Risk_Helper.STATUS_ACTIVE+'\'))';
    }

   

    public static void scheduleEasternRegion(Time runnigTime){
         //   "China & North Asia" or "Asia & Pacific" 
        list<string> regionList=new list<string>{'\'China & North Asia\'','\'Asia & Pacific\''};
      
        if(runnigTime == null){
            runnigTime=System.now().time().addMinutes(5);
        }

        DateTime runningDateTime = DateTime.newInstanceGMT(system.today(), runnigTime).addHours(-8); //creates date on GMT +timezone adjustmnent
        scheduleRegion(regionList,null,runningDateTime.time());
    }



    public static void scheduleWesternRegion(Time runnigTime){
    //   "Africa & Middle East" or "Europeor Americas" 
        list<string> regionList=new list<string>{'\'Africa & Middle East\'','\'Europe\'','\'Americas\''};
       
        if(runnigTime == null){
            runnigTime=System.now().time().addMinutes(5);
        }

        DateTime runningDateTime = DateTime.newInstanceGMT(system.today(), runnigTime).addHours(-1); //creates date on GMT +timezone adjustmnent
        scheduleRegion(regionList,null,runningDateTime.time());
    }


    private static void scheduleRegion(list<string> regionList,Date runningDate,Time runningTime){
        ANG_ActivateDeactivateRiskEventsBatch bat= new ANG_ActivateDeactivateRiskEventsBatch(regionList);
        string format ='ss mm HH dd MM ? yyyy';
        if(runningDate == null){
            format='ss mm HH * * ? *';
            runningDate=system.today();
        }
        string sch=Datetime.newInstance(runningDate,runningTime).format(format);
        String jobID = system.schedule('Batch ANG_ActivateDeactivateRiskEventsBatch Job '+system.now().format('dd/MM/yyyy hh:MM:ss'), sch, bat);
    }

    public void execute(SchedulableContext context){
        Database.executeBatch(this); 
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(query) ;
    }
     
    public  void  execute(Database.BatchableContext context, List<ANG_Agency_Risk_Event__c> scope){
        for(ANG_Agency_Risk_Event__c are :scope ){
            if(are.ANG_Issued_Date__c <=system.today() && are.ANG_Expiration_Date__c>system.today()&& are.ANG_Event_Status__c.equalsIgnoreCase(ANG_Risk_Helper.STATUS_INACTIVE)){
               are.ANG_Event_Status__c=ANG_Risk_Helper.STATUS_ACTIVE;
            }
            if(are.ANG_Expiration_Date__c<=system.today() && are.ANG_Event_Status__c==ANG_Risk_Helper.STATUS_ACTIVE ){
               are.ANG_Expired__c=true;    
               are.ANG_Event_Status__c=ANG_Risk_Helper.STATUS_INACTIVE;
            }
        }
        update scope;
    }

    public void finish(Database.BatchableContext context){
    }
}