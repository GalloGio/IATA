global class ANG_CalloutIEPMasterdata implements ANG_CalloutHelperInt {


	global static String fetchEndPoint(String endPoint){

		// dummy method, we don't need to do nothing in this instance.

		return endPoint;
	}

	global static String serializeData(Object obj){

		Account acct = (Account)obj;

		IEPMasterDataPayload payloadBody = new IEPMasterDataPayload(acct.IATACode__c, false);

		return JSON.serialize(payloadBody);

	}
	
	global static void doCallOut(Object obj, String endpoint){
		
		String body = serializeData(obj);

		sendCallout(body,endpoint);

	}

	@future (callout=true)
	private static void sendCallout(String body, String endpoint){

		HttpRequest req = new HttpRequest(); 
	 
		//Set HTTPRequest Method
		req.setMethod('PUT');

		//Set HTTPRequest header properties
		req.setHeader('content-type', 'application/json;charset=UTF-8');
		req.setHeader('Connection','keep-alive');
		req.setEndpoint(fetchEndPoint(endpoint));

		//Set the HTTPRequest body	

		req.setBody(body); 	

		Http http = new Http();

		//Execute web service call here		
		HTTPResponse res = http.send(req);	

		//Helpful debug messages
		System.debug(res.toString());

		System.debug('STATUS:'+res.getStatus());
		System.debug('STATUS_CODE:'+res.getStatusCode());

		if(res.getStatusCode() != ANG_IEP_CalloutHelper.STATUSOK)
			throw new AMS_ApplicationException('ANG_CalloutIEPMasterdata: The masterdata could not be sent to IEP. Status:' + res.getStatusCode() + ' - Reason:'+ res.getStatus());

	}


	private class IEPMasterDataPayload {

		String  AccountIATACode;
		Boolean AllHierarchy;

		public IEPMasterDataPayload(String iataCode, Boolean allHierarchyb){
			
			this.AccountIATACode = iataCode;
			this.allHierarchy = allHierarchyb;
		
		}

	}

}