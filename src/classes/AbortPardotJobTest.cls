@isTest
private class AbortPardotJobTest {
	static testmethod void test() {        
		Test.startTest();
			String sch = '0 10 * * * ?'; //schedule interval time
			System.schedule('TEST_abortPardotJobs', sch , new AbortPardotJobs());
		Test.stopTest();
	}
}