public class IECEBC_ETEmailSend {
	/*class UnexpectedResponse_Exception extends Exception{
		public String ErrorMessage {get; set;}
	}*/

	public static Map<String, String> failureDetails;

	// send single email
	public static void sendSingleEmail(String TriggeredParam, String subscriberKey, Map<String, String> attributes){
		sendMassEmail(TriggeredParam, new Map<String, Map<String, String>>{
			subscriberKey => attributes
		});
	}
	public static void sendMassEmail(String TriggeredParam, Map<String, Map<String, String>> recipients){
		//String email, Map<String, String> attributes
		HttpRequest req = new HttpRequest();
		Http http = new Http();
		String tags ='';

		for(String subscriberKey : recipients.keySet()) {
			Map<String, String> attributes = recipients.get(subscriberKey);
			tags +='<Subscribers>'
				+'<EmailAddress>'+IECEBC_ETHelper.xmlEncode(attributes.get('EMAIL'))+'</EmailAddress>'
				+'<SubscriberKey>'+IECEBC_ETHelper.xmlEncode(subscriberKey)+'</SubscriberKey>';

			for(String key : attributes.keySet()) {
				if (key == 'EMAIL') continue;

				tags+='<Attributes><Name>'+IECEBC_ETHelper.xmlEncode(key)+'</Name><Value>'+IECEBC_ETHelper.xmlEncode(attributes.get(key))+'</Value></Attributes>';
			}

			tags += '</Subscribers>';
		}

		string bodyContent =
			'<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
			+'<Options/>'
			+'<Objects xsi:type="TriggeredSend">'
			+'<TriggeredSendDefinition>'
			+'<CustomerKey>'+ IECEBC_ETHelper.xmlEncode(TriggeredParam) +'</CustomerKey>'
			+'</TriggeredSendDefinition>'
			+ tags
			+'</Objects>'
			+' </CreateRequest>';

		System.debug(bodyContent);

		req.setTimeout(IECEBC_ETInit.TimeOut);
		IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);
		// Soap response
		HTTPResponse response = null;
		String errorMessage = '', errorCode = '', displayMessage = '';
		// try and catches


	   	try{
			// send request
	 		response = http.send(req);
			// if response status 200 OK
			if (response.getStatusCode() == 200) {
				System.debug(response.getBody());
				// if status code not OK (Error)
				if (IECEBC_ETHelper.parse(response, 'StatusCode') != 'OK') {

					try {
						failureDetails = getFailuresDetails(response.getBody());
					} catch(Exception e) {
						// get errorCode and errorMessage
						errorCode = IECEBC_ETHelper.parse(response, 'ErrorCode');
						errorMessage = IECEBC_ETHelper.parse(response, 'StatusMessage');
						// Email failed validation
						if (IECEBC_ETHelper.parse(response, 'ErrorCode') == '7000') {
							displayMessage = 'Email Failed Validation: Invalid Place Holder';
							// throw InvalidPlaceHolderException
							throw new IECEBC_ExceptionHandler.InvalidPlaceHolder_Exception(errorMessage);
						}else{
							displayMessage = 'Unexpected Response';
							throw new IECEBC_ExceptionHandler.UnexpectedResponse_Exception(displayMessage);
						}
					}
				}
				// else
				system.debug('Emails are sent!');
			} else {
				System.debug(response);
				System.debug(response.getBody());
				displayMessage = 'Unexpected Response';
				throw new IECEBC_ExceptionHandler.UnexpectedResponse_Exception(displayMessage);
			}
		} catch (System.CalloutException e){
			System.debug(e);
			System.debug('ERROR:' + e);
			IECEBC_ExceptionHandler.addException('System Call out Exception', e);
		} catch (IECEBC_ExceptionHandler.InvalidPlaceHolder_Exception e){
			System.debug(e);
			// set error message
			e.ErrorMessage = IECEBC_ETHelper.parse(response, 'StatusMessage');
			// set attribute name from merge filed name in error
			e.AttributeNames = getErrorMergeFieldsNames(e.ErrorMessage);
			IECEBC_ExceptionHandler.addInvalidPlaceHolderException(displayMessage, e);
		} catch (IECEBC_ExceptionHandler.UnexpectedResponse_Exception e){
			System.debug('ERROR:' + e);
			System.debug(e);
			IECEBC_ExceptionHandler.addException(displayMessage, e);
		} finally{
		 	IECEBC_ExceptionHandler.saveExceptionLog();
		}
	}

	public static Map<String, String> getFailuresDetails(String xml) {
		Map<String, String> failures = new Map<String, String>();

		Dom.Document doc = new Dom.Document();
		doc.load(xml);

		Dom.XMLNode envelope = doc.getRootElement();
		String SOAPns = envelope.getNamespaceFor ('soap');
		String ETns = 'http://exacttarget.com/wsdl/partnerAPI';
		Dom.XMLNode body = envelope.getChildElement('Body', SOAPns);
		Dom.XMLNode createResponse = body.getChildElement('CreateResponse', ETns);
		Dom.XMLNode results = createResponse.getChildElement('Results', ETns);
		for(Dom.XMLNode child : results.getChildElements()) {
			if (child.getName() != 'SubscriberFailures') continue;

			String email = IECEBC_ETHelper.walkThrough(child, 'EmailAddress');
			String error = IECEBC_ETHelper.walkThrough(child, 'ErrorDescription');

			failures.put(email, error);
		}

		return failures;
	}

	// Send emails using : email template Id, List Id
	// @ todo in case of Plan B
	/*public static void sendEmailToList(String emailId, String listId){

		Http http = new Http();
		HttpRequest req = new HttpRequest();
		// create request body
		String  xmlRequestBody = IECEBC_ETHelper.requestSendEmailToList(emailId, listId);
		// create the soap request
		IECEBC_ETHelper.setSoapRequest(req, 'Create', xmlRequestBody);
		// Soap response
		HTTPResponse response = null;
		String errorMessage = '', errorCode = '', displayMessage = '';
		// try and catches
	   	try{
			// send request
	 		response = http.send(req);
			// if response status 200 OK
			if (response.getStatusCode() == 200) {
				// if status code not OK (Error)
				if (IECEBC_ETHelper.parse(response, 'StatusCode') != 'OK') {
					// get errorCode and errorMessage
					errorCode = IECEBC_ETHelper.parse(response, 'ErrorCode');
					errorMessage = IECEBC_ETHelper.parse(response, 'StatusMessage');
					// Email failed validation
					if (IECEBC_ETHelper.parse(response, 'ErrorCode') == '7000') {
						displayMessage = 'Email Failed Validation: Invalid Place Holder';
						// throw InvalidPlaceHolderException
						throw new IECEBC_ExceptionHandler.InvalidPlaceHolder_Exception(errorMessage);
					}else{
						displayMessage = 'Unexpected Response';
						throw new IECEBC_ExceptionHandler.UnexpectedResponse_Exception(displayMessage);
					}
				}
				// else
				system.debug('Emails are sent!');
			} else {
				displayMessage = 'Unexpected Response';
				throw new IECEBC_ExceptionHandler.UnexpectedResponse_Exception(displayMessage);
			}
		} catch (System.CalloutException e){
			System.debug('ERROR:' + e);
			IECEBC_ExceptionHandler.addException('System Call out Exception', e);
		} catch (IECEBC_ExceptionHandler.InvalidPlaceHolder_Exception e){
			// set error message
			e.ErrorMessage = IECEBC_ETHelper.parse(response, 'StatusMessage');
			// set attribute name from merge filed name in error
			e.AttributeNames = getErrorMergeFieldsNames(e.ErrorMessage);
			IECEBC_ExceptionHandler.addInvalidPlaceHolderException(displayMessage, e);
		} catch (IECEBC_ExceptionHandler.UnexpectedResponse_Exception e){
			System.debug('ERROR:' + e);
			IECEBC_ExceptionHandler.addException(displayMessage, e);
		} finally{
		 	IECEBC_ExceptionHandler.saveExceptionLog();
		}
	}*/

	// retrieve merge field Name in error from the soap response
	public static List<String> getErrorMergeFieldsNames(String statusMessage){
		statusMessage = statusMessage.replaceAll('[\n\r]', '');
		//system.debug('statusMessage 1 = ' + statusMessage);
		List<String> mergeFieldNames = new List<String>();
		statusMessage = statusMessage.substringAfter('%%');
		//system.debug('statusMessage 2 = ' + statusMessage);
		Integer len = statusMessage.length()/2;
		statusMessage = statusMessage.substring(0, len);
		//system.debug('statusMessage 3 = ' + statusMessage);
		String s2 = '';
		do{
			s2 = statusMessage.substringBefore('%%');
			//system.debug('s2 = ' + s2);
			mergeFieldNames.add(s2 + ', ');
			statusMessage = statusMessage.substringAfter('%%%%');
		}while(statusMessage.length() > 1);
		//system.debug('mergeFieldNames = ' + mergeFieldNames.size());
		return mergeFieldNames;
	}
}
