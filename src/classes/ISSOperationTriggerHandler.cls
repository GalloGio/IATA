public class ISSOperationTriggerHandler {

	public static final Integer BATCH_SIZE = 200;

	public static void handleAfterUpdate(List<AMS_Settlement_System__c> operations, Map<Id,AMS_Settlement_System__c> oldMap) {
		updateISSOperationRHCInformationFSFlag(operations, oldMap);
	}

	public static void handleAfterInsert(List<AMS_Settlement_System__c> operations, Map<Id,AMS_Settlement_System__c> oldMap){
		updateISSOperationRHCInformationFSFlag(operations, null);	
	}

	public static void updateISSOperationRHCInformationFSFlag(List<AMS_Settlement_System__c> operations, Map<Id,AMS_Settlement_System__c> oldMap){
		
		Set<String> operationsIds = new Set<String>();
		for (AMS_Settlement_System__c operation : operations){
			
			if (oldMap != null)
				if(operation.ANG_RHC_Amount_Equals_FS__c != oldMap.get(operation.id).ANG_RHC_Amount_Equals_FS__c && operation.recordtypeid == RECTYPE_BSP) operationsIds.add(operation.id);
			else
				if(operation.recordtypeid == AMS_Utils.RECTYPE_BSP) operationsIds.add(operation.id);
		}

		Database.executeBatch(new ANG_RHCEqualFSBatch(operationsIds), BATCH_SIZE);
	}
}