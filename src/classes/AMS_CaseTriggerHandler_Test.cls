/**
           File: AMS_CaseTriggerHandler_Test.cls
        Subject: Test Class for AMS_CaseTriggerHandler class.
        History: amtosantos, 2017-04-17, Initial Release.


*/
@isTest
private class AMS_CaseTriggerHandler_Test {
	@isTest
	static void testCaseTrigger_01() {
		Account parentAccount;
		Account parentAccount2;
		Account parentAccount3;
		Account childAccount;
		IATA_ISO_Country__c country;
		Case supportRequest;
		Case supportRequest1;
		Case supportRequest2;
		Case supportRequest3;
		List<Case> supportRequestList = new List<Case>();
		RecordType agencyRecordType;
		RecordType sidraRecordType;

		Test.startTest();

		country = new IATA_ISO_Country__c(
			name = 'test',
			CASS_Import__c = 'Yes',
			Case_BSP_Country__c = 'test',
			ISO_Code__c = 'T2',
			IATA_Contry_KR__c = 'test',
			IATA_Country_EN__C = 'testEN',
			IATA_Country_FR__c = 'testFR',
			IATA_Country_ZH__c = 'testZH',
			IATA_Country_IT__c = 'testIT',
			IATA_Country_JP__c = 'testJP',
			IATA_Country_PT__C = 'testPT',
			IATA_Country_SP__c = 'testSP'
		);

		insert country;

		agencyRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'IATA_Agency' LIMIT 1];
		sidraRecordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'SIDRA' LIMIT 1];

		parentAccount3 = ISSP_ObjectFactory.createNewAccount();

		parentAccount3.BillingCity = 'Test';
		parentAccount3.Name = 'Test';
		parentAccount3.sector__c = 'Travel Agent';
		parentAccount3.Location_Type__c = 'HO';
		parentAccount3.RecordTypeId = agencyRecordType.Id;
		parentAccount3.Status__c = 'Approved';
		parentAccount3.IATA_ISO_Country__c = country.Id;
		parentAccount3.ParentId = null;
		parentAccount3.Top_Parent__c = null;

		insert parentAccount3;

		parentAccount2 = ISSP_ObjectFactory.createNewAccount();

		parentAccount2.BillingCity = 'Test';
		parentAccount2.Name = 'Test';
		parentAccount2.sector__c = 'Travel Agent';
		parentAccount2.Location_Type__c = 'HO';
		parentAccount2.RecordTypeId = agencyRecordType.Id;
		parentAccount2.Status__c = 'Approved';
		parentAccount2.IATA_ISO_Country__c = country.Id;
		parentAccount2.ParentId = parentAccount3.Id;
		parentAccount2.Top_Parent__c = parentAccount3.Id;

		insert parentAccount2;

		parentAccount = ISSP_ObjectFactory.createNewAccount();

		parentAccount.BillingCity = 'Test';
		parentAccount.Name = 'Test';
		parentAccount.sector__c = 'Travel Agent';
		parentAccount.Location_Type__c = 'HO';
		parentAccount.RecordTypeId = agencyRecordType.Id;
		parentAccount.Status__c = 'Approved';
		parentAccount.IATA_ISO_Country__c = country.Id;
		parentAccount.ParentId = parentAccount2.Id;
		parentAccount.Top_Parent__c = parentAccount3.Id;

		insert parentAccount;

		childAccount = ISSP_ObjectFactory.createNewAccount();

		childAccount.BillingCity = 'Test';
		childAccount.Name = 'Test';
		childAccount.sector__c = 'Travel Agent';
		childAccount.Location_Type__c = 'HO';
		childAccount.RecordTypeId = agencyRecordType.Id;
		childAccount.IATACode__c = '100';
		childAccount.Status__c = 'Approved';
		childAccount.IATA_ISO_Country__c = country.Id;
		childAccount.Company_Type__c = 'A';
		childAccount.Top_Parent__c = parentAccount3.Id;
		childAccount.ParentId = parentAccount.Id;

		insert childAccount;

		supportRequest = ISSP_ObjectFactory.createNewCase();

		supportRequest.BSPCountry__c = 'Hong Kong (SAR), China';
		supportRequest.Reason1__c = 'Cargo';
		supportRequest.Customer_recovery__c = false;
		supportRequest.BounceEmailCounter__c = 0.0;
		supportRequest.Case_Language__c = 'English';
		supportRequest.Subject = 'Test SR';
		supportRequest.Reopened_case__c = 0.0;
		supportRequest.Account_Concerned__c = childAccount.Id;
		supportRequest.IFAP_Country_ISO__c = 'T2';
		supportRequest.RecordTypeId = sidraRecordType.Id;
		supportRequest.AccountId = childAccount.Id;
		supportRequest.Late_Payment_Date__c = Date.today();

		supportRequestList.add(supportRequest);

		supportRequest1 = ISSP_ObjectFactory.createNewCase();

		supportRequest1.BSPCountry__c = 'Hong Kong (SAR), China';
		supportRequest1.Reason1__c = 'Cargo';
		supportRequest1.Customer_recovery__c = false;
		supportRequest1.BounceEmailCounter__c = 0.0;
		supportRequest1.Case_Language__c = 'English';
		supportRequest1.Subject = 'Test SR';
		supportRequest1.Reopened_case__c = 0.0;
		supportRequest1.Account_Concerned__c = parentAccount.Id;
		supportRequest1.IFAP_Country_ISO__c = 'T2';
		supportRequest1.RecordTypeId = sidraRecordType.Id;
		supportRequest1.AccountId = parentAccount.Id;
		supportRequest1.Late_Payment_Date__c = Date.today();

		supportRequestList.add(supportRequest1);

		supportRequest2 = ISSP_ObjectFactory.createNewCase();

		supportRequest2.BSPCountry__c = 'Hong Kong (SAR), China';
		supportRequest2.Reason1__c = 'Cargo';
		supportRequest2.Customer_recovery__c = false;
		supportRequest2.BounceEmailCounter__c = 0.0;
		supportRequest2.Case_Language__c = 'English';
		supportRequest2.Subject = 'Test SR';
		supportRequest2.Reopened_case__c = 0.0;
		supportRequest2.Account_Concerned__c = parentAccount2.Id;
		supportRequest2.IFAP_Country_ISO__c = 'T2';
		supportRequest2.RecordTypeId = sidraRecordType.Id;
		supportRequest2.AccountId = parentAccount2.Id;
		supportRequest2.Late_Payment_Date__c = Date.today();

		supportRequestList.add(supportRequest2);

		supportRequest3 = ISSP_ObjectFactory.createNewCase();

		supportRequest3.BSPCountry__c = 'Hong Kong (SAR), China';
		supportRequest3.Reason1__c = 'Cargo';
		supportRequest3.Customer_recovery__c = false;
		supportRequest3.BounceEmailCounter__c = 0.0;
		supportRequest3.Case_Language__c = 'English';
		supportRequest3.Subject = 'Test SR';
		supportRequest3.Reopened_case__c = 0.0;
		supportRequest3.Account_Concerned__c = parentAccount3.Id;
		supportRequest3.IFAP_Country_ISO__c = 'T2';
		supportRequest3.RecordTypeId = sidraRecordType.Id;
		supportRequest3.AccountId = parentAccount3.Id;
		supportRequest3.Late_Payment_Date__c = Date.today();

		supportRequestList.add(supportRequest3);

		insert supportRequestList;

		Boolean isRunOnce = AMS_CaseTriggerHandler.runOnce();
		
		isRunOnce = AMS_CaseTriggerHandler.runOnce();

		AMS_CaseTriggerHandler.handleAfterInsert(supportRequestList);

		Test.stopTest();
	}
}