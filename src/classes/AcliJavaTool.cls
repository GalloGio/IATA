public with sharing class AcliJavaTool {

	public static String testJsonResults;
	public static AmazonCredentials CREDENTIAL = AmazonCredentials.getCredentials('ACLI');

	/**
		Get ACLI file from the server using web service
	**/
	public static Response getFile() {
		System.debug(CREDENTIAL.IAS_endpoint);
		System.debug(CREDENTIAL.IAS_configurationName);
		try {
			WSAcliJavaTool.AcliJavaTool app = new WSAcliJavaTool.AcliJavaTool();
			app.endpoint_x = CREDENTIAL.IAS_endpoint;
			String result = Test.isRunningTest()?
				testJsonResults:
				app.getFileFromServer(CREDENTIAL.IAS_configurationName);
			return new Response(result);
		}catch ( Exception e ) {
			return new Response(e);
		}
	}

	/**
		Delete ACLI file in the server using web service
	**/
	public static Response deleteFile() {
		System.debug(CREDENTIAL.IAS_endpoint);
		System.debug(CREDENTIAL.IAS_configurationName);
		try {
			WSAcliJavaTool.AcliJavaTool app = new WSAcliJavaTool.AcliJavaTool();
			app.endpoint_x = CREDENTIAL.IAS_endpoint;
			String result = Test.isRunningTest()?
				testJsonResults:
				app.deleteFileFromServer(CREDENTIAL.IAS_configurationName);
			return new Response(result);
		}catch ( Exception e ) {
			return new Response(e);
		}
	}

	/**
		Class to store a function response
		Parse input string as Json. Example:
			{"success":"0","code":"CONF_FILE_NOT_FOUND","message":"Configuration file[fakeFile.ini] not found","response":"to what?"}
	**/
	public class Response {
		public Boolean success{get;set;}
		public String code{get;set;}
		public String message{get;set;}
		public String content{get;set;}

		public Response(String jsonString) {
			success = false;
			JSONParser parser = JSON.createParser(jsonString);
			while (parser.nextToken() != null) {
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
					String fieldName = parser.getText();
					parser.nextToken();
					if (parser == null) {

					} else if(fieldName == 'success') {
						success = parser.getBooleanValue();
					} else if(fieldName == 'code'){
						code = parser.getText();
					} else if(fieldName == 'message'){
						message = parser.getText();
					} else if(fieldName == 'content'){
						content = parser.getText();
					}
				}
			}
		}

		public Response( Exception e) {
			success = false;
			code = 'IFAP Tool Error'; // to do remove the second part here
			message = e.getMessage(); //+ e.getStackTraceString();
		}

		public override String toString() {
			if (success) {
				return 'SUCCESS '  + content;
			}
			return 'ERROR [' + code + '] ' + message;
		}
	}

}
