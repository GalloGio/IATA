@IsTest
private class AccountSelectorTest {
	@TestSetup
	static void makeData(){
		Account account = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
		insert account;
	}

	@IsTest
	static void testSelectIdByNames(){
		List<Account> accountList = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'});
		System.assertEquals(1, accountList.size(), 'Expected Account was not returned by AccountSelector.selectByIds');
	}

	@IsTest
	static void testSelectById(){
		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		List<Account> accountList = AccountSelector.selectById(new Set<Id>{account.Id});
		System.assertEquals(1, accountList.size(), 'Expected Account was not returned by AccountSelector.selectByIds');
	}

	@IsTest
	static void testSelectIdMapByName(){
		Account account = AccountSelector.selectIdMapByName(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).values().get(0);
		List<Account> accountList = AccountSelector.selectById(new Set<Id>{account.Id});
		System.assertEquals(1, accountList.size(), 'Expected 1 Account');
	}

	@IsTest
	static void testSelectNewGenFieldsMapByName(){
		Test.startTest();
		String angIEPStatus = SObjectType.Account.Fields.ANG_IEP_Status__c.PicklistValues[0].getValue();
		String financialReviewResult = 'Financial Review Result';
		String heRiskHistoryAssessment = SObjectType.Account.Fields.ANG_HE_RiskHistoryAssessment__c.PicklistValues[0].getValue();

		Account account = AccountSelector.selectIdByNames(new Set<String>{TestDataFactory_Accounts.DEFAULTNAME + ' 0'}).get(0);
		account.ANG_IEP_Status__c = angIEPStatus;
		account.Financial_Review_Result__c = financialReviewResult;
		account.ANG_HE_RiskHistoryAssessment__c = heRiskHistoryAssessment;
		update account;
		Test.stopTest();

		String accountName = TestDataFactory_Accounts.DEFAULTNAME + ' 0';
		Map<String,Account> newGenAccountNameMap = AccountSelector.selectNewGenFieldsMapByName(null, new Set<String>{accountName}, null);
		String returnedAngIEPStatus = newGenAccountNameMap.get(accountName).ANG_IEP_Status__c;
		String returnedFinancialReviewResult = newGenAccountNameMap.get(accountName).Financial_Review_Result__c;
		String returnedHeRiskHistoryAssessment = newGenAccountNameMap.get(accountName).ANG_HE_RiskHistoryAssessment__c;
		
		System.assertEquals(angIEPStatus, returnedAngIEPStatus, 'Expected ANG_IEP_Status__c of ' + angIEPStatus + ' but received ' + returnedAngIEPStatus);
		System.assertEquals(financialReviewResult, returnedFinancialReviewResult, 'Expected Financial_Review_Result__c of ' + financialReviewResult + ' but received ' + returnedFinancialReviewResult);
		System.assertEquals(heRiskHistoryAssessment, returnedHeRiskHistoryAssessment, 'Expected ANG_HE_RiskHistoryAssessment__c of ' + heRiskHistoryAssessment + ' but received ' + returnedHeRiskHistoryAssessment);
	}
}