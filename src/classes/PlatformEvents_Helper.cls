public class PlatformEvents_Helper {
    
    public static void publishEvents(Map<Id,sObject> ObjectMap, string PE_Name, string ObjSource, boolean bIsInsert, boolean bIsUpdate, boolean bIsDelete, boolean bIsUndelete){
        string sEventType = '';
        if(bIsInsert) sEventType = 'Create';
        if(bIsUpdate) sEventType = 'Update';
        if(bIsDelete) sEventType = 'Delete';
        if(bIsUndelete) sEventType = 'Undelete';
        
        if(sEventType=='') return;
        
        list<ISSP_Web_Service_Log__c> lsLogs = new list<ISSP_Web_Service_Log__c>();
        
        try{
            map<string, string> MapMapping = getMappingMap(PE_Name);
            
            if(MapMapping==null) return;
            
            List<RecordType> rtList = RecordTypeSingleton.getInstance().getRecordTypesBySObject(ObjSource);
            
            List<SObject> lstSObjs = new list<SObject>();
            
            for(Id ObjId : ObjectMap.keySet()){
                SObject sObj = Schema.getGlobalDescribe().get(PE_Name).newSObject();
    
                for(String FieldSource : MapMapping.keyset()){
                    if(FieldSource=='Recordtype')
                        if(!rtList.isEmpty()) 
                            sObj.put(MapMapping.get(FieldSource) , RecordTypeSingleton.getInstance().getRecordTypeById(ObjSource, (Id)(ObjectMap.get(ObjId).get('RecordtypeId'))).Name);
                        else
                            sObj.put(MapMapping.get(FieldSource), null);
                        
                    else if(FieldSource=='EventType')
                        sObj.put(MapMapping.get(FieldSource), sEventType);
                    
                    else if(FieldSource=='Id')
                        sObj.put(MapMapping.get(FieldSource), ObjId);
                }
                
                lstSObjs.add(sObj);
            }
        
            
            if (!Test.isRunningTest()) {
                for (Database.SaveResult sr : EventBus.publish(lstSObjs)) {
                    if (!sr.isSuccess()){
                        for(Database.Error err : sr.getErrors()) {
                            lsLogs.add(CreateLog('Platform Events for ' + ObjSource + '. Event Type: ' + sEventType
                                     , err.getStatusCode() + ' - ' + err.getMessage()
                                     , PE_Name
                                     ,'PlatformEvents_Helper.publishEvents'
                                     ,'One of the following: ' + ObjectMap.keyset()));
                        }
                    }
                }
            }
            
        }catch(exception e){
            lsLogs.add(CreateLog('Platform Events for ' + ObjSource + '. Event Type: ' + sEventType
                                 , e.getMessage()
                                 , PE_Name
                                 ,'PlatformEvents_Helper.publishEvents'
                                 ,'One of the following: ' + ObjectMap.keyset()));
        }
        
        if(!lsLogs.isEmpty()) insert lsLogs;
    }
    
    private static map<string, string> getMappingMap(string sObj){
        if(sObj=='Account__e'){
            return new map<String,String>{
                'Id' => 'AccountId__c',
                'Recordtype' => 'RecordType__c',
                'EventType' => 'Type__c'
            };
        }
        
        if(sObj=='Contact__e' || sObj=='Product_Bin_Range__e' || sObj=='PartnerProduct__e' || sObj=='Product_Country_Config__e' ){
            return new map<String,String>{
                'Id' => 'RecordId__c',
                'Recordtype' => 'RecordType__c',
                'EventType' => 'EventType__c'
            };
        }
        
        return null;
    }
    
    @TestVisible
    private static ISSP_Web_Service_Log__c CreateLog(string theSystem, string ErrMess, string PE_Name, string theMethod, string theDesc){
        return new ISSP_Web_Service_Log__c(
                        System__c = theSystem,
                        Error_Message__c = ErrMess,
                        Web_Service__c = PE_Name,
                        Method__c = theMethod,
                        Input_Description__c = theDesc
                        );
    }
}
