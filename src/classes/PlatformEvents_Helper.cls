public class PlatformEvents_Helper implements Queueable {

    private static Map<String, Schema.SObjectType> schemaInfoMap = new Map<String, Schema.SObjectType>();
    private Map<Id,sObject> ObjectMap;
    private String PE_Name;
    private String ObjSource;
    private Boolean bIsInsert;
    private Boolean bIsUpdate;
    private Boolean bIsDelete;
    private Boolean bIsUndelete;

    private static Schema.SObjectType getSchemaInfo(String objectName) {

        if(!schemaInfoMap.containsKey(objectName)){
            schemaInfoMap.put(objectName, Schema.getGlobalDescribe().get(objectName));
        }

        return schemaInfoMap.get(objectName);
    }

    public PlatformEvents_Helper(Map<Id,sObject> ObjectMap, String PE_Name, String ObjSource, Boolean bIsInsert, Boolean bIsUpdate, Boolean bIsDelete, Boolean bIsUndelete) {
        this.ObjectMap = ObjectMap;
        this.PE_Name = PE_Name;
        this.ObjSource = ObjSource;
        this.bIsInsert = bIsInsert;
        this.bIsUpdate = bIsUpdate;
        this.bIsDelete = bIsDelete;
        this.bIsUndelete = bIsUndelete;
    }

    public void execute(QueueableContext context) {
        
        publishEvents(ObjectMap, PE_Name, ObjSource, bIsInsert, bIsUpdate, bIsDelete, bIsUndelete);

        System.debug('____ [PlatformEvents_Helper - execute] Events published');
    }
    
    public static void publishEvents(Map<Id,sObject> ObjectMap, string PE_Name, string ObjSource, boolean bIsInsert, boolean bIsUpdate, boolean bIsDelete, boolean bIsUndelete){
    	//Map that stores the name of the platform event based on the type of object received
    	map<string, string> PEObjName = new map<String,String>{
                'Account' => 'Account__e',
                'Contact' => 'Contact__e',
                'Account_Contact_Role__c' => 'AccountContactRole__e',
                'Account_Role__c' => 'AccountRole__e',
                'Partner_products__c' => 'PartnerProduct__e',
                'TIP_Pay_Prov_Prod_Country_Config__c' => 'Product_Country_Config__e',
                'TIP_BIN_Range__c' => 'Product_Bin_Range__e',
				'Remote_Invocation__c' => 'RemoteInvocation__e',
                'AP_Process_Form__c' => 'PASS__e',
                'Services_Rendered__c' => 'PASS__e'
		};
          
    	
        string sEventType = '';
        if(bIsInsert) sEventType = 'Create';
        if(bIsUpdate) sEventType = 'Update';
        if(bIsDelete) sEventType = 'Delete';
        if(bIsUndelete) sEventType = 'Undelete';
        
        if(sEventType=='') return;
        
        list<ISSP_Web_Service_Log__c> lsLogs = new list<ISSP_Web_Service_Log__c>();
        
        try{
            Map<Id,sObject> InternalObjectMap = new map<id, sObject>();
            List<RecordType> rtList = RecordTypeSingleton.getInstance().getRecordTypesBySObject(ObjSource);
            
            if(ObjSource == 'Account'){
            	rtList.addAll(RecordTypeSingleton.getInstance().getRecordTypesBySObject('Account_Role__c'));
            	InternalObjectMap = getAccountRoleToPublish(ObjectMap);
            }
            else if( ObjSource =='Contact'){
                rtList.addAll(RecordTypeSingleton.getInstance().getRecordTypesBySObject('Account_Contact_Role__c'));
            	InternalObjectMap = getAccountContactRoleToPublish(ObjectMap);
            }
            else InternalObjectMap = ObjectMap;
            
            List<SObject> lstSObjs = new list<SObject>();
            
            for(Id ObjId : InternalObjectMap.keySet()){
            	map<string, string> MapMapping = getMappingMap(PEObjName.get(string.valueOf(ObjId.getsobjecttype())));
            	if(MapMapping==null) continue;
                SObject sObj = getSchemaInfo(PEObjName.get(string.valueOf(ObjId.getsobjecttype()))).newSObject();
                for(string FieldSource:MapMapping.keyset()){
                    if(FieldSource=='Recordtype')
                        sObj.put(MapMapping.get(FieldSource), rtList.isEmpty() ? null : RTName(string.valueOf(ObjId.getsobjecttype()), (Id)(InternalObjectMap.get(ObjId).get('RecordtypeId'))));
                        
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
    
    private static string RTName(string theObject, id RTId){
        if(RTId==null)  return null;
        return RecordTypeSingleton.getInstance().getRecordTypeById(theObject, RTId).Name;
    }
    
    private static map<string, string> getMappingMap(string sObj){
        if(sObj=='Account__e'){
            return new map<String,String>{
                'Id' => 'AccountId__c',
                'Recordtype' => 'RecordType__c',
                'EventType' => 'Type__c'
            };
        }
        
        if(sObj=='Contact__e' || sObj=='Product_Bin_Range__e' || sObj=='PartnerProduct__e' 
        	|| sObj=='Product_Country_Config__e' || sObj=='AccountContactRole__e' || sObj=='AccountRole__e' || sObj=='RemoteInvocation__e' || sObj=='PASS__e'){
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
    
    
    //In case there is an Account Role related to TIP, it enrich the map with it
    private static Map<Id,sObject> getAccountRoleToPublish(Map<Id,sObject> mapAccnt){
    	map<id, sObject> mapToRet = new map<id, sObject>();
    	mapToRet.putAll(mapAccnt);

        if(mapAccnt.keyset().isEmpty()) return mapToRet;

    	for(Account_Role__c AccntRole: [select id, RecordTypeId, Account__c from Account_Role__c where Account__c in:mapAccnt.keyset() and recordtypeId=:TIP_UTILS.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID]){
    		mapToRet.put(accntRole.Id, AccntRole);
    	}
    	return mapToRet;
    }
    
     //In case there is an Account Contact Role related to TIP, it enrich the map with it
    private static Map<Id,sObject> getAccountContactRoleToPublish(Map<Id,sObject> mapCnt){
    	map<id, sObject> mapToRet = new map<id, sObject>();
    	mapToRet.putAll(mapCnt);

        if(mapCnt.keyset().isEmpty()) return mapToRet;
        
    	for(Account_Contact_Role__c AccntConRole: [select id, RecordTypeId, Account__c from Account_Contact_Role__c where Account__c in:mapCnt.keyset() and Service_Rendered__c = 'TIP']){
    		mapToRet.put(AccntConRole.Id, AccntConRole);
    	}
    	return mapToRet;
    }
}
