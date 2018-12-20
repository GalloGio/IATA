/*
	Class that sends massive campaing notifications to Portal Users
	Used in Portal and NewGen APP (mobile)
*/
global with sharing class ISSP_CampaignNotificationBatch implements Database.Batchable<sObject>{

	global string query = '';
	global string notificationId = '';
	global string vNotificationCampagneName = '';
	global static string notificationCampagneName = '';
	//DTULLO 20160208. Added for DDS managemente
	global boolean bIsDDS = false;
	 
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	notificationCampagneName = vNotificationCampagneName;
    	set<Id> contactIdSet = new set<Id>();

    	//DTULLO: Added for DDS
    	set<Id> setAccntId = new set<Id>();
		for(CampaignMember cm : (list<CampaignMember>)scope){
			if(cm.ContactId != null)
			contactIdSet.add(cm.ContactId);
		}
		list<Contact> contactList = [select Id,Notification_template__c, AccountId from Contact where Id in:contactIdSet];

		for(Contact con : contactList){
			con.Notification_template__c = notificationId;
			
			//DTULLO 20160208. DDS
			if(bIsDDS)
				setAccntId.add(con.AccountId);
		}

		ISSP_CreateNotification.CreateNotificationForSobjectList(contactList);
		//update contactList;

		// Start NewGenApp
		NewGenApp_Custom_Settings__c newgenCS = NewGenApp_Custom_Settings__c.getOrgDefaults();
		if(newgenCS != null && newgenCS.Push_Notifications_State__c){
			List<User> userList = [select Id, ContactId from user where ContactId in :contactIdSet];
			
			Notification_template__c template = [select Name, Id, Subject__c, Message__c from Notification_template__c where Name = :notificationId];

			for(User user: userList){
				set<String> userIdPush = new set<String>();
				userIdPush.add(String.valueOf(user.Id));

				NewGen_Account_Statement_Helper.sendPushNotification(userIdPush, template.subject__c, new List <String> {template.Message__c}, 'PUSH_NOTIFICATION');
			}
		}
		// End NewGenApp


		//DTULLO 20160208. DDS
		if(bIsDDS && !setAccntId.isEmpty()){
			list<Account> lsAccnt = [select Id, DDS_Last_Notification_Date__c, DDS_Status__c from Account where Id in:setAccntId];
			if(!lsAccnt.isEmpty()){
				for(Account a:lsAccnt){
					a.DDS_Last_Notification_Date__c = system.Today();
					a.DDS_Status__c = 'No Reply';
				}
				
				try{
					list<Database.SaveResult> lsSR = database.update(lsAccnt, false);
				}
				catch(exception e){
					
				}
			}
		}
    }
	
	global void finish(Database.BatchableContext BC){

    }
    
}