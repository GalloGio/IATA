global class ANG_CalloutIEPMasterdata implements ANG_CalloutHelperInt {

	global static String fetchEndPoint(ANG_CalloutMapping__c mappingObj){
		return mappingObj.Credential__c;
	}

	global static void doCallOut(Object obj, ANG_CalloutMapping__c mappingObj, String changeCodeId,String agencyUpdateId , String iataCode, Boolean isRunningBatch){
		sendCallout(JSON.serialize(obj), mappingObj.Action__c, mappingObj.Named_Credential__c, changeCodeId, agencyUpdateId, iataCode, isRunningBatch);
	}

	public static boolean runTheQueableTest = false;

	private static void sendCallout(String body, String action, String namedCredential, String changeCodeId, String agencyUpdateId, String iataCode,Boolean isRunningBatch){
		if(((System.isBatch() || System.isFuture()) && trigger.isExecuting) || (test.isRunningTest() && runTheQueableTest)){
			if((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) > 0)
				System.enqueueJob(new executeCalloutQueueable(body, action, namedCredential, changeCodeId, agencyUpdateId, iataCode));
			else
				if(System.isFuture() || System.isBatch())
					executeCallout(body, action, namedCredential, changeCodeId, agencyUpdateId, iataCode);
				else
					executeCalloutFuture(body, action, namedCredential, changeCodeId, agencyUpdateId, iataCode);
		}
		else if(isRunningBatch || ANG_ConversionHelper.isMigrationTool || System.isBatch() || System.isFuture()){
			executeCallout(body, action, namedCredential, changeCodeId, agencyUpdateId, iataCode);
		}
		else {
			executeCalloutFuture(body, action, namedCredential, changeCodeId, agencyUpdateId, iataCode);
		}
	}

	@future (callout=true)
	private static void executeCalloutFuture(String body, String action, String namedCredential, String changeCodeId, String agencyUpdateId, String iataCode){
		executeCallout(body, action, namedCredential, changeCodeId, agencyUpdateId, iataCode);
	}

	private static void executeCallout(String body, String action, String namedCredential, String changeCodeId, String agencyUpdateId, String iataCode){

		HttpRequest req = new HttpRequest();
		req.setHeader('Content-Type', 'application/json');
	 	req.setMethod(action);
	 	req.setTimeout(120000);
		req.setEndpoint('callout:' + namedCredential);
		req.setBody(body);

		System.debug('ANG_CalloutIEPMasterdata:Endpoint:' + req.getEndpoint());
		System.debug('ANG_CalloutIEPMasterdata:Callout request is:'+req.getBody());

		Http http = new Http();
		HTTPResponse res;

		try{
			res = http.send(req);
		}catch(CalloutException e){

			System.debug('ANG_CalloutIEPMasterdata: Exception:'+e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage()));

			ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
			log.Agency_Applied_Change_code__c = changeCodeId;
			log.Web_Service__c = 'callout:'+namedCredential + body;
			log.Input_Description__c= 'body:'+body;
			log.Method__c = action;
			log.Web_Service__c = String.valueOf(req);
			log.Error_Code__c = 'Exception sending request';
			log.Error_Message__c = e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage());
			log.Success__c = false;

			ServiceNow_Helper.sendRequestToSNOWMulesoft('JSD1', iatacode, log);
			ANG_IEP_CalloutHelper.updateAgencyEvent(agencyUpdateId,false);

			insert log;
			return;
		}

		System.debug('ANG_CalloutIEPMasterdata: Request Status:'+res.getStatus());
		System.debug('ANG_CalloutIEPMasterdata: Request Code:'+res.getStatusCode());

		ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();

		log.Agency_Applied_Change_code__c = changeCodeId;
		log.Web_Service__c = 'callout:'+namedCredential + body;
		log.Input_Description__c= 'body:' + body;
		log.Method__c = action;
		log.Web_Service__c = String.valueOf(req);

		try{
			log.Response__c = res.getBody();
		}catch(exception e){}

		if(!(res.getStatusCode() > ANG_IEP_CalloutHelper.STATUSOKLOWER   && res.getStatusCode() < ANG_IEP_CalloutHelper.STATUSOKHIGHER )){
			System.debug('ANG_CalloutIEPMasterdata: Payload could not be sent with success.');
			//throw new AMS_ApplicationException('ANG_CalloutIEPMasterdata: The masterdata could not be sent to IEP. Status:' + res.getStatusCode() + ' - Reason:'+ res.getStatus());
			log.Error_Code__c = String.valueOf(res.getStatusCode());
			log.Error_Message__c = res.getStatus();
			log.Success__c = false;
			ServiceNow_Helper.sendRequestToSNOWMulesoft('JSD2', iatacode, log);
		}
		else{
			System.debug('ANG_CalloutIEPMasterdata: Payload sent with success.');
			log.Success__c = true;
		}

		insert log;
		ANG_IEP_CalloutHelper.updateAgencyEvent(agencyUpdateId,log.Success__c);
	}

	public class executeCalloutQueueable implements Queueable, Database.AllowsCallouts {

		private String body;
		private String action;
		private String namedCredential;
		private String changeCodeId;
		private String agencyUpdateId;
		private String iataCode;

		public executeCalloutQueueable(String body, String action, String namedCredential, String changeCodeId, String agencyUpdateId, String iataCode){
			this.body =	body;
			this.action = action;
			this.namedCredential = namedCredential;
			this.changeCodeId =	changeCodeId;
			this.agencyUpdateId = agencyUpdateId;
			this.iataCode =	iataCode;
		}

		public void execute(QueueableContext context){
			executeCallout(body, action, namedCredential, changeCodeId, agencyUpdateId, iataCode);
		}

	}
}
