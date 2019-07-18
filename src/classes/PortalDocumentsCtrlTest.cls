@isTest
public class PortalDocumentsCtrlTest {
    @TestSetup
    public static void testSetup() {
        Id airlineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) { // AVOID MIXED_DML_OPERATION
            IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(ISO_Code__c = 'SC', Name = 'Some Country', Region__c = 'Europe');
            insert isoCountry;

            Account acc = ISSP_ObjectFactory.createNewAccount(); 
            acc.Name = 'Account Test Portal Documents';
            acc.Sector__c = 'Airline';
            acc.Category__c = 'Passenger and Cargo';
            acc.IATA_ISO_Country__c = isoCountry.Id;
            acc.IATACode__c = 'TEST';
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

            insert new Access_to_Libraries_on_Portal__c(
                Name = 'Group Test Portal Documents',
                Sector_of_Account__c = 'Airline',
                Record_Type_of_Account__c = 'Airline Headquarters',
                Library_visibility__c = 'Airline Test Portal Documents',
                Category_of_Account__c = 'Passenger and Cargo'
            );

            ContentWorkspace workspaceToInsert = new ContentWorkspace();
            workspaceToInsert.Name = 'Library Test Portal Documents';
            insert workspaceToInsert;

            ContentVersion content = new ContentVersion(); 
            content.ContentURL = 'http://www.salesforce.com/';
            content.Title = 'ContentVersion Test Portal Documents';
            content.Country_of_publication__c = 'All - Globally';
            content.Country_visibilty__c = 'All - Globally';
            content.Document_Category__c = 'Calendars';
            content.User_status_access__c = 'Approved User;Approved Admin';

            ContentVersion content2 = new ContentVersion(); 
            content2.ContentURL = 'http://www.salesforce.com/';
            content2.Title = 'ContentVersion Test2 Portal Documents';
            content2.Country_of_publication__c = 'Belgium';
            content2.Country_visibilty__c = 'All - Globally';
            content2.Document_Category__c = 'Calendars';
            content2.User_status_access__c = 'Approved User;Approved Admin';

            insert new List<ContentVersion>{content, content2};
        }
    }

    @isTest static void testGetDocuments() {
        User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        List<ContentVersion> testContent = [SELECT Id, Title, Document_Category__c, Country_of_publication__c FROM ContentVersion WHERE Title = 'ContentVersion Test Portal Documents'];
        List<ContentVersion> testContent2 = [SELECT Id, Title, Document_Category__c, Country_of_publication__c FROM ContentVersion WHERE Title = 'ContentVersion Test2 Portal Documents'];
        List<IATA_ISO_Country__c> isoCountry = [SELECT Name, Region__c FROM IATA_ISO_Country__c WHERE Name = 'Some Country'];

        Test.startTest();
            System.runAs(testUser) {
                PortalDocumentsController.PagedResult docsWithoutFilter = PortalDocumentsController.getSearchDocuments(testContent[0].Title, testContent[0].Document_Category__c, '', testContent[0].Country_of_publication__c, 0, testContent[0].Id);
                
                List<ContentVersion> contents = PortalDocumentsController.sortContentVersions(testContent, isoCountry[0].Name, isoCountry[0].Region__c);
                System.assertEquals(1, contents.size());

                List<ContentVersion> contents2 = PortalDocumentsController.sortContentVersions(testContent2, isoCountry[0].Name, isoCountry[0].Region__c);
                System.assertEquals(1, contents2.size());
            }
        Test.stopTest();
    }
}