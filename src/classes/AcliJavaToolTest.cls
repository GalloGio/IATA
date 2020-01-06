@isTest
private class AcliJavaToolTest {

	static void loadData() {
		Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'ACLI', Prod_Configuration__c = 'aprodconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred;

		list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
			new AWSKey__c(name = 'aprodconf',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd'),
			new AWSKey__c(name = 'adevconf' ,
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd')
		};

		insert AWS_KEYs;
	}

	static testMethod void testGetFile_Error() {
		loadData();

		Test.StartTest();
		AcliJavaTool.Response response = AcliJavaTool.getFile();
		String responseStr = response.toString();
		Test.StopTest();

		System.assert(response.success == false);
		System.assert(responseStr.startsWith('ERROR'));
	}

	static testMethod void testGetFile_Success() {
		loadData();

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
		loadData();

		Test.StartTest();
		AcliJavaTool.Response response = AcliJavaTool.deleteFile();
		String responseStr = response.toString();
		Test.StopTest();

		System.assert(response.success == false);
		System.assert(responseStr.startsWith('ERROR'));
	}

	static testMethod void testDeleteFile_Success() {
		loadData();

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
