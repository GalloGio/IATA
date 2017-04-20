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
	public static final Integer DEFAULTMESSAGE = -1;

    public static final Set<String> ALLOWEDLOCATIONCLASSES = new Set<String>{'P','D','T','F'};
    public static final Set<String> ALLOWEDSECTORS = new Set<String>{'Travel Agent'};

    public static final Set<String> OLDLOCATIONTYPES = new Set<String>{'BR','HO','SA','AO'};
    public static final Set<String> TOPLEVELLOCATIONTYPES = new Set<String>{'HO','AO'};

	public static final Set<String> LOCATIONTYPESNEWGEN = new Set<String>{'AE','HE'};
    
    public static Map<Integer, String> errorMessages = new Map<Integer, String> {
        -2 => 'Hierarchy with wrong Record Type',
        -3 => 'Hierarchy with branches abroad',
        -4 => 'Hierarchy with invalid location classes',
        -5 => 'Agencies in multiple hierarchies',
        -6 => 'Hierarchy with invalid sectors',
        -7 => 'Hierarchy is missing top parent',
        -8 => 'Orfan Branch'
    };   


	public static Map<Id,ANG_ConversionHelper.HierarchyStructure> buildHierarchyStructure(String country){

		Set<Id> allAgencies = new Set<Id>();
		Set<Id> allHierarchies = new Set<Id>();

		List<AMS_Agencies_relationhip__c> allRelations = [SELECT Id, Hierarchy__r.RecordType.Name, Hierarchy__r.Name,Hierarchy__r.Migrated__c, Hierarchy__c, Child_Account__c, Child_Account__r.Top_Parent__c, Child_Account__r.ParentId, Child_Account__r.Location_Class__c, Child_Account__r.Location_Type__c, Child_Account__r.Status__c, Child_Account__r.RecordType.Name, Child_Account__r.IATA_ISO_Country__r.Name,Child_Account__r.Sector__c, Child_Account__r.Top_Parent__r.IATACode__c, Child_Account__r.Top_Parent__r.Location_Class__c, Child_Account__r.Top_Parent__r.Location_Type__c, Child_Account__r.Top_Parent__r.Name, Child_Account__r.Top_Parent__r.Status__c, Child_Account__r.Top_Parent__r.RecordType.Name, Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name,Child_Account__r.Top_Parent__r.Sector__c, Child_Account__r.Top_Parent__r.Top_Parent__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Parent_Account__r.Location_Class__c from AMS_Agencies_relationhip__c where Child_Account__r.Top_Parent__r.Sector__c in:ALLOWEDSECTORS and Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name = :country and Hierarchy__r.Migrated__c = false];

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

		List<Account> allAccountsInvolved = [Select Id, Name, Location_Type__c, Top_Parent__c, ParentId from Account where Id in :allAgencies];

		List<AMS_Agencies_Hierarchy__c> allHierarchiesInvolved = [Select Id, Migrated__c from AMS_Agencies_Hierarchy__c where Id in :allHierarchies];


		For(ANG_ConversionHelper.HierarchyStructure toReturnStruct :toReturn.values()){

			toReturnStruct.fillAgencies(allAccountsInvolved,allHierarchiesInvolved);
		}

		List<Account> allAccountsSingleHierarchyHO = [SELECT Id, Name, Location_Type__c,IATACode__c, Status__c, RecordType.Name, IATA_ISO_Country__r.Name,Sector__c, Top_Parent__c from Account where Location_Type__c in :TOPLEVELLOCATIONTYPES and Sector__c in:ALLOWEDSECTORS and RecordTypeId in:ALLOWEDRECORDTYPES and Location_Class__c in:ALLOWEDLOCATIONCLASSES and IATA_ISO_Country__r.Name = :country and Id not in:allAgencies];

		for(Account acct: allAccountsSingleHierarchyHO)
			toReturn.put(acct.Id,createNewSoloHierarchyStructure(acct));

		List<Account> allAccountsSingleHierarchyBR = [SELECT Id, Name, Location_Type__c,IATACode__c, Status__c, RecordType.Name, IATA_ISO_Country__r.Name,Sector__c, Top_Parent__c from Account where Location_Type__c ='BR' and ParentId  = null and Sector__c in:ALLOWEDSECTORS and RecordTypeId in:ALLOWEDRECORDTYPES and Location_Class__c in:ALLOWEDLOCATIONCLASSES and IATA_ISO_Country__r.Name = :country and Id not in:allAgencies];

		for(Account acct: allAccountsSingleHierarchyBR)
			toReturn.put(acct.Id,createNewSoloHierarchyStructure(acct));

		return toReturn;
	}



	public static Map<Id,ANG_ConversionHelper.HierarchyStructure> buildSingleHierarchyStructure(String hierarchyId){

		List<AMS_Agencies_relationhip__c> allRelations = [SELECT Id, Hierarchy__r.Migrated__c, Hierarchy__r.RecordType.Name, Hierarchy__r.Name, Hierarchy__c, Child_Account__c, Child_Account__r.Location_Class__c, Child_Account__r.Location_Type__c, Child_Account__r.Status__c, Child_Account__r.RecordType.Name, Child_Account__r.IATA_ISO_Country__r.Name,Child_Account__r.Sector__c, Child_Account__r.Top_Parent__r.Name, Child_Account__r.Top_Parent__r.IATACode__c, Child_Account__r.Top_Parent__r.Location_Class__c, Child_Account__r.Top_Parent__r.Location_Type__c, Child_Account__r.Top_Parent__r.Status__c, Child_Account__r.Top_Parent__r.RecordType.Name, Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name,Child_Account__r.Top_Parent__r.Sector__c, Child_Account__r.Top_Parent__r.Top_Parent__c, Parent_Account__c from AMS_Agencies_relationhip__c where Hierarchy__c = :hierarchyId];

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


	public static ANG_ConversionHelper.HierarchyStructure performValidationsOnHierarchy(ANG_ConversionHelper.HierarchyStructure struct){

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


	private Static ANG_ConversionHelper.HierarchyStructure createNewSoloHierarchyStructure(Account acct){

		ANG_ConversionHelper.HierarchyStructure struct = new ANG_ConversionHelper.HierarchyStructure(acct);

		return struct;

	}

	public static void printStatistics(ANG_ConversionHelper.StatisticGeneratorStructure struct){

		System.debug('---------------------------------');
		System.debug('Total Hierarchies:'+struct.totalHierarchies);
		System.debug('Total Valid Hierarchies:'+struct.totalValidHierarchies);
		System.debug('Total Invalid Hierarchies:'+struct.totalInvalidHierarchies);
		System.debug('Total Migrated Hierarchies:'+struct.totalMigratedHierarchies);

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


	public static ANG_ConversionHelper.StatisticGeneratorStructure fetchStatistics(Map<Id,ANG_ConversionHelper.HierarchyStructure> structure){


		ANG_ConversionHelper.StatisticGeneratorStructure toReturn = new ANG_ConversionHelper.StatisticGeneratorStructure();

		for(ANG_ConversionHelper.HierarchyStructure struct: structure.values()){

			if(struct.migrated){

				toReturn.totalMigratedHierarchies ++;
			
			}
			else if(struct.isValid){

				toReturn.totalValidHierarchies++;

				toReturn.validHierarchies.put(struct.iataCodeTopParent,struct);

			}else{

				toReturn.totalInvalidHierarchies++;

				if(toReturn.inValidHierarchies.get(struct.errorCategory) == null)
					toReturn.inValidHierarchies.put(struct.errorCategory,new List<ANG_ConversionHelper.HierarchyStructure>{struct});
				else
					toReturn.inValidHierarchies.get(struct.errorCategory).add(struct);
			}

			toReturn.totalHierarchies++;

		}

		return toReturn;

	}

	public static List<ANG_ConversionHelper.HierarchyStructure> migrateStructures(List<ANG_ConversionHelper.HierarchyStructure> structures){

		Set<Account> accountsToUpdate = new Set<Account>();

		Set<AMS_Agencies_relationhip__c> relationsToUpdate = new Set<AMS_Agencies_relationhip__c>();

		Set<AMS_Agencies_Hierarchy__c> hierarchiesToUpdate = new Set<AMS_Agencies_Hierarchy__c>();

		List<ANG_ConversionHelper.HierarchyStructure> toReturn = new List<ANG_ConversionHelper.HierarchyStructure>();

		for(ANG_ConversionHelper.HierarchyStructure struct: structures){

			ANG_ConversionHelper.MigrationContainer container = changeStructure(struct);

			accountsToUpdate.addAll(container.accountsToUpdate);
			relationsToUpdate.addAll(container.relationsToUpdate);
	
			if(container.hierarchy != null)
				hierarchiesToUpdate.add(container.hierarchy);

			container.struct.migrated = true;

			toReturn.add(container.struct);

		}

		AMS_AgencyRelationshipTriggerHandler.isToRunTrigger = false;

		update new List<Account>(accountsToUpdate);

		update new List<AMS_Agencies_relationhip__c>(relationsToUpdate);

		update new List<AMS_Agencies_Hierarchy__c>(hierarchiesToUpdate);

		AMS_AgencyRelationshipTriggerHandler.isToRunTrigger = true;
		
		return toReturn;

	}


	public static ANG_ConversionHelper.MigrationContainer changeStructure(ANG_ConversionHelper.HierarchyStructure struct){


		Set<Account> accountsToUpdate = new Set<Account>();

		Set<AMS_Agencies_relationhip__c> relationsToUpdate = new Set<AMS_Agencies_relationhip__c>();

		if(struct.isSingleAgencyHierarchy){
			struct.allAgencies.get(struct.topParentId).Location_Type__c = 'HE';
			accountsToUpdate.add(struct.allAgencies.get(struct.topParentId));
		}
		else{
				for(AMS_Agencies_relationhip__c rel: struct.relations){

					rel.Parent_Account__c = struct.topParentId;
					
					struct.allAgencies.get(rel.Parent_Account__c).Location_Type__c = 'HE';

					struct.allAgencies.get(rel.Child_Account__c).Location_Type__c = 'AE';

					if(struct.allAgencies.get(rel.Child_Account__c).ParentId != struct.topParentId)
						struct.allAgencies.get(rel.Child_Account__c).ParentId = struct.topParentId;
					
					rel.Hierarchy__r.Migrated__c= true;

					accountsToUpdate.add(struct.allAgencies.get(rel.Parent_Account__c));
					accountsToUpdate.add(struct.allAgencies.get(rel.Child_Account__c));

					relationsToUpdate.add(rel);

				}
		}
		struct.migrated = true;

		if(!struct.isSingleAgencyHierarchy)
			struct.hierarchy.Migrated__c = true;
	
		return new ANG_ConversionHelper.MigrationContainer(struct,accountsToUpdate,relationsToUpdate,struct.hierarchy);

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
		public Id topParentId;
		public List<AMS_Agencies_relationhip__c> relations;
		public Boolean isValid;
		public Integer errorCategory;
		public String iataCodeTopParent;
		public boolean migrated;
		public String nameTopParent;
		public Map<Id,Account> allAgencies;
		public AMS_Agencies_Hierarchy__c hierarchy;

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

			allAgencies = new Map<Id,Account>();
			allAgencies.put(acct.Id, acct);

		}

		public HierarchyStructure(AMS_Agencies_relationhip__c relationShip){

			isSingleAgencyHierarchy = false;
			hierarchyId = relationShip.Hierarchy__c;
			topParentId = relationShip.Child_Account__r.Top_Parent__r.Id;
			relations = new List<AMS_Agencies_relationhip__c>{relationShip};
			isValid = false;
			errorCategory = DEFAULTMESSAGE;
			iataCodeTopParent = relationShip.Child_Account__r.Top_Parent__r.IATACode__c;
			migrated = relationShip.Hierarchy__r.Migrated__c;
			nameTopParent = relationShip.Child_Account__r.Top_Parent__r.Name;

		}

		public void fillAgencies(List<Account> accounts, List<AMS_Agencies_Hierarchy__c> hierarches){

			if(allAgencies == null)
				allAgencies = new Map<Id,Account>();
			
			Map<Id,Account> accountIds = new Map<Id,Account>();

			For(Account acct: accounts)
				accountIds.put(acct.Id,acct);

			Map<Id,AMS_Agencies_Hierarchy__c> hierarchyIds = new Map<Id,AMS_Agencies_Hierarchy__c>();

			For(AMS_Agencies_Hierarchy__c hier: hierarches)
				hierarchyIds.put(hier.Id,hier);

			For(Account acct: accounts){
				For(AMS_Agencies_relationhip__c rel: relations){
				
					if(accountIds.containsKey(rel.Child_Account__c))
						allAgencies.put(rel.Child_Account__c,accountIds.get(rel.Child_Account__c));
				
					if(hierarchyIds.containsKey(rel.Hierarchy__c))
						hierarchy = hierarchyIds.get(rel.Hierarchy__c);
				}
			}

			if(accountIds.containsKey(topParentId))
				allAgencies.put(topParentId,accountIds.get(topParentId));

		}



		
		/* Not used but could be in the future if needed.

		public HierarchyStructure(List<AMS_Agencies_relationhip__c> relationShips){

			if(relationShips.isEmpty())
				return;

			hierarchyId = relationShips.get(0).Hierarchy__c;
			topParentId = relationShips.get(0).Child_Account__r.Top_Parent__r.Id;
			relations = new List<AMS_Agencies_relationhip__c>();
			relations.addAll(relationShips);
			isValid = false;
			errorCategory = DEFAULTMESSAGE;
			iataCodeTopParent = relationShips.get(0).Child_Account__r.Top_Parent__r.IATACode__c;
		}*/

		public HierarchyStructure addRelation(AMS_Agencies_relationhip__c relationShip){

			if(relations.isEmpty())
				relations = new List<AMS_Agencies_relationhip__c>{relationShip};
			else
				relations.add(relationShip);

			return this;

		}
		
	} 

}