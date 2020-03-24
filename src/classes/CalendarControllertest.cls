@isTest
private class CalendarControllertest{

		 static testMethod void testMet1() {



			UtilityCS__c cs = new UtilityCS__c(name='PubCalendar',value__c = '123');
			insert cs;

			cs.value__c =   cs.id;
			update cs;

			CalendarController ctrl = new CalendarController();

			system.assertEquals(ctrl.calendarId , cs.id);

		 }

}
