public with sharing class IntegrationLogUtils {


	@AuraEnabled (cacheable=false)
	public static void insertIntoIntegrationLog(List<Integration_Log__c> intLogList){
		insert intLogList;
	}

	@AuraEnabled (cacheable=false)
	public static void insertIntoIntegrationLog(Integration_Log__c intLog){
		List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
		intLogList.add(intLog);
		IntegrationLogUtils.insertIntoIntegrationLog(intLogList);
	}

	@AuraEnabled (cacheable=false)
	public static Integration_Log__c createAccountContactRoleIntegrationLog(String extTranId, String recTypeId, String recordId){
		String objType = 'Account_Contact_Role__c';
		String status = 'In Progress';
		Integration_Log__c il = createIntegrationLog(extTranId, recTypeId, objType, status, recordId);
		return il;
	}

	@AuraEnabled (cacheable=false)
	public static Integration_Log__c createAccountRoleIntegrationLog(String extTranId, String recTypeId, String recordId){
		String objType = 'Account_Role__c';
		String status = 'In Progress';
		Integration_Log__c il = createIntegrationLog(extTranId, recTypeId, objType, status, recordId);
		return il;
	}

	@AuraEnabled (cacheable=false)
	public static Integration_Log__c createIntegrationLog(String extTranId, String recTypeId, String objType, String status, String recordId){
		Integration_Log__c il = new Integration_Log__c( External_Transaction_Id__c = extTranId,
														RecordTypeId = recTypeId,
														object_type__c = objType,
														RecordId__c = recordId,
														Status__c = status);
		return il;
	}
}
