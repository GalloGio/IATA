@isTest
public inherited sharing class IGOMContactRoleDetailUtilTest {

	@TestSetup
	static void makeData(){
		List<List<sObject>> stationObjects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ);
	}

	/**
	 * @description Test the setRoleDetailToContact method when the contact already has a role in station and the role name is correct.
	 */
	@isTest
	private static void setRoleDetailToContactTest_RoleExisting_Success(){
		Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
		Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		Id contRoleDetailId = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
		IGOMContactRoleDetailUtil.setRoleDetailToContact(IGOMConstants.ROLES.EDITOR, contactId, stationId);
		Test.stopTest();

		IGOM_Contact_Role_Detail__c role = [SELECT Id, Role__c FROM IGOM_Contact_Role_Detail__c WHERE Account_Role_Detail__c = :stationId AND Account_Contact_Role__r.Contact__c = :contactId LIMIT 1];
		System.assertEquals(contRoleDetailId, role.Id);
		System.assertEquals(IGOMConstants.ROLES.EDITOR, role.Role__c);
	}

	/**
	 * @description Test the setRoleDetailToContact method when the contact already has a role in station and the role name is incorrect.
	 */
	@isTest
	private static void setRoleDetailToContactTest_RoleExisting_Error(){
		Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
		Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
		try {
			IGOMContactRoleDetailUtil.setRoleDetailToContact('Non existent role', contactId, stationId);
		} catch (DmlException e) {
			System.debug('exc message '+  e.getMessage());
			System.assert(e.getMessage().contains('bad value for restricted picklist field'));
		}
		Test.stopTest();
	}

	/**
	 * @description Test the setRoleDetailToContact method when the contact has no role still in station and no contact role.
	 */
	@isTest
	private static void setRoleDetailToContactTest_RoleNotExisting_WithoutAccountContactRole_Success(){
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		Id contRoleDetailId = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1].Id;
		Contact contactInAccount = IGOMTestFactory.contactFactoryCreation(1, accId).get(0);
		insert contactInAccount;

		Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
		IGOMContactRoleDetailUtil.setRoleDetailToContact(IGOMConstants.ROLES.VIEWER, contactInAccount.Id, stationId);
		Test.stopTest();

		IGOM_Contact_Role_Detail__c role = [SELECT Id, Role__c FROM IGOM_Contact_Role_Detail__c WHERE Account_Role_Detail__c = :stationId AND Account_Contact_Role__r.Contact__c = :contactInAccount.Id LIMIT 1];
		System.assertNotEquals(contRoleDetailId, role.Id);
		System.assertEquals(IGOMConstants.ROLES.VIEWER, role.Role__c);
	}

	/**
	 * @description Test the setRoleDetailToContact method when the contact has no role still in station but has a contact role.
	 */
	@isTest
	private static void setRoleDetailToContactTest_RoleNotExisting_WithAccountContactRole_Success(){
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		Id contRoleDetailId = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1].Id;

		Contact contactInAccount = IGOMTestFactory.contactFactoryCreation(1, accId).get(0);
		insert contactInAccount;

		Id accRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		insert IGOMTestFactory.createAccountContactRole(accId, contactInAccount.Id, accRoleId);

		Id stationId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;

		Test.startTest();
		IGOMContactRoleDetailUtil.setRoleDetailToContact(IGOMConstants.ROLES.ACKNOWLEDGER, contactInAccount.Id, stationId);
		Test.stopTest();

		IGOM_Contact_Role_Detail__c role = [SELECT Id, Role__c FROM IGOM_Contact_Role_Detail__c WHERE Account_Role_Detail__c = :stationId AND Account_Contact_Role__r.Contact__c = :contactInAccount.Id LIMIT 1];
		System.assertNotEquals(contRoleDetailId, role.Id);
		System.assertEquals(IGOMConstants.ROLES.ACKNOWLEDGER, role.Role__c);
	}


	/**
	 * @description Test the getRoleDetailsFromContacts method for a list of contacts that belong to the account related to a station and a list of contacts that belong to an account
	 * that is unrelated with the station.
	 */
	@isTest
	private static void getRoleDetailsFromContactsTest_Success(){
		Map<Id, IGOMContactRoleDetailUtil.ContactRoleDetail> contactRolesPerContactId;
		Test.startTest();
		Id accRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		Id station1AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		Id accRoleDetailId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		// Create 7 contact roles (+Station administrator) in station 1
		List<SObject> station2Objects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		Id station2AccountId = station2Objects.get(0).Id;

		List<Contact> allContacts = new List<Contact>();
		List<Contact> contactsInStation1WithoutRole = IGOMTestFactory.contactFactoryCreation(5, station1AccountId);
		allContacts.addAll(contactsInStation1WithoutRole);

		List<Contact> contactsInStation2WithoutRole = IGOMTestFactory.contactFactoryCreation(2, station2AccountId);
		allContacts.addAll(contactsInStation2WithoutRole);
		insert allContacts;

		Set<Id> contactIds = new Set<Id>();
		//Create an account contact role for every contact
		List<Account_Contact_Role__c> accContactRoles = new List<Account_Contact_Role__c>();
		for (Contact c : allContacts) {
			accContactRoles.add(IGOMTestFactory.createAccountContactRole(station1AccountId, c.Id, accRoleId));
			contactIds.add(c.Id);
		}
		insert accContactRoles;

		//Create a contact role detail for every contact
		List<IGOM_Contact_Role_Detail__c> contactRoles = new List<IGOM_Contact_Role_Detail__c>();
		for (Account_Contact_Role__c accConRole : accContactRoles) {
			contactRoles.add(IGOMTestFactory.createIGOMContactRoleDetail(accConRole.Id, accRoleDetailId, IGOMConstants.ROLES.ACKNOWLEDGER));
		}
		insert contactRoles;

		contactRolesPerContactId =  IGOMContactRoleDetailUtil.getRoleDetailsFromContacts(accRoleDetailId, contactIds);
		Test.stopTest();

		System.assertNotEquals(null, contactRolesPerContactId);
		System.assertEquals(5+2, contactRolesPerContactId.size());
		for (IGOMContactRoleDetailUtil.ContactRoleDetail conRole : contactRolesPerContactId.values()) {
			System.assertEquals(IGOMConstants.ROLES.ACKNOWLEDGER, conRole.role);
		}
	}

	/**
	 * @description Test the getRoleDetailsFromContacts method for a list of contacts that do not have a role but have account contact roles.
	 */
	@isTest
	private static void getRoleDetailsFromContactsTest_Error_NoContactRoles(){
		Map<Id, IGOMContactRoleDetailUtil.ContactRoleDetail> contactRolesPerContactId;
		Test.startTest();
		Id accRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		Id station1AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		Id accRoleDetailId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		// Create 7 contact roles (+Station administrator) in station 1
		List<SObject> station2Objects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		Id station2AccountId = station2Objects.get(0).Id;

		List<Contact> allContacts = new List<Contact>();
		List<Contact> contactsInStation1WithoutRole = IGOMTestFactory.contactFactoryCreation(5, station1AccountId);
		allContacts.addAll(contactsInStation1WithoutRole);

		List<Contact> contactsInStation2WithoutRole = IGOMTestFactory.contactFactoryCreation(2, station2AccountId);
		allContacts.addAll(contactsInStation2WithoutRole);
		insert allContacts;

		Set<Id> contactIds = new Set<Id>();
		//Create an account contact role for every contact
		List<Account_Contact_Role__c> accContactRoles = new List<Account_Contact_Role__c>();
		for (Contact c : allContacts) {
			accContactRoles.add(IGOMTestFactory.createAccountContactRole(station1AccountId, c.Id, accRoleId));
			contactIds.add(c.Id);
		}
		insert accContactRoles;

		contactRolesPerContactId =  IGOMContactRoleDetailUtil.getRoleDetailsFromContacts(accRoleDetailId, contactIds);
		Test.stopTest();

		System.assertEquals(0, contactRolesPerContactId.size());
	}

	/**
	 * @description Test the getRoleDetailsFromContacts method for a list of contacts that do not have a role and do not have account contact roles.
	 */
	@isTest
	private static void getRoleDetailsFromContactsTest_Error_NoAccContactRoles(){
		Map<Id, IGOMContactRoleDetailUtil.ContactRoleDetail> contactRolesPerContactId;
		Test.startTest();
		Id station1AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		Id accRoleDetailId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		// Create 7 contact roles (+Station administrator) in station 1
		List<SObject> station2Objects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		Id station2AccountId = station2Objects.get(0).Id;

		List<Contact> allContacts = new List<Contact>();
		List<Contact> contactsInStation1WithoutRole = IGOMTestFactory.contactFactoryCreation(5, station1AccountId);
		allContacts.addAll(contactsInStation1WithoutRole);

		List<Contact> contactsInStation2WithoutRole = IGOMTestFactory.contactFactoryCreation(2, station2AccountId);
		allContacts.addAll(contactsInStation2WithoutRole);
		insert allContacts;

		Set<Id> contactIds = new Set<Id>();
		for (Contact c : allContacts) {
			contactIds.add(c.Id);
		}

		contactRolesPerContactId =  IGOMContactRoleDetailUtil.getRoleDetailsFromContacts(accRoleDetailId, contactIds);
		Test.stopTest();

		System.assertEquals(0, contactRolesPerContactId.size());
	}


	/**
	 * @description Test the getOtherRoleDetails method.
	 */
	@isTest
	private static void getOtherRoleDetailsTest(){
		Map<Id, IGOMContactRoleDetailUtil.ContactRoleDetail> contactRolesPerContactId;
		Test.startTest();
		Id accRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		Id station1AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		Id accRoleDetailId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		Id conRoleDetailId = [SELECT Id FROM IGOM_Contact_Role_Detail__c LIMIT 1].Id;
		// Create 7 contact roles (+Station administrator) in station 1
		List<SObject> station2Objects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		Id station2AccountId = station2Objects.get(0).Id;

		List<Contact> allContacts = new List<Contact>();
		List<Contact> contactsInStation1WithoutRole = IGOMTestFactory.contactFactoryCreation(5, station1AccountId);
		allContacts.addAll(contactsInStation1WithoutRole);

		List<Contact> contactsInStation2WithoutRole = IGOMTestFactory.contactFactoryCreation(2, station2AccountId);
		allContacts.addAll(contactsInStation2WithoutRole);
		insert allContacts;

		Set<Id> contactInAcc1Ids = new Set<Id>();
		//Create an account contact role for every contact
		List<Account_Contact_Role__c> accContactRoles = new List<Account_Contact_Role__c>();
		for (Contact c : allContacts) {
			accContactRoles.add(IGOMTestFactory.createAccountContactRole(station1AccountId, c.Id, accRoleId));
			if(c.AccountId == station1AccountId){
				contactInAcc1Ids.add(c.Id);
			}
		}
		insert accContactRoles;

		Map<Id, Id> contactIdByAccContRoleId = new Map<Id, Id>();
		//Create a contact role detail for every contact
		List<IGOM_Contact_Role_Detail__c> contactRoles = new List<IGOM_Contact_Role_Detail__c>();
		for (Account_Contact_Role__c accConRole : accContactRoles) {
			contactRoles.add(IGOMTestFactory.createIGOMContactRoleDetail(accConRole.Id, accRoleDetailId, IGOMConstants.ROLES.ACKNOWLEDGER));
			contactIdByAccContRoleId.put(accConRole.Id, accConRole.Contact__c);
		}
		insert contactRoles;

		// Avoid looking for the contact roles from contacts related to account 1
		Set<Id> contactRoleDetailsToAvoid = new Set<Id>();
		for(IGOM_Contact_Role_Detail__c cR : contactRoles){
			if(contactInAcc1Ids.contains(contactIdByAccContRoleId.get(cR.Account_Contact_Role__c))){
				contactRoleDetailsToAvoid.add(cR.Id);
			}
		}

		//Avoid looking for station admin
		contactRoleDetailsToAvoid.add(conRoleDetailId);

		contactRolesPerContactId =  IGOMContactRoleDetailUtil.getOtherRoleDetails(accRoleDetailId, contactRoleDetailsToAvoid);
		Test.stopTest();

		System.assertNotEquals(null, contactRolesPerContactId);
		System.assertEquals(2, contactRolesPerContactId.size());
		for (IGOMContactRoleDetailUtil.ContactRoleDetail conRole : contactRolesPerContactId.values()) {
			System.assertEquals(IGOMConstants.ROLES.ACKNOWLEDGER, conRole.role);
			System.assert(!contactRoleDetailsToAvoid.contains(conRole.Id));
		}
	}


	/**
	 * @description Test the getContactsAvoidingStation method when there is a list of contacts in other stations
	 * without a search term
	 */
	@isTest
	private static void getContactsAvoidingStationTest_EmptySearch(){
		Contact contactInStation2;
		Test.startTest();
		Id accRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		Id station1AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		Id accRoleDetailId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		// Create 5 contact roles (+Station administrator) in station 1 from the contacts in that station's account
		List<SObject> station2Objects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		Id station2AccountId = station2Objects.get(0).Id;

		List<Contact> allContacts = new List<Contact>();
		List<Contact> contactsInStation1WithoutRole = IGOMTestFactory.contactFactoryCreation(5, station1AccountId);
		allContacts.addAll(contactsInStation1WithoutRole);

		List<Contact> contactsInStation2WithoutRole = IGOMTestFactory.contactFactoryCreation(2, station2AccountId);
		allContacts.addAll(contactsInStation2WithoutRole);
		insert allContacts;

		//Create an account contact role for every contact
		List<Account_Contact_Role__c> accContactRolesStation1 = new List<Account_Contact_Role__c>();
		for (Contact c : contactsInStation1WithoutRole) {
			accContactRolesStation1.add(IGOMTestFactory.createAccountContactRole(station1AccountId, c.Id, accRoleId));
		}
		insert accContactRolesStation1;

		//Create a contact role detail for every contact
		List<IGOM_Contact_Role_Detail__c> contactRolesStation1 = new List<IGOM_Contact_Role_Detail__c>();
		for (Account_Contact_Role__c accConRole : accContactRolesStation1) {
			contactRolesStation1.add(IGOMTestFactory.createIGOMContactRoleDetail(accConRole.Id, accRoleDetailId, IGOMConstants.ROLES.ACKNOWLEDGER));
		}
		insert contactRolesStation1;

		contactInStation2 =  IGOMContactRoleDetailUtil.getContactsAvoidingStation(new List<Id>{accRoleDetailId}, '');
		Test.stopTest();

		System.assertNotEquals(null, contactInStation2);
		System.assertEquals(((Contact) station2Objects.get(1)).FirstName, contactInStation2.FirstName);
	}

	/**
	 * @description Test the getContactsAvoidingStation method when there is a list of contacts in other stations
	 * with a search term
	 */
	@isTest
	private static void getContactsAvoidingStationTest_WithSearch(){
		Contact contactInStation2;
		Test.startTest();
		Id accRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		Id station1AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		Id accRoleDetailId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		// Create 5 contact roles (+Station administrator) in station 1 from the contacts in that station's account
		List<SObject> station2Objects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		Id station2AccountId = station2Objects.get(0).Id;

		List<Contact> allContacts = new List<Contact>();
		List<Contact> contactsInStation1WithoutRole = IGOMTestFactory.contactFactoryCreation(5, station1AccountId);
		allContacts.addAll(contactsInStation1WithoutRole);

		List<Contact> contactsInStation2WithoutRole = IGOMTestFactory.contactFactoryCreation(2, station2AccountId);
		allContacts.addAll(contactsInStation2WithoutRole);
		insert allContacts;

		//Create an account contact role for every contact
		List<Account_Contact_Role__c> accContactRolesStation1 = new List<Account_Contact_Role__c>();
		for (Contact c : contactsInStation1WithoutRole) {
			accContactRolesStation1.add(IGOMTestFactory.createAccountContactRole(station1AccountId, c.Id, accRoleId));
		}
		insert accContactRolesStation1;

		//Create a contact role detail for every contact
		List<IGOM_Contact_Role_Detail__c> contactRolesStation1 = new List<IGOM_Contact_Role_Detail__c>();
		for (Account_Contact_Role__c accConRole : accContactRolesStation1) {
			contactRolesStation1.add(IGOMTestFactory.createIGOMContactRoleDetail(accConRole.Id, accRoleDetailId, IGOMConstants.ROLES.ACKNOWLEDGER));
		}
		insert contactRolesStation1;

		contactInStation2 =  IGOMContactRoleDetailUtil.getContactsAvoidingStation(new List<Id>{accRoleDetailId}, contactsInStation2WithoutRole.get(1).FirstName);
		Test.stopTest();

		System.assertNotEquals(null, contactInStation2);
		System.assertEquals(contactsInStation2WithoutRole.get(1).FirstName, contactInStation2.FirstName);
	}

	/**
	 * @description Test the getContactsAvoidingStation method when the search term contains a SOQL injection
	 */
	@isTest
	private static void getContactsAvoidingStationTest_TestSOQLInjection(){
		Contact contactInStation2;
		Test.startTest();
		Id accRoleId = [SELECT Id FROM Account_Role__c LIMIT 1].Id;
		Id station1AccountId = [SELECT Id FROM Account LIMIT 1].Id;
		Id accRoleDetailId = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 1].Id;
		// Create 5 contact roles (+Station administrator) in station 1 from the contacts in that station's account
		List<SObject> station2Objects = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);
		Id station2AccountId = station2Objects.get(0).Id;

		List<Contact> allContacts = new List<Contact>();
		List<Contact> contactsInStation1WithoutRole = IGOMTestFactory.contactFactoryCreation(5, station1AccountId);
		allContacts.addAll(contactsInStation1WithoutRole);

		List<Contact> contactsInStation2WithoutRole = IGOMTestFactory.contactFactoryCreation(2, station2AccountId);
		allContacts.addAll(contactsInStation2WithoutRole);
		insert allContacts;

		//Create an account contact role for every contact
		List<Account_Contact_Role__c> accContactRolesStation1 = new List<Account_Contact_Role__c>();
		for (Contact c : contactsInStation1WithoutRole) {
			accContactRolesStation1.add(IGOMTestFactory.createAccountContactRole(station1AccountId, c.Id, accRoleId));
		}
		insert accContactRolesStation1;

		//Create a contact role detail for every contact
		List<IGOM_Contact_Role_Detail__c> contactRolesStation1 = new List<IGOM_Contact_Role_Detail__c>();
		for (Account_Contact_Role__c accConRole : accContactRolesStation1) {
			contactRolesStation1.add(IGOMTestFactory.createIGOMContactRoleDetail(accConRole.Id, accRoleDetailId, IGOMConstants.ROLES.ACKNOWLEDGER));
		}
		insert contactRolesStation1;

		String searchTerm = 'attack%\') OR (Name LIKE \'';
		try {
			contactInStation2 =  IGOMContactRoleDetailUtil.getContactsAvoidingStation(new List<Id>{accRoleDetailId}, searchTerm);
		} catch (Exception e) {
			System.assertEquals(null, contactInStation2);
			System.assertEquals('ASDF', e.getMessage());
		}
		Test.stopTest();
		System.assertEquals(null, contactInStation2);
	}


	/**
	 * @description Test the getContactsInAccount method.
	 */
	@isTest
	private static void getContactsInAccountTest(){
		// Create 5 contact roles (+Station administrator) in station 1 from the contacts in that station's account
		Id station1AccountId = [SELECT Id FROM Account LIMIT 1].Id;

		List<Contact> contactsInStation1WithoutRole = IGOMTestFactory.contactFactoryCreation(5, station1AccountId);
		insert contactsInStation1WithoutRole;

		List<Contact> contactsInStation1;
		Test.startTest();
		contactsInStation1 = IGOMContactRoleDetailUtil.getContactsInAccount(station1AccountId);
		Test.stopTest();

		System.assertNotEquals(null, contactsInStation1);
		System.assertEquals(5+1, contactsInStation1.size()); //5 contacts + 1 admin
	}
}