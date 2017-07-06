@isTest

private class ISSP_ctrl_ContentDisplay_Test {

	@isTest static void testISSP_ctrl_ContentDisplay() {

		ISSP_Constant.adminIdSet.add(ISSP_Constant.TEST_User_ProfileID);

		//create user
		User user1 = createUser();
		insert user1;

		system.runAs(user1){

			//create isoCountry
			IATA_ISO_Country__c isoCountry = createIsoCountry();

			//create Account
			Account acc = createAccount(isoCountry);
      		insert acc;

			//Create Contact
			Contact con2 = createContact(acc);
      		insert con2;

			//Create portal applications
		    Portal_Applications__c app = new Portal_Applications__c(Name = 'test app');
      		insert app;
      		Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
      		insert appRight;

			//create ContentVersion
			ContentVersion contentVersionInsert = new ContentVersion();
			contentVersionInsert.Title = 'Salesforce.com';
			contentVersionInsert.ContentURL='http://www.salesforce.com/';
			insert contentVersionInsert;

			ContentVersion contentVersion = [SELECT Id, Title, Description, FileType, OwnerId, Owner.Name, VersionNumber, ContentUrl,
	                       					ContentDocumentId, Country_of_publication__c, Document_Category__c, ContentSize, IsLatest
											FROM ContentVersion
											WHERE Id = :contentVersionInsert.Id];
			system.debug('xxxR contentVersion ==> '+contentVersion);

			//ContentDocument is created on ContentVersion insert
			ContentDocument contentDocument = new ContentDocument();
			contentDocument = [select Id , Title from ContentDocument WHERE ID = :contentVersion.ContentDocumentId];
			system.debug('xxxR contentDocument ==> '+contentDocument);

			Test.startTest();

			Apexpages.currentPage().getParameters().put('id',contentVersion.ContentDocumentId);
			ISSP_CS__c cs = new ISSP_CS__c(Name = 'Host', Value__c = 'portal.iata.org');
            database.insert(cs);
			ISSP_ctrl_ContentDisplay controller = new ISSP_ctrl_ContentDisplay();

			System.assertEquals(true, Apexpages.currentPage().getParameters().get('id') != null);
			System.assertEquals(contentVersion.ContentDocumentId, Apexpages.currentPage().getParameters().get('id'));
			System.assertEquals(true, controller.conVer.id != null);
			System.assertEquals(contentVersion.Id, controller.conVer.id);

			Test.stopTest();
		}
	}

		/**

@isTest static void test_method_one() {

		ISSP_Constant.adminIdSet.add(ISSP_Constant.TEST_User_ProfileID);
		//ISSP_ObjectFactory.fiilIncludedFields();
		//Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);


		IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c();
		isoCountry = [select Name ,ISO_CODE__c From IATA_ISO_Country__c where ISO_Code__c =: 'SS' ][0];


		Account topacc = ISSP_ObjectFactory.createNewAccount();
		insert topacc;
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Top_Parent__c = topacc.Id;
		acc.Industry = 'Cargo Agent';
		acc.IATA_ISO_Country__c = isoCountry.Id ;
		acc.sector__c = 'Airline';
		insert acc;

		//Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,3);
		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.Email = 'test2@test.test';
		con2.AccountId= acc.Id;
		con2.User_Portal_Status__c='Active';
		insert con2;
		User newUser2 = ISSP_ObjectFactory.createPortalUser(con2);
		con2.OwnerId = newUser2.Id;
		update con2;
		Portal_Applications__c app = new Portal_Applications__c(Name = 'test app');
		insert app;
		Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
		insert appRight;

		ContentDocument cd = new ContentDocument();
		cd = [select Id , Title from ContentDocument limit 1][0];

		ContentVersion v = new ContentVersion();
		v = [select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId
			From ContentVersion
			Where IsLatest = true And
						ContentDocumentId =: cd.Id][0];
		system.debug('xxxR ContentVersion ==> '+v);

		ContentWorkspaceDoc workspaceDoc = new ContentWorkspaceDoc();
		workspaceDoc= [select Id ,ContentDocumentId ,ContentWorkspaceId from ContentWorkspaceDoc where  ContentDocumentId =: cd.Id][0];
	 	system.debug('xxxR workspaceDoc ==> '+workspaceDoc);

	 	Test.startTest() ;

	 	system.runAs(newUser2){
		Apexpages.currentPage().getParameters().put('id',v.Id);
		ISSP_ctrl_ContentDisplay controller = new ISSP_ctrl_ContentDisplay();

		Test.stopTest();

	}

	@isTest static void test_method_two() {
		// Implement test code
	}
	*/

	//private methods:

	/**
	 * Creates IATA_ISO_Country__c records for South Sudan
	 */
	private static IATA_ISO_Country__c createIsoCountry(){

		IATA_ISO_Country__c isoCountrySS = new  IATA_ISO_Country__c();
		isoCountrySS.name = 'South Sudan';
		isoCountrySS.ISO_Code__c = 'SS';
		isoCountrySS.ISO_Code_Numeric__c = 123; //not real code
		isoCountrySS.currencyIsoCode = 'SDG';
		isoCountrySS.AIMS_Area_ID__c = '3'; //not real code

		return isoCountrySS;
	}

	/**
	 * Creates Account
	 */
	private static Account createAccount(IATA_ISO_Country__c country){

		Account topacc = ISSP_ObjectFactory.createNewAccount();
		insert topacc;
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Top_Parent__c = topacc.Id;
		acc.Industry = 'Cargo Agent';
		acc.IATA_ISO_Country__c = country.Id ;
		acc.sector__c = 'Airline';

		return acc;
	}

	/**
	 * Creates Contact
	 */
	private static Contact createContact(Account acc){

		//Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,3);
		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.Email = 'test2@test.test';
		con2.AccountId= acc.Id;
		con2.User_Portal_Status__c='Active';

		return con2;
	}

	/**
	 * Creates User
	 */
	private static User createUser(){

		UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
		Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
		User user1 = new User(
		UserRoleId = portalRole.Id,
		ProfileId = profile1.Id,
		Username = System.now().millisecond() + 'dummy@test.com',
		Alias = 'dummy',
		Email='testdummy@gmail.com',
		EmailEncodingKey='UTF-8',
		Firstname='test',
		Lastname='dummy',
		LanguageLocaleKey='en_US',
		LocaleSidKey='en_US',
		timezonesidkey = 'Asia/Dubai',
		License_Cost_Center__c = 'ITO005CH01'
		);

		return user1;
	}
}