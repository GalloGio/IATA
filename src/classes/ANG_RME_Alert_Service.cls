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
		public Decimal consumedRHCAmount;
		public Decimal consumedRHCPercentage;

		//Used only on RHC Alert
		public String thresholdLevel;
		public String direction;

		//Used only on RTS ALert
		public String rtsSeverity;
		public Decimal agentSales;
	}

	global class RequestResult {
		global String api;
		global String code;
		global String trace;
		global String title;
		global String description;
		global String transactionId;

		global List<AgencyResult> summary;

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
			List<Account> accs = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where IATACode__c = :req.iataCode];
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
					saveAlert(req, rhcInfo);
					updateRHC(req, rhcInfo);
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

	private static void saveAlert(RHCMessage req, ANG_RHC_Information__c rhcInfo) {
		ANG_Risk_Alert__c alert = new ANG_Risk_Alert__c();
		alert.ANG_Account__c = rhcInfo.ANG_AccountId__c;
		alert.ANG_RHC_Information__c = rhcInfo.Id;
		alert.ANG_EventId__c = req.eventId;
		alert.ANG_Threshold_Level__c = req.thresholdLevel;
		alert.ANG_Direction__c = req.direction;
		alert.ANG_RME_Last_Update__c = req.eventTime;
		insert alert;

		setResponse(null, 202);
	}

	private static void updateRHC(RHCMessage req, ANG_RHC_Information__c rhcInfo) {
		rhcInfo.ANG_ConsumedRHC__c = req.consumedRHCAmount;
		rhcInfo.ANG_ConsumedRHC_Percent__c = req.consumedRHCPercentage * 100; //External system range is  0-1, Salesforcerange is  0-100
		rhcInfo.ANG_ConsumedRHC_Last_Update__c = req.eventTime.date();

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

	global class BalanceResult {
		webservice Boolean isSuccess;
		webservice String description;
		webservice String iataCode;
	}

	//webservice called by salesforce (javascript button and portal) to request an update
	webservice static BalanceResult requestBalanceUpdate(String accountId){

		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where Id = :accountId];
		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - requestBalanceUpdate] acc - ' + acc);

		BalanceResult result = new BalanceResult();
		result.isSuccess = true;
		result.iataCode = acc.IATACode__c;

		//do callout
		HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
		req.setMethod('POST');
		req.setTimeout(120000);
		req.setEndpoint('callout:ANG_Mulesoft_032?client_id=6235b6a786ae4e6c88526cd20fd3d2d0&client_secret=d629863C84E5458dB25778e8f7351d02');

		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - requestBalanceUpdate] req - ' + req);

		//parse result
		HttpResponse res;
		RHCMessage rhc;

		try {
			if(Test.isRunningTest()) res = new Http().send(req);
			//temporary stuff
			else{
				rhc = new RHCMessage();
				rhc.iataCode = result.iataCode;
				rhc.eventTime = System.now();
				rhc.consumedRHCAmount = 5000;
				rhc.consumedRHCPercentage = 0.5;
				res = new HttpResponse();
				res.setBody(JSON.serialize(rhc));
				res.setStatusCode(200);
			}
			// end temporary stuff

			if(res.getStatusCode() >= 200 && res.getStatusCode() < 300){
				/**
				TODO: Define response structure
				*/
				rhc = (RHCMessage)JSON.deserializeStrict(res.getBody(), RHCMessage.class);
				
				ANG_RHC_Information__c rhcInfo = acc.RHC_Informations__r[0];

				rhcInfo.ANG_ConsumedRHC__c = rhc.consumedRHCAmount;
				rhcInfo.ANG_ConsumedRHC_Percent__c = rhc.consumedRHCPercentage * 100;
				rhcInfo.ANG_ConsumedRHC_Last_Update__c = rhc.eventTime.date();
				update rhcInfo;
			}else{
				result.isSuccess = false;
				result.description = res.getBody();
			}
		} catch(Exception e) {
			result.isSuccess = false;
			result.description = e.getMessage();
		}


		//return
		return result;
	}
}