@isTest
public class OneId_Troubleshooting_Controller_Test {
    
	public static String generateUniqueUserEmail() {
        return (System.now().getTime() + '@test' + UserInfo.getOrganizationId() + '.org').toLowerCase();
    }
    
    public static User createUserWithRole() {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        String userEmail = generateUniqueUserEmail();
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userWithRole = new User(alias = 'hasrole', email = userEmail, userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username = userEmail, License_Cost_Center__c = 'ISF005CH01');
        
        insert userWithRole;
        return userWithRole;
    }
    
    public static User createGuestUser() {
        
        Id p = [select id from profile where name='System Administrator'].id;

        User user = new User(Alias = 'testuser', Email='testuser@example.com',
                             EmailEncodingKey='UTF-8', LastName='identity Site Guest User', LanguageLocaleKey='en_US',
                             LocalesIdKey='en_US', ProfileId = p, Country='United States', IsActive =true,
                             TimeZonesIdKey='America/Los_Angeles', Username='NDCGuestuserexmple732837489573945@example.com', License_Cost_Center__c = 'ISF005CH01');
        
        insert user;
        return user;
    }
    
    public static User createNonGuestUser() {
        
        Id p = [select id from profile where name='Partner Community User'].id;
        
        System.runAs(createUserWithRole()){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
            Account ac = new Account(RecordTypeId = recordTypeId, Name ='AirlineAcc') ;
            insert ac;
            
            Contact con = new Contact(LastName ='AirlineCon',AccountId = ac.Id, Email='testuser@example.com');
            insert con;
        }
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'AirlineCon'];
        User user = new User(Alias = 'testuser', Email='testuser@example.com',
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                             LocalesIdKey='en_US', ProfileId = p, Country='United States', IsActive =true,
                             ContactId = cont.Id,
                             TimeZonesIdKey='America/Los_Angeles', Username='testuser@example.com', License_Cost_Center__c = 'ISF005CH01');
        
        insert user;
        return user;
    }
    
    @isTest
    public static void testSubmitAsGuest() {
        
        Case cse = new Case();
        cse.Case_Creator_Email__c = 'casecreator@example.com';
        cse.Subject = 'testTroubleshootingController';
        cse.Description = 'test';

        Test.startTest();
        System.runAs(createGuestUser()) {
        	OneId_Troubleshooting_Controller.submit(cse);
        }
        Test.stopTest();
        
        List<Case> cseResult = [SELECT Id FROM Case WHERE Subject = 'testTroubleshootingController'];
        
        System.assertEquals(1, cseResult.size());
    }
    
    @isTest
    public static void testSubmitAsNonGuest() {
        
        Case cse = new Case();
        cse.Case_Creator_Email__c = 'casecreator@example.com';
        cse.Subject = 'testTroubleshootingController';
        cse.Description = 'test';

        Test.startTest();
        System.runAs(createNonGuestUser()) {
        	OneId_Troubleshooting_Controller.submit(cse);
        }
        Test.stopTest();
        
        List<Case> cseResult = [SELECT Id, subject FROM Case ];
        
//        System.assertEquals('test', cseResult[0].subject);
    }
    
    @isTest
    public static void testLoadEmptyCaseGuest() {
        
        Case emptyCase;
        
        Test.startTest();
        System.runAs(createGuestUser()) {
            emptyCase = OneId_Troubleshooting_Controller.loadEmptyCase();
        }
        Test.stopTest();
        
        system.assertEquals('', emptyCase.Subject);
    }
    
    @isTest
    public static void testLoadEmptyCaseNonGuest() {
        
        Case emptyCase;
        
        Test.startTest();
        System.runAs(createNonGuestUser()) {
            emptyCase = OneId_Troubleshooting_Controller.loadEmptyCase();
        }
        Test.stopTest();
        
        system.assertEquals('', emptyCase.Subject);
    }
}