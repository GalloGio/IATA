@isTest
private class ANG_RiskEventConfigurationTest {
	
	static {
		//initilize static variables
	}

	@testSetup static void createData() {
		ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Test', ANG_Risk_Id__c = '99', ANG_Expiration__c = 12);
		insert riskType;

		ANG_Risk_Event_Configuration__c config = new ANG_Risk_Event_Configuration__c();
		config.ANG_Risk_Event_Type__c = riskType.Id;
		config.ANG_Object_Type__c = 'Case';
		config.ANG_Object_Record_Type__c = 'SIDRA';
		insert config;
	}
	
	static testMethod void test_validation() {
		ANG_Risk_Event_Configuration__c config = [SELECT Id FROM ANG_Risk_Event_Configuration__c LIMIT 1];
		config.ANG_Field06__c = 'Test';

		Test.startTest();

		try {
			update config;
		} catch(Exception e) {
			System.assert(e.getMessage().contains('Please inform Conditions and Values for Field06'));
		}
	}
	
}