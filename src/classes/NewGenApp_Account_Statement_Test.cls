@isTest
private class NewGenApp_Account_Statement_Test
{
	private static User testUser;

    private static void loadData() {
        NewGenApp_Custom_Settings__c newgenCS = new NewGenApp_Custom_Settings__c();
        newgenCS.Push_Notifications_State__c = true;
        insert newgenCS;
        
        testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();
        Portal_Applications__c app = ISSP_Ctrl_AccountStatements_AcceptTest.createAccountStatementApp(testUser);
        Portal_Application_Right__c appRight = [Select Id from Portal_Application_Right__c where Portal_Application__c = :app.Id];

        Account account = [Select Id, Status__c from Account limit 1];
        account.Status__c = 'Approved';
        update account;

        list<Account> listofaccounts = new list<Account>();

    	Account newAccount1 = new Account();
        newAccount1.Name = 'Test Account 1';
        insert newAccount1;

        Account newAccount2 = new Account();
        newAccount2.Name = 'Test Account 2';
        newAccount2.ParentId = newAccount1.Id;
        insert newAccount2;

        Account newAccount3 = new Account();
        newAccount3.Name = 'Test Account 3';
        newAccount3.ParentId = newAccount2.Id;
        insert newAccount3;

        Account newAccount4 = new Account();
        newAccount4.Name = 'Test Account 4';
        newAccount4.ParentId = newAccount3.Id;
        insert newAccount4;

        Account newAccount5 = new Account();
        newAccount5.Name = 'Test Account 5';
        newAccount5.ParentId = newAccount4.Id;
        insert newAccount5;


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
                Group__c = 'group02',
                Period__c = 'period02',
                Operation__c = 'Operation02',
                Key__c = '020202',
                Paid__c = 0,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 100,
                Balance__c = 100,
                Account__c = newAccount1.Id,
                CurrencyIsoCode = 'USD'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(1),
                Group__c = 'group03',
                Period__c = 'period03',
                Operation__c = 'Operation03',
                Key__c = '030303',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = newAccount2.Id,
                CurrencyIsoCode = 'USD'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(1),
                Group__c = 'group04',
                Period__c = 'period04',
                Operation__c = 'Operation04',
                Key__c = '040404',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = newAccount3.Id,
                CurrencyIsoCode = 'USD'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(1),
                Group__c = 'group05',
                Period__c = 'period05',
                Operation__c = 'Operation05',
                Key__c = '050505',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = newAccount4.Id,
                CurrencyIsoCode = 'USD'));
        listAccountStatements.add(
            new Account_Statement__c(
                Remittance_Date__c = Date.today().addMonths(1),
                Group__c = 'group06',
                Period__c = 'period06',
                Operation__c = 'Operation06',
                Key__c = '060606',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = newAccount5.Id,
                CurrencyIsoCode = 'USD'));
        insert listAccountStatements;
    }

    @isTest
    static void testEditStatement(){
    	loadData();
    	list<Account_Statement__c> statementlist = [SELECT Id, Balance__c,Paid__c FROM Account_Statement__c];
    	statementlist[0].Balance__c = 4000;
    	statementlist[1].Balance__c = 0;
    	statementlist[2].Paid__c=100;
    	statementlist[3].Paid__c=300;
    	statementlist[4].Balance__c=100;
    	statementlist[5].Balance__c=430;
    	update statementlist;
    }

    @isTest
    static void testAccountHierarchy(){
    	loadData();
    	list<Account_Statement__c> statementlist = [SELECT Id, Balance__c,Paid__c,Account__c FROM Account_Statement__c WHERE Operation__c = 'Operation03' LIMIT 1];
    	statementlist[0].Balance__c = 4000;

       	update statementlist;
    }

}