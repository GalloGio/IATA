@isTest
public class PortalRecommendationCtrlTest {
    @TestSetup
    public static void testSetup() {
        Id airlineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Account acc = ISSP_ObjectFactory.createNewAccount();
            acc.Name = 'Account Test Recommendation Visibility';
            acc.Sector__c = 'Airline';
            acc.Category__c = 'Passenger and Cargo';
            acc.RecordTypeId = airlineRT;
            insert acc;

            Contact con = ISSP_ObjectFactory.createNewContact();
            con.AccountId = acc.Id;
            con.FirstName = 'Contact';
            con.LastName = 'Test Recommendation Visibility';
            con.Email = System.today().dayOfYear() + 'testemail1@csp.testclass';
            insert con;

            User usr = ISSP_ObjectFactory.createPortalUser(con);

            Id recommendationRT = RecordTypeSingleton.getInstance().getRecordTypeId('Recommendations_Visibility__c', 'ServiceRecommendation');
            Recommendations_Visibility__c recommendation = new Recommendations_Visibility__c(
                IsActive__c = true,
                StartDate__c = Date.today().addDays(-2),
                EndDate__c = Date.today().addDays(2),
                RecordTypeId = recommendationRT
            );
            insert recommendation;

            Card_Visibility__c cardVisibility = new Card_Visibility__c(
                Recommendation_Visibility__c = recommendation.Id,
                Sector__c = acc.Sector__c,
                Category__c = acc.Category__c
            );
            
            insert cardVisibility;
        }
    }

    @isTest
    public static void testGetRecommendations() {
        User testUser = [SELECT Id, Contact.Account.Sector__c, Contact.Account.Category__c FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];       

        Test.startTest();
        System.runAs(testUser) {
            List<PortalRecommendationCtrl.RecommendationWrapper> recommendations = PortalRecommendationCtrl.getRecommendations('Services');
            System.assertEquals(0, recommendations.size());
        }
        Test.stopTest();
    }
}