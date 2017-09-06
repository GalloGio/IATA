@isTest
private class ANG_AccountTriggerHandlerTest {


	@testSetup static void createData() {
        Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
        Id riskStatusAssessmentRT = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT;

		Account a = new Account(Name = 'Test', IATACode__c = '123', RecordTypeId = accRT, Location_Type__c = AMS_Utils.HE);
		insert a;

		insert new ANG_RHC_Information__c (ANG_AccountId__c = a.Id);

		ANG_Agency_Risk_Calculation__c calcA = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY, ANG_Risk_History_Assessment__c = AMS_Utils.PASSED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_A, ANG_Limit_Cash_Condition__c = false);
		ANG_Agency_Risk_Calculation__c calcB = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY, ANG_Risk_History_Assessment__c = AMS_Utils.PASSED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_B, ANG_Limit_Cash_Condition__c = false);
		ANG_Agency_Risk_Calculation__c calcC = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY, ANG_Risk_History_Assessment__c = AMS_Utils.FAILED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_c, ANG_Limit_Cash_Condition__c = true);
		insert new List<ANG_Agency_Risk_Calculation__c>{calcA, calcB, calcC};

	}
	
	static testMethod void test_riskStatus_allcases() {
		Account a = [SELECT Id FROM Account WHERE Name = 'Test'];
		// fill accounts last financial review result and risk history and assert new risk status
		Test.startTest();

		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] first update should be A');
		a.Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY;
		a.ANG_HE_RiskHistoryAssessment__c = AMS_Utils.PASSED;
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, Subject FROM Cases) FROM Account WHERE Name = 'Test'];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_A, a.ANG_RiskStatus__c);

		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] second update should be B');
		// change values and check downgrade and SAAM case creation
		a.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, Subject FROM Cases ORDER BY CreatedDate) FROM Account WHERE Name = 'Test'];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_B, a.ANG_RiskStatus__c);
		System.assertEquals(1, a.Cases.size());
		System.assertEquals('Test - 123 - Downgrade Risk Status', a.Cases[0].Subject);


		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] third update should be C');
		// change values one more time and check downgrade and OSCAR creation
		a.ANG_HE_RiskHistoryAssessment__c =  AMS_Utils.FAILED;
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, RecordType.DeveloperName FROM Cases ORDER BY CreatedDate) FROM Account WHERE Name = 'Test'];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_C, a.ANG_RiskStatus__c);
		System.assertEquals(2, a.Cases.size());
		System.assertEquals('OSCAR_Communication', a.Cases[1].RecordType.DeveloperName);
		System.assert([SELECT Id, ANG_CashCondition__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].ANG_CashCondition__c);

		Test.stopTest();
	}

	static testMethod void test_RHCupdate() {
		
		Account a = [SELECT Id FROM Account WHERE Name = 'Test'];
		a.Status__c = AMS_Utils.ACC_S0_TERMINATED;
		update a;

		Test.startTest();

		a.Status__c = AMS_Utils.ACC_S9_APPROVED;
		update a;

		Test.stopTest();
	}
	
}