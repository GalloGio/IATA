@isTest
private class ISSP_TC_SIS_Accept_Test {

	static testMethod void myUnitTest_1() {

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Sector__c = 'Cargo Agent';
		insert acc;
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= acc.Id;
		insert con;
		User thisUser = ISSP_ObjectFactory.createPortalUser(con);

		ISSP_CS__c profileCS = new ISSP_CS__c();
		profileCS.Name = 'SIS_URL';
		profileCS.Value__c = '/SIS';
		insert profileCS;

		ContactShare newShare = new ContactShare();
		newShare.ContactAccessLevel = 'Edit';
		newShare.ContactId = con.Id;
		newShare.UserOrGroupId = thisUser.Id;
		insert newShare;

		User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		myUser.SIS_Team__c = true;
		update myUser;
		system.runAs(myUser){
		PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
		Portal_Applications__c app = new Portal_Applications__c(Name = 'SIS');
		insert app;
		Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
		insert appRight;
		}
		Test.StartTest();
		system.runAs(thisUser){
			ISSP_TC_SIS_Accept cttr = new ISSP_TC_SIS_Accept();
			PageReference pg = Page.ISSP_TC_SIS_Accept;
			Test.setCurrentPage(pg);
			cttr.pageLoad();

		}
		Test.StopTest();
	}

	static testMethod void myUnitTest_2() {

		Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= acc.Id;
		insert con;
		User thisUser = ISSP_ObjectFactory.createPortalUser(con);

		ISSP_CS__c profileCS = new ISSP_CS__c();
		profileCS.Name = 'SIS_URL';
		profileCS.Value__c = '/SIS';
		insert profileCS;

		ISSP_TC_SIS_Accept cttr = new ISSP_TC_SIS_Accept();

		system.runAs(thisUser){
			PageReference pg = Page.ISSP_TC_SIS_Accept;
			Test.setCurrentPage(pg);
			system.assertEquals('/ISSP_Homepage',cttr.pageLoad().getUrl());
		}
	}

	static testMethod void myUnitTest_3() {

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.ISS_SIS_TC_Accepted__c = false;
		insert acc;
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= acc.Id;
		insert con;
		User thisUser = ISSP_ObjectFactory.createPortalUser(con);

		ISSP_CS__c profileCS = new ISSP_CS__c();
		profileCS.Name = 'SIS_URL';
		profileCS.Value__c = '/apex/ISSP_Homepage';
		insert profileCS;

		ISSP_TC_SIS_Accept cttr = new ISSP_TC_SIS_Accept();

		Test.StartTest();
		system.runAs(thisUser){
			PageReference pg = Page.ISSP_TC_SIS_Accept;
			Test.setCurrentPage(pg);
			cttr.accept = false;
			cttr.doContinue();
			cttr.accept = true;
			cttr.doContinue();
		}
		Test.StopTest();
	}

	static testMethod void myUnitTest_4() {

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.ISS_SIS_TC_Accepted__c = true;
		insert acc;
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= acc.Id;
		insert con;
		User thisUser = ISSP_ObjectFactory.createPortalUser(con);

		ContactShare newShare = new ContactShare();
		newShare.ContactAccessLevel = 'Edit';
		newShare.ContactId = con.Id;
		newShare.UserOrGroupId = thisUser.Id;
		insert newShare;

		ISSP_CS__c profileCS = new ISSP_CS__c();
		profileCS.Name = 'SIS_URL';
		profileCS.Value__c = '/apex/ISSP_Homepage';
		insert profileCS;

		User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		myUser.SIS_Team__c = true;
		update myUser;
		system.runAs(myUser){
		PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
		Portal_Applications__c app = new Portal_Applications__c(Name = 'SIS');
		insert app;
		Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
		insert appRight;
		}

		ISSP_TC_SIS_Accept cttr = new ISSP_TC_SIS_Accept();

		Test.StartTest();
		system.runAs(thisUser){
			PageReference pg = Page.ISSP_TC_SIS_Accept;
			Test.setCurrentPage(pg);
			cttr.pageLoad();
			cttr.accept = false;
			cttr.doContinue();
			cttr.accept = true;
			cttr.doContinue();
		}
		Test.StopTest();
	}
}
