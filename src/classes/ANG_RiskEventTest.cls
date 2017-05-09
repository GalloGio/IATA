@isTest
private class ANG_RiskEventTest {
	
	static {
		//initilize static variables
	}

	@testSetup static void createData() {
		Account a = new Account(Name = 'Test');
		insert a;

		ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Test', ANG_Risk_Id__c = '99', ANG_Expiration__c = 12);
		insert riskType;

		ANG_Agency_Risk_Event__c re = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = a.Id
			, ANG_Risk_Type__c = riskType.Id
			, ANG_Issued_date__c = System.today().addDays(1)
		);

		insert re;
	}
	
	static testMethod void test_loading() {
		ANG_Agency_Risk_Event__c re = [SELECT Id FROM ANG_Agency_Risk_Event__c ];

		Test.startTest();

		re.ANG_Issued_Date__c = Date.newInstance(2016, 10, 15);
		update re;

		Test.stopTest();

		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Expiration_Date__c, ANG_HE_AccountId__c FROM ANG_Agency_Risk_Event__c];
		System.assertEquals(Date.newInstance(2017, 10, 15), riskEvents[0].ANG_Expiration_Date__c);
	}
	
}