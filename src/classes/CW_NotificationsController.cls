public without sharing class CW_NotificationsController {
	public final static String RT_NOTIFICATION_PRIVATE_AREA = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Notification__c','PrivateArea');
			
	public static List<ICG_Notification__c> setNotificationCustom(String subject, String body,String status, List<String> contactList, ICG_Account_Role_Detail__c station, String recordType){
		return setNotificationCustom(subject, body, status, contactList, station, recordType, true);
	}

	/**
	* @description		setNotificationCustom: Create an new custom notification
	* @return			String with result 
	*/
	public static List<ICG_Notification__c> setNotificationCustom(String subject, String body,String status, List<String> contactList, ICG_Account_Role_Detail__c station, String recordType, Boolean doDbOperation){
		List<ICG_Notification__c> inputList = new List<ICG_Notification__c>();

		Set<String> handledRecipients = new Set<String>(contactList);

		handledRecipients.remove('');
		handledRecipients.remove('null');
		handledRecipients.remove(null);

		List<String> handledContacts = new List<String>(handledRecipients);

		try
		{
			if (String.isNotEmpty(body) && body.length() > 255) {
				body = body.left(252) + '...';
			}
			for(String contactId : handledContacts){
				ICG_Notification__c notification = new ICG_Notification__c(Subject__c = subject, Body__c = body,Status__c = status, Short_Description__c = subject,Target_Contact__c = contactId, Station__c = station != null ? station.Id : null);
				notification.RecordTypeId = recordType;
				inputList.add(notification);
			}
			
			if(doDbOperation){
				insert inputList;
			}
		}
		catch(Exception exc) {
		}

		return inputList; 
	}
	
	/**
* @description		getNotificationsFromUser: retrieve notifications the user
* @return			NotificationWrapper serialized with the needed info in the front side
*/
	@auraEnabled(cacheable=false)
	public static String getNotificationsFromUser(Boolean viewAlertsEvents){        		
		try {                            
			User user = [SELECT Id, ContactId FROM User WHERE id = :UserInfo.getUserId() LIMIT 1];
			String userContactId = user.ContactId;
			String query = 'SELECT id,Subject__c, Body__c,Status__c,Short_Description__c,Read__c,Station__c,Station_Company__c,Station_Name__c, RecordTypeId, CreatedDate, CreatedById FROM ICG_Notification__c ';
			query += ' WHERE RecordTypeId =: RT_NOTIFICATION_PRIVATE_AREA AND Target_Contact__c =: userContactId ';
			query += viewAlertsEvents == false ? ' AND Read__c = false ' : '';
			query += ' ORDER BY CreatedDate desc ';
			return JSON.serialize(Database.query(query));
		} catch (Exception exc) {
			throw new AuraHandledException('exception: ' + exc);
		}
	}
	
	/**
  * @description	Set  List<String> of notifications for mark as read
  * @param			List<String> notificationList
  * @return			Boolean with result of operation 
  */
	@AuraEnabled
	public static String setDismissNotifications(List<String> notificationList){  
		CW_Utilities.ResponseBody res = new CW_Utilities.ResponseBody();        
		List<ICG_Notification__c> listToUpdate;
		
		try
		{
			listToUpdate = [SELECT Id, Read__c FROM ICG_Notification__c WHERE Id IN : notificationList];
			
			for(ICG_Notification__c notif : listToUpdate){
				notif.Read__c = true;
			}
			
			update listToUpdate;
			res.success = true;
		}
		catch(Exception exc) {
			res.success = false;
			res.message = exc.getMessage();
		}
		return JSON.serialize(res);
	}
}