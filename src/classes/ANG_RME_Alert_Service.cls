/*
	Class that calls external service to get RHC information updated.
	Used in RHC service and NewGen APP (mobile)
*/
@RestResource(urlMapping='/RME_ALERT_BALANCEUPDATE/*')
global class ANG_RME_Alert_Service {

	@TestVisible
	private static final String RHC_ALERT_EVENT_TYPE = 'RHCAlert';
	@TestVisible
	private static final String RTS_ALERT_EVENT_TYPE = 'RTSAlert';
	@TestVisible
	private static final String EDS_ALERT_EVENT_TYPE = 'EDSAlert';
	@TestVisible
	private static final String BALANCE_UPDATE_EVENT_TYPE = 'BalanceUpdate';
	
	public static final string PROVISIONAL_NOT_ALLOWED_BY_BSP = 'Agency\'s BSP does not allow to request new provisional';
	@TestVisible
	private static final String GDS_CASHLESSFOPALERT_EVENT_TYPE = 'CashlessGDSAlert';
	@TestVisible
	private static final String GDS_TA_ALERT_EVENT_TYPE = 'TAGDSAlert';
	@TestVisible
	private static final String GDS_CASH_ALERT_EVENT_TYPE = 'CashGDSAlert';

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

		//INT_032: reception of EDS Alerts
		public List<String> triggeredRules;
		public List<AgentStates> agentStates;

		//INT_032: GDS FailSafe alert
		public string gds;
		public string ticketNumber;
		public string agentStatus;
		public list<fopValues> fop;

	}

	public class fopValues{
		public string type; //Valid values: CC, CA, EP
		public string status;
	}

	//INT_032: reception of EDS Alerts
	public class AgentStates {
		public String state;
		public String value;
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

	private static Map<String, String> agentStatesMapping = new Map<String, String>{
		'edsState_fastGrowth_ratio_L12M_P12M' => 'Fast Growth Last 12m',
		'edsState_fastGrowth_ratio_L3M_P3M'	=> 'Fast Growth Last 3m',
		'edsState_fastGrowth_ratio_L3M_L3MPY' => 'Fast Growth Last 3m vs previous year',
		'edsState_ticketsAbroad_ratio_L3M' => 'Cross Border Sales',
		'edsState_cashSales_ratio_L3M' => 'Cash Sales Shift',
		'edsState_cashSales_shift_L3M_P3M' => 'Shift of FoP',
		'edsState_market_intelligence' => 'Market Intelligence'
	};

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

			if(String.isBlank(req.iataCode)){
				setResponse('Required value missing: iataCode', 404);
				return new Map<String, RequestResult>{'apiStatus' => result};
			}

			//fetch current information
			List<Account> accs = [
				SELECT Id, IATACode__c, top_parent__c, ANG_IsNewGenAgency__c, status__c, 
					IATA_ISO_Country__r.AMS_Settlement_System__r.RHC_Exceptional_Monitoring__c,
					IATA_ISO_Country__r.AMS_Settlement_System__r.Exc_RHC_Monitoring_Alert__c,
					IATA_ISO_Country__r.ANG_Enable_NewGen__c, IATA_ISO_Country__r.ANG_Portal_Service__c, IATA_ISO_Country__r.ANG_IEP_Model__c, ANG_Accreditation_Model__c, IATA_ISO_Country__r.Allow_Cash_FOP_for_Cashless_Agencies__c, //for cashless agencies in an operation without IEP
					(SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c FROM RHC_Informations__r),
					(SELECT Id, ANG_FormOfPayment_ID__c, Status__c FROM Agency_Authorizations__r WHERE recordtype.developername ='FormOfPayment')  //Accelya Email + FOP
				FROM Account
				WHERE IATACode__c = :req.iataCode
					AND RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY];

			System.debug(LoggingLevel.FINE, '____ [cls ANG_RME_Alert_Service - doPut] accs - ' + accs);

			if(accs.isEmpty()) {
				setResponse('No agent found with IATA Code '+req.iataCode, 404);
			}
			else {
				Account acct = accs[0];

				boolean bIsOperationWithoutIEP = (acct.IATA_ISO_Country__r.ANG_Enable_NewGen__c 
													&& acct.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASHLESS
													&& acct.IATA_ISO_Country__r.Allow_Cash_FOP_for_Cashless_Agencies__c);

				switch on req.eventType {
					when 'RTSAlert'{ //move to static final above when Salesforce decides is a good idea to release it https://trailblazer.salesforce.com/ideaView?id=0873A000000lLkNQAU
						//handle Real Time Sales alert request
						saveRTSAlert(req, acct.Id);
					}
					when 'EDSAlert'{
						//handle EDS alert request
						saveEDSAlert(req, acct.Id);
					}
					when 'RHCAlert'{
						if(acct.IATA_ISO_Country__r.AMS_Settlement_System__r.RHC_Exceptional_Monitoring__c) {
							if(string.isNotBlank(acct.IATA_ISO_Country__r.AMS_Settlement_System__r.Exc_RHC_Monitoring_Alert__c) 
								&& acct.IATA_ISO_Country__r.AMS_Settlement_System__r.Exc_RHC_Monitoring_Alert__c.contains(req.thresholdLevel + req.direction)){
								saveAlert(req, acct.Id, null);
							} else {
								//Ignore the request
								setResponse(null, 202);
							}
						}else{
							if(acct.RHC_Informations__r.isEmpty()) {
								setResponse('Agent '+req.iataCode+' does not have RHC set', 404);
							} 
							else if(acct.RHC_informations__r.size()>1) {
								setResponse('Internal Error: Agent '+req.iataCode+' has more than one RHC record', 409);
							} else{
								ANG_RHC_Information__c rhcInfo = acct.RHC_informations__r[0];

								String errorMessage = '';
								//check if the agency is CASHLESS and the operation is without IEP vendor
								//If so, skip checks on currency and save the alert
								if(bIsOperationWithoutIEP){
									if(String.isNotEmpty(errorMessage))
										setResponse('Conflicting informations:'+errorMessage, 409);
									else{
										updateRHC(req, rhcInfo);
										saveAlert(req, rhcInfo.ANG_AccountId__c, rhcInfo.Id);
									}
								}else{
									if(rhcInfo.CurrencyIsoCode != req.storedBaseCurrency) errorMessage += '\n- Currency mismatch. Request value: '+req.storedBaseCurrency+'. Current value: '+rhcInfo.CurrencyIsoCode;

									if(String.isNotEmpty(errorMessage))
										setResponse('Conflicting informations:'+errorMessage, 409);
									else{
										updateRHC(req, rhcInfo);
										saveAlert(req, rhcInfo.ANG_AccountId__c, rhcInfo.Id);
									}
								}
							}
						}
					}
					when 'BalanceUpdate'{
						if(acct.RHC_Informations__r.isEmpty()) {
							setResponse('Agent '+req.iataCode+' does not have RHC set', 404);
						} 
						else if(acct.RHC_informations__r.size()>1) {
							setResponse('Internal Error: Agent '+req.iataCode+' has more than one RHC record', 409);
						} else{
							ANG_RHC_Information__c rhcInfo = acct.RHC_informations__r[0];

							String errorMessage = '';
							if(rhcInfo.CurrencyIsoCode != req.storedBaseCurrency) errorMessage += '\n- Currency mismatch. Request value: '+req.storedBaseCurrency+'. Current value: '+rhcInfo.CurrencyIsoCode;

							if(String.isNotEmpty(errorMessage))
								setResponse('Conflicting informations:'+errorMessage, 409);
							else{
								updateRHC(req, rhcInfo);
							}
						}
					}
					when 'CashlessGDSAlert'{
						if(req.fop == null || req.fop.size()==0){
							setResponse('FOP attribute cannot be blank',  400);
						}else{
							map<string, string> RMEFOPS = new map<string, string>();
							for(fopValues fops:req.fop) RMEFOPS.put(fops.type, fops.status);
							if(acct.Agency_Authorizations__r.isEmpty()){
								setResponse('Agent '+req.iataCode+' does not have FOP set', 404);
							}else{
								if(validateFOP(acct.Agency_Authorizations__r, RMEFOPS)){
									saveGDSAlert(req, acct.id, acct.top_parent__c);
								}else{
									map<string, string> SFDCFOPS = new map<string, string>();
									for(Agency_Authorization__c sffops:acct.Agency_Authorizations__r)	SFDCFOPS.put(sffops.ANG_FormOfPayment_ID__c , sffops.status__c);
									setResponse('FOPS Received (' + RMEFOPS + ') don\'t match Salesforce FOPS (' + SFDCFOPS + ') for agent ' +  req.iataCode,  400);
								}
							}
						}
					}
					when 'CashGDSAlert'{
						if(req.fop == null || req.fop.size()==0){
							setResponse('FOP attribute cannot be blank',  400);
						}else{
							if(acct.ANG_IsNewGenAgency__c){
								map<string, string> RMEFOPS = new map<string, string>();
								for(fopValues fops:req.fop) RMEFOPS.put(fops.type, fops.status);
								if(acct.Agency_Authorizations__r.isEmpty()){
									setResponse('Agent '+req.iataCode+' does not have FOP set', 404);
								}else{
									if(validateFOP(acct.Agency_Authorizations__r, RMEFOPS)){
										saveGDSAlert(req, acct.id, acct.top_parent__c);
									}else{
										map<string, string> SFDCFOPS = new map<string, string>();
										for(Agency_Authorization__c sffops:acct.Agency_Authorizations__r)	SFDCFOPS.put(sffops.ANG_FormOfPayment_ID__c , sffops.status__c);
										setResponse('FOPS Received (' + RMEFOPS + ') don\'t match Salesforce FOPS (' + SFDCFOPS + ') for agent ' +  req.iataCode,  400);
									}
								}
							}else{
								setResponse('Agent '+req.iataCode+' is not a newgen agency', 404);
							}
						}
					}
					when 'TAGDSAlert'{
						if(string.isBlank(req.agentStatus)){
							setResponse('agentStatus cannot be blank', 400);
						}else{
							if(acct.status__c == req.agentStatus){
								saveGDSAlert(req, acct.id, acct.top_parent__c);
							}else{
								setResponse('Request agentStatus (' + req.agentStatus +  ') doesn\'t match Agent '+req.iataCode+' status (' + acct.status__c + ')', 400);
							}
						}
					}
					when else {
						setResponse('Invalid Event Type: '+req.eventType, 405);
					}
				}
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

	private static void saveAlert(RHCMessage message, Id accountId, Id rhcInfoId) {
		ANG_Risk_Alert__c alert = new ANG_Risk_Alert__c();
		alert.ANG_Account__c = accountId;
		alert.ANG_RHC_Information__c = rhcInfoId;
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
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Alert__c','Risk_Alert_RTS'),
			ANG_Severity__c= req.rtsSeverity,
			ANG_Agent_Sales__c = req.agentSales,
			CurrencyIsoCode = req.storedBaseCurrency,
			ANG_Account__c = accountId,
			ANG_EventId__c = req.eventId,
			ANG_RME_Last_Update__c = req.eventTime
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

	private static Boolean validateEDSAlert(RHCMessage req){

		Boolean missingEventId = String.isBlank(req.eventId);
		Boolean missingRules = (req.triggeredRules == NULL || req.triggeredRules.isEmpty());

		if(missingEventId || missingRules){
			setResponse('Required values missing: ' +
				(missingEventId ? 'eventId ' : '') +
				(missingRules ? 'triggeredRules ' : ''),
				400);

			return false;

		}

		return true;

	}

	//Validates that the FOPS received from RME matches FOPS in Salesforce 
	private static boolean validateFOP(List<Agency_Authorization__c> agencyFOPs, map<string, string> RMEFOPs){
		for(Agency_Authorization__c FOP:agencyFOPs){
			if(!RMEFOPs.containsKey(FOP.ANG_FormOfPayment_ID__c))
				return false;
			else{
				if(FOP.status__c <> RMEFOPs.get(FOP.ANG_FormOfPayment_ID__c))
					return false;
			}
		}
		return true;
	}

	private static void saveGDSAlert(RHCMessage req, Id accountId, id TopParentAccntId){
		ANG_Risk_Alert__c gdsAlert = new ANG_Risk_Alert__c(
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Alert__c','RiskAlertGDS'),
			ANG_Account__c = TopParentAccntId==null?accountId:TopParentAccntId,
			GDS__c = req.gds,
			GDS_Alert_Type__c = req.eventType,
			Monitored_Account__c = accountId,
			Ticket_Number__c = req.ticketNumber,
			Additional_Alert_information__c = (req.eventType==GDS_TA_ALERT_EVENT_TYPE?string.valueOf(req.agentStatus):string.valueOf(req.fop)),
			ANG_EventId__c = req.eventId
		);
		insert gdsAlert;
		setResponse(null, 202);
	}

	private static void saveEDSAlert(RHCMessage req, Id accountId){

		if(!validateEDSAlert(req)){
			return;
		}

		Decimal openCashPosition = 0;
		String agentCurrentStanding = '';

		for(AgentStates agentState : req.agentStates){

			if(agentState.state == 'consumedRHC_USD'){
				openCashPosition = Decimal.valueOf(agentState.value);
				continue;
			}

			String readableState = agentStatesMapping.get(agentState.state);

			agentCurrentStanding += readableState + ': ' + agentState.value + '\n';

		}

		ANG_Risk_Alert__c edsAlert = new ANG_Risk_Alert__c(
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Alert__c','Risk_Alert_EDS'),
			ANG_Account__c = accountId,
			ANG_EventId__c = req.eventId,
			ANG_RME_Last_Update__c = req.eventTime,
			CurrencyIsoCode = 'USD',
			ANG_Open_Cash_Position__c = openCashPosition,
			ANG_Triggered_Rules__c = String.join(req.triggeredRules, ';'),
			ANG_Agent_current_standing__c = agentCurrentStanding
		);

		insert edsAlert;

		setResponse(null, 202);

	}

	global class WebserviceResult {
		webservice Boolean isSuccess;
		webservice String description;
		webservice String iataCode;
		webservice ISSP_Web_Service_Log__c log;

		public RHCMessage res;

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

		Account acc = [SELECT Id, IATACode__c, (SELECT Id, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c, ANG_RHC_Amount_Forecasted__c FROM RHC_Informations__r) FROM Account where Id = :accountId];

		WebserviceResult result = doRequest(acc.IATACode__c, 'BTN_Bal', null, false); //results are saved on the private varible "result"

		if(result.isSuccess) {
			Decimal toround = acc.RHC_Informations__r[0].ANG_RHC_Amount__c;
			Integer decimalPlaces = (result.res.storedRHCValue).scale();
			Decimal rounded = toRound.setScale(decimalPlaces, RoundingMode.HALF_UP);

			system.debug('rounded value :: ' + rounded + ' |  result storedRHCValue :: ' +  result.res.storedRHCValue + ' | Decimal Places :: ' +  decimalPlaces);

			if(result.res.iataCode != acc.IATACode__c){
				log.Error_Code__c = 'Iata Code Mismatch';
				result.isSuccess = false;
				ServiceNow_Helper.sendRequestToSNOWRME('JSD3', acc.IATACode__c, log, result);
				result.description = 'Error: '+log.Error_Code__c+'\nAn incident has been raised on Service Now.';
			}
			else if (result.res.storedBaseCurrency != acc.RHC_Informations__r[0].CurrencyIsoCode){
				result.isSuccess = false;
				log.Error_Code__c = 'Currency Mismatch';
				ServiceNow_Helper.sendRequestToSNOWRME('JSD4', acc.IATACode__c, log, result);
				result.description = 'Error: '+log.Error_Code__c+'\nAn incident has been raised on Service Now.';
			}
			else if (result.res.storedRHCValue != rounded){
				result.isSuccess = false;
				log.Error_Code__c = 'RHC Value Mismatch';
				ServiceNow_Helper.sendRequestToSNOWRME('JSD5', acc.IATACode__c, log, result);
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

	webservice static WebserviceResult requestProvisionalRHC(String accountId){
		list<ANG_RHC_Information__c> rhcInfo = [SELECT id, ANG_AccountId__r.IATACode__c, ANG_AccountId__r.Location_Type__c,
												ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Enable_Provisional_RHC_Request__c,
										  ANG_RHC_Amount_Provisional__c, CurrencyIsoCode, ANG_RHC_Amount__c, ANG_AccountId__c, ANG_Provisional_RHC_Last_Update__c
										  FROM ANG_RHC_Information__c WHERE ANG_AccountId__c=:accountId];
		if(rhcInfo[0].ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Enable_Provisional_RHC_Request__c)
			return requestProvisionalRHC(rhcInfo[0], true);
		else{
			WebserviceResult result = new WebserviceResult();
			result.isSuccess = false;
			result.description = PROVISIONAL_NOT_ALLOWED_BY_BSP;
			return result;
		}
	}

	public static WebserviceResult requestProvisionalRHC(ANG_RHC_Information__c rhcInfo, boolean ProvisionalIsAppliedImmediately){
		if(rhcInfo.ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Enable_Provisional_RHC_Request__c){
			WebserviceResult result = doRequest(rhcInfo.ANG_AccountId__r.IATACode__c, 'BTN_Prov', rhcInfo.ANG_AccountId__r.Location_Type__c); //results are saved on the private varible "result"

			if(result.isSuccess){

				if(result.res.iataCode != rhcInfo.ANG_AccountId__r.IATACode__c){
					if(ProvisionalIsAppliedImmediately){
						log.Error_Code__c = 'Iata Code Mismatch';
						ServiceNow_Helper.sendRequestToSNOWRME('JSD6', rhcInfo.ANG_AccountId__r.IATACode__c, log, result);
					}
				}
				else if (result.res.storedBaseCurrency != rhcInfo.CurrencyIsoCode){
					if(ProvisionalIsAppliedImmediately){
						log.Error_Code__c = 'Currency Mismatch';
						ServiceNow_Helper.sendRequestToSNOWRME('JSD7', rhcInfo.ANG_AccountId__r.IATACode__c, log, result);
					}
				}
				else{
					rhcInfo.ANG_RHC_Amount_Provisional__c = result.res.provisionalRHC;
					rhcInfo.ANG_Provisional_RHC_Last_Update__c = System.today();

					if(ProvisionalIsAppliedImmediately)
						update rhcInfo;
				}
				if(String.isNotEmpty(log.Error_Code__c)) update log;
			}

			//
			// To reset the singleton for future calls
			//
			log = null;
			return result;
		}else{
			WebserviceResult result = new WebserviceResult();
			result.isSuccess = false;
			result.description = PROVISIONAL_NOT_ALLOWED_BY_BSP;
			return result;
		}
	}

	//called from the oscar trigger when Endorsement_Requested__c is set to true
	@future (callout=true)
	webservice static void requestGDIEndorsementCertificate(String iataCode, String offerId){

		WebserviceResult result = doRequest(iataCode, 'ENDORS_CERT', null, true, offerId); //results are saved on the private varible "result"

		if(result.isSuccess){

			if(result.res.iataCode != iataCode){
				log.Error_Code__c = 'Iata Code Mismatch';
				ServiceNow_Helper.sendRequestToSNOWRME('JSD19',iataCode, log, result);
			}

			if(String.isNotEmpty(log.Error_Code__c)) update log;
		}

		//
		// To reset the singleton for future calls
		//
		log = null;

	}

	private static WebserviceResult doRequest(String iataCode, String mappingName, String locType){
		return doRequest(iataCode, mappingName, locType, true, '');
	}

	private static WebserviceResult doRequest(String iataCode, String mappingName, String locType, Boolean commitLog){
		return doRequest(iataCode, mappingName, locType, commitLog, '');
	}

	private static WebserviceResult doRequest(String iataCode, String mappingName, String locType, Boolean commitLog, String offerId){

		ANG_CalloutMapping__c params = ANG_CalloutMapping__c.getInstance(mappingName);

		WebserviceResult result = new WebserviceResult();
		result.iataCode = iataCode;

		//do callout
		HttpRequest req = new HttpRequest();
		req.setHeader('Content-Type', 'application/json');
		req.setMethod(params.Action__c);
		req.setTimeout(120000);
		if(!String.isBlank(locType)){
			Boolean isGE = (locType == AMS_Utils.GE);
			req.setEndpoint('callout:' + params.Named_Credential__c + params.Credential__c.replace('{agencyId}', iataCode).replace('{offerId}',offerId) + '?client_id=' + params.client_id__c + '&client_secret=' + params.client_secret__c + '&isGe=' + isGE);
		} else {
			req.setEndpoint('callout:' + params.Named_Credential__c + params.Credential__c.replace('{agencyId}', iataCode).replace('{offerId}',offerId) + '?client_id=' + params.client_id__c + '&client_secret=' + params.client_secret__c );
		}

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
				if(mappingName == 'ENDORS_CERT' && res.getStatusCode() >= 400)
					ServiceNow_Helper.sendRequestToSNOWRME('JSD21',iataCode, log, result);
				else if(res.getStatusCode() >= 400)
					ServiceNow_Helper.sendRequestToSNOWRME((params.name == 'BTN_Bal' ?  'JSD9': 'JSD20'), iataCode, log, result);
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