/**
	Test Class for OperationalImprovementsHandler.cls
**/
@isTest
private class OperationalImprovementsHandlerTest {

	public static final Id OI_RECORDTYPE_ID = Schema.SObjectType.Operational_Improvements__c.getRecordTypeInfosByDeveloperName().get('Operational_Improvements').getRecordTypeId();

	@isTest
	public static void test_populateExchangeRate_notCPS() {

		list<Operational_Improvements__c> listImprovements = new list<Operational_Improvements__c>();
		listImprovements.add(new Operational_Improvements__c(
			RecordTypeId = OI_RECORDTYPE_ID,
			Country__c = 'Spain',
			Section_Code__c = 'ES_BSP_Y_EUR_I',
			Exchange_rate__c = null,
			Currency__c = null
		));
		listImprovements.add(new Operational_Improvements__c(
			RecordTypeId = OI_RECORDTYPE_ID,
			Country__c = 'Spain',
			Section_Code__c = 'ES_BSP_Y_EUR_I',
			Exchange_rate__c = null,
			Currency__c = ''
		));
		listImprovements.add(new Operational_Improvements__c(
			RecordTypeId = OI_RECORDTYPE_ID,
			Country__c = 'Spain',
			Section_Code__c = 'ES_BSP_Y_EUR_I',
			Exchange_rate__c = null,
			Currency__c = 'USD'
		));
		listImprovements.add(new Operational_Improvements__c(
			RecordTypeId = OI_RECORDTYPE_ID,
			Country__c = 'Spain',
			Section_Code__c = 'ES_BSP_Y_EUR_I',
			Exchange_rate__c = null,
			Currency__c = 'XXX'
		));

		Test.StartTest();
		//test insert
		insert listImprovements;

		// check inserts
		list<Operational_Improvements__c> listResult = [SELECT Id, Exchange_rate__c FROM Operational_Improvements__c];
		System.assertEquals(4, listResult.size());
		for (Operational_Improvements__c result : listResult) {
			System.assertEquals(null, result.Exchange_rate__c);
		}

		//test update
		for (Operational_Improvements__c result : listResult) {
			result.Exchange_rate__c = null;
			result.Currency__c = 'EUR';
		}
		update listImprovements;

		listResult = [SELECT Id, Exchange_rate__c FROM Operational_Improvements__c];
		System.assertEquals(4, listResult.size());
		for (Operational_Improvements__c result : listResult) {
			System.assertEquals(null, result.Exchange_rate__c);
		}
		Test.StopTest();
	}

	@isTest
	public static void test_populateExchangeRate_CPS() {

		list<Operational_Improvements__c> listImprovements = new list<Operational_Improvements__c>();
		listImprovements.add(new Operational_Improvements__c(
			RecordTypeId = OperationalImprovementsHandler.CPS_RECORDTYPE_ID,
			Country__c = 'Spain',
			Section_Code__c = 'ES_BSP_Y_EUR_I',
			Exchange_rate__c = null,
			Currency__c = null
		));
		listImprovements.add(new Operational_Improvements__c(
			RecordTypeId = OperationalImprovementsHandler.CPS_RECORDTYPE_ID,
			Country__c = 'Spain',
			Section_Code__c = 'ES_BSP_Y_EUR_I',
			Exchange_rate__c = null,
			Currency__c = ''
		));
		listImprovements.add(new Operational_Improvements__c(
			RecordTypeId = OperationalImprovementsHandler.CPS_RECORDTYPE_ID,
			Country__c = 'Spain',
			Section_Code__c = 'ES_BSP_Y_EUR_I',
			Exchange_rate__c = null,
			Currency__c = 'USD'
		));
		listImprovements.add(new Operational_Improvements__c(
			RecordTypeId = OperationalImprovementsHandler.CPS_RECORDTYPE_ID,
			Country__c = 'Spain',
			Section_Code__c = 'ES_BSP_Y_EUR_I',
			Exchange_rate__c = null,
			Currency__c = 'XXX'
		));
		
		Test.StartTest();
		//test insert
		insert listImprovements;

		// check inserts
		list<Operational_Improvements__c> listResult = [SELECT Id, Exchange_rate__c, Currency__c FROM Operational_Improvements__c];
		System.assertEquals(4, listResult.size());
		for (Operational_Improvements__c result : listResult) {
			if (result.Currency__c == 'USD') {
				System.assert(result.Exchange_rate__c!=null);
			} else {
				System.assert(result.Exchange_rate__c==null);
			}
		}

		//test update
		for (Operational_Improvements__c result : listImprovements) {
			result.Currency__c = 'EUR';
		}
		update listImprovements;

		// check update
		listResult = [SELECT Id, Exchange_rate__c, Currency__c FROM Operational_Improvements__c];
		System.assertEquals(4, listResult.size());
		for (Operational_Improvements__c result : listResult) {
			System.assert(result.Exchange_rate__c!=null, 'fail: ' + result.Exchange_rate__c);
		}
		Test.StopTest();

	}
}
