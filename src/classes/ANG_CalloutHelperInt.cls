global interface ANG_CalloutHelperInt {

	String fetchEndPoint(ANG_CalloutMapping__c mappingObj);
	String serializeData(Object obj);
	void doCallOut(Object obj, ANG_CalloutMapping__c mappingObj, String changeCodeId, Boolean isRunningBatch);

}