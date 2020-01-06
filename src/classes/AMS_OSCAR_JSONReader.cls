public with sharing class AMS_OSCAR_JSONReader {
	/*

	public static AMS_OSCAR__c lifecycleRequest {get;set;}
	public static List<String> steps {get;set;}
	public static Map<String,List<String>> flows {get;set;}
	public static Map<String,String> labels {get;set;}
	public static Map<String,String> status {get;set;}
	public static String theFirst { get{
		return steps.get(0);
		}set;
	}
	public static Map<String,List<String>> requirements;
	public static Map<String,List<String>> actions{get;set;}
	public static Map<String,Map<String,List<String>>> automations{get;set;}
	public static Map<String,List<String>> process {get;set;}
	public static Boolean renderEventCreator {get;set;}
	public static AMS_OSCAR_Event__c lifecycleEvent {get;set;}
	public static String stepLabel {get;set;}

	public AMS_OSCAR_JSONReader() {
		renderEventCreator = false;
		//stdController.addFields(new List<String> {'Process__c','STEP1__c','STEP2__c','STEP3__c','STEP4__c','STEP5__c','STEP6__c','STEP7__c','STEP8__c','STEP9__c','STEP10__c','STEP11__c','STEP12__c','STEP13__c','STEP14__c','STEP15__c','STEP16__c','STEP17__c','STEP18__c','STEP19__c','STEP20__c'});
		//this.lifecycleRequest = (AMS_OSCAR__c)stdController.getRecord();
		//lifecycleEvent = new AMS_OSCAR_Event__c(Lifecycle_Request__c = this.lifecycleRequest.id);

		String currentStep = null;
		String currentFlow = null;
		String currentProcess = null;
		String currentFunction = null;

		String currentStatus = null;
		String currentClass = null;
		String currentMethod = null;
		String currentParam = null;


		steps = new List<String>();
		flows = new Map<String,List<String>>();
		requirements = new Map<String,List<String>>();
		process = new Map<String,List<String>>();
		actions = new Map<String,List<String>>();
		labels = new Map<String,String>();
		automations = new Map<String,Map<String,List<String>>>();
		Map<String,List<String>> functions = new Map<String,List<String>>();
		Map<String,List<String>> automationStatus = new Map<String,List<String>>();
		StaticResource sr = [select Body from StaticResource where Name = 'JSON_OSCAR_Process'];
		String jsonstring = sr.Body.toString();
		JSONParser parser = JSON.createParser(jsonstring);
		while (parser.nextToken() != null) {
			if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() != 'FLOW'){
				currentProcess = parser.getCurrentName();
				process.put(currentProcess, new List<String>());
			}
			if(parser.getCurrentName() == 'FLOW'){
				while(parser.nextToken()!= JSONToken.END_OBJECT){
					if(parser.getCurrentName() == 'NAME'){
						parser.nextToken();
						currentFlow = parser.getText();
						labels.put(currentFlow, currentFlow);
						flows.put(currentFlow,new List<String>());
						process.get(currentProcess).add(currentFlow);
					}
					if(parser.getCurrentName() == 'STEPS'){
						while(parser.nextToken() != JSONToken.END_OBJECT){
							if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
								currentStep = parser.getText();
								steps.add(currentStep);
								flows.get(currentFlow).add(currentStep);
								requirements.put(currentStep, new List<String>());
								actions.put(currentStep, new List<String>());
								automations.put(currentStep, new Map<String,List<String>>());
								while(parser.nextToken() != JSONToken.END_OBJECT){
									if(parser.getCurrentName() == 'LABEL'){
										parser.nextToken();
										labels.put(currentStep,parser.getText());
									}
									if(parser.getCurrentName() == 'REQUIRED'){
										while(parser.nextToken() != JSONToken.END_ARRAY){
											if(parser.getCurrentToken() == JSONToken.VALUE_STRING){
												requirements.get(currentStep).add(parser.getText());
											}
										}
									}
									if(parser.getCurrentName() == 'ACTIONS'){
										while(parser.nextToken() != JSONToken.END_ARRAY){
											//if(parser.getCurrentToken() == JSONToken.VALUE_STRING){
											//    actions.get(currentStep).add(parser.getText());
											//}
											if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'FUNCTIONNAME'){
												parser.nextToken();
												currentFunction = parser.getText();
												actions.get(currentStep).add(currentFunction);
												functions.put(currentFunction, new List<String>());
												while(parser.nextToken() != JSONToken.END_OBJECT){
													if(parser.getCurrentToken() == JSONToken.VALUE_STRING){
														functions.get(currentFunction).add(parser.getText());
													}
												}
											}
										}
									}
									if(parser.getCurrentName() == 'AUTOMATION'){
										automationStatus = new Map<String,List<String>>();
										while(parser.nextToken() != JSONToken.END_ARRAY){
											//if(parser.getCurrentToken() == JSONToken.VALUE_STRING){
											//    actions.get(currentStep).add(parser.getText());

											////}

											//"":"OK",
											//"CLASS":"AMS_OSCARUpdateWebservice",
											//"METHOD":"updateOSCAR_ChangeEffectiveDate",
											//"PARAM":"agencyId"

											if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'STATUS'){
												parser.nextToken();
												currentStatus = parser.getText();

												//System.debug('currentStep: ' + currentStep);
												//System.debug('currentStatus: ' + currentStatus);


												//functions.put(currentFunction, new List<String>());
												while(parser.nextToken() != JSONToken.END_OBJECT){
													if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'CLASS'){
														parser.nextToken();
														currentClass = parser.getText();
													}
													if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'METHOD'){
														parser.nextToken();
														currentMethod = parser.getText();
													}
													if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'PARAM'){
														parser.nextToken();
														currentParam = parser.getText();
													}

												}
												List<String> ls = new List<String>();
												ls.add(currentClass);
												ls.add(currentMethod);
												ls.add(currentParam);
												automationStatus.put(currentStatus,ls);
												automations.put(currentStep,automationStatus);
											}
											//if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'CLASS'){
											//    parser.nextToken();
											//    currentClass = parser.getText();
											//    automations.get(currentStep).add(currentClass);
											//}
											//if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'METHOD'){
											//    parser.nextToken();
											//    currentMethod = parser.getText();
											//    automations.get(currentStep).add(currentMethod);
											//}
											//if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'PARAM'){
											//    parser.nextToken();
											//    currentParam = parser.getText();
											//    automations.get(currentStep).add(currentParam);
											//}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		system.debug('AMS_OSCAR_JSONReader JSON - steps - ' + steps);
		system.debug('AMS_OSCAR_JSONReader JSON - flows - ' + flows);
		system.debug('AMS_OSCAR_JSONReader JSON - requirements - ' + requirements);
		system.debug('AMS_OSCAR_JSONReader JSON - process - ' + process);
		system.debug('AMS_OSCAR_JSONReader JSON - actions - ' + actions);
		system.debug('AMS_OSCAR_JSONReader JSON - labels - ' + labels);
		system.debug('AMS_OSCAR_JSONReader JSON - functions - ' + functions);
		system.debug('AMS_OSCAR_JSONReader JSON - automations - ' + automations);
	   // system.debug('JSON - dependent - ' + dependent);

	}


	public static List<String> getAutomations(String sSTEP, String sSTATUS){

		if(automations == null){
			System.debug('Call AMS_OSCAR_JSONReader Construtor');
			AMS_OSCAR_JSONReader x = new AMS_OSCAR_JSONReader();

		}else{
			System.debug('Cache!! AMS_OSCAR_JSONReader Construtor');
		}

		Map<String,List<String>> mapAuto = automations.get(sSTEP);
		system.debug('AMS_OSCAR_JSONReader JSON - ' + sSTEP + ' ' + mapAuto);

		List<String> ls = mapAuto.get(sSTATUS);

		return ls;
	}


	@future(callout=true)
	public static void doAUTOMATION(String sessionID, List<String> param){

		system.debug('Start AUTOMATION Request');

		HttpRequest req = new HttpRequest();
		//req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
		req.setHeader('Authorization', 'Bearer ' + sessionID);
		req.setHeader('Content-Type', 'application/json');

		String sCode = '';
		sCode = param.get(0) + '.' + param.get(1) + '(\''+ param.get(2) + '\');';


		//String sCode = 'AMS_OSCARUpdateWebservice.updateOSCAR_ChangeEffectiveDate(\''+this.lifecycleRequest.Agency__c+'\');';
		//String sCode = 'AMS_OSCARUpdateWebservice.updateOSCAR_ChangeEffectiveDate(\'teste\');';


		//AMS_OSCARUpdateWebservice.updateOSCAR_ChangeEffectiveDate('a0Mg00000051hIzEAI');
		//system.debug('AUTOMATION Request - ' + sCode);

		req.setEndpoint('https://cs17.salesforce.com/services/data/v28.0/tooling/executeAnonymous/?anonymousBody='+sCode);

		req.setMethod('GET');

		Http h = new Http();
		HttpResponse res = h.send(req);
		system.debug(res.getBody());
		//ToolingAPI.ExecuteAnonymousResult toolingResult = x.executeAnonymousUnencoded('
			//AMS_OSCARUpdateWebservice.AMS_OSCARUpdateWebservice(\''+this.lifecycleRequest.Agency__c+'\');');

	}

	public static void doAUTOMATION_v2(List<String> param, AMS_OSCAR_Event__c lce, AMS_OSCAR__c oscar){

		String sClass = param.get(0);
		String sMethod = param.get(1);

		if(sClass != Null && !sClass.equalsIgnoreCase('')){
		   AMS_OSCAR_AutomationManager am = new AMS_OSCAR_AutomationManager();
		   Boolean b = am.newClassInstance(sClass).processWork(lce, oscar);

		   system.debug('doAUTOMATION_v2 res: ' + b);
		}


	}*/
}
