/**
 * This class is an helper to create a backup data record for Accounts, Owners and Hierarchies involved on OSCAR 
 * Agency Change.
 * Also this class contains the methods to rollback the data of Accounts, Owners and Hierarchies involved;
 * When a billable change code is generated during the OSCAR process if the rollback is made an internal case will 
 * be created.
 */

public without sharing class AMS_OscarChangesHelper {

	/**
	 * Method that processes the OSCARs to create backup data records, 
	 * for each record it will create backup records for Accounts on the Hierarchy,
	 * Roles and Hierarchy relations
	 * @param oscarIds This is a set of OSCARs Ids
	 * @return Nothing
	 */
	@future 
	public static void createSavepoint(Set<Id> oscarIds) {
		List<AMS_OSCAR__c> oscars = [SELECT Id, Account__c FROM AMS_OSCAR__c WHERE Id IN :oscarIds AND Account__c <> null];
		Map<Id,Id> mapAccountToOscar = new Map<Id,Id>();
		Map<Id,Id> mapAllAccountsHierToOscar = new Map<Id,Id>();
		
		for(AMS_OSCAR__c oscar : oscars) {
			mapAccountToOscar.put(oscar.Account__c, oscar.Id);
		}

		if(mapAccountToOscar.isEmpty()) {
			return;
		}

		Map<Id, List<AMS_Agencies_relationhip__c>> mapHierarchies = AMS_HierarchyHelper.getAccountsHierarchies(mapAccountToOscar.keySet());
		Map<Id, List<AMS_Agencies_relationhip__c>> mapFiltredHierarchies = new Map<Id, List<AMS_Agencies_relationhip__c>>();
		for(Id accountId : mapHierarchies.keySet()) {
			List<AMS_Agencies_relationhip__c> fullHierarchy = mapHierarchies.get(accountId);
			Id oscarId = mapAccountToOscar.get(accountId);

			List<AMS_Agencies_relationhip__c> relations = extractRelations(accountId, fullHierarchy);
			mapFiltredHierarchies.put(accountId, relations);

			for(AMS_Agencies_relationhip__c relation : fullHierarchy) {
				mapAllAccountsHierToOscar.put(relation.Child_Account__c, oscarId);
				mapAllAccountsHierToOscar.put(relation.Parent_Account__c, oscarId);
			}	
		}

		for(Id accountId : mapFiltredHierarchies.keySet()) {
			Id oscarId = mapAccountToOscar.get(accountId);
			List<AMS_Agencies_relationhip__c> relations = mapFiltredHierarchies.get(accountId);
			if(relations == null) {
				continue;
			}
			for(AMS_Agencies_relationhip__c rel : relations) {
				if(accountId != rel.Child_Account__c) {
					mapAccountToOscar.put(rel.Parent_Account__c, oscarId);
					mapAccountToOscar.put(rel.Child_Account__c, oscarId);
				}
			}
		}

		System.debug('mapAccountToOscar: ' + mapAccountToOscar);
		
		createAccountsSavepoint(mapAccountToOscar);
		createHierarchiesSavepoint(mapFiltredHierarchies, mapAccountToOscar);
		if(mapAllAccountsHierToOscar.isEmpty()) {
			createRolesSavepoint(mapAccountToOscar);
		} else {
			createRolesSavepoint(mapAllAccountsHierToOscar);
		}	
		
	}	

	/**
	 * Method that exctracts the a subhierarchy from a complete hierarchy
	 * @param accountId This is top account id of the subhierarchy to extract
	 * @param relations This is the complete hiearchy records
	 * @return List<AMS_Agencies_relationhip__c> This is the list of relations of the subhierarchy extracted
	 */
	private static List<AMS_Agencies_relationhip__c> extractRelations(Id accountId, List<AMS_Agencies_relationhip__c> relations) {
		Set<AMS_Agencies_relationhip__c> result = new Set<AMS_Agencies_relationhip__c>();
		Set<Id> accIds = new Set<Id>(); 
		for(AMS_Agencies_relationhip__c rel : relations) {
			if(rel.Child_Account__c == accountId) {
				result.add(rel);
			} else if(rel.Parent_Account__c == accountId) {
				accIds.add(rel.Child_Account__c);
			}
		}

		if(!accIds.isEmpty()) {
			for(Id accId : accIds) {
				result.addAll(extractRelations(accId, relations));
			}
		}

		return new List<AMS_Agencies_relationhip__c> (result);
	}

	/**
	 * Method that creates the backup records for accounts involved on the hierachy
	 * @param mapAccountToOscar This is a map where the key is the account to do a backup and the value is the OSCAR id related with
	 * @return Nothing
	 */
	public static void createAccountsSavepoint(Map<Id,Id> mapAccountToOscar) {
		Set<Id> accountIds = mapAccountToOscar.keySet();
		String queryStr = 'SELECT BillingAddress, ShippingAddress';
		//EM - BillingAddress and ShippingAddress accessible just from API30 - sfdc bug
		if (test.isRunningTest())	queryStr = 'SELECT';
		
		List<Schema.FieldSetMember> fields = SObjectType.Account.FieldSets.AMS_Oscar_Savepoint_fields.getFields();
		for(Schema.FieldSetMember f : fields) {
			queryStr += ', ' + f.getFieldPath();
		}

		queryStr += ' FROM Account WHERE Id IN :accountIds';
		if (test.isRunningTest())	queryStr = queryStr.replace('SELECT,','SELECT');

		List<Account> accounts = Database.query(queryStr);

		System.debug('accounts: ' + accounts);

		List<Technical_Logs__c> accountBackupsToInsert = new List<Technical_Logs__c>();		
		for(Account acc : accounts) {
			Map<String,Object> fieldsToSerialize = new Map<String,Object>(); 
			for(Schema.FieldSetMember f : fields) {
				String fieldAPI = f.getFieldPath();
				fieldsToSerialize.put(fieldAPI, acc.get(fieldAPI));
			}
			Id oscarId = mapAccountToOscar.get(acc.Id);
			Technical_Logs__c backupData = new Technical_Logs__c(
				Log__c= JSON.serialize(fieldsToSerialize), 
				Status__c= 'Account', 
				Record__c= oscarId,
				Operation__c= 'Rollback');
			accountBackupsToInsert.add(backupData);
		}

		system.debug('accountBackupsToInsert: ' + accountBackupsToInsert);

		if(!accountBackupsToInsert.isEmpty()) {
			insert accountBackupsToInsert;
		}
	}

	/**
	 * Method that creates the backup records for the relations of the hierarchy or subhierarchy selected
	 * @param mapFiltredHierarchies This is map of each account sub-hierarchy, the key is an account id and the values are a list of relations
	 * @param mapAccountToOscar This is a map where the key is the account to do a backup and the value is the OSCAR id related with
	 * @return Nothing	
	 */
	public static void createHierarchiesSavepoint(Map<Id, List<AMS_Agencies_relationhip__c>> mapFiltredHierarchies, Map<Id,Id> mapAccountToOscar) {
		List<Technical_Logs__c> hierarchyBackupsToInsert = new List<Technical_Logs__c>();		
		for(Id accountId : mapAccountToOscar.keySet()) {
			List<AMS_Agencies_relationhip__c> relations = mapFiltredHierarchies.get(accountId);			
			if(relations != null && !relations.isEmpty()) {
				List<HierarchyWrapper> hierachyW = new List<HierarchyWrapper>();
				for(AMS_Agencies_relationhip__c relation : relations) {
					HierarchyWrapper hw = new HierarchyWrapper(relation.Hierarchy__c, relation.Id, relation.Parent_Account__c, relation.Child_Account__c);
					hierachyW.add(hw);
				}
				Id oscarId = mapAccountToOscar.get(accountId);
				Technical_Logs__c backupData = new Technical_Logs__c(
					Log__c= JSON.serialize(hierachyW), 
					Status__c= 'Hierarchy', 
					Record__c= oscarId,
					Operation__c= 'Rollback');
				hierarchyBackupsToInsert.add(backupData);
			}
		}

		if(!hierarchyBackupsToInsert.isEmpty()) {
			insert hierarchyBackupsToInsert;
		}
	}

	/**
	 * Method that creates the backup records for roles of each account involved on the OSCAR (including child accounts)
	 * @param mapAccountToOscar This is a map where the key is the account to do a backup and the value is the OSCAR id related with
	 * @return Nothing	
	 */
	public static void createRolesSavepoint(Map<Id,Id> mapAccountToOscar) {
		List<String> fieldsStr = new List<String>();

		List<Schema.FieldSetMember> fields = SObjectType.AMS_Account_Role__c.FieldSets.AMS_Oscar_Savepoint_fields.getFields();
		for(Schema.FieldSetMember f : fields) {
			fieldsStr.add(f.getFieldPath());
		}

		Set<Id> accountIds = mapAccountToOscar.keySet();
		String queryStr = 'SELECT ' + String.join(fieldsStr, ', ') + ' FROM AMS_Account_Role__c WHERE Account__c IN :accountIds';
		List<AMS_Account_Role__c> roles = Database.query(queryStr);

		List<Technical_Logs__c> roleBackupsToInsert = new List<Technical_Logs__c>();	
		for(AMS_Account_Role__c role : roles) {
			Id oscarId = mapAccountToOscar.get(role.Account__c);
			Map<String,Object> fieldsToSerialize = new Map<String,Object>(); 
			for(Schema.FieldSetMember f : fields) {
				String fieldAPI = f.getFieldPath();
				fieldsToSerialize.put(fieldAPI, role.get(fieldAPI));
			}

			Technical_Logs__c backupData = new Technical_Logs__c(
				Log__c= JSON.serialize(fieldsToSerialize), 
				Status__c= 'Role', 
				Record__c= oscarId,
				Operation__c= 'Rollback');
			roleBackupsToInsert.add(backupData);
		}

		if(!roleBackupsToInsert.isEmpty()) {
			insert roleBackupsToInsert;
		}
	}

	public static void rollbackOscarChanges(Set<Id> oscarIds) {
		List<Technical_Logs__c> rbData = [SELECT Id, Log__c, Status__c, Record__c, Operation__c
										  FROM Technical_Logs__c	
										  WHERE Record__c IN :oscarIds AND Operation__c = 'Rollback']; 

		system.debug('oscarIds: ' + oscarIds);
		system.debug('rbData: ' + rbData);

		List<Account> accountsToRollback = new List<Account>();
		List<HierarchyWrapper> hierarchiesToRollback = new List<HierarchyWrapper>();
		List<AMS_Account_Role__c> rolesToRollback = new List<AMS_Account_Role__c>();

		for(Technical_Logs__c rb : rbData) {
			if(rb.Status__c == 'Account') {
				Account acc = (Account) JSON.deserialize(rb.Log__c, Account.class);
				accountsToRollback.add(acc);
			} else if(rb.Status__c == 'Hierarchy') {
				List<HierarchyWrapper> hw = (List<HierarchyWrapper>) JSON.deserialize(rb.Log__c, List<HierarchyWrapper>.class);
				hierarchiesToRollback.addAll(hw);
			} else if(rb.Status__c == 'Role') {
				AMS_Account_Role__c role = (AMS_Account_Role__c) JSON.deserialize(rb.Log__c, AMS_Account_Role__c.class);
				rolesToRollback.add(role);
			}
		}

		if(!accountsToRollback.isEmpty()) {
			update accountsToRollback;
		}
		if(!hierarchiesToRollback.isEmpty()) {
			rollbackHierarchies(hierarchiesToRollback);
		} else {
			List<AMS_OSCAR__c> oscars = [SELECT Account__c FROM AMS_OSCAR__c WHERE Id IN :oscarIds];
			Set<Id> accountIds = new Set<Id>();
			for(AMS_OSCAR__c oscar : oscars) {
				accountIds.add(oscar.Account__c);
			}
			rollbackSingleAccountHierarchy(accountIds);
		}
		if(!rolesToRollback.isEmpty()) {
			rollbackRoles(rolesToRollback);
		}

		createInternalCase(oscarIds);
	}

	public static void createInternalCase(Set<Id> oscarIds) {
		system.debug('Internal cases for: ' + oscarIds);
		Set<String> billableChangeCodes = new Set<String>();
		List<Case> casesToInsert = new List<Case>();

		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;	

		Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Cases (IDFS ISS)').getRecordTypeId();
		
		for(AMS_ChangeCodes__c changeCode : [SELECT Name, Change_Code__c FROM AMS_ChangeCodes__c WHERE Billable__c = true]) {
			if(changeCode.Name == changeCode.Change_Code__c || changeCode.Name.startsWith('AMS')) billableChangeCodes.add(changeCode.Change_Code__c);
		}

		List<Agency_Applied_Change_code__c> appChangeCodes = [SELECT Id, Change_Code__c, OSCAR__c 
															  FROM Agency_Applied_Change_code__c
															  WHERE Change_Code__c IN :billableChangeCodes AND OSCAR__c IN :oscarIds];

		if(!appChangeCodes.isEmpty()) {
			Set<Id> oscarsToProcess = new Set<Id>();
			for(Agency_Applied_Change_code__c apcc : appChangeCodes) {
				oscarsToProcess.add(apcc.OSCAR__c);
			}

			List<AMS_OSCAR__c> oscars = [SELECT Id, 
											(SELECT Id, Subject, AccountId, Region__c, BSPCountry__c, Type_of_customer__c, ContactId FROM Cases__r) 
										 FROM AMS_OSCAR__c 
										 WHERE Id IN :oscarsToProcess];

			for(AMS_OSCAR__c oscar : oscars) {
				Case pc = oscar.Cases__r[0];
				Case cse = new Case(ParentId= pc.Id, AccountId= pc.AccountId, Region__c= pc.Region__c, BSPCountry__c= pc.BSPCountry__c, 
					RecordTypeId= recordTypeId, Origin= 'Internal Case', CaseArea__c= 'Invoicing', Reason1__c= 'Credit Note request',
					Type_of_customer__c= pc.Type_of_customer__c, ContactId= pc.ContactId, Subject= pc.Subject, Description= Label.AMS_RollbackCase_Description);
				cse.setOptions(dmo);
				casesToInsert.add(cse);
			}
		}

		if(!casesToInsert.isEmpty()) {
			FutureProcessorControl.inFutureContext = true;
			insert casesToInsert;
		}
	}

	public static void rollbackSingleAccountHierarchy(Set<Id> accountIds) {
		List<AMS_Agencies_relationhip__c> relationsToDelete = [SELECT Id, Hierarchy__c FROM AMS_Agencies_relationhip__c WHERE Child_Account__c IN :accountIds];

		if(!relationsToDelete.isEmpty()) {
			delete relationsToDelete;
		}
	}

	public static void rollbackHierarchies(List<HierarchyWrapper> hiearchiesW) {
		Set<Id> accountIds = new Set<Id>();
		Set<Id> hierarchyIdsToCheck = new Set<Id>();
		Set<Id> oldHierarchies = new Set<Id>();
		Set<Id> newHierarchies = new Set<Id>();
		for(HierarchyWrapper hierarchy : hiearchiesW) {
			accountIds.add(hierarchy.parentId);
			accountIds.add(hierarchy.childId);	
			hierarchyIdsToCheck.add(hierarchy.hierachyId);	
			oldHierarchies.add(hierarchy.hierachyId);	
		}

		List<AMS_Agencies_relationhip__c> relationsToDelete = [SELECT Id, Hierarchy__c FROM AMS_Agencies_relationhip__c WHERE Child_Account__c IN :accountIds];
		for(AMS_Agencies_relationhip__c relation : relationsToDelete) {
			hierarchyIdsToCheck.add(relation.Hierarchy__c);
		}

		if(!relationsToDelete.isEmpty()) {
			delete relationsToDelete;
		}

		List<AMS_Agencies_Hierarchy__c> hierarchies = [SELECT Id, (SELECT Id FROM AMS_Agencies_relationships__r) 
													   FROM AMS_Agencies_Hierarchy__c
													   WHERE Id IN :hierarchyIdsToCheck];

		Map<Id,AMS_Agencies_Hierarchy__c> mapHierarchies = new Map<Id,AMS_Agencies_Hierarchy__c>();
		for(AMS_Agencies_Hierarchy__c hierarchy : hierarchies) {
			mapHierarchies.put(hierarchy.id, hierarchy);
		}

		List<AMS_Agencies_Hierarchy__c> hierarchiesToDelete = new List<AMS_Agencies_Hierarchy__c>();
		Map<Id,AMS_Agencies_Hierarchy__c> hierarchiesToInsert = new Map<Id,AMS_Agencies_Hierarchy__c>();
		for(Id hierarchyId : oldHierarchies) {
			if(mapHierarchies.get(hierarchyId) == null) {
				hierarchiesToInsert.put(hierarchyId, new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c= 'Hierarchy'));
			}
		}

		for(Id hierarchyId : newHierarchies) {
			AMS_Agencies_Hierarchy__c hierarchy = mapHierarchies.get(hierarchyId);
			if(hierarchy != null && hierarchy.AMS_Agencies_relationships__r != null && hierarchy.AMS_Agencies_relationships__r.isEmpty()) {
				hierarchiesToDelete.add(hierarchy);
			}
		}

		if(!hierarchiesToInsert.isEmpty()) {
			insert hierarchiesToInsert.values();
		}

		if(!hierarchiesToDelete.isEmpty()) {
			delete hierarchiesToDelete;
		}

		List<AMS_Agencies_relationhip__c> relationsToInsert = new List<AMS_Agencies_relationhip__c>();
		for(HierarchyWrapper hierarchyW : hiearchiesW) {
			AMS_Agencies_Hierarchy__c hierarchy = mapHierarchies.get(hierarchyW.hierachyId);
			if(hierarchy == null) {
				hierarchy = hierarchiesToInsert.get(hierarchyW.hierachyId);
			}
			AMS_Agencies_relationhip__c relation = new AMS_Agencies_relationhip__c(Hierarchy__c= hierarchy.Id, Child_Account__c= hierarchyW.childId, Parent_Account__c= hierarchyW.parentId);
			relationsToInsert.add(relation);
		}

		if(!relationsToInsert.isEmpty()) {
			insert relationsToInsert;
		}
	}

	public static void rollbackRoles(List<AMS_Account_Role__c> roles) {
		Set<Id> accountIds = new Set<Id>();
		for(AMS_Account_Role__c role : roles) {
			accountIds.add(role.Account__c);
		}

		Map<Id,AMS_Account_Role__c> newRolesMap = new Map<Id,AMS_Account_Role__c>([SELECT Id, Account__c FROM AMS_Account_Role__c WHERE Account__c IN :accountIds]);		
		List<AMS_Account_Role__c> rolesToUpsert = new List<AMS_Account_Role__c>();
		for(AMS_Account_Role__c role : roles) {
			AMS_Account_Role__c newRole = newRolesMap.get(role.Id);
			if(newRole == null) {
				role.Id = null;				
			} else {
				newRolesMap.remove(role.Id);
			}
			rolesToUpsert.add(role);
		}

		if(!newRolesMap.isEmpty()) {
			delete newRolesMap.values();
		}

		if(!rolesToUpsert.isEmpty()) {
			upsert rolesToUpsert;
		}		
	}

	/**
	 * This class is a wrapper for an hierarchy relation to be stored as backup
	 */
	public class HierarchyWrapper {
		public Id hierachyId {get;set;}
		public Id relationId {get;set;}
		public Id parentId {get;set;}
		public Id childId {get;set;}

		public HierarchyWrapper(Id hierachyId, Id relationId, Id parentId, Id childId) {
			this.hierachyId = hierachyId;
			this.relationId = relationId;
			this.parentId = parentId;
			this.childId = childId;
		}
	}

}