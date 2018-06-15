/**
 * This class test the send notification by contact, which trigger by the account update.
 * Files tested:
 * 1. ISSP_Notification_Account_AfterUpdate.trigger
 * 2. ISSP_AccountTriggerHandler.cls
 * 3. ISSP_NotificationUtilities.cls
 * Created By:  Efraim Fligil 19-11-2014
 * Modified By: Niv.Goldenberg 13-12-2014
 */
@isTest
private class ISSP_AccountTriggerHandlerTest 
{
    /**
     * [Test notification trigger process]
     * Created By:  Efraim Fligil 19-11-2014
     * Modified By: Niv.Goldenberg 13-12-2014
     */
    static testMethod void test001() 
    {
        
        Notification_template__c nt = new Notification_template__c();
        nt.Subject__c = 'Test 001';
        nt.Type__c = 'Action';
        nt.Admins_Users__c = 'User';
        nt.Message__c = 'test {0}';
        nt.Notification_color__c = '#007FFF';
        insert nt;
        
        //Check if custom settings for notificaiton trigger are in the data (visible in test), if not create fake for test.    
        if(null == ISSP_AccountTriggerHandler.notificationsTrigger) 
        { 
            System.debug('KTC - ISSP_AccountTriggerHandler.notificationsTrigger: ' + ISSP_AccountTriggerHandler.notificationsTrigger);
        	ISSP_Notifications_Trigger__c ntr = new ISSP_Notifications_Trigger__c();
            ntr.Name = 'Acount Test 001';    
            ntr.FieldSetAPIName__c = 'ISSP_Notification_Trigger_Field_Set';
            ntr.Notification_Template_Id__c = nt.Id;
           	insert ntr;	   
            System.debug('KTC - ntr: ' + ntr);
            ISSP_AccountTriggerHandler.notificationsTrigger = ntr;
        }
        
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'Test 001';
        acc.Type = 'IATA Cargo Agent';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;
        
        //Contact cont = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact cont = ISSP_ObjectFactory.createNewContact();
        cont.Email = 'test@test.com';
        cont.FirstName = 'test';
        cont.LastName = 'tester';
        cont.User_Portal_Status__c = 'Approved Admin';
        cont.AccountId = acc.Id;
        insert cont;

        ISSP_AccountTriggerHandler.preventTrigger = false;
        acc.Accumulated_Irregularities__c = 613;
        update acc;

        //Check that one notification has been inserted.
        List<Notification__c> lstNotifications = [SELECT Id, Message__c FROM Notification__c];
        System.assertEquals(1, lstNotifications.size());

        //Check that the notificaiton message is included with Accumulated_Irregularities__c of 613.
        System.assertEquals('613', lstNotifications[0].Message__c.split(' ')[1]);
    }

    /**
     * [Test notification batch process]
     * Created By:  Niv.Goldenberg 13-12-2014
     * Modified By: Niv.Goldenberg 13-12-2014
     */
    static testMethod void test002() 
    {
        Notification_template__c nt = new Notification_template__c();
        nt.Subject__c = 'Test 001';
        nt.Type__c = 'Action';
        nt.Admins_Users__c = 'User';
        nt.Message__c = 'test {0}';
        nt.Notification_color__c = '#007FFF';
        insert nt;

        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'Test 001';
        acc.Type = 'IATA Cargo Agent';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;
        
        //Contact cont = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact cont = ISSP_ObjectFactory.createNewContact();
        cont.Email = 'test@test.com';
        cont.FirstName = 'test';
        cont.LastName = 'tester';
        cont.User_Portal_Status__c = 'Approved Admin';
        cont.AccountId = acc.Id;
        insert cont;

        Test.startTest();
        ISSP_NotificationBatch bc = new ISSP_NotificationBatch();
        bc.Query = 'SELECT ' + String.join(ISSP_NotificationUtilities.getAllContactFields(), ',') + ' FROM Contact WHERE Id IN (\'' + cont.Id + '\')';
        bc.NotificationTemplate = nt;
        bc.MessagesByGroupMap = null;
        bc.ContactGroupField = 'AccountId';
        Database.executeBatch(bc, 1);
        Test.stopTest();

        //Check that one notification has been inserted.
        //List<Notification__c> lstNotifications = [SELECT Id FROM Notification__c];
        //System.assertEquals(1, lstNotifications.size());
    }
}