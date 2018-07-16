public class ISSOperationTriggerHandler {
	
	public static void handleAfterUpdate(List<AMS_Settlement_System__c> operations, Map<Id,AMS_Settlement_System__c> oldMap) {
		updateISSOperationRHCInformationFSFlag(operations);
	}

	public static void handleAfterInsert(List<AMS_Settlement_System__c> operations, Map<Id,AMS_Settlement_System__c> oldMap){
		updateISSOperationRHCInformationFSFlag(operations);	
	}

	public static void updateISSOperationRHCInformationFSFlag(List<AMS_Settlement_System__c> operations){
		
		Set<id> operationsIds = new Set<Id>();
		list<ANG_RHC_Information__c> rhcinfos = new list<ANG_RHC_Information__c>(); 
		for (AMS_Settlement_System__c operation : operations){
			if(operation.ANG_RHC_Amount_Equals_FS__c){
				operationsIds.add(operation.id);
			}
		}

		//List<ANG_RHC_Information__c> RHCinfos = new List<ANG_RHC_Information__c>();
		//if(!operationsIds.isEmpty()) RHCinfos = ;
		for (Account acc : [SELECT Id, (SELECT ID FROM RHC_Informations__r) FROM Account WHERE IATA_ISO_Country__r.AMS_Settlement_System__c in :operationsIds]){
			rhcinfos.addAll(acc.RHC_Informations__r);
		}
		for (ANG_RHC_Information__c rhcinfo : rhcinfos) rhcinfo.ANG_RHC_Amount_Equals_FS__c = true;
		update rhcinfos;
	}
}