@isTest
private class UserControllerTest {

    @TestSetup
    static void makeData(){

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
        newContact.LastName = 'test'; 
        newContact.Email = DateTime.now().getTime() +'_test@test.test';
        newContact.AccountId = newAccount.Id;
        newContact.Preferred_Language__c = 'English';
        newContact.Country__c = 'Canada';
        newContact.Last_registration_notification_date__c = System.today();


        Contact newContact2 = new Contact();
        newContact2.FirstName = 'test2';
        newContact2.LastName = 'test2'; 
        newContact2.Email = DateTime.now().getTime() +'_test2@test.test';
        newContact2.AccountId = newAccount2.Id;        
        newContact2.Preferred_Language__c = 'Portuguese';
        newContact.Country__c = 'Portugal';
        newContact2.Last_registration_notification_date__c = System.today();


        insert (new List<Contact>{newContact,newContact2});

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
                                Username = 'testUsername@test.teste',
                                PortalRole = '',
                                CommunityNickname = 'test User',
                                ProfileId = profileId,
                                IsActive = true);

        User newUser2 = new User(alias = 'test', 
                                email = newContact2.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = newContact2.firstName, 
                                lastname = newContact2.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = newContact2.Id,
                                //FederationIdentifier = conId15,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'testUsername2@te st.teste',
                                PortalRole = '',
                                CommunityNickname = 'test2 User',
                                ProfileId = profileId,

                                IsActive = true);

            
            insert (new List<User>{newUser,newUser2});
    }

    @isTest 
    static void testItemsPerPage(){
        Integer items = UserController.getItemsPerPage();
        System.assertEquals(UserController.ITEMS_PER_PAGE, items);
    }

    @isTest 
    static void shouldReturnsAllGeneralPublicUsers(){
        Test.startTest();
        List<User> users = UserController.getGeneralPublicUsersByCategoryAndSector(null,'',null,null,0); 
        Test.stopTest();
        System.assertNotEquals(null, users);
        System.assertEquals(2, users.size());
    }

    @isTest 
    static void shouldReturnsOnlyGeneralPublicUsersSpeakingEnghlish(){
        Test.startTest();
        List<User> users = UserController.getGeneralPublicUsersByCategoryAndSector('Military','Airline',null,'English',0); 
        
        Test.stopTest();
        System.assertNotEquals(null, users);
        System.assertEquals(1, users.size());
        System.assertEquals('English', users.get(0).Contact.Preferred_Language__c);

    }

    @isTest 
    static void shouldReturnsOnlyMilitaryGeneralPublicUsers(){
        Test.startTest();
        List<User> users = UserController.getGeneralPublicUsersByCategoryAndSector('Military','Airline',null,null,0); 
        Test.stopTest();
        System.assertNotEquals(null, users);
        System.assertEquals(1, users.size());
    }

    @isTest 
    static void shouldReturnsTotalMilitaryGeneralPublicUsers(){
        Test.startTest();
        Integer users = UserController.getTotalGeneralPublicUsersByCategoryAndSector('Military','Airline',null,null);
    
        Test.stopTest();

        System.assertNotEquals(null, users);
        System.assertEquals(1, users);
    }

    @isTest 
    static void shouldReturnsUsersWithEnglishAsPreferredLanguage(){
        Test.startTest();
        Integer users = UserController.getTotalGeneralPublicUsersByCategoryAndSector('','Airline','','English'); 
        Test.stopTest();

        System.assertNotEquals(null, users);
        System.assertEquals(1, users);
    }

    @isTest 
    static void shouldReturnsTotalGeneralPublicUsers(){
        Test.startTest();
        Integer users = UserController.getTotalGeneralPublicUsersByCategoryAndSector('','Airline',null,null); 
        Test.stopTest();

        System.assertNotEquals(null, users);
        System.assertEquals(2, users);
    }

    @isTest 
    static void shouldReturnsAllGeneralPublicUsersIds(){
        Test.startTest();
        List<User> users = UserController.getAllGeneralPublicUsersIds(); 
        Test.stopTest();

        System.assertNotEquals(null, users);
        System.assertEquals(2, users.size());
    }

}