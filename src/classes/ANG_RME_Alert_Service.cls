@RestResource(urlMapping='/RME_ALERT_BALANCEUPDATE/*')
global class ANG_RME_Alert_Service {

	public class RequestMessage{
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
			RequestMessage req = (RequestMessage)JSON.deserializeStrict(RestContext.request.requestBody.toString(), RequestMessage.class);
			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] req - ' + req);
			result.iataCode = req.iataCode;

			//fetch current information
			List<Account> accs = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r) FROM Account where IATACode__c = :result.iataCode];
			System.debug(loggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] accs - ' + accs);

			if(accs.isEmpty()) 								setResponse('No agent found with IATA Code '+result.iataCode, 404);
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
				else if(req.eventType == 'RHCAlert') saveAlert(req, rhcInfo);
				else if(req.eventType == 'BalanceUpdate') updateRHC(req, rhcInfo);
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

	private static void saveAlert(RequestMessage req, ANG_RHC_Information__c rhcInfo) {
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

	private static void updateRHC(RequestMessage req, ANG_RHC_Information__c rhcInfo) {
		rhcInfo.ANG_ConsumedRHC__c = req.consumedRHCAmount;
		rhcInfo.ANG_ConsumedRHC_Percent__c = req.consumedRHCPercentage;
		rhcInfo.ANG_ConsumedRHC_Last_Update__c = req.eventTime.date();

		update rhcInfo;
		setResponse(null, 202);
	}
}