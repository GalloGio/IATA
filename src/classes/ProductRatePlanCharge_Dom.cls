/****************************************************************************************************
    Created by David D 2015-09-22
       This class contains all the methods call for the trigger on zqu__ProductRatePlanCharge__c
****************************************************************************************************/
public with sharing class ProductRatePlanCharge_Dom 
{
	/****************************************************************************************************
	    Created by CGI, David D 2015-09-22
	        Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
	    //*** instantiate the domain class to prevent too many static methods
	    ProductRatePlanCharge_Dom exe = new ProductRatePlanCharge_Dom();
	    
	    //*** call handler method corresponding to trigger event
	    if (trigger.isAfter) {
	        if (trigger.isInsert) exe.onAfterInsert();
	        else if (trigger.isUpdate) exe.onAfterUpdate();
	    }
	} //*** end of "triggerHandler"


	/****************************************************************************************************
	    Created by CGI, David D 2015-09-22
	        Data variables
	****************************************************************************************************/
	private List<zqu__ProductRatePlanCharge__c> newList = new List<zqu__ProductRatePlanCharge__c>();
	private List<zqu__ProductRatePlanCharge__c> oldList = new List<zqu__ProductRatePlanCharge__c>();
	private Map<Id, zqu__ProductRatePlanCharge__c> newMap = new Map<Id, zqu__ProductRatePlanCharge__c>();
	private Map<Id, zqu__ProductRatePlanCharge__c> oldMap = new Map<Id, zqu__ProductRatePlanCharge__c>();


	/****************************************************************************************************
	    Created by CGI, David D 2015-09-22
	        Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
	    if (newDataAvailable) {
	        newList = (List<zqu__ProductRatePlanCharge__c>) trigger.new;
	        newMap = (Map<Id, zqu__ProductRatePlanCharge__c>) trigger.newMap;
	    }
	    if (oldDataAvailable) {
	        oldList = (List<zqu__ProductRatePlanCharge__c>) trigger.old;
	        oldMap = (Map<Id, zqu__ProductRatePlanCharge__c>) trigger.oldMap;
	    }
	} //*** end of "getData"


	/****************************************************************************************************
	    Created by CGI, David D 2015-09-22
	        Method for event
	****************************************************************************************************/
	private void onAfterInsert() 
	{
	    getData(true, false);

	    //-- Set Stantard Price 
	    ProductRatePlanCharge_Svc.setStandardPrice(newMap, null);
	}

	private void onAfterUpdate() 
	{
	    getData(true, true);

	    //-- Set Stantard Price 
	    ProductRatePlanCharge_Svc.setStandardPrice(newMap, oldMap);
	}

}