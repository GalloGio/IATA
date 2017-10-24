global with sharing class ANG_ConversionHelper {
	
	//Record Types for the Account
    public static final String ACCOUNT_AGENCY_RT     = Schema.Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Agency').getRecordTypeId();
    public static final String ACCOUNT_STANDARD_RT   = Schema.Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();

    public static final Set<String> ALLOWEDRECORDTYPES = new Set<String>{ACCOUNT_AGENCY_RT,ACCOUNT_STANDARD_RT};

    public static final Integer WRONGRECORDTYPE= -2;
    public static final Integer BRANCHABROAD= -3;
    public static final Integer WRONGLOCATIONCLASS= -4;
    public static final Integer AGENCYINMUTIPLEHIERARCHIES= -5;
    public static final Integer WRONGSECTOR= -6;
    public static final Integer MISSINGTOPPARENT = -7;
	public static final Integer ORFANBRANCH = -8;
	public static final Integer DIFFERENTTOPPARENT = -9;
	public static final Integer DEFAULTMESSAGE = -1;

    public static final Set<String> ALLOWEDLOCATIONCLASSES = new Set<String>{'P','D'};
    public static final Set<String> ALLOWEDSECTORS = new Set<String>{'Travel Agent'};

    public static final Set<String> OLDLOCATIONTYPES = new Set<String>{'BR','HO','SA','AO'};
    public static final Set<String> TOPLEVELLOCATIONTYPES = new Set<String>{'HO','AO'};

	public static final Set<String> LOCATIONTYPESNEWGEN = new Set<String>{'AE','HE'};
    
    public static Map<Integer, String> errorMessages = new Map<Integer, String> {
        -2 => 'Hierarchies with wrong Record Type',
        -3 => 'Hierarchies with branches abroad',
        -4 => 'Hierarchies with invalid location classes',
        -5 => 'Agencies in multiple hierarchies',
        -6 => 'Hierarchies with invalid agencies sectors',
        -7 => 'Hierarchies with agencies missing top parent',
        -8 => 'Orphan Branches (BR)',
		-9 => 'Different Top Parent in the Hierarchies'
    };

    public static Map<Integer, String> errorMessagesLongDescription = new Map<Integer, String> {
        -2 => Label.ANG_Conversion_Tool_Error_2,
        -3 => Label.ANG_Conversion_Tool_Error_3,
        -4 => Label.ANG_Conversion_Tool_Error_4,
        -5 => Label.ANG_Conversion_Tool_Error_5,
        -6 => Label.ANG_Conversion_Tool_Error_6,
        -7 => Label.ANG_Conversion_Tool_Error_7,
        -8 => Label.ANG_Conversion_Tool_Error_8,
		-9 => Label.ANG_Conversion_Tool_Error_9
    };

    public static boolean isMigrationTool{
		get{
			if(isMigrationTool ==null) isMigrationTool=false;
			return isMigrationTool;
		}

		Set;
	}

   public static ANG_ConversionHelper.ControllerLightStructure runFullAnalyses(String countryName){
            
        Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure(countryName);

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		return new ControllerLightStructure(ANG_ConversionHelper.fetchStatistics(structure,countryName));
            
   }
    
	public static Map<Id,ANG_ConversionHelper.HierarchyStructure> buildHierarchyStructure(String country){

		Set<Id> allAgencies = new Set<Id>();
		Set<Id> allHierarchies = new Set<Id>();

		List<AMS_Agencies_relationhip__c> allRelations = [SELECT Id, Hierarchy__r.RecordType.Name, Hierarchy__r.Name,Hierarchy__r.Migrated__c, Hierarchy__c, Child_Account__c, Parent_Account__r.IATACode__c, Parent_Account__r.Status__c, Parent_Account__r.Purge_Flag__c, Child_Account__r.IATACode__c, Child_Account__r.Purge_Flag__c, Child_Account__r.Top_Parent__c, Child_Account__r.Financial_Review_Result__c, Child_Account__r.ParentId, Child_Account__r.Location_Class__c, Child_Account__r.Location_Type__c, Child_Account__r.Status__c, Child_Account__r.RecordType.Name, Child_Account__r.IATA_ISO_Country__r.Name,Child_Account__r.Sector__c, Child_Account__r.Top_Parent__r.IATACode__c, Child_Account__r.Top_Parent__r.Location_Class__c, Child_Account__r.Top_Parent__r.Location_Type__c, Child_Account__r.Top_Parent__r.Name, Child_Account__r.Top_Parent__r.Status__c, Child_Account__r.Top_Parent__r.RecordType.Name, Child_Account__r.Top_Parent__r.Financial_Review_Result__c, Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name,Child_Account__r.Top_Parent__r.Sector__c, Child_Account__r.Top_Parent__r.Top_Parent__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Parent_Account__r.Location_Class__c, Child_Account__r.Top_Parent__r.Purge_Flag__c from AMS_Agencies_relationhip__c where Child_Account__r.Top_Parent__r.Sector__c in:ALLOWEDSECTORS and Child_Account__r.Top_Parent__r.Location_Class__c in:ALLOWEDLOCATIONCLASSES and Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name = :country and Hierarchy__r.Migrated__c = false];

		Map<Id,ANG_ConversionHelper.HierarchyStructure> toReturn = new Map<Id,ANG_ConversionHelper.HierarchyStructure>();

		for(AMS_Agencies_relationhip__c relationShip: allRelations){

			allAgencies.add(relationShip.Child_Account__c);
			allAgencies.add(relationShip.Child_Account__r.Top_Parent__c);

			if(toReturn.get(relationShip.Hierarchy__c) == null)
				toReturn.put(relationShip.Hierarchy__c,createNewHierarchyStructure(relationShip));
			else{
				toReturn.get(relationShip.Hierarchy__c).addRelation(relationShip);
			}

			allHierarchies.add(relationShip.Hierarchy__c);
		}

		List<Account> allAccountsSingleHierarchyHO = [SELECT Id, Name,Purge_Flag__c, Financial_Review_Result__c, Location_Type__c,IATACode__c, Status__c, RecordType.Name, IATA_ISO_Country__r.Name,Sector__c, Top_Parent__c from Account where Location_Type__c in :TOPLEVELLOCATIONTYPES and Sector__c in:ALLOWEDSECTORS and RecordTypeId in:ALLOWEDRECORDTYPES and Location_Class__c in:ALLOWEDLOCATIONCLASSES and IATA_ISO_Country__r.Name = :country and Id not in:allAgencies];

		for(Account acct: allAccountsSingleHierarchyHO)
			toReturn.put(acct.Id,createNewSoloHierarchyStructure(acct));

		List<Account> allAccountsSingleHierarchyBR = [SELECT Id, Name, Purge_Flag__c, Location_Type__c, Financial_Review_Result__c,IATACode__c, Status__c, RecordType.Name, IATA_ISO_Country__r.Name,Sector__c, Top_Parent__c from Account where Location_Type__c ='BR' and ParentId  = null and Sector__c in:ALLOWEDSECTORS and RecordTypeId in:ALLOWEDRECORDTYPES and Location_Class__c in:ALLOWEDLOCATIONCLASSES and IATA_ISO_Country__r.Name = :country and Id not in:allAgencies];

		for(Account acct: allAccountsSingleHierarchyBR)
			toReturn.put(acct.Id,createNewSoloHierarchyStructure(acct));

		List<AMS_Agencies_Hierarchy__c> alreadyMigratedStructures = [select Id from AMS_Agencies_Hierarchy__c where migrated__c = true and Id in (select Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name = :country)];

		for(AMS_Agencies_Hierarchy__c h: alreadyMigratedStructures){

			toReturn.put(h.Id,createNewHierarchyStructure(h));

		}


		System.debug('All hierarchies:'+allHierarchies.size());
		
		System.debug('All HO Single Accounts:'+allAccountsSingleHierarchyHO.size());

		return toReturn;
	}



	public static Map<Id,ANG_ConversionHelper.HierarchyStructure> buildSingleHierarchyStructure(String hierarchyId){

		List<AMS_Agencies_relationhip__c> allRelations = [SELECT Id, Hierarchy__r.Migrated__c, Hierarchy__r.RecordType.Name, Hierarchy__r.Name, Hierarchy__c, Child_Account__c, Parent_Account__r.IATACode__c, Parent_Account__r.Status__c, Parent_Account__r.Purge_Flag__c, Child_Account__r.Purge_Flag__c, Child_Account__r.IATACode__c, Child_Account__r.Financial_Review_Result__c, Child_Account__r.Location_Class__c, Child_Account__r.Location_Type__c, Child_Account__r.Status__c, Child_Account__r.RecordType.Name, Child_Account__r.IATA_ISO_Country__r.Name,Child_Account__r.Sector__c, Child_Account__r.Top_Parent__r.Financial_Review_Result__c, Child_Account__r.Top_Parent__r.Name, Child_Account__r.Top_Parent__r.IATACode__c, Child_Account__r.Top_Parent__r.Location_Class__c, Child_Account__r.Top_Parent__r.Location_Type__c, Child_Account__r.Top_Parent__r.Status__c, Child_Account__r.Top_Parent__r.RecordType.Name, Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name,Child_Account__r.Top_Parent__r.Sector__c, Child_Account__r.Top_Parent__r.Top_Parent__c, Parent_Account__c, Child_Account__r.Top_Parent__r.Purge_Flag__c from AMS_Agencies_relationhip__c where Hierarchy__c = :hierarchyId];

		Map<Id,ANG_ConversionHelper.HierarchyStructure> toReturn = new Map<Id,ANG_ConversionHelper.HierarchyStructure>();

		for(AMS_Agencies_relationhip__c relationShip: allRelations){

			if(toReturn.get(relationShip.Hierarchy__c) == null)
				toReturn.put(relationShip.Hierarchy__c,createNewHierarchyStructure(relationShip));
			else{
				toReturn.get(relationShip.Hierarchy__c).addRelation(relationShip);
			}
		}

		return toReturn;
	}

	public static Map<Id,ANG_ConversionHelper.HierarchyStructure> performValidationOnHierarchyStructure(Map<Id,ANG_ConversionHelper.HierarchyStructure> structure){

		List<ANG_ConversionHelper.HierarchyStructure> hierarchies = structure.values();


		// so let's validate each hierarchy accordingly to the rules
		for(ANG_ConversionHelper.HierarchyStructure struct: hierarchies){

			if(!struct.migrated)
				struct = performValidationsOnHierarchy(struct);
			
		}

		return structure;

	}

	public static boolean validateCorrectRecordTypeInAgencies(List<AMS_Agencies_relationhip__c> relationShips){

		for(AMS_Agencies_relationhip__c rel: relationShips){

			if(!(ALLOWEDRECORDTYPES.contains(rel.Child_Account__r.RecordTypeId) && ALLOWEDRECORDTYPES.contains(rel.Child_Account__r.Top_Parent__r.RecordTypeId))){
				return false;
			}
		}

		return true;

	}

	public static boolean validateCorrectLocationClasses(List<AMS_Agencies_relationhip__c> relationShips){

		for(AMS_Agencies_relationhip__c rel: relationShips){
			if(!(ALLOWEDLOCATIONCLASSES.contains(rel.Child_Account__r.Location_Class__c) && ALLOWEDLOCATIONCLASSES.contains(rel.Child_Account__r.Top_Parent__r.Location_Class__c)))
				return false;
		}

		return true;

	}

	public static boolean validateCorrectSectorInAgencies(List<AMS_Agencies_relationhip__c> relationShips){

		for(AMS_Agencies_relationhip__c rel: relationShips){
			if(!(ALLOWEDSECTORS.contains(rel.Child_Account__r.Sector__c) && ALLOWEDSECTORS.contains(rel.Child_Account__r.Top_Parent__r.Sector__c)))
				return false;
		}

		return true;

	}

	public static boolean validateCorrectHierarchyStructure(List<AMS_Agencies_relationhip__c> relationShips){

		for(AMS_Agencies_relationhip__c rel: relationShips){
			if(rel.Child_Account__r.Top_Parent__c == null || rel.Child_Account__r.Top_Parent__r.Top_Parent__c != null)
				return false;
		}

		return true;


	}

	public static boolean validateBranchesAbroad(List<AMS_Agencies_relationhip__c> relationShips){

		for(AMS_Agencies_relationhip__c rel: relationShips){
			if(rel.Child_Account__r.IATA_ISO_Country__r.Name != rel.Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name)
				return false;
		}

		return true;

	}


	public static ANG_ConversionHelper.HierarchyStructure performValidationsOnHierarchy(ANG_ConversionHelper.HierarchyStructure struct){

			if(struct.errorCategory == DIFFERENTTOPPARENT){
				struct.isValid = false;
				struct.errorCategory = DIFFERENTTOPPARENT;
				return struct;
			}

			if(!validateCorrectHierarchyStructure(struct.relations)){
				struct.isValid = false;
				struct.errorCategory = MISSINGTOPPARENT;
				return struct;
			}

			if(!validateCorrectRecordTypeInAgencies(struct.relations)){
				struct.isValid = false;
				struct.errorCategory = WRONGRECORDTYPE;
				return struct;
			}

			if(!validateCorrectLocationClasses(struct.relations)){
				struct.isValid = false;
				struct.errorCategory = WRONGLOCATIONCLASS;
				return struct;
			}

			if(!validateCorrectSectorInAgencies(struct.relations)){
				struct.isValid = false;
				struct.errorCategory = WRONGSECTOR;
				return struct;
			}

			if(!validateBranchesAbroad(struct.relations)){
				struct.isValid = false;
				struct.errorCategory = BRANCHABROAD;
				return struct;
			}

			if(struct.errorCategory == DEFAULTMESSAGE){
				struct.isValid = true;
				struct.errorCategory = 0;
			}

			return struct;

	}

	private static ANG_ConversionHelper.HierarchyStructure createNewHierarchyStructure(AMS_Agencies_relationhip__c relationShip){

		ANG_ConversionHelper.HierarchyStructure struct = new ANG_ConversionHelper.HierarchyStructure(relationShip);

		return struct;
	}

	private static ANG_ConversionHelper.HierarchyStructure createNewHierarchyStructure(AMS_Agencies_Hierarchy__c hierarchy){

		ANG_ConversionHelper.HierarchyStructure struct = new ANG_ConversionHelper.HierarchyStructure(hierarchy);

		return struct;
	}

	private Static ANG_ConversionHelper.HierarchyStructure createNewSoloHierarchyStructure(Account acct){

		ANG_ConversionHelper.HierarchyStructure struct = new ANG_ConversionHelper.HierarchyStructure(acct);

		return struct;

	}

	public static void printStatistics(ANG_ConversionHelper.StatisticGeneratorStructure struct){

		System.debug('----------------------------------');
		System.debug('Total Hierarchies:'+struct.totalHierarchies);
		System.debug('Total Valid Hierarchies:'+struct.totalValidHierarchies);
		System.debug('Total Invalid Hierarchies:'+struct.totalInvalidHierarchies);
		System.debug('Total Migrated Hierarchies (not included single agencies):'+struct.totalMigratedHierarchies);

		System.debug('Valid Hierarchies');

		for(ANG_ConversionHelper.HierarchyStructure hStructure: struct.validHierarchies.values()){

			System.debug(hStructure.nameTopParent + ' || ' + hStructure.iataCodeTopParent + ' || Hierarchy Id:' + hStructure.hierarchyId );

		}

		System.debug('::: Invalid Hierarchies :::');

		Set<Integer> errorValues = struct.inValidHierarchies.keySet();

		for(Integer errorValue: errorValues){

			System.debug('-'+errorMessages.get(errorValue)+'-');

			for(ANG_ConversionHelper.HierarchyStructure hStructure: struct.inValidHierarchies.get(errorValue)){

				System.debug('IATA Code:' + hStructure.iataCodeTopParent + ' || Hierarchy Id:' + hStructure.hierarchyId);

			}
			

		}

		System.debug('---------------------------------');


	}

	public static Id runMigration(String countryName){

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure(countryName);
		       
		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);
		        
		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,countryName);

		ANG_ConversionBatch conversionBatch = new ANG_ConversionBatch(finalStruct.validHierarchies.values());

		Id conversionBatchId = null;

		if(!Test.isRunningTest())
    		conversionBatchId = Database.executeBatch(conversionBatch,1);	
    	else
    		conversionBatchId = Database.executeBatch(conversionBatch);	

    	return conversionBatchId;

	}


	public static Id runSpecificMigration(List<ANG_ConversionHelper.HierarchyStructure> structuresToMigrate){

		ANG_ConversionBatch conversionBatch = new ANG_ConversionBatch(structuresToMigrate);

		Id conversionBatchId = null;

		if(!Test.isRunningTest())
	    	conversionBatchId= Database.executeBatch(conversionBatch,1);	
	    else
	    	conversionBatchId= Database.executeBatch(conversionBatch);

    	return conversionBatchId;

	}

	public static ANG_ConversionHelper.StatisticGeneratorStructure fetchStatistics(Map<Id,ANG_ConversionHelper.HierarchyStructure> structure,String countryName){


		ANG_ConversionHelper.StatisticGeneratorStructure toReturn = new ANG_ConversionHelper.StatisticGeneratorStructure();

		for(ANG_ConversionHelper.HierarchyStructure struct: structure.values()){
			            
			if(struct.migrated){
				
				toReturn.totalMigratedHierarchies ++;
			
			}
			else if(struct.isValid){

				toReturn.totalValidHierarchies++;

				toReturn.validHierarchies.put(struct.iataCodeTopParent + struct.hierarchyId,struct);

			}else{

				toReturn.totalInvalidHierarchies++;

				if(toReturn.inValidHierarchies.get(struct.errorCategory) == null)
					toReturn.inValidHierarchies.put(struct.errorCategory,new List<ANG_ConversionHelper.HierarchyStructure>{struct});
				else
					toReturn.inValidHierarchies.get(struct.errorCategory).add(struct);
			}

			toReturn.totalHierarchies++;

		}

		// now we need to fetch the already migrated hierarchies

		Set<Id> accountsMigrated = new Set<Id>();

		List<AMS_Agencies_relationhip__c> alreadyMigratedStructures = [Select Id, Child_Account__c, Parent_Account__c from AMS_Agencies_relationhip__c where Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name = :countryName and Hierarchy__r.Migrated__c = true];

		for(AMS_Agencies_relationhip__c rel: alreadyMigratedStructures){
			accountsMigrated.add(rel.Child_Account__c);
			accountsMigrated.add(rel.Parent_Account__c);
		}

		List<Account> allAccountsSingleHierarchyHO = [SELECT Id  from Account where Location_Type__c in :LOCATIONTYPESNEWGEN and Sector__c in:ALLOWEDSECTORS and RecordTypeId in:ALLOWEDRECORDTYPES and Location_Class__c in:ALLOWEDLOCATIONCLASSES and IATA_ISO_Country__r.Name = :countryName and Id not in:accountsMigrated];

		set<Id> accsToCreateRisks = new set<Id>();
		for(ANG_ConversionHelper.HierarchyStructure i :toReturn.validHierarchies.values()){
			accsToCreateRisks.addAll(i.allAgencies);
		}

		Map<String,Integer> nRiskEventTypes = new Map<String,Integer>();
		Map<Id, ANG_Risk_Event_Type__c> mapTypes = new Map<ID, ANG_Risk_Event_Type__c>([SELECT Name FROM ANG_Risk_Event_Type__c]);

		for(ANG_Agency_Risk_Event__c a :  (new ANG_RiskEventMigrationHelper(accsToCreateRisks)).convertChangeCodesToRiskEvents()){
			if(nRiskEventTypes.containsKey(mapTypes.get(a.ANG_Risk_Type__c).Name))
				nRiskEventTypes.put(mapTypes.get(a.ANG_Risk_Type__c).name ,nRiskEventTypes.get(mapTypes.get(a.ANG_Risk_Type__c).Name)+1);
			else
				nRiskEventTypes.put(mapTypes.get(a.ANG_Risk_Type__c).Name, 1);
		}

		toReturn.RisksToAdd = nRiskEventTypes;

		toReturn.totalMigratedHierarchies+=allAccountsSingleHierarchyHO.size();
		toReturn.totalHierarchies+=allAccountsSingleHierarchyHO.size();

		return toReturn;

	}

	public static List<ANG_ConversionHelper.HierarchyStructure> migrateStructures(List<ANG_ConversionHelper.HierarchyStructure> structures){

		System.debug('Preparing to convert:'+structures);

		ANG_ConversionHelper.isMigrationTool=true;//skip agencyEventGenerator

		Map<Id,Account> allAgenciesFinalMap = null;

		Set<Account> allAgencies = null;

		AMS_Agencies_Hierarchy__c hierarchy = null;

		Set<Account> accountsToUpdate = new Set<Account>();

		Set<AMS_Agencies_relationhip__c> relationsToUpdate = new Set<AMS_Agencies_relationhip__c>();

		Set<AMS_Agencies_Hierarchy__c> hierarchiesToUpdate = new Set<AMS_Agencies_Hierarchy__c>();

		List<ANG_ConversionHelper.HierarchyStructure> toReturn = new List<ANG_ConversionHelper.HierarchyStructure>();

		Map<Id,List<Account>> allAgenciesMap = fetchAllAgenciesInvolved(structures);

		Map<Id,AMS_Agencies_Hierarchy__c> allHierarchiesInvolvedMap = fetchAllHierarchiesInvolved(structures);

		Set<Id> topParents = new Set<Id>();

		for(ANG_ConversionHelper.HierarchyStructure struct: structures){

			allAgencies = new Set<Account>();
			allAgencies.addAll(allAgenciesMap.get(struct.hierarchyId));

			allAgenciesFinalMap = new Map<Id,Account>();

			for(Account acct: allAgencies)
				allAgenciesFinalMap.put(acct.Id,acct);

			hierarchy = allHierarchiesInvolvedMap.get(struct.hierarchyId);

			ANG_ConversionHelper.MigrationContainer container = changeStructure(struct,allAgenciesFinalMap,hierarchy);

			accountsToUpdate.addAll(container.accountsToUpdate);
			relationsToUpdate.addAll(container.relationsToUpdate);
	
			if(container.hierarchy != null)
				hierarchiesToUpdate.add(container.hierarchy);

			container.struct.migrated = true;

			toReturn.add(container.struct);
			topParents.add(container.struct.topParentId);

		}

		AMS_AgencyRelationshipTriggerHandler.isToRunTrigger = false;
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		ANG_RiskEventMigrationHelper reHelper = new ANG_RiskEventMigrationHelper(accountsToUpdate);
		update new List<Account>(accountsToUpdate);
		insert reHelper.convertChangeCodesToRiskEvents();

		update new List<AMS_Agencies_relationhip__c>(relationsToUpdate);

		update new List<AMS_Agencies_Hierarchy__c>(hierarchiesToUpdate);

		ANG_RHCHelper.createRHCInfo(topParents, true);

		AMS_AgencyRelationshipTriggerHandler.isToRunTrigger = true;
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;

		createAgencyAuthorizations(accountsToUpdate);
		
		return toReturn;

	}


	public static Map<Id,List<Account>> fetchAllAgenciesInvolved(List<ANG_ConversionHelper.HierarchyStructure> structs){

		Set<Id> accountIdsToSearch = new Set<Id>();

		Map<Id,List<Account>> toReturn = new Map<Id,List<Account>>();


		for(ANG_ConversionHelper.HierarchyStructure struct:structs){

			if(!struct.isSingleAgencyHierarchy)
				accountIdsToSearch.addAll(struct.allAgencies);
			else
				accountIdsToSearch.add(struct.topParentId);
		}

		List<Account> accountsSearched = [SELECT Id, Name, Location_Type__c, ParentId, Status__c from Account where Id in :accountIdsToSearch];

		Map<Id,Account> accountsSearchedMap = new Map<Id,Account>();

		for(Account acct: accountsSearched){
			accountsSearchedMap.put(acct.Id,acct);
		}

		for(ANG_ConversionHelper.HierarchyStructure struct:structs){

			for(Id accountId: struct.allAgencies){

				if(toReturn.get(struct.hierarchyId) == null){

					toReturn.put(struct.hierarchyId, new List<Account>{accountsSearchedMap.get(accountId)});

				}else{

					toReturn.get(struct.hierarchyId).add(accountsSearchedMap.get(accountId));
				}

			}



		}

		return toReturn;

	}

	public static Map<Id,AMS_Agencies_Hierarchy__c> fetchAllHierarchiesInvolved(List<ANG_ConversionHelper.HierarchyStructure> structs){

		Set<Id> hierarchyIdsToSearch = new Set<Id>();

		Map<Id,AMS_Agencies_Hierarchy__c> toReturn = new Map<Id,AMS_Agencies_Hierarchy__c>();


		for(ANG_ConversionHelper.HierarchyStructure struct:structs){

			if(!struct.isSingleAgencyHierarchy)
				hierarchyIdsToSearch.add(struct.hierarchyId);
		}

		
		System.debug('Found these hierarchyIdsToSearch Id:' + hierarchyIdsToSearch);

		List<AMS_Agencies_Hierarchy__c> hierarchiesSearched = [SELECT Id, Migrated__c from AMS_Agencies_Hierarchy__c where Id in :hierarchyIdsToSearch];

		System.debug('Found these:' + hierarchiesSearched);

		Map<Id,AMS_Agencies_Hierarchy__c> hierarchiesSearchedMap = new Map<Id,AMS_Agencies_Hierarchy__c>();

		for(AMS_Agencies_Hierarchy__c h: hierarchiesSearched){
			hierarchiesSearchedMap.put(h.Id,h);
		}

		for(ANG_ConversionHelper.HierarchyStructure struct:structs){

			toReturn.put(struct.hierarchyId, hierarchiesSearchedMap.get(struct.hierarchyId));
			
		}

		return toReturn;
	}

	public static ANG_ConversionHelper.MigrationContainer changeStructure(ANG_ConversionHelper.HierarchyStructure struct, Map<Id,Account> allAgencies, AMS_Agencies_Hierarchy__c hierarchy){


	
					//TODO : Pick up all accounts to be updated and proccess them again in relation to Risk Status
			/*
			
				1) Query ALL ANG_Agency_Risk_Calculation__c do record type Risk Status Assessment (with the fields Finantial Review Result and Risk History Assessement) (going to be a config table)
				2) Loop all Agencies
				 3) For each account
				 	4) Find the ANG_Agency_Risk_Calculation__c with the same Finantial Review Result and Risk History Assessement in that account
				 	5) Assign the risk status of this calculation to the account -> Risk Status
			*/



		Set<Account> accountsToUpdate = new Set<Account>();

		Set<AMS_Agencies_relationhip__c> relationsToUpdate = new Set<AMS_Agencies_relationhip__c>();

		if(struct.isSingleAgencyHierarchy){
			
			if(allAgencies.get(struct.topParentId).Location_Type__c == AMS_Utils.AO && allAgencies.get(struct.topParentId).Status__c == AMS_Utils.ACC_S4_LISTED)
				allAgencies.get(struct.topParentId).Status__c = AMS_Utils.ACC_S9_APPROVED;		
			
			allAgencies.get(struct.topParentId).Location_Type__c = 'HE';			

			allAgencies.get(struct.topParentId).ANG_Accreditation_Model__c = 'Cash';
			allAgencies.get(struct.topParentId).ANG_HE_RiskHistoryAssessment__c = 'Passed';
			allAgencies.get(struct.topParentId).ANG_HE_CashCondition__c = false;
			allAgencies.get(struct.topParentId).Is_PCI_compliant__c = 'Yes';

			accountsToUpdate.add(allAgencies.get(struct.topParentId));

		}
		else{
				for(AMS_Agencies_relationhip__c rel: struct.relations){

					rel.Is_Newgen_Relation__c = true;
					rel.Parent_Account__c = struct.topParentId;
					
					if(allAgencies.get(rel.Parent_Account__c).Location_Type__c == AMS_Utils.AO && allAgencies.get(rel.Parent_Account__c).Status__c == AMS_Utils.ACC_S4_LISTED)
						allAgencies.get(rel.Parent_Account__c).Status__c = AMS_Utils.ACC_S9_APPROVED;	

					allAgencies.get(rel.Parent_Account__c).Location_Type__c = 'HE';
					allAgencies.get(rel.Parent_Account__c).ANG_Accreditation_Model__c = 'Cash';
					allAgencies.get(rel.Parent_Account__c).ANG_HE_RiskHistoryAssessment__c = 'Passed';
					allAgencies.get(rel.Parent_Account__c).ANG_HE_CashCondition__c = false;
					allAgencies.get(rel.Parent_Account__c).Is_PCI_compliant__c = 'Yes';

					allAgencies.get(rel.Child_Account__c).Location_Type__c = 'AE';
					allAgencies.get(rel.Child_Account__c).ANG_Accreditation_Model__c = 'Cash';
					allAgencies.get(rel.Child_Account__c).ANG_HE_RiskHistoryAssessment__c = 'Passed';
					allAgencies.get(rel.Child_Account__c).ANG_HE_CashCondition__c = false;
					allAgencies.get(rel.Child_Account__c).Is_PCI_compliant__c = 'Yes';

					if(allAgencies.get(rel.Child_Account__c).ParentId != struct.topParentId)
						allAgencies.get(rel.Child_Account__c).ParentId = struct.topParentId;
					
					rel.Hierarchy__r.Migrated__c= true;

					accountsToUpdate.add(allAgencies.get(rel.Parent_Account__c));
					accountsToUpdate.add(allAgencies.get(rel.Child_Account__c));

					relationsToUpdate.add(rel);

				}
		}
		struct.migrated = true;

		if(!struct.isSingleAgencyHierarchy){
			hierarchy.Migrated__c = true;
		}
	
		return new ANG_ConversionHelper.MigrationContainer(struct,accountsToUpdate,relationsToUpdate,hierarchy);

	}

	private static void createAgencyAuthorizations(Set<Account> accts){

        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        
        ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
        
        List<Account> acctToInsert = [SELECT Id, IATACode__c, Status__c, Purge_Flag__c from Account where Id in:accts];
        
        for(Account acct:acctToInsert){

        	if(isAcctElegibleToCreateAuthorization(acct)){
        		authorizations.add(new Agency_Authorization__c(Account__c = acct.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        		authorizations.add(new Agency_Authorization__c(Account__c = acct.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        		authorizations.add(new Agency_Authorization__c(Account__c = acct.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
			}
		}

        insert authorizations;
    }

    public static boolean isAcctElegibleToCreateAuthorization(Account acct){

    	return !(acct.IATACode__c == null ||  acct.Status__c == 'New application pending' || acct.Status__c == 'Not accreditated' || acct.Purge_Flag__c == true);

    }

	public class MigrationContainer{

		ANG_ConversionHelper.HierarchyStructure struct;

		Set<Account> accountsToUpdate;

		Set<AMS_Agencies_relationhip__c> relationsToUpdate;

		AMS_Agencies_Hierarchy__c hierarchy;

		public migrationContainer(ANG_ConversionHelper.HierarchyStructure structIn,Set<Account> accountsToUpdateIn, Set<AMS_Agencies_relationhip__c> relationsToUpdateIn, AMS_Agencies_Hierarchy__c hierarchyIn){

			struct = structIn;
			accountsToUpdate = accountsToUpdateIn;
			relationsToUpdate = relationsToUpdateIn;
			hierarchy = hierarchyIn;
		}

	}

	public class StatisticGeneratorStructure{

		public Map<String,Integer> RisksToAdd{get;set;}

		public Integer totalHierarchies{get;set;}

		public Integer totalValidHierarchies{get;set;}

		public Integer totalMigratedHierarchies{get;set;}
		
		public Integer totalInvalidHierarchies{get;set;}

		public Map<String,ANG_ConversionHelper.HierarchyStructure> validHierarchies;
		
		public Map<Integer,List<ANG_ConversionHelper.HierarchyStructure>> inValidHierarchies;

		public StatisticGeneratorStructure(){

			totalHierarchies = 0;
			totalValidHierarchies =0;
			totalInvalidHierarchies =0;
			totalMigratedHierarchies =0;

			validHierarchies = new Map<String,ANG_ConversionHelper.HierarchyStructure>();
			inValidHierarchies = new Map<Integer,List<ANG_ConversionHelper.HierarchyStructure>>();

		}

		public String fetchIataCodeFromHierarchy(ANG_ConversionHelper.HierarchyStructure struct){

			return struct.iataCodeTopParent;

		}
	}


	global class HierarchyStructure{

		public boolean isSingleAgencyHierarchy;
		public Id hierarchyId;
		public Id topParentId{get;set;}
		public List<AMS_Agencies_relationhip__c> relations;
		public Boolean isValid;
		public Integer errorCategory;
		public String iataCodeTopParent{get;set;}
		public boolean migrated;
        public String nameTopParent{get;set;}
		public Set<Id> allAgencies;

		public HierarchyStructure(AMS_Agencies_Hierarchy__c hierarchy){

			isSingleAgencyHierarchy = false;
			hierarchyId = hierarchy.Id;
			topParentId = null;
			relations = new List<AMS_Agencies_relationhip__c>(); 
			iataCodeTopParent = null;
			nameTopParent = null;

			isValid = true;

			errorCategory = DEFAULTMESSAGE;
			migrated = true;

			allAgencies = new Set<Id>();

		}

		public HierarchyStructure(Account acct){

			isSingleAgencyHierarchy = true;
			hierarchyId = acct.Id;
			topParentId = acct.Id;
			relations = new List<AMS_Agencies_relationhip__c>(); 
			iataCodeTopParent = acct.IATACode__c;
			nameTopParent = acct.Name;

			isValid = TOPLEVELLOCATIONTYPES.contains(acct.Location_Type__c);

			errorCategory = isValid ? DEFAULTMESSAGE : ORFANBRANCH;
			migrated = LOCATIONTYPESNEWGEN.contains(acct.Location_Type__c);

			allAgencies = new Set<Id>();
			allAgencies.add(acct.Id);

		}

		public HierarchyStructure(AMS_Agencies_relationhip__c relationShip){

			if(allAgencies == null)
				allAgencies = new Set<Id>();

			isSingleAgencyHierarchy = false;
			hierarchyId = relationShip.Hierarchy__c;
			topParentId = relationShip.Child_Account__r.Top_Parent__r.Id;
			relations = new List<AMS_Agencies_relationhip__c>{relationShip};
			isValid = false;
			errorCategory = DEFAULTMESSAGE;
			iataCodeTopParent = relationShip.Child_Account__r.Top_Parent__r.IATACode__c;
			migrated = relationShip.Hierarchy__r.Migrated__c;
			nameTopParent = relationShip.Child_Account__r.Top_Parent__r.Name;

			allAgencies.add(relationShip.Child_Account__c);
			allAgencies.add(relationShip.Parent_Account__c);

		}

		public HierarchyStructure addRelation(AMS_Agencies_relationhip__c relationShip){

			if(relations.isEmpty())
				relations = new List<AMS_Agencies_relationhip__c>{relationShip};
			else
				relations.add(relationShip);

			if(allAgencies == null)
				allAgencies = new Set<Id>();

			allAgencies.add(relationShip.Child_Account__c);
			allAgencies.add(relationShip.Parent_Account__c);

			if(iataCodeTopParent != relationShip.Child_Account__r.Top_Parent__r.IATACode__c){
				System.debug('Warning, in the hierarchy ' + hierarchyId + ' there are different top parents:' + iataCodeTopParent + ' and ' + relationShip.Child_Account__r.Top_Parent__r.IATACode__c);
				this.errorCategory = DIFFERENTTOPPARENT;
			}


			return this;

		}
		
	} 


	global class ControllerLightStructure{

		public Map<String,Integer> risksToAdd{get;set;}

		public Integer totalHierarchies{get;set;}

		public Integer totalValidHierarchies{get;set;}

		public Integer totalMigratedHierarchies{get;set;}
		
		public Integer totalInvalidHierarchies{get;set;}
		
		public Map<Integer,List<ANG_ConversionHelper.HierarchyStructure>> inValidHierarchies;

		public ControllerLightStructure(StatisticGeneratorStructure struct){
			this.risksToAdd = struct.risksToAdd;

			this.totalHierarchies = struct.totalHierarchies;

			this.totalValidHierarchies = struct.totalValidHierarchies;
			
			this.totalMigratedHierarchies = struct.totalMigratedHierarchies;
			
			this.totalInvalidHierarchies = struct.totalInvalidHierarchies;

			this.inValidHierarchies = struct.inValidHierarchies;

		}


	}

	global class ConversionBatchItem{

		public String run;
		public String iataCode;
		public String hierarchyId;
		public String batchId;
		public String topParentId;
		public boolean isError;
		public String errorMessage;

		public ConversionBatchItem(HierarchyStructure struct, Integer run, String batchId, boolean isError, String errorMessage){

			this.run = String.valueOf(run);
			this.hierarchyId = struct.hierarchyId;
			this.iataCode = struct.iataCodeTopParent;
			this.batchId = batchId;
			this.topParentId = struct.topParentId;
			this.isError = isError;
			this.errorMessage = errorMessage;

		}

		public override String toString(){

			String toReturn = '';

			if(this.isError){

				toReturn+='Run:' + this.run+'\n';
				toReturn+='Hierarchy:'+this.hierarchyId+'\n';
				toReturn+='Top Parent Id:'+this.topParentId+'\n';
				toReturn+='IATA Code:'+this.iataCode+'\n';
				toReturn+='Error:'+errorMessage+'\n';
			}
			else{
				toReturn+='IATA Code:'+this.iataCode+' || Hierarchy: ' + hierarchyId +  '\n';
			}

			return toReturn;

		}


	} 

}
