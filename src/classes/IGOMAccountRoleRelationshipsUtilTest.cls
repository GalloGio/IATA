@isTest
private class IGOMAccountRoleRelationshipsUtilTest
{
	private static final String STATION_TYPE_AIRLINE = IGOMConstants.STATION.TYPE.AIRLINE;
	private static final String STATION_TYPE_GH = IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ;

	/**
	 * @description Test getAllRelationshipsTest in a wide scenario
	 */
	@isTest
	private static void getAllRelationshipsTest()
	{
		/**
		 * The following relationship is being created:
		 *			 	Airline 1 -> Ground handler 1
		 *					^
		 * 					|
		 * Airline 4-> Airline 2 ->  Ground handler 2
		 * 			 			 |-> Ground handler 3 --> Ground handler 5 -->  Ground handler 6 -->  Ground handler 7
		 * 								   |
		 * 								   | (Gh 3 -> Gh 4)
		 * Airline 3 -> Ground handler 4 <-
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(4, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);
		List<SObject> airlineStation3 = airlinesStations.get(2);
		List<SObject> airlineStation4 = airlinesStations.get(3);

		List<List<SObject>> ghStations = IGOMTestFactory.generateIGOMUserFactory(7, IGOMConstants.ROLES.ADMIN, STATION_TYPE_GH);
		List<SObject> ghStation1 = ghStations.get(0);
		List<SObject> ghStation2 = ghStations.get(1);
		List<SObject> ghStation3 = ghStations.get(2);
		List<SObject> ghStation4 = ghStations.get(3);
		List<SObject> ghStation5 = ghStations.get(4);
		List<SObject> ghStation6 = ghStations.get(5);
		List<SObject> ghStation7 = ghStations.get(6);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);
		IGOM_Account_Role_Detail__c airline3 = (IGOM_Account_Role_Detail__c) airlineStation3.get(5);
		IGOM_Account_Role_Detail__c airline4 = (IGOM_Account_Role_Detail__c) airlineStation4.get(5);

		IGOM_Account_Role_Detail__c gh1 = (IGOM_Account_Role_Detail__c) ghStation1.get(5);
		IGOM_Account_Role_Detail__c gh2 = (IGOM_Account_Role_Detail__c) ghStation2.get(5);
		IGOM_Account_Role_Detail__c gh3 = (IGOM_Account_Role_Detail__c) ghStation3.get(5);
		IGOM_Account_Role_Detail__c gh4 = (IGOM_Account_Role_Detail__c) ghStation4.get(5);
		IGOM_Account_Role_Detail__c gh5 = (IGOM_Account_Role_Detail__c) ghStation5.get(5);
		IGOM_Account_Role_Detail__c gh6 = (IGOM_Account_Role_Detail__c) ghStation6.get(5);
		IGOM_Account_Role_Detail__c gh7 = (IGOM_Account_Role_Detail__c) ghStation7.get(5);

		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, gh1.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline4.Id, airline2.Id, airline4.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, gh2.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, gh3.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline3.Id, gh4.Id, airline3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(gh3.Id, gh5.Id, gh3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(gh5.Id, gh6.Id, gh5.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(gh6.Id, gh7.Id, gh6.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(gh3.Id, gh4.Id, gh3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		insert relationships;

		IGOMAccountRoleRelationshipsUtil.AllRelationships gh3Relations;
		Test.startTest();
		gh3Relations = IGOMAccountRoleRelationshipsUtil.getAllRelationships(gh3.Id);
		Test.stopTest();

		System.assertEquals(2, gh3Relations.parentStations.size());
		System.assertEquals(3, gh3Relations.childStations.size());
		System.assertEquals(1, gh3Relations.groupStations.size());
	}

	/**
	 * @description Test requestStationRelationship between two airlines that are related via a group
	 */
	@isTest
	private static void requestStationRelationshipTest_AirlineGroup()
	{
		List<List<SObject>> objectsStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> objectsStation1 = objectsStations.get(0);
		List<SObject> objectsStation2 = objectsStations.get(1);

		IGOM_Account_Role_Detail__c station1 = (IGOM_Account_Role_Detail__c) objectsStation1.get(5);
		IGOM_Account_Role_Detail__c station2 = (IGOM_Account_Role_Detail__c) objectsStation2.get(5);

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		System.runAs(user){
			IGOMAccountRoleRelationshipsUtil.requestStationRelationship(IGOMConstants.STATION.RELATIONSHIP_TYPE.GROVP, station1.Id, station2.Id, false);
		}
		Test.stopTest();

		List<IGOM_Account_Role_Relationship__c> relationshipList = [SELECT Id, From__c, To__c, Requested_By__c, Status__c, Type__c FROM IGOM_Account_Role_Relationship__c
		WHERE From__c = :station1.Id AND To__c = :station2.Id];
		System.assertEquals(1, relationshipList.size());
		System.assertEquals(IGOMConstants.STATION.STATUS.PENDING, relationshipList.get(0).Status__c);
		System.assertEquals(IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, relationshipList.get(0).Type__c);
	}

	/**
	 * @description Test requestStationRelationship between an airline and a gh that are related via a hierarchical relationship
	 */
	@isTest
	private static void requestStationRelationshipTest_AirlineGhHierarchy()
	{
		List<SObject> objectsStation1 = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE).get(0);
		List<SObject> objectsStation2 = IGOMTestFactory.generateIGOMUserFactory(1, IGOMConstants.ROLES.ADMIN, STATION_TYPE_GH).get(0);

		IGOM_Account_Role_Detail__c station1 = (IGOM_Account_Role_Detail__c) objectsStation1.get(5);
		IGOM_Account_Role_Detail__c station2 = (IGOM_Account_Role_Detail__c) objectsStation2.get(5);

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		System.runAs(user){
			IGOMAccountRoleRelationshipsUtil.requestStationRelationship(IGOMConstants.STATION.RELATIONSHIP_TYPE.CHILD, station1.Id, station2.Id, false);
		}
		Test.stopTest();

		List<IGOM_Account_Role_Relationship__c> relationshipList = [SELECT Id, From__c, To__c, Requested_By__c, Status__c, Type__c FROM IGOM_Account_Role_Relationship__c
		WHERE From__c = :station1.Id AND To__c = :station2.Id];
		System.assertEquals(1, relationshipList.size());
		System.assertEquals(IGOMConstants.STATION.STATUS.PENDING, relationshipList.get(0).Status__c);
		System.assertEquals(IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, relationshipList.get(0).Type__c);
	}

	/**
	 * @description Test requestStationRelationship between two ghs that are related via a group
	 */
	@isTest
	private static void requestStationRelationshipTest_GhGroup()
	{
		List<List<SObject>> objectsStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, STATION_TYPE_GH);
		List<SObject> objectsStation1 = objectsStations.get(0);
		List<SObject> objectsStation2 = objectsStations.get(1);

		IGOM_Account_Role_Detail__c station1 = (IGOM_Account_Role_Detail__c) objectsStation1.get(5);
		IGOM_Account_Role_Detail__c station2 = (IGOM_Account_Role_Detail__c) objectsStation2.get(5);

		Id contactId = [SELECT Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c LIMIT 1].Account_Contact_Role__r.Contact__c;
		User user = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
		Test.startTest();
		System.runAs(user){
			IGOMAccountRoleRelationshipsUtil.requestStationRelationship(IGOMConstants.STATION.RELATIONSHIP_TYPE.GROVP, station1.Id, station2.Id, false);
		}
		Test.stopTest();

		List<IGOM_Account_Role_Relationship__c> relationshipList = [SELECT Id, From__c, To__c, Requested_By__c, Status__c, Type__c FROM IGOM_Account_Role_Relationship__c
		WHERE From__c = :station1.Id AND To__c = :station2.Id];
		System.assertEquals(1, relationshipList.size());
		System.assertEquals(IGOMConstants.STATION.STATUS.PENDING, relationshipList.get(0).Status__c);
		System.assertEquals(IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, relationshipList.get(0).Type__c);
	}

	/**
	 * @description Test the getUnrelatedStations method with an empty search string
	 */
	@isTest
	private static void getUnrelatedStationsTest_EmptySearch()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -> Ground handler 1
		 *  ^
		 *  |
		 * Airline 2 ->  Ground handler 2
		 * 			 |-> Ground handler 3 -
		 * 								   | (Gh 3 -> Gh 4)
		 * Airline 3 -> Ground handler 4 <-
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(3, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);
		List<SObject> airlineStation3 = airlinesStations.get(2);

		List<List<SObject>> ghStations = IGOMTestFactory.generateIGOMUserFactory(4, IGOMConstants.ROLES.ADMIN, STATION_TYPE_GH);
		List<SObject> ghStation1 = ghStations.get(0);
		List<SObject> ghStation2 = ghStations.get(1);
		List<SObject> ghStation3 = ghStations.get(2);
		List<SObject> ghStation4 = ghStations.get(3);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);
		IGOM_Account_Role_Detail__c airline3 = (IGOM_Account_Role_Detail__c) airlineStation3.get(5);

		IGOM_Account_Role_Detail__c gh1 = (IGOM_Account_Role_Detail__c) ghStation1.get(5);
		IGOM_Account_Role_Detail__c gh2 = (IGOM_Account_Role_Detail__c) ghStation2.get(5);
		IGOM_Account_Role_Detail__c gh3 = (IGOM_Account_Role_Detail__c) ghStation3.get(5);
		IGOM_Account_Role_Detail__c gh4 = (IGOM_Account_Role_Detail__c) ghStation4.get(5);

		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, gh1.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, gh2.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, gh3.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline3.Id, gh4.Id, airline3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(gh3.Id, gh4.Id, gh3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		insert relationships;

		IGOMAccountRoleRelationshipsUtil.AllRelationships airline2Relations = IGOMAccountRoleRelationshipsUtil.getAllRelationships(airline2.Id);
		List<Id> relatedStations = new List<Id>();
		for (IGOMStationUtil.RelatedStation pStation : airline2Relations.parentStations) {
			relatedStations.add(pStation.stationInfo.id);
		}
		for (IGOMStationUtil.RelatedStation cStation : airline2Relations.childStations) {
			relatedStations.add(cStation.stationInfo.id);
		}
		for (IGOMStationUtil.RelatedStation gStation : airline2Relations.groupStations) {
			relatedStations.add(gStation.stationInfo.id);
		}

		List<IGOMStationUtil.RelatedStation> unrelatedStations = new List<IGOMStationUtil.RelatedStation>();
		Test.startTest();
		unrelatedStations = IGOMAccountRoleRelationshipsUtil.getUnrelatedStations(new Set<Id>(relatedStations), airline2.Id, '');
		Test.stopTest();

		System.assertEquals(3, unrelatedStations.size());
	}

	/**
	 * @description Test the getUnrelatedStations method with a search string
	 */
	@isTest
	private static void getUnrelatedStationsTest_WithSearch()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -> Ground handler 1
		 *  ^
		 *  |
		 * Airline 2 ->  Ground handler 2
		 * 			 |-> Ground handler 3 -
		 * 								   | (Gh 3 -> Gh 4)
		 * Airline 3 -> Ground handler 4 <-
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(3, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);
		List<SObject> airlineStation3 = airlinesStations.get(2);

		List<List<SObject>> ghStations = IGOMTestFactory.generateIGOMUserFactory(4, IGOMConstants.ROLES.ADMIN, STATION_TYPE_GH);
		List<SObject> ghStation1 = ghStations.get(0);
		List<SObject> ghStation2 = ghStations.get(1);
		List<SObject> ghStation3 = ghStations.get(2);
		List<SObject> ghStation4 = ghStations.get(3);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);
		IGOM_Account_Role_Detail__c airline3 = (IGOM_Account_Role_Detail__c) airlineStation3.get(5);

		IGOM_Account_Role_Detail__c gh1 = (IGOM_Account_Role_Detail__c) ghStation1.get(5);
		IGOM_Account_Role_Detail__c gh2 = (IGOM_Account_Role_Detail__c) ghStation2.get(5);
		IGOM_Account_Role_Detail__c gh3 = (IGOM_Account_Role_Detail__c) ghStation3.get(5);
		IGOM_Account_Role_Detail__c gh4 = (IGOM_Account_Role_Detail__c) ghStation4.get(5);

		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, gh1.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, gh2.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, gh3.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline3.Id, gh4.Id, airline3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(gh3.Id, gh4.Id, gh3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		insert relationships;

		IGOMAccountRoleRelationshipsUtil.AllRelationships airline2Relations = IGOMAccountRoleRelationshipsUtil.getAllRelationships(airline2.Id);
		List<Id> relatedStations = new List<Id>();
		for (IGOMStationUtil.RelatedStation pStation : airline2Relations.parentStations) {
			relatedStations.add(pStation.stationInfo.id);
		}
		for (IGOMStationUtil.RelatedStation cStation : airline2Relations.childStations) {
			relatedStations.add(cStation.stationInfo.id);
		}
		for (IGOMStationUtil.RelatedStation gStation : airline2Relations.groupStations) {
			relatedStations.add(gStation.stationInfo.id);
		}

		List<IGOMStationUtil.RelatedStation> unrelatedStations = new List<IGOMStationUtil.RelatedStation>();
		Test.startTest();
		unrelatedStations = IGOMAccountRoleRelationshipsUtil.getUnrelatedStations(new Set<Id>(relatedStations), airline2.Id, 'Test name 3');
		Test.stopTest();

		System.assertEquals(1, unrelatedStations.size());
	}

	/**
	 * @description Test the getUnrelatedStations method when there is
	 */
	@isTest
	private static void getUnrelatedStationsTest_PendingStation()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -> Ground handler 1
		 *  ^
		 *  | Still pending
		 * Airline 2 ->  Ground handler 2
		 * 			 |-> Ground handler 3 -
		 * 								   | (Gh 3 -> Gh 4)
		 * Airline 3 -> Ground handler 4 <-
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(3, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);
		List<SObject> airlineStation3 = airlinesStations.get(2);

		List<List<SObject>> ghStations = IGOMTestFactory.generateIGOMUserFactory(4, IGOMConstants.ROLES.ADMIN, STATION_TYPE_GH);
		List<SObject> ghStation1 = ghStations.get(0);
		List<SObject> ghStation2 = ghStations.get(1);
		List<SObject> ghStation3 = ghStations.get(2);
		List<SObject> ghStation4 = ghStations.get(3);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);
		IGOM_Account_Role_Detail__c airline3 = (IGOM_Account_Role_Detail__c) airlineStation3.get(5);

		IGOM_Account_Role_Detail__c gh1 = (IGOM_Account_Role_Detail__c) ghStation1.get(5);
		IGOM_Account_Role_Detail__c gh2 = (IGOM_Account_Role_Detail__c) ghStation2.get(5);
		IGOM_Account_Role_Detail__c gh3 = (IGOM_Account_Role_Detail__c) ghStation3.get(5);
		IGOM_Account_Role_Detail__c gh4 = (IGOM_Account_Role_Detail__c) ghStation4.get(5);

		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, gh1.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.PENDING));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, gh2.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, gh3.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline3.Id, gh4.Id, airline3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(gh3.Id, gh4.Id, gh3.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE));

		insert relationships;

		IGOMAccountRoleRelationshipsUtil.AllRelationships airline2Relations = IGOMAccountRoleRelationshipsUtil.getAllRelationships(airline2.Id);
		List<Id> relatedStations = new List<Id>();
		for (IGOMStationUtil.RelatedStation pStation : airline2Relations.parentStations) {
			relatedStations.add(pStation.stationInfo.id);
		}
		for (IGOMStationUtil.RelatedStation cStation : airline2Relations.childStations) {
			relatedStations.add(cStation.stationInfo.id);
		}
		for (IGOMStationUtil.RelatedStation gStation : airline2Relations.groupStations) {
			relatedStations.add(gStation.stationInfo.id);
		}

		List<IGOMStationUtil.RelatedStation> unrelatedStations = new List<IGOMStationUtil.RelatedStation>();
		Test.startTest();
		unrelatedStations = IGOMAccountRoleRelationshipsUtil.getUnrelatedStations(new Set<Id>(relatedStations), airline2.Id, '');
		Test.stopTest();

		System.assertEquals(4, unrelatedStations.size());
	}

	/**
	 * @description Test the getRelationshipBetweenStations method when a relationship exists between two stations.
	 */
	@isTest
	private static void getRelationshipBetweenStationsTest_RelationshipExists()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -> Airline 2
		 */
		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);

		insert IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.PENDING);

		IGOM_Account_Role_Relationship__c rel;
		Test.startTest();
		rel = IGOMAccountRoleRelationshipsUtil.getRelationshipBetweenStations(airline1.Id, airline2.Id);
		Test.stopTest();

		System.assertNotEquals(null, rel);
	}

	/**
	 * @description Test the getRelationshipBetweenStations method when multiple pending relationship exist between two stations.
	 */
	@isTest
	private static void getRelationshipBetweenStationsTest_RelationshipExists_Multiple_Success()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -Multiple relationships of all kind- Airline 2
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);

		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.PENDING));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, airline1.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.PENDING));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.PENDING));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, airline1.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.PENDING));

		insert relationships;

		IGOM_Account_Role_Relationship__c rel;
		Test.startTest();
		rel = IGOMAccountRoleRelationshipsUtil.getRelationshipBetweenStations(airline1.Id, airline2.Id);
		Test.stopTest();

		System.assertNotEquals(null, rel);
		List<IGOM_Account_Role_Relationship__c> relationshipsNew = [SELECT Id FROM IGOM_Account_Role_Relationship__c WHERE Id != :rel.Id];
		System.assertEquals(0, relationshipsNew.size());
	}

	/**
	 * @description Test the getRelationshipBetweenStations method when multiple pending relationship exist between two stations.
	 */
	@isTest
	private static void getRelationshipBetweenStationsTest_RelationshipExists_Multiple_Error()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -Multiple relationships of all kind- Airline 2
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);

		List<IGOM_Account_Role_Relationship__c> relationships = new List<IGOM_Account_Role_Relationship__c>();
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.PENDING));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, airline1.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.PENDING));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.HIERARCHICAL_REL, IGOMConstants.STATION.STATUS.ACTIVE));
		relationships.add(IGOMTestFactory.createIGOMAccountRoleRelationship(airline2.Id, airline1.Id, airline2.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.PENDING));

		IGOM_Account_Role_Relationship__c rel;
		Test.startTest();
		try {
			rel = IGOMAccountRoleRelationshipsUtil.getRelationshipBetweenStations(airline1.Id, airline2.Id);
		} catch (IGOMAccountRoleRelationshipsUtil.AccountRoleRelationshipServiceException exc) {
			System.assert(exc.getMessage().contains(IGOMConstants.ERRORS.RELATIONSHIP_ALREADY_EXISTS_ERROR));
		}
		Test.stopTest();
	}

	/**
	 * @description Test the getRelationshipBetweenStations method when no relationship exists between two stations.
	 */
	@isTest
	private static void getRelationshipBetweenStationsTest_NoRelationship()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -> Airline 2
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);

		IGOM_Account_Role_Relationship__c rel;
		Test.startTest();
		rel = IGOMAccountRoleRelationshipsUtil.getRelationshipBetweenStations(airline1.Id, airline2.Id);
		Test.stopTest();

		System.assertEquals(null, rel);
	}

	/**
	 * @description Test the deleteRelationship method.
	 */
	@isTest
	private static void deleteRelationshipTest()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -> Airline 2
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);

		IGOM_Account_Role_Relationship__c rel = IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline1.Id, true, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.ACTIVE);
		insert rel;

		Test.startTest();
		IGOMAccountRoleRelationshipsUtil.deleteRelationship(rel.Id);
		Test.stopTest();

		List<IGOM_Account_Role_Relationship__c> rels = [SELECT Id FROM IGOM_Account_Role_Relationship__c WHERE From__c = :airline1.Id AND To__c = :airline2.Id];
		System.assertEquals(0, rels.size());
	}

	/**
	 * @description Test the updateRelationshipStatus method.
	 */
	@isTest
	private static void updateRelationshipStatusTest()
	{
		/**
		 * The following relationship is being created:
		 * Airline 1 -> Airline 2
		 */

		List<List<SObject>> airlinesStations = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, STATION_TYPE_AIRLINE);
		List<SObject> airlineStation1 = airlinesStations.get(0);
		List<SObject> airlineStation2 = airlinesStations.get(1);

		IGOM_Account_Role_Detail__c airline1 = (IGOM_Account_Role_Detail__c) airlineStation1.get(5);
		IGOM_Account_Role_Detail__c airline2 = (IGOM_Account_Role_Detail__c) airlineStation2.get(5);

		IGOM_Account_Role_Relationship__c rel = IGOMTestFactory.createIGOMAccountRoleRelationship(airline1.Id, airline2.Id, airline1.Id, false, IGOMConstants.STATION.RELATIONSHIP_TYPE.GROUP_REL, IGOMConstants.STATION.STATUS.PENDING);
		insert rel;

		Test.startTest();
		IGOMAccountRoleRelationshipsUtil.updateRelationshipStatus(rel.Id, IGOMConstants.STATION.STATUS.ACTIVE, true);
		Test.stopTest();

		IGOM_Account_Role_Relationship__c relNew = [SELECT Id, Status__c, Accepts_Notifications__c FROM IGOM_Account_Role_Relationship__c WHERE From__c = :airline1.Id AND To__c = :airline2.Id LIMIT 1];
		System.assertEquals(true, relNew.Accepts_Notifications__c);
		System.assertEquals(IGOMConstants.STATION.STATUS.ACTIVE, relNew.Status__c);
	}
}