@isTest
public class PortalNewsCtrlTest {
    @TestSetup
    public static void testSetup() {
        Id airlineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) { // AVOID MIXED_DML_OPERATION
            Account acc = ISSP_ObjectFactory.createNewAccount();
            acc.Name = 'Account Test Portal Documents';
            acc.Sector__c = 'Airline';
            acc.Category__c = 'Passenger and Cargo';
            acc.RecordTypeId = airlineRT;
            insert acc;

            Contact con = ISSP_ObjectFactory.createNewContact();
            con.AccountId = acc.Id;
            con.FirstName = 'Contact';
            con.LastName = 'Test Portal Documents';
            con.Email = System.today().dayOfYear() + 'testemail1@csp.testclass';
            con.User_Portal_Status__c = 'Approved Admin';
            insert con;

            User usr = ISSP_ObjectFactory.createPortalUser(con);

            con.OwnerId = usr.Id;
            update con;

            ISSP_Banner__c banner = new ISSP_Banner__c();
            banner.Sector__c = 'Airline';
            banner.User_portal_Status__c = 'Approved User;Approved Admin;Pending Approval';
            banner.Country__c = 'All - Globally';
            banner.Publication_start_date__c = Date.today().addDays(-1);
            banner.Publication_end_date__c = Date.today().addDays(3);
            banner.Status__c = 'Active';
            insert banner;

            ISSP_Banner_Visibility__c bannerVisibility = new ISSP_Banner_Visibility__c();
            bannerVisibility.Sector__c = 'Airline';
            bannerVisibility.Category__c = 'Passenger and Cargo';
            bannerVisibility.ISSP_Banner__c = banner.Id;
            insert bannerVisibility;

            ContentVersion contentToInsert = new ContentVersion();
            contentToInsert.Title = 'ContentVersion Test Portal Documents';
            contentToInsert.PathOnClient = '/' + contentToInsert.Title + '.JPG'; 
            contentToInsert.VersionData = Blob.valueOf('Test Content');
            contentToInsert.IsMajorVersion = true;
            insert contentToInsert;

            ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentToInsert.Id LIMIT 1];

            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.ContentDocumentId = testContent.ContentDocumentId;
            contentLink.LinkedEntityId = banner.Id;
            contentLink.ShareType = 'V';
            contentLink.Visibility = 'AllUsers';
            insert contentLink;
        }
    }

    @isTest static void testGetBanners() {
        User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        Test.startTest();
            System.runAs(testUser) {
                List<PortalNewsController.WrapperBanner> banners = PortalNewsController.getBannerInformation();
                System.assertNotEquals(0, banners.size());
            }
        Test.stopTest();
    }    
}