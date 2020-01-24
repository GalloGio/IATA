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

		if(listIds != null && listIds.size() != 0){

			switch on (String.valueOf(listIds[0].getSObjectType())) {
  				when 'User' {
					List<User> userList = new List<User>([SELECT ContactId FROM User WHERE Id =: listIds AND ContactId != null]);

					for(User us : userList){
						contactIds.add(us.ContactId);
					}

					isUser = true;
				}
				when 'Case'{
					List<Case> caseList = new List<Case>([SELECT ContactId FROM Case WHERE Id =: listIds AND ContactId != null]);

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

				returnList.add(buildJSON(contactIds));
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

	private static String buildJSON(Set<Id> contactIds){

		List<User> userList;
		List<WrapperForJSON> wrapperList = new List<WrapperForJSON>();

		if(contactIds.size() > 0){

			userList = new List<User>([SELECT id, Contact.Salutation, Contact.FirstName, Contact.LastName, Contact.MailingCity, Contact.MailingState, Contact.Email, Contact.Status__c,
													Contact.Account.Global_ID__c, Contact.ID_Card_Preferred_Language__c, Contact.IATA_ISO_Billing_State__r.Name, Username
													FROM user WHERE ContactId IN :contactIds]);
		}

		if(userList.size() > 0){

			for(User us : userList){

				wrapperList.add(new WrapperForJSON(us));
				// remove if Mulesoft supports multiple requests in 1 JSON
				break;
			}

			// serielize all the JSONs into a string
			String stringToSend = JSON.serialize(wrapperList);

			String mulesoftResult;

			if(isUser){
				// remove substring if Mulesoft supports multiple requests in 1 JSON
				mulesoftResult = sendJSON(stringToSend.substring(1, stringToSend.length()-1));
			}
			else {
				// remove substring if Mulesoft supports multiple requests in 1 JSON
				sendJSONFuture(stringToSend.substring(1, stringToSend.length()-1));
			}


			return mulesoftResult;

		}
		else{
			return 'Unable to query information to build the JSON message';
		}
	}

	@future(callout=true)
	private static void sendJSONFuture(String JSONString){

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		String responseString;
		String responseCode;

		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		// endpoint, username and password defined in Mulesoft_GXA_Credentials
		request.setEndpoint('callout:Mulesoft_GXA_Credentials/users');
		request.setMethod('POST');

		// Set the body as a JSON object
		request.setBody(JSONString);

		HttpResponse response = http.send(request);

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
		}
	}

	private static String sendJSON(String JSONString){

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		String responseString;
		String responseCode;

		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		// endpoint, username and password defined in Mulesoft_GXA_Credentials
		request.setEndpoint('callout:Mulesoft_GXA_Credentials/users');
		request.setMethod('POST');

		// Set the body as a JSON object
		request.setBody(JSONString);

		HttpResponse response = http.send(request);

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

	public class WrapperForJSON{

		public String firstName { get; set; }
		public String lastName { get; set; }
		public String salutation { get; set; }
		public String city { get; set; }
		public String state { get; set; }
		public String preferredLanguage { get; set; }
		public String emailId { get; set; }
		public String salesForceClientNumber { get; set; }
		public String contactStatus { get; set; }
		public String salesForceUserEmailId { get; set; }

		public WrapperForJSON(User user){

			// Mulesoft doesn't accept null value
			firstName = user.Contact.FirstName;
			lastName = user.Contact.LastName;
			salutation = (user.Contact.Salutation != null) ? user.Contact.Salutation : '';
			city = (user.Contact.MailingCity != null) ? user.Contact.MailingCity : '';
			state = (user.Contact.IATA_ISO_Billing_State__r.Name != null) ? user.Contact.IATA_ISO_Billing_State__r.Name : '';
			emailId = user.Contact.Email;
			salesForceClientNumber = (user.Contact.Account.Global_ID__c != null) ? user.Contact.Account.Global_ID__c : '';
			contactStatus = user.Contact.Status__c;
			preferredLanguage = user.Contact.ID_Card_Preferred_Language__c.toLowerCase();
			salesForceUserEmailId = user.Username;
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