/**
	   File: AMS_UpdateCertificateCampaign.cls
	Subject: Test Class for AMS_UpdateCertificateCampaign class.
	History: amtosantos, 2017-04-13, Initial Release.


*/
@isTest
private class AMS_UpdateCertificateCampaign_Test {
	static final String EMAIL_ENCODING = 'UTF-8';
	static final String LANGUAGE = 'en_US';
	static final String TIMEZONE = 'Asia/Dubai';
	static final String PORTAL_ROLE = 'Manager';
	static final Id ACCOUNT_RECORD_TYPE_ID_IATA_AGENCY = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

	static User testUser;
	static Contact testContact;
	static Account testAccountTop;
	static Account testAccountChild;
	static IATA_ISO_Country__c testCountry;

	@isTest
	static void testCase_01() {
		setupTestContext();

		Test.startTest();
        Account campaignAccount;
		campaignAccount = ISSP_ObjectFactory.createNewAccount();
		campaignAccount.BillingCity = 'testCampaign';
		campaignAccount.Name = 'testCampaign';
		campaignAccount.Site = 'headSite';
		campaignAccount.Sector__c = 'Travel Agent';
		//campaignAccount.Top_Parent__c = testAccountTop.Id;
		campaignAccount.RecordTypeId = ACCOUNT_RECORD_TYPE_ID_IATA_AGENCY;
		campaignAccount.IATA_ISO_Country__c = testCountry.Id;

		insert campaignAccount;

		System.runAs(testUser) {
			AMS_UpdateCertificateCampaign updateCertificationCampaign;
			Set<Id> accountIdSet = new Set<Id>();

			accountIdSet.add(campaignAccount.Id);

			updateCertificationCampaign = new AMS_UpdateCertificateCampaign(accountIdSet);

			updateCertificationCampaign.start(null);

			updateCertificationCampaign.execute(null, [SELECT Id, Certificate_Generated_Current_Year__c FROM Account WHERE Id IN :accountIdSet]);
			
			updateCertificationCampaign.finish(null);
		}

		Test.stopTest();
	}

	/** Auxiliary Methods **/
	private static void setupTestContext() {
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
		Integer randomInteger = Integer.valueOf(Math.rint(Math.random()*1000000));
		String uniqueName = orgId + String.valueOf(datetime.now().format('yyMMddHHmmss'));
		String contactId15;

		testCountry = new IATA_ISO_Country__c(
			Name = 'Test Country',
			CASS_Import__c = 'Yes',
			Case_BSP_Country__c = 'test',
			ISO_Code__c = 'X1',
			IATA_Contry_KR__c = 'Test Country X1 KR',
			IATA_Country_EN__c = 'Test Country X1 EN',
			IATA_Country_FR__c = 'Test Country X1 FR',
			IATA_Country_JP__c = 'Test Country X1 JP',
			IATA_Country_SP__c = 'Test Country X1 SP',
			IATA_Country_PT__c = 'Test Country X1 PT',
			IATA_Country_IT__c = 'Test Country X1 IT'
		);

		insert testCountry;

		testAccountTop = ISSP_ObjectFactory.createNewAccount();
		testAccountChild = ISSP_ObjectFactory.createNewAccount();

		testAccountTop.BillingCity = 'test';
		testAccountTop.Name = 'test';
		testAccountTop.Sector__c = 'Travel Agent';
		testAccountTop.Location_Type__c = 'HO';
		testAccountTop.RecordTypeId = ACCOUNT_RECORD_TYPE_ID_IATA_AGENCY;
		testAccountTop.IATACode__c = '100';

		insert testAccountTop;

		testAccountChild.BillingCity = 'test2';
		testAccountChild.Name = 'test2';
		testAccountChild.Site = 'headSite';
		testAccountChild.Sector__c = 'Travel Agent';
		testAccountChild.Top_Parent__c = testAccountTop.Id;
		testAccountChild.RecordTypeId = ACCOUNT_RECORD_TYPE_ID_IATA_AGENCY;
		testAccountChild.IATA_ISO_Country__c = testCountry.Id;

		insert testAccountChild;

		testContact = ISSP_ObjectFactory.createNewContact();

		testContact.AccountId = testAccountChild.Id;
		testContact.Email = 'test@test01.com';

		insert testContact;

		contactId15 = testContact.Id;
		contactId15 = contactId15.substring(0,15);

		testUser = new User(
			alias = 'tuAlias',
			email = testContact.email,
			emailEncodingKey = EMAIL_ENCODING,
			firstName = testContact.FirstName,
			lastName = testContact.LastName,
			languageLocaleKey = LANGUAGE,
			LocaleSidKey = LANGUAGE,
			contactId = testContact.Id,
			FederationIdentifier = contactId15,
			TimezoneSidKey = TIMEZONE,
			Username = uniqueName + String.valueOf(Integer.valueOf(Math.rint(Math.random()*1000000))) +
						'@test' + orgId + '.org',
			PortalRole = PORTAL_ROLE,
			CommunityNickname = testContact.Email.substring(0, testContact.Email.indexOf('@')) +
								Datetime.now().formatLong().substring(10,15),
			ProfileId = ISSP_Constant.TEST_User_ProfileID,
			IsActive = true
		);

		insert testUser;

		testContact.OwnerId = testUser.Id;

		update testContact;
	}
}