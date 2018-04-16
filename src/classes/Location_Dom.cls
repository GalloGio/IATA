public with sharing class Location_Dom {
	/****************************************************************************************************
	        Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
	    //*** instantiate the domain class to prevent too many static methods
	    Location_Dom exe = new Location_Dom();
	    
	    //*** call handler method corresponding to trigger event
	    if (trigger.isBefore) {
            if (trigger.isInsert) exe.onBeforeInsert();
	        else if (trigger.isUpdate) exe.onBeforeUpdate();
	        else if (trigger.isDelete) exe.onBeforeDelete();
	    }
	    else if (trigger.isAfter)
	    {
	        if (trigger.isInsert) exe.onAfterInsert();
	        else if (trigger.isUpdate) exe.onAfterUpdate();
	    }
	} //*** end of "triggerHandler"

	/****************************************************************************************************
	        Data variables
	****************************************************************************************************/
	private List<Location__c> newList = new List<Location__c>();
	private List<Location__c> oldList = new List<Location__c>();
	private Map<Id, Location__c> newMap = new Map<Id, Location__c>();
	private Map<Id, Location__c> oldMap = new Map<Id, Location__c>();
	
	/****************************************************************************************************
	        Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
	        newList = (List<Location__c>) trigger.new;
	        newMap = (Map<Id, Location__c>) trigger.newMap;
		}
	    if (oldDataAvailable) {
	        oldList = (List<Location__c>) trigger.old;
	        oldMap = (Map<Id, Location__c>) trigger.oldMap;
	    }
	} //*** end of "getData"

	/****************************************************************************************************
	        Method for event
	****************************************************************************************************/
	private void onBeforeInsert(){
		getData(true, false);
		System.debug('Before Insert Location');
		//Set the correct Parent Account base on the Contact
		Location_Svc.setLocationAccountId(newList, null, true);
		
		// Validation Location record before proceeding, use the returned list in place of the newList from now on		
        Location_Svc.IsLocationValid(newList);
	}
	
	private void onBeforeUpdate(){
		getData(true, true);
		System.debug('Before Update Location');
		//Set the correct Parent Account base on the Contact
		Location_Svc.setLocationAccountId(newList, oldMap, false);
		
		// Validation Location record before proceeding, use the returned list in place of the newList from now on		
		Location_Svc.IsLocationValid(newList);
	}

	private void onAfterInsert() {
	    getData(true, false);
	    
		//Sync to SAP
		List<Location__c> locationsToSync = new List<Location__c>();
		for (Integer i = 0; i < newList.size(); i++)
			if (newList[i].Active__c == true && String.isBlank(newList[i].SAP_Id__c))
				locationsToSync.add(newList[i]);
		if (locationsToSync.size() > 0)
			Location_Svc.SendLocationToSAP(locationsToSync);
	}
	
	private void onAfterUpdate() {
		// This is a special custom setting to be added for each test class, and it is used to force skipping the trigger to avoid running into SOQL limits
		if (Test.isRunningTest() && Utility.getNumericSetting('Execute Trigger Location') != 1) return;
		
	    getData(true, true);
	    
		// Sync location updates to SAP and Zuora
	    Location_Svc.syncLocationsUpdateWithExternalSystems(newList, oldMap);
	    
	    //Sync to SAP the location billTo and ShipTo
        List<Location__c> locationsToSync = new List<Location__c>();
        //Set to keep the locations that were deactivated
        Set<Id> deactivatedlocationsList = new Set<Id>();

        for (Integer i = 0; i < newList.size(); i++){
            if (newList[i].Active__c == true && oldList[i].SAP_Id__c == newList[i].SAP_Id__c &&
                (oldList[i].Address__c != newList[i].Address__c || oldList[i].Email__c != newList[i].Email__c ||
                 oldList[i].Phone__c != newList[i].Phone__c || oldList[i].VAT_Number__c != newList[i].VAT_Number__c)){
             
                locationsToSync.add(newList[i]);
            }
            //Check if the location was deactivated by a Standard Type of user- INC376899
            if(!newList[i].Active__c && UserInfo.getUserType().equals('Standard')){
            	deactivatedlocationsList.add(newList[i].Id);
            }
        }

        if(locationsToSync.size() > 0){
            Location_Svc.SendLocationToSAP(locationsToSync);
        }

		//Verifies if there are deactivated locations - INC376899
		if(deactivatedlocationsList.size() > 0 ){
			//Retrieves the orders that have this locations and delete them
			List<Order> ordersToDelete = Order_Sel.getNewOrdersByLocation(deactivatedlocationsList);
			delete ordersToDelete;
		}

	}

	private void onBeforeDelete(){
		getData(false, true);

		//-- Forbid deletion once SAP Id is assigned
		Location_Svc.forbidSAPLocationDeletion(oldList);
	}
}