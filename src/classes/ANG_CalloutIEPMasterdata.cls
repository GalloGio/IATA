global class ANG_CalloutIEPMasterdata implements ANG_CalloutHelperInt {


	global static String fetchEndPoint(ANG_CalloutMapping__c mappingObj){

		return mappingObj.Credential__c;
	}

	global static String serializeData(Object obj){

		//return null;

		Account acct = (Account)obj;

		return acct.IATACode__c;

		/*
		IEPMasterDataPayload payloadBody = new IEPMasterDataPayload(acct.IATACode__c, false);

		return JSON.serialize(payloadBody);
		*/

	}
	
	global static void doCallOut(Object obj, ANG_CalloutMapping__c mappingObj){
		
		String body = serializeData(obj);

		sendCallout(body,mappingObj.Action__c, mappingObj.Named_Credential__c, mappingObj.Credential__c);

	}

	@future (callout=true)
	private static void sendCallout(String body, String action, String namedCredential, String endPointCredential){

		HttpRequest req = new HttpRequest(); 
	 	req.setMethod(action);
		req.setEndpoint('callout:'+namedCredential+endPointCredential+body);
		Http http = new Http();
		HTTPResponse res = http.send(req);	

        System.debug(res.toString());

		System.debug('sendCallout STATUS:'+res.getStatus());
		System.debug('sendCallout STATUS_CODE:'+res.getStatusCode());

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