@isTest
private class HigherLogicIntegrationTest {

	@testSetup static void setup() {
		
		List<Account> acctLst = new List<Account>();
		
		for(Integer i=0; i<10; i++){
			Account acc = ISSP_ObjectFactory.createNewAccount();
			acc.Field_Head_Office__c = 'Headquarter';  
			acctLst.add(acc);
		}
		
		insert acctLst;
		
		List<Contact> contactLst = new List<Contact>();
		
		for(Integer i=0; i<10; i++){
			Contact contact = ISSP_ObjectFactory.createNewContact();
			contact.Email = 'hltest_' + i + '@test.com';
			contact.AccountId = acctLst.get(i).Id;
			contactLst.add(contact);	
		}

		insert contactLst;
		
		List<User> userLst = new List<User>();
		
		for(Integer i=0; i<10; i++){
			
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
		
		contactLst.sort();
		
		List<Contact> contactSubList = new List<Contact>();
		
		for(Integer i = 0; i < 10; i++){
			
			Contact cont = contactLst[i];
			
			if(cont.Email.contains(String.valueOf(i))){
				contactSubList.add(cont);
			}
			
		}
	
		Portal_Applications__c app = new Portal_Applications__c(Name = 'Standards Setting Workspace'); 
		insert app;

		//Triggers the following exception:
		//Methods defined as TestMethod do not support Web service callouts
		createPortalApplicationRights(app.Id, contactSubList, 'Access Granted');
		
	}

	static testMethod void pushMembersTest() {

		List<Contact> contactLst = new List<Contact>(
			[SELECT Id, AccountId, Email FROM Contact]
		);
		
		contactLst.sort();
		
		List<Contact> contactSubList = new List<Contact>();
		
		for(Integer i = 5; i < 10; i++){
			
			Contact cont = contactLst[i];
			
			if(cont.Email.contains(String.valueOf(i))){
				contactSubList.add(cont);
			}
			
		}
		
		Portal_Applications__c app = [SELECT Id FROM Portal_Applications__c WHERE Name = 'Standards Setting Workspace'];
		
		Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
		Test.startTest();
		
		createPortalApplicationRights(app.Id, contactSubList, 'Access Granted');
		
		Test.stopTest();
		
		assertWebServiceLogs(2);	

		fillMembersDetails();
		
	}
	
	static testMethod void pushExistingMembersTest(){
		
		List<User> userLst = new List<User>(
			[SELECT 
				Id, 
				Name, 
				Street 
			 FROM 
				User 
			 WHERE 
			 	alias like 'Usertst%'
			]
		);
		
		for(User usr : userLst){
			usr.Street = 'New Street';
		}

		User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		
		system.runAs(usr){
			Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
			Test.startTest();
			update userLst;
			Test.stopTest();
		}
		
		assertWebServiceLogs(1);
		
	}
	
	static testMethod void pushCompanyMembersTest(){
		
		List<Account> accountLst = [SELECT Id, Name, BillingStreet FROM Account];
			
		for(Account acct : accountLst){
			acct.BillingStreet = 'New Street';
		}
		
		Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
		
		Test.startTest();
		
		update accountLst;		
		
		Test.stopTest();
		
		assertWebServiceLogs(1);
		
	}
	
	static testMethod void replaceMembersRelationshipTest(){

		List<Contact> contactLst = new List<Contact>(
			[SELECT Id, AccountId, Email FROM Contact]
		);
		
		Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
		
		Test.startTest();
		
		List<Account> accountLst = [SELECT Id FROM Account Order By Id];

		if(contactLst.size() > 0){
			
			Contact cont = contactLst[0];
			
			for(Account acc : accountLst){
				
				if(acc.Id != cont.AccountId){
					cont.AccountId = acc.Id;
					break;
				}
				
			}
			
			update cont;
		
		}
		
		Test.stopTest();

		assertWebServiceLogs(2);

	}
	
	static testMethod void pushPersonMembersTest(){
		
		List<Contact> contactLst = new List<Contact>(
			[SELECT Id, AccountId, Email FROM Contact]
		);
		
		List<Contact> contactUpdateLst = new List<Contact>();
		
		for(integer i=0; i<2; i++){
			Contact cont = contactLst.get(i);
			cont.Title = 'Mr.';
			contactUpdateLst.add(cont);
		}
		
		User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		
		// Avoid MIXED DML Exception
		system.runAs(usr){
			Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
			Test.startTest();
			update contactUpdateLst;
			Test.stopTest();
		}
		
		assertWebServiceLogs(1);
		
	}
	
	static testMethod void removeHigherLogicPermissionSetTest(){
		
		List<Contact> contactLst = new List<Contact>(
			[SELECT Id, AccountId, Email FROM Contact]
		);
		
		Test.startTest();
				
		Portal_Application_Right__c par = 
			[SELECT 
				Id 
			 FROM 
			 	Portal_Application_Right__c 
			 WHERE 
			 	 Right__c = 'Access Granted' 
			 AND Contact__c IN :contactLst 
			 LIMIT 1
			];
		
		par.Right__c = 'Access Denied';
		
		update par;
		
		Test.stopTest();
		
	}

	private static void createPortalApplicationRights(Id appId, List<Contact> contactLst, String access){
		
		List<Portal_Application_Right__c> parLst = new List<Portal_Application_Right__c>();
		
		Portal_Application_Right__c par1 = new Portal_Application_Right__c();
			
		par1.Contact__c = contactLst.get(0).Id;
		par1.Portal_Application__c = appId;
		par1.Right__c = access;

		Portal_Application_Right__c par2 = new Portal_Application_Right__c();
			
		par2.Contact__c = contactLst.get(1).Id;
		par2.Portal_Application__c = appId;
		par2.Right__c = access;
				
		parLst.add(par1);
		parLst.add(par2);
		
		insert parLst;
		
	}
	
	private static void assertWebServiceLogs(integer nbrOfLogs){
		
		List<ISSP_Web_Service_Log__c> logLst = new List<ISSP_Web_Service_Log__c>(
			[SELECT 
				Id, 
				Method__c,
				Error_Code__c, 
				Error_Message__c
			 FROM 
			 	ISSP_Web_Service_Log__c
			 ORDER BY
			 	CreatedDate DESC
			]
		);
		
		integer i=0;
		for(ISSP_Web_Service_Log__c log : logLst){
					
			if(i >= nbrOfLogs){
				return;				
			}
			
			system.assertEquals(log.Error_Code__c, '200');
			system.assert(log.Error_Message__c.contains('{"success":true'));
			
			i++;
					
		}
		
	}

	private static void fillMembersDetails(){
		
		//Increasing code coverage by creating a new MemberDetails fake element
		//since several elements aren't being used for now

		HigherLogicIntegrationWS.MemberDetails md = new HigherLogicIntegrationWS.MemberDetails();
		
		md.age = 50;
		md.birthday = System.today().addYears(-50);
		md.MemberSince = System.today();
		md.MemberExpiresOn = System.today().addYears(1);
		md.Designation = 'Member';
		md.PrefixCode = 'Mr';
		md.MiddleName = 'Middle';
		md.InformalName = 'Mr Member';
		md.Gender = 'M';
		md.Ethnicity = '';
		md.SuffixCode = 'K';
		md.PrimaryContactLegacyContactKey = 'MID-LC-1234';
		md.ExcludeFromDirectory = false;
		md.IsMember = true;
		md.MemberID = 'MID-1234';
		md.Bio = 'I am Mr. Member';
		md.ProfileImageURL = 'https://member.pic';
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

}