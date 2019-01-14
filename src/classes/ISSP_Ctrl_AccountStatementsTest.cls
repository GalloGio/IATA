@istest
private class ISSP_Ctrl_AccountStatementsTest {

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
                Group__c = 'group02',
                Period__c = 'period02',
                Operation__c = 'Operation02',
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
                Group__c = 'group03',
                Period__c = 'period03',
                Operation__c = 'Operation03',
                Key__c = '030303',
                Paid__c = 50,
                Billing_Amount__c = 100,
                Amount_to_be_Paid__c = 50,
                Balance__c = 50,
                Account__c = account.Id,
                CurrencyIsoCode = 'USD'));
        insert listAccountStatements;
    }

    @istest
    static void test_controller_AccountNotApproved() {
        testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();
        Portal_Applications__c app = ISSP_Ctrl_AccountStatements_AcceptTest.createAccountStatementApp(testUser);
        Portal_Application_Right__c appRight = [Select Id from Portal_Application_Right__c where Portal_Application__c = :app.Id];

        ISSP_Ctrl_AccountStatements controller;
        Test.startTest();
        System.runAs(testUser) {
            controller = new ISSP_Ctrl_AccountStatements();
            System.AssertEquals(1, controller.listMessages.size());
        }
        Test.stopTest();
    }

    @istest
    static void test_controller() {
        loadData();
        ISSP_Ctrl_AccountStatements controller;
        Test.startTest();
        System.runAs(testUser) {
            controller = new ISSP_Ctrl_AccountStatements();
            controller.initActions();
            System.AssertEquals(0, controller.listMessages.size());
            controller.getInstance();
            controller.updateAppRight();
        }
        Test.stopTest();
    }

    @istest
    static void test_checkTermsAndConditions() {
        loadData();

        ISSP_Ctrl_AccountStatements controller;
        System.runAs(testUser) {
            controller = new ISSP_Ctrl_AccountStatements();
        }

        Portal_Application_Right__c appRight = [
            Select Id, Terms_Acceptance__c, Right__c
            From Portal_Application_Right__c
            limit 1];

        System.assertEquals(false, appRight.Terms_Acceptance__c);

        PageReference pageref;
        Test.startTest();
        // terms not accepted
        System.runAs(testUser) {
            pageref = controller.initActions();
        }
        System.assert(pageref!=null);

        // accept terms
        appRight.Terms_Acceptance__c = true;
        update appRight;
        System.runAs(testUser) {
            pageref = controller.initActions();
        }
        System.assert(pageref==null);

        // no rights
        appRight.Right__c = 'Access Rejected';
        update appRight;
        System.runAs(testUser) {
            pageref = controller.initActions();
        }
        System.assert(pageref!=null);
        Test.stopTest();
    }

    @istest
    static void test_WrapperStatements() {
        loadData();

        ISSP_Ctrl_AccountStatements controller = new ISSP_Ctrl_AccountStatements();
        list<Account_Statement__c> listStatements = [
            Select Id, Period__c, Operation__c, Name, Key__c, CurrencyIsoCode, Account__c, Amount_to_be_Paid__c, Balance__c, Billing_Amount__c, Paid__c, Remittance_Date__c, Status__c, Billing_Adjustment__c, Group__c, Account__r.Name, Account__r.Site, LastModifiedDate
            From Account_Statement__c];

        Test.startTest();
        ISSP_Ctrl_AccountStatements.WrapperStatement wrapper;
        wrapper = new ISSP_Ctrl_AccountStatements.WrapperStatement(listStatements.remove(0));
        for (Account_Statement__c statement: listStatements) {
            wrapper.addStatement(statement);
        }

        wrapper.calculeLastUpdatedDate();
        wrapper.getParentStatus();
        wrapper.getParentBillingAdjustment();
        new list<ISSP_Ctrl_AccountStatements.WrapperStatement>().sort();

        Test.stopTest();
    }

    @istest
    static void test_Attachments()
    {

        loadData();

        ISSP_Ctrl_AccountStatements controller = new ISSP_Ctrl_AccountStatements();

        list<Account_Statement__c> listStatements = [Select Id, Period__c, Operation__c,
                                                        Name, Key__c, CurrencyIsoCode, Account__c,
                                                        Amount_to_be_Paid__c, Balance__c,
                                                        Billing_Amount__c, Paid__c, Remittance_Date__c,
                                                        Status__c, Billing_Adjustment__c,
                                                        Group__c, Account__r.Name, Account__r.Site,
                                                        LastModifiedDate
                                                       From Account_Statement__c];

        //String fileName = controller.amazonFileStartName;
        //String fileIdentifier = controller.amazonFileNameIdentifier;

        Test.startTest();
            controller.accountSelectedId = listStatements[0].Account__c;
            controller.accountStatementSelectedId = listStatements[0].Id;
            controller.accountSelectedName = listStatements[0].Account__r.Name;
            controller.accountStatementPeriod = listStatements[0].Period__c;
            controller.billingAmount = String.valueOf(listStatements[0].Billing_Amount__c);
            controller.amazonFileName = 'ICE POP' + ' ' + controller.accountStatementPeriod + ' ' + controller.billingAmount;

            List<AmazonFile__c> listAttachmentsAux = controller.listAttachments;


            Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
            insert Amazon_Cred;
            Amazon_Cred__c Amazon_Cred2 =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
            insert Amazon_Cred2;



            list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
                    new AWSKey__c(
                            name = 'adevconf',
                            Key__c = 'asd',
                            Secret__c = 'asd',
                            IAS_configuration_name__c = 'asdas',
                            IAS_Access_Point__c = 'asd',
                            Bucket__c = 'asd',
                            AWS_ENDPOINT_URL__c = 'asd')
                    };
            insert AWS_KEYs;

            AmazonFile__c azFile = new AmazonFile__c(
                Name='ICE POP' + ' ' + controller.accountStatementPeriod + ' ' + controller.billingAmount,
                RecordTypeId = controller.amazonRecordTypeId,
                Remittance_Period__c = controller.accountStatementPeriod,
                Category__c = 'ICE POP',
                File_Identifier_picklist__c = 'ICE_POP',
                Account__c =controller.accountSelectedId,
                Full_Name_Unique__c = '500/'+controller.accountSelectedId+'/ICE POP'
            );
            insert azFile;

        controller.addAttachment();
        controller.saveAttachment();
        String credName = controller.credentialName;

        controller.refreshList();
        Test.stopTest();
    }
}