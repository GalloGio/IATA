@isTest
public class ANG_ISSP_AfpWrapper_Test {
	@testSetup static void testSetup() {
		Test.startTest();

		Portal_Applications__c s1 = new Portal_Applications__c (Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
			ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_Accredited_Agents_Only__c = false,
			Agency__c = true);

		Portal_Applications__c s2 = new Portal_Applications__c (Name = AMS_Utils.IATA_ACCREDITATION_AND_CHANGES,
			ANG_Accredited_Agents_Only__c = false,
			Agency__c = true);

		insert new List<Portal_Applications__c>{s1, s2};

		IATA_ISO_Country__c indonesia = new IATA_ISO_Country__c(Name = 'Indonesia',
			ISO_Code__c = 'ID',
			ANG_Portal_Service__c = s1.id,
			ANG_Enable_NewGen__c = true);

		IATA_ISO_Country__c india = new IATA_ISO_Country__c(Name = 'India',
			ISO_Code__c = 'IN',
			ANG_Portal_Service__c = s1.id,
			ANG_Enable_NewGen__c = true,
			ANG_IEP_Model__c = 'Banking Model');

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name = 'Portugal',
			ISO_Code__c = 'PT',
			ANG_Portal_Service__c = s1.id,
			ANG_Enable_NewGen__c = true);

		IATA_ISO_Country__c china = new IATA_ISO_Country__c(Name = 'China',
			ISO_Code__c = 'CN',
			ANG_Portal_Service__c = s1.id,
			ANG_Enable_NewGen__c = true);

		insert new List<IATA_ISO_Country__c>{indonesia, india, portugal, china};

		Id easyPayModelConfig = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'EasyPay_Model_Config');

		AMS_Country_Specific_Attribute__c attr1 = new AMS_Country_Specific_Attribute__c(IATA_ISO_Country__c = indonesia.Id,
			RecordTypeId = easyPayModelConfig,
			IEP_Model_Banking_Message__c = 'ANG_ISSP_IEP_Indonesia_msg',
			Location_Class__c = 'P');

		AMS_Country_Specific_Attribute__c attr2 = new AMS_Country_Specific_Attribute__c(IATA_ISO_Country__c = india.Id,
			RecordTypeId = easyPayModelConfig,
			IEP_Model_Banking_Message__c = 'ANG_ISSP_IEP_ModelBanking_India_msg');

		insert new List<AMS_Country_Specific_Attribute__c>{attr1, attr2};

		Account indonesiaDomestic = new Account (name = 'Indonesia Domestic',
			IATA_ISO_Country__c = indonesia.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
			Location_type__c = 'HE',
			IATACode__c = '12345678',
			ANG_Accreditation_Model__c = 'Cash',
			Status__c = 'Approved',
			Location_Class__c = 'D',
			Category__c = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT);

		Account indonesiaInternational = new Account (name = 'Indonesia International',
			IATA_ISO_Country__c = indonesia.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
			Location_type__c = 'HE',
			IATACode__c = '12345677',
			ANG_Accreditation_Model__c = 'Cash',
			Status__c = 'Approved',
			Location_Class__c = 'P',
			Category__c = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT);

		Account indiaAcc = new Account (Name = 'India',
			IATA_ISO_Country__c = india.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
			Location_type__c = 'HE',
			IATACode__c = '12345677',
			ANG_Accreditation_Model__c = 'Cash',
			Status__c = 'Approved',
			Location_Class__c = 'P',
			Category__c = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT);

		Account portugalAcc = new Account (Name = 'Portugal',
			IATA_ISO_Country__c = portugal.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT,
			Location_type__c = 'HE',
			IATACode__c = '12345677',
			ANG_Accreditation_Model__c = 'Cashless',
			Status__c = 'Approved',
			Location_Class__c = 'P',
			Category__c = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT);

		Account chinaAcc = new Account (Name = 'China',
			IATA_ISO_Country__c = china.id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
			Location_type__c = 'HE',
			IATACode__c = '12345670',
			ANG_Accreditation_Model__c = 'Cash',
			Status__c = 'Approved',
			Location_Class__c = 'P',
			Category__c = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT);

		insert new List<Account>{indonesiaDomestic, indonesiaInternational, indiaAcc, portugalAcc, chinaAcc};

		Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'FormOfPayment');

		Agency_Authorization__c aa1 = new Agency_Authorization__c(ANG_FormOfPayment_ID__c = 'CA',
			Account__c = chinaAcc.id,
			Status__c = 'Authorized',
			RecordTypeId = formOfPaymentRT);

		Agency_Authorization__c aa2 = new Agency_Authorization__c(ANG_FormOfPayment_ID__c = 'CC',
			Account__c = chinaAcc.id,
			Status__c = 'Authorized',
			RecordTypeId = formOfPaymentRT);

		Agency_Authorization__c aa3 = new Agency_Authorization__c(ANG_FormOfPayment_ID__c = 'BOP',
			Account__c = chinaAcc.id,
			Status__c = 'Authorized',
			RecordTypeId = formOfPaymentRT);

		insert new List<Agency_Authorization__c>{aa1, aa2, aa3};

		Contact c1 = new Contact(FirstName = 'Indonesia',
			LastName = 'Domestic',
			AccountId = indonesiaDomestic.Id,
			Authorized_Signatory__c = true,
			Email = 'indonesia@domestic.com');

		Contact c2 = new Contact(FirstName = 'Indonesia',
			LastName = 'International',
			AccountId = indonesiaInternational.Id,
			Authorized_Signatory__c = true,
			Email = 'indonesia@international.com');

		Contact c3 = new Contact(FirstName = 'India',
			LastName = 'Test',
			AccountId = indiaAcc.Id,
			Authorized_Signatory__c = true,
			Email = 'india@acc.com');

		Contact c4 = new Contact(FirstName = 'Portugal Redirect',
			LastName = 'Test',
			AccountId = portugalAcc.Id,
			Authorized_Signatory__c = true,
			Email = 'portugal@acc.com');

		Contact c5 = new Contact(FirstName = 'Portugal No Redirect',
			LastName = 'Test',
			AccountId = portugalAcc.Id,
			Email = 'portugal2@acc.com');

		Contact c6 = new Contact(FirstName = 'China',
			LastName = 'Test',
			AccountId = chinaAcc.Id,
			Authorized_Signatory__c = true,
			Email = 'china@acc.com');

		insert new List<Contact>{c1, c2, c3, c4, c5, c6};

		Portal_Application_Right__c appRight1 = new Portal_Application_Right__c(Portal_Application__c = s1.id,
			Right__c = 'Access Granted',
			Contact__c = c2.Id);

		Portal_Application_Right__c appRight2 = new Portal_Application_Right__c(Portal_Application__c = s2.id,
			Right__c = 'Access Granted',
			Contact__c = c4.Id);

		insert new List<Portal_Application_Right__c>{appRight1, appRight2};

		User userIndoDomestic = ISSP_ObjectFactory.createPortalUser(c1);
		c1.OwnerId = userIndoDomestic.Id;

		User userIndoInternational = ISSP_ObjectFactory.createPortalUser(c2);
		c2.OwnerId = userIndoInternational.Id;

		User userIndia = ISSP_ObjectFactory.createPortalUser(c3);
		c3.OwnerId = userIndia.Id;

		User userPortugal = ISSP_ObjectFactory.createPortalUser(c4);
		c4.OwnerId = userPortugal.Id;

		User userPortugal2 = ISSP_ObjectFactory.createPortalUser(c5);
		c5.OwnerId = userPortugal2.Id;

		User userChina = ISSP_ObjectFactory.createPortalUser(c6);
		c6.OwnerId = userChina.Id;

		update new List<Contact>{c1, c2, c3, c4, c5, c6};

		Test.stopTest();
	}

	@isTest static void testCountrySpecificsWithClass() {
		User indonesiaUser = fetchUserFromEmail('indonesia@international.com');

		Test.startTest();

		System.runAs(indonesiaUser) {
			ANG_ISSP_AfpWrapper wrapper = new ANG_ISSP_AfpWrapper(indonesiaUser.Contact, indonesiaUser.Contact.Account);

			System.assertEquals('#', wrapper.iepLink, 'The link should not redirect to another page.');
			System.assertEquals(Label.ANG_ISSP_REH_AccessEasyPay, wrapper.iepLinkLabel, 'The label should be the default access EasyPay one.');
			System.assertEquals(Label.ANG_ISSP_IEP_Indonesia_msg, wrapper.modalErrorMessage, 'The message should be the specified one in the Country Specifics record.');
			System.assert(!wrapper.isSearch, 'This is the RHC Constructor.');
			System.assert(wrapper.isInternational, 'This is an International account.');
			System.assert(!wrapper.isDomestic, 'This is an International account.');
		}

		Test.stopTest();
	}

	@isTest static void testCountrySpecificsWithoutClass() {
		User indiaUser = fetchUserFromEmail('india@acc.com');

		Test.startTest();

		System.runAs(indiaUser) {
			ANG_ISSP_AfpWrapper wrapper = new ANG_ISSP_AfpWrapper(indiaUser.Contact, indiaUser.Contact.Account);

			System.assertEquals('#', wrapper.iepLink, 'The link should not redirect to another page.');
			System.assertEquals(Label.ANG_ISSP_IEP_ModelBanking_link, wrapper.iepLinkLabel, 'The label should be the Model Banking one.');
			System.assertEquals(Label.ANG_ISSP_IEP_ModelBanking_India_msg, wrapper.modalErrorMessage, 'The message should be the specified one in the Country Specifics record.');
		}

		Test.stopTest();
	}

	@isTest static void testCountrySpecificsWithoutMatch() {
		User indonesiaUser = fetchUserFromEmail('indonesia@domestic.com');

		Test.startTest();

		System.runAs(indonesiaUser) {
			ANG_ISSP_AfpWrapper wrapper = new ANG_ISSP_AfpWrapper(indonesiaUser.Contact, indonesiaUser.Contact.Account);

			System.assertEquals(ANG_ISSP_AfpWrapper.AVAILABLE_SERVICES_OLD, wrapper.iepLink, 'The link should not redirect to another page.');
			System.assertEquals(Label.ANG_ISSP_Request_Access_IATA_EasyPay, wrapper.iepLinkLabel, 'The label should be the Model Banking one.');
			System.assertEquals(ANG_ISSP_AfpWrapper.YES, wrapper.isIEP, 'There should be IEP authorizaation');
			System.assert(wrapper.isIEPFlag, 'There should be IEP authorizaation');
		}

		Test.stopTest();
	}

	@isTest static void testNoCountrySpecificsNoIEPWithRedirect() {
		User portugalUser = fetchUserFromEmail('portugal@acc.com');

		Test.startTest();

		System.runAs(portugalUser) {
			ANG_ISSP_AfpWrapper wrapper = new ANG_ISSP_AfpWrapper(portugalUser.Contact, portugalUser.Contact.Account);

			System.assertEquals(ANG_ISSP_AfpWrapper.AVAILABLE_SERVICES_OLD, wrapper.iepLink, 'The link should redirect to services page.');
			System.assertEquals(Label.ANG_ISSP_Open_IATA_EasyPay_Account, wrapper.iepLinkLabel, 'The label should be the default Request IEP one');
		}

		Test.stopTest();
	}

	@isTest static void testNoCountrySpecificsNoIEPWithoutRedirect() {
		User portugalUser = fetchUserFromEmail('portugal2@acc.com');

		Test.startTest();

		System.runAs(portugalUser) {
			ANG_ISSP_AfpWrapper wrapper = new ANG_ISSP_AfpWrapper(portugalUser.Contact, portugalUser.Contact.Account);

			System.assertEquals('#', wrapper.iepLink, 'The link should not redirect to another page.');
			System.assertEquals(Label.ANG_ISSP_Open_IATA_EasyPay_Account, wrapper.iepLinkLabel, 'The label should be the default IEP one');
			System.assertEquals(Label.ANG_ISSP_IEP_AuthorisedSignatory_HE_auth_msg, wrapper.modalErrorMessage, 'The message should be the HE one.');
			System.assertEquals('-', wrapper.modalErrorMessageFlag, 'The flag should be set to (-) ');
			System.assert(wrapper.displayIcons, 'Icons should be displayed in this scneario');
		}

		Test.stopTest();
	}

	@isTest static void testChinaAuthorizations() {
		User chinaUser = fetchUserFromEmail('china@acc.com');

		Test.startTest();

		System.runAs(chinaUser) {
			ANG_ISSP_AfpWrapper wrapper = new ANG_ISSP_AfpWrapper(chinaUser.Contact, chinaUser.Contact.Account);

			System.assertEquals(3, wrapper.authQuantity, 'There should be three authorizations. Including BOP.');
			System.assert(wrapper.isBOPFlag, 'There should be BOP authorization.');
			System.assert(wrapper.isCreditCardFlag, 'There should be Credit Card authorization.');
			System.assert(wrapper.isCashFlag, 'There should be Cash authorization.');
			System.assertEquals(ANG_ISSP_AfpWrapper.YES, wrapper.isCreditCard, 'There should be Credit Card authorization.');
			System.assertEquals(ANG_ISSP_AfpWrapper.YES, wrapper.isCash, 'There should be Cash authorization.');
		}

		Test.stopTest();
	}

	private static User fetchUserFromEmail(String email) {
		return [SELECT Id, ContactId, AccountId, Contact.Authorized_Signatory__c, Contact.Account.Id, Contact.Account.ANG_Accreditation_Model__c,
			Contact.Account.ANG_IEP_Status_FF__c, Contact.Account.IATA_ISO_Country__c, Contact.Account.Location_Class__c,
			Contact.Account.Category__c, Contact.Account.Location_Type__c, Contact.Account.Top_Parent__r.Location_Class__c,
			Contact.Account.IATA_ISO_Country__r.ISO_Code__c, Contact.Account.IATA_ISO_Country__r.ANG_IEP_Model__c
				FROM User
				WHERE Contact.Email = :email];
	}
}