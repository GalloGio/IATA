/**
  * Description: This class contains unit tests for the (Zuora Billing Account) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */

@isTest(SeeAllData=true)
private class trgHndlrSAPAccount_tst {

	static testMethod void TestSAPAccount() {
		System.debug('Unit Test: Start: TestSAPAccount');

		Account oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;

		Contact oContact = IECTestUtil.createSampleContact(oAccount);
		insert oContact;

		Zuora__CustomerAccount__c zBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
		insert zBillingAccount;

		Test.startTest();

		Account tempAccount = New Account();
		tempAccount.RecordTypeId = IECUserManager.getAccountRecordTypeForIEC(IECConstants.Account_ClientType_ThirdParty);
		tempAccount.BillingCountry = 'Canada';
		tempAccount.BillingCity = 'Montreal';
		tempAccount.Name = 'Company';
		tempAccount.OwnerId = IECUserManager.getIECAccountOwnerId();
		tempAccount.IATACode__c = '1234567';
		Insert tempAccount;

		SAP_Account__c oSAPAccount = IECTestUtil.CreateSampleSAPAccount(tempAccount.Id);
		insert oSAPAccount;
		oSAPAccount.GDP__c  = False;
		update oSAPAccount;
		delete oSAPAccount;
		Test.stopTest();

		System.debug('Unit Test: Finish: TestSAPAccount');
	}
}
