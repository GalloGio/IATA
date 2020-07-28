@isTest
private class EF_InvitationCtrlTest {
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
	static void getService(){
		Test.startTest();
		Portal_Applications__c pa = EF_InvitationCtrl.getService();
		Test.stopTest();

		Portal_Applications__c expected = [SELECT Id FROM Portal_Applications__c WHERE Name = 'E&F APPS'];

		System.assertEquals(expected.Id, pa.Id);
	}
	
	@IsTest
	static void getAccountRoles() {
		Id contactId = [SELECT Id FROM Contact][0].Id;
		Test.startTest();
		Map<String, String> acrList = EF_InvitationCtrl.getAccountRoles(contactId);
		Test.stopTest();

		Account acc = [SELECT Id, Name FROM Account][0];
		Account_Role__c accr = [SELECT Id FROM Account_Role__c][0];
		Map<String, String> expected = new Map<String, String>{acc.Name => accr.Id+':'+acc.Id};

		System.assertEquals(expected, acrList);
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
		EF_InvitationCtrl.createInvite(fields);
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
}