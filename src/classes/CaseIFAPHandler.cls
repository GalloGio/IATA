/*
 	Class Name: CaseIFAPHandler

 	Copyright © IATA

 	Purpose: This class aims to do the user provisioning to Mulesoft when an IFAP case is created or for Cargo

 	VERSION     AUTHOR        	DATE          	DETAIL/CHANGE REFERENCE
 	1.0 -	    João Santos     31/10/2019    	INITIAL DEVELOPMENT
*/

public class CaseIFAPHandler {

	public static boolean isUser;

	@InvocableMethod(label='User provisioning IFAP' description='User provisioning for Mulesoft when IFAP case is created.')
	public static List<String> getContactInfo(List<Id> listIds) {
		Set<Id> contactIds = new Set<Id>();
		List<String> returnList = new List<String>();
		List<Case> caseList = new List<Case>();

		if(listIds != null && listIds.size() != 0){

			switch on (String.valueOf(listIds[0].getSObjectType())) {
  				when 'User' {
					List<User> userList = new List<User>([SELECT ContactId FROM User WHERE Id IN: listIds AND ContactId != null]);
					for(User us : userList){
						contactIds.add(us.ContactId);
					}

					isUser = true;
				}
				when 'Case'{
					// get information about Company and Case
					caseList = new List<Case>([SELECT ContactId, Account.Name, Account.Global_ID__c, Account.Agent_Type_Code__c, Account.Airline_Code__c, Account.Status__c,
										Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.IATA_ISO_Country__r.Name,
										Account.IATACode__c, IFAP_Country_ISO__c, Financial_Review_Type__c, CaseNumber
								FROM Case
								WHERE Id =: listIds AND ContactId != null]);

					for(case cs : caseList){
						contactIds.add(cs.ContactId);
					}

					isUser = false;
				}
				when else{
					returnList.add('The object type in the parameter is not supported.');
					return returnList;
				}
			}

			if(contactIds.size() > 0){
				if(isUser){
					returnList = buildJSON(contactIds, null);
				}
				else{
					returnList = buildJSON(contactIds, caseList);
				}

			}
			else{
				returnList.add('Unable to find Contacts related to input parameter');
			}
		}
		else{

			returnList.add('Invalid input parameters');
		}

		return returnList;
	}

	private static List<String> buildJSON(Set<Id> contactIds, List<Case> caseList){
		List<User> userList;
		List<WrapperUserForJSON> wrapperListUser = new List<WrapperUserForJSON>();
		List<WrapperCompanyForJSON> wrapperListCompany = new List<WrapperCompanyForJSON>();
		List<WrapperCaseForJSON> wrapperListCase = new List<WrapperCaseForJSON>();
		List<WrapperUserRoleForJSON> wrapperListUserRole = new List<WrapperUserRoleForJSON>();
		List<String> mulesoftResult = new List<String>();

		if(contactIds.size() > 0){
			// get information about Contact/User
			userList = new List<User>([SELECT id, Contact.Name, Contact.Salutation, Contact.FirstName, Contact.LastName, Contact.MailingCity, Contact.MailingState, Contact.Email, Contact.Status__c,
													Contact.Account.Global_ID__c, Contact.Account.IATACode__c, Contact.ID_Card_Preferred_Language__c, Contact.IATA_ISO_Billing_State__r.Name, Username
													FROM user WHERE ContactId IN :contactIds]);

			if(Test.isRunningTest() && userList.isEmpty()){
				userList = new List<User>{new User(Alias = 'test', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8',
												   LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US',
													TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com')};
			}

			if(caseList == null){

				Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IATA Financial Review').getRecordTypeId();

				caseList = new List<Case>([SELECT ContactId, Account.Name, Account.Global_ID__c, Account.Agent_Type_Code__c, Account.Airline_Code__c, Account.Status__c,
										Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.IATA_ISO_Country__r.Name,
										Account.IATACode__c, IFAP_Country_ISO__c, Financial_Review_Type__c, CaseNumber
								FROM Case
								WHERE ContactId IN :contactIds AND RecordTypeId =: recordTypeId]);

			}
		}

		if(userList.size() > 0){
			for(User us : userList){

				wrapperListUser.add(new WrapperUserForJSON(us));
				// remove if Mulesoft supports multiple requests in 1 JSON
				break;
			}
		}

		// only execute if the imput parameter is a case
		if(caseList != null && caseList.size() > 0 && userList.size() > 0){

			for(Case cs : caseList){
				// for each case
				wrapperListCompany.add(new WrapperCompanyForJSON(cs));
				wrapperListCase.add(new WrapperCaseForJSON(cs));
				wrapperListUserRole.add(new WrapperUserRoleForJSON(userList[0], cs));
				// remove if Mulesoft supports multiple requests in 1 JSON
				break;
			}
		}

		String stringToSend;
		if(isUser){
			// remove substring if Mulesoft supports multiple requests in 1 JSON
			if(!wrapperListUser.isEmpty()){
				// serielize all the JSONs into a string
				stringToSend = JSON.serialize(wrapperListUser);
				mulesoftResult.add(sendJSON(stringToSend.substring(1, stringToSend.length()-1),'users'));
			}
			else{
				mulesoftResult.add('Unable to query information on Users');
			}
			if(!wrapperListCompany.isEmpty()){
				// serielize all the JSONs into a string
				stringToSend = JSON.serialize(wrapperListCompany);
				mulesoftResult.add(sendJSON(stringToSend.substring(1, stringToSend.length()-1),'accounts'));
			}
			else {
				mulesoftResult.add('Unable to query information on Companies');
			}
			if(!wrapperListUserRole.isEmpty()){
				// serielize all the JSONs into a string
				stringToSend = JSON.serialize(wrapperListUserRole);
				mulesoftResult.add(sendJSON(stringToSend.substring(1, stringToSend.length()-1),'roles'));
			}
			else {
				mulesoftResult.add('Unable to query information on User Roles');
			}
			if(!wrapperListCase.isEmpty()){
				// serielize all the JSONs into a string
				stringToSend = JSON.serialize(wrapperListCase);
				mulesoftResult.add(sendJSON(stringToSend.substring(1, stringToSend.length()-1),'cases'));
			}
			else {
				mulesoftResult.add('Unable to query information on Cases');
			}
		}
		else {
			if(Test.isRunningTest() && (System.IsBatch() || System.isFuture())){
				return mulesoftResult;
			}
			else{
				// remove substring if Mulesoft supports multiple requests in 1 JSON
				if(!wrapperListUser.isEmpty()){
					stringToSend = JSON.serialize(wrapperListUser);
					sendJSONFuture(stringToSend.substring(1, stringToSend.length()-1),'users');
				}
				else{
					mulesoftResult.add('Unable to query information on Users');
				}
				if(!wrapperListCompany.isEmpty()){
					stringToSend = JSON.serialize(wrapperListCompany);
					sendJSONFuture(stringToSend.substring(1, stringToSend.length()-1),'accounts');
				}
				else {
					mulesoftResult.add('Unable to query information on Companies');
				}
				if(!wrapperListUserRole.isEmpty()){
					stringToSend = JSON.serialize(wrapperListUserRole);
					sendJSONFuture(stringToSend.substring(1, stringToSend.length()-1),'roles');
				}
				else {
					mulesoftResult.add('Unable to query information on User Roles');
				}
				if(!wrapperListCase.isEmpty()){
					stringToSend = JSON.serialize(wrapperListCase);
					sendJSONFuture(stringToSend.substring(1, stringToSend.length()-1),'cases');
				}
				else {
					mulesoftResult.add('Unable to query information on Cases');
				}
			}
		}

		return mulesoftResult;
	}

	@future(callout=true)
	private static void sendJSONFuture(String JSONString, String endpoint){
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		String responseString;
		String responseCode;

		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		// endpoint, username and password defined in Mulesoft_GXA_Credentials
		request.setEndpoint('callout:Mulesoft_GXA_Credentials/' + endpoint);
		request.setMethod('POST');

		// Set the body as a JSON object
		request.setBody(JSONString);


		HttpResponse response;

		// when other Test Classes are running create mock response
		if(Test.isRunningTest()){
			String body = '{"apiStatus": {"api": "INT_220","code": "200","description": "Updated","transactionId": "4dd8f6c0-644f-11ea-8376-06359351e052","title": "Success"}}';

			response = new HttpResponse();
			response.setStatus('Complete');
			response.setStatusCode(500);
			response.setBody(body);
		}
		else{
			response = http.send(request);
		}
	}

	private static String sendJSON(String JSONString, String endpoint){

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		String responseString;
		String responseCode;

		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		// endpoint, username and password defined in Mulesoft_GXA_Credentials
		request.setEndpoint('callout:Mulesoft_GXA_Credentials/' + endpoint);
		request.setMethod('POST');

		// Set the body as a JSON object
		request.setBody(JSONString);

		HttpResponse response;

		if(Test.isRunningTest()){
			String body = '{"apiStatus": {"transactionId": "ac26fd60-103c-11ea-8586-06e8b32e1e4c","api": "","code": "500","description": "Error connecting to GXA system api","title": "TARGET_SYSTEM_CONNECTIVITY"}}';

			ISSP_AMC_MockHttp_Response_generator fakeResponse = new ISSP_AMC_MockHttp_Response_generator(500,
													 'Complete',
													 body,
													 null);

			Test.setMock(HttpCalloutMock.class, fakeResponse);

			response = new HttpResponse();
			response.setStatus('Complete');
			response.setStatusCode(500);
			response.setBody(body);
		}
		else{
			response = http.send(request);
		}

		// Parse the JSON response
		if (response.getStatusCode() != 200) {

			Error1Class responseValue = new Error1Class();
			responseValue = (Error1Class)System.JSON.deserialize(response.getBody(), Error1Class.class);

			if(responseValue.errors != null){

				responseString = responseValue.errors.get(0).detail;
				responseCode = responseValue.errors.get(0).status;
			}
			else{
				JSONParser parser = JSON.createParser(response.getBody());
				while (parser.nextToken() != null) {
					if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
						String fieldName = parser.getText();
						parser.nextToken();

						if(fieldName == 'description'){
							responseString = parser.getText();
						}
						else if(fieldName == 'code'){
							responseCode = parser.getText();
						}
					}
				}

			}

			return 'The status code returned was not expected: ' + responseCode + ' - ' + responseString;

		} else {
			return 'The connection with Mulesoft was successfully';
		}
	}

	public static String protectNullValues(String field){
		return (field != null) ? field : '';
	}

	public class WrapperUserForJSON{

		public String firstName { get; set; }
		public String lastName { get; set; }
		public String fullName { get; set; }
		public String salutation { get; set; }
		public String city { get; set; }
		public String state { get; set; }
		public String preferredLanguage { get; set; }
		public String emailId { get; set; }
		public String salesForceClientNumber { get; set; }
		public String contactStatus { get; set; }
		public String salesForceUserEmailId { get; set; }

		public WrapperUserForJSON(User user){

			// Mulesoft doesn't accept null value
			firstName = protectNullValues(user.Contact.FirstName);
			lastName = protectNullValues(user.Contact.LastName);
			fullName = protectNullValues(user.Contact.Name);
			salutation = protectNullValues(user.Contact.Salutation);
			city = protectNullValues(user.Contact.MailingCity);
			state = protectNullValues(user.Contact.IATA_ISO_Billing_State__r.Name);
			emailId = protectNullValues(user.Contact.Email);
			salesForceClientNumber = isUser ? protectNullValues(user.Contact.Account.IATACode__c) : protectNullValues(user.Contact.Account.Global_ID__c);
			contactStatus = protectNullValues(user.Contact.Status__c);
			preferredLanguage = protectNullValues(user.Contact.ID_Card_Preferred_Language__c).toLowerCase();
			// used substring because getOrganizationId returns 18 digits and the SSO uses 15 for the Company Id
			salesForceUserEmailId = UserInfo.getOrganizationId().substring(0, 15) + '@' + protectNullValues(user.Username);
		}
	}

	public class WrapperCompanyForJSON{

		public String salesForceClientName {get;set;}
		public String salesForceClientNumber {get;set;}
		public String agentType {get;set;}
		public String agentCode {get;set;}
		public String clientStatus {get;set;}
		public String street {get;set;}
		public String city {get;set;}
		public String zip {get;set;}
		public String country {get;set;}

		public WrapperCompanyForJSON(Case cs){

			salesForceClientName = protectNullValues(cs.Account.Name);
			salesForceClientNumber = isUser ? protectNullValues(cs.Account.Global_ID__c) : protectNullValues(cs.Account.IATACode__c);
			agentType = isUser ? '' : protectNullValues(cs.Account.Agent_Type_Code__c);
			agentCode = isUser ? '' : protectNullValues(cs.Account.IATACode__c);
			clientStatus = protectNullValues('Active');
			street = protectNullValues(cs.Account.BillingStreet);
			city = protectNullValues(cs.Account.BillingCity);
			zip = protectNullValues(cs.Account.BillingPostalCode);
			country = protectNullValues(cs.Account.IATA_ISO_Country__r.Name);
		}
	}

	public class WrapperCaseForJSON{

		public String businessType {get;set;}
		public String salesForceClientNumber {get;set;}
		public String countryCode {get;set;}
		public String paxCode {get;set;}
		public String reviewType {get;set;}
		public String salesforceCaseNumber {get;set;}

		public WrapperCaseForJSON(Case cs){

			businessType = isUser ? 'SF' : 'TA';
			salesForceClientNumber = isUser ? protectNullValues(cs.Account.Global_ID__c) : protectNullValues(cs.Account.IATACode__c);
			countryCode = isUser ? '' : protectNullValues(cs.IFAP_Country_ISO__c);
			paxCode = isUser ? '' : protectNullValues(cs.Account.Agent_Type_Code__c);
			reviewType = isUser ? '' : protectNullValues(cs.Financial_Review_Type__c);
			salesforceCaseNumber = protectNullValues(cs.CaseNumber);
		}
	}

	public class WrapperUserRoleForJSON{

		public String salesForceUserEmailId {get;set;}
		public String roleName {get;set;}
		public String emailId {get;set;}
		public String salesforceClientNumber {get;set;}
		public String roleStatus {get;set;}

		public WrapperUserRoleForJSON(User us, Case cs){

			// used substring because getOrganizationId returns 18 digits and the SSO uses 15 for the Company Id
			salesForceUserEmailId = UserInfo.getOrganizationId().substring(0, 15) + '@' + protectNullValues(us.Username);
			roleName = '';
			emailId = protectNullValues(us.Contact.Email);
			salesForceClientNumber = isUser ? protectNullValues(cs.Account.Global_ID__c) : protectNullValues(cs.Account.IATACode__c);
			roleStatus = protectNullValues('Active');
		}
	}

	public class Error1Class{
		public List<ErrorClass> errors {get;set;}
	}

	private class ErrorClass{
		public String status {get;set;}
		public String title {get;set;}
		public String detail {get;set;}
	}
}