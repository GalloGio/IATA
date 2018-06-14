global interface ANG_CalloutHelperInt {

	String fetchEndPoint(ANG_CalloutMapping__c mappingObj);
	void doCallOut(Object obj, ANG_CalloutMapping__c mappingObj, String changeCodeId,String agencyUpdateId, String iataCode, Boolean isRunningBatch);
}