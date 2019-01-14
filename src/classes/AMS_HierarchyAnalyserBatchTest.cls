@isTest
private class AMS_HierarchyAnalyserBatchTest
{
	public static Account HO;
	public static List<Account> secondLevel;
	public static List<Account> thirdLevel;
	public static List<AMS_Agencies_relationhip__c> rels;
	
	public static String SECTORPAX = 'Travel Agent';
	public static String CATEGORYPAX = 'IATA Passenger Sales Agent';
	public static String LOCCLASSPAX = 'P';
	
	 
	public static void initHierarchy(){

		Integer howManyBranches = 4;
		Integer howMany3rdLevelAgencies = 4;
		List<AMS_Agencies_Hierarchy__c> hierarchiesList = new List <AMS_Agencies_Hierarchy__c>();

		ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;
		

		
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
					//Create the hierarchy
			hierarchiesList.add(new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy '+i));
			
		}

		insert hierarchiesList;		

		integer count = 0;
		if(howManyBranches>0){
			insert secondLevel;				 
					
			for(Account branch : secondLevel){
				rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchiesList[count++].Id, Parent_Account__c = HO.Id, Child_Account__c = branch.Id, HO_Flag__c = 'true'));

			}
		}

		hierarchiesList.clear();
		//Create the 3rd level agencies (max 1 per second level)
		thirdlevel = new List<Account>();
		for(Integer i=0; i<howMany3rdLevelAgencies; i++){
			thirdLevel.add(new Account(RecordTypeId = rtAgency, Name = 'Your Travels', IATAcode__c = '333333'+i, 
										 ParentId = secondLevel[i].Id, IATA_ISO_Country__c = italy.id, 
										 Sector__c =  SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, 
										 Location_Type__c = 'SA',Status__c = AMS_Utils.ACC_S9_APPROVED));

			hierarchiesList.add(new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy '+i));

		}

		insert hierarchiesList;

		count = 0;
		if(howMany3rdLevelAgencies>0){
			insert thirdLevel;				 
					
			for(Account sa : thirdLevel){
				rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchiesList[count++].Id, Parent_Account__c = sa.ParentId, Child_Account__c = sa.Id, HO_Flag__c = 'false'));
				
			}
		}
		
		
		
		insert rels;
	}

	@isTest
	static void testBatchRun()
	{
		initHierarchy();

		Test.startTest();

		AMS_HierarchyAnalyser sch = new AMS_HierarchyAnalyser();
		System.schedule('Test Job', System.now().addHours(1).format('ss mm HH dd MM ? yyyy'), sch);
		sch.execute(null);

		Test.stopTest();

		Set<Id> hierarchiesSetIds = new Set<Id>();
		
		for(AMS_Agencies_relationhip__c rel : [select Id,Hierarchy__c,Child_Account__c from AMS_Agencies_relationhip__c where Parent_Account__c = :HO.id]) hierarchiesSetIds.add(rel.Hierarchy__c);

		System.assertEquals(1,hierarchiesSetIds.size());

	}
}