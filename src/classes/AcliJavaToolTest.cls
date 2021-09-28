@isTest
private class AcliJavaToolTest {

	@TestSetup
	static void makeData(){
		TestDataFactory_AWSKeys.createAllEntries();
	}
	
	static testMethod void testGetFile_Error() {
		Test.StartTest();
		AcliJavaTool.Response response = AcliJavaTool.getFile();
		String responseStr = response.toString();
		Test.StopTest();

		System.assert(response.success == false);
		System.assert(responseStr.startsWith('ERROR'));
	}

	static testMethod void testGetFile_Success() {
		String testResponse = '{"success":true,"content":"file content","code":"","message":""}';

		Test.StartTest();
		AcliJavaTool.testJsonResults = testResponse;
		AcliJavaTool.Response response = AcliJavaTool.getFile();
		String responseStr = response.toString();
		Test.StopTest();

		System.assert(response.success == true);
		System.assert(response.content == 'file content');
		System.assert(responseStr.startsWith('SUCCESS'));
	}

	static testMethod void testDeleteFile_Error() {
		Test.StartTest();
		AcliJavaTool.Response response = AcliJavaTool.deleteFile();
		String responseStr = response.toString();
		Test.StopTest();

		System.assert(response.success == false);
		System.assert(responseStr.startsWith('ERROR'));
	}

	static testMethod void testDeleteFile_Success() {
		String testResponse = '{"success":true,"content":"","code":"","message":""}';

		Test.StartTest();
		AcliJavaTool.testJsonResults = testResponse;
		AcliJavaTool.Response response = AcliJavaTool.deleteFile();
		String responseStr = response.toString();
		Test.StopTest();

		System.assert(response.success == true);
		System.assert(responseStr.startsWith('SUCCESS'));
	}

}
