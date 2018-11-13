@isTest
private class ANG_ConversionHelperTest {
	
	@testSetup static void setup(){
        
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        Account aw1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Test1 Agency NOK',Short_Name__c='Test1 Agency NOK', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
        insert new List<Account>{a1, aw1};

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Test3 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        Account aw2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Test2 Agency NOK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        Account aw3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Test3 Agency NOK',Short_Name__c='Test1 Agency', Sector__c = 'Cargo Agent',  Location_Class__c = 'P');
         
		insert new List<Account>{a2, a3,aw2,aw3};
 
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Test4 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        Account aw4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Test4 Agency NOK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'C');
        
        Account a5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='HO',Name='Test5 Agency OK',Short_Name__c='Test5 Agency OK', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        Account aw5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Test5 Agency NOK',Short_Name__c='Test5 Agency NOK', Sector__c = 'Travel Agent', Location_Class__c = 'P');
		
        Account a6 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='BR',Name='Test6 Agency OK',Short_Name__c='Test6 Agency NOK', Sector__c = 'Travel Agent', Location_Class__c = 'P');
		Account aw6 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw5.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Test6 Agency NOK',Short_Name__c='Test1 Agency', Sector__c = 'Cargo Agent', Location_Class__c = 'P');
	
        insert new List<Account>{a4,aw4, a5,aw5, a6,aw6};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1 OK');
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2 NOK');
		AMS_Agencies_Hierarchy__c hierarchy3 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 3 NOK');
		insert new list<AMS_Agencies_Hierarchy__c>{hierarchy,hierarchy2,hierarchy3};

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a3.Id, Child_Account__c = a4.Id);
		AMS_Agencies_relationhip__c relw1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy2.Id, Parent_Account__c = aw1.Id, Child_Account__c = aw2.Id);
		AMS_Agencies_relationhip__c relw2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy2.Id, Parent_Account__c = aw1.Id, Child_Account__c = aw3.Id);
		AMS_Agencies_relationhip__c relw3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy2.Id, Parent_Account__c = aw3.Id, Child_Account__c = aw4.Id);

		AMS_Agencies_relationhip__c relw4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy3.Id, Parent_Account__c = aw5.Id, Child_Account__c = aw6.Id);

        insert new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3,relw1, relw2, relw3,relw4};

		
    }

	@isTest static void executeAnalyses() {

		Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(5,finalStruct.totalHierarchies);
		System.assertEquals(2,finalStruct.totalValidHierarchies);
		System.assertEquals(3,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);


		Test.stopTest();
		
	}

	@isTest static void executeAnalysesForSingleHierarchy() {

		Test.startTest();

		AMS_Agencies_Hierarchy__c hierarchy = [SELECT Id, Migrated__c from AMS_Agencies_Hierarchy__c LIMIT 1];

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildSingleHierarchyStructure(hierarchy.Id);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		ANG_ConversionHelper.HierarchyStructure singleStruct = structure.values().get(0);

		String iataCode = finalStruct.fetchIataCodeFromHierarchy(singleStruct);

		Test.stopTest();
		
	}


	@isTest static void migrateStructures() {

		Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		Map<String,ANG_ConversionHelper.HierarchyStructure> validStruct = finalStruct.validHierarchies;

		System.assertEquals(2,validStruct.values().size());

		// now the update part.

		ANG_ConversionHelper.migrateStructures(validStruct.values());

		Map<Id,ANG_ConversionHelper.HierarchyStructure> newStructure = ANG_ConversionHelper.buildHierarchyStructure('US');

		newStructure = ANG_ConversionHelper.performValidationOnHierarchyStructure(newStructure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStructNew = ANG_ConversionHelper.fetchStatistics(newStructure,'US');

		ANG_ConversionHelper.printStatistics(finalStructNew);

		System.assertEquals(5,finalStructNew.totalHierarchies);
		
		// this finalStructNew.totalMigratedHierarchies is only 1 because one of the hierarchies envolved wasn't really an hierarchy, was just an HO that became HE. In the fetchStatistics method, we don't have a way to
		// distinguish between regular HE or migrated HO. This is also why we only have 4 agencies when fetching statistics.

		System.assertEquals(2,finalStructNew.totalMigratedHierarchies);
		
		System.assertEquals(0,finalStructNew.totalValidHierarchies);

		System.assertEquals(3,finalStructNew.totalInvalidHierarchies);

		List<Account> accountsChanged = [SELECT Id, ParentId , Location_Type__c, Top_Parent__c from Account];
		
		Map<Id,Account> accountsChangedMap =new Map<Id,Account>();

		for(Account acct: accountsChanged)
			accountsChangedMap.put(acct.Id, acct);

		Account acct =null;
		
		// validate if all the accounts have the same parent id and top parent, or if it's an HE it doesn't have any
		for(ANG_ConversionHelper.HierarchyStructure struct: validStruct.values()){
			if(!struct.isSingleAgencyHierarchy){
				for(Id acctId : struct.allAgencies){

					acct =accountsChangedMap.get(acctId);

					if(acct.Id != struct.topParentId){
						System.assertEquals(struct.topParentId, acct.ParentId);
						System.assertEquals(struct.topParentId, acct.Top_Parent__c);
						System.assertEquals('AE', acct.Location_type__c);
					}
					else{
						System.assertEquals(null, acct.ParentId);
						System.assertEquals(null, acct.Top_Parent__c);
						System.assertEquals('HE', acct.Location_type__c);
					}
				}
			}
		}
		
		Test.stopTest();
		
	}

	@isTest static void migrateStructuresBatch() {

		Test.startTest();

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,'US');

		Map<String,ANG_ConversionHelper.HierarchyStructure> validStruct = finalStruct.validHierarchies;

		System.assertEquals(2,validStruct.values().size());

		// now the update part.

    	Id conversionBatchId = ANG_ConversionHelper.runMigration('US');

		Test.stopTest();

		// Check batch status - IF COMPLETED then 
    	AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :conversionBatchId];  

    	System.debug('Status of the batch is:' + a.status + ' whith JobItemsProcessed ' + a.JobItemsProcessed + ' and with ' + a.NumberOfErrors + ' errors.');

		System.assertEquals('Completed',a.status);

		Map<Id,ANG_ConversionHelper.HierarchyStructure> newStructure = ANG_ConversionHelper.buildHierarchyStructure('US');

		newStructure = ANG_ConversionHelper.performValidationOnHierarchyStructure(newStructure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStructNew = ANG_ConversionHelper.fetchStatistics(newStructure,'US');

		ANG_ConversionHelper.printStatistics(finalStructNew);

		System.assertEquals(5,finalStructNew.totalHierarchies);
		
		// this finalStructNew.totalMigratedHierarchies is only 1 because one of the hierarchies envolved wasn't really an hierarchy, was just an HO that became HE. In the fetchStatistics method, we don't have a way to
		// distinguish between regular HE or migrated HO. This is also why we only have 4 agencies when fetching statistics.

		System.assertEquals(2,finalStructNew.totalMigratedHierarchies);
		
		System.assertEquals(0,finalStructNew.totalValidHierarchies);

		System.assertEquals(3,finalStructNew.totalInvalidHierarchies);
		
	}
	
	
}