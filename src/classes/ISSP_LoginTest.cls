@isTest
private class ISSP_LoginTest {

	 public static testMethod void testISSP_Login() {
	 	ISSP_Login controller = new ISSP_Login();
        controller.username = 'mcgrawa@iata.org';
        controller.password = 'welcome';
        controller.login();
        controller.forwardToAuthPage();
        ApexPages.currentPage().getHeaders().put('USER-AGENT','Chrome');
        ApexPages.currentPage().getParameters().put('lang','es');
        String isIE = controller.isIe;
        String lang = controller.lang;
		String communityName = controller.communityName;
        ApexPages.currentPage().getHeaders().put('USER-AGENT','MSIE');
        isIE = controller.isIe;
	}

	public static testMethod void testLanguage() {
	 	ISSP_Login controller = new ISSP_Login();
		// 	ApexPages.currentPage().getParameters().put('Accept-Language','es');
		String lang = controller.lang;
		System.assertEquals('en_US', lang, 'The language should be en_US');
	 	ApexPages.currentPage().getHeaders().put('Accept-Language','es');
        lang = controller.lang;
		System.assertEquals('es', lang, 'The language should be es');
		System.debug(lang);
	}

	public static testMethod void testISSP_Login_3() {

		String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
    	Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        contact.User_Portal_Status__c = 'Pending Approval';
        contact.Portal_User_Frozen__c = true;
        insert contact;
        User newUser = new User(alias = 'dsfsdfds',
	                            email = 'issp_login_test_class@testclass.testclass',
	                            emailencodingkey = 'UTF-8',
	                            firstname = contact.firstName,
	                            lastname = contact.lastname,
	                            languagelocalekey = 'en_US',
	                            localesidkey = 'en_US',
	                            contactId = contact.Id,
	                            timezonesidkey = 'Asia/Dubai',
	                            username = 'issp_login_test_class.testclass.testclass@partner.iata.org',
	                            PortalRole = 'Manager',
	                            CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
	                            ProfileId = profileId,
	                            IsActive = false);
    	insert newUser;

    	Apexpages.currentPage().getParameters().put('retURL', '/test');
    	ISSP_Login ctrl = new ISSP_Login();
    	ctrl.username = 'test';
    	ctrl.login();
        ctrl.username = 'issp_login_test_class@testclass.testclass';
        ctrl.login();
        ISSP_Login.reactivateContact(contact.Id);
	}

	public static testMethod void testISSP_Login_4() {

		String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
    	Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        contact.User_Portal_Status__c = 'Pending Approval';
        contact.Portal_User_Frozen__c = true;
        insert contact;
        User newUser = new User(alias = 'dsfsdfds',
	                            email = 'issp_login_test_class@testclass.testclass',
	                            emailencodingkey = 'UTF-8',
	                            firstname = contact.firstName,
	                            lastname = contact.lastname,
	                            languagelocalekey = 'en_US',
	                            localesidkey = 'en_US',
	                            contactId = contact.Id,
	                            timezonesidkey = 'Asia/Dubai',
	                            username = 'issp_login_test_class.testclass.testclass@partner.iata.org',
	                            PortalRole = 'Manager',
	                            CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
	                            ProfileId = profileId,
	                            Portal_User_Frozen_Checkbox__c = true,
	                            IsActive = true);
    	insert newUser;
		AccountTeamMember am = new AccountTeamMember();
		am.AccountId = acc.Id;
		am.UserId = newUser.Id;
		am.TeamMemberRole = 'Portal Administrator';

		insert am;
        
        system.runAs(newUser){
	    	Apexpages.currentPage().getParameters().put('retURL', '/test');
	    	ISSP_Login ctrl = new ISSP_Login();
	    	ctrl.username = 'issp_login_test_class.testclass.testclass@partner.iata.org';
            ctrl.login();
    	}

	}
	
	public static testMethod void testISSP_Login_5() {

		ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP','10.10.10.10');
		ISSP_IP_Locator__c newIP = new ISSP_IP_Locator__c();
		newIP.Start1__c = 10;
		newIP.Start2__c = 10;
		newIP.Start3__c = 10;
		newIP.Start4__c = 0;
		newIP.End1__c = 10;
		newIP.End2__c = 10;
		newIP.End3__c = 10;
		newIP.End4__c = 256;
		newIP.Country_Code__c = 'TT';
		insert newIP;

		ISSP_CS__c cs = new ISSP_CS__c();
		cs.Name = 'ipinfo_token';
		cs.Value__c = 'test';
		insert cs;

		ISSP_CS__c cs1 = new ISSP_CS__c();
		cs1.Name = '1ID redirect';
		cs1.Value__c = 'ON';
		insert cs1;

		System.currentPageReference().getParameters().put('startURL', 'test');

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        ISSP_Login ctrl = new ISSP_Login();
        ctrl.findLocationCaller();

        ISO_Country.Sanctioned_Country__c = true;
        update ISO_Country;

	}

}