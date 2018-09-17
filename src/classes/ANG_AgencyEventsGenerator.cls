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
        
        Set<String> setAccntId = new Set<String>();
        Set<String> setAccntIdWithSAPUpdate = new Set<String>();
        
    	for(sObject obj: newRecList)	setAccntId.add(String.ValueOf(obj.get(accField)));
    	
    	for(AMS_Agency_Updates__c aau: [select Account__c, id from AMS_Agency_Updates__c where Integration_System__c = 'SAP PI' and Account__c in :setAccntId and Update_Type__c not in ('Update_Sent','Invalid','Deleted')]){
    		setAccntIdWithSAPUpdate.add(string.valueOf(aau.Account__c).left(15));
    	}
        
        List<ANG_CalloutMapping__c> calloutmappingList = new List<ANG_CalloutMapping__c>();

        for(ANG_CalloutMapping__c cm: ANG_CalloutMapping__c.getAll().values()){
            if(cm.Type__c== cmType)
                calloutmappingList.add(cm);
        }

        Set<string> insertedRecordsSet = new Set<string>();
        List<AMS_Agency_Updates__c> agencyEventsList = new List<AMS_Agency_Updates__c>();   
        
        for(sObject obj: newRecList){
            for(ANG_CalloutMapping__c cm:calloutmappingList){
                if((cmType=='ChangeCode' && String.valueOf(obj.get('Change_Code__c')) == cm.Change_Code__c && (cm.Change_Code__c != 'CWD' || runDelayed)) || (oldRecMap!= null &&  String.valueOf(obj.get(cm.field__c)) != String.valueOf(oldRecMap.get(String.valueOf(obj.get('id'))).get(cm.field__c)))){
                    if(!insertedRecordsSet.contains(String.valueOf(obj.get(accField))+cm.Event_type__c+cm.Integration_System__c)){
                        AMS_Agency_Updates__c auRec = new AMS_Agency_Updates__c(
                            Account__c = String.ValueOf(obj.get(accField)), 
                            Update_Type__c = cm.Event_type__c,
                            Integration_System__c= cm.Integration_System__c,
                            Action_Type__c=cm.Action__c,
                            Change_Code__c=cm.Change_Code__c,
                            Agency_Applied_Change_code__c=cmType=='ChangeCode'?String.ValueOf(obj.get('id')):null,
                            ConfigurationID__c=cm.id
                        );
                        
                        if(cm.Integration_System__c == 'Mulesoft' || (cm.Integration_System__c == 'SAP PI' && !setAccntIdWithSAPUpdate.contains( String.ValueOf(obj.get(accField)).left(15) ))){
	                        insertedRecordsSet.add(String.valueOf(auRec.account__c)+auRec.Update_Type__c+auRec.Integration_System__c);
    	                    agencyEventsList.add(auRec);
                        }
                    }
                }
            }
        }
        if(agencyEventsList.size()>0)insert agencyEventsList;
    }

}