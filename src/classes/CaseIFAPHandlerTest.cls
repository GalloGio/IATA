/*
 	Class Name: CaseIFAPHandler

 	Copyright © IATA

 	Purpose: Test class for CaseIFAPHandler

 	VERSION     AUTHOR        	DATE          	DETAIL/CHANGE REFERENCE
 	1.0 -	    João Santos     07/11/2019    	INITIAL DEVELOPMENT
*/

@isTest
private class CaseIFAPHandlerTest {

	private static final Integer NUMBER_OF_RECORDS = 1;

	@testSetup static void setup(){

		List<Contact> contactList = new List<Contact>();
		List<User> userList = new List<User>();
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'];

		User thisUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		System.runAs (thisUser) {
			IATA_ISO_Country__c testcountry = new IATA_ISO_Country__c(Name = 'Canada', ISO_Code__c = 'TS',
															Region__c = 'Americas', AIMS_Area_ID__c = 'A'
															);

			insert testcountry;

			Account acc = new Account(Name = 'Test Acc', IATACode__c = '85101400005', Site ='85101400005 PT', Type = 'IATA Passenger Sales Agent',
									IATA_ISO_Country__c = testcountry.id, Location_Type__c = AMS_Utils.HO, Location_Class__c = AMS_Utils.LC_PASSENGER,
									RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,  BillingCity = 'test', BillingCountry = 'Canada',
									BillingStreet = 'some street', Has_a_Financial_Assessment_Contact_Sum__c = true);

			insert acc;

			for(Integer i = 0; i < NUMBER_OF_RECORDS; i++){

				contactList.add(new Contact(AccountId = acc.Id, Salutation = 'Mr.', FirstName = 'Test'+i,
											LastName = 'TEST', MailingCity = 'City', MailingState = 'State',
											Email = 'cont'+i+'@email.com', Status__c = 'Active', Financial_Assessment_Contact__c = true,
											ID_Card_Preferred_Language__c = 'en_us', Available_Services__c = 'IFAP',
											CanAllowPortalSelfReg = true));
			}

			insert contactList;

			for(Integer i = 0; i < NUMBER_OF_RECORDS; i++){

				userList.add(ISSP_ObjectFactory.createPortalUser(contactList[i]));
			}
		}
	}
	@isTest
	static void getContactInfoForUsersTest() {

		List<User> userList = new List<User>([SELECT Id FROM User WHERE Contact.LastName = 'TEST' LIMIT 1]);
		List<String> listIds = new List<String>();
		String body = '{"errors": [{"status": "400","title": "BAD_REQUEST","detail": "Error validating JSON. Error: - Invalid type Integer, expected String for state"}]}';

		ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(200,
												 'Complete',
												 'body',
												 null);

		Test.setMock(HttpCalloutMock.class, fakeResponse);

		Test.startTest();

		for(User us : userList){
			listIds.add(us.Id);
		}

		List<String> result = CaseIFAPHandler.getContactInfo(listIds);

		Test.stopTest();
		System.assertEquals('The status code returned was not expected: 500 - Error connecting to GXA system api', result[0]);
	}

	@isTest
	static void getContactInfoForCaseTest() {

		Id AccId = [SELECT Id from Account Limit 1].Id;
		Id ContId = [SELECT Id from Contact Limit 1].Id;
		List<Case> caseList = new List<Case>();

		List<User> userList = new List<User>();
		List<Case> cases = new List<Case>([SELECT Id FROM Case]);
		List<String> listIds = new List<String>();
		String body = '{"errors": [{"status": "400","title": "BAD_REQUEST","detail": "Error validating JSON. Error: - Invalid type Integer, expected String for state"}]}';

		ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(400,
												 'Complete',
												 body,
												 null);

		Test.setMock(HttpCalloutMock.class, fakeResponse);

		Test.startTest();

		for(Integer i = 0; i < NUMBER_OF_RECORDS; i++){
			caseList.add(new Case(RecordTypeID = AMS_Utils.RECTYPE_IFAP, Subject = 'IFAP', Status = 'Agent to be Notified', AccountId = accId,
								  Origin = 'Agent Financial Review Notification', ContactId = contId, Financial_Review_Type__c = 'Annual',
								  IFAP_Financial_Year__c = '201'+i, Deadline_Date__c = date.today().addDays(31), IFAP_Area__c = 'A'));
		}

		insert caseList;

		for(Case cs : caseList){
			listIds.add(cs.Id);
		}

		List<String> result = CaseIFAPHandler.getContactInfo(listIds);
		Test.stopTest();

		System.assertEquals(0, result.size());
	}


	@isTest
	static void getContactInfoForCaseErrorTest() {

		Id AccId = [SELECT Id from Account Limit 1].Id;
		Id ContId = [SELECT Id from Contact Limit 1].Id;
		List<Case> caseList = new List<Case>();

		List<User> userList = new List<User>();
		List<Case> cases = new List<Case>([SELECT Id FROM Case]);
		List<String> listIds = new List<String>();
		String body = '{"apiStatus": {"transactionId": "ac26fd60-103c-11ea-8586-06e8b32e1e4c","api": "","code": "500","description": "Error connecting to GXA system api","title": "TARGET_SYSTEM_CONNECTIVITY"}}';

		ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(500,
												 'Complete',
												 body,
												 null);

		Test.setMock(HttpCalloutMock.class, fakeResponse);

		Test.startTest();

		for(Integer i = 0; i < NUMBER_OF_RECORDS; i++){
			caseList.add(new Case(RecordTypeID = AMS_Utils.RECTYPE_IFAP, Subject = 'IFAP', Status = 'Agent to be Notified', AccountId = accId,
								  Origin = 'Agent Financial Review Notification', ContactId = contId, Financial_Review_Type__c = 'Annual',
								  IFAP_Financial_Year__c = '201'+i, Deadline_Date__c = date.today().addDays(31), IFAP_Area__c = 'A'));
		}

		insert caseList;

		for(Case cs : caseList){
			listIds.add(cs.Id);
		}

		List<String> result = CaseIFAPHandler.getContactInfo(listIds);

		Test.stopTest();

		System.assertEquals(0, result.size());
	}

	@isTest
	static void getContactInfoForUsersErrorTest() {

		List<User> users = new List<User>([SELECT Id FROM User WHERE Contact.LastName = 'TEST' LIMIT 1]);
		List<Id> listIds = new List<Id>();

		Id AccId = [SELECT Id from Account Limit 1].Id;
		Id ContId = [SELECT Id from Contact Limit 1].Id;
		Case cs = new Case(RecordTypeID = AMS_Utils.RECTYPE_IFAP, Subject = 'IFAP', Status = 'Agent to be Notified', AccountId = accId,
								  Origin = 'Agent Financial Review Notification', ContactId = contId, Financial_Review_Type__c = 'Annual',
								  IFAP_Financial_Year__c = '2016', Deadline_Date__c = date.today().addDays(31), IFAP_Area__c = 'A');
		insert cs;

		String body = '{"apiStatus": {"transactionId": "ac26fd60-103c-11ea-8586-06e8b32e1e4c","api": "","code": "500","description": "Error connecting to GXA system api","title": "TARGET_SYSTEM_CONNECTIVITY"}}';

		ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(500,
												 'Complete',
												 body,
												 null);

		Test.setMock(HttpCalloutMock.class, fakeResponse);

		Test.startTest();

		for(User us : users){
			listIds.add(us.Id);
		}

		List<String> result = CaseIFAPHandler.getContactInfo(listIds);

		Test.stopTest();

		System.assertEquals('The status code returned was not expected: 500 - Error connecting to GXA system api', result[0]);
	}
}