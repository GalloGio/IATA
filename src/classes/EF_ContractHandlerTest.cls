@isTest
private class EF_ContractHandlerTest
{
	@testSetup
	static void setup()
	{

		User u = EF_TestDataFactory.getEfProfileAndRole(0, 2);
		User u2 = EF_TestDataFactory.getEfProfileAndRole(0, 4);
		// EF_TestDataFactory.createCustomSettings();
		System.runAs(u){
			EF_TestDataFactory.createBaseData();
		}

	}

	@isTest
	static void testUpdateContractAsSpecialist()
	{
		// make an AccountShare to mimic the role based sharing in actual environment
		User u = [SELECT Id FROM User WHERE Username='efUnit@test.ch4' LIMIT 1];
		Account parent = [SELECT Id FROM Account WHERE Name = 'Test Account Client' LIMIT 1];
		AccountShare share = new AccountShare();
		share.AccountId = parent.Id;
		share.UserOrGroupId = u.Id;
		share.AccountAccessLevel = 'Edit';
		share.OpportunityAccessLevel = 'Edit';
		insert share;

		System.runAs(u) {

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];

			contract.EF_Allow_Billing_Agreements__c = 'Allowed';
			update contract;

			List<EF_Billing_Agreement__c> lsBillingAgreements = [SELECT Id, Data_Currency__c FROM EF_Billing_Agreement__c WHERE Contract__c =:contract.Id];

			Test.startTest();
			lsBillingAgreements[0].Data_Currency__c = 'QAR';
			try {
				update lsBillingAgreements;
			} catch(Exception e) {
				Boolean expectedExceptionThrown =  e.getMessage().contains('currency') ? true : false;
				System.AssertEquals(expectedExceptionThrown, false);

			}
			contract.EF_Data_Currency__c = 'EUR';
			try {
				update contract;

			} catch(Exception e) {
				Boolean expectedExceptionThrown =  e.getMessage().contains('currency') ? true : false;
				System.AssertEquals(expectedExceptionThrown, false);
			}
			Test.stopTest();
		}

	}

	@isTest
	static void testChangeBillingCurrencyOrCriticalField()
	{
		User u = [SELECT Id FROM User WHERE Username='efUnit@test.ch2' LIMIT 1];
		System.runAs(u) {

			Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
			contract.EF_Allow_Billing_Agreements__c = 'Allowed';
			update contract;

			List<EF_Billing_Agreement__c> lsBillingAgreements = [SELECT Id, Data_Currency__c FROM EF_Billing_Agreement__c WHERE Contract__c =:contract.Id];

			Test.startTest();
			lsBillingAgreements[0].Data_Currency__c = 'QAR';
			try {
				update lsBillingAgreements;
			} catch(Exception e) {
				Boolean expectedExceptionThrown =  e.getMessage().contains('currency') ? true : false;
				System.AssertEquals(expectedExceptionThrown, false);

			}
			contract.EF_Admin_Fee__c = 15;
			try {
				update contract;

			} catch(Exception e) {
				Boolean expectedExceptionThrown =  e.getMessage().contains('currency') ? true : false;
				System.AssertEquals(expectedExceptionThrown, false);
			}
			Test.stopTest();
		}

	}

}
