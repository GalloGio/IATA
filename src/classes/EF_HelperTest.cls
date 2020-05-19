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

		system.debug('TESTDEBUG: '+JSON.serializePretty(cntc));

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

		System.assertEquals(1, accrList.size());
	}

	@IsTest
	static void getEFContactRoleDetails() {
		Id contactId = [SELECT Id from Contact][0].Id;

		Test.startTest();
		List<E_and_F_Contact_Role_Detail__c> crdList = EF_Helper.getEFContactRoleDetails(String.valueOf(contactId).substring(0, 15), 'Service_Admin');
		Test.stopTest();

		System.assertEquals(1, crdList.size());
	}

	@IsTest
	static void requestAccessEF() {
		User usr = [SELECT Id, ContactId, Contact.Email, CurrencyIsoCode FROM User WHERE Alias = 'standt2'];
		Portal_Applications__c pa = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'E&F APPS'];

		Test.startTest();
		EF_Helper.requestAccessEF(pa.Id, pa.Name, usr);
		Test.stopTest();

		//Account_Contact_Role__c
		System.assertEquals(2, [SELECT Id FROM Account_Contact_Role__c].size());
		//E_and_F_Contact_Role_Detail__c
		System.assertEquals(2, [SELECT Id FROM E_and_F_Contact_Role_Detail__c].size());
		//Portal_Application_Right__c
		System.assertEquals(1, [SELECT Id FROM Portal_Applications__c].size());
	}

	@IsTest
	static void createInvite() {
		Id accountRoleId = [SELECT Id FROM Account_Role__c][0].Id;
		Id accountId = [SELECT Id FROM Account][0].Id;
		Id serviceId = [SELECT Id, Name FROM Portal_Applications__c WHERE Name = 'E&F APPS'].Id;

		Map<String, String> fields = new Map<String, String>{
			'Email__c' => 'test@test.com.efappreg',
			'AccountRoleId__c' => '',
			'Role__c' => accountRoleId,
			'AccountId__c' => accountId,
			'ServiceId__c' => serviceId
		};
		Test.startTest();
		EF_Helper.createInvite(fields);
		Test.stopTest();

		System.assertEquals(2, [SELECT Id FROM Invitation__c].size());
	}

	@IsTest
	static void getContacts(){

		Id contactId = [SELECT Id from Contact][0].Id;

		Test.startTest();
		System.assertEquals('Contact Test', EF_Helper.getContacts(contactId, 'Contact', null, null, null, '0')[0].contactName);
		Test.stopTest();
	}
}