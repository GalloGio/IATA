global class ANG_CalloutSAPMasterdata implements ANG_CalloutHelperInt{

	global static String fetchEndPoint(ANG_CalloutMapping__c mappingObj){
		return mappingObj.Credential__c;
	}

	global static void doCallOut(Object obj, ANG_CalloutMapping__c mappingObj, String changeCodeId,String agencyUpdateId , String iataCode, Boolean isRunningBatch){
        fetchEndPoint(mappingObj);
		// nothing to do here...
	}
}