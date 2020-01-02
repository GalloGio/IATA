/****************************************************************************************************
	Created by Kevin Ky 2015-01-27

****************************************************************************************************/
public class CampaignMember_Dom{
	/****************************************************************************************************
			Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
		//*** instantiate the domain class to prevent too many static methods
		CampaignMember_Dom exe = new CampaignMember_Dom();

		//*** call handler method corresponding to trigger event
		if (trigger.isBefore) {
			if (trigger.isInsert) exe.onBeforeInsert();
			/*else if (trigger.isUpdate) exe.onBeforeUpdate();
			else if (trigger.isUpdate) exe.onBeforeUpdate();
			else if (trigger.isDelete) exe.onBeforeDelete();*/
		} else if (trigger.isAfter) {
			 /*    if (trigger.isInsert) exe.onAfterInsert();
			else if (trigger.isUpdate) exe.onAfterUpdate();
			else if (trigger.isDelete) exe.onAfterDelete();*/
		}
	} //*** end of "triggerHandler"


	/****************************************************************************************************
			Data variables
	****************************************************************************************************/
	private List<CampaignMember> newList = new List<CampaignMember>();
	private List<CampaignMember> oldList = new List<CampaignMember>();
	private Map<Id, CampaignMember> newMap = new Map<Id, CampaignMember>();
	private Map<Id, CampaignMember> oldMap = new Map<Id, CampaignMember>();

	/****************************************************************************************************
			Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
			newList = (List<CampaignMember>) trigger.new;
			newMap = (Map<Id, CampaignMember>) trigger.newMap;
		}
		if (oldDataAvailable) {
			/*oldList = (List<CampaignMember>) trigger.old;
			oldMap = (Map<Id, CampaignMember>) trigger.oldMap;*/
		}
	} //*** end of "getData"

	/****************************************************************************************************
			Method for event
	****************************************************************************************************/
	private void onBeforeInsert() {
		getData(true, false);
		//Prevent user to add a new campaign member
		CampaignMember_Svc.validateAddingCampaignMembers(newList);
	}


}
