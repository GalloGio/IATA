@isTest
public class AccountStatementTransactionHandlerTest {
	private static final Id RT_ICE_BALANCE = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Statement_Transaction__c', 'ICE_Balance') ;
	private static String TEST_KEY = 'TESTKEY';

	@isTest
	private static void test_setParentId() {
		Account account = new Account(Name = 'Test Account');
		insert account;

		Account_Statement__c statement = new Account_Statement__c(
			Key__c = TEST_KEY,
			Account__c = account.Id,
			Operation__c = 'OP',
			Period__c = 'PE'
		);
		insert statement;

		Test.StartTest();
		Account_Statement_Transaction__c trans = new Account_Statement_Transaction__c(
			RecordTypeId = RT_ICE_BALANCE,
			Parent__c = null,
			Parent_Key__c = TEST_KEY,
			Transaction_Id__c = '1234',
			Amount__c = 10,
			Transaction_Type__c = 'Automatic Match'
		);
		insert trans;
		Test.StopTest();

		trans = [SELECT Id, Parent__c FROM Account_Statement_Transaction__c WHERE Id = :trans.Id];
		System.assertEquals(statement.Id, trans.Parent__c);
	}
}