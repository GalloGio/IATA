@isTest
private class EF_ContractHandlerTest
{
	@testSetup
    static void setup()
    {

		User u = EF_TestDataFactory.getEfProfileAndRole(0, 2);
		// User u2 = EF_TestDataFactory.getEfProfileAndRole(0, 4);
		EF_TestDataFactory.createCustomSettings();
		EF_TestDataFactory.createBaseData();
        System.runAs(u){
        }

    }

	@isTest
	static void testContract()
	{
		Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];

		contract.EF_Allow_Billing_Agreements__c = 'Allowed';
		update contract;

		List<EF_Billing_Agreement__c> lsBillingAgreements = [SELECT Id, Data_Currency__c FROM EF_Billing_Agreement__c WHERE Contract__c =:contract.Id];

// System.runAs(u){

        Test.startTest();
			lsBillingAgreements[0].Data_Currency__c = 'QAR';
			try {
				update lsBillingAgreements;
			} catch(Exception e) {
				Boolean expectedExceptionThrown =  e.getMessage().contains('currency') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);

			}
			contract.EF_Data_Currency__c = 'EUR';
			try {
				update contract;

			} catch(Exception e) {
				Boolean expectedExceptionThrown =  e.getMessage().contains('currency') ? true : false;
				System.AssertEquals(expectedExceptionThrown, false);
			}
        Test.stopTest();
// }

	}
	@isTest
	static void testContact2()
	{
		Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
		contract.EF_Allow_Billing_Agreements__c = 'Allowed';
		update contract;

// System.runAs(u){
        Test.startTest();
			contract.Name = 'fakeName';
			try {
				update contract;

			} catch(Exception e) {
				Boolean expectedExceptionThrown =  e.getMessage().contains('currency') ? true : false;
				System.AssertEquals(expectedExceptionThrown, false);
			}
        Test.stopTest();
// }
	}
}
