public with sharing class CalendarController {

	public String calendarId {get; set; }

	public CalendarController () {
		calendarId = UtilityCS__c.getValues('PubCalendar').Value__c;
	}
}
