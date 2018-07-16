public class ISSOperationTriggerHandler {
	
	public static final String RECTYPE_BSP;

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
				if(operation.ANG_RHC_Amount_Equals_FS__c && operation.ANG_RHC_Amount_Equals_FS__c != oldMap.get(operation.id).ANG_RHC_Amount_Equals_FS__c && operation.recordtypeid == RECTYPE_BSP) operationsIds.add(operation.id);
			else
				if(operation.ANG_RHC_Amount_Equals_FS__c && operation.recordtypeid == RECTYPE_BSP) operationsIds.add(operation.id);
		}

		for (Account acc : [SELECT Id, (SELECT ID FROM RHC_Informations__r) FROM Account WHERE IATA_ISO_Country__r.AMS_Settlement_System__c in :operationsIds]){
			rhcinfos.addAll(acc.RHC_Informations__r);
		}
		for (ANG_RHC_Information__c rhcinfo : rhcinfos) rhcinfo.ANG_RHC_Amount_Equals_FS__c = true;
		update rhcinfos;
	}
}