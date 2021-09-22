@isTest
public class IGOMCommunityUtilTest {

	private static final String STATION_TYPE = IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ;

	@TestSetup
	static void makeData(){
		List<List<SObject>> objectsStations = IGOMTestFactory.generateIGOMUserFactory(5, IGOMConstants.ROLES.ADMIN, STATION_TYPE);
	}

	/**
	 * @description Test the getCurrentUser method.
	 */
	@isTest
	public static void getCurrentUserTest(){
		Id profileId = [SELECT Id FROM Profile WHERE Name = :IGOMConstants.GLOBALS.COMMUNITY_PROFILE LIMIT 1].Id;
		Account acc = IGOMTestFactory.accountFactoryCreation(1).get(0);
		insert acc;

		Contact simulatedContact = new Contact(
			FirstName = 'Simulation',
			LastName = 'Test'
		);
		insert simulatedContact;
		Contact propperContact = new Contact(
			FirstName = 'Contact',
			LastName = 'Test',
			Email = 'test@contact.com',
			AccountId = acc.Id
		);
		insert propperContact;

		User u = IGOMTestFactory.userFactoryCreation(1).get(0);
		u.ContactId = propperContact.Id;
		u.ProfileId = profileId;
		insert u;

		User u_new;
		Test.startTest();
		System.runAs(u){
		   u_new = IGOMCommunityUtil.getCurrentUser();
		}
		Test.stopTest();

		System.assertEquals(propperContact.Id, u_new.ContactId);
		System.assertEquals(u.Id, u_new.Id);
	}

	/**
	 * @description Test the getUserData method.
	 */
	@isTest
	public static void getUserDataTest(){
		List<SObject> objects = IGOMTestFactory.generateIGOMUser(IGOMConstants.ROLES.ADMIN, STATION_TYPE);
		User u = (User) objects.get(2);
		Contact c = (Contact) objects.get(1);

		IGOMCommunityUtil.UserData uData;
		Test.startTest();
		System.runAs(u){
			uData = IGOMCommunityUtil.getUserData();
		}
		Test.stopTest();

		System.assertEquals(u.Id, uData.userId);
		System.assertEquals(c.Id, uData.contactId);
		System.assertEquals(IGOMConstants.ROLES.ADMIN, uData.role);
	}

	/**
	 * @description Test the gerUsersInStation method.
	 */
	@isTest
	public static void getUsersInStationTest(){
		IGOM_Account_Role_Detail__c station1 = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Account_Contact_Role__c accountContactRoleStation2 = [SELECT Id FROM Account_Contact_Role__c WHERE Account_Role__c != :station1.Account_Role__c LIMIT 1];

		IGOM_Contact_Role_Detail__c roleOfUserOfStation2InStation1 = IGOMTestFactory.createIGOMContactRoleDetail(accountContactRoleStation2.Id, station1.Id, IGOMConstants.ROLES.ACKNOWLEDGER);

		insert roleOfUserOfStation2InStation1;

		List<IGOMCommunityUtil.UserData> userDataList;
		Test.startTest();
		userDataList = IGOMCommunityUtil.getUsersInStation(station1.Id);
		Test.stopTest();

		System.assertEquals(2, userDataList.size());

		System.assertEquals(IGOMConstants.ROLES.ADMIN, userDataList.get(0).role);
		System.assertEquals(IGOMConstants.ROLES.ACKNOWLEDGER, userDataList.get(1).role);
	}

	/**
	 * @description Test the getAllRelatedStations method.
	 */
	@isTest
	public static void getAllRelatedStationsTest(){
		// Create four stations to create a relationship hierarchy
		List<IGOM_Account_Role_Detail__c> stations = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 4];
		IGOM_Account_Role_Detail__c station1 = stations.get(0);
		IGOM_Account_Role_Detail__c station2 = stations.get(1);
		IGOM_Account_Role_Detail__c station3 = stations.get(2);
		IGOM_Account_Role_Detail__c station4 = stations.get(3);

		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station1.Id, station2.Id, station1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station1.Id, station3.Id, station1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station3.Id, station4.Id, station3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		insert relationships;

		IGOMAccountRoleRelationshipsUtil.AllRelationships allRelationships;
		Test.startTest();
		allRelationships = IGOMCommunityUtil.getAllRelatedStations(station3.Id);
		Test.stopTest();

		System.assertEquals(1, allRelationships.parentStations.size());
		System.assertEquals(0, allRelationships.childStations.size());
		System.assertEquals(1, allRelationships.groupStations.size());
	}

	/**
	 * @description Test the getUnrelatedStations method.
	 */
	@isTest
	public static void getUnrelatedStationsTest(){
		List<IGOM_Account_Role_Detail__c> stations = [SELECT Id FROM IGOM_Account_Role_Detail__c LIMIT 5];
		IGOM_Account_Role_Detail__c station1 = stations.get(0);
		IGOM_Account_Role_Detail__c station2 = stations.get(1);
		IGOM_Account_Role_Detail__c station3 = stations.get(2);
		IGOM_Account_Role_Detail__c station4 = stations.get(3);
		IGOM_Account_Role_Detail__c station5 = stations.get(4);

		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station1.Id, station2.Id, station1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station1.Id, station3.Id, station1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station3.Id, station5.Id, station3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(station3.Id, station4.Id, station3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		insert relationships;

		List<IGOMStationUtil.RelatedStation> unrelatedStations;
		Test.startTest();
		unrelatedStations = IGOMCommunityUtil.getUnrelatedStations(station3.Id, '');
		Test.stopTest();

		System.assertEquals(1, unrelatedStations.size());
		System.assertEquals(false, unrelatedStations.get(0).isRelatedToActiveStation);
		System.assertEquals(station3.Id, unrelatedStations.get(0).baseStationId);
		System.assertEquals(station2.Id, unrelatedStations.get(0).stationInfo.id);
	}

	/**
	 * @description Test the searchSpecificUserAvoidingStation method when there is a user with search term that is not in station.
	 */
	@isTest
	public static void searchSpecificUserAvoidingStationTest_Success(){
		List<IGOM_Account_Role_Detail__c> stations = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 2];
		IGOM_Account_Role_Detail__c station1 = stations.get(0);
		IGOM_Account_Role_Detail__c station2 = stations.get(1);

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
		WHERE Account_Contact_Role__r.Account_Role__c = :station2.Account_Role__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user2 = [SELECT Id, Firstname, Lastname FROM User WHERE ContactId = :contactId LIMIT 1];

		IGOMCommunityUtil.UserData userFromOtherStation;
		Test.startTest();
		userFromOtherStation = IGOMCommunityUtil.searchSpecificUserAvoidingStation(station1.Id, 'Test');
		Test.stopTest();

		System.assertNotEquals(null, userFromOtherStation);
		System.assertEquals(user2.Firstname + ' ' + user2.Lastname, userFromOtherStation.fullName);
	}

	/**
	 * @description Test the searchSpecificUserAvoidingStation method when there is no user with search term that is not in station.
	 */
	@isTest
	public static void searchSpecificUserAvoidingStationTest_NoUser(){
		List<IGOM_Account_Role_Detail__c> stations = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 2];
		IGOM_Account_Role_Detail__c station1 = stations.get(0);
		IGOM_Account_Role_Detail__c station2 = stations.get(1);

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
		WHERE Account_Contact_Role__r.Account_Role__c = :station2.Account_Role__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user2 = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];

		IGOMCommunityUtil.UserData userFromOtherStation;
		Test.startTest();
		userFromOtherStation = IGOMCommunityUtil.searchSpecificUserAvoidingStation(station1.Id, 'Some text that is not like the user name');
		Test.stopTest();

		System.assertEquals(null, userFromOtherStation);
	}

	/**
	 * @description Test the deleteContactRoleDetail method.
	 */
	@isTest
	public static void deleteContactRoleDetailTest_Success(){
		// Same use case as before, create a hierarchy and try to recover unrelated station
		IGOM_Account_Role_Detail__c station1 = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
		WHERE Account_Contact_Role__r.Account_Role__c = :station1.Account_Role__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		Contact contact1 = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];

		Test.startTest();
		IGOMCommunityUtil.deleteContactRoleDetail(station1.Id, contact1.Id);
		Test.stopTest();

		List<IGOM_Contact_Role_Detail__c> contactRoles = [SELECT Id FROM IGOM_Contact_Role_Detail__c];
		System.assertEquals(5-1, contactRoles.size());
	}

	/**
	 * @description Test the deleteContactRoleDetail method when the record was already deleted.
	 */
	@isTest
	public static void deleteContactRoleDetailTest_Error(){
		// Same use case as before, create a hierarchy and try to recover unrelated station
		IGOM_Account_Role_Detail__c station1 = [SELECT Id, Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c 
		WHERE Account_Contact_Role__r.Account_Role__c = :station1.Account_Role__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		Contact contact1 = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
		IGOM_Contact_Role_Detail__c role1 = [SELECT Id FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__r.Contact__c = :contactId LIMIT 1];

		delete role1;

		Test.startTest();
		try {
			IGOMCommunityUtil.deleteContactRoleDetail(station1.Id, contact1.Id);
		} catch (ListException e) {
			System.assertNotEquals(null, e.getMessage());
		}
		Test.stopTest();
	}

	/**
	 * @description Test the removeItemsFromListByField method with an existing and queried field for the Account Sobject.
	 */
	@isTest
	public static void removeItemsFromListByFieldTest_Success(){
		String fieldApiName = 'Id';
		Integer baseListNum = 10;
		Integer numToRemove = 3;

		// Generate a bunch of accs
		List<Account> accList = IGOMTestFactory.accountFactoryCreation(baseListNum);
		insert accList;

		Set<Id> accIdsToRemove = new Set<Id>();
		for(Integer i = 0; i < numToRemove; i++){
			accIdsToRemove.add((Id) accList.get(i).get(fieldApiName));
		}

		List<Account> accListNew;
		Test.startTest();
		accListNew = IGOMCommunityUtil.removeItemsFromListByField(accList, accIdsToRemove, fieldApiName);
		Test.stopTest();

		System.assertEquals(baseListNum-numToRemove, accListNew.size());
	}

	/**
	 * @description Test the removeItemsFromListByField method with an existing but not queried field for the User Sobject.
	 */
	@isTest
	public static void removeItemsFromListByFieldTest_Error_NotQueried(){
		String fieldApiName = 'Name';
		Integer baseListNum = 10;
		Integer numToRemove = 3;

		// Generate a bunch of accs
		List<Account> accList = IGOMTestFactory.accountFactoryCreation(baseListNum);
		insert accList;

		Set<Id> accIdsToRemove = new Set<Id>();
		Set<Id> accIds = new Set<Id>();
		for(Integer i = 0; i < numToRemove; i++){
			if (i < numToRemove) {
				accIdsToRemove.add(accList.get(i).Id);
			}
			accIds.add(accList.get(i).Id);
		}

		List<Account> accList_Temp = [SELECT Id FROM Account WHERE Id IN :accIds];

		List<Account> accListNew;
		Test.startTest();
		try {
			accListNew = IGOMCommunityUtil.removeItemsFromListByField(accList_Temp, accIdsToRemove, fieldApiName);
		} catch (SObjectException e) {
			System.assert(e.getMessage().contains('SObject row was retrieved via SOQL without querying the requested field'));
		}
		Test.stopTest();
	}

	/**
	 * @description Test the removeItemsFromListByField method with a non existing field for the Account Sobject.
	 */
	@isTest
	public static void removeItemsFromListByFieldTest_Error_NoExistent(){
		String fieldApiName = 'Non existent field';
		Integer baseListNum = 10;
		Integer numToRemove = 3;

		// Generate a bunch of accs
		List<Account> accList = IGOMTestFactory.accountFactoryCreation(baseListNum);
		insert accList;

		Set<Id> accIdsToRemove = new Set<Id>();
		Set<Id> accIds = new Set<Id>();
		for(Integer i = 0; i < numToRemove; i++){
			if (i < numToRemove) {
				accIdsToRemove.add(accList.get(i).Id);
			}
			accIds.add(accList.get(i).Id);
		}

		List<Account> accList_Temp = [SELECT Id FROM Account WHERE Id IN :accIds];

		List<Account> accListNew;
		Test.startTest();
		try {
			accListNew = IGOMCommunityUtil.removeItemsFromListByField(accList_Temp, accIdsToRemove, fieldApiName);
		} catch (SObjectException e) {
			System.assert(e.getMessage().contains('Invalid field'));
		}
		Test.stopTest();
	}
}