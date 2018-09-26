@isTest
public class SidraLiteSendEmailControllerTest {

    @TestSetup
    public static void loadData() {
        RecordTypeEmail__c rt = new RecordTypeEmail__c();
        rt.Name = 'Name';
        rt.Record_Type_Developer_Name__c = 'SIDRA_Lite';
        rt.Country_Name__c = 'Default';
        rt.Case_Group__c = 'Default';
        rt.Email__c = 'noreply@iata.org';
        insert rt;
    }

    public static Case getSidraCase() {
        APXTConga4__Conga_Merge_Query__c cm1 = new APXTConga4__Conga_Merge_Query__c();
        cm1.APXTConga4__Name__c = 'Parent Case';
        insert cm1;
        APXTConga4__Conga_Merge_Query__c cm2 = new APXTConga4__Conga_Merge_Query__c();
        cm2.APXTConga4__Name__c = 'Parent Account';
        insert cm2;
        APXTConga4__Conga_Merge_Query__c cm3 = new APXTConga4__Conga_Merge_Query__c();
        cm3.APXTConga4__Name__c = 'Forms Of Payment';
        insert cm3;
        APXTConga4__Conga_Merge_Query__c cm4 = new APXTConga4__Conga_Merge_Query__c();
        cm4.APXTConga4__Name__c = 'RHC Information';
        insert cm4;
        
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
        APXTConga4__Conga_Merge_Query__c cm1 = new APXTConga4__Conga_Merge_Query__c();
        cm1.APXTConga4__Name__c = 'Parent Case';
        insert cm1;

        APXTConga4__Conga_Merge_Query__c cm2 = new APXTConga4__Conga_Merge_Query__c();
        cm2.APXTConga4__Name__c = 'Parent Account';
        insert cm2;

        APXTConga4__Conga_Merge_Query__c cm3 = new APXTConga4__Conga_Merge_Query__c();
        cm3.APXTConga4__Name__c = 'Forms Of Payment';
        insert cm3;

        APXTConga4__Conga_Merge_Query__c cm4 = new APXTConga4__Conga_Merge_Query__c();
        cm4.APXTConga4__Name__c = 'RHC Information';
        insert cm4;
        
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
    static void controller_ErrorNoCase() {
        Case cse = getSidraCase();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');
        delete cse;

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.returnToCase();
        Test.stopTest();
    }

    @isTest
    static void controller_OK() {
        Case cse = getSidraCase();
        cse.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';
        update cse;
        SidraLiteEmailTemplates__c template = new SidraLiteEmailTemplates__c();
        template.Name = 'Test Template';
        template.SidraLiteAction__c = 'REI';
        template.SidraLiteReason__c = 'Financial Review Non-compliance';
        template.Country__c = 'All Region';
        template.Region__c = 'Europe';
        template.TypeOfCustomer__c = 'Travel Agency Association';
        insert template;
        APXTConga4__Conga_Template__c ct = new APXTConga4__Conga_Template__c();
        Insert ct;
        SidraLiteCongaTemplates__c templateConga = new SidraLiteCongaTemplates__c();
        templateConga.Name = 'Test Template Conga';
        templateConga.SidraLiteAction__c = 'REI';
        templateConga.SidraLiteReason__c = 'Financial Review Non-compliance';
        templateConga.Country__c = 'All Region';
        templateConga.Region__c = 'Europe';
        templateConga.TypeOfCustomer__c = 'Travel Agency Association';
        templateConga.EmailTemplate__c = ct.Id;
        insert templateConga;
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.returnToCase();
        controller.selectedType = 'REI';
        controller.findTemplates();
        controller.goToCongaSendEmail();

        System.assert(SidraLiteSendEmailController.QUERY_PARENT_CASE!=null,'Conga Query "IRR letter gen. Conga 2010 - CS" not found');
        System.assert(SidraLiteSendEmailController.QUERY_ACCOUNT!=null,'Conga Query "IRR letter gen. Conga 2010 - CS" not found');
        Test.stopTest();
    }

    @isTest
    static void controller_OK_withoutTemplate() {
        Case cse = getSidraCase();
        cse.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';
        update cse;
        SidraLiteCongaTemplates__c templateConga = new SidraLiteCongaTemplates__c();
        templateConga.Name = 'Test Template Conga';
        templateConga.SidraLiteAction__c = 'REI';
        templateConga.SidraLiteReason__c = 'Financial Review Non-compliance';
        templateConga.Country__c = 'All Region';
        templateConga.Region__c = 'Europe';
        templateConga.TypeOfCustomer__c = 'Travel Agency Association';
        insert templateConga;
        ApexPages.StandardController stdController = new ApexPages.StandardController(cse);
        ApexPages.currentPage().getParameters().put('id',cse.Id);
        ApexPages.currentPage().getParameters().put('sessionId','test_session_id');
        ApexPages.currentPage().getParameters().put('serverUrl','http://testhost.com');

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController(stdController);
        controller.returnToCase();
        controller.selectedType = 'REI';
        controller.findTemplates();

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