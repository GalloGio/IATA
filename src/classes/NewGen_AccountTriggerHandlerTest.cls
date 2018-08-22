@isTest
private class NewGen_AccountTriggerHandlerTest {
	
	@testSetup static void createData() {
        Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
        Id riskStatusAssessmentRT = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT;

		IATA_ISO_Country__c countryNew = new IATA_ISO_Country__c( Name = 'Switzerland', ISO_Code__c = 'CH', ANG_Enable_NewGen__c = true);
		insert countryNew;

		Account a = new Account(Name = 'Test', IATACode__c = '123', RecordTypeId = accRT, Location_Type__c = AMS_Utils.HE, Location_Class__c = 'P', IATA_ISO_Country__c = countryNew.id);
		insert a;

		insert new ANG_RHC_Information__c (ANG_AccountId__c = a.Id);

		ANG_Agency_Risk_Calculation__c calcA = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY, ANG_Risk_History_Assessment__c = AMS_Utils.PASSED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_A, ANG_Limit_Cash_Condition__c = false);
		ANG_Agency_Risk_Calculation__c calcB = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY, ANG_Risk_History_Assessment__c = AMS_Utils.PASSED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_B, ANG_Limit_Cash_Condition__c = false);
		ANG_Agency_Risk_Calculation__c calcC = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY, ANG_Risk_History_Assessment__c = AMS_Utils.FAILED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_c, ANG_Limit_Cash_Condition__c = true);
		insert new List<ANG_Agency_Risk_Calculation__c>{calcA, calcB, calcC};

	}

	static testMethod void test_riskStatus_Change() {
		NewGenApp_Custom_Settings__c newgenCS = new NewGenApp_Custom_Settings__c();
        newgenCS.Push_Notifications_State__c = true;
        insert newgenCS;

		Account a = [SELECT Id, ANG_RiskStatus__c FROM Account WHERE Name = 'Test'];
		System.assertEquals(null, a.ANG_RiskStatus__c);

		a.Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY;
		a.ANG_HE_RiskHistoryAssessment__c = AMS_Utils.PASSED;
		update a;

		a = [SELECT Id, ANG_RiskStatus__c FROM Account WHERE Name = 'Test'];
		System.assertEquals('A', a.ANG_RiskStatus__c);
		
		// when status changes, it should send a push notification to mobile user.
		a.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		a.ANG_HE_RiskHistoryAssessment__c = AMS_Utils.FAILED;
		update a;

		Test.startTest();

		a = [SELECT Id, ANG_RiskStatus__c FROM Account WHERE Name = 'Test'];
		System.assertEquals('C', a.ANG_RiskStatus__c);

		// when Risk Status changes and Push_Notifications_State__c = true, push notification will be sent to user mobile

		Test.stopTest();

	}
}