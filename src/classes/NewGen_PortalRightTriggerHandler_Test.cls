@isTest
private class NewGen_PortalRightTriggerHandler_Test {
    @testSetup
    static void setup() {
        Portal_Applications__c easyPay1 = new Portal_Applications__c (
                Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false,
                Agency__c = true,
                NewGenAPP_ShortName__c = 'epay'
            );

        insert easyPay1;

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
                Name = 'Portugal_test',
                ISO_Code__c = 'PT',
                ANG_Portal_Service__c = easyPay1.id,
                ANG_Enable_NewGen__c = true
            );   

        insert portugal;                 

        Account topParent = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = portugal.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
                Location_type__c = 'HE',
                OwnerId = UserInfo.getUserId(),
                Reason_for_creation__c = 'Created by customer',
                Location_Class__c = 'P'
            );

        insert topParent;

        Account a = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = portugal.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
                Location_type__c = 'HE',
                OwnerId = UserInfo.getUserId(),
                Top_Parent__c = topParent.id,
                Reason_for_creation__c = 'Created by customer',
                Location_Class__c = 'P'
            );

        insert a;

        String accountId = String.valueOf(a.id).substring(0, 15);

        Contact c = new Contact (
                FirstName = 'Name',
                LastName = 'ContactTest',
                accountID = a.id,
                Email = 'email@fake.com'
            );

        insert c;

        User u = ISSP_ObjectFactory.createPortalUser(c);
        c.OwnerId = u.Id;
        update c;

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){
            Portal_Application_Right__c appRight = new Portal_Application_Right__c(
                    Portal_Application__c = easyPay1.id,
                    Right__c = 'Access Requested',
                    Contact__c = c.Id
            );
            insert appRight;
        }

        NewGenApp_Custom_Settings__c newgenCS = new NewGenApp_Custom_Settings__c();
        newgenCS.Push_Notifications_State__c = true;
        insert newgenCS;
    }

    static testMethod void testPushNotifications() {
        List <Portal_Application_Right__c> portalRight = new List <Portal_Application_Right__c>([SELECT Id FROM Portal_Application_Right__c]);

        System.assert(portalRight.size() == 1);

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){
            // simulate admin access grant
            portalRight[0].Right__c = 'Access Granted';
            update portalRight;
        }
    }

    static testMethod void testPushNotifications2() {
        List <Portal_Application_Right__c> portalRight = new List <Portal_Application_Right__c>([SELECT Id FROM Portal_Application_Right__c]);

        System.assert(portalRight.size() == 1);

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){
            // simulate admin access grant
            portalRight[0].Right__c = 'Access Denied';
            update portalRight;

            portalRight[0].Right__c = 'Access Requested';
            update portalRight;
        }
    }
}