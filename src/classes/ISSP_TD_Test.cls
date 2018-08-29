@isTest
private class ISSP_TD_Test {

    static testMethod void myUnitTest() {
    	
    	String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
    	Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        contact.User_Portal_Status__c = 'Pending Approval';
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
    	
    	ISSP_TD_Reports__c tdCS1 = new ISSP_TD_Reports__c();
    	tdCS1.Name = 'Test1';
    	tdCS1.Tab__c = 1;
    	tdCS1.Active__c = true;
    	tdCS1.Order__c = 1;
    	insert tdCS1;
    	ISSP_TD_Reports__c tdCS2 = new ISSP_TD_Reports__c();
    	tdCS2.Name = 'Test2';
    	tdCS2.Tab__c = 2;
    	tdCS2.Active__c = true;
    	tdCS2.Order__c = 2;
    	insert tdCS2;
    	ISSP_TD_Reports__c tdCS3 = new ISSP_TD_Reports__c();
    	tdCS3.Name = 'Test3';
    	tdCS3.Tab__c = 2;
    	tdCS3.Active__c = true;
    	tdCS3.Order__c = 3;
    	insert tdCS3;
    	PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
    	Portal_Applications__c app = new Portal_Applications__c(Name = 'Treasury Dashboard - Premium');
    	app.TD_Included_Dashboards__c = 'ISSP_TD_1;ISSP_TD_2;ISSP_TD_3;ISSP_TD_4;ISSP_TD_5';
    	app.TD_Included_Reports__c = 'Test1;Test2';
        insert app;
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
        insert appRight;
	    	
	    system.runAs(newUser){
		    ISSP_TD ctrl = new ISSP_TD();
		    ctrl.pageLoad();
		    ISSP_TD.toLogout_TD();

	        ctrl = new ISSP_TD();
	        ctrl.pageLoad();
	        ISSP_TD.toLogout_TD();
    	}

    }
    
    static testMethod void processPluginTest() {
    	ISSP_CS__c newCS = new ISSP_CS__c();
    	newCS.Name = 'TwoFA_Emails';
    	newCS.Value__c = 'test@test.com';
    	insert newCS;
    	String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
    	Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        contact.User_Portal_Status__c = 'Pending Approval';
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
    	
    	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	system.runAs(thisUser){
    		String userid = newUser.Id;
	    	Map<String,String> QR = Auth.SessionManagement.getQrCode();
	    	String secret = QR.get('secret');
	    	TwoFactorInfo TwoFactor = new TwoFactorInfo(UserId=userid, Type='TOTP', SharedKey=secret);
	        insert(TwoFactor);
	    	
	    	ISSP_2FA_Reset ctrl = new ISSP_2FA_Reset();
	        Map<String,Object> inputParams = new Map<String,Object>();
	        Map<String,Object> outputParams = new Map<String,Object>();
	         
	        //inputParams.put(userid,null);
	        inputParams.put('userId',userid);
	        Process.PluginRequest request = new Process.PluginRequest(inputParams);
	        Process.PluginResult result;
	        result = ctrl.invoke(request);
    	}
    }
    
    static testMethod void processPluginDescribeTest() {

        ISSP_2FA_Reset ctrl = new ISSP_2FA_Reset();
        Process.PluginDescribeResult result = ctrl.describe();
       
        System.AssertEquals(result.OutputParameters.size(), 0);
    }
    
    static testMethod void myUnitTest_2() {
    	User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	thisUser.TD_Team__c = true;
    	update thisUser;
    	thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	system.runAs(thisUser){
	    	String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
	    	Account acc = ISSP_ObjectFactory.createNewAccount();
			insert acc;
			Contact contact = ISSP_ObjectFactory.createNewContact();
	        contact.AccountId = acc.Id;
	        contact.User_Portal_Status__c = 'Pending Approval';
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
	    	
		    ISSP_TD ctrl = new ISSP_TD();
		    ctrl.pageLoad();
		    ISSP_TD.toLogout_TD();
	    	
	    	ISSP_Record_Type_Mgmt__c rtMgmt = new ISSP_Record_Type_Mgmt__c (Name = 'Treasury Dashboard', Record_Type_Name__c = 'FDS_ICCS_Email_to_Case');
	    	insert rtMgmt;
	    	Portal_Applications__c app = new Portal_Applications__c(Name = 'Treasury Dashboard'); 
	        insert app;
	        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = contact.Id, Portal_Application__c = app.Id, Right__c = 'Access Requested');
	        insert appRight;
	        appRight.Right__c = 'Access Denied';
	        update appRight;
	        appRight.Right__c = 'Access Granted';
	        update appRight;
    	}
    }
}