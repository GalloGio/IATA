@isTest
private  class ISSP_BatchUpdatePIRHistoryTest {
	static testMethod void ISSP_BatchUpdatePIRHistoryTest() {
		    insert new ISSP_CS__c(Name = 'Baggage History - Number Of Months',Value__c = '12');
	    	Account airlineIssuing = ISSP_TestBaggageObjectCreator.CreateAccount('SILVERWINGS','SI');
	    	Account airlineRecieving = ISSP_TestBaggageObjectCreator.CreateAccount('GOLDENWINGS','GO');
	    	PIR_Form__c pirFormArchived = ISSP_TestBaggageObjectCreator.CreatePirForm(airlineIssuing.Id, 'testArchived');
	    	Baggage_Claim__c prorateRequestExpired = ISSP_TestBaggageObjectCreator.CreateProrateRequest(pirFormArchived.Id, airlineRecieving.Id, 'GO');
	    	PIR_Form__c pirFormNotArchived = ISSP_TestBaggageObjectCreator.CreatePirForm(airlineIssuing.Id, 'testNotArchived');
	    	Baggage_Claim__c prorateRequestNotExpired = ISSP_TestBaggageObjectCreator.CreateProrateRequest(pirFormNotArchived.Id, airlineRecieving.Id, 'GO');
	        
	    	Test.startTest();

	        prorateRequestExpired.Date_Time_Proceed_to_payment__c = system.now().addMonths(-13);
	        update prorateRequestExpired;

	        ISSP_BatchUpdatePIRHistory batch = new ISSP_BatchUpdatePIRHistory();
	        Database.executeBatch(batch, 200);
	        
	        Test.stopTest();
	    }
}