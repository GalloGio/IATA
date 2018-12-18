/*
	Class that calls external service to get RHC information updated.
	Used in RHC service and NewGen APP (mobile)
*/
@RestResource(urlMapping='/RME_ALERT_BALANCEUPDATE/*')
global class ANG_RME_Alert_Service {

	public class RHCMessage{
		//Basic info

		public String iataCode;
		public String eventId;
		public String eventType;
		public Decimal schemaVersion;
		public Datetime eventTime;

		//Balance Update AND RHC alert
		public String storedBaseCurrency;
		public Decimal storedRHCValue;
		public Decimal provisionalRHC;
		public Decimal consumedRHCAmount;
		public Decimal consumedRHCPercentage;

		//Used only on RHC Alert
		public String thresholdLevel;
		public String direction;

		//Used only on RTS ALert
		public String RTSSeverity;
		public Decimal AgentSales;
		
		//Used on INT 033: Request Provisional RHC (button)
		public String title;
		public String transactionId;
		public String api;
		public String code;
	}

	global class RequestResult {
		global String api;
		global String code;
		global String trace;
		global String title;
		global String description;
		global String transactionId;

		global List<AgencyResult> summary;

		private RHCMessage res;

		global RequestResult(){
			api =  'INT_032';
			trace = '';
			title = '';
			description =  '';
			transactionId =  '';

			summary = new List<AgencyResult>{new AgencyResult()};
		}
	}

	global class AgencyResult{
		global String status;
		global String description;
		global String agencyId;
	}

	private static RequestResult result{
		get{
			if(result == null) result = new RequestResult();
			return result;
		}
		set;
	}

	private static ISSP_Web_Service_Log__c log{
		get{
			if(log == null) log = new ISSP_Web_Service_Log__c();
			return log;
		}
		set;
	}

	private static void setResponse(String message, Integer statusCode){
		setResponse(message, null, statusCode);
	}

	private static void setResponse(String message, String stackTrace, Integer statusCode){
		if(RestContext.response == null) RestContext.response = new RestResponse(); //this line is for testing purposes
		RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.statusCode = statusCode;

		result.code = String.valueOf(statusCode);
		if(String.isNotBlank(message)) result.description = message;
		if(String.isNotBlank(stackTrace)) result.trace = stackTrace;

		result.summary[0].status = String.valueOf(statusCode); 
		if(String.isNotBlank(message)) result.summary[0].description = message;
	}

	@HttpPut
	global static Map<String, RequestResult> doPut() {

		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] requestBody - ' + RestContext.request.requestBody.toString());

		//set savepoint
		Savepoint sp = Database.setSavepoint();

		try{
			//receive request
			RHCMessage req = (RHCMessage)JSON.deserializeStrict(RestContext.request.requestBody.toString(), RHCMessage.class);
			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] req - ' + req);
			result.summary[0].agencyId = req.iataCode;

			String eventType = RestContext.request.params.get('eventType');

			//fetch current information
			List<Account> accs = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where IATACode__c = :req.iataCode AND RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY];
			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] accs - ' + accs);

			if(accs.isEmpty()) 								setResponse('No agent found with IATA Code '+req.iataCode, 404);

			//handle Real Time Sales alert request 
			else if(req.eventType == 'RTSAlert') 			saveRTSAlert(req, accs[0].Id);

			else if(accs[0].RHC_Informations__r.isEmpty())	setResponse('Agent '+req.iataCode+' does not have RHC set', 404);
			else if(accs[0].RHC_informations__r.size()>1)	setResponse('Internal Error: Agent '+req.iataCode+' has more than one RHC record', 409);
			else{

				//information found, validate values
				ANG_RHC_Information__c rhcInfo = accs[0].RHC_informations__r[0];

				String errorMessage = '';
				//if(rhcInfo.ANG_RHC_Amount__c != req.storedRHCValue) errorMessage += '\n- RHC Amount mismatch. Request value: '+req.storedRHCValue+'. Current value: '+rhcInfo.ANG_RHC_Amount__c;
				if(rhcInfo.CurrencyIsoCode != req.storedBaseCurrency) errorMessage += '\n- Currency mismatch. Request value: '+req.storedBaseCurrency+'. Current value: '+rhcInfo.CurrencyIsoCode;

				if(String.isNotEmpty(errorMessage)) setResponse('Conflicting informations:'+errorMessage, 409);
				//validation passed, perform logic
				else if(eventType == 'RHCAlert'){
					updateRHC(req, rhcInfo);
					saveAlert(req, rhcInfo);
				}
				else if(eventType == 'BalanceUpdate') updateRHC(req, rhcInfo);
				else setResponse('Invalid Event Type: '+eventType, 405);
			}

		}catch(JSONException e){
			setResponse('Malformed request: '+e.getMessage(), 400);
		}
		catch(Exception e){
			setResponse(e.getMessage(), e.getStackTraceString(), 500);
		}

		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] result - ' + result);
		return new Map<String, RequestResult>{'apiStatus' => result};
	}

	/*
		Expose webservice as a RESTfull service for NewGen Mobile APP
	*/
	@HttpPost
  	global static void doPost(String accountId){
  		ANG_RME_Alert_Service.requestBalanceUpdate(accountId);
  	}

	private static void saveAlert(RHCMessage message, ANG_RHC_Information__c rhcInfo) {
		ANG_Risk_Alert__c alert = new ANG_Risk_Alert__c();
		alert.ANG_Account__c = rhcInfo.ANG_AccountId__c;
		alert.ANG_RHC_Information__c = rhcInfo.Id;
		alert.ANG_EventId__c = message.eventId;
		alert.ANG_Threshold_Level__c = message.thresholdLevel;
		alert.ANG_Direction__c = message.direction;
		alert.ANG_RME_Last_Update__c = message.eventTime;
		insert alert;

		setResponse(null, 202);
	}

	private static void updateRHC(RHCMessage message, ANG_RHC_Information__c rhcInfo) {
		rhcInfo.ANG_ConsumedRHC__c = message.consumedRHCAmount;
		rhcInfo.ANG_ConsumedRHC_Percent__c = message.consumedRHCPercentage*100;
		rhcInfo.ANG_ConsumedRHC_Last_Update__c = message.eventTime.date();

		update rhcInfo;
		setResponse(null, 202);
	}

	private static void saveRTSAlert(RHCMessage req, Id accountId){

		if(!validateRTSAlert(req)) return;

		ANG_Risk_Alert__c rtsAlert = new ANG_Risk_Alert__c(
			RecordTypeId = Schema.SObjectType.ANG_Risk_Alert__c.getRecordTypeInfosByName().get('Risk Alert RTS').getRecordTypeId(),
			ANG_Severity__c= req.rtsSeverity,
			ANG_Agent_Sales__c = req.agentSales,
			CurrencyIsoCode = req.storedBaseCurrency,
			ANG_Account__c = accountId,
			ANG_EventId__c = req.eventId
		);
    	insert rtsAlert;
    	setResponse(null, 202);
	}

	private static Boolean validateRTSAlert(RHCMessage req) {

		// validate fields required
		if (String.isBlank(req.rtsSeverity) || req.agentSales == null || String.isBlank(req.eventId)) {
			setResponse('Required values missing: '
				+ (String.isBlank(req.rtsSeverity) ? 'rtsSeverity ' : '') 
				+ (req.agentSales == null ? 'agentSales ' : '' )
				+ (String.isBlank(req.eventId) ? 'eventId ' : '')
				, 400);
			return false;
		}

		//validate severity value - check if exists on picklist
		String severPLvals = '';
		for (Schema.PicklistEntry entry :ANG_Risk_Alert__c.ANG_Severity__c.getDescribe().getPicklistValues()){
				
			if(String.isBlank(severPLvals))
				severPLvals = entry.getValue();
			else 
				severPLvals += ',' + entry.getValue();
		}

		if (!(new Set<String>(severPLvals.split(','))).contains(req.rtsSeverity)) {

			setResponse('Invalid rtsSeverity: "'+req.rtsSeverity+'". Field is case Sensitive. Allowed values are: '+severPLvals, 400);
			return false;
		}

		//validate currency
		Set<String> currencyPLvals = new Set<String>();

		for (Schema.Picklistentry entry: ANG_Risk_Alert__c.getSObjectType().getDescribe().fields.getMap().get('CurrencyIsoCode').getDescribe().getPickListValues()){
			currencyPLvals.add(entry.getValue());
		}

		if (!currencyPLvals.contains(req.storedBaseCurrency)){
			setResponse('Invalid storedBaseCurrency: "'+req.storedBaseCurrency+'". Currency code must have 3 upper case characters.', 400);
			return false; 
		}

		return true;

	}

	global class WebserviceResult {
		webservice Boolean isSuccess;
		webservice String description;
		webservice String iataCode;
		webservice ISSP_Web_Service_Log__c log; 

		private RHCMessage res;

		private WebserviceResult(){
			isSuccess = true;
		}
	}

	public static WebserviceResult testWebserviceResult(){
		if(Test.isRunningTest()){
			WebserviceResult result = new WebserviceResult();
			result.isSuccess=true;
			result.description='test description';
			return result;
		}
		return null;
	}

	//webservice called by salesforce (javascript button and portal) to request an update of RHC Consumption Status
	webservice static WebserviceResult requestBalanceUpdate(String accountId){

		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where Id = :accountId];

		WebserviceResult result = doRequest(acc.IATACode__c, 'BTN_Bal', false); //results are saved on the private varible "result"

		if(result.isSuccess) {

			if(result.res.iataCode != acc.IATACode__c){
				log.Error_Code__c = 'Iata Code Mismatch';
				result.isSuccess = false;
				//ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_068', 'requestBalanceUpdate', 'featurespace-system-service', 'RME', accountId + ' ' + log.Error_Code__c, String.valueOf(result), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
				ServiceNow_Helper.sendRequestToSNOWRME('SNOW3', acc.IATACode__c, log, result);
				result.description = 'Error: '+log.Error_Code__c+'\nAn incident has been raised on Service Now.';
			}
			else if (result.res.storedBaseCurrency != acc.RHC_Informations__r[0].CurrencyIsoCode){
				result.isSuccess = false;
				log.Error_Code__c = 'Currency Mismatch';
				//ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_068', 'requestBalanceUpdate', 'featurespace-system-service', 'RME', accountId + ' ' + log.Error_Code__c,  String.valueOf(result), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
				ServiceNow_Helper.sendRequestToSNOWRME('SNOW4', acc.IATACode__c, log, result);
				result.description = 'Error: '+log.Error_Code__c+'\nAn incident has been raised on Service Now.';
			}
			else if (result.res.storedRHCValue != acc.RHC_Informations__r[0].ANG_RHC_Amount__c){
				result.isSuccess = false;
				log.Error_Code__c = 'RHC Value Mismatch';
				//ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_068', 'requestBalanceUpdate', 'featurespace-system-service', 'RME', accountId + ' ' + log.Error_Code__c,  String.valueOf(result), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
				ServiceNow_Helper.sendRequestToSNOWRME('SNOW5', acc.IATACode__c, log, result);
				result.description = 'Error: '+log.Error_Code__c+'\nAn incident has been raised on Service Now.';
			}
			else
				updateRHC(result.res, acc.RHC_Informations__r[0]);

		}

		if(result.log != null)
			insert result.log;

		//
		// To reset the singleton for future calls
		//
		log = null;	

		return result;
	}

	//webservice called by salesforce (javascript button) to request an update on Provisional RHC status
	webservice static WebserviceResult requestProvisionalRHC(String accountId, Boolean flagUpdateProvisioning){

		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where Id = :accountId];
		
		WebserviceResult result = doRequest(acc.IATACode__c, 'BTN_Prov'); //results are saved on the private varible "result"

		if(result.isSuccess){

			if(result.res.iataCode != acc.IATACode__c){ 
				log.Error_Code__c = 'Iata Code Mismatch';
				//ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_033', 'requestBalanceUpdate', 'featurespace-system-service', 'RME', accountId + ' ' + log.Error_Code__c, String.valueOf(result), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
				ServiceNow_Helper.sendRequestToSNOWRME('SNOW6', acc.IATACode__c, log, result);
			}
			else if (result.res.storedBaseCurrency != acc.RHC_Informations__r[0].CurrencyIsoCode){ 
				log.Error_Code__c = 'Currency Mismatch';
				//ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_033', 'requestBalanceUpdate', 'featurespace-system-service', 'RME', accountId + ' ' + log.Error_Code__c, String.valueOf(result), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
				ServiceNow_Helper.sendRequestToSNOWRME('SNOW7', acc.IATACode__c, log, result);
			}
			//COMMENTED - we should not validate this for provisional RHC
			/*else if (result.res.storedRHCValue != acc.RHC_Informations__r[0].ANG_RHC_Amount__c){
				log.Error_Code__c = 'RHC Value Mismatch';
				ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_033', 'requestBalanceUpdate', 'featurespace-system-service', 'RME', accountId + ' ' + log.Error_Code__c, String.valueOf(result), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
			}*/
			else{
				ANG_RHC_Information__c rhcInfo = acc.RHC_Informations__r[0];
				rhcInfo.ANG_RHC_Amount_Provisional__c = result.res.provisionalRHC;
				rhcInfo.ANG_Provisional_RHC_Last_Update__c = System.today();

				if(flagUpdateProvisioning) {
					rhcInfo.ANG_RME_Amount__c = rhcInfo.ANG_RHC_Amount_Provisional__c;
				}

				update rhcInfo;
			}
			if(String.isNotEmpty(log.Error_Code__c)) update log;
		}

		//
		// To reset the singleton for future calls
		//
		log = null;	

		return result;
	}

	//called from the oscar trigger when Endorsement_Requested__c is set to true
	@future (callout=true)
	webservice static void requestGDIEndorsementCertificate(String iataCode, String offerId){

		WebserviceResult result = doRequest(iataCode, 'ENDORS_CERT', true, offerId); //results are saved on the private varible "result"

		if(result.isSuccess){

			if(result.res.iataCode != iataCode){ 
				log.Error_Code__c = 'Iata Code Mismatch';
				//ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_033', 'requestBalanceUpdate', 'featurespace-system-service', 'RME', accountId + ' ' + log.Error_Code__c, String.valueOf(result), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
				ServiceNow_Helper.sendRequestToSNOWRME('SNOW6',iataCode, log, result);
			}

			if(String.isNotEmpty(log.Error_Code__c)) update log;
		}

		//
		// To reset the singleton for future calls
		//
		log = null;	

	}

	private static WebserviceResult doRequest(String iataCode, String mappingName){
		return doRequest(iataCode, mappingName, true, '');
	}

	private static WebserviceResult doRequest(String iataCode, String mappingName, boolean commitLog){
		return doRequest(iataCode, mappingName, commitLog, '');
	}

	private static WebserviceResult doRequest(String iataCode, String mappingName, boolean commitLog, String offerId){

		ANG_CalloutMapping__c params = ANG_CalloutMapping__c.getInstance(mappingName);

		WebserviceResult result = new WebserviceResult();
		result.iataCode = iataCode;

		//do callout
		HttpRequest req = new HttpRequest();
		req.setHeader('Content-Type', 'application/json');
		req.setMethod(params.Action__c);
		req.setTimeout(120000);
		req.setEndpoint('callout:' + params.Named_Credential__c + params.Credential__c.replace('{agencyId}', iataCode).replace('{offerId}',offerId) + '?client_id=' + params.client_id__c + '&client_secret=' + params.client_secret__c);

		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doRequest] req - ' + req);

		//start logging
		log.Web_Service__c = 'Mulesoft/Future Space';
		log.Method__c = req.getMethod();
		log.Input_Description__c = 'GET Request\nEndpoint:'+req.getEndpoint();

		//parse result
		HttpResponse res;

		try {
			res = new Http().send(req);

			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doRequest] res - ' + res);
			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doRequest] res body - ' + res.getBody());

			log.Input_Description__c += '\n\nResponse:\n'+res.toString()+'\n'+res.getBody();

			if(res.getStatusCode() >= 200 && res.getStatusCode() < 300){
				result.res = (RHCMessage)JSON.deserializeStrict(res.getBody(), RHCMessage.class);
			}else{
				result.isSuccess = false;

				log.Error_Code__c = String.valueOf(res.getStatusCode());
				log.Error_Message__c = res.getBody();
				if(res.getStatusCode() >= 400) //ServiceNow_Helper.sendRequestToSNOW('Mulesoft', (params.name == 'BTN_Bal' ?  'INT_068': 'INT_033'), (params.name == 'BTN_Bal' ?  'INT_068': 'INT_033'), 'featurespace-system-service', 'RME', String.valueOf(result),  String.valueOf(result), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
					ServiceNow_Helper.sendRequestToSNOWRME((params.name == 'BTN_Bal' ?  'SNOW9': 'SNOW9.1'), iataCode, log, result);
				result.description = 'An unexpected error ocurred while contacting the external system. An incident has been raised on Service Now.';
			}
		} catch(Exception e) {
			result.isSuccess = false;

			log.Error_Code__c = 'Unexpected Exception on Apex Class';
			log.Error_Message__c = e.getMessage();
			result.description = 'An unexpected error ocurred while contacting the external system. Please, try again later or contact your system admin';
		}

		log.Success__c = result.isSuccess;
		
		if(commitLog)
			insert log;

		result.log = log;

		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doRequest] log - ' + log);
		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doRequest] result - ' + result);
		
		return result;
	}
}