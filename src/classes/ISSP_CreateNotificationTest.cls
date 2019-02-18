@isTest
public class ISSP_CreateNotificationTest {

    public static testMethod void testISSP_CreateNotificationTest() {
        //ISSP_ObjectFactory.fiilIncludedFields();

        Notification_template__c notificationTemplate = new Notification_template__c();  
        //(Notification_template__c)ISSP_ObjectFactory.createSObject('Notification_template__c',false,1);
        Notification_template__c notificationTemplate2 =  new Notification_template__c();
        //(Notification_template__c)ISSP_ObjectFactory.createSObject('Notification_template__c',false,1);
        notificationTemplate2.Admins_Users__c = 'Administrators';
        notificationTemplate2.Expire_in_days__c = 3;
        insert new List<Notification_Template__c>{notificationTemplate, notificationTemplate2};
        
        notificationTemplate = [select Name from Notification_template__c  where Id =:notificationTemplate.Id];
        notificationTemplate2 = [select Name from Notification_template__c  where Id =:notificationTemplate2.Id];
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert new List<IATA_ISO_Country__c>{country};

        // Create an Airline HQ account
        Account top = new Account(Name = 'acc1');
        insert top;

        Account a = new Account(Name = 'acc1', ParentId = top.Id);
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.User_Portal_Status__c = 'Approved Admin';
        contact.AccountId = a.Id;
        //(Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        insert contact;
         
         Portal_Applications__c app = new Portal_Applications__c(Name = 'test app'); 
         insert app;
         Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
         par.Contact__c = contact.Id;
         insert par;

        User u = new User (
            Alias = 'newUser2', 
            Email='newuser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing3', 
            LanguageLocaleKey='en_US', 
            ContactId = contact.id,            
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User'].Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='newuser2@testorg.com',
            License_Cost_Center__c = 'XSMW01JO01'
        );
        insert u;
         
        insert new AccountTeamMember(AccountId = a.Id, UserId = u.Id, TeamMemberRole = ENV.TeamMemberRolePL.PortalAdministrator);

        Test.startTest();

         Case testCase = ISSP_ObjectFactory.createNewCase();
         testCase.ContactId = contact.Id;
            //(Case)ISSP_ObjectFactory.createSObject('Case',false,3);
         insert testCase;
         
        
         list<Notification__c> notificationList = [select id from Notification__c];
         
             contact.Notification_Template__c = notificationTemplate.Name;
             par.Notification_Template__c = notificationTemplate.Name;
             testCase.Notification_Template__c = notificationTemplate2.Name;
             ISSP_CreateNotification.CreateNotificationForSobjectList(new list<sObject>{(sObject)contact});
             ISSP_CreateNotification.CreateNotificationForSobjectList(new list<sObject>{(sObject)par});
             ISSP_CreateNotification.CreateNotificationForSobjectList(new list<sObject>{(sObject)testCase});
             ISSP_CreateNotification.SendEmailToPortalAdminNewContact(new List<Contact>{contact});
         Test.stopTest(); 
         //System.assertEquals(notificationList.size(),3);
    }

    /* 
        NewGen APP
    */
    public static testMethod void testAlert_Contact_By_Push_Notification() {
        Notification_template__c notificationTemplate = new Notification_template__c();
        notificationTemplate.Alert_Contact_By_Push_Notification__c = true;
        insert new List<Notification_Template__c>{notificationTemplate};
        
        notificationTemplate = [select Name, Alert_Contact_By_Push_Notification__c from Notification_template__c  where Id =:notificationTemplate.Id];
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert new List<IATA_ISO_Country__c>{country};

        // Create an Airline HQ account
        Account top = new Account(Name = 'acc1');
        insert top;

        Account a = new Account(Name = 'acc1', ParentId = top.Id);
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.User_Portal_Status__c = 'Approved Admin';
        contact.AccountId = a.Id;
        insert contact;
         
         Portal_Applications__c app = new Portal_Applications__c(Name = 'test app'); 
         insert app;
         Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
         par.Contact__c = contact.Id;
         insert par;

        User u = new User (
            Alias = 'newUser2', 
            Email='newuser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing3', 
            LanguageLocaleKey='en_US', 
            ContactId = contact.id,            
            LocaleSidKey='en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User'].Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='newuser2@testorg.com',
            License_Cost_Center__c = 'XSMW01JO01'
        );
        insert u;
         
        insert new AccountTeamMember(AccountId = a.Id, UserId = u.Id, TeamMemberRole = ENV.TeamMemberRolePL.PortalAdministrator);

        Test.startTest();
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.ContactId = contact.Id;
            testCase.Notification_Template__c = notificationTemplate.Name;
            insert testCase;

            contact.Notification_Template__c = notificationTemplate.Name;
            par.Notification_Template__c = notificationTemplate.Name;
            testCase.Notification_Template__c = notificationTemplate.Name;
            ISSP_CreateNotification.SendEmailToPortalAdminNewContact(new List<Contact>{contact});

            List <Notification__c> notificationSent = new List <Notification__c>([SELECT Name, Alert_Contact_By_Push_Notification__c 
                                                                                  FROM   Notification__c]);

            System.assertEquals(notificationTemplate.Alert_Contact_By_Push_Notification__c, notificationSent[0].Alert_Contact_By_Push_Notification__c, 'Field Alert_Contact_By_Push_Notification__c should be copied to notificationSent');

        Test.stopTest(); 
    }
}