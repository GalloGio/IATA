@isTest
private class ANG_ConversionHelperOfficialTest {
	
	@isTest static void ANG_ConversionHelperEnhancedTestTest1() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='HIERARCHY1 Agency BR1 OK',Short_Name__c='HIERARCHY1 Agency BR1 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='HIERARCHY1 Agency BR2 OK',Short_Name__c='HIERARCHY1 Agency BR2 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S4_LISTED);
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='HIERARCHY1 Agency SA1 OK',Short_Name__c='HIERARCHY1 Agency SA1 OK', Sector__c = 'Travel Agent',  Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING);
         
		insert new List<Account>{a2,a3,a4};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		// 2 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);

        insert new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest1] Printing Statistics before migration');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.debug('[ANG_ConversionHelperEnhancedTestTest1] Finish Printing Statistics before migration');

    	Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> newStructure = ANG_ConversionHelper.buildHierarchyStructure('US');

		newStructure = ANG_ConversionHelper.performValidationOnHierarchyStructure(newStructure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStructNew = ANG_ConversionHelper.fetchStatistics(newStructure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest1] Printing Statistics after migration');

		ANG_ConversionHelper.printStatistics(finalStructNew);

		System.debug('[ANG_ConversionHelperEnhancedTestTest1] Finish  Printing Statistics after migration');

		List<Account> accounts = [SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account];
		List<AMS_Agencies_Hierarchy__c> hierarchies = [SELECT Id, Name, Migrated__c FROM AMS_Agencies_Hierarchy__c];
		List<AMS_Agencies_relationhip__c> relations = [SELECT Id, Parent_Account__c, Child_Account__c, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('[ANG_ConversionHelperEnhancedTestTest1] Accounts:'+accounts);
		System.debug('[ANG_ConversionHelperEnhancedTestTest1] hierarchies:'+hierarchies);
		System.debug('[ANG_ConversionHelperEnhancedTestTest1] relations:'+relations);

		Map<String,Account> accountsMap = new Map<String,Account>();
		for(Account acc: accounts)
			accountsMap.put(acc.Name,acc);

		System.assertEquals('HE',accountsMap.get('Agency HO').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('HIERARCHY1 Agency BR2 OK').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('HIERARCHY1 Agency SA1 OK').Location_Type__c);

		System.assertEquals('P',accountsMap.get('Agency HO').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency BR2 OK').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency SA1 OK').Location_Class__c);

		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('Agency HO').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency BR1 OK').Status__c);
		System.assertEquals(AMS_Utils.ACC_S4_LISTED,accountsMap.get('HIERARCHY1 Agency BR2 OK').Status__c);
		System.assertEquals(AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING,accountsMap.get('HIERARCHY1 Agency SA1 OK').Status__c);

		System.assertEquals(null,accountsMap.get('Agency HO').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency BR1 OK').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency BR2 OK').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency SA1 OK').Top_Parent__c);

		System.assertEquals(null,accountsMap.get('Agency HO').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency BR1 OK').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency BR2 OK').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency SA1 OK').ParentId);

		System.assertEquals(1,hierarchies.size());
		System.assertEquals(3,relations.size());

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest2() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='HIERARCHY1 Agency BR1 OK',Short_Name__c='HIERARCHY1 Agency BR1 OK', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='HIERARCHY1 Agency BR2 OK',Short_Name__c='HIERARCHY1 Agency BR2 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='HIERARCHY1 Agency BR3 OK',Short_Name__c='HIERARCHY1 Agency BR3 OK', Sector__c = 'Travel Agent',  Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
         
		insert new List<Account>{a2,a3,a4};

		Account a5 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='SA',Name='HIERARCHY1 Agency SA1 OK',Short_Name__c='HIERARCHY1 Agency SA1 OK', Sector__c = 'Travel Agent',  Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert a5;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		// 2 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);

		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a5.Id);

        List<AMS_Agencies_relationhip__c> relationsToInsert = new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3, rel4};

        insert relationsToInsert;

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest2] Printing Statistics before migration');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.debug('[ANG_ConversionHelperEnhancedTestTest2] Finish Printing Statistics before migration');

		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> newStructure = ANG_ConversionHelper.buildHierarchyStructure('US');

		newStructure = ANG_ConversionHelper.performValidationOnHierarchyStructure(newStructure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStructNew = ANG_ConversionHelper.fetchStatistics(newStructure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest2] Printing Statistics after migration');

		ANG_ConversionHelper.printStatistics(finalStructNew);

		System.debug('[ANG_ConversionHelperEnhancedTestTest2] Finish  Printing Statistics after migration');

		List<Account> accounts = [SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account];
		List<AMS_Agencies_Hierarchy__c> hierarchies = [SELECT Id, Name, Migrated__c FROM AMS_Agencies_Hierarchy__c];
		List<AMS_Agencies_relationhip__c> relations = [SELECT Id, Parent_Account__c, Child_Account__c, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('[ANG_ConversionHelperEnhancedTestTest2] Accounts:'+accounts);
		System.debug('[ANG_ConversionHelperEnhancedTestTest2] hierarchies:'+hierarchies);
		System.debug('[ANG_ConversionHelperEnhancedTestTest2] relations:'+relations);

		Map<String,Account> accountsMap = new Map<String,Account>();
		for(Account acc: accounts)
			accountsMap.put(acc.Name,acc);

		System.assertEquals('HE',accountsMap.get('Agency HO').Location_Type__c);
		

		if(!((accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Type__c == 'HO' && accountsMap.get('HIERARCHY1 Agency BR3 OK').Location_Type__c == 'BR')||(accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Type__c == 'BR' && accountsMap.get('HIERARCHY1 Agency BR3 OK').Location_Type__c == 'HO'))){
			System.assertEquals(true,false);
		}

		//System.assertEquals('HO',accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('HIERARCHY1 Agency BR2 OK').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('HIERARCHY1 Agency SA1 OK').Location_Type__c);
		//System.assertEquals('BR',accountsMap.get('HIERARCHY1 Agency BR3 OK').Location_Type__c);

		System.assertEquals('P',accountsMap.get('Agency HO').Location_Class__c);
		System.assertEquals('T',accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency BR2 OK').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency SA1 OK').Location_Class__c);
		System.assertEquals('T',accountsMap.get('HIERARCHY1 Agency BR3 OK').Location_Class__c);

		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('Agency HO').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency BR1 OK').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency BR2 OK').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency SA1 OK').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency BR3 OK').Status__c);

		System.assertEquals(null,accountsMap.get('Agency HO').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency BR2 OK').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency SA1 OK').Top_Parent__c);


		if(!((accountsMap.get('HIERARCHY1 Agency BR1 OK').Top_Parent__c == null && accountsMap.get('HIERARCHY1 Agency BR3 OK').Top_Parent__c == a2.Id) || (accountsMap.get('HIERARCHY1 Agency BR1 OK').Top_Parent__c == a4.Id && accountsMap.get('HIERARCHY1 Agency BR3 OK').Top_Parent__c  == null))){
			System.assertEquals(true,false);
		}

		if(!((accountsMap.get('HIERARCHY1 Agency BR1 OK').ParentId == null && accountsMap.get('HIERARCHY1 Agency BR3 OK').ParentId == a2.Id) || (accountsMap.get('HIERARCHY1 Agency BR1 OK').ParentId == a4.Id && accountsMap.get('HIERARCHY1 Agency BR3 OK').ParentId  == null))){
			System.assertEquals(true,false);
		}
		
		//System.assertEquals(null,accountsMap.get('HIERARCHY1 Agency BR1 OK').Top_Parent__c);
		//System.assertEquals(a2.Id,accountsMap.get('HIERARCHY1 Agency BR3 OK').Top_Parent__c);



		System.assertEquals(null,accountsMap.get('Agency HO').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency BR2 OK').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency SA1 OK').ParentId);

		System.assertEquals(2,hierarchies.size());
		System.assertEquals(3,relations.size());

		List<AMS_Agencies_relationhip__c> relationsToVerify = [SELECT Id, Parent_Account__c, Child_Account__c, Hierarchy__c from AMS_Agencies_relationhip__c where Id not in:relationsToInsert];

		System.assertEquals(1,relationsToVerify.size());

		System.assert((relationsToVerify.get(0).Parent_Account__c == a2.Id && relationsToVerify.get(0).Child_Account__c == a4.Id) || (relationsToVerify.get(0).Child_Account__c == a2.Id || relationsToVerify.get(0).Parent_Account__c == a4.Id));

		//System.assertEquals(a2.Id,relationsToVerify.get(0).Parent_Account__c);
		//System.assertEquals(a4.Id,relationsToVerify.get(0).Child_Account__c);


		System.assertNotEquals(hierarchy.Id,relationsToVerify.get(0).Hierarchy__c);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest3() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US', ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='PK',ISO_Code__c = 'PK', ANG_Enable_NewGen__c=true)  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='HIERARCHY1 Agency BR1 OK',Short_Name__c='HIERARCHY1 Agency BR1 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='HIERARCHY1 Agency BR2 OK',Short_Name__c='HIERARCHY1 Agency BR2 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='HIERARCHY1 Agency BR3 OK',Short_Name__c='HIERARCHY1 Agency BR3 OK', Sector__c = 'Travel Agent',  Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
         
		insert new List<Account>{a2,a3,a4};

		Account a5 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='SA',Name='HIERARCHY1 Agency SA1 OK',Short_Name__c='HIERARCHY1 Agency SA1 OK', Sector__c = 'Travel Agent',  Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert a5;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		// 2 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);

		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a5.Id);

        List<AMS_Agencies_relationhip__c> relationsToInsert = new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3, rel4};

        insert relationsToInsert;

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Printing Statistics before migration');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Finish Printing Statistics before migration');

		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> newStructure = ANG_ConversionHelper.buildHierarchyStructure('US');

		newStructure = ANG_ConversionHelper.performValidationOnHierarchyStructure(newStructure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStructNew = ANG_ConversionHelper.fetchStatistics(newStructure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Printing Statistics after migration');

		ANG_ConversionHelper.printStatistics(finalStructNew);

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Finish  Printing Statistics after migration');

		List<Account> accounts = [SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c,ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, ANG_Accreditation_Model__c, Is_PCI_compliant__c FROM Account];
		List<AMS_Agencies_Hierarchy__c> hierarchies = [SELECT Id, Name, Migrated__c FROM AMS_Agencies_Hierarchy__c];
		List<AMS_Agencies_relationhip__c> relations = [SELECT Id, Parent_Account__c, Child_Account__c, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Accounts:'+accounts);
		System.debug('[ANG_ConversionHelperEnhancedTestTest3] hierarchies:'+hierarchies);
		System.debug('[ANG_ConversionHelperEnhancedTestTest3] relations:'+relations);

		Map<String,Account> accountsMap = new Map<String,Account>();
		for(Account acc: accounts)
			accountsMap.put(acc.Name,acc);

		System.assertEquals('HE',accountsMap.get('Agency HO').Location_Type__c);
		//System.assertEquals('HO',accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('HIERARCHY1 Agency BR2 OK').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('HIERARCHY1 Agency SA1 OK').Location_Type__c);
		//System.assertEquals('BR',accountsMap.get('HIERARCHY1 Agency BR3 OK').Location_Type__c);
		
		if(!((accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Type__c == 'HO' && accountsMap.get('HIERARCHY1 Agency BR3 OK').Location_Type__c == 'BR')||(accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Type__c == 'BR' && accountsMap.get('HIERARCHY1 Agency BR3 OK').Location_Type__c == 'HO'))){
			System.assertEquals(true,false);
		}

		System.assertEquals('P',accountsMap.get('Agency HO').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency BR1 OK').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency BR2 OK').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency SA1 OK').Location_Class__c);
		System.assertEquals('P',accountsMap.get('HIERARCHY1 Agency BR3 OK').Location_Class__c);

		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('Agency HO').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency BR1 OK').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency BR2 OK').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency SA1 OK').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HIERARCHY1 Agency BR3 OK').Status__c);

		System.assertEquals(null,accountsMap.get('Agency HO').Top_Parent__c);
		//System.assertEquals(null,accountsMap.get('HIERARCHY1 Agency BR1 OK').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency BR2 OK').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency SA1 OK').Top_Parent__c);
		//System.assertEquals(a2.Id,accountsMap.get('HIERARCHY1 Agency BR3 OK').Top_Parent__c);

		if(!((accountsMap.get('HIERARCHY1 Agency BR1 OK').Top_Parent__c == null && accountsMap.get('HIERARCHY1 Agency BR3 OK').Top_Parent__c == a2.Id) || (accountsMap.get('HIERARCHY1 Agency BR1 OK').Top_Parent__c == a4.Id && accountsMap.get('HIERARCHY1 Agency BR3 OK').Top_Parent__c  == null))){
			System.assertEquals(true,false);
		}

		if(!((accountsMap.get('HIERARCHY1 Agency BR1 OK').ParentId == null && accountsMap.get('HIERARCHY1 Agency BR3 OK').ParentId == a2.Id) || (accountsMap.get('HIERARCHY1 Agency BR1 OK').ParentId == a4.Id && accountsMap.get('HIERARCHY1 Agency BR3 OK').ParentId  == null))){
			System.assertEquals(true,false);
		}

		System.assertEquals(null,accountsMap.get('Agency HO').ParentId);
		//System.assertEquals(null,accountsMap.get('HIERARCHY1 Agency BR1 OK').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency BR2 OK').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('HIERARCHY1 Agency SA1 OK').ParentId);
		//System.assertEquals(a2.Id,accountsMap.get('HIERARCHY1 Agency BR3 OK').ParentId);

		System.assertEquals(2,hierarchies.size());
		System.assertEquals(3,relations.size());

		List<AMS_Agencies_relationhip__c> relationsToVerify = [SELECT Id, Parent_Account__c, Child_Account__c, Hierarchy__c from AMS_Agencies_relationhip__c where Id not in:relationsToInsert];

		System.assertEquals(1,relationsToVerify.size());

		//System.assertEquals(a2.Id,relationsToVerify.get(0).Parent_Account__c);
		//System.assertEquals(a4.Id,relationsToVerify.get(0).Child_Account__c);
		
		System.assert((relationsToVerify.get(0).Parent_Account__c == a2.Id && relationsToVerify.get(0).Child_Account__c == a4.Id) || (relationsToVerify.get(0).Child_Account__c == a2.Id || relationsToVerify.get(0).Parent_Account__c == a4.Id));

		System.assertNotEquals(hierarchy.Id,relationsToVerify.get(0).Hierarchy__c);

		System.debug('Accounts final are:' + [SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, ANG_Accreditation_Model__c, Is_PCI_compliant__c from Account ]);

		List<Account> accountsToRemainTheSame = [SELECT Id, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, ANG_Accreditation_Model__c, Is_PCI_compliant__c from Account where Name in ('HIERARCHY1 Agency BR1 OK','HIERARCHY1 Agency BR3 OK')];

		System.assertEquals(2,accountsToRemainTheSame.size());

		for(Account acct: accountsToRemainTheSame){

			System.assertEquals(null,acct.ANG_HE_RiskHistoryAssessment__c);
			System.assertEquals(null,acct.ANG_HE_RiskStatus__c);
			System.assertEquals(null,acct.ANG_Accreditation_Model__c);
			System.assertEquals(null,acct.Is_PCI_compliant__c);

		}

		List<Agency_Authorization__c> aAEEptyList = [SELECT Id, Account__c, Status__c, ANG_FormOfPayment_ID__c from Agency_Authorization__c where Account__r.Name in ('HIERARCHY1 Agency BR1 OK','HIERARCHY1 Agency BR3 OK')];

		System.assertEquals(0,aAEEptyList.size());

		List<Agency_Applied_Change_code__c> aaccEmptyList = [ Select Id, Account__c, Change_Code__c from Agency_Applied_Change_code__c where Account__r.Name in ('HIERARCHY1 Agency BR1 OK','HIERARCHY1 Agency BR3 OK')];

		System.assertEquals(2,aaccEmptyList.size());

		aAEEptyList = [SELECT Id, Account__c, Status__c, ANG_FormOfPayment_ID__c  from Agency_Authorization__c where Account__r.Name not in ('HIERARCHY1 Agency BR1 OK','HIERARCHY1 Agency BR3 OK')];

		System.debug('aAEEptyList is:' + aAEEptyList);

		System.assertNotEquals(0,aAEEptyList.size());

		aaccEmptyList = [ Select Id, Account__c, Change_Code__c from Agency_Applied_Change_code__c where Account__r.Name not in ('HIERARCHY1 Agency BR1 OK','HIERARCHY1 Agency BR3 OK')];

		System.debug('aaccEmptyList is:' + aaccEmptyList);


		System.assertNotEquals(0,aaccEmptyList.size());

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest4() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US', ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='HO1',Short_Name__c='HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='ST',Name='ST1',Short_Name__c='ST1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='BR2',Short_Name__c='BR2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-3));
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='ST',Name='ST2',Short_Name__c='ST2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-3));
         
		insert new List<Account>{a1,a2,a3,a4};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest4] Printing Statistics before migration');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(4,finalStruct.totalHierarchies);
		System.assertEquals(3,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('[ANG_ConversionHelperEnhancedTestTest4] Finish Printing Statistics before migration');

    	Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> newStructure = ANG_ConversionHelper.buildHierarchyStructure('US');

		newStructure = ANG_ConversionHelper.performValidationOnHierarchyStructure(newStructure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStructNew = ANG_ConversionHelper.fetchStatistics(newStructure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest4] Printing Statistics after migration');

		ANG_ConversionHelper.printStatistics(finalStructNew);

		System.debug('[ANG_ConversionHelperEnhancedTestTest4] Finish  Printing Statistics after migration');

		List<Account> accounts = [SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account];

		System.debug('[ANG_ConversionHelperEnhancedTestTest4] Accounts:'+accounts);

		Map<String,Account> accountsMap = new Map<String,Account>();
		for(Account acc: accounts)
			accountsMap.put(acc.Name,acc);

		System.assertEquals('HE',accountsMap.get('HO1').Location_Type__c);
		System.assertEquals('BR',accountsMap.get('BR2').Location_Type__c);
		System.assertEquals('ST',accountsMap.get('ST1').Location_Type__c);
		System.assertEquals('ST',accountsMap.get('ST2').Location_Type__c);

		System.assertEquals('P',accountsMap.get('HO1').Location_Class__c);
		System.assertEquals('P',accountsMap.get('BR2').Location_Class__c);
		System.assertEquals('P',accountsMap.get('ST1').Location_Class__c);
		System.assertEquals('P',accountsMap.get('ST2').Location_Class__c);

		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('HO1').Status__c);
		System.assertEquals(AMS_Utils.ACC_S0_TERMINATED,accountsMap.get('BR2').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('ST1').Status__c);
		System.assertEquals(AMS_Utils.ACC_S0_TERMINATED,accountsMap.get('ST2').Status__c);

		System.assertEquals(null,accountsMap.get('HO1').Top_Parent__c);
		System.assertEquals(null,accountsMap.get('BR2').Top_Parent__c);
		System.assertEquals(null,accountsMap.get('ST1').Top_Parent__c);
		System.assertEquals(null,accountsMap.get('ST2').Top_Parent__c);

		System.assertEquals(null,accountsMap.get('HO1').ParentId);
		System.assertEquals(null,accountsMap.get('BR2').ParentId);
		System.assertEquals(null,accountsMap.get('ST1').ParentId);
		System.assertEquals(null,accountsMap.get('ST2').ParentId);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest5() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US', ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR1',Short_Name__c='Agency BR1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-3));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR2',Short_Name__c='Agency BR2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-20));
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR3',Short_Name__c='Agency BR3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-3));
         
		insert new List<Account>{a2,a3,a4};

		Account a5 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='SA',Name='Agency SA1',Short_Name__c='Agency SA1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-23));
		Account a6 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a4.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234566',Location_Type__c='SA',Name='Agency SA2',Short_Name__c='Agency SA2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

		insert new List<Account>{a5,a6};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		// 2 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);

		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a5.Id);
		AMS_Agencies_relationhip__c rel5 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a4.Id, Child_Account__c = a6.Id);

        List<AMS_Agencies_relationhip__c> relationsToInsert = new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3, rel4, rel5};

        insert relationsToInsert;

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Printing Statistics before migration');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Finish Printing Statistics before migration');

    	Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> newStructure = ANG_ConversionHelper.buildHierarchyStructure('US');

		newStructure = ANG_ConversionHelper.performValidationOnHierarchyStructure(newStructure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStructNew = ANG_ConversionHelper.fetchStatistics(newStructure,'US');

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Printing Statistics after migration');

		ANG_ConversionHelper.printStatistics(finalStructNew);

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Finish  Printing Statistics after migration');

		List<Account> accounts = [SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account];
		List<AMS_Agencies_Hierarchy__c> hierarchies = [SELECT Id, Name, Migrated__c FROM AMS_Agencies_Hierarchy__c];
		List<AMS_Agencies_relationhip__c> relations = [SELECT Id, Parent_Account__c, Child_Account__c, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('[ANG_ConversionHelperEnhancedTestTest3] Accounts:'+accounts);
		System.debug('[ANG_ConversionHelperEnhancedTestTest3] hierarchies:'+hierarchies);
		System.debug('[ANG_ConversionHelperEnhancedTestTest3] relations:'+relations);

		Map<String,Account> accountsMap = new Map<String,Account>();
		for(Account acc: accounts)
			accountsMap.put(acc.Name,acc);

		System.assertEquals('HE',accountsMap.get('Agency HO').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('Agency BR1').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('Agency BR2').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('Agency BR3').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('Agency SA1').Location_Type__c);
		System.assertEquals('AE',accountsMap.get('Agency SA2').Location_Type__c);

		System.assertEquals('P',accountsMap.get('Agency HO').Location_Class__c);
		System.assertEquals('P',accountsMap.get('Agency BR1').Location_Class__c);
		System.assertEquals('P',accountsMap.get('Agency BR2').Location_Class__c);
		System.assertEquals('P',accountsMap.get('Agency BR3').Location_Class__c);
		System.assertEquals('P',accountsMap.get('Agency SA1').Location_Class__c);
		System.assertEquals('P',accountsMap.get('Agency SA2').Location_Class__c);

		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('Agency HO').Status__c);
		System.assertEquals(AMS_Utils.ACC_S0_TERMINATED,accountsMap.get('Agency BR1').Status__c);
		System.assertEquals(AMS_Utils.ACC_S0_TERMINATED,accountsMap.get('Agency BR2').Status__c);
		System.assertEquals(AMS_Utils.ACC_S0_TERMINATED,accountsMap.get('Agency BR3').Status__c);
		System.assertEquals(AMS_Utils.ACC_S0_TERMINATED,accountsMap.get('Agency SA1').Status__c);
		System.assertEquals(AMS_Utils.ACC_S9_APPROVED,accountsMap.get('Agency SA2').Status__c);

		System.assertEquals(null,accountsMap.get('Agency HO').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('Agency BR1').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('Agency BR2').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('Agency BR3').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('Agency SA1').Top_Parent__c);
		System.assertEquals(a1.Id,accountsMap.get('Agency SA2').Top_Parent__c);

		System.assertEquals(null,accountsMap.get('Agency HO').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('Agency BR1').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('Agency BR2').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('Agency BR3').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('Agency SA1').ParentId);
		System.assertEquals(a1.Id,accountsMap.get('Agency SA2').ParentId);

		System.assertEquals(1,hierarchies.size());
		System.assertEquals(5,relations.size());

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest6() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US', ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a1};

        case cc = new case(AccountId = a1.Id);
        insert cc;

        Financial_Institution__c FI = new Financial_Institution__c(Name = 'FI1', INSTITUTION_TYPE__C='Bank');
        insert FI;
        Financial_Security__c fs1 = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a1.Id, AMOUNT__C=820932, Unlimited_Security__c =true, FINANCIAL_INSTITUTION__c=FI.Id,  Security_Type__c='MCPG', Region__c ='Europe', Security_Status__c = 'Active', Reception_Date__c=Date.today().addMonths(-20), Reasonforrequest__c='New Application', Reception_Case__c=cc.Id);
        insert fs1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR1',Short_Name__c='Agency BR1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-20));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR2',Short_Name__c='Agency BR2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-20));
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR3',Short_Name__c='Agency BR3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-20));
         
		insert new List<Account>{a2,a3,a4};

		Account a5 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='SA',Name='Agency SA1',Short_Name__c='Agency SA1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-20));
		Account a6 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a4.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234566',Location_Type__c='SA',Name='Agency SA2',Short_Name__c='Agency SA2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-20));

		insert new List<Account>{a5,a6};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		// 2 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);

		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a5.Id);
		AMS_Agencies_relationhip__c rel5 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a4.Id, Child_Account__c = a6.Id);

        List<AMS_Agencies_relationhip__c> relationsToInsert = new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3, rel4, rel5};

        insert relationsToInsert;

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

    	Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> newStructure = ANG_ConversionHelper.buildHierarchyStructure('US');

		newStructure = ANG_ConversionHelper.performValidationOnHierarchyStructure(newStructure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStructNew = ANG_ConversionHelper.fetchStatistics(newStructure,'US');

		ANG_ConversionHelper.printStatistics(finalStructNew);

		System.debug([SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account]);

		System.debug([Select Id, ANG_AccountId__c,ANG_CashCondition__c,ANG_RME_Amount__c,ANG_ConsumedRHC__c,ANG_ConsumedRHC_Percent__c,ANG_Consumed_RHC_Date__c,ANG_ConsumedRHC_Last_Update__c,ANG_Enable_Calculation__c,ANG_Exceeding_Financial_Security__c,ANG_RHC_Amount_Forecasted__c,ANG_Minimum_Financial_Security__c,ANG_RHC_Amount_Provisional__c,ANG_Provisional_RHC_Last_Update__c,ANG_RME_Amount_Provisional__c,ANG_RHC_Amount__c,ANG_RHC_Amount_Simulation__c,ANG_RHC_Effective_Date__c,ANG_RME_Amount_Last_Update__c,ANG_Financial_Security__c,ANG_UniqueKey__c from ANG_RHC_Information__c]);

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(1,hierarchies.size());
		
		System.assertEquals(hierarchy.Id,hierarchies.get(0).Id);
	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest7() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US', ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR1',Short_Name__c='Agency BR1', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR2',Short_Name__c='Agency BR2', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
         
		insert new List<Account>{a2,a3};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		// 2 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);

        List<AMS_Agencies_relationhip__c> relationsToInsert = new List<AMS_Agencies_relationhip__c>{rel1, rel2};

        insert relationsToInsert;

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		System.debug('Accounts are:' + [SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account]);

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		List<AMS_Agencies_relationhip__c> relations = [SELECT Id, Hierarchy__c, Parent_Account__c, Child_Account__c  FROM AMS_Agencies_relationhip__c];

		System.debug('hierarchies are:'+hierarchies);
		System.debug('relations are:'+relations);

		System.assertEquals(1,hierarchies.size());
		
		System.assertNotEquals(hierarchy.Id,hierarchies.get(0).Id);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest8() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US', ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR1',Short_Name__c='Agency BR1', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR2',Short_Name__c='Agency BR2', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
         
		insert new List<Account>{a2,a3};

        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Agency SA1',Short_Name__c='Agency SA1', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a4;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		// 2 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a3.Id, Child_Account__c = a4.Id);

        List<AMS_Agencies_relationhip__c> relationsToInsert = new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3};

        insert relationsToInsert;

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		System.debug([SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account]);

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(1,hierarchies.size());
		
		System.assertNotEquals(hierarchy.Id,hierarchies.get(0).Id);
	}

}