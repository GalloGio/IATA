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
	}

	global class RequestResult {
		global Boolean isSuccess;
		global String description;
		global String iataCode;

		private RHCMessage res;

		global RequestResult(){
			isSuccess = true;
		}
	}

	private static RequestResult result{
		get{
			if(result == null) result = new RequestResult();
			return result;
		}
		set;
	}

	private static void setResponse(String message, Integer statusCode){
		if(RestContext.response == null) RestContext.response = new RestResponse(); //this line is for testing purposes
        RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.statusCode = statusCode;

		if(String.isNotBlank(message)) result.description = message;
		result.isSuccess = statusCode >= 200 && statusCode < 300; 
	}

	@HttpPut
	global static RequestResult doPut() {

		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] requestBody - ' + RestContext.request.requestBody.toString());

		//set savepoint
		Savepoint sp = Database.setSavepoint();

		try{
			//receive request
			RHCMessage req = (RHCMessage)JSON.deserializeStrict(RestContext.request.requestBody.toString(), RHCMessage.class);
			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] req - ' + req);
			result.iataCode = req.iataCode;

			String eventType = RestContext.request.params.get('eventType');

			//fetch current information
			List<Account> accs = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where IATACode__c = :result.iataCode];
			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] accs - ' + accs);

			if(accs.isEmpty())								setResponse('No agent found with IATA Code '+result.iataCode, 404);
			else if(accs[0].RHC_Informations__r.isEmpty())	setResponse('Agent '+result.iataCode+' does not have RHC set', 404);
			else if(accs[0].RHC_informations__r.size()>1)	setResponse('Internal Error: Agent '+result.iataCode+' has more than one RHC record', 409);
			else{

				//information found, validate values
				ANG_RHC_Information__c rhcInfo = accs[0].RHC_informations__r[0];

				String errorMessage = '';
				//if(rhcInfo.ANG_RHC_Amount__c != req.storedRHCValue) errorMessage += '\n- RHC Amount mismatch. Request value: '+req.storedRHCValue+'. Current value: '+rhcInfo.ANG_RHC_Amount__c;
				if(rhcInfo.CurrencyIsoCode != req.storedBaseCurrency) errorMessage += '\n- Currency mismatch. Request value: '+req.storedBaseCurrency+'. Current value: '+rhcInfo.CurrencyIsoCode;

				if(String.isNotEmpty(errorMessage)) setResponse('Conflicting informations:'+errorMessage, 409);
				//validation passed, perform logic
				else if(eventType == 'RHCAlert') saveAlert(req, rhcInfo);
				else if(eventType == 'BalanceUpdate') updateRHC(req, rhcInfo);
				else setResponse('Invalid Event Type: '+req.eventType, 405);
			}

		}catch(JSONException e){
			setResponse('Malformed request: '+e.getMessage(), 400);
		}
		catch(Exception e){
			setResponse(e.getMessage(), 500);
		}

		return result;
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
		rhcInfo.ANG_ConsumedRHC_Percent__c = message.consumedRHCPercentage;
		rhcInfo.ANG_ConsumedRHC_Last_Update__c = message.eventTime.date();

		update rhcInfo;
		setResponse(null, 202);
	}

	//webservice called by salesforce (javascript button and portal) to request an update of RHC Consumption Status
	webservice static RequestResult requestBalanceUpdate(String accountId){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where Id = :accountId];

		doRequest(acc.IATACode__c, 'BTN_Bal'); //results are saved on the private varible "result"

		if(result.isSuccess) updateRHC(result.res, acc.RHC_Informations__r[0]);

		return result;
	}

	//webservice called by salesforce (javascript button) to request an update on Provisional RHC status
	webservice static RequestResult requestProvisionalRHC(String accountId){
		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where Id = :accountId];

		doRequest(acc.IATACode__c, 'BTN_Prov'); //results are saved on the private varible "result"

		if(result.isSuccess){
			ANG_RHC_Information__c rhcInfo = acc.RHC_Informations__r[0];
			rhcInfo.ANG_RHC_Amount_Provisional__c = result.res.storedRHCValue;
			rhcInfo.ANG_Provisional_RHC_Last_Update__c = result.res.eventTime.date();
			update rhcInfo;
		}

		return result;
	}

	private static void doRequest(String iataCode, String mappingName){

		ANG_CalloutMapping__c params = ANG_CalloutMapping__c.getInstance(mappingName);

		result.iataCode = iataCode;

		//do callout
		HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
		req.setMethod(params.Action__c);
		req.setTimeout(120000);
		req.setEndpoint('callout:' + params.Named_Credential__c + params.Credential__c.replace('{agencyId}', iataCode) + '?client_id=6235b6a786ae4e6c88526cd20fd3d2d0&client_secret=d629863C84E5458dB25778e8f7351d02');

		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - requestBalanceUpdate] req - ' + req);

		//start log
		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
		log.Web_Service__c = 'Mulesoft/Future Space';
		log.Method__c = req.getMethod();
		log.Input_Description__c = 'GET Request\nEndpoint:'+req.getEndpoint();

		//parse result
		HttpResponse res;

		try {
			res = new Http().send(req);

			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - requestBalanceUpdate] res - ' + res);
			log.Input_Description__c += '\n\nResponse:\n'+res.toString();

			if(res.getStatusCode() >= 200 && res.getStatusCode() < 300){
				result.res = (RHCMessage)JSON.deserializeStrict(res.getBody(), RHCMessage.class);
			}else{
				result.isSuccess = false;
				result.description = res.getBody();

				log.Error_Code__c = String.valueOf(res.getStatusCode());
			}
		} catch(Exception e) {
			result.isSuccess = false;
			result.description = e.getMessage();

			log.Error_Code__c = 'Unexpected Error';
		}

		log.Success__c = result.isSuccess;
		if(!log.Success__c) log.Error_Message__c = result.description;
		
		insert log;

		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - requestBalanceUpdate] log - ' + log);
		System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - requestBalanceUpdate] result - ' + result);
	}
}