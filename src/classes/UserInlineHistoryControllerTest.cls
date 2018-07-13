@isTest
private class UserInlineHistoryControllerTest {
    
    @testSetup static void setup(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, License_Cost_Center__c = 'ISF005CH01',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testhistory.com');        
        insert u;
        
        User_History__c uh1 = new User_History__c();
        uh1.User__c = u.Id;
        uh1.Old_Value__c = '';
        uh1.New_Value__c = 'someValue';
        uh1.What__c = 'Email';
        uh1.ApiName__c = 'Email';
        insert uh1;

    }

    @isTest static void checkCustomTracking() {

        PageReference pageRef = Page.UserInlineHistory;
        Test.setCurrentPage(pageRef);

        User user1 = [Select id from user where UserName = 'standarduser@testhistory.com'];

        ApexPages.StandardController con = new ApexPages.StandardController(user1);
        UserInlineHistoryController extension = new UserInlineHistoryController(con);

        //we should only have 1 record in history
        system.assertEquals(1,extension.historiesList.size());
    }
    
}