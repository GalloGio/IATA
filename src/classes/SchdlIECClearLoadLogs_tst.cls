@isTest
private class SchdlIECClearLoadLogs_tst {

	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

	static void Init() {
		insert new IEC_Settings__c(
			Customer_Permission_Set_Id__c = 'Test'
			, PaymentMethod_Bank_Transfer_Zuora_ID__c = 'Test'
			, PaymentMethod_Other_Zuora_ID__c = 'Test'
			, Quote_Template_Zuora_ID_New_Subscription__c = 'Test'
			, Cart_cookie_session_timeout__c = -1
			, Encryption_Algorythm__c = 'Test'
			, Encryption_Key__c = 'Test'
			, IEC_Web_Service_Endpoint__c = 'Test'
			, IEC_Web_Service_Password__c = 'Test'
			, IEC_Web_Service_Username__c = 'Test'
			, SchdlIECCompileUsage_Class_ID__c = 'Test'
			, Server_API_URL__c = 'Test'
			, CAC_Web_Service_API_Gateway__c = 'Test'
			, CAC_Web_Service_Usage_Url__c = 'Test'
			, SchdlCACWSUsageUpdate_Class_ID__c = 'Test'
			, Error_Log_Keep_Duration__c = 6);

		IEC_Error_Log__c e1 = new IEC_Error_Log__c();
		e1.Source__c = 'DataLoader: Accounts';
		insert e1;

		IEC_Error_Log__c e2 = new IEC_Error_Log__c();
		e2.Source__c = 'DataLoader: Contacts';
		insert e2;

		IEC_Error_Log__c e3 = new IEC_Error_Log__c();
		e3.Source__c = 'Other Logs';
		insert e3;
	}

		static testMethod void clearDataLoaderLogs() {

			Init();

			//Check that 3 logs are on the table
		List<IEC_Error_Log__c> list1 = [SELECT Id FROM IEC_Error_Log__c];
		System.assertEquals(3, list1.size());


			Test.startTest();

				// Schedule the test job
				String jobId = System.schedule('SchdlIECClearLoadLogs', CRON_EXP, new SchdlIECClearLoadLogs());

				// Get the information from the CronTrigger API object
				CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

				// Verify the expressions are the same
				System.assertEquals(CRON_EXP, ct.CronExpression);

				// Verify the job has not run
				System.assertEquals(0, ct.TimesTriggered);


			Test.stopTest();

			//Check that only 1 log remains on the table
		List<IEC_Error_Log__c> list2 = [SELECT Id FROM IEC_Error_Log__c];
		System.assertEquals(1, list2.size());

		}
}
