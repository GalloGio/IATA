@isTest 
private class NotificationCenterControllerTest {

    @TestSetup
    static void makeData(){
         Notification_template__c template = new Notification_template__c(
               Identifier__c = 'test notification template',
                Message__c = 'this is a dummy test message',
                Alert_Contact_By_Email__c = false,
                Alert_Contact_By_Push_Notification__c = true,
                Subject__c = 'Test Subject',
                Type__c = 'Information',
                Notification_color__c = '#007FFF',
                CriticalNotification__c = true,
                Expire_in_days__c = 1
            );
        insert template;

        Portal_Applications__c portalApp = new Portal_Applications__c(
            Name = 'testService'
        );
        insert portalApp;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.ISO_Code__c = 'CA';

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c();
        country2.Name = 'Portugal';
        country2.ISO_Code__c = 'PT';

        insert (new List<IATA_ISO_Country__c> {country,country2});

        Account newAccount = new Account();
        newAccount.Name = 'Test Account 1';
        newAccount.Sector__c = 'Airline';
        newAccount.Category__c = 'Military';
        newAccount.Is_General_Public_Account__c = true;   
        newAccount.IATA_ISO_Country__c = country.Id;        


        Account newAccount2 = new Account();
        newAccount2.Name = 'Test Account 2';
        newAccount2.Sector__c = 'Airline';
        newAccount2.Category__c = 'Cargo only';
        newAccount2.Is_General_Public_Account__c = true;      
        newAccount2.IATA_ISO_Country__c = country2.Id;        

        insert (new List<Account>{newAccount,newAccount2}); 

        Contact newContact = new Contact();
        newContact.FirstName = 'test';
        newContact.LastName = 'testUserController'; 
        newContact.Email = DateTime.now().getTime() +'_test@test.test';
        newContact.AccountId = newAccount.Id;
        newContact.Preferred_Language__c = 'English';
        newContact.Country__c = 'Canada';
        newContact.Community__c = 'ISS Customer Portal';
        newContact.Last_registration_notification_date__c = System.today();


        Contact newContact2 = new Contact();
        newContact2.FirstName = 'test2';
        newContact2.LastName = 'test2UserController'; 
        newContact2.Email = DateTime.now().getTime() +'_test2@test.test';
        newContact2.AccountId = newAccount2.Id;        
        newContact2.Preferred_Language__c = 'Portuguese';
        newContact.Country__c = 'Portugal';
        newContact2.Community__c = 'ISS Customer Portal';
        newContact2.Last_registration_notification_date__c = System.today();

        insert (new List<Contact>{newContact,newContact2});
    }

    @isTest
    static void shouldRetunOneTemplate(){
        Test.startTest();
        List<Notification_template__c> templates =  NotificationCenterController.getInformationNotificationTemplates();
        Test.stopTest();
        System.assertEquals(1, templates.size());
        System.assertEquals('test notification template', templates.get(0).Identifier__c);
    }

    @isTest 
    static void shouldReturnOnePortalService(){
        Test.startTest();
        List<AggregateResult> services = NotificationCenterController.getPortalServicesName();
        Test.stopTest();        
        System.assertEquals(1, services.size());
        System.assertEquals('testService',(services.get(0)).get('Name'));
    }

    @isTest 
    static void shouldReturnTwoCountries(){
        Test.startTest();
        List<AggregateResult> countries = NotificationCenterController.getAccountCoutries();
        Test.stopTest();        
        System.assertEquals(2, countries.size());
        System.assertEquals('Canada',(countries.get(0)).get('Name'));
        System.assertEquals('Portugal',(countries.get(1)).get('Name'));

    }

    @isTest 
    static void shouldFailDueToNoEmail(){
        Test.startTest();
        String result = NotificationCenterController.sendNotification('',false,new List<String>());
        Test.stopTest();    
        System.assertEquals('TEMPLATE ERROR', result);    
    }

    @isTest 
    static void shouldfailDueToEmptyContactIdList(){
        Test.startTest();
        Notification_template__c temp = [SELECT Name FROM Notification_template__c WHERE  Identifier__c = 'test notification template'];
         String result = NotificationCenterController.sendNotification(temp.Name,false,new List<String>());
        Test.stopTest();      
        System.assertEquals('none', result);     
    }

    @isTest 
    static void shouldfailDueToNoContactIdList(){
        Test.startTest();
        Notification_template__c temp = [SELECT Name FROM Notification_template__c WHERE  Identifier__c = 'test notification template'];
         String result = NotificationCenterController.sendNotification(temp.Name,false,null);
        Test.stopTest();      
        System.assertEquals('none', result);     
    }

    @isTest 
    static void shouldSendOneNotification(){
        Test.startTest();
        List<Contact> contacts= [SELECT Id FROM Contact];
        Notification_template__c temp = [SELECT Name FROM Notification_template__c WHERE  Identifier__c = 'test notification template'];
        String result = NotificationCenterController.sendNotification(temp.Name,false,new List<String>{contacts.get(0).Id});
        List<Notification__c> notifications = [SELECT Id FROM Notification__c];
        Test.stopTest();      
        System.assertEquals('all', result);
        System.assertEquals(1, notifications.size());     
    }

    @isTest 
    static void shouldSendTwoNotification(){
        Test.startTest();
        List<Contact> contacts= [SELECT Id FROM Contact];
        Notification_template__c temp = [SELECT Name FROM Notification_template__c WHERE  Identifier__c = 'test notification template'];
        String result = NotificationCenterController.sendNotification(temp.Name,false,new List<String>{contacts.get(0).Id,contacts.get(1).Id});
        Test.stopTest();      
        List<Notification__c> notifications = [SELECT Id FROM Notification__c]; 
        System.assertEquals('batch', result);
        System.assertEquals(2, notifications.size());     
    }

    @isTest 
    static void shouldFailDueToWrongContactId(){
        Test.startTest();
        List<Contact> contacts= [SELECT Id FROM Contact];
        Notification_template__c temp = [SELECT Name FROM Notification_template__c WHERE  Identifier__c = 'test notification template'];
        String Id1 = contacts.get(0).Id;
        Id1 = Id1.left(Id1.length() -1 ) + 'ç';
        String result = NotificationCenterController.sendNotification(temp.Name,false,new List<String>{Id1});
        Test.stopTest();      
        List<Notification__c> notifications = [SELECT Id FROM Notification__c]; 
        System.assertEquals('none', result);
        System.assertEquals(0, notifications.size());     

    }
}