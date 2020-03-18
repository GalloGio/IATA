public with sharing class Attachment_Dom
{
	/****************************************************************************************************
			Data variables
	****************************************************************************************************/
	private List<Attachment> newList = new List<Attachment>();
	private List<Attachment> oldList = new List<Attachment>();
	private Map<Id, Attachment> newMap = new Map<Id, Attachment>();
	private Map<Id, Attachment> oldMap = new Map<Id, Attachment>();


	/****************************************************************************************************
			Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
		//*** instantiate the domain class to prevent too many static methods
		Attachment_Dom exe = new Attachment_Dom();

		//*** call handler method corresponding to trigger event
		if (trigger.isBefore) {
		 	if (trigger.isInsert) exe.onBeforeInsert();
			else if (trigger.isUpdate) exe.onBeforeUpdate();
			/*else if (trigger.isDelete) exe.onBeforeDelete();*/
		} else if (trigger.isAfter) {
			/*if (trigger.isInsert) exe.onAfterInsert();
			else if (trigger.isUpdate) exe.onAfterUpdate();
			else*/ if (trigger.isDelete) exe.onAfterDelete();
		}
	} //*** end of "triggerHandler"


	/****************************************************************************************************
			Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
			newList = (List<Attachment>) trigger.new;
			newMap = (Map<Id, Attachment>) trigger.newMap;
		}
		if (oldDataAvailable) {
			oldList = (List<Attachment>) trigger.old;
			oldMap = (Map<Id, Attachment>) trigger.oldMap;
		}
	} //*** end of "getData"

	/****************************************************************************************************
			Method for event
	****************************************************************************************************/
	private void onBeforeInsert() {
		getData(true, true);

		//-- Validate Attachement for T&C is PDF document and unique document
		Attachment_Svc.validateTnCAttachmentExist(newList);
		Attachment_Svc.validateAttachmentIsPDF(newList);
	}

	private void onBeforeUpdate() {
		getData(true, true);
		Attachment_Svc.validateAttachmentIsPDF(newList);
	}

	private void onAfterDelete() {
		getData(true, true);
		Attachment_Svc.setTnCDeletedFlag(oldList);
	}

	/*private void onAfterInsert() {
		getData(true, true);
	}*/

	/*private void onAfterUpdate() {
		getData(true, true);
	}*/

	/*private void onBeforeDelete() {
		getData(false, true);
	}*/


}
