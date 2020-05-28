@isTest
private class EF_HelperTest {
	@TestSetup
	static void makeData(){
		Id accRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Id acrRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
		Id crdRecId = RecordTypeSingleton.getInstance().getRecordTypeId('E_and_F_Contact_Role_Detail__c', 'Service_Admin');
		Id accrRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Master');
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)'].Id;

		Account acc = new Account();
		acc.Name = 'Airline test';
		acc.Sector__c = 'Airline';
		acc.Field_Head_Office__c = 'Headquarters';
		acc.Membership_status__c = 'Non-IATA member';
		acc.RecordTypeId = accRecId;
		insert acc;

		Contact cntc = new Contact();
		cntc.FirstName = 'Contact';
		cntc.LastName = 'Test';
		cntc.Status__c = 'Active';
		cntc.AccountId = acc.Id;
		cntc.Email = 'standarduser2@testorg.com.efappreg';
		insert cntc;

		User usr = New User();
		usr.Alias = 'standt2';
		usr.Email='standarduser2@testorg.com.efappreg';
		usr.EmailEncodingKey='UTF-8';
		usr.LastName='Testing';
		usr.LanguageLocaleKey='en_US';
		usr.LocaleSidKey='en_US';
		usr.ProfileId = profileId;
		usr.TimeZoneSidKey='America/Los_Angeles';
		usr.UserName='standard.username@test.com.efappreg';
		usr.License_Cost_Center__c = 'ISF005CH01';
		usr.ContactId = cntc.Id;
		insert usr;

		Account_Role__c accr = new Account_Role__c();
		accr.Account__c = accr.Id;
		accr.CurrencyIsoCode = 'USD';
		accr.Functional_Role__c = 'E&F';
		accr.RecordTypeId = accrRecId;
		accr.Account__c = acc.Id;
		insert accr;

		E_and_F_Account_Role_Detail__c ard = new E_and_F_Account_Role_Detail__c();
		ard.Detailed_Account_Role__c = 'Client';
		ard.Account_Role__c = accr.Id;
		insert ard;

		Account_Contact_Role__c acr = new Account_Contact_Role__c();
		acr.RecordTypeId = acrRecId;
		acr.Account__c = acc.Id;
		acr.Account_Role__c = accr.Id;
		acr.Contact__c = cntc.Id;
		acr.Service_Rendered__c = 'Other';
		acr.Functional_Role__c = 'E&F';
		acr.Status__c = 'Active';
		insert acr;

		E_and_F_Contact_Role_Detail__c crd = new E_and_F_Contact_Role_Detail__c();
		crd.Contact_Role__c = acr.Id;
		crd.CurrencyIsoCode = 'USD';
		crd.E_F_Account_Role_Detail__c = ard.Id;
		crd.RecordTypeId = crdRecId;
		insert crd;

		Portal_Applications__c pa = new Portal_Applications__c();
		pa.name = 'E&F APPS';
		pa.Cannot_be_managed_by_portal_admin__c = false;
		pa.Auto_approved_for__c = null;
		insert pa;

		Invitation__c invite = new Invitation__c();
		invite.Email__c = cntc.Email;
		invite.AccountId__c = acc.Id;
		invite.AccountRoleId__c = accr.Id;
		invite.Role__c = 'Service Admin';
		invite.ServiceId__c = pa.Id;
		insert invite;
	}

	@IsTest
	static void getEFAccountRoleDetail() {
		Id accountRoleId = [SELECT Id from Account_Role__c][0].Id;

		Test.startTest();
		E_and_F_Account_Role_Detail__c ard = EF_Helper.getEFAccontRoleDetail(accountRoleId);
		Test.stopTest();

		System.assertEquals([SELECT Id FROM E_and_F_Account_Role_Detail__c WHERE Account_Role__c =: accountRoleId], ard);
	}

	@IsTest
	static void getAccountContactRoles() {
		Id contactId = [SELECT Id from Contact][0].Id;

		Test.startTest();
		List<E_and_F_Account_Role_Detail__c> accrList = EF_Helper.getAccountContactRoles(contactId);
		Test.stopTest();

		List<E_and_F_Account_Role_Detail__c> expected = [SELECT Id, Account_Role__c, Account_Role__r.Account_Name__c, Account_Role__r.Account__c
														   FROM E_and_F_Account_Role_Detail__c
														  WHERE Account_Role__r.Functional_Role__c = 'E&F'
															AND ID IN (
																SELECT E_F_Account_Role_Detail__c
																  FROM E_and_F_Contact_Role_Detail__c
																 WHERE RecordType.DeveloperName = 'Service_Admin'
																   AND Contact_Role__r.Contact__c =: contactId
															)
														];

		System.assertEquals(expected, accrList);
	}

	@IsTest
	static void getEFContactRoleDetails() {
		Id contactId = [SELECT Id from Contact][0].Id;

		Test.startTest();
		List<E_and_F_Contact_Role_Detail__c> crdList = EF_Helper.getEFContactRoleDetails(String.valueOf(contactId).substring(0, 15), 'Service_Admin');
		Test.stopTest();

		List<E_and_F_Contact_Role_Detail__c> expected = [SELECT Id, RecordTypeId, RecordType.DeveloperName, Account_name__c, E_F_Account_Role_Detail__c, E_F_Account_Role_Detail__r.RecordTypeId
															  , E_F_Account_Role_Detail__r.RecordType.DeveloperName, E_F_Account_Role_Detail__r.Account_Role__c
															  , E_F_Account_Role_Detail__r.Account_Role__r.Account__c, E_F_Account_Role_Detail__r.Account_Role__r.Account__r.Global_ID__c
														   FROM E_and_F_Contact_Role_Detail__c
														  WHERE ContactFunctionalRole__c = 'E&F' AND Contact_Id__c =: String.valueOf(contactId).substring(0, 15) AND RecordType.DeveloperName = 'Service_Admin'];

		System.assertEquals(expected, crdList);
	}

	@IsTest
	static void requestAccessEF() {
		User usr = [SELECT Id, ContactId, Contact.Email, CurrencyIsoCode FROM User WHERE Alias = 'standt2'];
		E_and_F_Account_Role_Detail__c ard = [SELECT Id FROM E_and_F_Account_Role_Detail__c][0];
		Id accountRoleId = [SELECT Id from Account_Role__c][0].Id;
		Account acc = [SELECT Id FROM Account][0];
		Portal_Applications__c pa = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'E&F APPS'];

		Id crdRecId = RecordTypeSingleton.getInstance().getRecordTypeId('E_and_F_Contact_Role_Detail__c', 'Service_Admin');
		Id acrRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');

		Test.startTest();
		EF_Helper.requestAccessEF(pa.Id, pa.Name, usr);
		Test.stopTest();

		//Account_Contact_Role__c
		Account_Contact_Role__c acrExpected = new Account_Contact_Role__c(
			RecordTypeId = acrRecId,
			Account__c = acc.Id,
			Account_Role__c = accountRoleId,
			Contact__c = usr.ContactId,
			Service_Rendered__c = 'Other',
			Functional_Role__c = 'E&F',
			Status__c = 'Active',
			Id = null
		);
		Account_Contact_Role__c acrActual = [SELECT Id, RecordTypeId, Account__c, Account_Role__c, Contact__c
												  , Service_Rendered__c, Functional_Role__c, Status__c
											   FROM Account_Contact_Role__c ORDER BY CreatedDate DESC][0];
		Id acrId = acrActual.Id;
		acrActual.Id = null;
		System.assertEquals(acrExpected, acrActual);

		//E_and_F_Contact_Role_Detail__c
		E_and_F_Contact_Role_Detail__c crdExpected = new E_and_F_Contact_Role_Detail__c(
			Contact_Role__c = acrId,
			CurrencyIsoCode = usr.CurrencyIsoCode,
			E_F_Account_Role_Detail__c = ard.Id,
			RecordTypeId = crdRecId,
			Id = null
		);
		E_and_F_Contact_Role_Detail__c crdActual = [SELECT Id, Contact_Role__c, CurrencyIsoCode, E_F_Account_Role_Detail__c
														 , RecordTypeId
													  FROM E_and_F_Contact_Role_Detail__c ORDER BY CreatedDate DESC][0];
		crdActual.Id = null;
		System.assertEquals(crdExpected, crdActual);

		//Portal_Application_Right__c
		Portal_Application_Right__c parExpected = new Portal_Application_Right__c(
			Contact__c = usr.ContactId,
			Portal_Application__c = pa.Id,
			Right__c = 'Access Granted',
			Id = null
		);
		Portal_Application_Right__c parActual = [SELECT Id, Contact__c, Portal_Application__c, Right__c
												   FROM Portal_Application_Right__c ORDER BY CreatedDate DESC][0];
		parActual.Id = null;
		System.assertEquals(parExpected, parActual);

	}

	@IsTest
	static void createInvite() {
		Id accountRoleId = [SELECT Id FROM Account_Role__c][0].Id;
		Id accountId = [SELECT Id FROM Account][0].Id;
		Id serviceId = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'E&F APPS'].Id;

		Map<String, String> fields = new Map<String, String>{
			'Email__c' => 'test@test.com.efappreg',
			'AccountRoleId__c' => accountRoleId,
			'Role__c' => 'Service Admin',
			'AccountId__c' => accountId,
			'ServiceId__c' => serviceId
		};

		Test.startTest();
		EF_Helper.createInvite(fields);
		Test.stopTest();

		Invitation__c expected = new Invitation__c(
			Email__c = fields.get('Email__c'),
			AccountRoleId__c = fields.get('AccountRoleId__c'),
			Role__c = fields.get('Role__c'),
			AccountId__c = fields.get('AccountId__c'),
			ServiceId__c = fields.get('ServiceId__c'),
			Id = null
		);

		Invitation__c actual = [SELECT Email__c, AccountRoleId__c, Role__c, AccountId__c, ServiceId__c FROM Invitation__c WHERE Email__c =: fields.get('Email__c') ORDER BY CreatedDate DESC][0];
		actual.Id = null;

		System.assertEquals(expected, actual);
	}

	@IsTest
	static void getContacts(){
		Contact contact = [SELECT Id, Name from Contact][0];
		Portal_Applications__c application = [SELECT Id FROM Portal_Applications__c][0];

		Portal_Application_Right__c app = new Portal_Application_Right__c(Contact__c = contact.Id,Portal_Application__c = application.Id,Right__c = 'Access granted');
		insert app;

		List<Id> contacts = new List<Id>{contact.Id};
		String appName = 'E&F APPS';

		String query = String.format(
			'SELECT {0} , Portal_Application__r.Name' +
			' FROM Portal_Application_Right__c' +
			' WHERE Portal_Application__r.Name =: appName'+
			' AND Contact__c IN :contacts ',
			new List<String>{
				String.join(new PortalApplicationRight_Sel().getSObjectFieldListForWithContactInfo(), ', ')
			}
		);

		query += ' AND (contact__r.name LIKE {0} OR contact__r.email LIKE {0} OR contact__r.account.IATACode__c LIKE {0} OR contact__r.account.BillingCity LIKE {0} OR contact__r.account.IATA_ISO_Country__r.Name LIKE {0} )'.replace('{0}', '\'%Contact%\'');

		app = Database.query(query);

		List<PortalServicesCtrl.ContactWrapper> expected = new List<PortalServicesCtrl.ContactWrapper>();
		expected.add(new PortalServicesCtrl.ContactWrapper(app));

		Test.startTest();
		List<PortalServicesCtrl.ContactWrapper> actualList = EF_Helper.getContacts(contact.Id, 'Contact', null, null, null, '');
		Test.stopTest();

	}
}