public  with sharing class ANG_IEP_CalloutHelper {
	

	//**** =========================== Variable Assignment =================================== ****
	public static final Integer STATUSOKLOWER  = 199;
	public static final Integer STATUSOKHIGHER = 300;
	public static final Integer THRESHOLD = 40;
	public static boolean isRunningTestForThreshold = false;
	public static String INTEGRATIONSYSTEM_MULESOFT = 'Mulesoft';
	public static String INTEGRATIONSYSTEM_SAPPI = 'SAP PI';
	public static String MULESOFTPREFIX = 'MS_';




	 //**** ===========================SECONDARY CLASSES =================================== ****

	public class ANG_calloutHelperWrapper {
	    public ANG_CalloutMapping__c calloutMapping{get;set;}
		public ANG_IEP_CalloutHelper.AgencyEvent2Send rec2Send{get;set;}
		public String changeCodeId{get;set;}
		public string agencyUpdateId{get;set;}
		

		public ANG_calloutHelperWrapper(ANG_CalloutMapping__c cm,ANG_IEP_CalloutHelper.AgencyEvent2Send aer,String ccId,String auId){
			calloutMapping=cm;
			rec2Send=aer;
			changeCodeId=ccId;
			agencyUpdateId=auId;
		}

	}
	public class AgencyEvent2Send{  // mulesoft request structure

			private String EventType;
			private String changeCode;
			public String IATACode{get;private set;}

			public AgencyEvent2Send(string et,string cc,string ic){
				EventType=et;
				changeCode=cc;
				IATACode=ic;
			}
		}



	 //**** ===========================  ACTION METHODS  =================================== ****

	  @InvocableMethod(label='Create a payload to be sent to mulesoft' description='Create a payload to be sent to mulesoft')
    public static void invokeCustomImpl(List<Agency_Applied_Change_code__c> objList) {}

    public static void invokeCustomImpl(List<AMS_Agency_Updates__c> agencyEventsList) {
    	
		Map<String,Id> changeCodeIdMap = new Map<String,Id>();

		Map<String,ANG_CalloutMapping__c> calloutMappingMap = new Map<String,ANG_CalloutMapping__c>();
		for(ANG_CalloutMapping__c cm: ANG_CalloutMapping__c.getall().values()){
			calloutMappingMap.put(cm.id,cm);
		}

		list<ANG_IEP_CalloutHelper.ANG_calloutHelperWrapper> records2SendList = new list<ANG_IEP_CalloutHelper.ANG_calloutHelperWrapper>();
		for(AMS_Agency_Updates__c ae: agencyEventsList){
			if((ae.Integration_System__c==INTEGRATIONSYSTEM_MULESOFT || ae.Integration_System__c==INTEGRATIONSYSTEM_SAPPI) && calloutMappingMap.keySet().contains(ae.ConfigurationID__c)){
				ANG_IEP_CalloutHelper.AgencyEvent2Send tempchw =new ANG_IEP_CalloutHelper.AgencyEvent2Send((ae.ANG_Account_Portal_Service__c!=null?ae.ANG_Account_Portal_Service__c+'.':'')+ae.Update_Type__c.replace(MULESOFTPREFIX,''),ae.Change_Code__c,ae.IATACode__c);
				records2SendList.add( new ANG_IEP_CalloutHelper.ANG_calloutHelperWrapper(calloutMappingMap.get(ae.ConfigurationID__c),tempchw,ae.Agency_Applied_Change_code__c,ae.id));
			}
		}
	

		//so since Salesforce governor limits don't allow us to have more than 50 future calls in a single apex transition, and some times change codes propagate to 
		// an hierarchy that has > 50 agencies, we need to queue the calls in a batch.

		system.debug('ANG_IEP_CalloutHelper records2SendList'+records2SendList);
		
		if((records2SendList.size() + System.Limits.getFutureCalls()) < THRESHOLD && !isRunningTestForThreshold){

			System.debug('The change codes size is bellow THRESHOLD ('+THRESHOLD+'). Running future method process.');

			for(ANG_calloutHelperWrapper item: records2SendList){
				invokeChangeCodeImpl(item.calloutMapping,item.rec2Send,item.changeCodeId,item.agencyUpdateId,item.rec2Send.IATACode,false);
			}

		}else{

			ANG_IEPChangecodeInvocationBatch iEPChangecodeInvocationBatch = new ANG_IEPChangecodeInvocationBatch(records2SendList);

			Id iEPChangecodeInvocationBatchId;

			if(!Test.isRunningTest())
				iEPChangecodeInvocationBatchId = Database.executeBatch(iEPChangecodeInvocationBatch,1);
			else
				iEPChangecodeInvocationBatchId = Database.executeBatch(iEPChangecodeInvocationBatch);

			System.debug('Running the ANG_IEPChangecodeInvocationBatch with Id:'+iEPChangecodeInvocationBatchId);

		}
	
	}


	public static void invokeChangeCodeImpl(ANG_CalloutMapping__c calloutMapping, Object obj, String changeCodeId, String agencyUpdateId, String iataCode, Boolean isRunningBatch){

		// Get the Type corresponding to the class name
		Type t = Type.forName(calloutMapping.CalloutClass__c);

		ANG_CalloutHelperInt callout = (ANG_CalloutHelperInt)t.newInstance();

		callout.doCallOut(obj, calloutMapping, changeCodeId, agencyUpdateId, iataCode, isRunningBatch);
	}


	public static void updateAgencyEvent(String aeId,boolean isSuccess){ //updates agency update after communication

		if(aeId!=null){
			AMS_Agency_Updates__c aeRecord= [select id,Update_Type__c from AMS_Agency_Updates__c where id =:aeId];
			aeRecord.Update_Type__c=isSuccess?(aeRecord.Update_Type__c.replace(MULESOFTPREFIX,'')+'_Sent'):'Error';
			update aeRecord;
		}
	}

	
	

}