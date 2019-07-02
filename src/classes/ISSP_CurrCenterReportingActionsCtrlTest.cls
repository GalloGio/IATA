@IsTest
private class ISSP_CurrCenterReportingActionsCtrlTest {

    @testSetup 
    static void init() {
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.BillingCity = 'test2';
        acc.Name = 'test2';
        acc.Reason_for_creation__c = 'Other';
        acc.Comments_Reason_for_creation__c = 'Test Account';
        insert acc;
        
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= acc.Id;
        contact.Email = 'Test@test11.com';
        insert contact;
        
        User testUser = ISSP_ObjectFactory.createPortalUser(contact);
        contact.OwnerId = testUser.Id;
        update contact;       
    }

    @IsTest
    static void test01() {        
        test.startTest();
        
        User portalUser = [SELECT Id, ContactId FROM User WHERE ContactId in (SELECT Id FROM Contact)][0];
        
        Portal_Applications__c currencyCenter = new Portal_Applications__c(name = 'Currency Center');
        insert currencyCenter;
        
        System.RunAs(portalUser) {
            Portal_Application_Right__c portalAppRight = new Portal_Application_Right__c(Portal_Application__c = currencyCenter.Id, Contact__c = portalUser.ContactId, Right__c= 'Access Granted');
            insert portalAppRight ;
            ISSP_CurrencyCenterReportingActionsCtrl ctrl = new ISSP_CurrencyCenterReportingActionsCtrl();
            ctrl.updateAppRight();
        }
        
        test.stopTest();
    }
}