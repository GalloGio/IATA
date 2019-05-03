global without sharing class ISSP_CurrencyCenterEventListingCtrl {

	public List<newsWrapper> newsList {get; set;}

	static final Integer MAX_NUM_NEWS = 8;

	public ISSP_CurrencyCenterEventListingCtrl() {

		User currentUser = [SELECT Id, Profile.Name, ContactId, Contact.Id, Contact.AccountId, Contact.Account.Id, Contact.Account.IATA_ISO_Country__c, Contact.Account.Remittance_frequency__c, Contact.Account.Location_Class__c FROM User WHERE Id = :UserInfo.getUserId() ];
		Id currentContactId = currentUser.Contact.Id;
		Id currentAccountId = currentUser.Contact.Account.Id;

		List<Task> tasksList = [SELECT Id, Subject, ActivityDate, Description, OwnerId, WhatId FROM Task WHERE ActivityDate > TODAY ORDER BY ActivityDate LIMIT 10];
		system.debug('ISSP_CurrencyCenterEventListingCtrl> Tasks List = ' + tasksList);

		List<Event> eventsList = [SELECT Id, Subject, StartDateTime, EndDateTime, IsAllDayEvent, Description, OwnerId, WhatId FROM Event WHERE StartDateTime > TODAY ORDER BY StartDateTime LIMIT 10];
		system.debug('ISSP_CurrencyCenterEventListingCtrl> Events List = ' + eventsList);

		List<newsWrapper> lstOfItems = new List<newsWrapper>();

		for (Task t: tasksList) {
			if (t.WhatId != NULL) {
				//if ((t.WhatId.getsobjecttype() == Schema.Account.getSObjectType() && t.WhatId == currentAccountId) || (t.WhatId.getsobjecttype() == Schema.Country_Profile__c.getSObjectType()) ) {
				if (t.WhatId.getsobjecttype() == Schema.Country_Profile__c.getSObjectType()) {
						newsWrapper n = new newsWrapper();
						n.idt = t.Id;
						n.title = t.Subject;
						n.typo = 'Task';
						n.start = t.ActivityDate;
						lstOfItems.add(n);
				} 
			}
			/*else if (t.OwnerId != NULL) {
				if (t.ownerId == currentUser.Id) {
						newsWrapper n = new newsWrapper();
						n.idt = t.Id;
						n.title = t.Subject;
						n.typo = 'Task';
						n.start = t.ActivityDate;
						lstOfItems.add(n);
				}
			}*/
		}

		for (Event e: eventsList) {

			System.Debug('ISSP_CurrencyCenterEventListingCtrl:Current Account Id = ' + currentAccountId);
			System.Debug('ISSP_CurrencyCenterEventListingCtrl:Current User Id = ' + currentUser.Id);
			System.Debug('ISSP_CurrencyCenterEventListingCtrl:Event = ' + e);
			if (e.WhatId != NULL) {
				System.Debug('ISSP_CurrencyCenterEventListingCtrl:WhatId Type = ' + e.WhatId.getSObjectType());
				System.Debug('ISSP_CurrencyCenterEventListingCtrl:WhatId = ' + e.WhatId);
			}
			System.Debug('ISSP_CurrencyCenterEventListingCtrl:OwnerId = ' + e.OwnerId);


			if (e.WhatId != NULL) {
				//if ((e.WhatId.getSObjectType() == Schema.Account.getSObjectType() && e.WhatId == currentAccountId) || (e.WhatId.getsobjecttype() == Schema.Country_Profile__c.getSObjectType()) ) {
				if (e.WhatId.getsobjecttype() == Schema.Country_Profile__c.getSObjectType()) {
						newsWrapper n = new newsWrapper();
						n.idt = e.Id;
						n.title = e.Subject;
						n.typo = 'Event';
						n.start = e.StartDateTime;
						lstOfItems.add(n);
				} 
			}
			/*else if (e.OwnerId != NULL) {
				if (e.ownerId == currentUser.Id) {
						newsWrapper n = new newsWrapper();
						n.idt = e.Id;
						n.title = e.Subject;
						n.typo = 'Event';
						n.start = e.StartDateTime;
						lstOfItems.add(n);
				}
			}*/
		}

		this.newsList = lstOfItems;
		system.debug('ISSP_CurrencyCenterEventListingCtrl> NewsList = ' + this.newsList);
	}

	public class newsWrapper {
		public Id idt {get; set;}
		public String title {get; set;}
		public String typo {get; set;}
		public DateTime start {get; set;}
	}
}