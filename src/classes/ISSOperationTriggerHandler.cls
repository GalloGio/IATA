public class ISSOperationTriggerHandler {
	
	public static final String RECTYPE_BSP = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Settlement_System__c').get('BSP');  

	public static void handleAfterUpdate(List<AMS_Settlement_System__c> operations, Map<Id,AMS_Settlement_System__c> oldMap) {
		updateISSOperationRHCInformationFSFlag(operations, oldMap);
	}

	public static void handleAfterInsert(List<AMS_Settlement_System__c> operations, Map<Id,AMS_Settlement_System__c> oldMap){
		updateISSOperationRHCInformationFSFlag(operations, null);	
	}

	public static void updateISSOperationRHCInformationFSFlag(List<AMS_Settlement_System__c> operations, Map<Id,AMS_Settlement_System__c> oldMap){
		
		Set<id> operationsIds = new Set<Id>();
		list<ANG_RHC_Information__c> rhcinfos = new list<ANG_RHC_Information__c>(); 
		for (AMS_Settlement_System__c operation : operations){
			
			if (oldMap != null)
				if(operation.ANG_RHC_Amount_Equals_FS__c != oldMap.get(operation.id).ANG_RHC_Amount_Equals_FS__c && operation.recordtypeid == RECTYPE_BSP) operationsIds.add(operation.id);
			else
				if(operation.recordtypeid == RECTYPE_BSP) operationsIds.add(operation.id);
		}

		for (Account acc : [SELECT Id, IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c, (SELECT ID,ANG_RHC_Amount_Equals_FS__c FROM RHC_Informations__r) FROM Account WHERE IATA_ISO_Country__r.AMS_Settlement_System__c in :operationsIds]){
			if(!acc.RHC_Informations__r.isEmpty()){
				acc.RHC_Informations__r[0].ANG_RHC_Amount_Equals_FS__c = acc.IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c;
				rhcinfos.add(acc.RHC_Informations__r[0]);
			}
		}
		update rhcinfos;
	}
}