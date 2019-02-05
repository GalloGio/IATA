@isTest
public class CaseDetailTriggerHandlerTest {

	private static final String CALL_MONITORING = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Detail__c', 'Call_Monitoring'); 
    private static final String CASE_MONITORING = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Detail__c', 'Case_Monitoring'); 

	@isTest
	static void calculateScoreTest() {
		Case_Detail_Score_Fields_Weight__c sf1 = new Case_Detail_Score_Fields_Weight__c(Name = 'Identified_themselves__c', Call_Monitoring_Weight__c = 1, Case_Monitoring_Weight__c = 2);
		Case_Detail_Score_Fields_Weight__c sf2 = new Case_Detail_Score_Fields_Weight__c(Name = 'Mentioned_IATA__c', Call_Monitoring_Weight__c = 1, Case_Monitoring_Weight__c = 2);
		insert sf1;
		insert sf2;

		Case c = new Case();
		insert c;

		Case_Detail__c cd = new Case_Detail__c(Case__c = c.Id, RecordTypeId = CALL_MONITORING, Identified_themselves__c = true, Mentioned_IATA__c = true);
		insert cd;

		List<Case_Detail__c> caseDetailList = [SELECT Score1__c FROM Case_Detail__c WHERE Id =: cd.Id];

		System.assertEquals(caseDetailList[0].Score1__c, '2');

		cd.RecordTypeId = CASE_MONITORING;
		update cd;

		caseDetailList = [SELECT Score1__c FROM Case_Detail__c WHERE Id =: cd.Id];

		System.assertEquals(caseDetailList[0].Score1__c, '4');
	}

}