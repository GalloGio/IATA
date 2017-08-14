global class ANG_CalloutIEPMasterdata implements ANG_CalloutHelperInt {


	global static String fetchEndPoint(ANG_CalloutMapping__c mappingObj){

		return mappingObj.Credential__c;
	}

	global static String serializeData(Object obj){

		return String.valueOf(obj);

	}
	
	global static void doCallOut(Object obj, ANG_CalloutMapping__c mappingObj, String changeCodeId){
		
		String body = serializeData(obj);

		sendCallout(body,mappingObj.Action__c, mappingObj.Named_Credential__c, fetchEndPoint(mappingObj),mappingObj.client_id__c,mappingObj.client_secret__c,changeCodeId);

	}

	@future (callout=true)
	private static void sendCallout(String body, String action, String namedCredential, String endPointCredential, String clientId, String clientSecret, String changeCodeId){

		HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
	 	req.setMethod(action);
	 	req.setTimeout(120000);
		//req.setEndpoint('https://iata-agencies-process.cloudhub.io'+endPointCredential+body+'?client_id=6235b6a786ae4e6c88526cd20fd3d2d0&client_secret=d629863C84E5458dB25778e8f7351d02');
		req.setEndpoint('callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret);

		System.debug('ANG_CalloutIEPMasterdata:Callout request is:'+req);
   
        
		Http http = new Http();
		HTTPResponse res;

		try{
			res = http.send(req);	
		}catch(CalloutException e){
			System.debug('ANG_CalloutIEPMasterdata: Exception:'+e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage()));
			ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();log.Agency_Applied_Change_code__c = changeCodeId;log.Web_Service__c = 'callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret;log.Method__c = action;
			log.Web_Service__c = String.valueOf(req);log.Error_Code__c = 'Exception sending request';log.Error_Message__c = e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage());log.Success__c = false;insert log;return;
		}

		System.debug('ANG_CalloutIEPMasterdata: Request Status:'+res.getStatus());
		System.debug('ANG_CalloutIEPMasterdata: Request Code:'+res.getStatusCode());

		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();

		log.Agency_Applied_Change_code__c = changeCodeId;
		log.Web_Service__c = 'callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret;
		log.Method__c = action;
		log.Web_Service__c = String.valueOf(req);


		if(!(res.getStatusCode() > ANG_IEP_CalloutHelper.STATUSOKLOWER   && res.getStatusCode() < ANG_IEP_CalloutHelper.STATUSOKHIGHER )){
			System.debug('ANG_CalloutIEPMasterdata: Payload could not be sent with success.');
			//throw new AMS_ApplicationException('ANG_CalloutIEPMasterdata: The masterdata could not be sent to IEP. Status:' + res.getStatusCode() + ' - Reason:'+ res.getStatus());
			log.Error_Code__c = String.valueOf(res.getStatusCode());
			log.Error_Message__c = res.getStatus();
			log.Success__c = false;
		}
		else{
			System.debug('ANG_CalloutIEPMasterdata: Payload sent with success.');
			log.Success__c = true;
		}

		insert log;


	}

}