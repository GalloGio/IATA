@isTest
private class CreateNotificationsFromQueryBatchTest {

	 @TestSetup
	static void makeData(){

		Notification_template__c template = new Notification_template__c(
			Identifier__c = 'test notification template',
			Message__c = 'this is a dummy test message',
			Alert_Contact_By_Email__c = false,
			Alert_Contact_By_Push_Notification__c = true,
			Subject__c = 'Test Subject',
			Type__c = 'Information',
			Notification_color__c = '#007FFF',
			CriticalNotification__c = true,
			Expire_in_days__c = 1
		);

		insert template;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Canada';
		country.ISO_Code__c = 'CA';

		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c();
		country2.Name = 'Portugal';
		country2.ISO_Code__c = 'PT';

		insert (new List<IATA_ISO_Country__c> {country,country2});

		Account newAccount = new Account();
		newAccount.Name = 'Test Account 1';
		newAccount.Sector__c = 'Airline';
		newAccount.Category__c = 'Military';
		newAccount.Is_General_Public_Account__c = true;
		newAccount.IATA_ISO_Country__c = country.Id;
		newAccount.Reason_for_creation__c = 'Account is missing';


		Account newAccount2 = new Account();
		newAccount2.Name = 'Test Account 2';
		newAccount2.Sector__c = 'Airline';
		newAccount2.Category__c = 'Cargo only';
		newAccount2.Is_General_Public_Account__c = true;
		newAccount2.IATA_ISO_Country__c = country2.Id;
		newAccount2.Reason_for_creation__c = 'Account is missing';

		insert (new List<Account>{newAccount,newAccount2});

		Contact newContact = new Contact();
		newContact.FirstName = 'test';
		newContact.LastName = 'testUserController';
		newContact.Email = DateTime.now().getTime() +'_test@test.test';
		newContact.AccountId = newAccount.Id;
		newContact.Preferred_Language__c = 'English';
		newContact.Country__c = 'Canada';
		newContact.Community__c = 'ISS Customer Portal';
		newContact.Last_registration_notification_date__c = System.today();


		Contact newContact2 = new Contact();
		newContact2.FirstName = 'test2';
		newContact2.LastName = 'test2UserController';
		newContact2.Email = DateTime.now().getTime() +'_test2@test.test';
		newContact2.AccountId = newAccount2.Id;
		newContact2.Preferred_Language__c = 'Portuguese';
		newContact.Country__c = 'Portugal';
		newContact2.Community__c = 'ISS Customer Portal';
		newContact2.Last_registration_notification_date__c = System.today();


		insert (new List<Contact>{newContact,newContact2});


		Id profileId = [select Id from profile where Name=:'ISS Portal (Partner)'].Id;

		User newUser = new User(alias = 'test',
								email = newContact.email,
								emailencodingkey = 'UTF-8',
								firstname = newContact.firstName,
								lastname = newContact.lastname,
								languagelocalekey = 'en_US',
								localesidkey = 'en_US',
								contactId = newContact.Id,
								//FederationIdentifier = conId15,
								timezonesidkey = 'Asia/Dubai',
								Username = 'my_test_email@test.test',
								PortalRole = '',
								CommunityNickname = 'test User',
								ProfileId = profileId,
								IsActive = true);

		User newUser2 = new User(alias = 'test',
								email = newContact2.email,
								emailencodingkey = 'UTF-8',
								firstname = newContact2.firstName,
								lastname = newContact2.lastname,
								languagelocalekey = 'pt_BR',
								localesidkey = 'pt_BR',
								contactId = newContact2.Id,
								//FederationIdentifier = conId15,
								timezonesidkey = 'Asia/Dubai',
								Username = 'my_other_test_email@test.test',
								PortalRole = '',
								CommunityNickname = 'test2 User',
								ProfileId = profileId,
								IsActive = true);

		insert (new List<User>{newUser,newUser2});

		Portal_Applications__c portalApp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		portalApp.Name = 'testService';

		insert portalApp;

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
			Portal_Application__c = portalApp.Id,
			Contact__c = newContact.Id,
			Right__c = 'Access Granted'
		);
		Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(
			Portal_Application__c = portalApp.Id,
			Contact__c = newContact2.Id,
			Right__c = 'Access Granted'
		);
		insert (new List<Portal_Application_Right__c>{appRight,appRight2});
	}

	@isTest
	static void shouldCreateNotifications(){

		Test.startTest();
		Notification_template__c template =
					[SELECT Subject__c, Name, Message__c, Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
					Expire_in_days__c, CriticalNotification__c, LanguageLocaleKey__c,Alert_Contact_By_Push_Notification__c
					FROM Notification_template__c
					WHERE  Identifier__c = 'test notification template'];


		Id networkId = [SELECT Id FROM Network WHERE Name = 'CS Portal'].Id;

		CreateNotificationsFromQueryBatch batch = new CreateNotificationsFromQueryBatch(template,networkId,'Military','Airline',new List<String>{},'testService');
		Database.executeBatch(batch);
		Test.stopTest();
		List<Notification__c> nots = [SELECT Id,Contact__c, Message__c, Alert_Contact_By_Email__c, Alert_Contact_By_Push_Notification__c, Subject__c, Type__c, Notificatin_color__c, Notification_Campagne_Name__c, Critical_notification__c, Expiry_date__c FROM Notification__c];
		System.debug('VALINHO TEST BAATCH nots.size() => '+ nots.size());
		System.assert(nots.size() >= 1);
		System.assertEquals('this is a dummy test message', nots.get(0).Message__c);
	}
}
