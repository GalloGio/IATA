/**
 * @description This is a test Class for eventTriggerHandler
 *
 *
 * @creation  2019-01-30
 * @author    José Cardoso
 */
@isTest
private class EventTriggerHandlerTest {

	@isTest static void handleCountryProfileEventsTest(){

		List<User> users = new List<User>();
		//ACAMBAS - WMO-568: Begin
		//insert contacts to subscrive to country profile
		//Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		
		Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		
		List<Contact> contacts = new List<Contact>();
		contacts.add(ISSP_ObjectFactory.createNewContact());
		//contacts.add(ISSP_ObjectFactory.createNewContact());
		contacts[0].AccountId = acc.Id;
		//contacts[1].AccountId = acc.Id;
		insert contacts;

		/*users.add(new User(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@realm.com', Alias = 'johnd',
									EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
									LocaleSidKey='en_US', ProfileId = p.Id, ContactId = contacts[0].Id,
									TimeZoneSidKey='America/Los_Angeles', UserName='john.doe@testorg.com', License_Cost_Center__c = 'XSMW01JO01'));
		users.add(new User(FirstName = 'Jane', LastName = 'Doe', Email = 'jane.doe@realm.com', Alias = 'janed',
									EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
									LocaleSidKey='en_US', ProfileId = p.Id, ContactId = contacts[1].Id,
									TimeZoneSidKey='America/Los_Angeles', UserName='jane.doe@testorg.com', License_Cost_Center__c = 'XSMW01JO01'));*/
		users.add(ISSP_ObjectFactory.createPortalUser(contacts[0]));
		contacts[0].OwnerId = users[0].Id;
		//contacts[1].OwnerId = users[1].Id;
        update contacts;

		Network community = [SELECT id, name, status FROM Network WHERE Name = 'IATA Portal' LIMIT 1];
		//ACAMBAS - WMO-568: End

		//insert country profile
		Country_Profile__c cp = new Country_Profile__c(Name='Test Country');
		insert cp;
		
		List<EntitySubscription> esList = new List<EntitySubscription>();
		esList.add(new EntitySubscription(ParentId = cp.Id, SubscriberId = users[0].Id, NetworkId = community.Id));
		//esList.add(new EntitySubscription(ParentId = cp.Id, SubscriberId = users[1].Id, NetworkId = community.Id));	
		insert esList ;

		// create actions (events)
		List<Event> eList = new List<Event>();

		// add future events
		eList.add(new Event(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Event', 'Task_Force'),StartDateTime=Datetime.now().addDays(1),EndDateTime=Datetime.now().addDays(1).addHours(1)));
		insert eList;

		Test.startTest();
		System.debug('Limits.getEmailInvocations: ' + Limits.getEmailInvocations());
		System.assertEquals(1,Limits.getEmailInvocations());
		Test.stopTest();
	}
}