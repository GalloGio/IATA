@isTest
private class ANG_ConversionHelperEnhancedTest {
	
	@isTest static void ANG_ConversionHelperEnhancedTestTest1() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='HIERARCHY1 Agency HO TERMINATED',Short_Name__c='Test1 Agency TERMINATED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
        Account aw1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='HIERARCHY2 Agency HO OK',Short_Name__c='Test1 Agency HO OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a1, aw1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='HIERARCHY1 Agency BR1 OK',Short_Name__c='HIERARCHY1 Agency BR1 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='HIERARCHY1 Agency BR2 OK',Short_Name__c='HIERARCHY1 Agency BR2 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        Account aw2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='HIERARCHY2 Agency BR1 OK',Short_Name__c='HIERARCHY2 Agency BR1 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account aw3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='HIERARCHY2 Agency BR2 OK',Short_Name__c='HIERARCHY2 Agency BR2 OK', Sector__c = 'Travel Agent',  Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
         
		insert new List<Account>{a2, a3,aw2,aw3};
 
		Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='HIERARCHY1 Agency SA OK',Short_Name__c='HIERARCHY1 Agency SA OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a4};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1 NOK');
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2 OK');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy,hierarchy2};

		// 3 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a3.Id, Child_Account__c = a4.Id);

		// 2 level hierarchy
		AMS_Agencies_relationhip__c relw1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy2.Id, Parent_Account__c = aw1.Id, Child_Account__c = aw2.Id);
		AMS_Agencies_relationhip__c relw2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy2.Id, Parent_Account__c = aw1.Id, Child_Account__c = aw3.Id);

        insert new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3,relw1, relw2};

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

		System.debug('finalStructNew.totalHierarchies:'+finalStructNew.totalHierarchies);
		System.debug('finalStructNew.totalValidHierarchies:'+finalStructNew.totalValidHierarchies);
		System.debug('finalStructNew.totalInvalidHierarchies:'+finalStructNew.totalInvalidHierarchies);
		System.debug('finalStructNew.totalMigratedHierarchies:'+finalStructNew.totalMigratedHierarchies);

		System.debug([SELECT Id, Name, Location_Class__c, Location_Type__c FROM Account]);

		System.debug([SELECT Id, Name, Migrated__c FROM AMS_Agencies_Hierarchy__c]);

		System.assertEquals(1,finalStructNew.totalHierarchies);
		System.assertEquals(0,finalStructNew.totalValidHierarchies);
		System.assertEquals(0,finalStructNew.totalInvalidHierarchies);
		System.assertEquals(1,finalStructNew.totalMigratedHierarchies);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest2_0() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='BR',Name='Agency BR1 ACCREDITED',Short_Name__c='Agency BR1 ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR2 TERMINATED 2017',Short_Name__c='Agency BR2 TERMINATED 2016', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-4));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR3 TERMINATED 2016',Short_Name__c='Agency BR2 TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-10));
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR4 ACCREDITED (T)',Short_Name__c='Agency BR4 ACCREDITED (T)', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        Account a5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='ST',Name='Agency ST1 ACCREDITED (P)',Short_Name__c='Agency ST1 ACCREDITED (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a6 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234566',Location_Type__c='ST',Name='Agency ST2 TERMINATED (P) 2017',Short_Name__c='Agency ST2 TERMINATED (P) 2017', Sector__c = 'Travel Agent',  Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-4));
		Account a7 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234567',Location_Type__c='ST',Name='Agency ST3 TERMINATED (P) 2016',Short_Name__c='Agency ST3 TERMINATED (P) 2016', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-10));

        insert new List<Account>{a1,a2,a3,a4,a5,a6,a7};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		System.assertEquals(4,finalStruct.totalHierarchies);
		System.assertEquals(2,finalStruct.totalValidHierarchies);
		System.assertEquals(2,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		ANG_ConversionHelper.printStatistics(finalStruct);

    	Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c FROM Account ORDER BY IATACode__c];

		Map<String,Account> accountMap = new Map<String,Account>();

		for(Account acct: accounts){
			accountMap.put(acct.Name,acct);
		}

		System.assertEquals(accountMap.get('Agency BR1 ACCREDITED').Location_Type__c,'BR');
		System.assertEquals(accountMap.get('Agency BR1 ACCREDITED').Location_Class__c,'P');

		System.assertEquals(accountMap.get('Agency BR2 TERMINATED 2017').Location_Type__c,'AE');
		System.assertEquals(accountMap.get('Agency BR2 TERMINATED 2017').Location_Class__c,'P');

		System.assertEquals(accountMap.get('Agency BR3 TERMINATED 2016').Location_Type__c,'BR');
		System.assertEquals(accountMap.get('Agency BR3 TERMINATED 2016').Location_Class__c,'P');

		System.assertEquals(accountMap.get('Agency BR4 ACCREDITED (T)').Location_Type__c,'BR');
		System.assertEquals(accountMap.get('Agency BR4 ACCREDITED (T)').Location_Class__c,'T');

		System.assertEquals(accountMap.get('Agency ST1 ACCREDITED (P)').Location_Type__c,'ST');
		System.assertEquals(accountMap.get('Agency ST1 ACCREDITED (P)').Location_Class__c,'P');

		System.assertEquals(accountMap.get('Agency ST2 TERMINATED (P) 2017').Location_Type__c,'AE');
		System.assertEquals(accountMap.get('Agency ST2 TERMINATED (P) 2017').Location_Class__c,'P');

		System.assertEquals(accountMap.get('Agency ST3 TERMINATED (P) 2016').Location_Type__c,'ST');
		System.assertEquals(accountMap.get('Agency ST3 TERMINATED (P) 2016').Location_Class__c,'P');

	}	

	@isTest static void ANG_ConversionHelperEnhancedTestTest2_1() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        //Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='BR',Name='Agency BR1 ACCREDITED',Short_Name__c='Agency BR1 ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR2 TERMINATED 2017',Short_Name__c='Agency BR2 TERMINATED 2016', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-4));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR3 TERMINATED 2016',Short_Name__c='Agency BR2 TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-10));
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR4 ACCREDITED (T)',Short_Name__c='Agency BR4 ACCREDITED (T)', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        //Account a5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='ST',Name='Agency ST1 ACCREDITED (P)',Short_Name__c='Agency ST1 ACCREDITED (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a6 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234566',Location_Type__c='ST',Name='Agency ST2 TERMINATED (P) 2017',Short_Name__c='Agency ST2 TERMINATED (P) 2017', Sector__c = 'Travel Agent',  Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-4));
		Account a7 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234567',Location_Type__c='ST',Name='Agency ST3 TERMINATED (P) 2016',Short_Name__c='Agency ST3 TERMINATED (P) 2016', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED,Expiry_Date__c = Date.today().addMonths(-10));

        insert new List<Account>{a2,a3,a4,a6,a7};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		System.assertEquals(2,finalStruct.totalHierarchies);
		System.assertEquals(2,finalStruct.totalValidHierarchies);
		System.assertEquals(0,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c FROM Account ORDER BY IATACode__c];

		Map<String,Account> accountMap = new Map<String,Account>();

		for(Account acct: accounts){
			accountMap.put(acct.Name,acct);
		}

		//System.assertEquals(accountMap.get('Agency BR1 ACCREDITED').Location_Type__c,'AE'); -> Validation rule that states that you cannot have an active AE with no ParentId
		//System.assertEquals(accountMap.get('Agency BR1 ACCREDITED').Location_Class__c,'P'); -> Validation rule that states that you cannot have an active AE with no ParentId

		System.assertEquals(accountMap.get('Agency BR2 TERMINATED 2017').Location_Type__c,'AE');
		System.assertEquals(accountMap.get('Agency BR2 TERMINATED 2017').Location_Class__c,'P');

		System.assertEquals(accountMap.get('Agency BR3 TERMINATED 2016').Location_Type__c,'BR');
		System.assertEquals(accountMap.get('Agency BR3 TERMINATED 2016').Location_Class__c,'P');

		System.assertEquals(accountMap.get('Agency BR4 ACCREDITED (T)').Location_Type__c,'BR');
		System.assertEquals(accountMap.get('Agency BR4 ACCREDITED (T)').Location_Class__c,'T');

		//System.assertEquals(accountMap.get('Agency ST1 ACCREDITED (P)').Location_Type__c,'AE'); -> Validation rule that states that you cannot have an active AE with no ParentId
		//System.assertEquals(accountMap.get('Agency ST1 ACCREDITED (P)').Location_Class__c,'P'); -> Validation rule that states that you cannot have an active AE with no ParentId

		System.assertEquals(accountMap.get('Agency ST2 TERMINATED (P) 2017').Location_Type__c,'AE');
		System.assertEquals(accountMap.get('Agency ST2 TERMINATED (P) 2017').Location_Class__c,'P');

		System.assertEquals(accountMap.get('Agency ST3 TERMINATED (P) 2016').Location_Type__c,'ST');
		System.assertEquals(accountMap.get('Agency ST3 TERMINATED (P) 2016').Location_Class__c,'P');


	}	

	@isTest static void ANG_ConversionHelperEnhancedTestTest3() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO ACCREDITED',Short_Name__c='Agency HO ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR2 ACCREDITED (T)',Short_Name__c='Agency BR2 ACCREDITED (T)', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR3 ACCREDITED (P)',Short_Name__c='Agency BR3 ACCREDITED (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a2,a3};

        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Agency SA ACCREDITED',Short_Name__c='Agency SA ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert a4;


        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a4.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account ORDER BY IATACode__c];

		for(Account acct: accounts){

			if(acct.Name == 'Agency HO ACCREDITED')
				System.assertEquals(acct.Location_Type__c,'HE');
			else
				if(acct.Name == 'Agency BR2 ACCREDITED (T)')
					System.assertEquals(acct.Location_Type__c,'HO');
				else
					System.assertEquals(acct.Location_Type__c,'AE');

			if(acct.Name == 'Agency BR2 ACCREDITED (T)')
				System.assertEquals(acct.Location_Class__c,'T');
			else
				System.assertEquals(acct.Location_Class__c,'P');

		}


	}	

	@isTest static void ANG_ConversionHelperEnhancedTestTest4() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO TERMINATED 2016',Short_Name__c='Agency HO TERMINATED 2016', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-30));

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR2 TERMINATED 2016 (T)',Short_Name__c='Agency BR2 TERMINATED 2016 (T)', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-30));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR3 TERMINATED 2016 (P)',Short_Name__c='Agency BR3 TERMINATED 2016 (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-30));
        
        insert new List<Account>{a2,a3};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(0,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(0,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c FROM Account ORDER BY IATACode__c];

		Map<String,Account> accountMap = new Map<String,Account>();

		for(Account acct: accounts){
			accountMap.put(acct.Name,acct);
		}

		for(Account acct: accounts){

			if(acct.Name == 'Agency HO TERMINATED 2016')
				System.assertEquals(acct.Location_Type__c,'HO');
			else
				System.assertEquals(acct.Location_Type__c,'BR');

			if(acct.Name == 'Agency BR2 TERMINATED 2016 (T)')
				System.assertEquals(acct.Location_Class__c,'T');
			else
				System.assertEquals(acct.Location_Class__c,'P');

		}
	}	

	@isTest static void ANG_ConversionHelperEnhancedTestTest5() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO TERMINATED 2017',Short_Name__c='Agency HO TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency ST (P) TERMINATED 2017',Short_Name__c='Agency ST (P) TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (T) TERMINATED 2017',Short_Name__c='Agency BR (T) TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        
        insert new List<Account>{a2,a3};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c FROM Account ORDER BY IATACode__c];

		Map<String,Account> accountMap = new Map<String,Account>();

		for(Account acct: accounts){
			accountMap.put(acct.Name,acct);
		}

		for(Account acct: accounts){

			if(acct.Name == 'Agency HO TERMINATED 2017')
				System.assertEquals(acct.Location_Type__c,'HO');
			else
				if(acct.Location_Class__c == 'T')
					System.assertEquals(acct.Location_Type__c,'BR');
				else
					System.assertEquals(acct.Location_Type__c,'BR');

			if(acct.Name=='Agency BR (T) TERMINATED 2017')
				System.assertEquals(acct.Location_Class__c,'T');
			else
				System.assertEquals(acct.Location_Class__c,'P');
		}

		System.assertEquals([Select id from AMS_Agencies_relationhip__c].size(),2);
		
		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(1,hierarchies.size());
		
		System.assertEquals(hierarchy.Id,hierarchies.get(0).Id);


	}	


	@isTest static void ANG_ConversionHelperEnhancedTestTest6() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO ACCREDITED',Short_Name__c='Agency HO ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency ST (T) TERMINATED 2017',Short_Name__c='Agency ST (T) TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) TERMINATED 2015',Short_Name__c='Agency BR (P) TERMINATED 2015', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-10));
        
        insert new List<Account>{a2,a3};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(1,finalStruct.totalValidHierarchies);
		System.assertEquals(0,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c FROM Account ORDER BY IATACode__c];

		Map<String,Account> accountMap = new Map<String,Account>();

		for(Account acct: accounts){
			accountMap.put(acct.Name,acct);
		}

		for(Account acct: accounts){

			if(acct.Name == 'Agency HO ACCREDITED')
				System.assertEquals(acct.Location_Type__c,'HE');
			else
				System.assertEquals(acct.Location_Type__c,'AE');

			System.assertEquals(acct.Location_Class__c,'P');

		}
	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest7() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO ACCREDITED',Short_Name__c='Agency HO ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR2 TERMINATED 2017 (P)',Short_Name__c='Agency BR2 TERMINATED 2017 (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR3 TERMINATED 2015 (P)',Short_Name__c='Agency BR3 TERMINATED 2015 (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-10));
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR4 TERMINATED 2017 (F)',Short_Name__c='Agency BR4 TERMINATED 2017 (P)', Sector__c = 'Travel Agent', Location_Class__c = 'F', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        
        insert new List<Account>{a2,a3,a4};

        Account a5 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='SA',Name='Agency SA TERMINATED 2015',Short_Name__c='Agency SA TERMINATED 2015', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-10));
        
        insert a5;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);
		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a5.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3, rel4};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(1,finalStruct.totalValidHierarchies);
		System.assertEquals(0,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account ORDER BY IATACode__c];

		for(Account acct: accounts){

			System.debug('Analyzing account ' + acct);

			if(acct.Name == 'Agency HO ACCREDITED')
				System.assertEquals(acct.Location_Type__c,'HE');
			if(acct.Name == 'Agency BR2 TERMINATED 2017 (P)')
				System.assertEquals(acct.Location_Type__c,'AE');
			if(acct.Name == 'Agency BR2 TERMINATED 2015 (P)')
				System.assertEquals(acct.Location_Type__c,'AE');
			if(acct.Name == 'Agency BR4 TERMINATED 2017 (F)')
				System.assertEquals(acct.Location_Type__c,'AE');
			if(acct.Name == 'Agency SA TERMINATED 2015')
				System.assertEquals(acct.Location_Type__c,'AE');


			System.assertEquals(acct.Location_Class__c,'P');

		}

		List<Agency_Applied_Change_code__c> changeCodes = [SELECT Id, Account__c, Change_Code__c  FROM Agency_Applied_Change_code__c ];

		System.assertEquals(1,changeCodes.size());

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(1,hierarchies.size());
		
		System.assertEquals(hierarchy.Id,hierarchies.get(0).Id);

	}		

	@isTest static void ANG_ConversionHelperEnhancedTestTest8() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO ACCREDITED',Short_Name__c='Agency HO ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='ST',Name='Agency ST TERMINATED 2017 (F)',Short_Name__c='Agency ST TERMINATED 2017 (F)', Sector__c = 'Travel Agent', Location_Class__c = 'F', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='ES',Name='Agency ES TERMINATED 2015 (F)',Short_Name__c='Agency ES TERMINATED 2015 (F)', Sector__c = 'Travel Agent', Location_Class__c = 'F', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-10));
        
        insert new List<Account>{a2,a3};

        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='SA',Name='Agency SA TERMINATED 2017',Short_Name__c='Agency SA TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        
        insert a4;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a4.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(1,finalStruct.totalValidHierarchies);
		System.assertEquals(0,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account ORDER BY IATACode__c];

		for(Account acct: accounts){

			System.debug('Analyzing account ' + acct);

			if(acct.Name == 'Agency HO ACCREDITED')
				System.assertEquals(acct.Location_Type__c,'HE');
			if(acct.Name == 'Agency ST TERMINATED 2017 (F)')
				System.assertEquals(acct.Location_Type__c,'AE');
			if(acct.Name == 'Agency ES TERMINATED 2015 (F)')
				System.assertEquals(acct.Location_Type__c,'AE');
			if(acct.Name == 'Agency SA TERMINATED 2017')
				System.assertEquals(acct.Location_Type__c,'AE');

			System.assertEquals(acct.Location_Class__c,'P');

		}

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(1,hierarchies.size());
		
		System.assertEquals(hierarchy.Id,hierarchies.get(0).Id);


	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest9() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO TERMINATED 2017',Short_Name__c='Agency HO TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (T) 2', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR (T)',Short_Name__c='Agency BR (T)', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a2,a3,a4};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2,rel3};

        Account a5 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='SA',Name='Agency SA (P)',Short_Name__c='Agency SA (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a5};

		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a4.Id, Child_Account__c = a5.Id);
		insert new List<AMS_Agencies_relationhip__c>{rel4};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		System.assertEquals(3,rels.size());
		System.assertEquals(2,hiers.size());

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest10() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO TERMINATED 2017',Short_Name__c='Agency HO TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (T) 1',Short_Name__c='Agency BR (T) 1', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a2};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

		System.assertEquals(0,rels.size());
		System.assertEquals(0,hiers.size());

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest11() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a2};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

		System.assertEquals(0,rels.size());
		System.assertEquals(0,hiers.size());

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest12() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='PK',ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO TERMINATED 2017',Short_Name__c='Agency HO TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR', Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR (P) 3',Short_Name__c='Agency BR (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a2,a3,a4};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2,rel3};

        Account a5 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='SA',Name='Agency SA (P)',Short_Name__c='Agency SA (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a5};

		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a4.Id, Child_Account__c = a5.Id);
		insert new List<AMS_Agencies_relationhip__c>{rel4};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		System.assertEquals(3,rels.size());
		System.assertEquals(2,hiers.size());

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest13() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO 1',Short_Name__c='Agency HO 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='HO',Name='Agency HO 1',Short_Name__c='Agency HO 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a1,a2};

		ANG_RHC_Information__c rhc = new ANG_RHC_Information__c(
				ANG_AccountId__c = a1.Id,
				RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
				ANG_UniqueKey__c= a1.id+ANG_RHCHelper.RHC_INFO_STD_RT,
				CurrencyIsoCode = ctry.CurrencyIsoCode
			);

		insert rhc;

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);
		
		Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(0,hierarchies.size());

		System.debug([SELECT Id, ANG_AccountId__c, ANG_AccountId__r.Name from ANG_RHC_Information__c where RecordTypeId = :ANG_RHCHelper.RECTYPE_STDRHCINFO]);
	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest14() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US',ISO_Code__c = 'US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO', Name='Agency HO',      Short_Name__c='Agency HO',       Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR', Name='Agency BR (C) 1',Short_Name__c='Agency BR (c) 1', Sector__c = 'Cargo Agent',  Location_Class__c = 'C', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR', Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR', Name='Agency BR (M) 1',Short_Name__c='Agency BR (M) 3', Sector__c = 'Travel Agent', Location_Class__c = 'M', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a1,a2,a3,a4};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(0,hierarchies.size());
		
	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest15() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c=true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='HIERARCHY1 Agency HO OK',Short_Name__c='Test1 Agency TERMINATED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='HIERARCHY1 Agency BR1 OK',Short_Name__c='HIERARCHY1 Agency BR1 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='HIERARCHY1 Agency BR2 OK',Short_Name__c='HIERARCHY1 Agency BR2 OK', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED);
        
		insert new List<Account>{a2,a3};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1 NOK');

		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy};

		// 3 level hierarchy
		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);

        insert new List<AMS_Agencies_relationhip__c>{rel1, rel2};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

    	Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(1,hierarchies.size());
		
		System.assertEquals(hierarchy.Id,hierarchies.get(0).Id);

		System.debug('[ANG_ConversionHelperEnhancedTestTest15]'+[SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account]);

	}

	
	@isTest static void ANG_ConversionHelperEnhancedTestTest16() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO ACCREDITED',Short_Name__c='Agency HO ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency ST (T) TERMINATED 2017',Short_Name__c='Agency ST (T) TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) TERMINATED 2015',Short_Name__c='Agency BR (P) TERMINATED 2015', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
		Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR 2 (T) ',Short_Name__c='Agency BR 2 (T) TERMINATED 2017', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a5 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='BR',Name='Agency BR 3 (T) ',Short_Name__c='Agency BR 3 (T)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert new List<Account>{a2,a3,a4,a5};

		Contact newContact1 = new Contact();
		newContact1.FirstName = 'Joel';
		newContact1.LastName = 'Chandler';
		newContact1.Email = 'joel.chandler@test1.com';
		newContact1.User_Portal_Status__c = 'Approved Admin';
		newContact1.AccountId = a3.Id;

		insert newContact1;

		newContact1.User_Portal_Status__c = 'Approved Admin';

		update newContact1;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);
		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a5.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2,rel3, rel4};

		Integer dMLStatements = Limits.getDMLStatements();
		integer futureCalls = Limits.getFutureCalls();

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		Id conversionBatchId = ANG_ConversionHelper.runFullAnalysesWithReport('US');


		Test.stopTest();

		System.assertEquals(dMLStatements,Limits.getDMLStatements());
		System.assertEquals(futureCalls,Limits.getFutureCalls());

		System.assertEquals([Select Id from AMS_Agencies_Hierarchy__c].size(),1);
		
	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest17() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO ACCREDITED',Short_Name__c='Agency HO ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P)',Short_Name__c='Agency BR (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a2;

		Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='EB',Name='Agency EB (F)',Short_Name__c='Agency EB (F)', Sector__c = 'Travel Agent', Location_Class__c = 'F', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));

		insert a3;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);

		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a3.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2};


        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);


		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(1,hierarchies.size());
		
		System.debug('[ANG_ConversionHelperEnhancedTestTest17]'+[SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account]);

		System.assertNotEquals(hierarchy.Id,hierarchies.get(0).Id);
	}


	@isTest static void ANG_ConversionHelperEnhancedTestTest18() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO ACCREDITED',Short_Name__c='Agency HO ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (T)',Short_Name__c='Agency BR (T)', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a2;

		Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (P)',Short_Name__c='Agency SA (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));

		insert a3;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);

		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a3.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2};


        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);


		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		System.assertEquals(1,hierarchies.size());
		
		System.debug('[ANG_ConversionHelperEnhancedTestTest18]'+[SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account]);

		System.assertEquals(hierarchy.Id,hierarchies.get(0).Id);
	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest19() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO ACCREDITED',Short_Name__c='Agency HO ACCREDITED', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (T)',Short_Name__c='Agency BR (T)', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a2;

		Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (P)',Short_Name__c='Agency SA (P)', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));

		insert a3;

		Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (T)',Short_Name__c='Agency SA (T)', Sector__c = 'Travel Agent', Location_Class__c = 'T', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));

		insert a4;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);

		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a3.Id);

		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a4.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3};


        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);


		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c];

		List<AMS_Agencies_relationhip__c> relations = [SELECT Id, Hierarchy__c, Parent_Account__c, Child_Account__c  FROM AMS_Agencies_relationhip__c];

		System.assertEquals(2,hierarchies.size());
		System.assertEquals(2,relations.size());

		System.debug('[ANG_ConversionHelperEnhancedTestTest19] accounts:'+[SELECT Id, Name, Status__c, Location_Class__c, Location_Type__c, RecordType.DeveloperName, Sector__c, ParentId, Top_Parent__c, IATACode__c FROM Account]);

		System.debug('[ANG_ConversionHelperEnhancedTestTest19] relations:'+[SELECT Id, Hierarchy__c, Parent_Account__c, Child_Account__c  FROM AMS_Agencies_relationhip__c]);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest20() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

		IATA_ISO_Country__c ctry3 = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='TK', ISO_Code__c = 'TK')  ;
        insert ctry3 ;

		IATA_ISO_Country__c ctry4 = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='RK', ISO_Code__c = 'RK')  ;
        insert ctry4 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry3.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a2,a3};

        Account a4 = new Account(IATA_ISO_Country__c = ctry4.id, ParentId = a3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a4;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a3.Id, Child_Account__c = a4.Id);


		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest21() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

		IATA_ISO_Country__c ctry3 = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='TK', ISO_Code__c = 'TK')  ;
        insert ctry3 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry3.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a2,a3};

        Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR (P) 3',Short_Name__c='Agency BR (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a4;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a3.Id, Child_Account__c = a4.Id);


		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest22() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert new List<Account>{a2,a3};

        Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR (P) 3',Short_Name__c='Agency BR (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a4;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a3.Id, Child_Account__c = a4.Id);


		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('PK');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'PK');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest23() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a5 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='BR',Name='Agency BR (P) 4',Short_Name__c='Agency BR (P) 4', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
      
        insert new List<Account>{a2,a3,a5};

        Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR (P) 3',Short_Name__c='Agency BR (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));

        insert a4;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a3.Id, Child_Account__c = a4.Id);
		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a5.Id);


		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3,rel4};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('PK');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'PK');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		if(mapAccount.get('Agency BR (P) 4').Location_Type__c == 'HE'){
			System.assertEquals('HE' , mapAccount.get('Agency BR (P) 4').Location_Type__c);
			System.assertEquals('AE' , mapAccount.get('Agency BR (P) 3').Location_Type__c);
		}else{
			System.assertEquals('AE' , mapAccount.get('Agency BR (P) 4').Location_Type__c);
			System.assertEquals('HE' , mapAccount.get('Agency BR (P) 3').Location_Type__c);
		}

		System.assertEquals('BR' , mapAccount.get('Agency BR (P) 1').Location_Type__c);
		System.assertEquals('BR' , mapAccount.get('Agency BR (P) 2').Location_Type__c);
		System.assertEquals('HO' , mapAccount.get('Agency HO').Location_Type__c);

		System.assertEquals(3 , rels.size());
		System.assertEquals(2 , hiers.size());

		if(mapAccount.get('Agency BR (P) 4').Location_Type__c == 'HE'){
			System.assertEquals(null , mapAccount.get('Agency BR (P) 4').ParentId);
			System.assertEquals(null , mapAccount.get('Agency BR (P) 4').Top_Parent__c);

			System.assertEquals(mapAccount.get('Agency BR (P) 4').Id , mapAccount.get('Agency BR (P) 3').ParentId);
			System.assertEquals(mapAccount.get('Agency BR (P) 4').Id , mapAccount.get('Agency BR (P) 3').Top_Parent__c);
		}else{
			System.assertEquals(null , mapAccount.get('Agency BR (P) 3').ParentId);
			System.assertEquals(null , mapAccount.get('Agency BR (P) 3').Top_Parent__c);

			System.assertEquals(mapAccount.get('Agency BR (P) 3').Id , mapAccount.get('Agency BR (P) 4').ParentId);
			System.assertEquals(mapAccount.get('Agency BR (P) 3').Id , mapAccount.get('Agency BR (P) 4').Top_Parent__c);
		}


		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency HO').Id , mapAccount.get('Agency BR (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency HO').Id , mapAccount.get('Agency BR (P) 1').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency HO').Id , mapAccount.get('Agency BR (P) 2').ParentId);
		System.assertEquals(mapAccount.get('Agency HO').Id , mapAccount.get('Agency BR (P) 2').Top_Parent__c);

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest24() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
      
        insert new List<Account>{a2};

        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='BR',Name='Agency BR (P) 3',Short_Name__c='Agency BR (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));

        insert a4;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a4.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('PK');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'PK');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Migrated__c, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		System.assertEquals('BR' , mapAccount.get('Agency BR (P) 3').Location_Type__c);
		System.assertEquals('HE' , mapAccount.get('Agency BR (P) 1').Location_Type__c);
		System.assertEquals('HO' , mapAccount.get('Agency HO').Location_Type__c);

		System.assertEquals(1 , rels.size());
		System.assertEquals(1 , hiers.size());

		System.assertEquals(null , mapAccount.get('Agency BR (P) 1').ParentId);
		System.assertEquals(null , mapAccount.get('Agency BR (P) 1').Top_Parent__c);
		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency HO').Id , mapAccount.get('Agency BR (P) 3').ParentId);
		System.assertEquals(mapAccount.get('Agency HO').Id , mapAccount.get('Agency BR (P) 3').Top_Parent__c);


		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

		System.assertEquals(false , hiers.get(0).Migrated__c);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest25() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
      
        insert new List<Account>{a2,a3};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);


		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('PK');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'PK');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		if(mapAccount.get('Agency BR (P) 1').Location_Type__c == 'HE'){
			System.assertEquals('HE' , mapAccount.get('Agency BR (P) 1').Location_Type__c);
			System.assertEquals('AE' , mapAccount.get('Agency BR (P) 2').Location_Type__c);
		}
		else{
			System.assertEquals('AE' , mapAccount.get('Agency BR (P) 1').Location_Type__c);
			System.assertEquals('HE' , mapAccount.get('Agency BR (P) 2').Location_Type__c);			
		}

		System.assertEquals('HO' , mapAccount.get('Agency HO').Location_Type__c);

		System.assertEquals(1 , rels.size());
		System.assertEquals(1 , hiers.size());

		System.assertNotEquals(hierarchy.Id, hiers.get(0).Id);

		if(mapAccount.get('Agency BR (P) 1').ParentId == null){
			System.assertEquals(null , mapAccount.get('Agency BR (P) 1').ParentId);
			System.assertEquals(null , mapAccount.get('Agency BR (P) 1').Top_Parent__c);
			System.assertEquals(mapAccount.get('Agency BR (P) 1').Id , mapAccount.get('Agency BR (P) 2').ParentId);
			System.assertEquals(mapAccount.get('Agency BR (P) 1').Id , mapAccount.get('Agency BR (P) 2').Top_Parent__c);
		}else{
			System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 1').ParentId);
			System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 1').Top_Parent__c);
			System.assertEquals(null , mapAccount.get('Agency BR (P) 2').ParentId);
			System.assertEquals(null, mapAccount.get('Agency BR (P) 2').Top_Parent__c);
		}

		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest26() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S1_NOTACCREDITED);
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-3));
      
        insert new List<Account>{a2,a3};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);


		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);
	
		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		Map<String,List<Agency_Authorization__c>> agencyAuthorizations = new Map<String,List<Agency_Authorization__c>>();

		For(Agency_Authorization__c aa : [Select Id, Status__c, Account__c, Account__r.IATACode__c from Agency_Authorization__c]){

			if(agencyAuthorizations.get(aa.Account__r.IATACode__c) != null)
				agencyAuthorizations.get(aa.Account__r.IATACode__c).add(aa);
			else
				agencyAuthorizations.put(aa.Account__r.IATACode__c, new List<Agency_Authorization__c>{aa});

		}

		System.assertEquals(agencyAuthorizations.get('1234561').size(),3);
		System.assertEquals(agencyAuthorizations.get('1234562'),null);
		System.assertEquals(agencyAuthorizations.get('1234563').size(),3);

		For(Agency_Authorization__c aa : agencyAuthorizations.get('1234561')){
			System.assertEquals(aa.Status__c, 'Active');
		}

		For(Agency_Authorization__c aa : agencyAuthorizations.get('1234563')){
			System.assertEquals(aa.Status__c, 'Non-Active');
		}

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest27() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
        
        insert new List<Account>{a2};

		Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (P) 1',Short_Name__c='Agency SA (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
		Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1274523',Location_Type__c='SA',Name='Agency SA (P) 2',Short_Name__c='Agency SA (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
      
        insert new List<Account>{a3,a4};

        Account a6 = new Account(IATA_ISO_Country__c = ctry2.id,ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1277561',Location_Type__c='SA',Name='Agency SA (P) 3',Short_Name__c='Agency SA (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a6;

        Account a5 = new Account(IATA_ISO_Country__c = ctry2.id,ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1299561',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P',Status__c = AMS_Utils.ACC_S9_APPROVED );

        insert a5;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a4.Id);
		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a5.Id);
		AMS_Agencies_relationhip__c rel5 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a6.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3,rel5,rel4};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		System.assertEquals('HE' , mapAccount.get('Agency HO').Location_Type__c);
		System.assertEquals('HO', mapAccount.get('Agency BR (P) 2').Location_Type__c);

		System.assertEquals(4 , rels.size());
		System.assertEquals(1 , hiers.size());

		System.assertNotEquals(hierarchy.Id, hiers.get(0).Id);

		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 1').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 1').Id , mapAccount.get('Agency SA (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 1').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 1').Id , mapAccount.get('Agency SA (P) 2').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 2').Top_Parent__c);

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest28() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
        
        insert new List<Account>{a2};

		Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (P) 1',Short_Name__c='Agency SA (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
		Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a2.Id, RecordTypeId = accountAgencyRT, IATACode__c='1274523',Location_Type__c='SA',Name='Agency SA (P) 2',Short_Name__c='Agency SA (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
      
        insert new List<Account>{a3,a4};

        Account a6 = new Account(IATA_ISO_Country__c = ctry2.id,ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1277561',Location_Type__c='SA',Name='Agency SA (P) 3',Short_Name__c='Agency SA (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a6;

        Account a5 = new Account(IATA_ISO_Country__c = ctry2.id,ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1299561',Location_Type__c='SA',Name='Agency SA (P) 4',Short_Name__c='Agency SA (P) 4', Sector__c = 'Travel Agent', Location_Class__c = 'P',Status__c = AMS_Utils.ACC_S9_APPROVED );

        insert a5;

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a2.Id, Child_Account__c = a4.Id);
		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a5.Id);
		AMS_Agencies_relationhip__c rel5 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a6.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3,rel5,rel4};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		System.assertEquals('HE' , mapAccount.get('Agency HO').Location_Type__c);

		System.assertEquals(4 , rels.size());
		System.assertEquals(1 , hiers.size());

		System.assertNotEquals(hierarchy.Id, hiers.get(0).Id);

		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest29() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-10));
        Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (P) 1',Short_Name__c='Agency SA (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1277563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
     
        insert new List<Account>{a2,a3,a4};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);


		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('PK');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'PK');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

		System.assertEquals('HE' , mapAccount.get('Agency BR (P) 2').Location_Type__c);
		System.assertEquals('AE' , mapAccount.get('Agency BR (P) 1').Location_Type__c);
		System.assertEquals('AE' , mapAccount.get('Agency SA (P) 1').Location_Type__c);
		System.assertEquals('HO' , mapAccount.get('Agency HO').Location_Type__c);

		System.assertEquals(2 , rels.size());
		System.assertEquals(1 , hiers.size());

		System.assertNotEquals(hierarchy.Id, hiers.get(0).Id);

		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);
		
		System.assertEquals(null , mapAccount.get('Agency BR (P) 2').ParentId);
		System.assertEquals(null , mapAccount.get('Agency BR (P) 2').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 1').Top_Parent__c);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 1').Top_Parent__c);



	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest30() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-20));
        Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (P) 1',Short_Name__c='Agency SA (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
		Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1277563',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-20));
     
        insert new List<Account>{a2,a3,a4};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);


		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('PK');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'PK');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

		System.assertEquals('AE' , mapAccount.get('Agency BR (P) 2').Location_Type__c);
		System.assertEquals('AE' , mapAccount.get('Agency BR (P) 1').Location_Type__c);
		System.assertEquals('HE' , mapAccount.get('Agency SA (P) 1').Location_Type__c);
		System.assertEquals('HO' , mapAccount.get('Agency HO').Location_Type__c);

		System.assertEquals(2 , rels.size());
		System.assertEquals(1 , hiers.size());

		System.assertNotEquals(hierarchy.Id, hiers.get(0).Id);

		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);
		
		System.assertEquals(null , mapAccount.get('Agency SA (P) 1').ParentId);
		System.assertEquals(null , mapAccount.get('Agency SA (P) 1').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency SA (P) 1').Id , mapAccount.get('Agency BR (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency SA (P) 1').Id , mapAccount.get('Agency BR (P) 1').Top_Parent__c);
		System.assertEquals(mapAccount.get('Agency SA (P) 1').Id , mapAccount.get('Agency BR (P) 2').ParentId);
		System.assertEquals(mapAccount.get('Agency SA (P) 1').Id , mapAccount.get('Agency BR (P) 2').Top_Parent__c);



	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest31() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Id accountStandardRT = AMS_Utils.getId('Account', 'Standard_Account');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountStandardRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Reason_for_creation__c = 'Account is missing');
		Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (P) 1',Short_Name__c='Agency SA (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
		Account a4 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountStandardRT, IATACode__c='1274523',Location_Type__c='SA',Name='Agency SA (P) 2',Short_Name__c='Agency SA (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Reason_for_creation__c = 'Account is missing');
        Account a5 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1299561',Location_Type__c='BR',Name='Agency BR (P) 2',Short_Name__c='Agency BR (P) 2', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a6 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1277561',Location_Type__c='SA',Name='Agency SA (P) 3',Short_Name__c='Agency SA (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        Account a7 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1299564',Location_Type__c='BR',Name='Agency BR (P) 3',Short_Name__c='Agency BR (P) 3', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));

        insert new List<Account>{a2,a3,a4,a5,a6,a7};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a4.Id);
		AMS_Agencies_relationhip__c rel4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a5.Id);
		AMS_Agencies_relationhip__c rel5 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a6.Id);
		AMS_Agencies_relationhip__c rel6 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a7.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2,rel3,rel5,rel4,rel6};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		System.assertEquals('HE' , mapAccount.get('Agency HO').Location_Type__c);
		System.assertEquals('HO', mapAccount.get('Agency BR (P) 2').Location_Type__c);

		System.assertEquals(5 , rels.size());
		System.assertEquals(1 , hiers.size());

		System.assertNotEquals(hierarchy.Id, hiers.get(0).Id);

		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 1').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 3').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency BR (P) 3').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 1').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 2').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 2').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 3').ParentId);
		System.assertEquals(mapAccount.get('Agency BR (P) 2').Id , mapAccount.get('Agency SA (P) 3').Top_Parent__c);


		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}

	@isTest static void ANG_ConversionHelperEnhancedTestTest32() {
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',BSP_Country_free_text__c='US' , ISO_Code__c = 'US')  ;
        insert ctry ;

		IATA_ISO_Country__c ctry2 = new IATA_ISO_Country__c (Name='PK',BSP_Country_free_text__c='PK', ISO_Code__c = 'PK')  ;
        insert ctry2 ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Id accountStandardRT = AMS_Utils.getId('Account', 'Standard_Account');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Agency HO',Short_Name__c='Agency HO', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);

        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountStandardRT, IATACode__c='1234562',Location_Type__c='BR',Name='Agency BR (P) 1',Short_Name__c='Agency BR (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Reason_for_creation__c = 'Account is missing');
		Account a3 = new Account(IATA_ISO_Country__c = ctry2.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='SA',Name='Agency SA (P) 1',Short_Name__c='Agency SA (P) 1', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S0_TERMINATED, Expiry_Date__c = Date.today().addMonths(-7));
	
        insert new List<Account>{a2,a3};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);

		insert new List<AMS_Agencies_relationhip__c>{rel1,rel2};

        Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(1,finalStruct.totalHierarchies);
		System.assertEquals(0,finalStruct.totalValidHierarchies);
		System.assertEquals(1,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);

		System.debug('Running specific migration on:'+structure.values());
		
		Id migrationBacthId = ANG_ConversionHelper.runSpecificMigration(structure.values());

		Test.stopTest();

		List<Account> accounts = [SELECT Id, IATACode__c, Name, Location_Class__c, Location_Type__c, ParentId, Top_Parent__c FROM Account];
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c];
		List<AMS_Agencies_Hierarchy__c> hiers = [SELECT Id, Name FROM AMS_Agencies_Hierarchy__c];

		Map<String,Account> mapAccount = new Map<String,Account>();

		for(Account act: accounts){

			mapAccount.put(act.Name, act);

		}

		System.assertEquals('HE' , mapAccount.get('Agency HO').Location_Type__c);
		System.assertEquals('HO', mapAccount.get('Agency SA (P) 1').Location_Type__c);

		System.assertEquals(1 , rels.size());
		System.assertEquals(1 , hiers.size());

		System.assertNotEquals(hierarchy.Id, hiers.get(0).Id);

		System.assertEquals(null , mapAccount.get('Agency HO').ParentId);
		System.assertEquals(null , mapAccount.get('Agency HO').Top_Parent__c);

		System.assertEquals(mapAccount.get('Agency SA (P) 1').Id , mapAccount.get('Agency BR (P) 1').ParentId);
		System.assertEquals(mapAccount.get('Agency SA (P) 1').Id , mapAccount.get('Agency BR (P) 1').Top_Parent__c);

		System.debug('accounts are:'+accounts);
		System.debug('rels are:'+rels);
		System.debug('hiers are:'+hiers);

	}
}