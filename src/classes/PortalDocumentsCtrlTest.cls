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
				Library_visibility__c = 'Library Test Portal Documents',
				Category_of_Account__c = 'Passenger and Cargo'
			);

			ContentWorkspace workspaceToInsert = new ContentWorkspace();
			workspaceToInsert.Name = 'Library Test Portal Documents';
			insert workspaceToInsert;


			ContentWorkspacePermission cwp= new ContentWorkspacePermission(
				name='perm1',
				PermissionsManageWorkspace=true,
				PermissionsDeliverContent=true,
				PermissionsAddContent=true
				);
			
			insert cwp;
			ContentWorkspaceMember cwm= new ContentWorkspaceMember(
				ContentWorkspaceId=workspaceToInsert.id,
				ContentWorkspacePermissionId=cwp.id,
				MemberId=usr.id
			);
			insert cwm;

			ContentVersion content = new ContentVersion();
			content.Title = 'ContentVersion Test Portal Documents';
			content.Country_of_publication__c = 'Belgium';
			content.Country_visibilty__c = 'All - Globally';
			content.Document_Category__c = 'Calendars';
			content.User_status_access__c = 'Approved User;Approved Admin';
			content.PathOnClient ='test';
			content.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');

			ContentVersion content2 = new ContentVersion();
			content2.ContentURL = 'http://www.salesforce.com/';
			content2.Title = 'ContentVersion Test2 Portal Documents';
			content2.Country_of_publication__c = 'Belgium';
			content2.Country_visibilty__c = 'All - Globally';
			content2.Document_Category__c = 'Calendars';
			content2.User_status_access__c = 'Approved User;Approved Admin';

			insert new List<ContentVersion>{content, content2};

			
			contentVersion cv2=[select id,contentDocumentId from contentversion where id=:content.id];

			ContentWorkspaceDoc cwd= new ContentWorkspaceDoc(
				ContentWorkspaceId=workspaceToInsert.id,
				ContentDocumentId=cv2.contentDocumentId
			);
			insert cwd;


			insert new Notification_template__c (
				Subject__c = 'Some subject',
				Message__c = 'Some message',
				Type__c = 'Information',
				Notification_color__c = '#FF5E4D',
				Admins_Users__c = 'User',
				Expire_in_days__c = 3,
				Identifier__c = 'New_Doc_Version_Available',
				language__c='English'
			);			
		}
	}

	@isTest static void testGetDocuments() {
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		List<ContentVersion> testContent = [SELECT Id, Title, Document_Category__c, Country_of_publication__c FROM ContentVersion WHERE Title = 'ContentVersion Test Portal Documents'];
		List<ContentVersion> testContent2 = [SELECT Id, Title, Document_Category__c, Country_of_publication__c FROM ContentVersion WHERE Title = 'ContentVersion Test2 Portal Documents'];
		List<IATA_ISO_Country__c> isoCountry = [SELECT Name, Region__c FROM IATA_ISO_Country__c WHERE Name = 'Some Country'];

		Test.startTest();
			System.runAs(testUser) {
				CSP_Utils.PagedResult docsWithoutFilter = PortalDocumentsController.getSearchDocuments(testContent[0].Title, testContent[0].Document_Category__c, '', testContent[0].Country_of_publication__c, 0, testContent[0].Id);

				List<ContentVersion> contents = PortalDocumentsController.sortContentVersions(testContent, isoCountry[0].Name, isoCountry[0].Region__c);
				System.assertEquals(1, contents.size());

				List<ContentVersion> contents2 = PortalDocumentsController.sortContentVersions(testContent2, isoCountry[0].Name, isoCountry[0].Region__c);
				System.assertEquals(1, contents2.size());
			}
		Test.stopTest();
	}

	@IsTest static void testPortalGlobalSearch() {

		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(testUser) {
			CSP_Utils.PagedResult test = new CSP_Utils.PagedResult();

			PortalSearchFilterWrapper.documentsComponent documentsCmp = new PortalSearchFilterWrapper.documentsComponent();
			documentsCmp.show = true;
			PortalSearchFilterWrapper filtersWrapper = new PortalSearchFilterWrapper();
			filtersWrapper.searchText = 'Test';
			filtersWrapper.documentsComponent = documentsCmp;

			test = PortalGlobalSearchCtrl.portalGlobalSearch(JSON.serialize(filtersWrapper), 'Documents');
		}
		Test.stopTest();
	}

	@IsTest static void testDocumentswithBookmarkInfo() {
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		List<ContentVersion> testContent = [SELECT Id, Title, Document_Category__c, Country_of_publication__c FROM ContentVersion WHERE Title = 'ContentVersion Test Portal Documents'];
		
		Test.startTest();
		System.runAs(testUser) {
				CSP_Utils.PagedResult resultWrapper = PortalDocumentsController.getSearchDocumentsWithBookmarks(testContent[0].Title, testContent[0].Document_Category__c, '', testContent[0].Country_of_publication__c, 0, testContent[0].Id);
				 list<PortalDocumentsController.docWrapper> resultList =  (list<PortalDocumentsController.docWrapper>)JSON.deSerialize(resultWrapper.recordsString,list<PortalDocumentsController.docWrapper>.class);
				
				System.assertEquals(1, resultList.size());
				System.assertEquals(false, resultList[0].isBookmarked);


				//Bookmark document
				PortalDocumentsController.toggleBookmarkDocument(((contentVersion)resultList[0].record).contentDocumentId);


				resultWrapper = PortalDocumentsController.getSearchDocumentsWithBookmarks(testContent[0].Title, testContent[0].Document_Category__c, '', testContent[0].Country_of_publication__c, 0, testContent[0].Id);
				resultList =  (list<PortalDocumentsController.docWrapper>)JSON.deSerialize(resultWrapper.recordsString,list<PortalDocumentsController.docWrapper>.class);
					
				System.assertEquals(1, resultList.size());
				System.assertEquals(true, resultList[0].isBookmarked);
			
		}
		Test.stopTest();
	}

	@IsTest static void testGetBookmarksList() {
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		List<ContentVersion> testContent = [SELECT contentDocumentId,title FROM ContentVersion WHERE Title = 'ContentVersion Test Portal Documents'];
		
		Test.startTest();
		System.runAs(testUser) {
				//Bookmark document
				PortalDocumentsController.toggleBookmarkDocument(testContent[0].contentDocumentId);
				
				CSP_Utils.PagedResult resultwrapper= PortalDocumentsController.getBookmarkedDocuments('ContentVersion',1);
				list<contentVersion> resultList =  (list<contentVersion>)JSON.deSerialize(resultwrapper.recordsString,list<contentVersion>.class);
				
				System.assertEquals(1, resultList.size());
				System.assertEquals(testContent[0].title, resultList[0].title);

				//remove bookmark from document
				PortalDocumentsController.toggleBookmarkDocument(testContent[0].contentDocumentId);
				
				resultwrapper= PortalDocumentsController.getBookmarkedDocuments('ContentVersion',1);
				resultList =  (list<contentVersion>)JSON.deSerialize(resultwrapper.recordsString,list<contentVersion>.class);
				
				System.assertEquals(0, resultList.size());
				
				try{

					PortalDocumentsController.toggleBookmarkDocument(null);
				}catch(Exception e){
					System.assertEquals(e.getMessage(),Label.ISSP_ANG_GenericError);
				}
				
			}
		Test.stopTest();
	}


	@IsTest
	static void testNotifyUsersOfNewVersionInsert(){
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		List<ContentVersion> testContent = [SELECT contentDocumentId,title FROM ContentVersion WHERE Title = 'ContentVersion Test Portal Documents'];
		
		Test.startTest();
		System.runAs(testUser) {
			
			//Bookmark document
			PortalDocumentsController.toggleBookmarkDocument(testContent[0].contentDocumentId);	
		
		}

		ContentVersion cvNew = new ContentVersion();		
			cvNew.Title = 'ContentVersion Test3 Portal Documents';			
			cvNew.PathOnClient ='test';
			cvNew.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body2');
			cvNew.sent_Date__c=System.Now()+(2/24);
			cvNew.contentDocumentId=testContent[0].contentDocumentId;

		insert cvNew;

		Test.stopTest();

		system.assertEquals(1,[Select count() from notification__c]);

	}


	@IsTest
	static void testNotifyUsersOfNewVersionUpdate(){
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		List<ContentVersion> testContent = [SELECT contentDocumentId,title FROM ContentVersion WHERE Title = 'ContentVersion Test Portal Documents' and isLatest=true];
		
		Test.startTest();
			System.runAs(testUser) {				
				//Bookmark document
				PortalDocumentsController.toggleBookmarkDocument(testContent[0].contentDocumentId);	
			
			}
			contentVersion cv=testContent[0];
			cv.sent_date__c=system.NOW()+(2/24);//adds 2h to datetime

			update cv;
		Test.stopTest();

		system.assertEquals(1,[Select count() from notification__c]);

	}

	@IsTest
	static void testTriggerNotificationManually(){
		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		List<ContentVersion> testContent = [SELECT contentDocumentId,title FROM ContentVersion WHERE Title = 'ContentVersion Test Portal Documents' and isLatest=true];
		
		Test.startTest();
			System.runAs(testUser) {				
				//Bookmark document
				PortalDocumentsController.toggleBookmarkDocument(testContent[0].contentDocumentId);			
			}
			
			//Validation test
			CSP_Utils.triggerUserNotification(null);
			
			CSP_Utils.triggerUserNotification(testContent[0].id);
		Test.stopTest();

		system.assertEquals(1,[Select count() from notification__c]);

	}
}