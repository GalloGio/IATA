@isTest
private class csp_redirectorControllerTest {

	public class MockHttpResponseGenerator implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
			// Optionally, only send a mock response for a specific endpoint
			// and method.
			System.assertEquals('GET', req.getMethod());

			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"country":"Portugal"}');
			res.setStatusCode(200);
			return res;
		}
	}

	public class MockHttpResponseErrorGenerator implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
			// Optionally, only send a mock response for a specific endpoint
			// and method.
			System.assertEquals('GET', req.getMethod());

			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"example":"test"}');
			res.setStatusCode(200);
			return res;
		}
	}

	@TestSetup
	static void testSetup(){

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		List<ISSP_CS__c> customSettingList = new List<ISSP_CS__c>();

		ISSP_CS__c customSetting1 = new ISSP_CS__c();
		customSetting1.Name = 'ipinfo_token';
		customSetting1.Value__c = '871e08ecd39325';
		customSettingList.add(customSetting1);

		ISSP_CS__c customSetting2 = new ISSP_CS__c();
		customSetting2.Name = '1ID redirect';
		customSetting2.Value__c = 'ON';
		customSettingList.add(customSetting2);

		ISSP_CS__c customSetting3 = new ISSP_CS__c();
		customSetting3.Name = 'Identity Login Page';
		customSetting3.Value__c = 'https://identity.iata.org/s/login';
		customSettingList.add(customSetting3);

		ISSP_CS__c customSetting4 = new ISSP_CS__c();
		customSetting4.Name = 'ISSP Landing Page';
		customSetting4.Value__c = 'ISSP';
		customSetting4.defaultValue__c = '/ISSP_Homepage';
		customSettingList.add(customSetting4);

		ISSP_CS__c customSetting5 = new ISSP_CS__c();
		customSetting5.Name = 'CS Portal Redirect';
		customSetting5.Value__c = 'CSP';
		customSetting5.defaultValue__c = '/s/';
		customSettingList.add(customSetting5);

		insert customSettingList;

	}

	@IsTest
	static void testBlankServiceNameRedirect(){

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		//delete the custom settings to test the scenario without them
		List<ISSP_CS__c> listCustomSettings = ISSP_CS__c.getAll().values();

		for(ISSP_CS__c cs : listCustomSettings) {
			cs.Value__c = null;
		}

		update listCustomSettings;

		test.startTest();
		String newLocation = csp_redirectorController.redirectToLogin(null, '', 'csportal', '','');
		test.stopTest();

		System.assertEquals('/issp_login?communityName=csportal', newLocation);

	}

	@IsTest
	static void testCSPortalRedirectWithoutStartURL(){

		test.startTest();
		String newLocation = csp_redirectorController.redirectToLogin(null, '', null, 'CSP','');
		test.stopTest();

		System.assertEquals('https://identity.iata.org/s/login?startURL=/s/&serviceName=CSP', newLocation);

	}

	@IsTest
	static void testCSPortalRedirectWithStartURL(){

		test.startTest();
		String newLocation = csp_redirectorController.redirectToLogin('/ISSP_Homepage', '', null, 'CSP','');
		test.stopTest();

		System.assertEquals('https://identity.iata.org/s/login?startURL=/ISSP_Homepage&serviceName=CSP', newLocation);

	}

	@IsTest
	static void testFindLocationWithoutCountry(){

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseErrorGenerator());

		List<ISSP_Web_Service_Log__c> logsListBefore = [SELECT Id FROM ISSP_Web_Service_Log__c];

		test.startTest();
		String newLocation = csp_redirectorController.redirectToLogin('/ISSP_Homepage', '', 'csportal', 'CSP','192.0.2.0');
		test.stopTest();

		List<ISSP_Web_Service_Log__c> logsListAfter = [SELECT Id FROM ISSP_Web_Service_Log__c];

		System.assertNotEquals(logsListBefore.size(), logsListAfter.size());

	}

	@IsTest
	static void testFindLocationWithIpAddress(){

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		test.startTest();
		csp_redirectorController.findLocation(false, '192.0.2.0');
		test.stopTest();
	}

	@IsTest
	static void testExpetionInRequest(){


		test.startTest();
		csp_redirectorController.findLocation(false, '192.0.2.0');
		test.stopTest();
	}
}
