public without sharing class ServiceNow_Helper {
	public static void sendRequestToSNOWSFDC(String setting_name, Exception e, set<string> setIdInvolved){
		sendRequestToSNOW(new SNOWBody(e.getMessage()), setting_name, setIdInvolved);
	}

	public static void sendRequestToSNOWMulesoft(String setting_name, String iatacode, ISSP_Web_Service_Log__c log){
		sendRequestToSNOW(new SNOWBody(log.Error_Message__c), setting_name, iatacode==null?null:(new set<string>{iatacode}));
	}

	public static void sendRequestToSNOWRME(String setting_name, String iatacode, ISSP_Web_Service_Log__c log, ANG_RME_Alert_Service.WebserviceResult result){
		sendRequestToSNOW(new SNOWBody(String.valueOf(result)), setting_name, iatacode==null?null:(new set<string>{iatacode}));
	}

	public static void sendRequestToSNOWSAP(String setting_name, SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response response, Exception e){
		sendRequestToSNOW(new SNOWBody((response != null)?String.valueOf(response.Error.Message):((e != null)?e.getMessage():'')), setting_name, null);
	}

	public static void sendRequestToSNOW(SNOWBody theBody, string setting_name, set<string> setInvolvedItem){

			Map<String,ISSP_Int_Error__c> settings =  ISSP_Int_Error__c.getall();

			if(!settings.containsKey(setting_name)){
				theBody.description = 'WARNING: Setting ' + setting_name + ' does not exists! Error is: ' + theBody.description;
			}else{
				ISSP_Int_Error__c s = settings.get(setting_name);
				
				theBody.summary = s.Short_Description__c;
				theBody.description = s.Error_Message__c 
									  + ((setInvolvedItem==null || setInvolvedItem.isEmpty())?'<Nil>':string.join(new list<string>(setInvolvedItem), '; ')) 
									  + '. Error description: ' + theBody.description;
				theBody.impact = integer.valueOf(s.Impact__c);
				theBody.businessService = s.Business_Service__c;
				theBody.businessProcess = s.Caused_By__c;
			}
			
			theBody.errorKey = setting_name;

		if(trigger.isExecuting && !(system.isFuture() || system.isBatch())) sendRequestToSNOW_Future(setting_name, JSON.serialize(theBody));
		else if(system.isFuture() || system.isBatch()) sendRequestToSNOW_Immediate(setting_name, JSON.serialize(theBody));
		else sendRequestToSNOW_Future(setting_name, JSON.serialize(theBody));
	}

	@future(callout=true)
	private static void sendRequestToSNOW_Future(string sName, string theBody){   sendRequest(sName, theBody); }

	private static void sendRequestToSNOW_Immediate(string sName, string theBody){    sendRequest(sName, theBody); }

	private static void sendRequest(string sName, string theBody){
		HttpRequest req = new HttpRequest();
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		
		req.setTimeout(120000);
		req.setBody(theBody);
		req.setMethod('POST');
		req.setEndpoint('callout:Mulesoft_Experience_API_V1/incidents');

		Http http = new Http();
		HTTPResponse res;
		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
		log.Web_Service__c = req.getEndpoint();
		log.Input_Description__c = 'body:' + theBody;
		log.Method__c = 'POST';
		
		try{
			res = http.send(req);
		}catch(CalloutException e){
			log.Web_Service__c = String.valueOf(req);
			log.Error_Code__c = 'Exception sending request';
			log.Error_Message__c = e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage());
			log.Success__c = false;
			insert log;

			return;
		}

		try{
		  log.Response__c = res.getBody();
		}catch(exception e){log.Response__c = 'Error while getting response body: ' + e.getMessage();}

		log.Error_Code__c = String.valueOf(res.getStatusCode());
		log.Error_Message__c = res.getStatus();

		if((res.getStatusCode() > ANG_IEP_CalloutHelper.STATUSOKLOWER && res.getStatusCode() < ANG_IEP_CalloutHelper.STATUSOKHIGHER )) log.Success__c = true;
		else log.Success__c = false;

		insert log;
	}

	public class SNOWBody{
		public string summary			{get; set;}	//E.g.: "Failed to get calculated RHC",
		public string description		{get; set;}	//E.g."500 - Failed to get calculated RHC for agent 12345678"
		public integer impact			{get; set;}	//Enum {1,2,3}
		public string businessService	{get; set;}	//E.g.: RME
		public string businessProcess	{get; set;}	//E.g.: "RME - Other"
		public string errorKey			{get; set;}	//This is the key used by Mulesoft to identify an open incident in JSD. E.g.: "INT_032-SFDC-RME-400".

		public SNOWBody(string description){
			this.description = description;
		}

		public SNOWBody(){}
	}
}
