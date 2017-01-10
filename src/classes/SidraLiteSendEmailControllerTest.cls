@isTest(SeeAllData='true')
public class SidraLiteSendEmailControllerTest {

    public static Case getSidraCase() {
        Account account = new Account(
            Name = 'test account',
            Sector__c = 'Travel Agent',
            Category__c = 'Travel Agency Association'
        );
        insert account;

        Case cse = new Case(
            AccountId = account.Id,
            RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA Lite').getRecordtypeId(),
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France'
        );
        insert cse;
        return cse;
    }

    @isTest
    static void controller_ErrorNoCaseId() {
        Account acc = new Account(Name='test');
        insert acc;
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.returnToCase();
        Test.stopTest();
    }

    @isTest
    static void controller_ErrorNoSessionId() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.returnToCase();
        Test.stopTest();
    }

    @isTest
    static void controller_ErrorNoServerURL() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.returnToCase();
        Test.stopTest();
    }

    @isTest
    static void controller_OK() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.returnToCase();
        controller.findTemplates();

        System.assert(SidraLiteSendEmailController.QUERY_PARENT_CASE!=null,'Conga Query "IRR letter gen. Conga 2010 - CS" not found');
        System.assert(SidraLiteSendEmailController.QUERY_ACCOUNT!=null,'Conga Query "IRR letter gen. Conga 2010 - CS" not found');
        Test.stopTest();
    }

    @isTest
    static void Test_GoToSendEmail_NoFields() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);

        Test.startTest();
        controller.selectedToCase = null;
        controller.goToCongaSendEmail();
        controller.selectedToCase = 'true';
        controller.selectedCustomize = null;
        controller.goToCongaSendEmail();
        controller.selectedCustomize = 'true';
        controller.selectedType = null;
        controller.goToCongaSendEmail();
        Test.stopTest();
    }

    @isTest
    static void Test_GoToSendEmail_IRR() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.selectedToCase = 'true';
        controller.selectedCustomize = 'true';
        controller.selectedType = 'IRR';

        Test.startTest();
        controller.goToCongaSendEmail();
        Test.stopTest();
    }

    @isTest
    static void Test_GoToSendEmail_IRRWD() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.selectedToCase = 'true';
        controller.selectedCustomize = 'true';
        controller.selectedType = 'IRRWD';

        Test.startTest();
        controller.goToCongaSendEmail();
        Test.stopTest();
    }

    @isTest
    static void Test_GoToSendEmail_DEF() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.selectedToCase = 'true';
        controller.selectedCustomize = 'true';
        controller.selectedType = 'DEF';

        Test.startTest();
        controller.goToCongaSendEmail();
        Test.stopTest();
    }

    @isTest
    static void Test_GoToSendEmail_DEFWD() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.selectedToCase = 'true';
        controller.selectedCustomize = 'true';
        controller.selectedType = 'DEFWD';

        Test.startTest();
        controller.goToCongaSendEmail();
        Test.stopTest();
    }

    @isTest
    static void Test_GoToSendEmail_NOT() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.selectedToCase = 'true';
        controller.selectedCustomize = 'true';
        controller.selectedType = 'NOT';

        Test.startTest();
        controller.goToCongaSendEmail();
        Test.stopTest();
    }

    @isTest
    static void Test_GoToSendEmail_TER() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.selectedToCase = 'true';
        controller.selectedCustomize = 'true';
        controller.selectedType = 'TER';

        Test.startTest();
        controller.goToCongaSendEmail();
        Test.stopTest();
    }

}
