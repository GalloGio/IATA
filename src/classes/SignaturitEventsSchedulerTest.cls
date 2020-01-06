@istest
class SignaturitEventsSchedulerTest {
public static testMethod void testschedule() {
	Test.StartTest();
	SignaturitEventsScheduler testsche = new SignaturitEventsScheduler();
	String sch = '0 0 23 * * ?';
	system.schedule('Test status Check', sch, testsche );
	Test.stopTest();
}
}