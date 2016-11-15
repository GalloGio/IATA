public with sharing class Account_Svc {
	
	/**
	 * Function will sync any new updates on Account object to SAP
	 *
	 * Test Coverage: Provided in the class Location_Dom_Test
	 **/
	public static void syncAccountUpdateWithExternalSystems(List<Account> lstAccount, Map<Id,Account> mapOldAccount)
	{
		/* Commented till figure out whether we are going to filter using recordtypes or not
		// Retrieve list of RecordTypeIds that are allowed to be synced to SAP
		String sAccRecTypeToSAP = Utility.getTextSetting('Account Record Type IDs to sync to SAP');
		Set<Id> setAccRecTypeToSAP = new Set<Id>((List<Id>) sAccRecTypeToSAP.split(','));
		*/
		
		// Retrieve list of fields that are allowed to be synced to SAP
		List<String> lstAccFieldsToSAP = Utility.getSeqTextSetting('Account fields to sync to SAP', ',').split(',');
		
		Set<Id> setAccIdsToSync = new Set<Id>();

		//Select only accounts that respond to certain criteria
		list<Account> accsToPass = new list<Account>();
		for (Account runAccs : lstAccount)
		{
			if(runAccs.ACLI_SAP_Id__c == null && runAccs.ACLI_Status__c != 'Active company') {
				accsToPass.add(runAccs);
			}
		}
		
	    for (Account acc : accsToPass)
	    {
	    	/* Commented till figure out whether we are going to filter using recordtypes or not
    		// Make sure that the account has the required RecType
	    	if (setAccRecTypeToSAP.contains(acc.RecordTypeId))
	    	{
	    	*/
	    		// Check that specific list of fields are modified to sync to SAP
	    		if (!lstAccFieldsToSAP.isEmpty())
	    		{
		    		for(String field : lstAccFieldsToSAP)
		    		{
	                    if(!String.isBlank(field) && acc.get(field) != mapOldAccount.get(acc.Id).get(field))
	                    {
				    		setAccIdsToSync.add(acc.Id);
				    		break;
	                    }
	                }
	    		}
	    	/*}*/
	    }
	    
	    // The map of Location that will be synced with SAP
	    Map<Id, Location__c> mapLocation = new Map<Id, Location__c>(
	    	[SELECT Id
	    	FROM Location__c
	    	WHERE Account__c IN :setAccIdsToSync
	    		AND Type__c = 'Sold To'
	    		AND Active__c = true]);
	    
	    // Make the SAP call to update the account/contact
	    if (!mapLocation.isEmpty())
	    {
	    	IECAddress_Svc.syncCustomerMasterWithSAP(mapLocation.keySet());
	    }
    }
}