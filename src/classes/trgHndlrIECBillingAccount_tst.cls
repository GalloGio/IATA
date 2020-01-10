/**
  * Description: This class contains unit tests for the (Zuora Billing Account) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */

@isTest(SeeAllData=true)
private class trgHndlrIECBillingAccount_tst {

	static testMethod void TestBillingAccount() {
		System.debug('Unit Test: Start: TestBillingAccount');

		Account oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;

		Contact oContact = IECTestUtil.createSampleContact(oAccount);
		insert oContact;

		Zuora__CustomerAccount__c zBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
		insert zBillingAccount;
		update zBillingAccount;

		// Make sure that the product linking has occured
		system.assertEquals([SELECT Contact__c FROM Zuora__CustomerAccount__c WHERE Id = :zBillingAccount.Id].Contact__c, oContact.Id);

		System.debug('Unit Test: Finish: TestBillingAccount');
	}
}
