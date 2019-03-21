@IsTest
private class ISSP_CurrencyCenterEventListingCtrlTest {

	@IsTest
	static void test01(){

		//ISO Country
		IATA_ISO_Country__c isoC = new IATA_ISO_Country__c();
		isoC.name = 'Portugal';
		isoC.ISO_Code__c = 'PT';
		isoC.Case_BSP_Country__c = 'Portugal';
		isoC.Region__c = 'Europe';
		isoC.LVA_CountryLanguage__c = 'pt';
		insert isoC;
		System.debug('ISSP_CurrencyCenterCalendarCtrlTest IATA_ISO_Country__c: ' + isoC);

		//Country Profile
		Country_Profile__c cp = new Country_Profile__c(Name=isoC.Name, IATA_ISO_Country__c = isoC.Id);
		insert cp;
		System.debug('ISSP_CurrencyCenterCalendarCtrlTest Country_Profile__c: ' + cp);

		Id rtIdHq = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

		Account headQuarter = ISSP_ObjectFactory.createNewAccount();
		headQuarter.BillingCity = 'test2';
		headQuarter.Name = 'test2';
		headQuarter.RecordTypeId = rtIdHq;
		headQuarter.Site = 'headSite';
		insert headQuarter;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.Email = 'testxxaasddasdasda@test.com';
		con.AccountId= headQuarter.Id;
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalBasicAirlineUser(con);

		List<Event> events = new List<Event>();
		Event ev = new Event(Subject ='Test event',
				StartDateTime =System.now().addDays(1),
				EndDateTime =system.now().addDays(1).addHours(1),
				WhatId =cp.Id);
		events.add(ev);
		ev = new Event(Subject ='Test event',
				StartDateTime =System.now().addDays(2),
				EndDateTime =system.now().addDays(2).addHours(1),
				OwnerId = newUser.Id);
		events.add(ev);
		insert events;

		List<Task> tasks = new List<Task>();
		Task t = new Task(Subject = 'Test Task', ActivityDate = Date.valueOf(System.now().addDays(1)), WhatId =cp.Id);
		tasks.add(t);
		t = new Task(Subject = 'Test Task', ActivityDate = Date.valueOf(System.now().addDays(2)),OwnerId = newUser.Id);
		tasks.add(t);
		insert tasks;

		System.runAs(newUser){
			ISSP_CurrencyCenterEventListingCtrl ctrl = new ISSP_CurrencyCenterEventListingCtrl();
			System.assertEquals(2,ctrl.newsList.size());
		}

	}
}