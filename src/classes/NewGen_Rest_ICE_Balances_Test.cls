@isTest
private class NewGen_Rest_ICE_Balances_Test
{
	private static User testUser;

    private static void loadData() {
        testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();
        Portal_Applications__c app = ISSP_Ctrl_AccountStatements_AcceptTest.createAccountStatementApp(testUser);
        Portal_Application_Right__c appRight = [Select Id from Portal_Application_Right__c where Portal_Application__c = :app.Id];

        Account account = [Select Id, Status__c from Account limit 1];
        account.Status__c = 'Approved';
        update account;

        list<Account_Statement__c> listAccountStatements = new list<Account_Statement__c>();
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today(),
                Group__c = 'group01',
                Period__c = 'period01',
                Operation__c = 'Operation01',
                Key__c = '010101',
                Paid__c = 100,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 0,
                Balance__c = 0,
                Account__c = account.Id,
                CurrencyIsoCode = 'EUR'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(-1),
                Group__c = 'group01',
                Period__c = 'period01',
                Operation__c = 'Operation01',
                Key__c = '020202',
                Paid__c = 0,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 100,
                Balance__c = 100,
                Account__c = account.Id,
                CurrencyIsoCode = 'USD'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(1),
                Group__c = 'group01',
                Period__c = 'period02',
                Operation__c = 'Operation01',
                Key__c = '030303',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = account.Id,
                CurrencyIsoCode = 'USD'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(1),
                Group__c = 'group01',
                Period__c = 'period02',
                Operation__c = 'Operation02',
                Key__c = '444',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = account.Id,
                CurrencyIsoCode = 'USD'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(1),
                Group__c = 'group01',
                Period__c = 'period03',
                Operation__c = 'Operation02',
                Key__c = '555',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = account.Id,
                CurrencyIsoCode = 'USD'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(1),
                Group__c = 'group01',
                Period__c = 'period02',
                Operation__c = 'Operation01',
                Key__c = '666',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = account.Id,
                CurrencyIsoCode = 'USD'));
        insert listAccountStatements;
    }

	@isTest
	static void testDoGet()
	{
		loadData();

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		
		req.requestURI = 'services/apexrest/newgenapp/v1/iceGetBalances/*';

		req.addParameter('callback', 'test');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;


		System.runAs(testUser){
			NewGen_Rest_ICE_Balances.doGet();
		}
	}

	@isTest
	static void errorDoGet()
	{
		loadData();

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
		
		req.requestURI = 'services/apexrest/newgenapp/v1/iceGetBalances/*';

		req.addParameter('callback', 'test');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		NewGen_Rest_ICE_Balances.doGet(); 
		Test.stopTest();
	}
}