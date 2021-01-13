@isTest
private class OneId_NDCMM_AccountSelection_CTRL_TEST {
	public static Account airline {get;set;}
	public static Account seller {get;set;}
	public static Account aggregator {get;set;}

	public static Contact communityUserContactAirline {get;set;}
	public static Contact communityUserContactSeller {get;set;}
	public static Contact communityUserContactAggregator {get;set;}

	public static User communityUserAirline {get;set;}
	public static User communityUserSeller {get;set;}
	public static User communityUserAggregator {get;set;}

	@testSetup
	static void setup() {

		Id rtID = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Provider');

		//Create config service object
		One_Id_Service_Provider_Config__c serviceConfig = new One_Id_Service_Provider_Config__c();
		serviceConfig.Service_Provider_Name__c = 'NDCMM';
		serviceConfig.RecordTypeId = rtID;
		insert serviceConfig;

		//Create Airline, Seller and Aggregator accounts
		insert new IATA_ISO_Country__c(ISO_Code__c='US', Name='United States');
		IATA_ISO_Country__c isoCountry = [select id from IATA_ISO_Country__c WHERE ISO_Code__c = 'US'][0];
		list<Account> accs = new list<Account>{
			new Account(
				name= 'Airline',
				recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'),
				IATA_ISO_Country__c = isoCountry.Id,
				Sector__c = 'Airline',
				Category__c = ''
			),
			new Account(
				name= 'Seller',
				recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
				IATA_ISO_Country__c = isoCountry.Id,
				Sector__c = 'Travel Agent',
				Category__c = 'IATA Passenger Sales Agent'
			),
			new Account(
				name= 'Aggregator',
				recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others'),
				IATA_ISO_Country__c = isoCountry.Id,
				Sector__c = 'Airline Supplier',
				Category__c = 'Global Distribution System'
			)
		};
		insert accs;

		Id guestProfile = [select id from profile where name='identity Profile'].id;

		List<User> guestUsers = [select Id from User where Name = 'identity Site Guest User'];

		if(guestUsers.isEmpty()){
			User guestUser = new User(alias = 'guest', email='guest@noemail.com',
					emailencodingkey='UTF-8', firstname='identity', lastname='Site Guest User', languagelocalekey='en_US',
					localesidkey='en_US', profileid = guestProfile, country='United States',IsActive =true,
					License_Cost_Center__c = 'ISF005CH01',
					timezonesidkey='America/Los_Angeles', username='guest@noemail.com');
			insert guestUser;
		}



		// Create a community user
		Id p = [select id from profile where name='ISS Portal (Partner)'].id;
		airline = accs[0];
		seller = accs[1];
		aggregator = accs[2];

		communityUserContactAirline = new Contact(FirstName = 'Airline', LastName ='Contact',AccountId = airline.Id);
		communityUserContactSeller = new Contact(FirstName = 'Seller', LastName ='Contact',AccountId = seller.Id);
		communityUserContactAggregator = new Contact(FirstName = 'Aggregator', LastName ='Contact',AccountId = aggregator.Id);

		List<Contact> contacts = new List<Contact>{communityUserContactAirline, communityUserContactSeller, communityUserContactAggregator};
		insert contacts;

		communityUserAirline = new User(alias = 'airline', email='airline@noemail.com',
				emailencodingkey='UTF-8', firstname = 'Airline', lastname='Contact', languagelocalekey='en_US',
				localesidkey='en_US', profileid = p, country='United States',IsActive =true,
				ContactId = communityUserContactAirline.Id,
				License_Cost_Center__c = 'ISF005CH01',
				timezonesidkey='America/Los_Angeles', username='airline@noemail.com');

		communityUserSeller = new User(alias = 'seller', email='seller@noemail.com',
				emailencodingkey='UTF-8', firstname = 'Seller', lastname='Contact', languagelocalekey='en_US',
				localesidkey='en_US', profileid = p, country='United States',IsActive =true,
				ContactId = communityUserContactSeller.Id,
				License_Cost_Center__c = 'ISF005CH01',
				timezonesidkey='America/Los_Angeles', username='seller@noemail.com');

		communityUserAggregator = new User(alias = 'aggregat', email='aggregator@noemail.com',
				emailencodingkey='UTF-8', firstname = 'Aggregator', lastname='Contact', languagelocalekey='en_US',
				localesidkey='en_US', profileid = p, country='United States',IsActive =true,
				ContactId = communityUserContactAggregator.Id,
				License_Cost_Center__c = 'ISF005CH01',
				timezonesidkey='America/Los_Angeles', username='aggregator@noemail.com');

		List<User> users = new List<User>{communityUserAirline, communityUserSeller, communityUserAggregator};
		insert users;
//        insert communityUser;
	}

	@isTest
	static void registerAsNewContact(){
		Contact newContact = new Contact(
			FirstName = 'new',
			LastName = 'Contact',
			Salutation = 'Mr.',
			Email = 'new@test.com',
			Title = 'title',
			Phone = '123',
			MobilePhone = '123',
			Fax = '123',
			Membership_Function__c = 'any'
		);

		Account airline = [Select
							Id,
							Name,
							Sector__c,
							Category__c,
							ParentId,
							IATA_ISO_Country__c,
							IATA_ISO_Shipping_Country__c,
							BillingCountry,
							ShippingCountry,
							IATA_ISO_Billing_State__c,
							IATA_ISO_Shipping_State__c
							from Account where RecordType.DeveloperName = 'IATA_Airline'];

		User guestUser = [select Id from User where Name = 'identity Site Guest User'];

		system.runAs(guestUser) {
			OneId_RegistrationProcessController.UserInformation info = OneId_RegistrationProcessController.getUserInformationFromEmail('new@test.com', 'NDCMM');
			OneId_RegistrationProcessController.registration(airline, newContact, 'NDCMM', false);
		}

	}

	@isTest
	static void registerAsExistingAirlineContact(){
		Account airline = [Select
							Id,
							Name,
							Sector__c,
							Category__c,
							ParentId,
							IATA_ISO_Country__c,
							IATA_ISO_Shipping_Country__c,
							BillingCountry,
							ShippingCountry,
							IATA_ISO_Billing_State__c,
							IATA_ISO_Shipping_State__c
							from Account where RecordType.DeveloperName = 'IATA_Airline'];
		Contact airlineContact = new Contact(FirstName = 'Airline 2', LastName = 'Contact', AccountId = airline.Id, Email = 'test@test.test');
		insert airlineContact;

		User guestUser = [select Id from User where Name = 'identity Site Guest User'];

		system.runAs(guestUser) {
			//OneId_RegistrationProcessController.UserInformation info = OneId_RegistrationProcessController.getUserInformationFromEmail(airlineContact.Email, 'NDCMM');
			//OneId_RegistrationProcessController.registration(airline, airlineContact, 'NDCMM');
		}
	}

	@isTest
	static void initPageAsAirlineUser() {
		User commUser = [SELECT Id FROM User WHERE firstname = 'Airline' LIMIT 1][0];
		system.runAs(commUser) {
			Account airline = [Select
								Id,
								Name,
								Sector__c,
								Category__c,
								ParentId,
								IATA_ISO_Country__c,
								IATA_ISO_Shipping_Country__c,
								BillingCountry,
								ShippingCountry,
								IATA_ISO_Billing_State__c,
								IATA_ISO_Shipping_State__c
								from Account where RecordType.DeveloperName = 'IATA_Airline'];

			 Contact airlineContact = [Select
								Id
								from Contact where FirstName = 'Airline'];


			OneId_RegistrationProcessController.getUserInformation('NDCMM');
			OneId_RegistrationProcessController.registration(airline, airlineContact, 'NDCMM', false);
		}
	}

	@isTest
	static void initPageAsSellerUser() {
		User commUser = [SELECT Id FROM User WHERE firstname = 'Seller' LIMIT 1][0];
		system.runAs(commUser) {
			Account seller = [Select
								Id,
								Name,
								Sector__c,
								Category__c,
								ParentId,
								IATA_ISO_Country__c,
								IATA_ISO_Shipping_Country__c,
								BillingCountry,
								ShippingCountry,
								IATA_ISO_Billing_State__c,
								IATA_ISO_Shipping_State__c
								from Account where RecordType.DeveloperName = 'IATA_Agency'];

			 Contact sellerContact = [Select
								Id
								from Contact where FirstName = 'Seller'];


			OneId_RegistrationProcessController.getUserInformation('NDCMM');
			OneId_RegistrationProcessController.registration(seller, sellerContact, 'NDCMM', false);
		}
	}

	@isTest
	static void initPageAsAggregatorUser() {
		 User commUser = [SELECT Id FROM User WHERE firstname = 'Aggregator' LIMIT 1][0];
		system.runAs(commUser) {
			Account aggregator = [Select
								Id,
								Name,
								Sector__c,
								Category__c,
								ParentId,
								IATA_ISO_Country__c,
								IATA_ISO_Shipping_Country__c,
								BillingCountry,
								ShippingCountry,
								IATA_ISO_Billing_State__c,
								IATA_ISO_Shipping_State__c
								from Account where RecordType.DeveloperName = 'Others'];

			 Contact aggregatorContact = [Select
								Id
								from Contact where FirstName = 'Aggregator'];


			OneId_RegistrationProcessController.getUserInformation('NDCMM');
			OneId_RegistrationProcessController.registration(aggregator, aggregatorContact, 'NDCMM', false);
		}
	}

	@isTest
	static void Base_CTRLTest() {
		Base_CTRL.loadConfig('NDCMM');
	}


	@isTest
	static void search() {
		IATA_ISO_Country__c isoCountry = [select id from IATA_ISO_Country__c WHERE ISO_Code__c = 'US'][0];

		List<Account> acc1 = OneId_RegistrationProcessController.getAccountsBySectorAndCategory('Airline', '', isoCountry.Id, 'Air');
		List<Account> acc2 = OneId_RegistrationProcessController.getAccountsBySectorAndCategory('Travel Agent', 'IATA Passenger Sales Agent', isoCountry.Id, 'Sel');
		List<Account> acc3 = OneId_RegistrationProcessController.getAccountsBySectorAndCategory('Airline Supplier', 'Global Distribution System', isoCountry.Id, 'Agg');
	}
}
