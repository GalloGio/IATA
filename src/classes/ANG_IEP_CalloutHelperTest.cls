@isTest
private class ANG_IEP_CalloutHelperTest {
	

	public class MockHttpResponseSuccessGenerator implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
			// Optionally, only send a mock response for a specific endpoint
			// and method.
			System.assertEquals('PUT', req.getMethod());
			
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(200);
			return res;
		}
	}

	public class MockHttpResponseFailureGenerator implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
			// Optionally, only send a mock response for a specific endpoint
			// and method.
			System.assertEquals('PUT', req.getMethod());
			
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(400);
			return res;
		}
	}

	@testSetup static void setup(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
		insert ctry ;

		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
		
		insert a1;

		//create custom setting
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'IEP', CalloutClass__c = 'ANG_CalloutIEPMasterdata', Remote_Site__c ='https://www.foonewgentest.com'));

		insert customsettings;

	
	}


	@isTest static void validateCorrectResponse() {
		
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

		Account acct = [Select Id, IATACode__c from Account LIMIT 1];

		ANG_IEP_CalloutHelper.invokeCustomImpl('IEP',acct);

		Test.stopTest();
	}
	
	@isTest static void validateIncorrectResponse() {

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailureGenerator());

		Account acct = [Select Id, IATACode__c from Account LIMIT 1];
		
		try{
			ANG_IEP_CalloutHelper.invokeCustomImpl('IEP',acct);
		
			System.assertEquals(true,false);
			
		}catch(Exception e){

			System.assertEquals('ANG_CalloutIEPMasterdata: The masterdata could not be sent to IEP. Status:400 - Reason:null' , e.getMessage());

		}

		Test.stopTest();

	}
	
}