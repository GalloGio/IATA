@isTest
private class RecordTypeSingletonTest {
	
	@isTest 
	private static void getRecordTypesTest() {
		//Id retrieved using Schema class
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		
		RecordType rtAccountStdd = RecordTypeSingleton.getInstance().getRecordType('Account', 'Standard_Account');
		Id rtAccountStddId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		// assertion to test RecordTypeSingleton.getInstance().getRecordTypeId(...)
		System.assertEquals(rtId, rtAccountStddId, 'The returned Id does not match the Id for Account type, Standard_Account record type');
		// assertion to test RecordTypeSingleton.getInstance().getRecordType(...)
		System.assertEquals('Account', rtAccountStdd.SobjectType, 'The returned type, ' + rtAccountStdd.SobjectType + ', does not match Account');
		System.assertEquals('Standard_Account', rtAccountStdd.DeveloperName, 'The returned record type, ' + rtAccountStdd.DeveloperName + ', does not match Standard_Account');

	}

	@isTest
	private static void getRecordTypeObjIdListTest(){
		//Map of RecordTypeInfo retrieved using Schema class
		Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.Participant__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
		
		List<Id> rtIdsList = RecordTypeSingleton.getInstance().getRecordTypeObjIdListForSpecfifiedNames('Participant__c', new List<String>{'Local_Group_Participants'});
		// assertions to test RecordTypeSingleton.getInstance().getRecordTypeObjIdListForSpecfifiedNames(...)
		System.assertEquals(recordTypesMap.get('Local_Group_Participants').getRecordTypeId(), rtIdsList.get(0), 'The returned List of Ids retrieved a wrong Id for Local_Group_Participants: ' +  rtIdsList.get(0));
		System.assertNotEquals(recordTypesMap.get('Reg_Div_Group_Participants').getRecordTypeId(), rtIdsList.get(0), 'The returned List of Ids retrieved a Id for Reg_Div_Group_Participants: ' +  rtIdsList.get(0));

	}

	@isTest
	private static void getRecordTypeObjIdListExceptPassedNamesTest(){
		// Map of RecordTypeInfo retrieved using Schema class
		Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
		
		List<Id> rtIdsExceptList = RecordTypeSingleton.getInstance().getRecordTypeObjIdListExceptPassedNames('Account', new List<String>{'IATA_Agency'});
		// assertion to test RecordTypeSingleton.getInstance().getRecordTypeObjIdListExceptPassedNames()
		System.assert(!rtIdsExceptList.contains(recordTypesMap.get('IATA_Agency').getRecordTypeId()), 'The returned List of Ids retrieved a Id for IATA_Agency: ' +  rtIdsExceptList.get(0));
	}
	

	@isTest
	private static void getRecordTypesBySObjectTest(){
		// Map of RecordTypeInfo retrieved using Schema class
		Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.Participant__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

		List<RecordType> participantRecTypeList = RecordTypeSingleton.getInstance().getRecordTypesBySObject('Participant__c');
		// assetions to test RecordTypeSingleton.getInstance().getRecordTypesBySObject(...)
		for(RecordType recType : participantRecTypeList){

			System.assert(recordTypesMap.keySet().contains(recType.DeveloperName), 'The returned list contains an invalid record type: ' + recType.Id);
			
		}

	}


}