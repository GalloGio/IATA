@isTest
private class ANG_AccountTriggerHandlerTest {


	@testSetup static void createData() {
        Id accRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency');
        Id riskStatusAssessmentRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Agency_Risk_Calculation__c').get('Risk_Status_Assessment');

		Account a = new Account(Name = 'Test', IATACode__c = '123', RecordTypeId = accRT, Location_Type__c = 'HE');
		insert a;

		ANG_Agency_Risk_Calculation__c calcA = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = 'Satisfactory', ANG_Risk_History_Assessment__c = 'Passed', ANG_Risk_History__c = 'A');
		ANG_Agency_Risk_Calculation__c calcB = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = 'Unsatisfactory - No action', ANG_Risk_History_Assessment__c = 'Passed', ANG_Risk_History__c = 'B');
		ANG_Agency_Risk_Calculation__c calcC = new ANG_Agency_Risk_Calculation__c(RecordTypeId = riskStatusAssessmentRT, ANG_Financial_Review_Result__c = 'Unsatisfactory - No action', ANG_Risk_History_Assessment__c = 'Failed', ANG_Risk_History__c = 'C');
		insert new List<ANG_Agency_Risk_Calculation__c>{calcA, calcB, calcC};

	}
	
	static testMethod void test_riskStatus_allcases() {
		Account a = [SELECT Id FROM Account WHERE Name = 'Test'];
		// fill accounts last financial review result and risk history and assert new risk status
		Test.startTest();

		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] first update should be A');
		a.Financial_Review_Result__c = 'Satisfactory';
		a.ANG_HE_RiskHistoryAssessment__c = 'Passed';
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, Subject FROM Cases) FROM Account WHERE Name = 'Test'];
		System.assertEquals('A', a.ANG_RiskStatus__c);

		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] second update should be B');
		// change values and check downgrade and SAAM case creation
		a.Financial_Review_Result__c = 'Unsatisfactory - No action';
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, Subject FROM Cases ORDER BY CreatedDate) FROM Account WHERE Name = 'Test'];
		System.assertEquals('B', a.ANG_RiskStatus__c);
		System.assertEquals(1, a.Cases.size());
		System.assertEquals('Test - 123 - Downgrade Risk Status', a.Cases[0].Subject);


		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] third update should be C');
		// change values one more time and check downgrade and OSCAR creation
		a.ANG_HE_RiskHistoryAssessment__c = 'Failed';
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, RecordType.DeveloperName FROM Cases ORDER BY CreatedDate) FROM Account WHERE Name = 'Test'];
		System.assertEquals('C', a.ANG_RiskStatus__c);
		System.assertEquals(2, a.Cases.size());
		System.assertEquals('OSCAR_Communication', a.Cases[1].RecordType.DeveloperName);

		Test.stopTest();
	}
	
}