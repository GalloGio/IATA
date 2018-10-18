@isTest
private class ISSP_TIPExternalReportsController_Test {

    static testMethod void Test_1() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = acc.Id;
        insert con;

        //User thisUser = ISSP_ObjectFactory.createPortalUser(con);
        
        Portal_Applications__c portal = new Portal_Applications__c();
        portal.Name = 'TIP Reports';
        insert portal;

        ISSP_External_Reports_Config__c custom_setting = new ISSP_External_Reports_Config__c();
        custom_setting.Portal_Service_ID__c = portal.Id;
        custom_setting.Report_ID__c = 'ER-001';
        insert custom_setting;

        Portal_Application_Right__c appRight = new Portal_Application_Right__c();
        appRight.Contact__c = con.Id;
        appRight.Portal_Application__c = portal.Id;
        appRight.Right__c = 'Access Granted';
        insert appRight;

        ISSP_External_Report__c er = new ISSP_External_Report__c();
        er.Account__c = acc.Id;
        er.Report_ID__c = 'ER-001';
        er.Name = 'ER-001';
        insert er;


        /*ContactShare newShare = new ContactShare();
        newShare.ContactAccessLevel = 'Edit';
        newShare.ContactId = con.Id;
        newShare.UserOrGroupId = thisUser.Id;
        insert newShare;*/
        
        cttr.init();



    }

}