global class ANG_CalloutIEPMasterdata implements ANG_CalloutHelperInt {


	global static String fetchEndPoint(ANG_CalloutMapping__c mappingObj){

		return mappingObj.Credential__c;
	}

	global static String serializeData(Object obj){

		return String.valueOf(obj);

	}
	
	global static void doCallOut(Object obj, ANG_CalloutMapping__c mappingObj){
		
		String body = serializeData(obj);

		sendCallout(body,mappingObj.Action__c, mappingObj.Named_Credential__c, fetchEndPoint(mappingObj),mappingObj.client_id__c,mappingObj.client_secret__c);

	}

	@future (callout=true)
	private static void sendCallout(String body, String action, String namedCredential, String endPointCredential, String clientId, String clientSecret){

		HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
	 	req.setMethod(action);

		//req.setEndpoint('https://iata-agencies-process.cloudhub.io'+endPointCredential+body+'?client_id=6235b6a786ae4e6c88526cd20fd3d2d0&client_secret=d629863C84E5458dB25778e8f7351d02');
		req.setEndpoint('callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret);

		System.debug('ANG_CalloutIEPMasterdata:Callout request is:'+req);
   
        
		Http http = new Http();
		HTTPResponse res = http.send(req);	

		System.debug('ANG_CalloutIEPMasterdata: Request Status:'+res.getStatus());
		System.debug('ANG_CalloutIEPMasterdata: Request Code:'+res.getStatusCode());

		if(!(res.getStatusCode() > ANG_IEP_CalloutHelper.STATUSOKLOWER   && res.getStatusCode() < ANG_IEP_CalloutHelper.STATUSOKHIGHER ))
			throw new AMS_ApplicationException('ANG_CalloutIEPMasterdata: The masterdata could not be sent to IEP. Status:' + res.getStatusCode() + ' - Reason:'+ res.getStatus());
		else
			System.debug('ANG_CalloutIEPMasterdata: Payload sent with success.');


	}

}