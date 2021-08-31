/**
 * @description		Class to contain all the functions related to the IGOM_Account_Role_Detail__c object
 */
public without sharing class IGOMAccountRoleDetailUtil {
	@InvocableMethod(label='Set IGOM Account role detail record types' description='Set the record type when the record type does not have it. Base the record type on the related account.' category= 'IGOM_Account_Role_Detail__c')
	public static List<ID> setRecordTypes(List<IGOM_Account_Role_Detail__c> accountRoleDetails) {
		Map<String, Id> recordTypeIdsByName = RecordTypeSingleton.getInstance().getRecordTypeObjIdMapForSpecfifiedNames('IGOM_Account_Role_Detail__c', new List<String>{IGOMConstants.STATION.TYPE.AIRLINE, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ});
		Id recordTypeAirline = recordTypeIdsByName.get(IGOMConstants.STATION.TYPE.AIRLINE);
		Id recordTypeGH_HQ = recordTypeIdsByName.get(IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ);

		Set<Id> accountRoleDetailIds = new Set<Id>();
		for(IGOM_Account_Role_Detail__c accRoleDetail: accountRoleDetails){
			accountRoleDetailIds.add(accRoleDetail.Id);
		}

		Set<Id> accountRoleIds = new Set<Id>();
		List<IGOM_Account_Role_Detail__c> accountRoleDetailsToUpdate = new List<IGOM_Account_Role_Detail__c>();
		for(IGOM_Account_Role_Detail__c accRoleDetail : [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c WHERE Id IN :accountRoleDetailIds]){
			if (accRoleDetail.Account_Role__c != null) {
				accountRoleIds.add(accRoleDetail.Account_Role__c);
				accountRoleDetailsToUpdate.add(accRoleDetail);
			}
		}

		List<Account_Role__c> accRoles = [SELECT Id, Account__r.Category__c FROM Account_Role__c WHERE Id IN :accountRoleIds];
		Map<Id, String> accCategoryPerAccRole = new Map<Id, String>();
		for(Account_Role__c accRole :accRoles){
			accCategoryPerAccRole.put(accRole.Id, accRole.Account__r.Category__c);
		}


		for(IGOM_Account_Role_Detail__c accRoleDetail : accountRoleDetailsToUpdate){
			accRoleDetail.RecordTypeId = accCategoryPerAccRole.get(accRoleDetail.Account_Role__c) == 'Ground Service Provider' ? recordTypeGH_HQ : recordTypeAirline;
		}

		Database.SaveResult[] results = Database.update(accountRoleDetailsToUpdate);
		List<ID> resultIds = new List<ID>();
		for (Database.SaveResult result : results) {
			if (result.isSuccess()) {
				resultIds.add(result.getId());
			}
		}
		return resultIds;
	}
}