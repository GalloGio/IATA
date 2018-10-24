@isTest 
private class ISSP_EditPortalServiceAccessExt_Test {


	@testSetup static void setup() {			
		insert new ISSP_TD_Currencies__c(Name = 'EUR', Currency_Label__c = 'Euro');

		Account account = IECTestUtil.createSampleAccount();
    	insert account;
    	Contact c = IECTestUtil.createSampleContact(account);
    	insert c;
		
		User testUser = IECTestUtil.createSampleUser(c);
		testUser.TD_Team__c = true;
/*
		User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = [Select Id from Profile where name = 'System Administrator'].ID,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01',
            IsActive = true, TD_Team__c = true
        );
*/

        insert testUser;

	}


	@isTest static void testSaveUpdate() {

		Pagereference pageRef;
		Id portalAppID;
		ISSP_EditPortalServiceAccessExt controller;

		User usr = [SELECT ID FROM User WHERE Alias= 'User'];

		System.runAs(usr){

			Account acc2 = new Account(Name='Acc2', recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY);
			insert acc2;

			Contact c = new Contact(AccountID = acc2.ID, FirstName = 'test', LastName = 'test', User_Portal_Status__c = 'Approved Admin', 
				Email = 'testiata@yopmail.com');
			insert c;

			Portal_Applications__c par = new Portal_Applications__c(Name = 'Treasury Dashboard');
			insert par;

			Portal_Application_Right__c portalAppRight = new Portal_Application_Right__c(Portal_Application__c = par.Id, Right__c = 'Access Granted', Contact__c = c.Id);
			insert portalAppRight;

			Portal_Application_Right__c portalARight = [SELECT Application_Name__c, Contact__c, Portal_Application__c 
														FROM Portal_Application_Right__c Where ID =:portalAppRight.ID];

			Test.startTest();

			controller = new ISSP_EditPortalServiceAccessExt(new ApexPages.StandardController(portalARight));
			pageRef = controller.saveUpdate();
			portalAppID = portalAppRight.id;

			Test.stopTest();
		}

		System.assert(pageRef.getUrl().contains(portalAppID));
		//Check inactiveUser flag
		System.assert(controller.noUser);

	}


	@isTest static void testSaveWithPendingApproval() {
		Pagereference pageRef;
		Id portalAppID;
		ISSP_EditPortalServiceAccessExt controller;

		User usr = [SELECT ID FROM User WHERE Alias= 'User'];
		usr.TD_Team__c = true;

		System.runAs(usr){

			Account acc2 = new Account(Name='Acc2', recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY);
			insert acc2;

			Contact c = new Contact(AccountID = acc2.ID, FirstName = 'test', LastName = 'test', User_Portal_Status__c = 'Pending Approval',
			 						Email = 'testiata@yopmail.com', Community__c = 'Community test');
			insert c;

			Portal_Applications__c par = new Portal_Applications__c(Name = 'Treasury Dashboard');
			insert par;

			Portal_Application_Right__c portalAppRight = new Portal_Application_Right__c(Portal_Application__c = par.Id, Right__c = 'Access Granted', Contact__c = c.Id);
			insert portalAppRight;

			Portal_Application_Right__c portalARight = [SELECT Application_Name__c, Contact__c, Portal_Application__c 
														FROM Portal_Application_Right__c Where ID =:portalAppRight.ID];

			Test.startTest();

			controller = new ISSP_EditPortalServiceAccessExt(new ApexPages.StandardController(portalARight));
			pageRef = controller.save();
			portalAppID = portalAppRight.id;

			Test.stopTest();
		}

		System.assert(pageRef.getUrl().contains(portalAppID));
		//Check pendingApproval flag
		System.assert(controller.pendingApproval);
	}

	@isTest static void testSaveWithInactiveUser() {
		Pagereference pageRef;
		Id portalAppID;
		ISSP_EditPortalServiceAccessExt controller;

		User usr = [SELECT ID FROM User WHERE Alias= 'User'];
		usr.TD_Team__c = true;

		System.runAs(usr){

			Account acc2 = new Account(Name='Acc2', recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY);
			insert acc2;

			Contact c = new Contact(AccountID = acc2.ID, FirstName = 'test', LastName = 'test', User_Portal_Status__c = 'Inactive',
			 						Email = 'testiata@yopmail.com', Community__c = 'Community test');
			insert c;

			Portal_Applications__c par = new Portal_Applications__c(Name = 'Treasury Dashboard');
			insert par;

			Portal_Application_Right__c portalAppRight = new Portal_Application_Right__c(Portal_Application__c = par.Id, Right__c = 'Access Granted', Contact__c = c.Id);
			insert portalAppRight;

			Portal_Application_Right__c portalARight = [SELECT Application_Name__c, Contact__c, Portal_Application__c 
														FROM Portal_Application_Right__c Where ID =:portalAppRight.ID];

			Test.startTest();

			controller = new ISSP_EditPortalServiceAccessExt(new ApexPages.StandardController(portalARight));
			pageRef = controller.save();
			portalAppID = portalAppRight.id;

			Test.stopTest();
		}
		
		System.assert(pageRef.getUrl().contains(portalAppID));
		//Check inactiveUser flag
		System.assert(controller.inactiveUser);
	}

/*
	@isTest static void testSaveWithNoUser() {
		Pagereference pageRef;
		Id portalAppID;
		ISSP_EditPortalServiceAccessExt controller;

		User usr = [SELECT ID FROM User WHERE Alias= 'User'];
		usr.TD_Team__c = true;

		System.runAs(usr){

			ISSP_CS__c isspCs = new ISSP_CS__c(Name = 'ISS_Portal_Agency_User',Value__c = '00ew0000001QoBp');
			insert isspCs;

			Account acc2 = new Account(Name='Acc2', recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY);
			insert acc2;

			Contact c = new Contact(AccountID = acc2.ID, FirstName = 'test', LastName = 'test', User_Portal_Status__c =  'Approved Admin',
			 						Email = 'testiata@yopmail.com', Community__c = 'Community test');
			insert c;

			Portal_Applications__c par = new Portal_Applications__c(Name = 'Treasury Dashboard');
			insert par;

			Portal_Application_Right__c portalAppRight = new Portal_Application_Right__c(Portal_Application__c = par.Id, Right__c = 'Access Granted', Contact__c = c.Id);
			insert portalAppRight;

			Portal_Application_Right__c portalARight = [SELECT Application_Name__c, Contact__c, Portal_Application__c 
														FROM Portal_Application_Right__c Where ID =:portalAppRight.ID];

			Test.startTest();

			controller = new ISSP_EditPortalServiceAccessExt(new ApexPages.StandardController(portalARight));
			pageRef = controller.save();
			portalAppID = portalAppRight.id;

			Test.stopTest();
		}
		
		System.assert(pageRef.getUrl().contains(portalAppID));
		//Check NoUser flag
		System.assert(controller.NoUser);
	}
	*/
	
}