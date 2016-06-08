global class AMS_HierarchyHelper {

	//bulk
	/*public static void setBranchAsHeadOffice(List<Account> brs){

	}
	
	//atomic
	public static void setBranchAsHeadOffice(Account br){

		Boolean needUpdate = false;
		//given an agency get the hierarchy it belongs to
		AMS_Agencies_relationhip__c relationship = [SELECT Id, Child_Account__c, Parent_Account__c, Hierarchy__c FROM AMS_Agencies_relationhip__c WHERE Child_Account__c =: br.Id limit 1];

		List<AMS_Agencies_relationhip__c> hierarchyRelationships = new List<AMS_Agencies_relationhip__c>([SELECT Id, Parent_Account__c, Child_Account__c FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c =: relationship.Hierarchy__c]);
		
		//define the new HO as the parent of all the relationships in the hierarchy
		for(AMS_Agencies_relationhip__c relation: hierarchyRelationships){
			//the existing HO(parent) is moved to BR(child)
			if(relation.Child_Account__c == br.Id)
				relation.Child_Account__c = relation.Parent_Account__c;
			
			//all the parents replaced with the new Ho
			relation.Parent_Account__c = br.Id;

		}

		update hierarchyRelationships;

	}*/

	// returns the list of relationships
	// NOTE: this is making the assumption that each agency is involved in max 1 hierarhcy
	public static Map<Id, List<AMS_Agencies_relationhip__c>>  getAccountsHierarchies(Set<Id> accountsIds){

		// As first I retrieve all the hierarchies involved
		Map<Id, Set<Id>> hierarchyToAccounts = new Map<Id,Set<Id>>();
		
		system.debug(LoggingLevel.ERROR,'getAccountsHierarchies() --> accountsIds '+accountsIds);
		
		for(AMS_Agencies_relationhip__c h : [SELECT Hierarchy__c, Parent_Account__c,  Child_Account__c
											FROM AMS_Agencies_relationhip__c
											WHERE Parent_Account__c IN :accountsIds OR Child_Account__c IN :accountsIds ]){
			
			system.debug(LoggingLevel.ERROR,'getAccountsHierarchies() --> trovo hierarchy '+h.ID);
			if(hierarchyToAccounts.get(h.Hierarchy__c)==null)
				hierarchyToAccounts.put(h.Hierarchy__c, new Set<Id>());
				
				
			if(accountsIds.contains(h.Parent_Account__c)){
				hierarchyToAccounts.get(h.Hierarchy__c).add(h.Parent_Account__c);
				
			}/*else */if(accountsIds.contains(h.Child_Account__c)){
				hierarchyToAccounts.get(h.Hierarchy__c).add(h.Child_Account__c);
			}
		}
		
		system.debug(LoggingLevel.ERROR,'getAccountsHierarchies() --> hierarchyToAccounts '+hierarchyToAccounts);

		// Now I retrieve all the relationship for the hierarchies in the map
		Map<Id, List<AMS_Agencies_relationhip__c>> result = new Map<Id, List<AMS_Agencies_relationhip__c>>();

		for(Id accountId : accountsIds)
			result.put(accountId, new List<AMS_Agencies_relationhip__c>());

		for(AMS_Agencies_relationhip__c r : [SELECT Hierarchy__c, Parent_Account__c,  Child_Account__c
											FROM AMS_Agencies_relationhip__c
											WHERE Hierarchy__c IN :hierarchyToAccounts.keyset() ]){
			
			system.debug(LoggingLevel.ERROR,'getAccountsHierarchies() --> found relationship '+r);
			for(Id theAccountId : hierarchyToAccounts.get(r.Hierarchy__c)){
				result.get(theAccountId).add(r);
			}
		}

		System.debug('getAccountsHierarchies() --> result '+result);
		
		return result;
	}




	// return hierarchy relationships that need to be updated
	// the first parameter is the account which will become the new HO
	public static HierarchyStruct switchBRwithHO(Id newHO, List<AMS_Agencies_relationhip__c> hierarchyRelationships){
		
		//Id newHO = newHeadOffice.Id;
		Id oldHO = getHierarchyHO(hierarchyRelationships);
		
		// loop over all the relationships and switch old ho and new ho
		List<AMS_Agencies_relationhip__c> relToUpdate = new List<AMS_Agencies_relationhip__c>();
		for(AMS_Agencies_relationhip__c rel : hierarchyRelationships){

			System.debug('AGENCY CHANGES:BEFORE RELID' + rel.Id + ' RELCHILD' + rel.Child_Account__c + ' RELPARENT' + rel.Parent_Account__c);

			System.debug('NEW HO: ' + newHO + ' OLD HO ' + oldHO );

			if(rel.Parent_Account__c == newHO)
				rel.Parent_Account__c = oldHO;
			else if(rel.Parent_Account__c == oldHO)
				rel.Parent_Account__c = newHO;
				
			if(rel.Child_Account__c == newHO)
				rel.Child_Account__c = oldHO;
			else if(rel.Child_Account__c == oldHO)
				rel.Child_Account__c = newHO;
				
			if(rel.Parent_Account__c == newHO || rel.Parent_Account__c == oldHO || 
			   rel.Child_Account__c == newHO || rel.Child_Account__c == oldHO)
				relToUpdate.add(rel);

			System.debug('AGENCY CHANGES:AFTER RELID' + rel.Id + ' RELCHILD' + rel.Child_Account__c + ' RELPARENT' + rel.Parent_Account__c);
		}
		
		return new HierarchyStruct(relToUpdate, null, null);
	}


	// return hierarchy relationships that need to be updated
	// this is covering the scenarios NON-IATA BUYS IATA
	// newHO = the agency for which the OSCAR was opened
	// hierarchyRelationships = newHO's hierarhcy
	// agenciesToMigrate = the list of the agencies which will be migrated: newHO + all the others
	public static HierarchyStruct migrateAccountsToNewHierarchy(Id newHO, List<AMS_Agencies_relationhip__c> hierarchyRelationships, Set<Id> agenciesToMigrate){
		
		// check if the old hierarchy is completely migrated
		Set<Id> agenciesNotMigrated = getAccountNotMigrated(hierarchyRelationships, agenciesToMigrate);
		boolean completeMigration = (agenciesNotMigrated.size()==0);
		
		system.debug(LoggingLevel.ERROR, 'COMPLETE MIGRATION ? '+completemigration);
		
		// check if the old HO is the same as the new HO
		Id oldHO = getHierarchyHO(hierarchyRelationships);
		
		if(completeMigration){
			// Scenario 1) all the hierarchy is moved
			if(newHO==oldHO)
				return new HierarchyStruct();
			else
				return switchBRwithHO(newHO,hierarchyRelationships);
		}else{
			String errorMigration = validateIncompleteMigration(agenciesNotMigrated);
			
			// Scenario 3) HO + some branches --> I have some branches which will remain standalone --> ERROR
			if(errorMigration!=null)
				return new HierarchyStruct(errorMigration);
			
			// Scenario 2) only some branches. One of them will became the new HO
			// Separate the relationships in three:
			//  - the ones which links agencies in the old hierarchy to agencies in the old hierarchy --> nothing to do
			//  - the ones which links agencies in the new hierarchy to agencies in the new hierarchy --> nothing to do
			//  - the ones which links agencies in the old hierarchy to agencies in the new hierarchy --> to be deleted	

			List<AMS_Agencies_relationhip__c> oldHier = new List<AMS_Agencies_relationhip__c>();
			List<AMS_Agencies_relationhip__c> newHier = new List<AMS_Agencies_relationhip__c>();
			List<AMS_Agencies_relationhip__c> oldnewHier = new List<AMS_Agencies_relationhip__c>();
			
			for(AMS_Agencies_relationhip__c rel : hierarchyRelationships){
				if(agenciesNotMigrated.contains(rel.Parent_account__c) && agenciesNotMigrated.contains(rel.Child_account__c))
					oldHier.add(rel);
				else if(agenciesNotMigrated.contains(rel.Parent_account__c) && agenciesToMigrate.contains(rel.Child_account__c))
					oldnewHier.add(rel);
				else if(agenciesToMigrate.contains(rel.Parent_account__c) && agenciesNotMigrated.contains(rel.Child_account__c))
					oldnewHier.add(rel);
				else if(agenciesToMigrate.contains(rel.Parent_account__c) && agenciesToMigrate.contains(rel.Child_account__c))
					newHier.add(rel);
			}
			
			system.debug('migrateAccountsToNewHierarchy() SCENARIO 2: only some branches!');
			
			system.debug('migrateAccountsToNewHierarchy() agenciesToMigrate = '+agenciesToMigrate);
			system.debug('migrateAccountsToNewHierarchy() agenciesNotMigrated = '+agenciesNotMigrated);

			system.debug('migrateAccountsToNewHierarchy() oldHier = '+oldHier);
			system.debug('migrateAccountsToNewHierarchy() newHier = '+newHier);
			system.debug('migrateAccountsToNewHierarchy() oldnewHier = '+oldnewHier);

			HierarchyStruct result = new HierarchyStruct();
			result.relationsToDelete = oldnewHier;
			
			
			// Now I create relationships for the agencies in the new hieararchy (only br to ho, I ignore SAs)
			result.relationsToInsert = new List<AMS_Agencies_relationhip__c>();
			//result.hierarchyToInsert = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');

			AMS_Agencies_Hierarchy__c newHierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
			insert newHierarchy;

			System.debug('AGENCY CHANGES: Hierarchy Id: '+ newHierarchy.id);

			for(Account acc : [SELECT Location_Type__c FROM Account WHERE Id IN :agenciesToMigrate AND ID <> :newHO]){
				if(acc.Location_Type__c == 'BR'){
					result.relationsToInsert.add(new AMS_Agencies_relationhip__c(Parent_Account__c = newHO, Child_Account__c = acc.Id, Hierarchy__c = newHierarchy.id));
				}
			}
			
			return result;
			
		}

	}


	// return hierarchy relationships that need to be updated
	// this is covering the scenarios IATA BUYS IATA
	// mainAccount = the agency for which the OSCAR was opened
	// currentHierarchy = mainAccount's hierarhcy
	// targetHO = the HO of the target hierarchy
	// agenciesToMigrate = the list of the agencies which will be migrated: the mainAccount + all the others
	public static HierarchyStruct migrateAccountsToExistingHierarchy(/*Account mainAccount, */List<AMS_Agencies_relationhip__c> currentHierarchy, Id targetAccount, List<AMS_Agencies_relationhip__c> newHierarchy, Set<Id> agenciesToMigrate){
		// check if the old hierarchy is completely migrated
		Set<Id> agenciesNotMigrated = getAccountNotMigrated(currentHierarchy, agenciesToMigrate);
		boolean completeMigration = (agenciesNotMigrated.size()==0);
		
		// check if the old HO is the same as the new HO
		Id oldHO = getHierarchyHO(currentHierarchy);
		boolean needNewHierarchy = newHierarchy.size()==0;

		//FM - Needed to place this here because the test class keep on failing on NULL!
		Id newHierarchyName;
		newHierarchyName = needNewHierarchy ? null : newHierarchy[0].Hierarchy__c;
		
		if(needNewHierarchy){
			AMS_Agencies_Hierarchy__c newh = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
			insert newh;
			newHierarchyName = newh.Id;
		}

		Id targetHO = needNewHierarchy ? targetAccount : getHierarchyHO(newHierarchy);

		system.debug('migrateAccountsToExistingHierarchy() --> targetAccount = '+targetAccount+' - agenciesToMigrate = '+agenciesToMigrate);
		system.debug('migrateAccountsToExistingHierarchy() --> currentHierarchy = '+currentHierarchy);
		system.debug('migrateAccountsToExistingHierarchy() --> newHierarchy = '+newHierarchy);
		system.debug('migrateAccountsToExistingHierarchy() --> completeMigration = '+completemigration);
		system.debug('migrateAccountsToExistingHierarchy() --> needNewHierarchy = '+needNewHierarchy);
		system.debug('migrateAccountsToExistingHierarchy() --> newHierarchyName = '+newHierarchyName);
		system.debug('migrateAccountsToExistingHierarchy() --> oldHO = '+oldHO);



		if(completeMigration){
			// Scenario 1) all the hierarchy is moved
			
			system.debug('migrateAccountsToExistingHierarchy() --> Scenario 1 ');


			HierarchyStruct res = new HierarchyStruct();
			res.relationsToUpdate = new List<AMS_Agencies_relationhip__c>();
			for(AMS_Agencies_relationhip__c rel : currentHierarchy){
				if(rel.Parent_Account__c == oldHO)
					rel.Parent_Account__c = targetHO;
 				rel.Hierarchy__c = newHierarchyName;
				res.relationsToUpdate.add(rel);
			}
			res.relationsToInsert = new List<AMS_Agencies_relationhip__c>();
			res.relationsToInsert.add(new AMS_Agencies_relationhip__c(Hierarchy__c = newHierarchyName, Parent_Account__c = targetHO, 
																	  Child_Account__c = oldHO));

			return res;

		}else{
			String errorMigration = validateIncompleteMigration(agenciesNotMigrated);
			
			// Scenario 3) HO + some branches --> I have some branches which will remain standalone --> ERROR
			if(errorMigration!=null)
				return new HierarchyStruct(errorMigration);
			
			system.debug('migrateAccountsToExistingHierarchy() --> Scenario 2 ');

			// Scenario 2) only some branches. All of them will be moved under the targetHO
			// Get all the relationships which links an agency to be moved to the old HO
			// Replace the old HO with the target HO in those relationships

			HierarchyStruct result = new HierarchyStruct();
			result.relationsToUpdate = new List<AMS_Agencies_relationhip__c>();

			for(AMS_Agencies_relationhip__c rel : currentHierarchy){
				if(agenciesToMigrate.contains(rel.Child_account__c) && rel.Parent_account__c == oldHO){
					rel.Hierarchy__c = newHierarchyName;
					rel.Parent_Account__c = targetHO;
					result.relationsToUpdate.add(rel);
				}
				
			}

			return result;
						
		}
	}
	
	
	
	// returns the ids of the agencies which belongs to this hierarchy but which are not included in the list agenciesToMigrate
	public static Set<Id> getAccountNotMigrated(List<AMS_Agencies_relationhip__c> hierarchyRelationships, Set<Id> agenciesToMigrate){

		System.debug('AGENCY CHANGES: hierarchyRelationships: ' + hierarchyRelationships + '  agenciesToMigrate: '+ agenciesToMigrate);

		Set<Id> accountsInHierarchy = new Set<Id>();
		Set<Id> accountsNotMigrated = new Set<Id>();
		for(AMS_Agencies_relationhip__c rel : hierarchyRelationships){
			accountsInHierarchy.add(rel.Parent_Account__c);
			accountsInHierarchy.add(rel.Child_Account__c);
		}
		for(Id id : accountsInHierarchy)
			if(!agenciesToMigrate.contains(id))
				accountsNotMigrated.add(id);

		System.debug('AGENCY CHANGES: accounts not migrated: ' + accountsNotMigrated);
		
		return accountsNotMigrated;
	}

	
	// return the HO's id of the hierarchy received as parameter
	public static Id getHierarchyHO(List<AMS_Agencies_relationhip__c> hierarchyRelationships){
		
		if(hierarchyRelationships.isEmpty())
			return null;

		Id hierarchyHO = hierarchyRelationships[0].Parent_Account__c;

		for(AMS_Agencies_relationhip__c rel : hierarchyRelationships){
			if(rel.Child_Account__c == hierarchyHO)
				hierarchyHO = rel.Parent_Account__c;
		}

		return hierarchyHO;
	}

	// return null if the incomplete migration is valid, a string with the error message otherwise
	public static String validateIncompleteMigration(Set<Id> agenciesNotMigrated){
		List<Account> accountsNotMigrated = [SELECT Id, Name, Status__c, IATAcode__c, Location_Type__c, ParentId FROM Account WHERE Id IN :agenciesNotMigrated];
		String errorMessage = '';
system.debug('NON MIGRATE = '+agenciesNotMigrated);
		for(Account a : accountsNotMigrated){


system.debug('DEVO VALIDARE '+a.Name+' - iata code '+a.IATAcode__c+' - Location type '+a.Location_Type__c+' - ParentId '+a.ParentId);

			// if the agency is active, is not an HO and was related to an HO which was moved I raise an error
			if(a.Location_Type__c!=AMS_Utils.HO && !agenciesNotMigrated.contains(a.ParentId) &&
				a.Status__c != AMS_Utils.ACC_S0_TERMINATED && a.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED)
				 
				errorMessage += (errorMessage=='' ? '' : '\n' ) + 
							'Cannot leave the agency '+a.Name+' with IATA code '+a.IATAcode__c+' as a standalone '+a.Location_Type__c+' agency, '+
							 'because it has status '+a.Status__c;
		}


		return errorMessage == '' ? null : errorMessage;
	}

	public class HierarchyStruct {

        public List<AMS_Agencies_relationhip__c> relationsToUpdate;
        public List<AMS_Agencies_relationhip__c> relationsToInsert; //the relationship to be inserted may have hierarchy = null. If so they should be filled with hierarchyToInsert
        public List<AMS_Agencies_relationhip__c> relationsToDelete;
        
        // map, hierarchy to insert --> relationship update with the hierarchy id and upsert
        // public AMS_Agencies_Hierarchy__c hierarchyToInsert;
		
		public String errorMessage = null;

        public HierarchyStruct(){}

        public HierarchyStruct(List<AMS_Agencies_relationhip__c> relationsToUpdate, List<AMS_Agencies_relationhip__c> relationsToInsert, List<AMS_Agencies_relationhip__c> relationsToDelete) {

            this.relationsToUpdate = relationsToUpdate;
            this.relationsToInsert = relationsToInsert;
            this.relationsToDelete = relationsToDelete;

        }
        
        public HierarchyStruct(String errorMessage){
        	this.errorMessage = errorMessage;
        }

    }

    // Method invoked by a button on Process Detail related list.
    // This will create a process detail for this Oscar for each account in the hierarhcy (except for the main account related to the oscar)
    // This method won't create any duplicate if there is already a process detail with the same OSCAR-Account
    webservice static void createProcessDetailForFullHierarchy(ID theOscarId, ID theMainAccountId){

    	Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies = getAccountsHierarchies(new Set<Id>{theMainAccountId});

		Set<Id> accountIdToBeAdded = new Set<Id>();

		for(AMS_Agencies_relationhip__c rel : hierarchies.get(theMainAccountId)){
			accountIdToBeAdded.add(rel.Parent_Account__c);
			accountIdToBeAdded.add(rel.Child_Account__c);
		}

		// remove the accounts terminated from the list of process detail to be created
		for(Account a : [SELECT Id, Name, Status__c FROM Account WHERE Id IN :accountIdToBeAdded AND Status__c = :AMS_Utils.ACC_S0_TERMINATED])
			accountIdToBeAdded.remove(a.Id);


		Set<Id> alreadyThere = new Set<Id>(); 
		for(AMS_Process_Detail__c det : [SELECT Account__c FROM AMS_Process_Detail__c WHERE Oscar__c = :theOscarId ]){
			alreadyThere.add(det.Account__c);
		}

		List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
		for(Id accountId : accountIdToBeAdded){
			if(accountId!=theMainAccountId && !alreadyThere.contains(accountId))
				pds.add(new AMS_Process_Detail__c(Account__c = accountId, OSCAR__c = theOscarId));
		}

		insert pds;

    }

}