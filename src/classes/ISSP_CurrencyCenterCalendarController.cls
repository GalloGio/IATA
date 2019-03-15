/**
 * @description This is a controller class for ISSP_CurrencyCenterCalendar page and ISSP_CurrencyCenterCalendarMini component
 *
 *
 * @creation  2019-01-15
 * @author    José Cardoso
 */
global without sharing class ISSP_CurrencyCenterCalendarController {

	public User user {get;set;}
	public Contact contact {get;set;}
	public Account account {get;set;}
	public String defaultCountry {get; set;}
	public Date maxDate {get; set;}
	public Date minDate {get; set;}

	public list<SelectOption> countryOptions {get;set;}

	private final map<string,string> ISOFIELDPERLANGUAGE = new map<string,string>{
		'en' => 'IATA_COUNTRY_EN__c',
		'ko' => 'IATA_Contry_KR__c',
		'fr' => 'IATA_Country_FR__c',
		'it' => 'IATA_Country_IT__c',
		'ja' => 'IATA_Country_JP__c',
		'pt' => 'IATA_Country_PT__c',
		'es' => 'IATA_Country_SP__c',
		'zh' => 'IATA_Country_ZH__c'
	};

	private transient list<EventWrapper> listEvents{
		/*get{
			List<EventWrapper> tmpListEvents = new List<EventWrapper>();
			tmpListEvents.addAll(getEvents(this.defaultCountry));
			//tmpListEvents.addAll(getTasks());
			return tmpListEvents;
		}
		*/
		get;
		set;
	}

	public String getListEventsJSON() {
		list<EventWrapper> tmpListEvents = this.listEvents;
		System.debug('jmc - getListEventsJSON listEvents = ' + tmpListEvents);
		String result = JSON.serialize(tmpListEvents,true);
		System.debug('jmc - getListEventsJSON result = ' + result);
		result = result.replace('"finish":','"end":');
		System.debug('jmc - getListEventsJSON result (after replace) = ' + result);
		return result;
	}

	public string getUserLanguage() {
		return UserInfo.getLanguage();
	}

	public ISSP_CurrencyCenterCalendarController(){
		this.user = [
				SELECT Id, Profile.Name, ContactId, Contact.Id, Contact.AccountId,
				Contact.Account.Id,
				Contact.Account.IATA_ISO_Country__c,
				Contact.Account.Remittance_frequency__c,
				Contact.Account.Location_Class__c
				FROM User
				WHERE Id = :UserInfo.getUserId()];
		this.contact = this.user.contact;
		this.account = this.user.contact.account;
		this.defaultCountry = getCountryProfileId(this.account.IATA_ISO_Country__c);
		this.maxDate = Date.newInstance(Date.Today().year()+2, 1, 1);
		this.minDate = Date.newInstance(Date.Today().year()-1, 1, 1);

		InitCountries();

		// get events
		this.listEvents = new List<EventWrapper>();
		//this.listEvents.addAll(getEvents(this.defaultCountry));
		this.listEvents.addAll(getEvents(''));
	}

	private void InitCountries(){
		// countries
		String fieldName = getIsoCountryFieldName();
		map<String,IATA_ISO_Country__c> mapNameCountry = new map<String,IATA_ISO_Country__c>();
		List<IATA_ISO_Country__c> isoCountries = [SELECT Id, Name,
													IATA_COUNTRY_EN__c,
													IATA_Contry_KR__c,
													IATA_Country_FR__c,
													IATA_Country_IT__c,
													IATA_Country_JP__c,
													IATA_Country_PT__c,
													IATA_Country_SP__c,
													IATA_Country_ZH__c
													FROM IATA_ISO_Country__c];
		Map<String, String> mapIsoCountries = new Map<String, String>();
		for(IATA_ISO_Country__c isoCountry:isoCountries){
			String countryName = (String)isoCountry.get(fieldName);
			if (countryName==null) countryName = isoCountry.Name;
			mapIsoCountries.put(isoCountry.Id, countryName);
		}

		List<Country_Profile__c> cpList = [SELECT Id, Name, IATA_ISO_Country__c FROM Country_Profile__c];
		cpList.sort();

		// create the country list ordered
		this.countryOptions = new list<SelectOption>();
		this.countryOptions.add(new SelectOption('', Label.ANG_ISSP_Picklist_None));

		for(Country_Profile__c cp: cpList){
			String countryName = mapIsoCountries.get(cp.IATA_ISO_Country__c);
			if (countryName==null) countryName = cp.Name;
			this.countryOptions.add(new SelectOption(cp.Id, countryName));
		}
	}

	/**
		Get the country field value where is located the translated name of the country
	**/
	public String getIsoCountryFieldName() {
		String locale = UserInfo.getLanguage().left(2).toLowerCase();
		locale = ISOFIELDPERLANGUAGE.containsKey(locale) ? locale: 'en';
		return ISOFIELDPERLANGUAGE.get(locale);
	}


	// Get Country Profile Id from ISO Country Id
	private String getCountryProfileID(String isoCountryId){
		String result = '';
		List<Country_Profile__c> cp = [SELECT Id, Name FROM Country_Profile__c WHERE IATA_ISO_Country__c=:isoCountryId LIMIT 1];
		if(!cp.isEmpty()){
			result = cp[0].Id;
		}
		return result;
	}

	private List<EventWrapper> getEvents(String countryId){
		List<EventWrapper> tmpListEvents = new List<EventWrapper>();

		String userId = this.user.Id;
		Date startDateTime = this.minDate;
		Date endDateTime = this.maxDate;
		System.debug('jmc - getEvents userId=' + userId);
		System.debug('jmc - getEvents startDateTime=' + startDateTime);
		System.debug('jmc - getEvents endDateTime=' + endDateTime);

		String soqlQuery = 'SELECT Subject, StartDateTime, EndDateTime, IsAllDayEvent, Description, ' +
									'OwnerId, WhatId ' +
							'FROM Event ' +
							'WHERE StartDateTime>=:startDateTime AND EndDateTime<=:endDateTime';
		if(countryId != ''){
			soqlQuery += ' AND WhatId=:countryId';
		}
		System.debug('jmc - getEvents soqlQuery=' + soqlQuery);

		List<Event> events = Database.query(soqlQuery);
		System.debug('jmc - getEvents events=' + events);

		for(Event e: events){
			if(e.WhatId != null && e.WhatId.getsobjecttype().getDescribe().getName() == 'Country_Profile__c') {
				EventWrapper ew = new EventWrapper();
				ew.title = e.Subject;
				ew.start = e.StartDateTime;
				ew.finish = e.EndDateTime;
				ew.allDay = e.IsAllDayEvent;
				ew.className = 'Event';
				ew.description = e.Description;
				tmpListEvents.add(ew);
			}
		}

		System.debug('jmc - getEvents tmpListEvents=' + tmpListEvents);
		return tmpListEvents;
	}

	/*
	private List<EventWrapper> getTasks(){
		List<EventWrapper> tmpListEvents = new List<EventWrapper>();

		String userId = this.user.Id;
		String accountId = this.account.Id;
		Date startDateTime = this.minDate;
		Date endDateTime = this.maxDate;
		System.debug('jmc - getTasks userId=' + userId);
		System.debug('jmc - getTasks accountId=' + accountId);
		System.debug('jmc - getTasks startDateTime=' + startDateTime);
		System.debug('jmc - getTasks endDateTime=' + endDateTime);

		String soqlQuery = 'SELECT Subject, ActivityDate, Description, ' +
									'OwnerId, WhatId ' +
							'FROM Task ' +
							'WHERE (OwnerId=:userId OR WhatId=:accountId) ' +
							'AND ActivityDate>=:startDateTime AND ActivityDate<=:endDateTime';
		System.debug('jmc - getTasks soqlQuery=' + soqlQuery);

		List<Task> tasks = Database.query(soqlQuery);
		System.debug('jmc - getTasks tasks=' + tasks);

		for(Task t: tasks){
			EventWrapper ew = new EventWrapper();
			ew.title = t.Subject;
			ew.start = t.ActivityDate;
			ew.finish = t.ActivityDate;
			ew.allDay = false;
			ew.className = 'Task';
			ew.description = t.Description;
			tmpListEvents.add(ew);
		}

		System.debug('jmc - getTasks tmpListEvents=' + tmpListEvents);
		return tmpListEvents;
	}
	*/

	/**
		Find the event list and converts it to JSON, a format valid for javascript
		This is called from the page, usually when a filter changes, only allowed to airlines
	**/
	@RemoteAction
	global static String loadEventsRemote(String country) {
		ISSP_CurrencyCenterCalendarController cccc = new ISSP_CurrencyCenterCalendarController();
		List<EventWrapper> tmpListEvents = new List<EventWrapper>();
		tmpListEvents.addAll(cccc.getEvents(country));
		return JSON.serialize(tmpListEvents,true);
	}

	/**
		Get the event list for the mini calendar
		This list is grouped by day, so there is only one event per day and each
		individual event is described in the hover
	**/
	public String getListEventsJSONGrouped() {
		return JSON.serialize(groupEvents(this.listEvents),true);
	}

	public static list<EventWrapper> groupEvents(list<EventWrapper> listEvents) {
		map<Date,EventWrapper> mapEvents = new map<Date,EventWrapper>();
		if (listEvents!=null) {
			for (EventWrapper event: listEvents) {
				Date dateKey = Date.ValueOf(event.start.date());
				EventWrapper newEvent = mapEvents.get(dateKey);
				if (newEvent==null) {
					newEvent = new EventWrapper();
					newEvent.title = '';
					newEvent.start = event.start;
					newEvent.finish = event.finish;
					newEvent.allDay = event.allDay;
					newEvent.className = event.className;
					newEvent.description = '';
				}
				newEvent.description+= event.title + '</br>';
				mapEvents.put(dateKey, newEvent);
			}
		}
		System.debug('jmc - groupEvents mapEvents' + mapEvents);
		return mapEvents.values();
	}

	private class EventWrapper {
		public Integer id;
		public String title;
		public DateTime start;
		public DateTime finish;
		public Boolean allDay;
		public String url;
		public String className;
		public String color;
		public String backgroundColor;
		public String borderColor;
		public String textColor;
		public String description;
	}
}