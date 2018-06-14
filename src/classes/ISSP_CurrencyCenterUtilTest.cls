@isTest
private class ISSP_CurrencyCenterUtilTest {

    private static void init(){

    }
    
    @isTest static void testCheckIfUserHasAccessToServiceWithoutUser() {
        PageReference result = ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
        System.assertNotEquals(new PageReference('/ISSP_Homepage'),result);
    }
    
    @isTest static void testStampVisitDateTimeWithoutUser() {
        ISSP_CurrencyCenterUtil.stampVisitDateTime(8);
    }

    @isTest static void testMethodsWithUsers() {
        Test.startTest();

        Id conRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='Standard_Contact' AND SobjectType = 'Contact'].Id;
        Id accRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='Standard_Account' AND SobjectType = 'Account'].Id;

        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser','PowerPartner','PowerCustomerSuccess','CustomerSuccess'};
        Account acc = new Account (
        RecordTypeId = accRtId,
        Name = 'testAcc'
        );  
        insert acc;

        Contact con = new Contact (
        AccountId = acc.id,
        RecordTypeId = conRtId, 
        LastName = 'portalUser',
        FirstName = 'Name',
        User_Portal_Status__c = 'Approved User'
        );
        insert con;

        Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
         
        User newUser = new User(
        profileId = p.id,
        username = 'someuser@iata.org',
        email = 'someuser@iata.org',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = con.id
        );
        insert newUser;

        Portal_Applications__c app = new Portal_Applications__c(Application_URL__c='/ISSP_CurrencyCenterHome');
        insert app;

        Portal_Application_Right__c par = 
            new Portal_Application_Right__c(Contact__c=newUser.ContactId,Right__c = 'Access Granted',Portal_Application__c=app.Id);
        insert par;

        System.runAs(newUser){
            ISSP_CurrencyCenterUtil.stampVisitDateTime(8);
            ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
            ISSP_CurrencyCenterUtil.getPreviousVisitDateTime();
        }

        Test.stopTest();
        
    }

    @isTest static void testGetPreviousVisitDateTime() {
        ISSP_CurrencyCenterUtil.getPreviousVisitDateTime();
    }
    
}