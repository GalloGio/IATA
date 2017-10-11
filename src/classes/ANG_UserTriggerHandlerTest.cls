@isTest
private class ANG_UserTriggerHandlerTest {
	
	static testMethod void test_createPortalUser() {
		Test.startTest();

		User u;

		System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]){

			Account acc = ISSP_ObjectFactory.createNewAccount();  
			insert acc;
			
			Contact contact = ISSP_ObjectFactory.createNewContact();
			contact.AccountId = acc.Id;
			insert contact;
			
			u = new User(
				Alias = 'dsfsdfds', 
				Email = contact.email, 
				Emailencodingkey = 'UTF-8', 
				Firstname = contact.firstName, 
				Lastname = contact.lastname, 
				Languagelocalekey = 'en_US', 
				Localesidkey = 'en_US', 
				ContactId = contact.Id,
				Timezonesidkey = 'Asia/Dubai',
				Username = contact.email+'dfgdf',
				PortalRole = 'Manager',
				CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
				ProfileId = ISSP_Constant.TEST_User_ProfileID,
				IsActive = true
			);

			insert u;
			
		}

		Test.stopTest();

		User check = [SELECT Id, ContactId, FederationIdentifier FROM User WHERE Id = :u.Id];
	}

	static testMethod void test_createNonPortalUser() {

		Test.startTest();

		User u;
			
		u = new User(
			Alias = 'dsfsdfds', 
			Email = 'test@email.com', 
			Emailencodingkey = 'UTF-8', 
			Firstname = 'Test', 
			Lastname = 'Contact', 
			Languagelocalekey = 'en_US', 
			Localesidkey = 'en_US',
			Timezonesidkey = 'Asia/Dubai',
			Username = 'test@email.comdfgdf',
			PortalRole = 'Manager',
			CommunityNickname = 'test'+Datetime.now().formatLong().substring(10,15),
			ProfileId = UserInfo.getProfileId(),
			IsActive = true,
			License_Cost_Center__c = 'ISF005CH01'
		);

		insert u;

		Test.stopTest();

		User check = [SELECT Id, ContactId, FederationIdentifier FROM User WHERE Id = :u.Id];
	}	
}