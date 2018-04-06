public class PlatformEvents_Helper {
    
    public static void publishEvents(Map<Id,sObject> ObjectMap, String sEventType, string PE_Name, string ObjSource){
    	list<ISSP_Web_Service_Log__c> lsLogs = new list<ISSP_Web_Service_Log__c>();
    	
	    try{
	    	map<string, string> MapMapping = getMappingMap(PE_Name);
			
			if(MapMapping==null) return;
			
			List<SObject> lstSObjs = new list<SObject>();
			
			for(Id ObjId : ObjectMap.keySet()){
				SObject sObj = Schema.getGlobalDescribe().get(PE_Name).newSObject();
	
				for(string FieldSource:MapMapping.keyset()){
					if(FieldSource=='Recordtype')
						sObj.put(MapMapping.get(FieldSource) , RTName(ObjSource, (Id)(ObjectMap.get(ObjId).get('RecordtypeId'))));
						
					if(FieldSource=='EventType')
						sObj.put(MapMapping.get(FieldSource) , sEventType);
					
					if(FieldSource=='Id')	sObj.put(MapMapping.get(FieldSource) , ObjId);
				}
				
				lstSObjs.add(sObj);
			}
		
			
			
			for (Database.SaveResult sr : EventBus.publish(lstSObjs)) {
				if (!sr.isSuccess()){
					for(Database.Error err : sr.getErrors()) {
						lsLogs.add(new ISSP_Web_Service_Log__c(
										System__c = 'Platform Events for ' + ObjSource + '. Event Type: ' + sEventType,
										Error_Message__c = err.getStatusCode() + ' - ' + err.getMessage(),
										Web_Service__c = PE_Name,
										Method__c = 'PlatformEvents_Helper.publishEvents',
										Input_Description__c = 'One of the following: ' + ObjectMap.keyset()
										)
									);
					}
				}
			}
			
		}catch(exception e){
			lsLogs.add(new ISSP_Web_Service_Log__c(
						System__c = 'Platform Events for ' + ObjSource + '. Event Type: ' + sEventType,
						Error_Message__c = e.getMessage(),
						Web_Service__c = PE_Name,
						Method__c = 'PlatformEvents_Helper.publishEvents',
						Input_Description__c = 'One of the following: ' + ObjectMap.keyset()
						)
					);
		}
		
		if(!lsLogs.isEmpty()) insert lsLogs;
    }
    
    private static string RTName(string theObject, id RTId){
    	if(RTId==null)	return null;
    	return Schema.getGlobalDescribe().get(theObject).getDescribe().getRecordTypeInfosById().get(RTId).getName();
    }
    
    private static map<string, string> getMappingMap(string sObj){
    	if(sObj=='Account__e'){
    		return new map<String,String>{
		        'Id' => 'AccountId__c',
		        'Recordtype' => 'Recordtype__c',
		        'EventType' => 'Type__c'
		    };
    	}
    	
    	if(sObj=='Contact' || sObj=='Product_Bin_Range__e' || sObj=='PartnerProduct__e' || sObj=='Product_Country_Config__e' ){
    		return new map<String,String>{
		        'Id' => 'RecordId__c',
		        'Recordtype' => 'RecordType__c',
		        'EventType' => 'EventType__c'
		    };
    	}
    	
    	return null;
    }
}