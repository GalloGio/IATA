@isTest
public class ServiceNow_Helper_test {

	@testSetup
	public static void createSettings(){

		//mulesoft
		ISSP_Int_Error__c settingMS  = new ISSP_Int_Error__c(
			Name = 'SNOW1',
			Assignment_Group__c = 'Mulesoft Support',
			Business_Service__c = 'Mulesoft',
			Caller_ID__c = 'Salesforce.com',
			Category__c = 'Failure',
			Caused_By__c = 'Mulesoft',
			Contact_Type__c = 'Monitoring',
			Impact__c = '2',
			Severity__c = '2',
			Subcategory__c = 'Connectivity',
			U_Application__c = 'Mulesoft',
			U_Business_Service__c = 'Infrastructure Services',
			U_Issue_Identified_By__c = 'INT_008',
			U_Operation_Name__c = 'Agency MasterData',
			Urgency__c = '2'
		);
	
		//RME
		ISSP_Int_Error__c settingRME  = new ISSP_Int_Error__c(
			Name = 'SNOW3',
			Assignment_Group__c = 'GDC 24x7 Active Desk',
			Business_Service__c = 'RME',
			Caller_ID__c = 'Salesforce.com',
			Category__c = 'Failure',
			Caused_By__c = 'Mulesoft',
			Contact_Type__c = 'Monitoring',
			Impact__c = '2',
			Severity__c = '2',
			Subcategory__c = 'Connectivity',
			U_Application__c = 'featurespace-system-service',
			U_Business_Service__c = 'RHC',
			U_Issue_Identified_By__c = 'INT_068',
			U_Operation_Name__c = 'requestBalanceUpdate',
			Urgency__c = '2'
		);

		//SFDC
		ISSP_Int_Error__c settingSFDC  = new ISSP_Int_Error__c(
			Name = 'SNOW10',
			Assignment_Group__c = 'Salesforce Support Level 2',
			Business_Service__c = 'SFDC',
			Caller_ID__c = 'Salesforce.com',
			Category__c = 'Failure',
			Caused_By__c = 'Salesforce',
			Contact_Type__c = 'Monitoring',
			Impact__c = '2',
			Severity__c = '2',
			Short_Description__c = 'Downgrade of Risk Status - SAAM creation failed',
			Subcategory__c = 'Connectivity',
			U_Application__c = 'SFDC',
			U_Business_Service__c = 'Salesforce.com',
			U_Issue_Identified_By__c = 'ANG_AccountTriggerHandler',
			U_Operation_Name__c = 'manageDowngrades',
			Urgency__c = '2'
		);

		List<ISSP_Int_Error__c> settings = new List<ISSP_Int_Error__c>{settingMS,settingRME,settingSFDC};
		insert settings;
	}
	
	@isTest
	public static void responsePassed(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPassed());
        //ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'featurespace-system-service', 'RME', 'Test', 'Test', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c(Error_Code__c = 'Iata Code Mismatch');
		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.testWebserviceResult();
		ServiceNow_Helper.sendRequestToSNOWRME('SNOW3', '12345678', log, result);
		Test.stopTest();
		List<ISSP_Web_Service_Log__c> logs = [select id, Success__c from ISSP_Web_Service_Log__c];
		System.assertEquals(logs.size(), 1);
		System.assert(logs[0].Success__c, 'Log should be true');
	} 
    
    @isTest
	public static void responseFailed(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailed());
        //ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'featurespace-system-service', 'RME', 'Test', 'Test', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c(Error_Code__c = 'Exception sending request', Error_Message__c = 'test Error Message');
		ServiceNow_Helper.sendRequestToSNOWMulesoft('SNOW1', '12345678', log);
		Test.stopTest();
		List<ISSP_Web_Service_Log__c> logs = [select id, Success__c from ISSP_Web_Service_Log__c];
		System.assertEquals(logs.size(), 1);
		System.assert((!logs[0].Success__c), 'Log should be false');
	}

	@isTest
	public static void noResponse(){
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorNoResponse());
        //ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'featurespace-system-service', 'RME', 'Test', 'Test', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
		try{
    		CalloutException ce = new CalloutException();
    		ce.setMessage('test Exception');
    		throw ce;
		}catch(Exception e){
			ServiceNow_Helper.sendRequestToSNOWSFDC('SNOW10', e);
		}	
		Test.stopTest();
		List<ISSP_Web_Service_Log__c> logs = [select id, Success__c from ISSP_Web_Service_Log__c];
		System.assertEquals(logs.size(), 1);
		System.assert((!logs[0].Success__c), 'Log should be false');
	}

	public class MockHttpResponseGeneratorPassed implements HttpCalloutMock {
	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setStatusCode(200);
	        return res;
	    }
	}
    
	public class MockHttpResponseGeneratorFailed implements HttpCalloutMock {
	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setStatusCode(400);
	        return res;
	    }
	}

	public class MockHttpResponseGeneratorNoResponse implements HttpCalloutMock {
	    public HTTPResponse respond(HTTPRequest req) {
	       CalloutException e = (CalloutException)CalloutException.class.newInstance();
        	e.setMessage('TESTING ERROR. Creating log accordingly');
        	throw e;
	    }
	}
}