global class CreateNotificationsFromQueryBatch implements Database.Batchable<sObject>{

	Notification_template__c template;
	private String query;

	global CreateNotificationsFromQueryBatch(Notification_template__c template,Id networkId, String category, String sector, List<String> countries, String portalService) {

		this.template = template;
		this.query = 'SELECT ContactId FROM User WHERE ContactId != null AND Id in (SELECT MemberId from NetworkMember where NetworkId = \'' + networkId + '\') ';

		if(category != null && !string.isEmpty(category)){
			this.query += ' AND Contact.Account.Category__c = \'' + string.escapeSingleQuotes(category) + '\'' ;
		}
		if(sector != null && !string.isEmpty(sector)){
			 this.query += ' AND Contact.Account.Sector__c = \'' + string.escapeSingleQuotes(sector) + '\'';
		}
		if(countries != null && countries.size() > 0 ){
			this.query += ' AND Contact.Account.IATA_ISO_Country__r.Name IN (\'' + String.join(countries, '\',\'') + '\')' ;
		}
		if(portalService != null && !string.isEmpty(portalService)){
			this.query += ' AND ContactId IN (SELECT Contact__c From  Portal_Application_Right__c WHERE Portal_Application__r.Name = \'' + portalService + '\' AND Right__c = \'Access Granted\') ';
		}
		if(Test.isRunningTest()){
			this.query += ' LIMIT 2';
		}
	}

	 global Database.QueryLocator start(Database.BatchableContext context){
		 return Database.getQueryLocator(this.query);
	 }

	 global void execute(Database.BatchableContext context, List<sObject> users){
		List<User> usersList =  (List<User>)users;
		List<Notification__c> notifications = new List<Notification__c>();

		for(User user : usersList){
			notifications.add(new Notification__c(
				Contact__c = user.ContactId,
				Message__c = this.template.Message__c,
				Alert_Contact_By_Email__c = this.template.Alert_Contact_By_Email__c,
				Alert_Contact_By_Push_Notification__c = this.template.Alert_Contact_By_Push_Notification__c,
				Subject__c = this.template.Subject__c,
				Type__c = this.template.Type__c,
				Notificatin_color__c = this.template.Notification_color__c,
				Notification_Campagne_Name__c = '',
				Critical_notification__c = this.template.CriticalNotification__c,
				Expiry_date__c = system.Now() + this.template.Expire_in_days__c
			));
		}
		insert notifications;
	 }

	 global void finish(Database.BatchableContext context){
	 }
}
