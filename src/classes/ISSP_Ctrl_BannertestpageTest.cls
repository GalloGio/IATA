@isTest
private class ISSP_Ctrl_BannertestpageTest {
	@testSetup static void methodName() {
		IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(ISO_Code__c='12',Name='Italy',Region__c='Europe');
        insert isoCountry;

		Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
		child.IATA_ISO_Country__c = isoCountry.Id ;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.Top_Parent__c = parent.Id;
		child.Sector__c = 'Airline';
		child.BillingCountry = 'Italy';
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
 
        con.AccountId= child.Id;
		con.Email = 'Test@test11.com';
		con.User_Portal_Status__c = 'Approved Admin';
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
	}

	static testMethod void testISSP_Ctrl_BannertestpageTest()
	{
		List<User> newUser_List = new List<User>([select Id ,Name From User where Email = 'Test@test11.com' ]);
		User newUser = newUser_List[0];

		ISSP_Banner__c Ban1 = new ISSP_Banner__c();
		Ban1.Status__c = 'Active';
		Ban1.Publication_start_date__c = System.today()-1;
		Ban1.Publication_end_date__c = System.today()+1;
		Ban1.User_portal_Status__c = 'Approved Admin';
 		Ban1.Sector__c = 'Airline';
		Ban1.Country__c = 'Italy';
		Ban1.Zone_1_text__c = 'Zone1';
		Ban1.Zone_2_text__c = 'Zone2';
		Ban1.Zone_3_text__c = 'Zone3';
		insert Ban1;

		ISSP_Banner__c Ban2 = new ISSP_Banner__c();
		Ban2.Status__c = 'Active';
		Ban2.Publication_start_date__c = System.today()-1;
		Ban2.Publication_end_date__c = System.today()+1;
		Ban2.User_portal_Status__c = 'Approved Admin';
		//Ban.Name = 'Ban-002';
		Ban2.Sector__c = 'Airline';
		Ban2.Country__c = 'Italy';
		Ban2.Zone_1_text__c = 'Zone1';
		Ban2.Zone_2_text__c = 'Zone2';
		Ban2.Zone_3_text__c = 'Zone3';

		insert Ban2 ;
		
        Test.startTest();
        System.runAs(newUser)
        {
			ISSP_Ctrl_Bannertestpage controller = new ISSP_Ctrl_Bannertestpage();
			controller.getDefaultBanner();

			List<String> lsLanguages = new List<String> {'es', 'ko', 'zh_CN', 'pt_BR', 'fr', 'ja', 'it', 'de', 'th', 'in', 'vi', 'ar'};
			for(String s: lsLanguages) {
				newUser.languagelocalekey = s;
				update newUser;
				controller.setBannerLanguage();
			}
		}
		Test.stopTest();
	}

}