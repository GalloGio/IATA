@isTest 
private class RegistrationComunicationsControllerTest {

    private static String ALL = 'all';
    private static String NONE = 'none';
    private static String SOME = 'some';
    private static String EMAIL = 'email';
    private static String NOTIFICATION = 'notification';

    @TestSetup
    static void makeData(){

        //Folder f = New Folder(name = 'MyDocuments', Type='Document');
        //insert f;

        Document document;
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'CSP_Notification_Header_Image';
        document.IsPublic = true;
        document.Name = 'CSP_Notification_Header_Image';
        document.FolderId =  UserInfo.getUserId(); //document will added the My Personal Documents folder
        insert document;

        Notification_template__c template = new Notification_template__c(
                Identifier__c = 'Lvl 2 Registration reminder',
                Message__c = '<p>Test Message</p><p>[URL]</p><p>[CustomerName]</p>',
                Alert_Contact_By_Email__c = false,
                Alert_Contact_By_Push_Notification__c = true,
                Subject__c = 'Test Subject',
                Type__c = 'Information',
                Notification_color__c = '#007FFF',
                CriticalNotification__c = true,
                Expire_in_days__c = 1
            );

        insert template;

        Account newAccount = new Account();
        newAccount.Name = 'Test Account 1';
        newAccount.Sector__c = 'Airline';
        newAccount.Category__c = 'Military';
        newAccount.Is_General_Public_Account__c = true;        
        newAccount.Reason_for_creation__c = 'Account is missing';     

        Account newAccount2 = new Account();
        newAccount2.Name = 'Test Account 2';
        newAccount2.Sector__c = 'Airline';
        newAccount2.Category__c = 'Cargo only';
        newAccount2.Is_General_Public_Account__c = true;      
        newAccount2.Reason_for_creation__c = 'Account is missing';    

        insert (new List<Account>{newAccount,newAccount2}); 

        Contact newContact = new Contact();
        newContact.FirstName = 'test';
        newContact.LastName = 'test'; 
        newContact.Email = 'my_test_email@test.test';
        newContact.AccountId = newAccount.Id;
        newContact.Preferred_Language__c = 'English';

        Contact newContact2 = new Contact();
        newContact2.FirstName = 'test2';
        newContact2.LastName = 'test2'; 
        newContact2.Email = 'my_other_test_email@test.test';
        newContact2.AccountId = newAccount2.Id;  
        newContact2.Preferred_Language__c = 'Portuguese';

        insert new List<Contact> {newContact,newContact2};

        Id profileId = [select Id from profile where Name=:'ISS Portal (Partner)'].Id;

        User newUser = new User(alias = 'test', 
                                email = newContact.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = newContact.firstName, 
                                lastname = newContact.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = newContact.Id,
                                //FederationIdentifier = conId15,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'my_test_email@test.test',
                                PortalRole = '',
                                CommunityNickname = 'test User',
                                ProfileId = profileId,
                                IsActive = true);

        User newUser2 = new User(alias = 'test', 
                                email = newContact2.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = newContact2.firstName, 
                                lastname = newContact2.lastname, 
                                languagelocalekey = 'pt_BR', 
                                localesidkey = 'pt_BR', 
                                contactId = newContact2.Id,
                                //FederationIdentifier = conId15,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'my_other_test_email@test.test',
                                PortalRole = '',
                                CommunityNickname = 'test2 User',
                                ProfileId = profileId,
                                IsActive = true);
            
        insert (new List<User>{newUser,newUser2});
            
    }

     @isTest 
    private static void shouldExitDueToNoData(){

        Test.startTest();
            Map<String,Boolean> result = RegistrationComunicationsController.sendSingleLevel2RegistrationAlert(null);
        Test.stopTest();        

        System.assertEquals(false, result.get(EMAIL));
        System.assertEquals(false, result.get(NOTIFICATION));
    }

    @isTest 
    private static void shouldExitDueToNoEmptyInput(){

        Test.startTest();
            Map<String,String> result = RegistrationComunicationsController.sendBatchLevel2RegistrationAlert(null);
        Test.stopTest();        

        System.assertNotEquals(null, result);
        System.assertEquals(NONE, result.get(EMAIL));
        System.assertEquals(NONE, result.get(NOTIFICATION));
    }

    @isTest 
    private static void shouldSendOneEmailAndNotification(){

        Test.startTest();
            Id contactId = [SELECT Id FROM Contact WHERE Email = 'my_test_email@test.test'].Id;
            List<Notification__c> notificationsBefore = [SELECT Id,Contact__c FROM Notification__c WHERE Contact__c = :contactId];
            //FOR testing purposes sometimes the user creation (in test setup) is creating a notification
            Map<String,Boolean> result = RegistrationComunicationsController.sendSingleLevel2RegistrationAlert(contactId);
            Integer invocations = Limits.getEmailInvocations();
            List<Notification__c> notifications = [SELECT Id,Contact__c FROM Notification__c WHERE Contact__c = :contactId];
            System.debug(notifications);

            Contact updated = [SELECT Id, Last_registration_notification_date__c FROM Contact WHERE Email = 'my_test_email@test.test'];
        Test.stopTest();        

        System.assertEquals(true,  result.get(EMAIL));
        System.assertEquals(true,  result.get(NOTIFICATION));
        System.assertEquals(1, invocations);
        System.assertEquals(1, notifications.size() - notificationsBefore.size());
        System.assertEquals(System.today(),updated.Last_registration_notification_date__c );
    }

    @isTest 
    private static void shouldSendOneEmailAndNotificationWithDefaultTemplate(){

        Test.startTest();
            Id contactId = [SELECT Id FROM Contact WHERE Email = 'my_other_test_email@test.test'].Id;
            Map<String,Boolean> result = RegistrationComunicationsController.sendSingleLevel2RegistrationAlert(contactId);
            Integer invocations = Limits.getEmailInvocations();
            List<Notification__c> notifications = [SELECT Id,Contact__c FROM 	Notification__c WHERE Contact__c = :contactId];
        Test.stopTest();        

        System.assertEquals(true,  result.get(EMAIL));
        System.assertEquals(true,  result.get(NOTIFICATION));
        System.assertEquals(1, invocations);
        System.assertEquals(1, notifications.size());
    }

    @isTest 
    private static void shouldSuccedToAll(){

        Contact newContact = [SELECT Id, email, firstName,lastname  FROM Contact WHERE email = 'my_test_email@test.test'][0];
        Contact newContact2 = [SELECT Id, email, firstName,lastname  FROM Contact WHERE email = 'my_other_test_email@test.test'][0];

        Test.startTest();
            List<Notification__c> notificationsBefore = [SELECT Id,Contact__c FROM Notification__c ];
            //FOR testing purposes sometimes the user creation (in test setup) is creating a notification

            Map<String,String> result = RegistrationComunicationsController.sendBatchLevel2RegistrationAlert(new List<Id>{newContact.Id,newContact2.Id});
            Integer invocations = Limits.getEmailInvocations();
            List<Notification__c> notifications = [SELECT Id,Contact__c FROM Notification__c ];
        Test.stopTest();        


        System.assertNotEquals(null, result);
        System.assertEquals(ALL, result.get(EMAIL));
        System.assertEquals(ALL, result.get(NOTIFICATION));
        System.assertEquals(1, invocations);
        System.assertEquals(2,notifications.size() - notificationsBefore.size());
    }
}