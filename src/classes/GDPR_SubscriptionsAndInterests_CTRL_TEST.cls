@isTest

public class GDPR_SubscriptionsAndInterests_CTRL_TEST {
    
    
    @isTest
    static void getSubscriptionListTest(){
        
        // Insert credential
        Pardot_API__c pardotSetting = new Pardot_API__c();
        pardotSetting.API_Version__c = '4';
        pardotSetting.Password__c = 'fakePassword';
        pardotSetting.User_Key__c = '111111111';
        pardotSetting.Email__c = 'fake@fake.com';
        pardotSetting.Assigned_User__c = '1111111';
        insert pardotSetting;

		Contact c = new Contact(FirstName = 'fred', LastName = 'dev', Salutation = 'Mr.',  Email = 'fred.dev@iatatest.com');
        INSERT c;

        Lead l = new Lead(FirstName = 'fred', LastName = 'dev', Salutation = 'Mr.',  Email = 'fred.dev@iatatest.com', Company='iatatest');
        INSERT l;

        Pardot_API_RequestMock_Test fakeResponse =  new Pardot_API_RequestMock_Test('MOCK_READ_PROSPECT');
        Test.setMock(HttpCalloutMock.class, fakeResponse);
       
        Test.startTest();
            list<GDPR_SubscriptionsAndInterests_CTRL.InterestsWrapper> intList = GDPR_SubscriptionsAndInterests_CTRL.getInterestList('iata.fred.dev+1@gmail.com', c.Id);
            String subList = GDPR_SubscriptionsAndInterests_CTRL.getSubscriptionList('iata.fred.dev+1@gmail.com', c.Id);
            Boolean updSubList = GDPR_SubscriptionsAndInterests_CTRL.updateSubscriptionList('56308118', 'iata.fred.dev+1@gmail.com', new list<String>{'111','222'}, new list<String>() );
            Boolean updSubList2 = GDPR_SubscriptionsAndInterests_CTRL.updateSubscriptionList('56308118', 'iata.fred.dev+1@gmail.com', new list<String>(), new list<String>{'111','222'} );
            Boolean optOut = GDPR_SubscriptionsAndInterests_CTRL.optOut('56308118', 'iata.fred.dev+1@gmail.com', true);
            Boolean optIn = GDPR_SubscriptionsAndInterests_CTRL.optIn(c.Id, 'iata.fred.dev+1@gmail.com', true);
            Boolean optIn2 = GDPR_SubscriptionsAndInterests_CTRL.optIn(l.Id, 'iata.fred.dev+1@gmail.com', true);  
            Boolean updateInterest = GDPR_SubscriptionsAndInterests_CTRL.updateInterest('56308118', 'iata.fred.dev+1@gmail.com', '', new list<String>());          
        Test.stopTest();

        
        
    }
    
}