/**
	* Description: This test class tests SchdlEBCPeriodicQueryOnAgency
	*   Basic test class
	*
	* Author: Sonny Leman
	*
	* History:
	*   20160613-sl: initial version
	*
	*/


@isTest
private class SchdlEBCPeriodicQueryOnAgency_tst {

	// ========================================================================
	// basic test class, without even creating test data
	// this is used to test the scheduled job.
	static testMethod void testScheduleJob01_Basic()
	{
		Test.startTest();

		// Set up scheduled job
		datetime nextScheduleTime = system.now().addMinutes(1);
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' * * * ?' ;

		string jobName = 'SchdlEBCPeriodicQueryOnAgency ' + (Test.isRunningTest() ? 'Test' : '') + nextScheduleTime.format('hh:mm');
		system.schedule(jobName, cronvalue , new SchdlEBCPeriodicQueryOnAgency());

		Test.stopTest();
	} // testScheduleJob01_Basic

} // SchdlEBCPeriodicQueryOnAgency_tst
