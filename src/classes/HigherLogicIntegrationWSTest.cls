@isTest
private class HigherLogicIntegrationWSTest {

	@testSetup static void setup() {
		
		Higher_Logic_Settings__c hls = new Higher_Logic_Settings__c();
		
		hls.Endpoint__c = 'https://test.higherlogic.com';
		hls.Api_Key__c = 'asdfghjklçqwertyuiop';
		hls.Tenant_Code__c = 'HLTENANT';
		
		insert hls;
		
		List<Account> acctLst = new List<Account>();
		
		for(Integer i=0; i<2; i++){
			Account acc = ISSP_ObjectFactory.createNewAccount();
			acc.Field_Head_Office__c = 'Headquarter';  
			acctLst.add(acc);
		}
		
		insert acctLst;
		
		List<Contact> contactLst = new List<Contact>();
		
		for(Integer i=0; i<2; i++){
			Contact contact = ISSP_ObjectFactory.createNewContact();
			contact.Email = 'hltest_' + i + '@test.com';
			contact.AccountId = acctLst.get(i).Id;
			contactLst.add(contact);	
		}

		insert contactLst;
		
		List<User> userLst = new List<User>();
		
		for(Integer i=0; i<2; i++){
			
			Contact contact = contactLst.get(i);
			 
			User newUser = new User(
				Alias = 'Usertst' + i, 
				Email = contact.Email,
				EmailEncodingKey = 'UTF-8', 
				FirstName = contact.FirstName, 
				LastName = contact.LastName, 
				LanguageLocaleKey = 'en_US', 
				LocaleSidKey = 'en_US', 
				ContactId = contact.Id,
				TimezoneSidKey = 'Asia/Dubai',
				Username = contact.Email + i,
				PortalRole = 'Manager',
				CommunityNickname = contact.Email.substring(0, contact.Email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
				ProfileId = ISSP_Constant.TEST_User_ProfileID,
				IsActive = true
			);
			
			userLst.add(newUser);
			
		}
		
		insert userLst;

	}

	static testMethod void pushMembersTest() {

		List<Contact> contactLst = new List<Contact>(
			[SELECT Id FROM Contact]
		);
		
		Portal_Applications__c app = new Portal_Applications__c(Name = 'Standards Setting Workspace'); 
		insert app;
		
		Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
		Test.startTest();
		
		Portal_Application_Right__c par = new Portal_Application_Right__c();
			
		par.Contact__c = contactLst.get(0).Id;
		par.Portal_Application__c = app.Id;
		par.Right__c = 'Access Granted';
		
		insert par;
			
		Test.stopTest();
		
		//Increasing code coverage by creating a new MemberDetails fake element
		
		HigherLogicIntegrationWS.MemberDetails md = new HigherLogicIntegrationWS.MemberDetails();
		
		md.age = 50;
		md.birthday = System.today().addYears(-50);
		md.MemberSince = System.today();
		md.MemberExpiresOn = System.today().addYears(1);
		md.Designation = 'Fake';
		md.PrefixCode = 'Mr';
		md.MiddleName = 'Middle';
		md.InformalName = 'Mr Fake';
		md.Gender = 'M';
		md.Ethnicity = '';
		md.SuffixCode = 'K';
		md.PrimaryContactLegacyContactKey = 'MID-LC-1234';
		md.ExcludeFromDirectory = false;
		md.IsMember = true;
		md.MemberID = 'MID-1234';
		md.Bio = 'I am Mr. Fake';
		md.ProfileImageURL = 'https://fake.pic';
		md.Phone4 = '555555555';
		md.Phone4Type = 'WORK';
		md.Address2 = 'Street 2';
		md.Address3 = 'Street 3';
		md.YouTubeURL = 'https://youtube.com';
		md.FacebookURL = 'https://facebook.com';
		md.TwitterURL = 'https://twitter.com';
		md.GooglePlusURL = 'https://googleplus.com';
		md.LinkedInURL = 'https://linkedin.com';
		md.BloggerURL = 'https://blogger.com';
		md.WordPressURL = 'https://wordpress.com';
		md.OtherBlogURL = 'https://otherblog.com';
				
	}
	
	static testMethod void pushMembersFailTest(){
		
		delete [select id from Higher_Logic_Settings__c];
		
		List<Contact> contactLst = new List<Contact>(
			[SELECT Id FROM Contact]
		);
		
		Portal_Applications__c app = new Portal_Applications__c(Name = 'Standards Setting Workspace'); 
		insert app;
		
		Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
		Test.startTest();
		
		Portal_Application_Right__c par = new Portal_Application_Right__c();
			
		par.Contact__c = contactLst.get(0).Id;
		par.Portal_Application__c = app.Id;
		par.Right__c = 'Access Granted';
		
		insert par;
			
		Test.stopTest();
		
	}
	
}