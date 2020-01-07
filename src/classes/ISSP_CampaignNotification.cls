public with sharing class ISSP_CampaignNotification {

	public Notification_template__c notification {get;set;}
	public Opportunity opp {get;set;}
	public boolean successFlag {get;set;}
	public string notificationCampagneName {get;set;}

	public ISSP_CampaignNotification(){
		notification = new Notification_template__c();
		opp = new Opportunity();
		successFlag = false;
	}
	public Pagereference send(){
		list<CampaignMember> campaignMemberList = [Select c.ContactId, c.CampaignId From CampaignMember c where CampaignId =:opp.CampaignId ];

		ISSP_CampaignNotificationBatch bc = new ISSP_CampaignNotificationBatch();
		bc.query = 'Select c.ContactId, c.CampaignId From CampaignMember c where CampaignId =\''+opp.CampaignId+'\'';
		//DTULLO 20160208. Added field for DDS notification
		//Notification_template__c nt = [select Name from Notification_template__c where Id=:notification.Master_Notification_template__c];
		Notification_template__c nt = [select Name, DDS_Update_Request__c from Notification_template__c where Id=:notification.Master_Notification_template__c];
		bc.notificationId = nt.Name;
		//DTULLO 20160208
		bc.bIsDDS = nt.DDS_Update_Request__c;
		bc.vNotificationCampagneName = notificationCampagneName;
		Database.executeBatch(bc, 500);

		successFlag = true;
		return null;
	}
}
