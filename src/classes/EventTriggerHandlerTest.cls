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
		Test.startTest();

		//insert country profile
		Country_Profile__c cp = new Country_Profile__c(Name='Test Country');
		insert cp;

		//insert contacts to subscrive to country profile
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		List<User> users = new List<User>();
		users.add(new User(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@realm.com', Alias = 'johnd',
									EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
									LocaleSidKey='en_US', ProfileId = p.Id,
									TimeZoneSidKey='America/Los_Angeles', UserName='john.doe@testorg.com', License_Cost_Center__c = 'XSMW01JO01'));
		users.add(new User(FirstName = 'Jane', LastName = 'Doe', Email = 'jane.doe@realm.com', Alias = 'janed',
									EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
									LocaleSidKey='en_US', ProfileId = p.Id,
									TimeZoneSidKey='America/Los_Angeles', UserName='jane.doe@testorg.com', License_Cost_Center__c = 'XSMW01JO01'));
		insert users;

		List<EntitySubscription> esList = new List<EntitySubscription>();
		esList.add(new EntitySubscription(ParentId = cp.Id, SubscriberId = users[0].Id));
		esList.add(new EntitySubscription(ParentId = cp.Id, SubscriberId = users[1].Id));
		insert esList;

		// create actions (events)
		List<Event> eList = new List<Event>();

		// add future events
		eList.add(new Event(WhatId=cp.Id,RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('Event', 'Task_Force'),StartDateTime=Datetime.now().addDays(1),EndDateTime=Datetime.now().addDays(1).addHours(1)));

		insert eList;
		System.debug('Limits.getEmailInvocations: ' + Limits.getEmailInvocations());
		System.assertEquals(1,Limits.getEmailInvocations());

		Test.stopTest();
	}
}