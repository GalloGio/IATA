@isTest
private class ISSP_NotificationUtilitiesTest {
    
    @TestSetup
    static void loadData() {
        Notification_template__c masterTemplate = new Notification_template__c(
            Subject__c = 'English',
            Type__c = 'Action',
            Admins_Users__c = 'User',
            Message__c = 'test {0}',
            Notification_color__c = '#007FFF',
            language__c = 'English');
        insert masterTemplate;
        
        list<Notification_template__c> listTemplates = new list<Notification_template__c>();
        listTemplates.add(
            new Notification_template__c(
                Master_Notification_template__c = masterTemplate.Id,
                Subject__c = 'Spanish',
                Type__c = 'Action',
                Admins_Users__c = 'User',
                Message__c = 'test {0}',
                Notification_color__c = '#007FFF',
                language__c = 'Spanish'));
        listTemplates.add(
            new Notification_template__c(
                Master_Notification_template__c = masterTemplate.Id,
                Subject__c = 'French',
                Type__c = 'Action',
                Admins_Users__c = 'User',
                Message__c = 'test {0}',
                Notification_color__c = '#007FFF',
                language__c = 'French'));
        insert listTemplates;
    }

    static testMethod void test001() {
        //find templates
        Notification_template__c template = [
            Select Type__c, Subject__c, Notification_color__c, Name, Message__c, Master_Notification_template__c, Language__c, Id, Expire_in_days__c, Due_date__c, DDS_Update_Request__c, Alert_Contact_By_Email__c, Admins_Users__c, CriticalNotification__c,
                (Select Type__c, Subject__c, Notification_color__c, Name, Message__c, Master_Notification_template__c, Language__c, Id, Expire_in_days__c, Due_date__c, DDS_Update_Request__c, Alert_Contact_By_Email__c, Admins_Users__c, CriticalNotification__c
                from Notification_templates__r)
            From Notification_template__c
            Where Subject__c = 'English'
            Limit 1
        ];

        //load contact for different languages
        list<Contact> lstContacts = new list<Contact>();
        Contact englishContact = ISSP_ObjectFactory.createNewContact();
        englishContact.Email = 'test1@test.com';
        englishContact.FirstName = 'test1';
        englishContact.LastName = 'tester';
        englishContact.User_Portal_Status__c = 'Approved Admin';
        englishContact.Preferred_Language__c = 'English';
        lstContacts.add(englishContact);
        
        Contact spanishContact = ISSP_ObjectFactory.createNewContact();
        spanishContact.Email = 'test1@test.com';
        spanishContact.FirstName = 'test1';
        spanishContact.LastName = 'tester';
        spanishContact.User_Portal_Status__c = 'Approved Admin';
        spanishContact.Preferred_Language__c = 'Spanish';
        lstContacts.add(spanishContact);
        
        Contact frenchContact = ISSP_ObjectFactory.createNewContact();
        frenchContact.Email = 'test1@test.com';
        frenchContact.FirstName = 'test1';
        frenchContact.LastName = 'tester';
        frenchContact.User_Portal_Status__c = 'Approved Admin';
        frenchContact.Preferred_Language__c = 'French';
        lstContacts.add(frenchContact);
        
        Contact portugueseContact = ISSP_ObjectFactory.createNewContact();
        portugueseContact.Email = 'test1@test.com';
        portugueseContact.FirstName = 'test1';
        portugueseContact.LastName = 'tester';
        portugueseContact.User_Portal_Status__c = 'Approved Admin';
        portugueseContact.Preferred_Language__c = 'Portuguese';
        lstContacts.add(portugueseContact);
        
        insert lstContacts;

        Test.startTest();
        ISSP_NotificationUtilities.insertNotifications(lstContacts, template, null, null);
        Test.stopTest();

        //Check that one notification has been inserted for each contact
        Notification__c englishNotification = [Select Subject__c from Notification__c where Contact__c = :englishContact.Id];
        System.assertEquals('English', englishNotification.Subject__c);
        
        Notification__c spanishNotification = [Select Subject__c from Notification__c where Contact__c = :spanishContact.Id];
        System.assertEquals('Spanish', spanishNotification.Subject__c);
        
        Notification__c frenchNotification = [Select Subject__c from Notification__c where Contact__c = :frenchContact.Id];
        System.assertEquals('French', frenchNotification.Subject__c);
        
        Notification__c portugueseNotification = [Select Subject__c from Notification__c where Contact__c = :portugueseContact.Id];
        System.assertEquals('English', portugueseNotification.Subject__c);
    }

}