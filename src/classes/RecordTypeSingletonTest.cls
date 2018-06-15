@isTest
private class RecordTypeSingletonTest {
	
	
	@isTest 
	private static void getRecordTypesTest() {
		//Id retrieved using Schema class
		Id rtId = Schema.Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();
		
		RecordType rtAccountStdd = RecordTypeSingleton.getInstance().getRecordType('Account', 'Standard_Account');
		Id rtAccountStddId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		// assertion to test RecordTypeSingleton.getInstance().getRecordTypeId()
		System.assertEquals(rtId, rtAccountStddId, 'The returned Id does not match the Id for Account type, Standard_Account record type');
		// assertion to test RecordTypeSingleton.getInstance().getRecordType()
		System.assertEquals('Account', rtAccountStdd.SobjectType, 'The returned type, ' + rtAccountStdd.SobjectType + ', does not match Account');
		System.assertEquals('Standard_Account', rtAccountStdd.DeveloperName, 'The returned record type, ' + rtAccountStdd.DeveloperName + ', does not match Standard_Account');

	}
	
}