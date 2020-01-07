/**
 * Encapsulates all behaviour logic relating to the zqu__ZProduct__c object
 *
 * @author: kevin ky <kevin.ky@cgi.com>
 * @date: 2015-08-18
 *
 *
 **/
public without sharing class ZProduct_Dom {

/****************************************************************************************************

		Call trigger method corresponding to trigger event
****************************************************************************************************/
public static void triggerHandler() {
	//*** instantiate the domain class to prevent too many static methods
	ZProduct_Dom exe = new ZProduct_Dom();

	//*** call handler method corresponding to trigger event
	if (trigger.isBefore) {
			 /*if (trigger.isInsert) exe.onBeforeInsert();
		else if (trigger.isUpdate) exe.onBeforeUpdate();
		else if (trigger.isDelete) exe.onBeforeDelete();*/
	} else if (trigger.isAfter) {
			 if (trigger.isInsert) exe.onAfterInsert();
		/*else if (trigger.isUpdate) exe.onAfterUpdate();
		else if (trigger.isDelete) exe.onAfterDelete();*/
	}
} //*** end of "triggerHandler"


/****************************************************************************************************
		Data variables
****************************************************************************************************/
private List<zqu__ZProduct__c> newList = new List<zqu__ZProduct__c>();
//private List<zqu__ZProduct__c> oldList = new List<zqu__ZProduct__c>();
private Map<Id, zqu__ZProduct__c> newMap = new Map<Id, zqu__ZProduct__c>();
//private Map<Id, zqu__ZProduct__c> oldMap = new Map<Id, zqu__ZProduct__c>();


/****************************************************************************************************
		Set trigger data to data variables
****************************************************************************************************/
private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
	if (newDataAvailable) {
		newList = (List<zqu__ZProduct__c>) trigger.new;
		newMap = (Map<Id, zqu__ZProduct__c>) trigger.newMap;
	}
	/*if (oldDataAvailable) {
		oldList = (List<zqu__ZProduct__c>) trigger.old;
		oldMap = (Map<Id, zqu__ZProduct__c>) trigger.oldMap;
	}*/
} //*** end of "getData"


/****************************************************************************************************
		Method for event
****************************************************************************************************/
/*private void onBeforeInsert() {
	//getData(true, false);
}
private void onBeforeUpdate() {
	//getData(true, true);
}
private void onBeforeDelete() {
	//getData(false, true);
}*/
private void onAfterInsert() {
	getData(true, false);
	//Link the zProduct to Product
	ZProduct_Svc.setZuoraProductField(newList);
}
/*private void onAfterUpdate() {
	//getData(true, true);

}
private void onAfterDelete() {
	//getData(false, true);
}*/



}//*** end of class
