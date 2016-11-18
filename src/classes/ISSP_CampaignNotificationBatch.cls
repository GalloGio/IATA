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