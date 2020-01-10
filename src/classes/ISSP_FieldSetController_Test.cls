@isTest
private class ISSP_FieldSetController_Test {

	static testMethod void myUnitTest() {

		//ISSP_FieldSetController ctrl = new ISSP_FieldSetController('Contact', 'Id');

		Set <String> stringSet = new Set <String>();
		stringSet.add('Id');
		stringSet.add('Name');
		ISSP_FieldSetController ctrl2 = new ISSP_FieldSetController('Contact', 'Id', stringSet);

		Map <String, String> stringMap = new Map <String, String>();
		stringMap.put('Id', 'Id');
		stringMap.put('Name', 'Name');
		stringMap.put('Account.Id', 'Account.Id');
		stringMap.put('IEC_Billing_Address__r.Id', 'IEC_Billing_Address__r.Id');
		ISSP_FieldSetController ctrl3 = new ISSP_FieldSetController(stringMap, 'Id');

		//ISSP_FieldSetController ctrl4 = new ISSP_FieldSetController('Contact', 'Id', 'Id', 'Id', stringSet);

		ISSP_FieldSetController ctrl5 = new ISSP_FieldSetController('Contact', 'Id', stringSet, 'Id', 'Id', stringSet);

		ISSP_FieldSetController ctrl6 = new ISSP_FieldSetController(stringMap, 'Id', 'Id');

		ctrl6.getLanguage();
		ctrl6.getSeparator();

	}
}
