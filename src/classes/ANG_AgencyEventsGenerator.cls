public class ANG_AgencyEventsGenerator{
    private String cmType;
    private String accField;
    private list<sObject> newRecList;
    private map<id,sObject>oldRecMap;


    public ANG_AgencyEventsGenerator(list<sObject> nrL,map<id,sObject>orM,string cmt,string acf){
        cmType=cmt;
        accField=acf;       
        newRecList=nrL;
        oldRecMap=orM;
    }

    public void run(){
        run(false);
    }

    public void run(Boolean runDelayed){
        
        if(ANG_ConversionHelper.isMigrationTool && cmType !='ChangeCode' ) return; //in case of migrating account, prevents following code to be run
        list<ANG_CalloutMapping__c> calloutmappingList= new list<ANG_CalloutMapping__c>();
        for(ANG_CalloutMapping__c cm: ANG_CalloutMapping__c.getAll().values()){
            if (cm.Integration_System__c == 'SAP PI') {
                if (cm.Type__c == cmType && !cm.Event_type__c.equalsIgnoreCase('Update_Sent') && !cm.Event_type__c.equalsIgnoreCase('Invalid') && !cm.Event_type__c.equalsIgnoreCase('Deleted')) 
                    calloutmappingList.add(cm);
            } else if (cm.Type__c == cmType) calloutmappingList.add(cm);
        }

        set<string> insertedRecordsSet = new set<string>();
        list<AMS_Agency_Updates__c> agencyEventsList = new list<AMS_Agency_Updates__c>();   
        
        for(sObject obj: newRecList){
            for(ANG_CalloutMapping__c cm:calloutmappingList){
                if((cmType=='ChangeCode' && String.valueOf(obj.get('Change_Code__c')) == cm.Change_Code__c && (cm.Change_Code__c != 'CWD' || runDelayed)) || (oldRecMap!= null &&  String.valueOf(obj.get(cm.field__c)) != String.valueOf(oldRecMap.get(String.valueOf(obj.get('id'))).get(cm.field__c)))){
                    if(!insertedRecordsSet.contains(String.valueOf(obj.get(accField))+cm.Event_type__c)){
                        AMS_Agency_Updates__c auRec = new AMS_Agency_Updates__c(
                            Account__c = String.ValueOf(obj.get(accField)), 
                            Update_Type__c = cm.Event_type__c,
                            Integration_System__c= cm.Integration_System__c,
                            Action_Type__c=cm.Action__c,
                            Change_Code__c=cm.Change_Code__c,
                            Agency_Applied_Change_code__c=cmType=='ChangeCode'?String.ValueOf(obj.get('id')):null,
                            ConfigurationID__c=cm.id
                        );
                        insertedRecordsSet.add(String.valueOf(auRec.account__c)+auRec.Update_Type__c);
                        agencyEventsList.add(auRec);
                    }
                }
            }
        }
        if(agencyEventsList.size()>0)insert agencyEventsList;
    }

}