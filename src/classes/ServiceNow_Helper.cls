public without sharing class ServiceNow_Helper {
	public static void sendRequestToSNOWSFDC(String setting_name, Exception e){
		SNOWBody theBody = new SNOWBody();

		theBody.description = e.getMessage();

		sendRequestToSNOW(theBody, setting_name);
	}

	public static void sendRequestToSNOWMulesoft(String setting_name, String iatacode, ISSP_Web_Service_Log__c log){
		SNOWBody theBody = new SNOWBody();

		theBody.short_description = iatacode+' - '+log.Error_Code__c;
		theBody.description = log.Error_Message__c;

		sendRequestToSNOW(theBody, setting_name);
	}

	public static void sendRequestToSNOWRME(String setting_name, String iatacode, ISSP_Web_Service_Log__c log, ANG_RME_Alert_Service.WebserviceResult result){
		SNOWBody theBody = new SNOWBody();

		theBody.short_description = iatacode+' - '+log.Error_Code__c;
		theBody.description = String.valueOf(result);

		sendRequestToSNOW(theBody, setting_name);
	}

	public static void sendRequestToSNOWSAP(String setting_name, SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response response, Exception e){
		SNOWBody theBody = new SNOWBody();

		if(response != null) theBody.description = String.valueOf(response.Error.Message);
		else if(e != null) theBody.description = e.getMessage();

		sendRequestToSNOW(theBody, setting_name);
	}

	public static void sendRequestToSNOW(SNOWBody theBody, string setting_name){

			Map<String,ISSP_Int_Error__c> settings =  ISSP_Int_Error__c.getall();

			if(!settings.containsKey(setting_name)){
				System.debug(LoggingLevel.Error, '[ServiceNow_Helper - sendRequestToSNOW] - SNOW incident not created: missing '+setting_name+' ISSP_Int_Error__c configuration');
				return;
			}

			ISSP_Int_Error__c s = settings.get(setting_name);

			theBody.caused_by = s.caused_by__c;
			theBody.u_issue_identified_by = s.u_issue_identified_by__c;
			theBody.u_operation_name = s.Name;
			theBody.u_application = s.u_application__c;
			theBody.business_service = s.business_service__c;
			theBody.impact = s.impact__c;
			theBody.urgency = s.urgency__c;
			theBody.severity = s.severity__c;
			theBody.category = s.category__c;
			theBody.subcategory = s.subcategory__c;
			theBody.caller_id = s.caller_id__c;
			theBody.opened_by = s.opened_by__c;
			theBody.u_business_service = s.u_business_service__c;
			theBody.assignment_group = s.assignment_group__c;
			theBody.contact_type = s.contact_type__c;
			if(String.isBlank(theBody.short_description)) theBody.short_description = s.short_description__c;

		if(trigger.isExecuting && !(system.isFuture() || system.isBatch())) sendRequestToSNOW_Future(s.Name, JSON.serialize(theBody));
		else if(system.isFuture() || system.isBatch()) sendRequestToSNOW_Immediate(s.Name, JSON.serialize(theBody));
		else sendRequestToSNOW_Future(s.Name, JSON.serialize(theBody));
	}


	@future(callout=true)
	private static void sendRequestToSNOW_Future(string sName, string theBody){   sendRequest(sName, theBody); }


	private static void sendRequestToSNOW_Immediate(string sName, string theBody){    sendRequest(sName, theBody); }


	private static void sendRequest(string sName, string theBody){
		string incidentId = '';
		if(!string.isEmpty(sName)){
			HttpRequest req = new HttpRequest();
			req.setHeader('Content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');
			req.setMethod('GET');
			req.setTimeout(120000);
			req.setEndpoint('callout:ServiceNow_Login/api/now/table/incident?active=true&u_operation_name=' + sName +  '&sysparm_limit=1&sysparm_query=' + EncodingUtil.urlEncode('state=1^ORstate=2^ORstate=8', 'UTF-8'));

			Http http = new Http();
			HTTPResponse res;

			try{
				res = http.send(req);
				
				if(!string.isEmpty(res.getBody())){
					map<string, list<oResult>> snowRes = (map<string, List<oResult>>)System.JSON.deserialize(res.getBody(), map<string, List<oResult>>.class);

					for(string s:snowres.keySet()){
						list<oResult> ls = snowRes.get(s);
						if(!ls.isEmpty())
							incidentId = ls[0].sys_id;
						break; //get only first element
					}
				}
			}catch(Exception e){
				//nothing to do. Incident will be created
			}
		}


		HttpRequest req = new HttpRequest();
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		
		req.setTimeout(120000);
		if(string.isEmpty(incidentId)){
			req.setBody(theBody);
			req.setMethod('POST');
			req.setEndpoint('callout:ServiceNow_Login/api/now/table/incident');
		}else{
			SNOWBodyWorkNotes wn = new SNOWBodyWorkNotes();
			wn.work_notes = theBody;
			req.setBody(json.serialize(wn));
			req.setMethod('PUT');
			req.setEndpoint('callout:ServiceNow_Login/api/now/table/incident/' + incidentId);
		}

		Http http = new Http();
		HTTPResponse res;

		try{
			res = http.send(req);
		}catch(CalloutException e){
			ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
			log.Web_Service__c = req.getEndpoint(); //'callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret;
			try{
			  log.Input_Description__c = 'body:' + res.getBody();
			}catch(exception e1){}
			log.Method__c = 'POST';
			log.Web_Service__c = String.valueOf(req);
			log.Error_Code__c = 'Exception sending request';
			log.Error_Message__c = e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage());
			log.Success__c = false;
			insert log;

			return;
		}

		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();

		//log.Agency_Applied_Change_code__c = changeCodeId;
		log.Web_Service__c = req.getEndpoint(); //'callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret;
		log.Input_Description__c= 'body:'+res.getBody();
		log.Method__c = 'POST';
		//log.Web_Service__c = String.valueOf(req);

		try{
		  log.Response__c = res.getBody();
		}catch(exception e){}

		log.Error_Code__c = String.valueOf(res.getStatusCode());
		log.Error_Message__c = res.getStatus();

		if((res.getStatusCode() > ANG_IEP_CalloutHelper.STATUSOKLOWER && res.getStatusCode() < ANG_IEP_CalloutHelper.STATUSOKHIGHER )) log.Success__c = true;
		else log.Success__c = false;

		insert log;
	}


	public class SNOWBodyWorkNotes{
		public string work_notes {get; set;}
	}

	public class SNOWBody{
		public string caused_by {get; set;}     //SFDC
		public string u_issue_identified_by {get; set;} //INT_008
		public string u_operation_name {get; set;}  //Agency MasterData
		public string u_application {get; set;} //featurespace-system-service
		public string business_service {get; set;}  //RME
		public string short_description {get; set;} //excception or description
		public string description {get; set;}   //full description
		public string impact  {get; set;} //2
		public string urgency  {get; set;} //2
		public string severity  {get; set;} //2
		public string category  {get; set;} //failure
		public string subcategory {get; set;}   //connectivity  or Software
		public string caller_id {get; set;} //Max Mule
		public string opened_by {get; set;} //Max Mule
		public string u_business_service {get; set;}    //Infrastructure Services
		public string assignment_group {get; set;}  //Mulesoft Support
		public string contact_type {get; set;}  //

	}

	public map<string, List<oResult>> SnowResponse {get;set;} 
	public class oResult {
		public String sys_id {get;set;} 
	}
}
