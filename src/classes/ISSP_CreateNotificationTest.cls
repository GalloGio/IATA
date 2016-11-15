@isTest
public class ISSP_CreateNotificationTest {

    public static testMethod void testISSP_CreateNotificationTest() {
         //ISSP_ObjectFactory.fiilIncludedFields();
         
         Notification_template__c notificationTemplate = new Notification_template__c();  
            //(Notification_template__c)ISSP_ObjectFactory.createSObject('Notification_template__c',false,1);
         insert notificationTemplate;
        
        Notification_template__c notificationTemplate2 =  new Notification_template__c();
            //(Notification_template__c)ISSP_ObjectFactory.createSObject('Notification_template__c',false,1);
        notificationTemplate2.Admins_Users__c = 'Administrators';
        insert notificationTemplate2;
        
        notificationTemplate = [select Name from Notification_template__c  where Id =:notificationTemplate .Id];
        notificationTemplate2 = [select Name from Notification_template__c  where Id =:notificationTemplate .Id];
        
         Contact contact = ISSP_ObjectFactory.createNewContact();
            //(Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
         insert contact;
         
         Portal_Applications__c app = new Portal_Applications__c(Name = 'test app'); 
		 insert app;
         Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
         par.Contact__c = contact.Id;
         insert par;
         
         Case testCase = ISSP_ObjectFactory.createNewCase();
            //(Case)ISSP_ObjectFactory.createSObject('Case',false,3);
         insert testCase;
         
        
         list<Notification__c> notificationList = [select id from Notification__c];
         Test.startTest();
             contact.Notification_Template__c = notificationTemplate.Name;
             par.Notification_Template__c = notificationTemplate.Name;
             testCase.Notification_Template__c = notificationTemplate2.Name;
             ISSP_CreateNotification.CreateNotificationForSobjectList(new list<sObject>{(sObject)contact});
             ISSP_CreateNotification.CreateNotificationForSobjectList(new list<sObject>{(sObject)par});
             ISSP_CreateNotification.CreateNotificationForSobjectList(new list<sObject>{(sObject)testCase});
         Test.stopTest(); 
         //System.assertEquals(notificationList.size(),3);
    }
}