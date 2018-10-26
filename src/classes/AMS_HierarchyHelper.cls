global class AMS_HierarchyHelper {

	// returns the list of relationships
	// NOTE: this is making the assumption that each agency is involved in max 1 hierarhcy
	public static Map<Id, List<AMS_Agencies_relationhip__c>>  getAccountsHierarchies(Set<Id> accountsIds) {

		// As first I retrieve all the hierarchies involved
		Map<Id, Set<Id>> hierarchyToAccounts = new Map<Id, Set<Id>>();

		system.debug(LoggingLevel.ERROR, 'getAccountsHierarchies() --> accountsIds ' + accountsIds);

		if(!accountsIds.isEmpty()){

			for (AMS_Agencies_relationhip__c h : [SELECT Hierarchy__c, Parent_Account__c, Child_Account__c
			                                      FROM AMS_Agencies_relationhip__c 
			                                      WHERE Parent_Account__c IN :accountsIds OR Child_Account__c IN :accountsIds ]) {

				system.debug(LoggingLevel.ERROR, 'getAccountsHierarchies() --> trovo hierarchy ' + h.ID);
				if (hierarchyToAccounts.get(h.Hierarchy__c) == null)
					hierarchyToAccounts.put(h.Hierarchy__c, new Set<Id>());


				if (accountsIds.contains(h.Parent_Account__c)) {
					hierarchyToAccounts.get(h.Hierarchy__c).add(h.Parent_Account__c);

				}/*else */if (accountsIds.contains(h.Child_Account__c)) {
					hierarchyToAccounts.get(h.Hierarchy__c).add(h.Child_Account__c);
				}
			}
		}

		system.debug(LoggingLevel.ERROR, 'getAccountsHierarchies() --> hierarchyToAccounts ' + hierarchyToAccounts);

		// Now I retrieve all the relationship for the hierarchies in the map
		Map<Id, List<AMS_Agencies_relationhip__c>> result = new Map<Id, List<AMS_Agencies_relationhip__c>>();

		for (Id accountId : accountsIds)
			result.put(accountId, new List<AMS_Agencies_relationhip__c>());
		//AMSU-134 added HO_Flag__c,Parent_agency__c, Child_Agency__c, Is_Newgen_Relation__c
		if(!hierarchyToAccounts.keyset().isEmpty()){
			
			for (AMS_Agencies_relationhip__c r : [SELECT Hierarchy__c, Parent_Account__c, Child_Account__c, Parent_Account__r.Location_Type__c,  Child_Account__r.Location_Type__c,  
													Child_Account__r.Status__c, Parent_Account__r.Status__c, Child_Account__r.Reason__c, Parent_Account__r.Reason__c,
													HO_Flag__c, Parent_agency__c, Child_Agency__c, Is_Newgen_Relation__c
			                                      FROM AMS_Agencies_relationhip__c
			                                      WHERE Hierarchy__c IN :hierarchyToAccounts.keyset() ]) {

				system.debug(LoggingLevel.ERROR, 'getAccountsHierarchies() --> found relationship ' + r);
				for (Id theAccountId : hierarchyToAccounts.get(r.Hierarchy__c)) {
					result.get(theAccountId).add(r);
				}
			}
		}

		System.debug('getAccountsHierarchies() --> result ' + result);

		return result;
	}

	// return hierarchy relationships that need to be updated
	// the first parameter is the account which will become the new HO
	public static HierarchyStruct switchParentWithChild(Id newParent, Id oldParent, String changeLocationTypeBehavior, Map<Id, Account> accounts, List<AMS_Agencies_relationhip__c> hierarchyRelationships) {

		// loop over all the relationships and switch the child with the parent
		List<AMS_Agencies_relationhip__c> relToUpdate = new List<AMS_Agencies_relationhip__c>();
		if(hierarchyRelationships.isEmpty()) return new HierarchyStruct(relToUpdate, null, null, null);
 
		Id hierarchyHO = getHierarchyHO(hierarchyRelationships);
		System.debug('Hierarchy HO: ' + accounts.get(hierarchyHO).Name + ' ('+accounts.get(hierarchyHO).IATACode__c+')');

		for (AMS_Agencies_relationhip__c rel : hierarchyRelationships) {

			System.debug('Processing relation: '+
				+' \nParent -> ' + accounts.get(rel.Parent_Account__c).Name + ' ('+accounts.get(rel.Parent_Account__c).IATACode__c+') '+
				+' \nChild -> ' + accounts.get(rel.Child_Account__c).Name + ' ('+accounts.get(rel.Child_Account__c).IATACode__c+')');

			Boolean relNeedsUpdate = false;

			//exception to te general rule, no switch between parent <-> child in this situation
			//here only one relation will need to be updated, the one where the SA(for which the oscar was opened) is a child.
			if (changeLocationTypeBehavior == AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP && accounts.get(newParent).Location_Type__c == AMS_Utils.SA) {
				if (rel.Child_Account__c == newParent) {
					rel.Parent_Account__c = hierarchyHO;
					relNeedsUpdate = true;
				}
			} else {
				//relations having the parent equal to the old parent must be updated with the new parent
				//child of the relation which have location type SA is an exception and should keep the parent UNLESS the new parent is an SA
				if (rel.Parent_Account__c == oldParent && (accounts.get(rel.Child_Account__c).Location_Type__c != AMS_Utils.SA || /*rel.Child_Account__c == newParent || */accounts.get(newParent).Location_Type__c == AMS_Utils.SA)) {
					System.debug('PARENT REPLACE: ' + accounts.get(rel.Parent_Account__c).Name + ' ('+ accounts.get(rel.Parent_Account__c).IATACode__c + ') WITH ' + accounts.get(newParent).Name + ' (' + accounts.get(newParent).IATACode__c + ')');
					rel.Parent_Account__c = newParent;
					relNeedsUpdate = true;
				}
				//relations having the parent equal to the new parent must be updated with the old parent
				//child of the relation which have location type SA is an exception and should keep the parent
				else if (rel.Parent_Account__c == newParent && (accounts.get(rel.Child_Account__c).Location_Type__c != AMS_Utils.SA /*|| rel.Child_Account__c == newParent || accounts.get(newParent).Location_Type__c == AMS_Utils.SA*/)) {
					System.debug('PARENT REPLACE: ' + accounts.get(rel.Parent_Account__c).Name + ' ('+ accounts.get(rel.Parent_Account__c).IATACode__c + ') WITH ' + accounts.get(oldParent).Name + ' (' + accounts.get(oldParent).IATACode__c + ')');
					rel.Parent_Account__c = oldParent;
					relNeedsUpdate = true;
				}
				//relations having the child equal to the new parent must be updated with the old parent
				if (rel.Child_Account__c == newParent) {
					System.debug('CHILD REPLACE: ' + accounts.get(rel.Child_Account__c).Name + ' ('+ accounts.get(rel.Child_Account__c).IATACode__c + ') WITH ' + accounts.get(oldParent).Name + ' (' + accounts.get(oldParent).IATACode__c + ')');
					rel.Child_Account__c = oldParent;
					relNeedsUpdate = true;
				}
				//relations having the child equal to the old parent must be updated with the new parent
				else if (rel.Child_Account__c == oldParent) {
					System.debug('CHILD REPLACE: ' + accounts.get(rel.Child_Account__c).Name + ' ('+ accounts.get(rel.Child_Account__c).IATACode__c + ') WITH ' + accounts.get(newParent).Name + ' (' + accounts.get(newParent).IATACode__c + ')');
					rel.Child_Account__c = newParent;
					relNeedsUpdate = true;
				}
			}

			if (relNeedsUpdate)
				relToUpdate.add(rel);
		}

		return new HierarchyStruct(relToUpdate, null, null, null);
	}

	public static HierarchyStruct reparentChildSA(Id child, Id newParent, Map<Id, Account> accounts, List<AMS_Agencies_relationhip__c> hierarchyRelationships) {

		List<AMS_Agencies_relationhip__c> relToUpdate = new List<AMS_Agencies_relationhip__c>();

		for (AMS_Agencies_relationhip__c rel : hierarchyRelationships) {

			System.debug('Processing relation: Parent -> ' + accounts.get(rel.Parent_Account__c).Name + ' Child -> ' + accounts.get(rel.Child_Account__c).Name);

			if (rel.Child_Account__c == child) {
				System.debug('PARENT REPLACE: ' + accounts.get(rel.Parent_Account__c).Name + ' WITH ' + accounts.get(newParent).Name);
				rel.Parent_Account__c = newParent;
				relToUpdate.add(rel);
				break;
			}

		}

		return new HierarchyStruct(relToUpdate, null, null, null);
	}


	// return hierarchy relationships that need to be updated
	// this is covering the scenarios NON-IATA BUYS IATA
	// newHO = the agency for which the OSCAR was opened
	// hierarchyRelationships = newHO's hierarhcy
	// agenciesToMigrate = the list of the agencies which will be migrated: newHO + all the others
	public static HierarchyStruct migrateAccountsToNewHierarchy(Id newHO, Map<Id, Account> accounts, List<AMS_Agencies_relationhip__c> hierarchyRelationships, Set<Id> agenciesToMigrate) {

		// check if the old hierarchy is completely migrated
		Set<Id> agenciesNotMigrated = getAccountNotMigrated(hierarchyRelationships, agenciesToMigrate);
		boolean completeMigration = (agenciesNotMigrated.size() == 0);
		boolean singleAgencyMigration = (agenciesToMigrate.size() == 1);

		system.debug(LoggingLevel.ERROR, 'COMPLETE MIGRATION ? ' + completemigration);

		// check if the old HO is the same as the new HO
		Id oldHO = getHierarchyHO(hierarchyRelationships);

		if (completeMigration) {
			// Scenario 1) all the hierarchy is moved
			//when HO is not changed or the oscar was opened on an SA nothing is changed on the hierarchy
			if (newHO == oldHO || accounts.get(newHO).Location_Type__c == AMS_Utils.SA)
				return new HierarchyStruct();
			else
				return switchParentWithChild(newHO, oldHO, null, accounts, hierarchyRelationships);
			//return switchBRwithHO(newHO,hierarchyRelationships);
		} else {
			String errorMigration = validateIncompleteMigration(agenciesNotMigrated);

			// Scenario 3) HO + some branches --> I have some branches which will remain standalone --> ERROR
			if (errorMigration != null)
				return new HierarchyStruct(errorMigration);

			AMS_Agencies_Hierarchy__c newHierarchy;

			if (!singleAgencyMigration) {
				newHierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
				insert newHierarchy;
				System.debug('AGENCY CHANGES: Hierarchy Id: ' + newHierarchy.id);
			} else {
				Account acc = accounts.get(newHO);
				acc.Location_Type__c = AMS_Utils.HO;
				acc.ParentId = null;
				update acc;
			}

			HierarchyStruct result = new HierarchyStruct();
			// Now I create relationships for the agencies in the new hieararchy
			result.relationsToInsert = new List<AMS_Agencies_relationhip__c>();
			result.relationsToUpdate = new List<AMS_Agencies_relationhip__c>();

			// Scenario 2) only some branches. One of them will became the new HO
			// Separate the relationships in three:
			//  - the ones which links agencies in the old hierarchy to agencies in the old hierarchy --> nothing to do
			//  - the ones which links agencies in the new hierarchy to agencies in the new hierarchy --> nothing to do
			//  - the ones which links agencies in the old hierarchy to agencies in the new hierarchy --> to be deleted

			List<AMS_Agencies_relationhip__c> oldHier = new List<AMS_Agencies_relationhip__c>();
			List<AMS_Agencies_relationhip__c> newHier = new List<AMS_Agencies_relationhip__c>();
			List<AMS_Agencies_relationhip__c> oldnewHier = new List<AMS_Agencies_relationhip__c>();

			/*for(AMS_Agencies_relationhip__c rel : hierarchyRelationships){
				if(agenciesNotMigrated.contains(rel.Parent_account__c) && agenciesNotMigrated.contains(rel.Child_account__c))
					oldHier.add(rel);
				else if(agenciesNotMigrated.contains(rel.Parent_account__c) && agenciesToMigrate.contains(rel.Child_account__c))
					oldnewHier.add(rel);
				else if(agenciesToMigrate.contains(rel.Parent_account__c) && agenciesNotMigrated.contains(rel.Child_account__c))
					oldnewHier.add(rel);
				else if(agenciesToMigrate.contains(rel.Parent_account__c) && agenciesToMigrate.contains(rel.Child_account__c))
					newHier.add(rel);
			}*/

			for (AMS_Agencies_relationhip__c rel : hierarchyRelationships) {
				if (agenciesNotMigrated.contains(rel.Parent_account__c) && agenciesNotMigrated.contains(rel.Child_account__c))
					oldHier.add(rel);
				else if (agenciesNotMigrated.contains(rel.Parent_account__c) && agenciesToMigrate.contains(rel.Child_account__c)) {
					oldnewHier.add(rel);
					//children being migrated without their parents will become child of the newHO
					if (rel.Child_account__c != newHO)
						result.relationsToInsert.add(new AMS_Agencies_relationhip__c(Parent_Account__c = newHO, Child_Account__c = rel.Child_account__c, Hierarchy__c = newHierarchy.id));
				}
				//LM: This situation should never happen since it would leave a child without parent in the original hierarchy
				//else if(agenciesToMigrate.contains(rel.Parent_account__c) && agenciesNotMigrated.contains(rel.Child_account__c))
				//	oldnewHier.add(rel);
				else if (agenciesToMigrate.contains(rel.Parent_account__c) && agenciesToMigrate.contains(rel.Child_account__c)) {
					oldnewHier.add(rel);
					if (rel.Child_account__c != newHO)
						//An SA will remain as child of its parent
						if (accounts.get(rel.Child_account__c).Location_Type__c == AMS_Utils.SA)
							result.relationsToInsert.add(new AMS_Agencies_relationhip__c(Parent_Account__c = rel.Parent_account__c, Child_Account__c = rel.Child_account__c, Hierarchy__c = newHierarchy.id));
						else
							result.relationsToInsert.add(new AMS_Agencies_relationhip__c(Parent_Account__c = newHO, Child_Account__c = rel.Child_account__c, Hierarchy__c = newHierarchy.id));
				}
			}

			system.debug('migrateAccountsToNewHierarchy() SCENARIO 2: only some branches!');

			system.debug('migrateAccountsToNewHierarchy() agenciesToMigrate = ' + agenciesToMigrate);
			system.debug('migrateAccountsToNewHierarchy() agenciesNotMigrated = ' + agenciesNotMigrated);

			system.debug('migrateAccountsToNewHierarchy() oldHier = ' + oldHier);
			system.debug('migrateAccountsToNewHierarchy() newHier = ' + newHier);
			system.debug('migrateAccountsToNewHierarchy() oldnewHier = ' + oldnewHier);


			result.relationsToDelete = oldnewHier;

			return result;

		}

	}


	// return hierarchy relationships that need to be updated
	// this is covering the scenarios IATA BUYS IATA
	// mainAccount = the agency for which the OSCAR was opened
	// currentHierarchy = mainAccount's hierarhcy
	// targetHO = the HO of the target hierarchy
	// agenciesToMigrate = the list of the agencies which will be migrated: the mainAccount + all the others
	public static HierarchyStruct migrateAccountsToExistingHierarchy(Id oldHO, List<AMS_Agencies_relationhip__c> currentHierarchy, Id targetAccount, List<AMS_Agencies_relationhip__c> newHierarchy, Set<Id> agenciesToMigrate, Map<Id, Account> accounts) {
		// check if the old hierarchy is completely migrated
		Set<Id> agenciesNotMigrated = getAccountNotMigratedExcludingTerminated(currentHierarchy, agenciesToMigrate, accounts);
		boolean completeMigration = (agenciesNotMigrated.size() == 0);

		List<Account> accountsToUpdate = new List<Account>();

		// check if the old HO is the same as the new HO
		//Id oldHO = getHierarchyHO(currentHierarchy);
		boolean needNewHierarchy = newHierarchy.size() == 0;

		//FM - Needed to place this here because the test class keep on failing on NULL!
		Id newHierarchyName;
		newHierarchyName = needNewHierarchy ? null : newHierarchy[0].Hierarchy__c;

		if (needNewHierarchy) {
			AMS_Agencies_Hierarchy__c newh = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
			insert newh;
			newHierarchyName = newh.Id;
		}

		Id targetHO = needNewHierarchy ? targetAccount : getHierarchyHO(newHierarchy);

		system.debug('migrateAccountsToExistingHierarchy() --> targetAccount = ' + targetAccount + ' - agenciesToMigrate = ' + agenciesToMigrate);
		system.debug('migrateAccountsToExistingHierarchy() --> currentHierarchy = ' + currentHierarchy);
		system.debug('migrateAccountsToExistingHierarchy() --> newHierarchy = ' + newHierarchy);
		system.debug('migrateAccountsToExistingHierarchy() --> completeMigration = ' + completemigration);
		system.debug('migrateAccountsToExistingHierarchy() --> needNewHierarchy = ' + needNewHierarchy);
		system.debug('migrateAccountsToExistingHierarchy() --> newHierarchyName = ' + newHierarchyName);
		system.debug('migrateAccountsToExistingHierarchy() --> oldHO = ' + oldHO);



		if (completeMigration) {
			// Scenario 1) all the hierarchy is moved

			system.debug('migrateAccountsToExistingHierarchy() --> Scenario 1 ');


			HierarchyStruct res = new HierarchyStruct();
			res.relationsToUpdate = new List<AMS_Agencies_relationhip__c>();
			res.relationsToDelete = new List<AMS_Agencies_relationhip__c>();
			res.hierarchiesToDelete = new List<Id>();

			Id hierarchyToDelete;

			for (AMS_Agencies_relationhip__c rel : currentHierarchy) {

				if(hierarchyToDelete==null)
					hierarchyToDelete = rel.Hierarchy__c;

				//BRs under the oldHO will move under the targetHO
				if ((rel.Parent_Account__c == oldHO && rel.Child_Account__r.Location_Type__c == AMS_Utils.BR && rel.Child_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED) 
					|| (rel.Parent_Account__c == oldHO && rel.Child_Account__r.Location_Type__c == AMS_Utils.SA && rel.Child_Account__r.Status__c == AMS_Utils.ACC_S1_NOTACCREDITED)){
					rel.Parent_Account__c = targetHO;
					rel.Hierarchy__c = newHierarchyName;
				}
				//TERMINATED BRs ARE TO BE LEFT STANDALONE
				//TERMINATED SAs UNDER TERMINATED BRs also to be left STANDALONE
				if((rel.Parent_Account__c == oldHO && rel.Child_Account__r.Location_Type__c == AMS_Utils.BR && rel.Child_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED)
					|| (rel.Parent_Account__r.Location_Type__c == AMS_Utils.BR && rel.Parent_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED && rel.Child_Account__r.Location_Type__c == AMS_Utils.SA && rel.Child_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED)){
					//delete relation
					//remove parentId from Account
					res.relationsToDelete.add(rel);
					Account a = accounts.get(rel.Child_Account__c);
					a.ParentId = null;
					accountsToUpdate.add(a);
				}
				else{
					rel.Hierarchy__c = newHierarchyName;
					res.relationsToUpdate.add(rel);
				}
			}
			//still need to create a new relation to move the oldHO under the targetHO
			res.relationsToInsert = new List<AMS_Agencies_relationhip__c>();
			res.relationsToInsert.add(new AMS_Agencies_relationhip__c(Hierarchy__c = newHierarchyName, Parent_Account__c = targetHO,
			                          Child_Account__c = oldHO));

			if(!accountsToUpdate.isEmpty())
				update accountsToUpdate;

			//on a complete migration the old hierarchy is to be deleted
			res.hierarchiesToDelete.add(hierarchyToDelete);

			return res;

		} else {
			String errorMigration = validateIncompleteMigration(agenciesNotMigrated);

			// Scenario 3) HO + some branches --> I have some branches which will remain standalone --> ERROR
			if (errorMigration != null)
				return new HierarchyStruct(errorMigration);

			system.debug('migrateAccountsToExistingHierarchy() --> Scenario 2 ');

			// Scenario 2) only some branches. All of them will be moved under the targetHO
			// Get all the relationships which links an agency to be moved to the old HO
			// Replace the old HO with the target HO in those relationships

			HierarchyStruct result = new HierarchyStruct();
			result.relationsToUpdate = new List<AMS_Agencies_relationhip__c>();

			for (AMS_Agencies_relationhip__c rel : currentHierarchy) {

				if (agenciesToMigrate.contains(rel.Child_account__c)) {
					//Branch will be moved under the targetHO
					if (rel.Child_account__r.Location_Type__c == AMS_Utils.BR) {
						rel.Parent_Account__c = targetHO;
					} else if (rel.Child_account__r.Location_Type__c == AMS_Utils.SA) {
						//SA will move under the targetHO if the parent is not being migrated
						if (!agenciesToMigrate.contains(rel.Parent_account__c))
							rel.Parent_Account__c = targetHO;
					}
					rel.Hierarchy__c = newHierarchyName;
					result.relationsToUpdate.add(rel);
				}
				/*if(agenciesToMigrate.contains(rel.Child_account__c) && rel.Parent_account__c == oldHO){
					rel.Hierarchy__c = newHierarchyName;
					rel.Parent_Account__c = targetHO;
					result.relationsToUpdate.add(rel);
				}*/

			}

			return result;

		}
	}



	// returns the ids of the agencies which belongs to this hierarchy but which are not included in the list agenciesToMigrate
	public static Set<Id> getAccountNotMigrated(List<AMS_Agencies_relationhip__c> hierarchyRelationships, Set<Id> agenciesToMigrate) {

		System.debug('AGENCY CHANGES: hierarchyRelationships: ' + hierarchyRelationships + '  agenciesToMigrate: ' + agenciesToMigrate);

		Set<Id> accountsInHierarchy = new Set<Id>();
		Set<Id> accountsNotMigrated = new Set<Id>();
		for (AMS_Agencies_relationhip__c rel : hierarchyRelationships) {
			accountsInHierarchy.add(rel.Parent_Account__c);
			accountsInHierarchy.add(rel.Child_Account__c);
		}
		for (Id id : accountsInHierarchy)
			if (!agenciesToMigrate.contains(id))
				accountsNotMigrated.add(id);

		System.debug('AGENCY CHANGES: accounts not migrated: ' + accountsNotMigrated);

		return accountsNotMigrated;
	}

	public static Set<Id> getAccountNotMigratedExcludingTerminated(List<AMS_Agencies_relationhip__c> hierarchyRelationships, Set<Id> agenciesToMigrate, Map<Id, Account> accounts) {

		System.debug('AGENCY CHANGES: hierarchyRelationships: ' + hierarchyRelationships + '  agenciesToMigrate: ' + agenciesToMigrate);

		Set<Id> accountsInHierarchy = new Set<Id>();
		Set<Id> accountsNotMigrated = new Set<Id>();
		for (AMS_Agencies_relationhip__c rel : hierarchyRelationships) {
			accountsInHierarchy.add(rel.Parent_Account__c);
			accountsInHierarchy.add(rel.Child_Account__c);
		}
		for (Id id : accountsInHierarchy)
			if (!agenciesToMigrate.contains(id) && accounts.get(id).Status__c != AMS_Utils.ACC_S0_TERMINATED)
				accountsNotMigrated.add(id);

		System.debug('AGENCY CHANGES: accounts not migrated: ' + accountsNotMigrated);

		return accountsNotMigrated;
	}


	// return the HO's id of the hierarchy received as parameter
	public static Id getHierarchyHO(List<AMS_Agencies_relationhip__c> hierarchyRelationships) {

		if (hierarchyRelationships.isEmpty())
			return null;

		Id hierarchyHO = hierarchyRelationships[0].Parent_Account__c;

		for (AMS_Agencies_relationhip__c rel : hierarchyRelationships) {
			if (rel.Child_Account__c == hierarchyHO)
				hierarchyHO = rel.Parent_Account__c;
		}

		return hierarchyHO;
	}

	// return null if the incomplete migration is valid, a string with the error message otherwise
	public static String validateIncompleteMigration(Set<Id> agenciesNotMigrated) {
		List<Account> accountsNotMigrated = [SELECT Id, Name, Status__c, IATAcode__c, Location_Type__c, ParentId FROM Account WHERE Id IN :agenciesNotMigrated];
		String errorMessage = '';
		system.debug('NON MIGRATE = ' + agenciesNotMigrated);
		for (Account a : accountsNotMigrated) {


			system.debug('DEVO VALIDARE ' + a.Name + ' - iata code ' + a.IATAcode__c + ' - Location type ' + a.Location_Type__c + ' - ParentId ' + a.ParentId);

			//whenever a child agency (active) is left without a parent an error should be raised
			if (a.Location_Type__c != AMS_Utils.HO && a.Location_Type__c != AMS_Utils.AO && !agenciesNotMigrated.contains(a.ParentId) &&
			        a.Status__c != AMS_Utils.ACC_S0_TERMINATED && a.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED)

				errorMessage += (errorMessage == '' ? '' : '\n' ) +
				                'Cannot leave the agency ' + a.Name + ' with IATA code ' + a.IATAcode__c + ' as a standalone ' + a.Location_Type__c + ' agency, ' +
				                'because it has status ' + a.Status__c;
		}


		return errorMessage == '' ? null : errorMessage;
	}

	// return null if the incomplete migration is valid, a string with the error message otherwise
	public static Boolean isAllHierarchySelected(Set<Id> agenciesSelected, List<AMS_Agencies_relationhip__c> hierarchyRelationships, Map<Id, Account> accounts) {
		for (AMS_Agencies_relationhip__c rel : hierarchyRelationships) {
			Id parentId = rel.Parent_Account__c;
			Id childId = rel.Child_Account__c;
			//only active hierarchy agencies are to be considered
			Account parent = accounts.get(parentId); 
			Account child = accounts.get(childId);
			if (parent !=null && parent.Status__c != AMS_Utils.ACC_S0_TERMINATED && parent.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && !agenciesSelected.contains(parentId)){
				return false;
			}
			if (child !=null && child.Status__c != AMS_Utils.ACC_S0_TERMINATED && child.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && child.Status__c != null && !agenciesSelected.contains(childId)){				
				return false;
			}
		}
		return true;
	}

	public static Boolean isAllHierarchySelectedExcludeAbroad(Set<Id> agenciesSelected, List<AMS_Agencies_relationhip__c> hierarchyRelationships, Map<Id, Account> accounts) {
		for (AMS_Agencies_relationhip__c rel : hierarchyRelationships) {
			Id parentId = rel.Parent_Account__c;
			Id childId = rel.Child_Account__c;
			//only active hierarchy agencies are to be considered
			Account parent = accounts.get(parentId); 
			Account child = accounts.get(childId);
			if(child.Is_Branch_Abroad__c != 'Yes'){
				if (parent !=null && parent.Status__c != AMS_Utils.ACC_S0_TERMINATED && parent.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && !agenciesSelected.contains(parentId)){
					return false;
				}
				if (child !=null && child.Status__c != AMS_Utils.ACC_S0_TERMINATED && child.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && child.Status__c != null && !agenciesSelected.contains(childId)){				
					return false;
				}
			}
		}
		return true;
	}

	public class HierarchyStruct {

		public List<AMS_Agencies_relationhip__c> relationsToUpdate;
		public List<AMS_Agencies_relationhip__c> relationsToInsert; //the relationship to be inserted may have hierarchy = null. If so they should be filled with hierarchyToInsert
		public List<AMS_Agencies_relationhip__c> relationsToDelete;

		public List<Id> hierarchiesToDelete;

		// map, hierarchy to insert --> relationship update with the hierarchy id and upsert
		// public AMS_Agencies_Hierarchy__c hierarchyToInsert;

		public String errorMessage = null;

		public HierarchyStruct() {}

		public HierarchyStruct(List<AMS_Agencies_relationhip__c> relationsToUpdate, List<AMS_Agencies_relationhip__c> relationsToInsert, List<AMS_Agencies_relationhip__c> relationsToDelete, List<Id> hierarchiesToDelete) {

			this.relationsToUpdate = relationsToUpdate;
			this.relationsToInsert = relationsToInsert;
			this.relationsToDelete = relationsToDelete;
			this.hierarchiesToDelete = hierarchiesToDelete;

		}

		public HierarchyStruct(String errorMessage) {
			this.errorMessage = errorMessage;
		}

	}

	// Method invoked by a button on Process Detail related list.
	// This will create a process detail for this Oscar for each account in the hierarhcy (except for the main account related to the oscar)
	// This method won't create any duplicate if there is already a process detail with the same OSCAR-Account
	webservice static void createProcessDetailForFullHierarchy(ID theOscarId, ID theMainAccountId) {
		ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');
		Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies = getAccountsHierarchies(new Set<Id> {theMainAccountId});

		Set<Id> accountIdToBeAdded = new Set<Id>();

		for (AMS_Agencies_relationhip__c rel : hierarchies.get(theMainAccountId)) {
			accountIdToBeAdded.add(rel.Parent_Account__c);
			accountIdToBeAdded.add(rel.Child_Account__c);
		}

		AMS_OSCAR__c oscar = [SELECT Process__c FROM AMS_OSCAR__c WHERE Id = :theOscarId LIMIT 1];

		if(oscar.Process__c == AMS_Utils.VOLRELINQUISH || oscar.Process__c == AMS_Utils.VOLRELINQUISH_CA){

			// remove the accounts terminated and not accreditated from the list of process detail to be created
			for (Account a : [SELECT Id, Name, Status__c FROM Account WHERE Id IN :accountIdToBeAdded AND (Status__c = :AMS_Utils.ACC_S0_TERMINATED OR Status__c =: AMS_Utils.ACC_S1_NOTACCREDITED OR Status__c = '')]){

				accountIdToBeAdded.remove(a.Id);
			}

		} else {

			// remove the accounts terminated from the list of process detail to be created
			for (Account a : [SELECT Id, Name, Status__c FROM Account WHERE Id IN :accountIdToBeAdded AND (Status__c = :AMS_Utils.ACC_S0_TERMINATED OR Status__c = '')]){

				accountIdToBeAdded.remove(a.Id);
			}

		}


		Set<Id> alreadyThere = new Set<Id>();
		//DTULLO: Added check on the record type
		//for (AMS_Process_Detail__c det : [SELECT Account__c FROM AMS_Process_Detail__c WHERE Oscar__c = :theOscarId ]) {
		for (AMS_Process_Detail__c det : [SELECT Account__c FROM AMS_Process_Detail__c WHERE Oscar__c = :theOscarId and recordtype.developername='Agency_Involved']) {
			alreadyThere.add(det.Account__c);
		}

		List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
		for (Id accountId : accountIdToBeAdded) {
			if (accountId != theMainAccountId && !alreadyThere.contains(accountId))
				//DTULLO: Added Record Type
				pds.add(new AMS_Process_Detail__c(Account__c = accountId, OSCAR__c = theOscarId, recordtypeid = rtAgencyInvolved));
		}

		insert pds;

	}

	//verifies if every account involved has all its children selected
	public static Boolean isAllChildrenSelected(AMS_Oscar__c oscar) {
		List<AMS_Oscar__c> oscars = new List<AMS_Oscar__c>{oscar};

		//fetch all relationships for each account
		Map<Id, List<AMS_Agencies_relationhip__c>> relationshipMap = getAccountsHierarchies(new Set<Id>{oscar.Account__c});


		//gets selected accounts for each oscar
		Map<Id, Set<Id>> accountsInvolved = new Map<Id, Set<Id>>{ oscar.Id => new Set<Id>{oscar.Account__c} };
		//DTULLO: Added check on record-type
		//for(AMS_Process_Detail__c pd : [SELECT Id, Account__c, OSCAR__c FROM AMS_Process_Detail__c WHERE Oscar__c = :accountsInvolved.keyset()]){
		for(AMS_Process_Detail__c pd : [SELECT Id, Account__c, OSCAR__c FROM AMS_Process_Detail__c WHERE Oscar__c = :accountsInvolved.keyset() and recordtype.developername='Agency_Involved']){
			accountsInvolved.get(pd.OSCAR__c).add(pd.Account__c);
		}

		return isAllChildrenSelected(oscars, relationshipMap, accountsInvolved).get(oscar.Id);
	}

	public static Map<Id, Boolean> isAllChildrenSelected(List<AMS_Oscar__c> oscars, Map<Id, List<AMS_Agencies_relationhip__c>> relationshipMap, Map<Id, Set<Id>> accountsInvolved) {

		Map<Id, Boolean> results = new Map<Id, Boolean>();

		//initialize map
		for(AMS_Oscar__c oscar : oscars){
			results.put(oscar.Id, true);
		}

		//create a map for the child accounts for every level on the hierarchy
		Map<Id, Map<Id, Set<Id>>> childAccounts = new Map<Id, Map<Id, Set<Id>>>();
		for(AMS_Oscar__c oscar : oscars){
			childAccounts.put(oscar.Id, new Map<Id, Set<Id>>());
			childAccounts.get(oscar.Id).put(oscar.Account__c, new Set<Id>());

			for(AMS_Agencies_relationhip__c r : relationshipMap.get(oscar.Account__c)){

				if(!childAccounts.get(oscar.Id).containsKey(r.Parent_Account__c)) childAccounts.get(oscar.Id).put(r.Parent_Account__c, new Set<Id>());
				if(!childAccounts.get(oscar.Id).containsKey(r.Child_Account__c)) childAccounts.get(oscar.Id).put(r.Child_Account__c, new Set<Id>());

				if(r.Child_Account__r.Status__c != null && r.Child_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && r.Child_Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && r.Child_Account__r.Status__c != '') childAccounts.get(oscar.Id).get(r.Parent_Account__c).add(r.Child_Account__c);
			}
		}

		//check if all the selected account childrens are also selected
		for(AMS_Oscar__c oscar : oscars){
			for(Id accId : accountsInvolved.get(oscar.Id)){
				for(Id childId : childAccounts.get(oscar.Id).get(accId)){
					if(!accountsInvolved.get(oscar.Id).contains(childId)) results.put(oscar.Id, false);
				}
			}
		}
		return results;
	}

	//compares the owners between several accounts in the same hierarchy
	public static boolean checkHierarchyIntegrity( Map<Id, Set<Id>> oscarAccounts ) {

		// Let's get all the information about the Account Roles to Compare
		Map<Id, List<AMS_Account_Role__c>> rolesForAccounts = fetchRolesInAccounts(oscarAccounts.values());

		if (rolesForAccounts.isEmpty())
			return true;

		// now we have to divide the accounts between the Oscars

		List<Id> oscarIds = new List<Id>(oscarAccounts.keySet());

		for (Id oscarId : oscarIds) {

			//list of accounts from a specific OSCAR
			Set<Id> accountsToAnalyze = oscarAccounts.get(oscarId);

			Map<Id, List<AMS_Account_Role__c>> accountsWithRoles = new Map<Id, List<AMS_Account_Role__c>>();

			for (Id account : accountsToAnalyze) {


				accountsWithRoles.put(account, rolesForAccounts.get(account));


			}

			// now we have a map with Accounts and Roles, so let's compare them ...

			return compareRolesInAccounts(accountsWithRoles);


		}




		return true;

	}

	private static boolean compareRolesInAccounts(Map<Id, List<AMS_Account_Role__c>> accountsWithRoles) {

		Set<Id> accountIds = accountsWithRoles.keySet();

		// for each Account we should compare it against all the others.
		for (Id account : accountIds) {

			List<AMS_Account_Role__c> roles = accountsWithRoles.get(account);

			if (roles == null)
				return false;


			// so we do not compare against itself
			accountsWithRoles.remove(account);

			if (!deepCompareRolesInAccounts(roles, accountsWithRoles))
				return false;

			break;
		}

		return true;

	}


	private static boolean deepCompareRolesInAccounts(List<AMS_Account_Role__c> roles, Map<Id, List<AMS_Account_Role__c>> accountsWithRoles) {



		Set<Id> accountIds = accountsWithRoles.keySet();

		// for each Account we should compare it against all the others.
		for (Id account : accountIds) {

			List<AMS_Account_Role__c> rolesToCompare = accountsWithRoles.get(account);

			if (rolesToCompare == null || !compareRolesList(roles, rolesToCompare))
				return false;

		}

		return true;



	}

	private static boolean compareRolesList(List<AMS_Account_Role__c> leftList, List<AMS_Account_Role__c> rightList) {

		// they have to have the same numbers of owners, otherwise we don't even have to compare it...

		if (leftList.size() != rightList.size()) {
			System.debug('List of owners have diff sizes, returning false.');
			return false;
		}

		for (AMS_Account_Role__c role : leftList) {

			AMS_Account_Role__c elemFound = fetchRoleInList(role, rightList);

			if (elemFound == null) {
				System.debug('Did not find any role, returning false.');
				return false;
			}

			Set<AMS_Account_Role__c> tempSetRole = new Set<AMS_Account_Role__c>(rightList);

			tempSetRole.remove(elemFound);

			rightList = new List<AMS_Account_Role__c>(tempSetRole);

		}

		return true;

	}


	public static AMS_Account_Role__c fetchRoleInList(AMS_Account_Role__c roleToFind, List<AMS_Account_Role__c> listToFind) {

		for (AMS_Account_Role__c role : listToFind) {

			if (compareRoles(roleToFind, role)) {
				return role;
			}

		}

		System.debug('Comparison did not return any role, returning false.');
		return null;
	}

	public static boolean compareRoles(AMS_Account_Role__c roleOriginal, AMS_Account_Role__c roleList) {

		System.debug('Preparing to compare the following roles: ' + roleOriginal + ' and ' + roleList);

		if (roleOriginal.Contact__c != null && roleOriginal.Contact__c == roleList.Contact__c) {
			return true;
		}

		if (roleOriginal.Person__c != null && roleOriginal.Person__c == roleList.Person__c) {
			return true;
		}

		if (roleOriginal.Owner_Account__c != null && roleOriginal.Owner_Account__c == roleList.Owner_Account__c) {
			return true;
		}

		if (roleOriginal.Legacy_External_ID__c != null && roleOriginal.Owner_Name__c != null && roleOriginal.Owner_Name__c == roleList.Owner_Name__c  ) {
			return true;
		}

		System.debug('Could not find any kind of match between the 2 roles, returning false.');

		return false;

	}

	private static Map<Id, List<AMS_Account_Role__c>> fetchRolesInAccounts(List<Set<Id>> accts) {

		Set<Id> acctsToSearch = new Set<Id>();

		for (Set<Id> toAdd : accts) {

			acctsToSearch.addAll(toAdd);
		}

		Map<Id, List<AMS_Account_Role__c>> toReturn = new Map<Id, List<AMS_Account_Role__c>>();

		List<AMS_Account_Role__c> allRoles = [SELECT Id, RecordType.Name, Account__c, Contact__c, Contact__r.Email, Owner_Account__c, Percentage__c, Person__c, Person__r.Contact__c, Person__r.Contact__r.Email , Owner_Name__c, Legacy_System__c, Legacy_External_ID__c FROM AMS_Account_Role__c where Account__c in :acctsToSearch and Active__c = true and Termination_Date__c = null and RecordType.DeveloperName = 'Ownership'];

		For(AMS_Account_Role__c role: allRoles) {

			List<AMS_Account_Role__c> roles =  toReturn.get(role.Account__c);

			if ( roles == null) {

				List<AMS_Account_Role__c> roleList = new List<AMS_Account_Role__c>();
				roleList.add(role);

				toReturn.put(role.Account__c, roleList);

			} else {

				roles.add(role);

				toReturn.put(role.Account__c, roles);

			}

		}

		return toReturn;

	}

	public static Set<Id> addTerminatedDescendants(Set<Id> agenciesAffected, Map<Id, Set<Id>> agencyTerminatedChildAgencies, Boolean isChangeOwnershipToIATA, Map<Id, Account> accounts){

		Set<Id> output = new Set<Id>(agenciesAffected);

		for(Id ag: agenciesAffected){
			//check if agency has direct child that is terminated
			if(agencyTerminatedChildAgencies.containsKey(ag)){
				if(!isChangeOwnershipToIATA){
					output.addAll(agencyTerminatedChildAgencies.get(ag));
					output.addAll(addTerminatedDescendants(agencyTerminatedChildAgencies.get(ag), agencyTerminatedChildAgencies, isChangeOwnershipToIATA, accounts));
				}
				else{
					//in this situation we only need to add the Terminated SA's automatically
					for(Id childAgTerminated: agencyTerminatedChildAgencies.get(ag)){
						if(accounts.get(childAgTerminated).Location_Type__c == AMS_Utils.SA)
							output.add(childAgTerminated);
					}
				}
			}
		}

		return output;

	}

	public class AccountStruct{
		
	    public String parentIATACode;
	    public String locationType;

	    public AccountStruct(String parentIATACode, String locationType) {
	        this.parentIATACode = parentIATACode;
	        this.locationType = locationType;
	    }
	}

}