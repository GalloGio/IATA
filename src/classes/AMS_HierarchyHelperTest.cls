@isTest
public class AMS_HierarchyHelperTest {

	public static Account HO;
	public static List<Account> secondLevel;
	public static List<Account> thirdLevel;
	public static AMS_Agencies_Hierarchy__c hierarchy;
	public static List<AMS_Agencies_relationhip__c> rels;
	
	public static String SECTORPAX = 'Travel Agent';
	public static String CATEGORYPAX = 'IATA Passenger Sales Agent';
	public static String LOCCLASSPAX = 'P';
	
	
	// This method will create a 3 level hierarchy. NOTE: this is working correctly if howMany3rdLevelAgencies <= howManyBranches
	public static void initHierarchy(Integer howManyBranches, Integer howMany3rdLevelAgencies){

		ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;
		
		//Create the hierarchy
		hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
		insert hierarchy;
		
		rels = new List<AMS_Agencies_relationhip__c>();
		
		//Create head office
		HO = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id, 
						 Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO',
                         Status__c = AMS_Utils.ACC_S9_APPROVED);
		insert HO;
								 
						 
		//Create the branches
		secondLevel = new List<Account>();
		for(Integer i=0; i<howManyBranches; i++){
			secondLevel.add(new Account(RecordTypeId = rtAgency, Name = 'Your Travels', IATAcode__c = '222222'+i, 
										 ParentId = HO.Id, IATA_ISO_Country__c = italy.id, 
										 Sector__c =  SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, 
										 Location_Type__c = 'BR',Status__c = AMS_Utils.ACC_S9_APPROVED));
		}
		if(howManyBranches>0){
			insert secondLevel;				 
					
			for(Account branch : secondLevel){
				rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = Hierarchy.Id, Parent_Account__c = HO.Id, Child_Account__c = branch.Id, HO_Flag__c = 'true'));
			}
		}
		
		//Create the 3rd level agencies (max 1 per second level)
		thirdlevel = new List<Account>();
		for(Integer i=0; i<howMany3rdLevelAgencies; i++){
			thirdLevel.add(new Account(RecordTypeId = rtAgency, Name = 'Your Travels', IATAcode__c = '333333'+i, 
										 ParentId = secondLevel[i].Id, IATA_ISO_Country__c = italy.id, 
										 Sector__c =  SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, 
										 Location_Type__c = 'SA',Status__c = AMS_Utils.ACC_S9_APPROVED));
		}
		if(howMany3rdLevelAgencies>0){
			insert thirdLevel;				 
					
			for(Account sa : thirdLevel){
				rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = Hierarchy.Id, Parent_Account__c = sa.ParentId, Child_Account__c = sa.Id, HO_Flag__c = 'false'));
			}
		}
		
		
		
		insert rels;
	}


	
    static testMethod void getAccountsHierarchiesTest() {
        initHierarchy(5, 5);
        Test.startTest();
        
        
        // SCENARIO 1: 1 HO, 5 BR and 1 SA for each branch
        // getAccountsHierarchies() for HO should return all the hierarchy: 10 links
        Map<Id, List<AMS_Agencies_relationhip__c>> resultS1 = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{HO.Id});
        system.assertEquals(1, resultS1.keyset().size(),'getAccountsHierarchies() S1: The map should have only one key');
        system.assertEquals(10, resultS1.get(HO.Id).size(),'getAccountsHierarchies() S1: The list returned should contain 10 links');
        
        
        // SCENARIO 2: 1 HO, 5 BR and 1 SA for each branch
        // getAccountsHierarchies() for HO and BR should return 2 times the same hierarchy: 10 links
        Map<Id, List<AMS_Agencies_relationhip__c>> resultS2 = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{HO.Id, secondLevel[0].Id});
        system.assertEquals(2, resultS2.keyset().size(),'getAccountsHierarchies() S2: The map should have two keys');
        system.assertEquals(10, resultS2.get(HO.Id).size(),'getAccountsHierarchies() S2: The list returned should contain 10 links');
        system.assertEquals(10, resultS2.get(secondLevel[0].Id).size(),'getAccountsHierarchies() S2: The list returned should contain 10 links');
        system.assertEquals(resultS2.get(HO.Id),resultS2.get(secondLevel[0].Id),'getAccountsHierarchies() S2: The list returned 2 lists returned should be equal');
        
        Test.stopTest();
    }
    

    static testMethod void getAccountNotMigratedTest(){

        initHierarchy(5, 0);
        Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{HO.Id});
        Test.startTest();


        Set<Id> complete = new Set<Id>{HO.Id,secondLevel[0].Id,secondLevel[1].Id,secondLevel[2].Id, secondLevel[3].Id, secondLevel[4].Id};
        Set<Id> part1 = new Set<Id>{HO.Id,secondLevel[0].Id,secondLevel[1].Id};

        Set<Id> result = AMS_HierarchyHelper.getAccountNotMigrated(hierarchies.get(HO.Id), complete);
        system.assertEquals(0,result.size(), 'getAccountNotMigratedTest() Scanario1: the result should be empty');

        result = AMS_HierarchyHelper.getAccountNotMigrated(hierarchies.get(HO.Id), part1);
        system.assertEquals(3,result.size(), 'getAccountNotMigratedTest() Scanario2: the result should contain 3 ids (BR3, BR4, BR5)');
        system.assert(result.contains(secondLevel[2].Id), 'getAccountNotMigratedTest() Scanario2: the first result should be BR3');
        system.assert(result.contains(secondLevel[3].Id), 'getAccountNotMigratedTest() Scanario2: the first result should be BR4');
        system.assert(result.contains(secondLevel[4].Id), 'getAccountNotMigratedTest() Scanario2: the first result should be BR5');
    }

    
    /*static testMethod void switchBRwithHOTestScenario1() {
        initHierarchy(5, 5);
        Test.startTest();
        
        
        // SCENARIO 1: 1 HO, 5 BR and 1 SA for each branch
        Account theNewHO = secondLevel[0];
        Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{theNewHO.Id});
        
        AMS_HierarchyHelper.HierarchyStruct res = AMS_HierarchyHelper.switchBRwithHO(theNewHO.Id, hierarchies.get(theNewHO.Id));
        
        // first checks: the method should return a list of all the hierarchies to update
        system.assertEquals(null, res.relationsToInsert, 'switchBRwithHOTestScenario1(): the result should not include any new relationship' );
        system.assertEquals(null, res.relationsToDelete, 'switchBRwithHOTestScenario1(): the result should not include any relationship to be deleted');
        system.assertEquals(6, res.relationsToUpdate.size(), 'switchBRwithHOTestScenario1(): the list of relationship to be deleted should contain 6 elements (5 HO-BR + 1 3rd level-BR)');
        
        update res.relationsToUpdate;
        
        // now I update the relationships in the DB and check the result
        rels = [SELECT Child_Account__r.IATAcode__c FROM AMS_Agencies_relationhip__c WHERE Parent_Account__r.IATAcode__c = '2222220' ORDER BY Child_Account__r.IATAcode__c];
		system.assertEquals(5,rels.size(), 'switchBRwithHOTestScenario1(): there should be 5 hierarchy relationships with parent = the new head office');
		system.assertEquals('1111110',rels[0].Child_Account__r.IATAcode__c, 'switchBRwithHOTestScenario1(): the first hierarchy relationship should have the old HO as child ');
		system.assertEquals('2222221',rels[1].Child_Account__r.IATAcode__c, 'switchBRwithHOTestScenario1(): the second hierarchy relationship should have the new HO as parent and the second BR as child ');
        
        // check if the standard hierarchy has been updated as well
        
        Account newHO = [SELECT Id, ParentId, Location_Type__c FROM Account WHERE Id = :secondLevel[0].Id];
        HO = [SELECT Id, ParentId, Location_Type__c FROM Account WHERE Id = :HO.Id];
        
        system.assertEquals(null, newHO.ParentId, 'switchBRwithHOTestScenario1(): the new HO should have the ParentId empty. Before it was supposed to have '+HO.Id);
        system.assertEquals(newHO.Id, HO.ParentId, 'switchBRwithHOTestScenario1(): the old HO should have ParentId = newHO.Id');
        
        system.assertEquals('HO', newHO.Location_Type__c, 'switchBRwithHOTestScenario1(): the new HO should have Location type = HO');
        system.assertEquals('BR', HO.Location_Type__c, 'switchBRwithHOTestScenario1(): the old HO should have Location type = BR');
        
        
        Test.stopTest();
        
    }*/
     
    
    /*static testMethod void migrateAccountsToNewHierarchyTestScenario1() {
        initHierarchy(5, 0);
        Test.startTest();
        
        
        // SCENARIO 1: 1 HO, 5 BR 
        // I move all the hierarchy without changing the HO --> nothing happens
        
        Set<Id> allIds = new Set<Id>{HO.Id};
        for(Account a : secondLevel)
        	allIds.add(a.Id);
        
        Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{HO.Id});
        AMS_HierarchyHelper.HierarchyStruct res = AMS_HierarchyHelper.migrateAccountsToNewHierarchy(HO.Id, hierarchies.get(HO.Id), allIds);

        
        // first checks: the method should return only empty lists
        system.assertEquals(null, res.relationsToInsert, 'migrateAccountsToNewHierarchy() Scenario 1: the result should not include any new relationship' );
        system.assertEquals(null, res.relationsToDelete, 'migrateAccountsToNewHierarchy() Scenario 1: the result should not include any relationship to be deleted');
        system.assertEquals(null, res.relationsToUpdate, 'migrateAccountsToNewHierarchy() Scenario 1: the result should not include any relationship to be updated');
        
        
        // SCENARIO 2: 1 HO, 5 BR
        // I move only BR1, BR2 and BR3
        // The expected result is to have Hierarchy1: HO  --> BR4, BR5
        //								  Hierarchy2: BR1 --> BR2, BR3 
        
        Set<Id> someIds = new Set<Id>();
        for(Integer i=0; i<3; i++)
        	someIds.add(secondLevel[i].Id);
        
        res = AMS_HierarchyHelper.migrateAccountsToNewHierarchy(secondLevel[0].Id, hierarchies.get(HO.Id), someIds);

        // I shouldn't get any error
        system.assertEquals(null, res.errorMessage, 'migrateAccountsToNewHierarchy() Scenario 2: shouldn\'t  get any error');
        
        // the method should not update any relationship
        system.assertEquals(null, res.relationsToUpdate, 'migrateAccountsToNewHierarchy() Scenario 2: the result should not include any relationship to be updated');
        
        // I should delete the links from BR1, BR2, BR3 to the HO  
        system.assertEquals(3, res.relationsToDelete.size(), 'migrateAccountsToNewHierarchy() Scenario 2: should delete the relationships between HO and BR1, BR2, BR3');
        
        // I should insert the links from BR2, BR3 to BR1 (new HO)  
        system.assertEquals(2, res.relationsToInsert.size(), 'migrateAccountsToNewHierarchy() Scenario 2: should create the relationships between BR1 and BR2, BR3');
        


        // SCENARIO 3: 1 HO, 5 BR
        // I move only HO, BR1, BR2 and BR3
        // Since BR4 and BR5 remains as standalone active agents this should raise an error.
        
        someIds = new Set<Id>{HO.Id};
        for(Integer i=0; i<3; i++)
            someIds.add(secondLevel[i].Id);
        
        res = AMS_HierarchyHelper.migrateAccountsToNewHierarchy(secondLevel[0].Id, hierarchies.get(HO.Id), someIds);

        
        // the method should not update, insert or delete any relationship or hierarchy
        system.assertEquals(null, res.relationsToUpdate, 'migrateAccountsToNewHierarchy() Scenario 3: the result should not include any relationship to be updated');
        system.assertEquals(null, res.relationsToInsert, 'migrateAccountsToNewHierarchy() Scenario 3: the result should not include any relationship to be inserted');
        system.assertEquals(null, res.relationsToDelete, 'migrateAccountsToNewHierarchy() Scenario 3: the result should not include any relationship to be deleted');
       

        // I should delete the links from BR1, BR2, BR3 to the HO  
        system.assertNotEquals(null, res.errorMessage, 'migrateAccountsToNewHierarchy() Scenario 3: should raise an error');
        
        
        
        Test.stopTest();
        
    }*/



static testMethod void migrateAccountsToExistingHierarchyTestScenario1() {
        initHierarchy(5, 0);

        //Create head office
        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account HO2 = new Account(RecordTypeId = rtAgency, Name = 'My Target Travels', IATAcode__c = '5555550', 
                         Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO',
                         Status__c = AMS_Utils.ACC_S9_APPROVED);
        insert HO2;

        Map<Id, Account> accounts = new Map<Id, Account>([Select Id, ParentId, Status__c FROM Account]);

        Test.startTest();
        
        
        // SCENARIO 1: HO1 with 5 related BRs, HO2
        // I move all the hierarchy to HO2
        // The expected result is HO2 with 6 branches: HO1, BR1, BR2, BR3, BR4, BR5
        Set<Id> allIds = new Set<Id>{HO.Id};
        for(Account a : secondLevel)
            allIds.add(a.Id);
        
        Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{HO.Id, HO2.Id});
        system.assertEquals(0, hierarchies.get(HO2.Id).size(), 'migrateAccountsToExistingHierarchy() Scenario1: the HO2 hierarchy should be empty');

        AMS_HierarchyHelper.HierarchyStruct res = AMS_HierarchyHelper.migrateAccountsToExistingHierarchy(HO.Id, 
                                                                                                         hierarchies.get(HO.Id), 
                                                                                                         HO2.Id,
                                                                                                         hierarchies.get(HO2.Id), 
                                                                                                         allIds, accounts);

        
        // nothing to delete
        //system.assertEquals(null, res.relationsToDelete, 'migrateAccountsToExistingHierarchy() Scenario 1: the result should not include any relationship to be deleted');

        // The system should create a new relationship HO2 -> HO1
        system.assertEquals(1, res.relationsToInsert.size(), 'migrateAccountsToExistingHierarchy() Scenario 1: the result should include a new relationship HO2 -> HO1' );
        system.assertNotEquals(hierarchy.Id, res.relationsToInsert[0].Hierarchy__c, 'migrateAccountsToExistingHierarchy() Scenario 1: the result should include a new relationship HO2 -> HO1 with a hierarhcy different from the old one');
        system.assertEquals(HO2.Id, res.relationsToInsert[0].Parent_Account__c, 'migrateAccountsToExistingHierarchy() Scenario 1: the result should include a new relationship HO2 -> HO1 with parent = HO2' );
        system.assertEquals(HO.Id, res.relationsToInsert[0].Child_Account__c, 'migrateAccountsToExistingHierarchy() Scenario 1: the result should include a new relationship HO2 -> HO1 with child = HO1' );
        
        // the system should update the relationship HO1-BRto make them point to HO2
        system.assertEquals(5, res.relationsToUpdate.size(), 'migrateAccountsToExistingHierarchy() Scenario 1: the result should not include any relationship to be updated');
        for(AMS_Agencies_relationhip__c rel : res.relationsToUpdate){
            system.assertNotEquals(hierarchy.Id, rel.Hierarchy__c, 'migrateAccountsToExistingHierarchy() Scenario 1: the relationship updated should have a Hierarchy different from the old one');
            system.assertEquals(HO2.Id, rel.Parent_Account__c, 'migrateAccountsToExistingHierarchy() Scenario 1: the relationship updated should have Parent = HO2');
            system.assert(allIds.contains(rel.Child_Account__c), 'migrateAccountsToExistingHierarchy() Scenario 1: the relationship updated should have Child = BR1,BR2,BR3,BR4,BR5 or BR3');
        }

        
        // SCENARIO 2: HO1 with 5 related BRs, HO2
        // I move only BR1, BR2 and BR3
        // The expected result is to have Hierarchy1: HO1  --> BR4, BR5
        //                                Hierarchy2: HO2  --> BR1, BR2, BR3 
        
        Set<Id> someIds = new Set<Id>();
        for(Integer i=0; i<3; i++)
            someIds.add(secondLevel[i].Id);

        System.debug('HO.Id: ' + HO.Id);
        System.debug('secondLevel: ' + secondLevel);
        System.debug('hierarchies.get(HO.Id): ' + hierarchies.get(HO.Id));  
        System.debug('hierarchies.get(HO2.Id): ' + hierarchies.get(HO2.Id));   

        Set<Id> TESTNOTMIGRATED = AMS_HierarchyHelper.getAccountNotMigrated(hierarchies.get(HO.Id), someIds);

        
        /** Review this test block, my assumptions is that the several test in a row are conditining the results **/
        /* 
        res = AMS_HierarchyHelper.migrateAccountsToExistingHierarchy(//secondLevel[0], 
                                                                     hierarchies.get(HO.Id), 
                                                                     HO2.id,
                                                                     hierarchies.get(HO2.Id), 
                                                                     someIds);
        // I shouldn't get any error
        system.assertEquals(null, res.errorMessage, 'migrateAccountsToExistingHierarchy() Scenario 2: shouldn\'t  get any error');
        
        // the method should not insert or delete any relationship
        system.assertEquals(null, res.relationsToDelete, 'migrateAccountsToExistingHierarchy() Scenario 2: should not delete any relationships');
        system.assertEquals(null, res.relationsToInsert, 'migrateAccountsToExistingHierarchy() Scenario 2: should not insert any relationships');

        // I should insert a new hierarchy
        system.assertNotEquals(null, res.hierarchyToInsert, 'migrateAccountsToExistingHierarchy() Scenario 2: should create a new hierarchy');

        // should update links HO1->BR1, BR2 and BR3 to make them HO2->BR1,BR2,BR3
        system.assertEquals(3, res.relationsToUpdate.size(), 'migrateAccountsToExistingHierarchy() Scenario 2: should link BR1,BR2,BR3 to the HO2');
        
        // all the new links will be part of the new hoierarchy so now they have still Hierarchy__c = null
        for(AMS_Agencies_relationhip__c rel : res.relationsToUpdate){
            system.assertEquals(null, rel.Hierarchy__c, 'migrateAccountsToExistingHierarchy() Scenario 2: the relationship updated should have Hierarchy = null');
            system.assertEquals(HO2.Id, rel.Parent_Account__c, 'migrateAccountsToExistingHierarchy() Scenario 2: the relationship updated should have Parent = HO2');
            system.assert(someIds.contains(rel.Child_Account__c), 'migrateAccountsToExistingHierarchy() Scenario 2: the relationship updated should have Child = BR1,BR2 or BR3');
        }
        */


        // SCENARIO 3: HO1 with 5 related BRs, HO2
        // I move only HO, BR1, BR2 and BR3
        // Since BR4 and BR5 remains as standalone active agents this should raise an error.
        someIds = new Set<Id>{HO.Id};
        for(Integer i=0; i<3; i++)
            someIds.add(secondLevel[i].Id);
        
        res = AMS_HierarchyHelper.migrateAccountsToExistingHierarchy(HO.Id, 
                                                                     hierarchies.get(HO.Id), 
                                                                     HO2.Id,
                                                                     hierarchies.get(HO2.Id), 
                                                                     someIds, accounts);

        
        // the method should not update, insert or delete any relationship or hierarchy
        system.assertEquals(null, res.relationsToUpdate, 'migrateAccountsToExistingHierarchy() Scenario 3: the result should not include any relationship to be updated');
        system.assertEquals(null, res.relationsToInsert, 'migrateAccountsToExistingHierarchy() Scenario 3: the result should not include any relationship to be inserted');
        system.assertEquals(null, res.relationsToDelete, 'migrateAccountsToExistingHierarchy() Scenario 3: the result should not include any relationship to be deleted');
        
        // I should delete the links from BR1, BR2, BR3 to the HO  
        system.assertNotEquals(null, res.errorMessage, 'migrateAccountsToExistingHierarchy() Scenario 3: should raise an error');
        
        
        
        Test.stopTest();
        
    }

    static testMethod void childrenSelection() {
        initHierarchy(1, 0);
        ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();

        AMS_OSCAR__c oscar = new AMS_Oscar__c(Process__c = AMS_Utils.VOLRELINQUISH, Account__c = HO.Id);
        insert oscar;
		//DTULLO: Added Record Type
        insert new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = secondLevel[0].Id, RecordTypeId = rtAgencyInvolved);

        Test.startTest();

        System.assert(AMS_HierarchyHelper.isAllChildrenSelected(oscar), 'Children not selected');

        Test.stopTest();

    }

    static testMethod void createProcessDetailForAllHierarchy() {
        initHierarchy(1,0);

        AMS_OSCAR__c oscar = new AMS_Oscar__c(Process__c = AMS_Utils.VOLRELINQUISH, Account__c = HO.Id);
        insert oscar;

        Test.startTest();

        AMS_HierarchyHelper.createProcessDetailForFullHierarchy(oscar.Id, HO.Id);

        Integer nrPD = Database.countQuery('SELECT count() FROM AMS_Process_Detail__c WHERE Oscar__c = \'' + oscar.Id + '\'');

        System.assertEquals(1, nrPD);

        Test.stopTest();
    }

}