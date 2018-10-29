global class ANG_ActivateDeactivateRiskEventsBatch implements Database.Batchable<sObject>, Schedulable{
    
    private final String query = 'SELECT Id, ANG_Issued_Date__c, ANG_Expiration_Date__c, ANG_Event_Status__c, ANG_Expired__c, ANG_Limit_Cash_Conditions__c, ANG_Cash_Conditions_Activation_FF__c FROM ANG_Agency_Risk_Event__c WHERE ANG_AccountId__r.Region_formula__c  IN :regionList AND ((ANG_Issued_Date__c <= TODAY AND ANG_Expiration_Date__c > TODAY AND ANG_Event_Status__c = :inactiveStatus) OR (ANG_Event_Status__c = :activeStatus AND (ANG_Expiration_Date__c <= TODAY OR (ANG_Cash_Conditions_Activation_FF__c <= TODAY AND ANG_Limit_Cash_Conditions__c = false))))';
    private final String inactiveStatus = ANG_Risk_Helper.STATUS_INACTIVE;
    private final String activeStatus = ANG_Risk_Helper.STATUS_ACTIVE;

    private List<String> regionList;
    
    public ANG_ActivateDeactivateRiskEventsBatch(List<String> regionList){
        this.regionList = regionList;
    }

   

    public static void scheduleEasternRegion(Time runnigTime){
         //   "China & North Asia" or "Asia & Pacific" 
        List<String> regionList = new List<String>{'China & North Asia','Asia & Pacific'};
      
        if(runnigTime == null) runnigTime = System.now().time().addMinutes(5);

        DateTime runningDateTime = DateTime.newInstanceGMT(System.today(), runnigTime).addHours(-8); //creates date on GMT +timezone adjustmnent
        scheduleRegion(regionList,null,runningDateTime.time());
    }



    public static void scheduleWesternRegion(Time runnigTime){
        //   "Africa & Middle East" or "Europe" or "Americas" 
        List<String> regionList = new List<String>{'Africa & Middle East','Europe','Americas'};
       
        if(runnigTime == null) runnigTime = System.now().time().addMinutes(5);

        DateTime runningDateTime = DateTime.newInstanceGMT(System.today(), runnigTime).addHours(-1); //creates date on GMT +timezone adjustmnent
        scheduleRegion(regionList,null,runningDateTime.time());
    }


    private static void scheduleRegion(List<String> regionList,Date runningDate,Time runningTime){
        ANG_ActivateDeactivateRiskEventsBatch bat = new ANG_ActivateDeactivateRiskEventsBatch(regionList);
        String format ='ss mm HH dd MM ? yyyy';
        if(runningDate == null){
            format = 'ss mm HH * * ? *';
            runningDate = System.today();
        }
        String sch = Datetime.newInstance(runningDate,runningTime).format(format);
        String jobID = System.schedule('Batch ANG_ActivateDeactivateRiskEventsBatch Job '+System.now().format('dd/MM/yyyy hh:MM:ss'), sch, bat);
    }

    public void execute(SchedulableContext context){
        Database.executeBatch(this); 
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        ANG_AccountTriggerHandler.isExpiration = true;
        return Database.getQueryLocator(query);
    }
     
    public void execute(Database.BatchableContext context, List<ANG_Agency_Risk_Event__c> scope){
        for(ANG_Agency_Risk_Event__c are : scope){
            if(are.ANG_Issued_Date__c <= System.today() && are.ANG_Expiration_Date__c > System.today() && are.ANG_Event_Status__c.equalsIgnoreCase(ANG_Risk_Helper.STATUS_INACTIVE)){
               are.ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE;
            }
            if(are.ANG_Expiration_Date__c <= System.today() && are.ANG_Event_Status__c == ANG_Risk_Helper.STATUS_ACTIVE ){
               are.ANG_Expired__c = true;    
               are.ANG_Event_Status__c = ANG_Risk_Helper.STATUS_INACTIVE;
            }
            if(are.ANG_Cash_Conditions_Activation_FF__c <= System.today() && are.ANG_Event_Status__c == ANG_Risk_Helper.STATUS_ACTIVE && !are.ANG_Limit_Cash_Conditions__c){
               are.ANG_Limit_Cash_Conditions__c = true;
            }
        }
        
        ANG_AccountTriggerHandler.isExpiration = true;
        try{
            update scope;
        }catch(Exception e){
            //ServiceNow_Helper.sendRequestToSNOW('Salesforce', 'ANG_ActivateDeactivateRiskEventsBatch', 'ANG_ActivateDeactivateRiskEventsBatch', 'SFDC', 'SFDC',  e.getMessage(), 'false', 'System', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
            ServiceNow_Helper.sendRequestToSNOWSFDC('SNOW13',e);
        }
    }

    public void finish(Database.BatchableContext context){
    }
}