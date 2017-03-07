@isTest
private class ISSP_UserTriggerHandler_Test {

    static testMethod void myUnitTest() {
        //ISSP_ObjectFactory.fiilIncludedFields();
    	String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC' LIMIT 1].Id;
    	//Account acc = (Account)ISSP_ObjectFactory.createSObject('Account',false,4);
    	Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		//Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
		Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.Email = 'test2@test.test';
        contact.AccountId = acc.Id;
        insert contact;

        User newUser = new User(alias = 'dsfsdfds', 
	                            email = contact.email, 
	                            emailencodingkey = 'UTF-8', 
	                            firstname = contact.firstName, 
	                            lastname = contact.lastname, 
	                            languagelocalekey = 'en_US', 
	                            localesidkey = 'en_US', 
	                            contactId = contact.Id,
	                            timezonesidkey = 'Asia/Dubai',
	                            username = contact.email+'dfgdf',
	                            PortalRole = 'Manager',
	                            CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
	                            ProfileId = profileId,
	                            IsActive = true);
    	insert newUser;

    	Map<Id, String> conEmailMap = new Map<Id, String>();
    	conEmailMap.put(contact.Id, contact.Email);
    	Map<Id, String> conFirstNameMap = new Map<Id, String>();
    	conFirstNameMap.put(contact.Id, contact.Firstname);
    	Map<Id, String> conLastNameMap = new Map<Id, String>();
    	conLastNameMap.put(contact.Id, contact.Lastname);
    	Set<Id> conEmailIdSet = new Set<Id>();
    	conEmailIdSet.add(contact.Id);

    	PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
    	Portal_Applications__c app = new Portal_Applications__c(Name = 'SIS'); 
        insert app;
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
        insert appRight;
        PortalServiceAccessTriggerHandler.avoidAppTrigger = false;

        ISSP_CS__c cs = new ISSP_CS__c();
        cs.Name='SIS_WebService_ON';
     	insert cs;

    	System.runAs (newUser){
    		Test.startTest();
	    	newUser.email = 'test1234@test.test';
	    	update newUser;	    	

	    	ISSP_UserTriggerHandler.changeEmailFromContact(conEmailMap, conFirstNameMap, conLastNameMap, conEmailIdSet);
	    	ISSP_UserTriggerHandler.updateSIS_permissionSet(conEmailIdSet, conEmailIdSet);

	    	PermissionSet ps = new PermissionSet();
		    ps.Name = 'Test';
		    ps.Label = 'Test';
		    insert ps;

	    	PermissionSetAssignment psa = new PermissionSetAssignment();
		    psa.AssigneeId = UserInfo.getUserId();
		    psa.PermissionSetId = ps.Id;
		    insert psa;
	    	
	    	Set<Id> emptySet = new Set<Id>();
	    	ISSP_UserTriggerHandler.updateUserPermissionSet('Test', conEmailIdSet, conEmailIdSet);
	    	ISSP_UserTriggerHandler.deleteTwoFactor(conEmailIdSet);
	    	ISSP_UserTriggerHandler.updateFederation(conLastNameMap);
	    	ISSP_UserTriggerHandler.updateUserPermissionSet('Test', conEmailIdSet, emptySet);	    	

	    	Test.stopTest();
    	}

    	ISSP_NonTD_Report__c report = new ISSP_NonTD_Report__c();
        report.Posted_Date__c = System.Today();
        report.Account__c = acc.Id;
        insert report;

    	/*ISSP_NonTD_Report__Share newReportShare = new ISSP_NonTD_Report__Share();
		newReportShare.AccessLevel = 'Read';
		newReportShare.ParentId = report.Id;
		newReportShare.UserOrGroupId = newUser.Id;
		insert newReportShare;*/

		ISSP_UserTriggerHandler.addNonTdReportSharing(conEmailIdSet);
    	ISSP_UserTriggerHandler.removeNonTdReportSharing(conEmailIdSet);

    	String thisUsername = [SELECT Id, Email, Username FROM User WHERE Id = :newUser.Id].Username;
    	system.assertEquals(thisUsername, 'test1234.test.test@partner.iata.org');
    }
}