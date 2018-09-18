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
            if (req.getEndpoint().contains('Mulesoft_Credential_Masterdata')) 
				System.assertEquals('PUT', req.getMethod());
			
			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(400);
			return res;
		}
	}
	public class UnauthorizedEndpointMockHttpResponseGenerator implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
		
			CalloutException e = (CalloutException)CalloutException.class.newInstance();
	        e.setMessage('Unauthorized endpoint!');
	        throw e;

		}
	}

	@testSetup static void setup(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
		insert ctry ;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account a1 = new Account(ANG_IEP_Status__c = 'Open', IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
		
		insert a1;

		Account a2 = new Account(ANG_IEP_Status__c = 'Open', IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234567',Location_Type__c='HO',Name='Test2 Agency OK',Short_Name__c='Test2 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
		
		insert a2;

		//create custom setting
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'IEP_1',Integration_System__c='Mulesoft', Action__c = 'PUT' , CalloutClass__c = 'ANG_CalloutIEPMasterdata', Event_Type__C = 'Update', Change_code__c = 'IEP' ,Credential__c = '/agencies/v1/' , Named_Credential__c = 'Mulesoft_Credential_Masterdata',Type__c='ChangeCode',Field__c='' ));
		customsettings.add(new ANG_CalloutMapping__c(Name = 'IEP_2',Integration_System__c='SAP PI', Action__c = 'PUT' , CalloutClass__c = 'ANG_CalloutSAPMasterdata', Event_Type__C = 'Update', Change_code__c = 'IEP' ,Credential__c = '/agencies/v1/' , Named_Credential__c = 'Mulesoft_Credential_Masterdata',Type__c='ChangeCode',Field__c='' ));

		insert customsettings; 

	
	}


	@isTest static void validateCorrectResponse() {
		
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

		Account acct = [Select Id, ANG_IEP_Status__c, IATACode__c, Location_Type__c from Account LIMIT 1];
		
		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = acct.Id, Change_Code__c = 'IEP',  Sent_to_external_system__c = false);

		insert aacc1;
		Test.stopTest();
		list<AMS_Agency_Updates__c> agencyEventsList = [select id,Update_Type__c,Integration_System__c from AMS_Agency_Updates__c where  Agency_Applied_Change_code__c =:aacc1.id and Integration_System__c = 'Mulesoft'];

		system.assertEquals(1,agencyEventsList.size());

		system.assertEquals('Mulesoft',agencyEventsList.get(0).Integration_System__c);
		system.assertEquals('Update_Sent',agencyEventsList.get(0).Update_Type__c);

		
	}
	@isTest static void unauthorizedEndpointResponse() {
		
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointMockHttpResponseGenerator());

		Account acct = [Select Id, ANG_IEP_Status__c, IATACode__c, Location_Type__c from Account LIMIT 1];
		
		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = acct.Id, Change_Code__c = 'IEP',  Sent_to_external_system__c = false);

		insert aacc1;
		Test.stopTest();
		list<AMS_Agency_Updates__c> agencyEventsList = [select id,Update_Type__c,Integration_System__c from AMS_Agency_Updates__c where  Agency_Applied_Change_code__c =:aacc1.id and Integration_System__c = 'Mulesoft'];

		system.assertEquals(1,agencyEventsList.size());
		system.assertEquals('Error',agencyEventsList.get(0).Update_Type__c);
	}
	
	@isTest static void validateIncorrectResponse() {

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailureGenerator());

		Account acct = [Select Id, ANG_IEP_Status__c, IATACode__c, Location_Type__c from Account LIMIT 1];
		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = acct.Id, Change_Code__c = 'IEP', Sent_to_external_system__c = false);
		
		try{
			insert aacc1;
		}catch(Exception e){
			System.assertEquals('ANG_CalloutIEPMasterdata: The masterdata could not be sent to IEP. Status:400 - Reason:null' , e.getMessage());
		}

		Test.stopTest();		
		list<AMS_Agency_Updates__c> agencyEventsList = [select id,Update_Type__c from AMS_Agency_Updates__c where  Agency_Applied_Change_code__c =:aacc1.id and Integration_System__c = 'Mulesoft'];

		system.assertEquals(1,agencyEventsList.size());
		system.assertEquals('Error',agencyEventsList.get(0).Update_Type__c);
	}

	@isTest static void validateCorrectResponseAboveThreshold() {
		
		Test.startTest();

		ANG_IEP_CalloutHelper.isRunningTestForThreshold = true;

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

		List<Account> acctList = [Select Id, ANG_IEP_Status__c, IATACode__c, Location_Type__c from Account];
		
		Account acct1 = acctList.get(0);
		Account acct2 = acctList.get(1);

		Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Account__c = acct1.Id, Change_code__c = 'IEP', Sent_to_external_system__c = false);
		Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Account__c = acct2.Id, Change_code__c = 'IEP',  Sent_to_external_system__c = false);

		insert new List<Agency_Applied_Change_code__c>{aacc1,aacc2};

		ANG_IEP_CalloutHelper.isRunningTestForThreshold = false;
		
		Test.stopTest();
	}

	@isTest static void testTriggerEvents() {
		//covering unused events on trigger
		ANG_agencyEventTriggerHandler triggerhandler = new ANG_agencyEventTriggerHandler();
		triggerhandler.onBeforeInsert();
		triggerhandler.onBeforeUpdate();
		triggerhandler.onAfterUpdate();
		triggerhandler.onBeforeDelete();
		triggerhandler.onAfterDelete();

	}
	
}