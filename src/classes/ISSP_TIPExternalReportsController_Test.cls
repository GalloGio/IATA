@isTest
private class ISSP_TIPExternalReportsController_Test {

    private static ISSP_TIP_External_Reports_Controller controller;
    private static ISSP_External_Report__c er;
    private static AmazonFile file;

    @testSetup
    public static void loadCredentials() {
        WrapperAttachTest.loadTestCredentials(); 
    }
    
    static void createTestData() {

        //Account
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        //Contact
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;

        //User
        User user = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = user.Id;
        update con;
        
        //Portal
        Portal_Applications__c portal = new Portal_Applications__c();
        portal.Name = 'TIP Reports';
        insert portal;

        //External report config (custom setting)
        ISSP_External_Reports_Config__c custom_setting = new ISSP_External_Reports_Config__c();
        custom_setting.Portal_Service_ID__c = portal.Id;
        custom_setting.Report_ID__c = 'ER-001';
        custom_setting.Name = 'ER-001';
        insert custom_setting;

        //Portal access
        Portal_Application_Right__c appRight = new Portal_Application_Right__c();
        appRight.Contact__c = con.Id;
        appRight.Portal_Application__c = portal.Id;
        appRight.Right__c = 'Access Granted';
        insert appRight;

        //External report
        er = new ISSP_External_Report__c();
        er.Account__c = acc.Id;
        er.Report_ID__c = 'ER-001';
        er.Name = 'ER-001';
        insert er;

        //Amazon file
        file = WrapperAttachTest.createAmazonFile(er, 'testname');


        System.runAs(user) {
            PageReference pageRef = Page.ISSP_TIP_External_Reports;
            Test.setCurrentPage(pageRef);
            controller = new ISSP_TIP_External_Reports_Controller();

            controller.init();
        }
    }

    static testMethod void Test_1() {
        createTestData();

        System.assertEquals(1, [select count() from AmazonFile__c]);

        ISSP_TIP_External_Reports_Controller.getExpiringLinkIfap('testname');

        ISSP_TIP_External_Reports_Controller.createDocumentTrackerRecord(file.getId(), er.Id);
        System.assertEquals(1, [select count() from ISSP_Document_Tracker__c where Type__c = 'TIP Report']);
    }

}