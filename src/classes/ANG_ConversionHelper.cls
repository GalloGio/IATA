global with sharing class ANG_ConversionHelper {
	
	//Record Types for the Account
    public static final String ACCOUNT_AGENCY_RT     = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
    public static final String ACCOUNT_STANDARD_RT   = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account') ;

    public static final Set<String> ALLOWEDRECORDTYPES = new Set<String>{ACCOUNT_AGENCY_RT,ACCOUNT_STANDARD_RT};

    public static final Set<String> INVALIDAGENCYSTATUS = new Set<String>{AMS_utils.ACC_S2_NEWAPPLICATIONPENDING,AMS_utils.ACC_S1_NOTACCREDITED,'',null,AMS_utils.ACC_S3_NOTINOPERATION, 'Not Accredited'};

    public static final Set<String> ACTIVEAGENCYSTATUS = new Set<String>{AMS_Utils.ACC_S9_APPROVED,AMS_Utils.ACC_S5_CASHNOCOMMISSION,AMS_Utils.ACC_S6_CASHWITHCOMMISSION,AMS_Utils.ACC_S8_CHANGESPROCESSED,AMS_Utils.ACC_S4_LISTED,AMS_Utils.ACC_S7_UNDERREVIEW,'Endorsed','On hold','Review'};
    public static final Set<String> INACTIVEAGENCYSTATUS = new Set<String>{AMS_Utils.ACC_S1_NOTACCREDITED,'Not Accredited',AMS_Utils.ACC_S3_NOTINOPERATION,AMS_Utils.ACC_S0_TERMINATED};
    public static final Set<String> BLANKAGENCYSTATUS = new Set<String>{'',null,AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING};

    public static final Integer WRONGRECORDTYPE= -2;
    public static final Integer BRANCHABROAD= -3;
    public static final Integer WRONGLOCATIONCLASS= -4;
    public static final Integer AGENCYINMUTIPLEHIERARCHIES= -5;
    public static final Integer WRONGSECTOR= -6;
    public static final Integer MISSINGTOPPARENT = -7;
	public static final Integer ORFANBRANCH = -8;
	public static final Integer DIFFERENTTOPPARENT = -9;
	public static final Integer BRDIFFCOUNTRY = -10;
	public static final Integer DEFAULTMESSAGE = -1;

	public static final String TIDSLOCALTIONCLASS = 'T';

    public static final Set<String> ALLOWEDLOCATIONCLASSES = new Set<String>{'P','D'};
    public static final Set<String> ALLOWEDSECTORS = new Set<String>{'Travel Agent'};

    public static final Set<String> OLDLOCATIONTYPES = new Set<String>{'BR','HO','SA','AO'};
    public static final Set<String> TOPLEVELLOCATIONTYPES = new Set<String>{'HO','AO'};

	public static final Set<String> LOCATIONTYPESNEWGEN = new Set<String>{'AE','HE'};

    public static Set<String> LOCATIONTYPESBRS {

    	get{
    		if(LOCATIONTYPESBRS == null){

		    	Set<String> pickListValuesList= new Set<String>();

				Schema.DescribeFieldResult fieldResult = Account.Location_Type__c.getDescribe();

				List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

				for( Schema.PicklistEntry pickListVal : ple){

					String valuePickList = pickListVal.getValue();

					if((!(LOCATIONTYPESNEWGEN.contains(valuePickList) || TOPLEVELLOCATIONTYPES.contains(valuePickList))) && pickListVal.isActive())
						pickListValuesList.add(valuePickList);

				}    

				LOCATIONTYPESBRS = pickListValuesList;

    		}

			return LOCATIONTYPESBRS;
    	}

    	Set;
    }
    
    public static Map<Integer, String> errorMessages = new Map<Integer, String> {
        -2 => 'Hierarchies with wrong Record Type',
        -3 => 'Hierarchies with branches abroad',
        -4 => 'Hierarchies with invalid location classes',
        -5 => 'Agencies in multiple hierarchies',
        -6 => 'Hierarchies with invalid agencies sectors',
        -7 => 'Hierarchies with agencies missing top parent',
        -8 => 'Orphan Branches (BR,SA,ST,etc.)',
		-9 => 'Different Top Parent in the Hierarchies',
		-10 => 'Branches Abroad in a different country Hierarchies'
    };

    public static Map<Integer, String> errorMessagesLongDescription = new Map<Integer, String> {
        -2 => Label.ANG_Conversion_Tool_Error_2,
        -3 => Label.ANG_Conversion_Tool_Error_3,
        -4 => Label.ANG_Conversion_Tool_Error_4,
        -5 => Label.ANG_Conversion_Tool_Error_5,
        -6 => Label.ANG_Conversion_Tool_Error_6,
        -7 => Label.ANG_Conversion_Tool_Error_7,
        -8 => Label.ANG_Conversion_Tool_Error_8,
		-9 => Label.ANG_Conversion_Tool_Error_9,
		-10 => Label.ANG_Conversion_Tool_Error_10
    };

    public static boolean isMigrationTool{
		get{
			if(isMigrationTool ==null) isMigrationTool=false;
			return isMigrationTool;
		}

		Set;
	}

    public static boolean isMigrationToolAnalyses{
		get{
			if(isMigrationToolAnalyses ==null) isMigrationToolAnalyses=false;
			return isMigrationToolAnalyses;
		}

		Set;
	}


   public static ANG_ConversionHelper.ControllerLightStructure runFullAnalyses(String countryName){
         
		Set<Id> allAgenciesGlobal = new Set<Id>();

        Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure(countryName);

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		for(ANG_ConversionHelper.HierarchyStructure struct: structure.values()){
			if(struct.isValid){
				if(struct.isSingleAgencyHierarchy)
					allAgenciesGlobal.add(struct.topParentId);
				else{
					for(AMS_Agencies_relationhip__c rel: struct.relations){
						allAgenciesGlobal.add(rel.Child_Account__c);
						allAgenciesGlobal.add(rel.Parent_Account__c);
					}
				}
			}
		}

		system.debug('Total of valid agencies is:'+allAgenciesGlobal.size());

		return new ControllerLightStructure(ANG_ConversionHelper.fetchStatistics(structure,countryName));
            
   }
    
	public static Map<Id,ANG_ConversionHelper.HierarchyStructure> buildHierarchyStructure(String country){

		Set<Id> allAgencies = new Set<Id>();
		Set<Id> allHierarchies = new Set<Id>();

		List<AMS_Agencies_relationhip__c> allRelations = [SELECT Id, Hierarchy__r.RecordType.Name, Hierarchy__r.Name,Hierarchy__r.Migrated__c, Hierarchy__c, Child_Account__c, Parent_Account__r.IATACode__c, Parent_Account__r.Status__c, Parent_Account__r.Purge_Flag__c, Child_Account__r.IATACode__c, Child_Account__r.Purge_Flag__c, Child_Account__r.Top_Parent__c, Child_Account__r.Financial_Review_Result__c, Child_Account__r.ParentId, Child_Account__r.Location_Type__c, Child_Account__r.Status__c, Child_Account__r.RecordType.Name, Child_Account__r.IATA_ISO_Country__r.Name,Child_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c,Parent_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c,Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP_Country_free_text__c, Parent_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP_Country_free_text__c,Child_Account__r.IATA_ISO_Country__r.BSP__c,Parent_Account__r.IATA_ISO_Country__r.BSP__c,Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP__c, Parent_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP__c,Child_Account__r.IATA_ISO_Country__r.ISO_Code__c ,Parent_Account__r.IATA_ISO_Country__r.ISO_Code__c ,Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.ISO_Code__c , Parent_Account__r.Top_Parent__r.IATA_ISO_Country__r.ISO_Code__c ,Child_Account__r.Sector__c, Child_Account__r.Top_Parent__r.IATACode__c, Child_Account__r.Top_Parent__r.Location_Type__c, Child_Account__r.Top_Parent__r.Name, Child_Account__r.Top_Parent__r.Status__c, Child_Account__r.Top_Parent__r.RecordType.Name, Child_Account__r.Top_Parent__r.Financial_Review_Result__c, Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name,Child_Account__r.Top_Parent__r.Sector__c, Child_Account__r.Top_Parent__r.Top_Parent__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Top_Parent__r.Purge_Flag__c, Child_Account__r.Expiry_Date__c, Parent_Account__r.Expiry_Date__c, Child_Account__r.Top_Parent__r.Expiry_Date__c, Child_Account__r.Location_Class__c, Parent_Account__r.Location_Class__c, Child_Account__r.Top_Parent__r.Location_Class__c, Parent_Account__r.Top_Parent__r.Location_Class__c from AMS_Agencies_relationhip__c where Child_Account__r.Top_Parent__r.Location_Type__c in:TOPLEVELLOCATIONTYPES and Child_Account__r.Top_Parent__r.Sector__c in:ALLOWEDSECTORS and Child_Account__r.Top_Parent__r.Location_Class__c in:ALLOWEDLOCATIONCLASSES and Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name = :country and Hierarchy__r.Migrated__c = false];

		Map<Id,ANG_ConversionHelper.HierarchyStructure> toReturn = new Map<Id,ANG_ConversionHelper.HierarchyStructure>();

		Date frontierDate = Date.today().addMonths(-6);

		for(AMS_Agencies_relationhip__c relationShip: allRelations){

			if(relationShip.child_Account__r.Top_Parent__r.Status__c == AMS_Utils.ACC_S0_TERMINATED && relationShip.Child_Account__r.Top_Parent__r.Expiry_Date__c < frontierDate) // let's ignore it
				continue;

			allAgencies.add(relationShip.Child_Account__c);
			allAgencies.add(relationShip.Child_Account__r.Top_Parent__c);

			if(toReturn.get(relationShip.Hierarchy__c) == null)
				toReturn.put(relationShip.Hierarchy__c,createNewHierarchyStructure(relationShip));
			else{
				toReturn.get(relationShip.Hierarchy__c).addRelation(relationShip);
			}

			allHierarchies.add(relationShip.Hierarchy__c);
		}

		List<Account> allAccountsSingleHierarchyHOorTerminatedAgencies = [SELECT Id, Name,Purge_Flag__c, Financial_Review_Result__c, Location_Type__c,IATACode__c, Status__c, RecordType.Name, IATA_ISO_Country__r.BSP_Country_free_text__c, IATA_ISO_Country__r.ISO_Code__c, IATA_ISO_Country__r.BSP__c,IATA_ISO_Country__r.Name,Sector__c, Top_Parent__c, Top_Parent__r.IATA_ISO_Country__r.BSP__c,Top_Parent__r.IATA_ISO_Country__r.Name,  Expiry_Date__c, Location_Class__c from Account where IATA_ISO_Country__r.Name = :country and Id not in:allAgencies AND ((Location_Type__c in :TOPLEVELLOCATIONTYPES and Sector__c in:ALLOWEDSECTORS and RecordTypeId in:ALLOWEDRECORDTYPES and Location_Class__c in:ALLOWEDLOCATIONCLASSES AND Status__c != :AMS_Utils.ACC_S0_TERMINATED) OR (Status__c = :AMS_Utils.ACC_S0_TERMINATED and Sector__c in:ALLOWEDSECTORS and Location_Class__c in:ALLOWEDLOCATIONCLASSES and Location_Type__c not in:LOCATIONTYPESNEWGEN)) ];

		for(Account acct: allAccountsSingleHierarchyHOorTerminatedAgencies){

			//this is single or Terminated Agencies, so we should not catch any Lost BR in another countries hierarchy

			if(acct.Top_Parent__r != null && acct.IATA_ISO_Country__r.Name <> acct.Top_Parent__r.IATA_ISO_Country__r.Name)
				continue;

			if(acct.Status__c == AMS_Utils.ACC_S0_TERMINATED){
				if(acct.Expiry_Date__c < frontierDate){
					continue;
				}else
					toReturn.put(acct.Id,createNewSoloHierarchyStructure(acct));
			}else
				toReturn.put(acct.Id,createNewSoloHierarchyStructure(acct));

			allAgencies.add(acct.Id);
		}

		List<Account> allAccountsSingleHierarchyBR = [SELECT Id, Name, Purge_Flag__c, Location_Class__c, Location_Type__c, Financial_Review_Result__c,IATACode__c, Status__c, RecordType.Name, IATA_ISO_Country__r.BSP_Country_free_text__c,IATA_ISO_Country__r.BSP__c,IATA_ISO_Country__r.ISO_Code__c ,IATA_ISO_Country__r.Name,Sector__c, Top_Parent__c, Expiry_Date__c from Account where Location_Type__c in :LOCATIONTYPESBRS and ParentId  = null and IATA_ISO_Country__r.Name = :country and RecordTypeId in:ALLOWEDRECORDTYPES and Sector__c in:ALLOWEDSECTORS and Location_Class__c in:ALLOWEDLOCATIONCLASSES and Id not in:allAgencies];

		for(Account acct: allAccountsSingleHierarchyBR){
			if(acct.Status__c == AMS_Utils.ACC_S0_TERMINATED){
				if(acct.Expiry_Date__c < frontierDate){
					continue;
				}else{
					toReturn.put(acct.Id,createNewSoloHierarchyStructure(acct));
				}
			}else{
				if(ALLOWEDLOCATIONCLASSES.contains(acct.Location_Class__c)){
					toReturn.put(acct.Id,createNewSoloHierarchyStructure(acct));
				}
			}

			allAgencies.add(acct.Id);
		}


		// fetch all the agencies that are belonging to other countries
		List<AMS_Agencies_relationhip__c> brAbroadInDiffCountries = [SELECT Id, Hierarchy__r.RecordType.Name, Hierarchy__r.Name,Hierarchy__r.Migrated__c, Hierarchy__c, Child_Account__c, Parent_Account__r.IATACode__c, Parent_Account__r.Status__c, Parent_Account__r.Purge_Flag__c, Child_Account__r.IATACode__c, Child_Account__r.Purge_Flag__c, Child_Account__r.Top_Parent__c, Child_Account__r.Financial_Review_Result__c, Child_Account__r.ParentId, Child_Account__r.Location_Type__c, Child_Account__r.Status__c, Child_Account__r.RecordType.Name, Child_Account__r.IATA_ISO_Country__r.Name,Child_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c,Parent_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c,Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP_Country_free_text__c, Parent_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP_Country_free_text__c,Child_Account__r.IATA_ISO_Country__r.BSP__c,Parent_Account__r.IATA_ISO_Country__r.BSP__c,Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP__c, Parent_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP__c,Child_Account__r.IATA_ISO_Country__r.ISO_Code__c ,Parent_Account__r.IATA_ISO_Country__r.ISO_Code__c ,Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.ISO_Code__c , Parent_Account__r.Top_Parent__r.IATA_ISO_Country__r.ISO_Code__c ,Child_Account__r.Sector__c, Child_Account__r.Top_Parent__r.IATACode__c, Child_Account__r.Top_Parent__r.Location_Type__c, Child_Account__r.Top_Parent__r.Name, Child_Account__r.Top_Parent__r.Status__c, Child_Account__r.Top_Parent__r.RecordType.Name, Child_Account__r.Top_Parent__r.Financial_Review_Result__c, Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name,Child_Account__r.Top_Parent__r.Sector__c, Child_Account__r.Top_Parent__r.Top_Parent__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.Top_Parent__r.Purge_Flag__c, Child_Account__r.Expiry_Date__c, Parent_Account__r.Expiry_Date__c, Child_Account__r.Top_Parent__r.Expiry_Date__c, Child_Account__r.Location_Class__c, Parent_Account__r.Location_Class__c, Child_Account__r.Top_Parent__r.Location_Class__c, Parent_Account__r.Top_Parent__r.Location_Class__c from AMS_Agencies_relationhip__c where Child_Account__r.IATA_ISO_Country__r.Name = :country and Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name <> :country and Child_Account__r.Sector__c in:ALLOWEDSECTORS and Child_Account__r.Location_Class__c in:ALLOWEDLOCATIONCLASSES and Hierarchy__r.Migrated__c = false and Child_Account__c not in:allAgencies];

		System.debug('brAbroadInDiffCountries are:'+brAbroadInDiffCountries);

		for(AMS_Agencies_relationhip__c relationShip: brAbroadInDiffCountries){
			
			/*if(relationShip.Child_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED)
				if(relationShip.Child_Account__r.Expiry_Date__c < frontierDate)
					continue;
			*/
			
			if(validateBranchesAbroad(new List<AMS_Agencies_relationhip__c>{relationShip})){// it's a false positive
				continue;
			}
			
			if(toReturn.get(relationShip.Hierarchy__c) == null){
				system.debug('Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name is ' + relationShip.Child_Account__r.IATA_ISO_Country__r.Name);
				toReturn.put(relationShip.Hierarchy__c,createNewBrAbroadByCountryHierarchyStructure(relationShip,relationShip.Child_Account__r.IATA_ISO_Country__r.Name));
			}
			else{
				toReturn.get(relationShip.Hierarchy__c).addRelation(relationShip);
			}

		}

		List<AMS_Agencies_Hierarchy__c> alreadyMigratedStructures = [select Id from AMS_Agencies_Hierarchy__c where migrated__c = true and Id in (select Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name = :country)];

		for(AMS_Agencies_Hierarchy__c h: alreadyMigratedStructures){

			toReturn.put(h.Id,createNewHierarchyStructure(h));

		}


		System.debug('All hierarchies:'+allHierarchies.size());
		
		System.debug('All HO Single Accounts:'+allAccountsSingleHierarchyHOorTerminatedAgencies.size());

		return toReturn;
	}



	public static Map<Id,ANG_ConversionHelper.HierarchyStructure> buildSingleHierarchyStructure(String hierarchyId){

		List<AMS_Agencies_relationhip__c> allRelations = [SELECT Id, Hierarchy__r.Migrated__c, Hierarchy__r.RecordType.Name, Hierarchy__r.Name, Hierarchy__c, Child_Account__c, Parent_Account__r.IATACode__c, Parent_Account__r.Status__c, Parent_Account__r.Purge_Flag__c, Child_Account__r.Purge_Flag__c, Child_Account__r.IATACode__c, Child_Account__r.Financial_Review_Result__c, Child_Account__r.Location_Class__c, Child_Account__r.Location_Type__c, Child_Account__r.Status__c, Child_Account__r.RecordType.Name, Child_Account__r.IATA_ISO_Country__r.Name,Child_Account__r.Sector__c, Child_Account__r.Top_Parent__r.Financial_Review_Result__c, Child_Account__r.Top_Parent__r.Name, Child_Account__r.Top_Parent__r.IATACode__c, Child_Account__r.Top_Parent__r.Location_Class__c, Child_Account__r.Top_Parent__r.Location_Type__c, Child_Account__r.Top_Parent__r.Status__c, Child_Account__r.Top_Parent__r.RecordType.Name, Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.Name,Child_Account__r.Top_Parent__r.Sector__c, Child_Account__r.Top_Parent__r.Top_Parent__c, Parent_Account__c, Child_Account__r.Top_Parent__r.Purge_Flag__c, Parent_Account__r.Expiry_Date__c, Child_Account__r.Expiry_Date__c, Child_Account__r.Top_Parent__r.Expiry_Date__c from AMS_Agencies_relationhip__c where Hierarchy__c = :hierarchyId];

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
			if(!(ALLOWEDLOCATIONCLASSES.contains(rel.Child_Account__r.Location_Class__c) && ALLOWEDLOCATIONCLASSES.contains(rel.Child_Account__r.Top_Parent__r.Location_Class__c))){

				if(!(ALLOWEDLOCATIONCLASSES.contains(rel.Child_Account__r.Top_Parent__r.Location_Class__c)))
					return false;

				if(!(rel.Child_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED))
					return false;

				if(rel.Child_Account__r.Location_Class__c == TIDSLOCALTIONCLASS) // NEWGEN-2539 TIDS should be raise as an exception to be splited after.
					return false;
			}

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
			if(!validateBSPAttributes(rel.Child_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c, rel.Child_Account__r.IATA_ISO_Country__r.ISO_Code__c, rel.Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.BSP_Country_free_text__c,rel.Child_Account__r.Top_Parent__r.IATA_ISO_Country__r.ISO_Code__c))
				return false;
		}

		return true;

	}

	public static boolean validateBSPAttributes(String bSPCountryChild, String iSOCodeChild,String bSPCountryParent, String iSOCodeParent){

		if(bSPCountryChild <> null && bSPCountryParent <> null)
			return bSPCountryChild == bSPCountryParent;
		else
			return iSOCodeChild == iSOCodeParent;

	}


	public static ANG_ConversionHelper.HierarchyStructure performValidationsOnHierarchy(ANG_ConversionHelper.HierarchyStructure struct){

			if(struct.errorCategory == BRDIFFCOUNTRY){
				struct.isValid = false;
				struct.errorCategory = BRDIFFCOUNTRY;
				return struct;

			}

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

	private Static ANG_ConversionHelper.HierarchyStructure createNewBrAbroadByCountryHierarchyStructure(AMS_Agencies_relationhip__c relationShip, String country){

		ANG_ConversionHelper.HierarchyStructure struct = new ANG_ConversionHelper.HierarchyStructure(relationShip, country);

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

		ANG_ConversionHelper.isMigrationTool=true;
		
		ANG_ConversionBatch conversionBatch = new ANG_ConversionBatch(finalStruct.validHierarchies.values());

		Id conversionBatchId = null;

		if(!Test.isRunningTest())
    		conversionBatchId = Database.executeBatch(conversionBatch,1);	
    	else
    		conversionBatchId = Database.executeBatch(conversionBatch);	

    	return conversionBatchId;

	}

	public static Id runFullAnalysesWithReport(String countryName){

		Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure(countryName);
		       
		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);
		        
		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure,countryName);

		ANG_ConversionHelper.isMigrationTool=true;
		ANG_ConversionHelper.isMigrationToolAnalyses=true;
		
		ANG_ConversionFullAnalysesBatch conversionBatch = new ANG_ConversionFullAnalysesBatch(finalStruct.validHierarchies.values(), countryName);

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
				
				//System.debug('Account Migrated:'+struct.hierarchyId);

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

		for(Account acct: allAccountsSingleHierarchyHO){
			accountsMigrated.add(acct.Id);
			//System.debug('Account Migrated:'+acct.Id);
		}

		Date frontierDate = Date.today().addMonths(-6);

		List<Account> allAccountsSingleHierarchyHOTerminated = [SELECT Id  from Account where Location_Type__c in :LOCATIONTYPESNEWGEN and Sector__c in:ALLOWEDSECTORS and RecordTypeId in:ALLOWEDRECORDTYPES and IATA_ISO_Country__r.Name = :countryName and Id not in:accountsMigrated and Status__c = :AMS_Utils.ACC_S0_TERMINATED and Expiry_Date__c > :frontierDate];

		For(Account acct: allAccountsSingleHierarchyHOTerminated){

			accountsMigrated.add(acct.Id);
			//System.debug('Account Migrated:'+acct.Id);
		}

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

		toReturn.totalMigratedHierarchies+=allAccountsSingleHierarchyHOTerminated.size();
		toReturn.totalHierarchies+=allAccountsSingleHierarchyHOTerminated.size();


		return toReturn;

	}

	public static Set<Account> migrateStructures(List<ANG_ConversionHelper.HierarchyStructure> structures){

		System.debug('Preparing to convert:'+structures);

		ANG_ConversionHelper.isMigrationTool=true;//skip agencyEventGenerator

		Map<Id,Account> allAgenciesFinalMap = null;

		Set<Account> allAgencies = null;

		AMS_Agencies_Hierarchy__c hierarchy = null;

		Set<Account> accountsToUpdate = new Set<Account>();

		Set<AMS_Agencies_relationhip__c> relationsToUpdate = new Set<AMS_Agencies_relationhip__c>();

		Set<AMS_Agencies_relationhip__c> relationsToInsert = new Set<AMS_Agencies_relationhip__c>();

		Set<AMS_Agencies_relationhip__c> relationsToDelete = new Set<AMS_Agencies_relationhip__c>();

		Set<AMS_Agencies_Hierarchy__c> hierarchiesToUpdate = new Set<AMS_Agencies_Hierarchy__c>();

		Set<AMS_Agencies_Hierarchy__c> hierarchiesToDelete = new Set<AMS_Agencies_Hierarchy__c>();

		List<ANG_ConversionHelper.HierarchyStructure> toReturn = new List<ANG_ConversionHelper.HierarchyStructure>();

		Map<Id,List<Account>> allAgenciesMap = fetchAllAgenciesInvolved(structures);

		Map<Id,AMS_Agencies_Hierarchy__c> allHierarchiesInvolvedMap = fetchAllHierarchiesInvolved(structures);

		Set<Id> topParents = new Set<Id>();

		ANG_ConversionHelper.MigrationContainer container = null;

		for(ANG_ConversionHelper.HierarchyStructure struct: structures){

			allAgencies = new Set<Account>();
			allAgencies.addAll(allAgenciesMap.get(struct.hierarchyId));

			allAgenciesFinalMap = new Map<Id,Account>();

			for(Account acct: allAgencies)
				allAgenciesFinalMap.put(acct.Id,acct);

			hierarchy = allHierarchiesInvolvedMap.get(struct.hierarchyId);

			container = changeStructure(struct,allAgenciesFinalMap,hierarchy);

			accountsToUpdate.addAll(container.accountsToUpdate);
			accountsToUpdate.addAll(container.accountsSplitedToUpdate);
			relationsToUpdate.addAll(container.relationsToUpdate);
			relationsToInsert.addAll(container.relationsToAdd);
			relationsToDelete.addAll(container.relationsToDelete);

			if(container.hierarchy != null && !container.hierarchyToDelete)
				hierarchiesToUpdate.add(container.hierarchy);

			if(container.hierarchy != null && container.hierarchyToDelete)
				hierarchiesToDelete.add(container.hierarchy);

			container.struct.migrated = true;

			toReturn.add(container.struct);

			/*
			MT Enhancement 2019/03/11- Not Accredited Agencies with RHC Object
			*/
			if(!String.isBlank(container.struct.iataCodeTopParent)){
				topParents.add(container.struct.topParentId);	
			}
			

		}

		AMS_AgencyRelationshipTriggerHandler.isToRunTrigger = false;
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		
		ANG_RiskEventMigrationHelper reHelper = null;

		if(container != null)
			reHelper = new ANG_RiskEventMigrationHelper(container.accountsToUpdate);
	
		update new List<Account>(accountsToUpdate);
	
		if(reHelper != null)
			insert reHelper.convertChangeCodesToRiskEvents();

		update new List<AMS_Agencies_relationhip__c>(relationsToUpdate);

		update new List<AMS_Agencies_Hierarchy__c>(hierarchiesToUpdate);

		insert new List<AMS_Agencies_relationhip__c>(relationsToInsert);

		delete new List<AMS_Agencies_Hierarchy__c>(hierarchiesToDelete);

		delete new List<AMS_Agencies_relationhip__c>(relationsToDelete);

		ANG_RHCHelper.createRHCInfo(topParents, false); //as per NEWGEN-2487

		AMS_AgencyRelationshipTriggerHandler.isToRunTrigger = true;
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;

		if(container != null){
			createAgencyAuthorizations(container.accountsToUpdate);
			createCorrectionChangeCodes(filterByStatus(accountsToUpdate));
		}

		//return toReturn;
		return container.accountsToUpdate;

	}


	public static Set<Account> filterByStatus(Set<Account> accounts){

		Set<Account> accountsToReturn = new Set<Account>();

		For(Account acct: accounts){
			if(INVALIDAGENCYSTATUS.contains(acct.Status__c) || acct.Status__c == AMS_utils.ACC_S0_TERMINATED)
				continue;

			accountsToReturn.add(acct);
		}

		return accountsToReturn;
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

		List<Account> accountsSearched = [SELECT Id, Name, Top_Parent__c, Top_Parent__r.Location_Type__c, Location_Type__c, Location_Class__c, ParentId, Status__c, IATA_ISO_Country__r.BSP_Country_free_text__c, IATA_ISO_Country__r.BSP__c, IATA_ISO_Country__r.ISO_Code__c, Remittance_frequency__c, Financial_Review_Result__c, IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, ANG_RiskStatus__c, ANG_Accreditation_Model__c, Email__c,ANG_CashCondition__c, IATACode__c, (select Id, ANG_Financial_Security__c, ANG_RHC_Amount__c from RHC_Informations__r), Guaranteed_amount__c,IATA_ISO_Country__r.CurrencyIsoCode, ANG_IEP_Status__c, CNS_Agency__c, RecordTypeId from Account where Id in :accountIdsToSearch];

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


		//Date frontierDate = Date.today().addMonths(-6);

		Set<Account> accountsToUpdate = new Set<Account>();

		Set<Account> accountsSplitedToUpdate = new Set<Account>();

		Set<AMS_Agencies_relationhip__c> relationsToUpdate = new Set<AMS_Agencies_relationhip__c>();

		Set<AMS_Agencies_relationhip__c> relationsTidsToSplit = new Set<AMS_Agencies_relationhip__c>();

		Set<AMS_Agencies_relationhip__c> relationsToDelete = new Set<AMS_Agencies_relationhip__c>();

		Set<AMS_Agencies_relationhip__c> relationsToAdd = new Set<AMS_Agencies_relationhip__c>();

		boolean hierarchyToDelete = false;

		boolean hierarchyToDeleteAux = true;

		boolean hierarchyWithBrOfCountryToBeMigrated = false;

		if(struct.countryABR != null){

			hierarchyWithBrOfCountryToBeMigrated = true;

			List<Account> accountsToCreateNewHierarchy = new List<Account>();

			System.debug('struct.relations is currently:'+struct.relations);

			struct.relations = reOrderListForStatus(struct.relations);

			System.debug('struct.relations is now:'+struct.relations);

			for(AMS_Agencies_relationhip__c rel: struct.relations){ // first extract all accounts involved.

				if(struct.topParentId == null)
					struct.topParentId = rel.Child_Account__c;

				accountsToCreateNewHierarchy.add(allAgencies.get(rel.Child_Account__c));
				relationsToDelete.add(rel);


			}

			if(struct.relations.size() == 1){

				Id soloId = struct.relations.get(0).Child_Account__c;

				allAgencies.get(soloId).Location_Type__c = 'HE';
				if(allAgencies.get(soloId).RecordTypeId != ANG_ConversionHelper.ACCOUNT_STANDARD_RT){
					allAgencies.get(soloId).ANG_Accreditation_Model__c = 'Cash';
					allAgencies.get(soloId).ANG_HE_RiskHistoryAssessment__c = 'Passed';
					allAgencies.get(soloId).ANG_HE_CashCondition__c = false;
					
					if(allAgencies.get(soloId).ANG_IEP_Status__c ==null)
						allAgencies.get(soloId).ANG_IEP_Status__c  = 'No IEP Account';
				}
				allAgencies.get(soloId).Organization_Last_Change_Date__c = System.today();
				allAgencies.get(soloId).Top_Parent__c = null;
				allAgencies.get(soloId).ParentId = null;

				accountsToUpdate.add(allAgencies.get(soloId));
			}
			else{// Now, let's create a new hierarchy if needed and a new Set of Relations...

				AMS_Agencies_Hierarchy__c newHierarchy;
				
				if(!isMigrationToolAnalyses){
					newHierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
					insert newHierarchy;
				}

				for(Account acct: accountsToCreateNewHierarchy){
					
					if(acct.Id == struct.topParentId){
						allAgencies.get(acct.Id).Location_Type__c = 'HE';
						
						allAgencies.get(acct.Id).Top_Parent__c = null;
						allAgencies.get(acct.Id).ParentId = null;

					}else{
						relationsToAdd.add(new AMS_Agencies_relationhip__c(Parent_Account__c = struct.topParentId, Child_Account__c = acct.Id, Hierarchy__c = newHierarchy.id));

						allAgencies.get(acct.Id).Location_Type__c = 'AE';
						
						allAgencies.get(acct.Id).Top_Parent__c = struct.topParentId;
						allAgencies.get(acct.Id).ParentId = struct.topParentId;

					}
					
					if(allAgencies.get(acct.Id).RecordTypeId != ANG_ConversionHelper.ACCOUNT_STANDARD_RT){
						allAgencies.get(acct.Id).ANG_Accreditation_Model__c = 'Cash';
						allAgencies.get(acct.Id).ANG_HE_RiskHistoryAssessment__c = 'Passed';
						allAgencies.get(acct.Id).ANG_HE_CashCondition__c = false;
						
						if(allAgencies.get(acct.Id).ANG_IEP_Status__c ==null)
							allAgencies.get(acct.Id).ANG_IEP_Status__c  = 'No IEP Account';
					}

					allAgencies.get(acct.Id).Organization_Last_Change_Date__c = System.today();

					accountsToUpdate.add(allAgencies.get(acct.Id));
				}

			}

			// now we need to recreate any missing relation...

			List<AMS_Agencies_relationhip__c> relsToUpdate = [Select Id, Hierarchy__c, Child_Account__c, Parent_Account__c, Parent_Account__r.Top_Parent__c from AMS_Agencies_relationhip__c where Parent_Account__c in: accountsToCreateNewHierarchy and Child_Account__c not in:accountsToCreateNewHierarchy and Hierarchy__c = :struct.HierarchyId];

			Set<Id> accountNotSearch = new Set<Id>();

			For(AMS_Agencies_relationhip__c rels: relsToUpdate){
				accountNotSearch.add(rels.Parent_Account__c);
				accountNotSearch.add(rels.Child_Account__c);
			}
			
			// we are not getting all the relations and we need them to adjust the actual hierarchy.
			Map<Id,Account> accountsSearched = new Map<Id,Account>([SELECT Id, Name, Top_Parent__c, Top_Parent__r.Location_Type__c, Location_Type__c, Location_Class__c, ParentId, Status__c, IATA_ISO_Country__r.BSP_Country_free_text__c, IATA_ISO_Country__r.BSP__c, IATA_ISO_Country__r.ISO_Code__c, Remittance_frequency__c, Financial_Review_Result__c, IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, ANG_RiskStatus__c, ANG_Accreditation_Model__c, Email__c,ANG_CashCondition__c, IATACode__c, (select Id, ANG_Financial_Security__c, ANG_RHC_Amount__c from RHC_Informations__r), Guaranteed_amount__c from Account where Id in :accountNotSearch]);


			For(AMS_Agencies_relationhip__c rel: relsToUpdate){

				relationsToDelete.add(rel);
				relationsToAdd.add(new AMS_Agencies_relationhip__c(Parent_Account__c = rel.Parent_Account__r.Top_Parent__c, Child_Account__c = rel.Child_Account__c, Hierarchy__c = struct.HierarchyId));
				hierarchyToDeleteAux = false;

				accountsSearched.get(rel.Child_Account__c).ParentId = rel.Parent_Account__r.Top_Parent__c;
				accountsSearched.get(rel.Child_Account__c).Top_Parent__c = rel.Parent_Account__r.Top_Parent__c;

				accountsToUpdate.add(accountsSearched.get(rel.Child_Account__c));
			}

			if(hierarchyToDeleteAux){


				List<AMS_Agencies_relationhip__c> relsInHierarchy = [Select Id, Hierarchy__c, Child_Account__c, Parent_Account__c, Parent_Account__r.Top_Parent__c from AMS_Agencies_relationhip__c where Hierarchy__c = :struct.HierarchyId];

				Set<String> relsSet = new Set<String>();
				for(AMS_Agencies_relationhip__c rel: relsInHierarchy)
					relsSet.add(rel.Id);

				for(AMS_Agencies_relationhip__c rel: relationsToDelete)
					relsSet.remove(rel.Id);

				hierarchyToDelete = relsSet.size() == 0;

			}


		}else if(struct.isSingleAgencyHierarchy){
			if(allAgencies.get(struct.topParentId).Location_Type__c == AMS_Utils.AO && allAgencies.get(struct.topParentId).Status__c == AMS_Utils.ACC_S4_LISTED)
				allAgencies.get(struct.topParentId).Status__c = AMS_Utils.ACC_S9_APPROVED;		
			
			if(allAgencies.get(struct.topParentId).Status__c == AMS_Utils.ACC_S0_TERMINATED && !TOPLEVELLOCATIONTYPES.contains(allAgencies.get(struct.topParentId).Location_Type__c)){
				allAgencies.get(struct.topParentId).Location_Type__c = 'AE';					
			} else {

				if(TOPLEVELLOCATIONTYPES.contains(allAgencies.get(struct.topParentId).Location_Type__c))
					allAgencies.get(struct.topParentId).Location_Type__c = 'HE';			
				else
					allAgencies.get(struct.topParentId).Location_Type__c = 'AE';		


				if(allAgencies.get(struct.topParentId).RecordTypeId != ANG_ConversionHelper.ACCOUNT_STANDARD_RT){
					allAgencies.get(struct.topParentId).ANG_Accreditation_Model__c = 'Cash';
					allAgencies.get(struct.topParentId).ANG_HE_RiskHistoryAssessment__c = 'Passed';
					allAgencies.get(struct.topParentId).ANG_HE_CashCondition__c = false;
					
					if(allAgencies.get(struct.topParentId).ANG_IEP_Status__c == null)
						allAgencies.get(struct.topParentId).ANG_IEP_Status__c  = 'No IEP Account';
				}


				allAgencies.get(struct.topParentId).Organization_Last_Change_Date__c = System.today();

				accountsToUpdate.add(allAgencies.get(struct.topParentId));
			}
		} else{

				for(AMS_Agencies_relationhip__c rel: struct.relations){

					if(allAgencies.get(rel.Child_Account__c).Location_Class__c == TIDSLOCALTIONCLASS || !validateBSPAttributes(allAgencies.get(rel.Child_Account__c).IATA_ISO_Country__r.BSP_Country_free_text__c, allAgencies.get(rel.Child_Account__c).IATA_ISO_Country__r.ISO_Code__c, allAgencies.get(rel.Child_Account__r.Top_Parent__c).IATA_ISO_Country__r.BSP_Country_free_text__c,allAgencies.get(rel.Child_Account__r.Top_Parent__c).IATA_ISO_Country__r.ISO_Code__c)){
                        relationsTidsToSplit.add(rel);
						if(struct.relations.size() == 1)
							hierarchyToDelete = true; // this need to be changed. Not only with 1 hierarchy we need to delete it.
					}

					if(!relationsTidsToSplit.contains(rel)){

						rel.Is_Newgen_Relation__c = true;
						rel.Parent_Account__c = struct.topParentId;
						
						if(allAgencies.get(rel.Parent_Account__c).Location_Type__c == AMS_Utils.AO && allAgencies.get(rel.Parent_Account__c).Status__c == AMS_Utils.ACC_S4_LISTED)
							allAgencies.get(rel.Parent_Account__c).Status__c = AMS_Utils.ACC_S9_APPROVED;	

						allAgencies.get(rel.Parent_Account__c).Location_Type__c = 'HE';
						if(allAgencies.get(rel.Parent_Account__c).RecordTypeId != ANG_ConversionHelper.ACCOUNT_STANDARD_RT){
							allAgencies.get(rel.Parent_Account__c).ANG_Accreditation_Model__c = 'Cash';
							allAgencies.get(rel.Parent_Account__c).ANG_HE_RiskHistoryAssessment__c = 'Passed';
							allAgencies.get(rel.Parent_Account__c).ANG_HE_CashCondition__c = false;
							
							if(allAgencies.get(rel.Parent_Account__c).ANG_IEP_Status__c ==null)
								allAgencies.get(rel.Parent_Account__c).ANG_IEP_Status__c  = 'No IEP Account';
						}						
						allAgencies.get(rel.Parent_Account__c).Organization_Last_Change_Date__c = System.today();


						//if(!(rel.child_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED && rel.Child_Account__r.Expiry_Date__c < frontierDate)) { // let's ignore it
							
						allAgencies.get(rel.Child_Account__c).Location_Type__c = 'AE';
						if(allAgencies.get(rel.Child_Account__c).RecordTypeId != ANG_ConversionHelper.ACCOUNT_STANDARD_RT){
							allAgencies.get(rel.Child_Account__c).ANG_Accreditation_Model__c = 'Cash';
							allAgencies.get(rel.Child_Account__c).ANG_HE_RiskHistoryAssessment__c = 'Passed';
							allAgencies.get(rel.Child_Account__c).ANG_HE_CashCondition__c = false;
							
							if(allAgencies.get(rel.Child_Account__c).ANG_IEP_Status__c ==null)
								allAgencies.get(rel.Child_Account__c).ANG_IEP_Status__c  = 'No IEP Account';
						}
						allAgencies.get(rel.Child_Account__c).Organization_Last_Change_Date__c = System.today();

						if(allAgencies.get(rel.Child_Account__c).ParentId != struct.topParentId)
							allAgencies.get(rel.Child_Account__c).ParentId = struct.topParentId;


						if(rel.child_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED && (!ALLOWEDLOCATIONCLASSES.contains(rel.Child_Account__r.Location_Class__c))){
							if(allAgencies.get(rel.Child_Account__c).Location_Class__c <> TIDSLOCALTIONCLASS)
								allAgencies.get(rel.Child_Account__c).Location_Class__c = 'P';
						}

						accountsToUpdate.add(allAgencies.get(rel.Child_Account__c));
						//}

						rel.Hierarchy__r.Migrated__c= true;

						accountsToUpdate.add(allAgencies.get(rel.Parent_Account__c));					

						if(!relationsTidsToSplit.contains(rel))
							relationsToUpdate.add(rel);
					}
				}
		}

		struct.migrated = true;

		if(!struct.isSingleAgencyHierarchy && !hierarchyWithBrOfCountryToBeMigrated){
			hierarchy.Migrated__c = true;
		}



		Map<String,List<AMS_Agencies_relationhip__c>> relationsToSplitByBSPCountry = splitRelationsByBSPCountry(relationsTidsToSplit,allAgencies);

		for(List<AMS_Agencies_relationhip__c> relationsTidsToSplitPerCountry: relationsToSplitByBSPCountry.values()){

			boolean parentAdded = false;
			AMS_Agencies_relationhip__c parentRel;
			boolean relationsToCreate = (!relationsTidsToSplitPerCountry.isEmpty() && relationsTidsToSplitPerCountry.size() > 1);
			AMS_Agencies_Hierarchy__c newHierarchy = null;

			Set<AMS_Agencies_relationhip__c> relationsTidsToSplitPerCountrySet = new Set<AMS_Agencies_relationhip__c>();
			relationsTidsToSplitPerCountrySet.addAll(relationsTidsToSplitPerCountry);

			System.debug('Relations to relationsTidsToSplitPerCountrySet are:'+relationsTidsToSplitPerCountrySet);

			List<AMS_Agencies_relationhip__c> relationsTidsToSplitLst = reOrderListForStatusSet(relationsTidsToSplitPerCountrySet);

			System.debug('Relations to Split are:'+relationsTidsToSplitLst);

			for(AMS_Agencies_relationhip__c rel: relationsTidsToSplitLst){

				System.debug('Analysing rel:'+rel);

				if(!parentAdded){
					parentAdded = true;
					parentRel = rel;
					allAgencies.get(rel.Child_Account__c).ParentId = null;
					allAgencies.get(rel.Child_Account__c).Top_Parent__c = null;
					allAgencies.get(rel.Child_Account__c).Location_Type__c = 'HO';
					allAgencies.get(rel.Child_Account__c).Organization_Last_Change_Date__c = System.today();

					if(relationsToCreate && !isMigrationToolAnalyses){
						newHierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
						insert newHierarchy;
					}

				}else{

					if(allAgencies.get(rel.Child_Account__c).ParentId == allAgencies.get(rel.Child_Account__c).Top_Parent__c){
						
						System.debug('parentRel.Child_Account__c is ' + parentRel.Child_Account__c);
						System.debug('allAgencies.get(parentRel.Child_Account__c).Id is:'+allAgencies.get(parentRel.Child_Account__c).Id);

						allAgencies.get(rel.Child_Account__c).ParentId = allAgencies.get(parentRel.Child_Account__c).Id;
						relationsToAdd.add(new AMS_Agencies_relationhip__c(Parent_Account__c = parentRel.Child_Account__c, Child_Account__c = rel.Child_account__c, Hierarchy__c = newHierarchy.id));
					}else{
						relationsToAdd.add(new AMS_Agencies_relationhip__c(Parent_Account__c = rel.Parent_Account__c, Child_Account__c = rel.Child_account__c, Hierarchy__c = newHierarchy.id));
					}

					allAgencies.get(rel.Child_Account__c).Top_Parent__c = allAgencies.get(parentRel.Child_Account__c).Id;
					//allAgencies.get(rel.Child_Account__c).Location_Type__c = 'BR';
					allAgencies.get(rel.Child_Account__c).Organization_Last_Change_Date__c = System.today();

				}

				accountsSplitedToUpdate.add(allAgencies.get(rel.Child_Account__c));

				relationsToDelete.add(rel);

				if(!accountsToUpdate.contains(allAgencies.get(rel.Child_Account__r.Top_Parent__c))){

					if(allAgencies.get(rel.Child_Account__r.Top_Parent__c).Location_Type__c == AMS_Utils.AO)
						if(allAgencies.get(rel.Child_Account__r.Top_Parent__c).Status__c == AMS_Utils.ACC_S4_LISTED)
							allAgencies.get(rel.Child_Account__r.Top_Parent__c).Status__c = AMS_Utils.ACC_S9_APPROVED;	

					allAgencies.get(rel.Child_Account__r.Top_Parent__c).Location_Type__c = 'HE';
					if(allAgencies.get(rel.Child_Account__r.Top_Parent__c).RecordTypeId != ANG_ConversionHelper.ACCOUNT_STANDARD_RT){
						allAgencies.get(rel.Child_Account__r.Top_Parent__c).ANG_Accreditation_Model__c = 'Cash';
						allAgencies.get(rel.Child_Account__r.Top_Parent__c).ANG_HE_RiskHistoryAssessment__c = 'Passed';
						allAgencies.get(rel.Child_Account__r.Top_Parent__c).ANG_HE_CashCondition__c = false;
						
						if(allAgencies.get(rel.Child_Account__r.Top_Parent__c).ANG_IEP_Status__c ==null)
							allAgencies.get(rel.Child_Account__r.Top_Parent__c).ANG_IEP_Status__c  = 'No IEP Account';
					}	

					allAgencies.get(rel.Child_Account__r.Top_Parent__c).Organization_Last_Change_Date__c = System.today();

					System.debug('Adding accounts to update :' + allAgencies.get(rel.Child_Account__r.Top_Parent__c));

					accountsToUpdate.add(allAgencies.get(rel.Child_Account__r.Top_Parent__c));	
				}
			}

			if(!hierarchyToDelete)
				hierarchyToDelete = isToDeleteHierarchy(struct,relationsToDelete);
			
		}

		return new ANG_ConversionHelper.MigrationContainer(struct,accountsToUpdate,accountsSplitedToUpdate,relationsToUpdate,hierarchy,relationsToDelete,relationsToAdd,hierarchyToDelete);

	}


	private static Map<String,List<AMS_Agencies_relationhip__c>> splitRelationsByBSPCountry(Set<AMS_Agencies_relationhip__c> relationsToUpdate,Map<Id,Account> allAgencies){

		Map<String,List<AMS_Agencies_relationhip__c>> mapToReturn = new Map<String,List<AMS_Agencies_relationhip__c>>();

		for(AMS_Agencies_relationhip__c rel: relationsToUpdate){

			if(!validateBSPAttributes(allAgencies.get(rel.Child_Account__c).IATA_ISO_Country__r.BSP_Country_free_text__c, allAgencies.get(rel.Child_Account__c).IATA_ISO_Country__r.ISO_Code__c, allAgencies.get(rel.Child_Account__r.Top_Parent__c).IATA_ISO_Country__r.BSP_Country_free_text__c,allAgencies.get(rel.Child_Account__r.Top_Parent__c).IATA_ISO_Country__r.ISO_Code__c)){

				if(mapToReturn.get(rel.Child_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c) != null){
					mapToReturn.get(rel.Child_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c).add(rel);
				}else{
					List<AMS_Agencies_relationhip__c> relToAdd = new List<AMS_Agencies_relationhip__c>();
					relToAdd.add(rel);
					mapToReturn.put(rel.Child_Account__r.IATA_ISO_Country__r.BSP_Country_free_text__c,relToAdd);
				}

			}else{
				if(mapToReturn.get('TIDS CATEGORY') != null){
					mapToReturn.get('TIDS CATEGORY').add(rel);
				}else{
					List<AMS_Agencies_relationhip__c> relToAdd = new List<AMS_Agencies_relationhip__c>();
					relToAdd.add(rel);
					mapToReturn.put('TIDS CATEGORY',relToAdd);
				}
			}
		}

		return mapToReturn;
	}


	private static boolean isToDeleteHierarchy(ANG_ConversionHelper.HierarchyStructure struct,Set<AMS_Agencies_relationhip__c> relsToDelete){

		if(struct.isSingleAgencyHierarchy)
			return false;

		Integer countTopParent = 0;

		for(AMS_Agencies_relationhip__c rel: struct.relations){
			if(relsToDelete.contains(rel))
				continue;

			if(rel.Parent_Account__c == struct.topParentId)
				countTopParent++;
		}

		return countTopParent == 0;

	}

	private static List<AMS_Agencies_relationhip__c> reOrderListForStatusSet(Set<AMS_Agencies_relationhip__c> relationsSet){

		List<AMS_Agencies_relationhip__c> relations = new List<AMS_Agencies_relationhip__c>();
		relations.addAll(relationsSet);
		return reOrderListForStatus(relations);

	}


	@TestVisible private static List<AMS_Agencies_relationhip__c> reOrderListForStatus(List<AMS_Agencies_relationhip__c> relations){

		List<OrderRelations> relationships = new List<OrderRelations>();

		for(AMS_Agencies_relationhip__c relation : relations)
			relationships.add(new OrderRelations(relation));

		relations.clear();

		relationships.sort();

		for(OrderRelations relationship : relationships)
			relations.add(relationship.relation);

		return relations;

	}

	private static void createAgencyAuthorizations(Set<Account> accts){

        List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();
        
        ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
        
        List<Account> acctToInsert = [SELECT Id, IATACode__c, Status__c, Purge_Flag__c from Account where Id in:accts];
        
        String statusAA = null;

        for(Account acct:acctToInsert){

        	if(isAcctElegibleToCreateAuthorization(acct)){

        		statusAA = acct.Status__c == AMS_utils.ACC_S0_TERMINATED ? 'Non-Active' :  'Active';

        		authorizations.add(new Agency_Authorization__c(Account__c = acct.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = statusAA, RecordTypeId = FormOfPaymentRT));
        		authorizations.add(new Agency_Authorization__c(Account__c = acct.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = statusAA, RecordTypeId = FormOfPaymentRT));
        		authorizations.add(new Agency_Authorization__c(Account__c = acct.Id, ANG_FormOfPayment_ID__c = 'EP', Status__c = statusAA, RecordTypeId = FormOfPaymentRT));
			}
		}

        insert authorizations;
    }

    public static boolean isAcctElegibleToCreateAuthorization(Account acct){

    	return !(acct.IATACode__c == null ||  INVALIDAGENCYSTATUS.contains(acct.Status__c) || acct.Purge_Flag__c == true);

    }

    public static void createCorrectionChangeCodes(Set<Account> accountsToApply){

        Map<Id,Agency_Applied_Change_code__c> mapAACCAccounts = new Map<Id,Agency_Applied_Change_code__c>();

        //Accounts are reQueried to avoid conflicts with Risk Assessment (performed on an earlier step)
		List<Account> accounts = [SELECT Id, Status__c, CNS_Agency__c, (SELECT Reason_Code__c, Reason_Description__c,Account__r.Status__c FROM Agencies_Applied_Change_codes__r WHERE Active__c = TRUE ORDER BY CreatedDate DESC) FROM Account WHERE Id in :accountsToApply];

		for(Account a : accounts){
			if(!a.Agencies_Applied_Change_codes__r.isEmpty()) mapAACCAccounts.put(a.Id,a.Agencies_Applied_Change_codes__r[0]);
		}

        //prepare data structures to feed into change code generator
        List<Account> accts = new List<Account>();
        //No oscars are involved in this process but we still need it to pass onto the method
        List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();
        List<AMS_OSCAR_JSON.ChangeCode> corChangeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();

		AMS_OSCAR_JSON.ChangeCode changeCode;

        for(Account acc: accounts){

			//create correction change code definition
	    	changeCode = new AMS_OSCAR_JSON.ChangeCode();

	        changeCode.name = 'COR';
	        changeCode.memoText = 'Correction';
	        changeCode.publishedOnEBulletin = false;
	        changeCode.status  = null;

			if(mapAACCAccounts.get(acc.Id) != null){
			    changeCode.reasonCode = mapAACCAccounts.get(acc.Id).Reason_Code__c;
			    changeCode.reasonDesc = mapAACCAccounts.get(acc.Id).Reason_Description__c;
			    changeCode.status = AMS_Utils.getIATANumericStatus(mapAACCAccounts.get(acc.Id).Account__r.Status__c);
			}

        	accts.add(acc);
        	corChangeCodes.add(changeCode);
        	oscars.add(null);
        }

		AMS_ChangeCodesHelper.createAAChangeCodes(corChangeCodes, oscars, accts, true);
    }

    
	public class MigrationContainer{

		ANG_ConversionHelper.HierarchyStructure struct;

		public Set<Account> accountsToUpdate;

		Set<Account> accountsSplitedToUpdate;

		Set<AMS_Agencies_relationhip__c> relationsToUpdate;

		AMS_Agencies_Hierarchy__c hierarchy;

		Set<AMS_Agencies_relationhip__c> relationsToDelete;

		Set<AMS_Agencies_relationhip__c> relationsToAdd;

		Boolean hierarchyToDelete;

		public migrationContainer(ANG_ConversionHelper.HierarchyStructure structIn,Set<Account> accountsToUpdateIn, Set<Account> accountsSplitedToUpdateIn, Set<AMS_Agencies_relationhip__c> relationsToUpdateIn, AMS_Agencies_Hierarchy__c hierarchyIn,Set<AMS_Agencies_relationhip__c> relationsToDeleteIn,Set<AMS_Agencies_relationhip__c> relationsToAddIn, boolean hierarchyToDeleteIn){

			struct = structIn;
			accountsToUpdate = accountsToUpdateIn;
			accountsSplitedToUpdate = accountsSplitedToUpdateIn;
			relationsToUpdate = relationsToUpdateIn;
			hierarchy = hierarchyIn;
			relationsToDelete = relationsToDeleteIn;
			relationsToAdd = relationsToAddIn;
			hierarchyToDelete = hierarchyToDeleteIn;

			if(hierarchyToDelete){
				for(AMS_Agencies_relationhip__c rel: relationsToDelete){
					if(rel.Hierarchy__c == hierarchy.Id)
						relationsToDelete.remove(rel);
				}
			}
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
		public String countryABR{get;set;}

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

			Date frontierDate = Date.today().addMonths(-6);
			isSingleAgencyHierarchy = true;
			hierarchyId = acct.Id;
			topParentId = acct.Id;
			relations = new List<AMS_Agencies_relationhip__c>(); 
			iataCodeTopParent = acct.IATACode__c;
			nameTopParent = acct.Name;

			isValid = TOPLEVELLOCATIONTYPES.contains(acct.Location_Type__c);

			if(!isValid){

				if(acct.Status__c == AMS_Utils.ACC_S0_TERMINATED && acct.Expiry_Date__c > frontierDate)
					isValid = true;
			}

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

		public HierarchyStructure(AMS_Agencies_relationhip__c relationShip, String countryABRIn){

			system.debug('Addind HierarchyStructure:' + relationShip + ' with country:' + countryABRIn);
			if(allAgencies == null)
				allAgencies = new Set<Id>();

			isSingleAgencyHierarchy = false;
			hierarchyId = relationShip.Hierarchy__c;
			topParentId = relationShip.Child_Account__r.Status__c <> AMS_Utils.ACC_S0_TERMINATED ? relationShip.Child_Account__c : topParentId;
			relations = new List<AMS_Agencies_relationhip__c>{relationShip};
			isValid = false;
			errorCategory = BRDIFFCOUNTRY;
			iataCodeTopParent = relationShip.Child_Account__r.Top_Parent__r.IATACode__c;
			migrated = relationShip.Hierarchy__r.Migrated__c;
			nameTopParent = relationShip.Child_Account__r.Top_Parent__r.Name;

			allAgencies.add(relationShip.Child_Account__c);
			allAgencies.add(relationShip.Parent_Account__c);
			countryABR = countryABRIn;

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

	global class OrderRelations implements Comparable{

		private AMS_Agencies_relationhip__c relation;
		private Integer statusWeight;
		private Integer locationTypeWeight;

		public OrderRelations(AMS_Agencies_relationhip__c relation){
			this.relation = relation;
			defineWeights(relation);
		}

		/**
		*	Compares two relationships by Child Account Status and Location Type
		*	Returns 0 if both relationships can be in the same position of the hierarchy
		*	Returns 1 if the relationship can be parent of the compareTo
		*	Returns -1 if the relationship cannot be parent of the compareTo
		**/
		public Integer compareTo(Object compareTo) {
       
            OrderRelations compareToOR = (OrderRelations)compareTo;

            if(statusWeight == compareToOR.statusWeight) {

            	if (locationTypeWeight == compareToOR.locationTypeWeight)
            		return 0;
        		else
        			return locationTypeWeight < compareToOR.locationTypeWeight ? 1 : -1;

            } else {

            	return statusWeight < compareToOR.statusWeight ? 1 : -1;
            }
		}

		/**
		*	Define weights taking into consideration the Child Account Status and Location Type
		**/
		private void defineWeights(AMS_Agencies_relationhip__c relationship) {

			//define status weight
			if(ACTIVEAGENCYSTATUS.contains(relationship.Child_Account__r.Status__c))
				statusWeight = 30;
			else if(INACTIVEAGENCYSTATUS.contains(relationship.Child_Account__r.Status__c))
				statusWeight = 20;
			else if(BLANKAGENCYSTATUS.contains(relationship.Child_Account__r.Status__c))
				statusWeight = 10;
			else
				statusWeight = 0;

			//define location type weight
			if(relationship.Child_Account__r.Location_Type__c == 'BR')
				locationTypeWeight = 20;
			else if(relationship.Child_Account__r.Location_Type__c == 'SA')
				locationTypeWeight = 10;
			else
				locationTypeWeight = 0;
		}

	}

}