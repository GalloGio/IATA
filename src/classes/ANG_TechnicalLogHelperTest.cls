@isTest
public class ANG_TechnicalLogHelperTest {
	@isTest
	public static void testCommitTechnicalLog() {
		Test.startTest();
		Technical_Logs__c log = ANG_TechnicalLogHelper.createTechnicalLog('Test', new MyException('some exception'), 'Log');
		ANG_TechnicalLogHelper.commitTechnicalLogs(log);
		Test.stopTest();

		List<Technical_Logs__c> logs = [SELECT Id, Operation__c, Status__c, Log__c FROM Technical_Logs__c];
		System.assertEquals(1, logs.size());
		System.assertEquals('Test', logs.get(0).Operation__c);
		System.assertEquals('some exception ()', logs.get(0).Status__c); // exception message + stack track (non existing)
		System.assertEquals('Log', logs.get(0).Log__c);
	}

	public class MyException extends Exception { }
}