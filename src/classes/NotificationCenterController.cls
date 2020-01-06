public with sharing class NotificationCenterController {

	@AuraEnabled(cacheable=true)
	public static List<Notification_template__c> getInformationNotificationTemplates(){
		return [SELECT Subject__c, Name FROM Notification_template__c WHERE Type__c = 'Information'];
	}

	@AuraEnabled(cacheable=true)
	public static List<AggregateResult> getPortalServicesName(){
		return [SELECT Name FROM  Portal_Applications__c GROUP BY Name];
	}

	@AuraEnabled(cacheable=true)
	public static List<IATA_ISO_Country__c> getAccountCoutries(){
		return [SELECT Name FROM IATA_ISO_Country__c ORDER BY Name];
	}

	@AuraEnabled
	public static String sendNotification(String notificationTemplate, Boolean sendEmail, List<String> contactIds){
		Notification_template__c template;
		try{
			template = [SELECT Subject__c, Name, Message__c, Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
						Expire_in_days__c, CriticalNotification__c, LanguageLocaleKey__c,Alert_Contact_By_Push_Notification__c
						FROM Notification_template__c
						WHERE  Name = :notificationTemplate];

		}catch(Exception e){
			return 'TEMPLATE ERROR';
		}

		if(contactIds == null ||contactIds.size() < 1){
			return 'none';
		}

		List<Notification__c> notifications = new List<Notification__c>();

		for(Id contactId : contactIds){
			notifications.add(new Notification__c(
				Contact__c = contactId,
				Message__c = template.Message__c,
				Alert_Contact_By_Email__c = sendEmail,
				Alert_Contact_By_Push_Notification__c = template.Alert_Contact_By_Push_Notification__c,
				Subject__c = template.Subject__c,
				Type__c = template.Type__c,
				Notificatin_color__c = template.Notification_color__c,
				Notification_Campagne_Name__c = '',
				Critical_notification__c = template.CriticalNotification__c,
				Expiry_date__c = system.Now() + template.Expire_in_days__c
			));
		}

		try{
			if(notifications.size() < 10000 && !Test.isRunningTest() || notifications.size() < 2 && Test.isRunningTest() ){
				Database.SaveResult[] srList = Database.insert(notifications,false);
				Boolean someFailed = false;
				Boolean someSucceded = false;

				for (Database.SaveResult sr : srList) {
					if (sr.isSuccess()) {
						someSucceded = true;
					}else{
						someFailed = true;
					}
				}
				if(!someFailed){
					return 'all';
				}else if(!someSucceded){
					return 'none';
				}
				return 'some';
			} else  {
				CreateNotificationsBatch batch = new CreateNotificationsBatch(notifications);
				Database.executeBatch(batch);
				return 'batch';
			}

		}catch(Exception e){
			return 'none';
		}
	}

	@AuraEnabled
	public static String sendNotificationToAll(String notificationTemplate, Boolean sendEmail, String category, String sector, List<String> countries, String portalService){
		Notification_template__c template;
		Id networkId;
		try{
			template = [SELECT Subject__c, Name, Message__c, Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
						Expire_in_days__c, CriticalNotification__c, LanguageLocaleKey__c,Alert_Contact_By_Push_Notification__c
						FROM Notification_template__c
						WHERE  Name = :notificationTemplate];

			networkId = [SELECT Id FROM Network WHERE Name = 'CS Portal'].Id;

		}catch(Exception e){
			return 'TEMPLATE ERROR';
		}

		template.Alert_Contact_By_Email__c = sendEmail;
		try{
			CreateNotificationsFromQueryBatch batch = new CreateNotificationsFromQueryBatch(template,networkId , category, sector, countries, portalService);
			Database.executeBatch(batch);
			return 'batch';
		}catch(Exception e){
			return 'none';
		}
	}
}
