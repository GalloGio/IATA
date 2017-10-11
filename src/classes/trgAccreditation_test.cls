@isTest
public class trgAccreditation_test {

    @isTest  
    static void test1()
    {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Business Administrator'];
        User testUser = New User(
          Alias = 'standt', Email='standarduser@testorg.com',
          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
          LocaleSidKey='en_US', ProfileId = testProfile.Id,
          TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );

        System.runAs(testUser) {
          Accreditation__c acc = new Accreditation__c();
            insert acc;
        }
    }
}
