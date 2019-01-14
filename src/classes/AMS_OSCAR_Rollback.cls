public without sharing class AMS_OSCAR_Rollback {

	private static final Set<String> HIERARCHY_CHANGES = new Set<String> {'Location type', 'Minor Shareholding', 'Major Shareholding', 'Ownership to non-IATA Agent', 
																			'Ownership to IATA Agent'};
	private static final Set<String> BRANCH_CHANGES = new Set<String> {'Name', 'Legal status', 'Location type', 'Minor Shareholding', 'Major Shareholding', 
																			'Ownership to non-IATA Agent', 'Ownership to IATA Agent', 'VMFR'};
	private static final Set<String> OWNERS_CHANGES = new Set<String> {'Minor Shareholding', 'Major Shareholding', 'Ownership to non-IATA Agent', 
																			'Ownership to IATA Agent'};

	private Map<Id,RollbackConfig> mapIdToOscar {get; set;}
	private Map<Id,List<Account>> mapOscarToAccounts {get;set;}
	private Map<Id,Account> mapAccounts {get;set;}
	private Map<Id,List<AMS_Agencies_relationhip__c>> mapOscarToRelations {get;set;}
	private Map<Id,List<AMS_Account_Role__c>> mapOscarToOwners {get;set;}
	private List<Account> accountOwners {get;set;}
	private List<Contact> contactOwners {get;set;}
	private Boolean hasData {get;set;}

	public AMS_OSCAR_Rollback(List<AMS_OSCAR__c> oscars) {
		this.mapIdToOscar = new Map<Id,RollbackConfig>();
		this.mapOscarToAccounts = new Map<Id,List<Account>>();
		this.mapOscarToRelations = new Map<Id,List<AMS_Agencies_relationhip__c>>();
		this.mapOscarToOwners = new Map<Id,List<AMS_Account_Role__c>>();
		this.mapAccounts = new Map<Id,Account>();
		this.accountOwners = new List<Account>();
		this.contactOwners = new List<Contact>();
		init(oscars);
		retriveBackupData();
	} 

	private void init(List<AMS_OSCAR__c> oscars) {
		for(AMS_OSCAR__c oscar : oscars) {
			if(String.isNotBlank(oscar.Type_of_change__c)) {
				List<String> typesOfChange = oscar.Type_of_change__c.split(';');
				Boolean needHierarchyCheck = false;
				Boolean needBranchCheck = false;
				Boolean needOwnersCheck = false;
				for(String change : typesOfChange) {
					needHierarchyCheck |= HIERARCHY_CHANGES.contains(change);
					needBranchCheck |= BRANCH_CHANGES.contains(change);
					needOwnersCheck |= OWNERS_CHANGES.contains(change);
				}

				mapIdToOscar.put(oscar.Id, new RollbackConfig(oscar, needHierarchyCheck, needBranchCheck, needOwnersCheck));
			}
		}
	}

	private void retriveBackupData() {
		List<Technical_Logs__c> dataRecords = [SELECT Log__c, Status__c, Record__c FROM Technical_Logs__c WHERE Record__c IN :mapIdToOscar.keySet() AND Operation__c = 'Rollback'];
		this.hasData = !dataRecords.isEmpty();
		for(Technical_Logs__c data : dataRecords) {
			Id oscarId = data.Record__c;
			if(data.Status__c == 'Account') {
				Account acc = (Account) JSON.deserialize(data.Log__c, Account.class);
				List<Account> accs = mapOscarToAccounts.get(oscarId);
				if(accs == null) {
					accs = new List<Account>();
					mapOscarToAccounts.put(oscarId, accs);
				}
				accs.add(acc);
				mapAccounts.put(acc.Id, acc);
			} else if(data.Status__c == 'Relation') {
				AMS_Agencies_relationhip__c relation = (AMS_Agencies_relationhip__c) JSON.deserialize(data.Log__c, AMS_Agencies_relationhip__c.class);
				List<AMS_Agencies_relationhip__c> rels = mapOscarToRelations.get(oscarId);
				if(rels == null) {
					rels = new List<AMS_Agencies_relationhip__c>();
					mapOscarToRelations.put(oscarId, rels);
				}
				rels.add(relation);
			} else if(data.Status__c == 'Owner') {
				AMS_Account_Role__c own = (AMS_Account_Role__c) JSON.deserialize(data.Log__c, AMS_Account_Role__c.class);
				List<AMS_Account_Role__c> owns = mapOscarToOwners.get(oscarId);
				if(owns == null) {
					owns = new List<AMS_Account_Role__c>();
					mapOscarToOwners.put(oscarId, owns);
				}
				owns.add(own);
			} else if(data.Status__c == 'Contact Owner') {
				contactOwners.add( (Contact) JSON.deserialize(data.Log__c, Contact.class));
			} else if(data.Status__c == 'Account Owner') {
				accountOwners.add( (Account) JSON.deserialize(data.Log__c, Account.class));
			} else {
				throw new AMS_ApplicationException('Invalid Entity.');
			}
		}
	}

	public void rollbackOSCAR() {
		if(!this.hasData) {
			system.debug('No backup data retrieved');
			return;
		}


		List<Account> accountsToUpdate = new List<Account>();
		List<HierarchyWrapper> hierarchyToUpdate = new List<HierarchyWrapper>();
		List<AMS_Account_Role__c> ownersToUpdate = new List<AMS_Account_Role__c>();

		List<AMS_Process_Detail__c> details = [SELECT Account__c, OSCAR__c FROM AMS_Process_Detail__c WHERE OSCAR__c IN :mapIdToOscar.keySet()];
		Map<Id,Set<Id>> mapOscarToDetailAcc = new Map<Id,Set<Id>>();
		for(AMS_Process_Detail__c detail : details) {
			Set<Id> accIds = mapOscarToDetailAcc.get(detail.OSCAR__c);
			if(accIds == null) {
				accIds = new Set<Id>();
				mapOscarToDetailAcc.put(detail.OSCAR__c, accIds);
			}
			accIds.add(detail.OSCAR__c);
		}

		for(RollbackConfig config : mapIdToOscar.values()) {
			Set<Id> accountIds = new Set<Id> {config.oscar.Account__c};
			Set<Id> detailAccountIds = mapOscarToDetailAcc.get(config.oscar.Id);
			if(detailAccountIds != null && !detailAccountIds.isEmpty()) {
				accountIds.addAll(detailAccountIds);
			}

			accountsToUpdate.addAll(rollbackAccounts(accountIds, config.oscar.Id, config.needHierarchyCheck || config.needBranchCheck));

			if(config.needHierarchyCheck) {
				HierarchyWrapper hw = retrieveHierarchy(config.oscar.Id);
				if(hw != null) {
					hierarchyToUpdate.add(hw);
				}				
			}

			if(config.needOwnersCheck) {
				List<AMS_Account_Role__c> ows = mapOscarToOwners.get(config.oscar.Id);
				if(ows != null) {
					ownersToUpdate.addAll(ows);
				}				
			}
		}

		if(!accountsToUpdate.isEmpty()) {
			AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = true;
			accountsToUpdate.addAll(accountOwners);
			update accountsToUpdate;
		}

		if(!hierarchyToUpdate.isEmpty()) {
			rollbackHierarchy(hierarchyToUpdate);
		}

		if(!ownersToUpdate.isEmpty()) {
			rollbackOwners(ownersToUpdate);
		}

		if(!contactOwners.isEmpty()) {
			update contactOwners;
		}

		createInternalCase(mapIdToOscar.keySet());
	}

	private void createInternalCase(Set<Id> oscarIds) {
		system.debug('Internal cases for: ' + oscarIds);
		Set<String> billableChangeCodes = new Set<String>();
		List<Case> casesToInsert = new List<Case>();

		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;	

		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');
		
		for(AMS_ChangeCodes__c changeCode : [SELECT Change_Code__c FROM AMS_ChangeCodes__c where Billable__c = true]) {
			billableChangeCodes.add(changeCode.Change_Code__c);
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
			insert casesToInsert;
		}
	}

	private List<Account> rollbackAccounts(Set<Id> oscarAccountIds, Id oscarId, Boolean allHierarchy) {
		List<Account> res = new List<Account>();

		if(allHierarchy) {
			res.addAll(mapOscarToAccounts.get(oscarId));			
		} else {
			for(Id accountId : oscarAccountIds) {
				res.add(mapAccounts.get(accountId));
			}			
		}

		return res;
	}

	private HierarchyWrapper retrieveHierarchy(Id oscarId) {
		HierarchyWrapper res;
		List<AMS_Agencies_relationhip__c> relations = mapOscarToRelations.get(oscarId);
		
		if(relations != null) {
			res = new HierarchyWrapper(relations[0].Hierarchy__c, null);
			for(AMS_Agencies_relationhip__c relation : relations) {
				res.relations.add(relation);
			}
		} else {
			res = new HierarchyWrapper(null, mapOscarToAccounts.get(oscarId)[0].Id);
		}

		return res;
	}

	private void rollbackHierarchy(List<HierarchyWrapper> hierarchies) {
		System.debug('Starting Hierarchy Rollback...');
		Set<Id> oldHierarchyIds = new Set<Id>();
		Set<Id> accountIds = new Set<Id>();
		List<AMS_Agencies_Hierarchy__c> hierarchiesToCreate = new List<AMS_Agencies_Hierarchy__c>();

		for(HierarchyWrapper hierarchyW : hierarchies) {
			System.debug('Hierarchy Wrapper: ' + hierarchyW);
			if(hierarchyW.isEmptyHierarchy) {
				accountIds.add(hierarchyW.accountId);	
			} else {			
			oldHierarchyIds.add(hierarchyW.orginalHierarchyId);
			hierarchiesToCreate.add(hierarchyW.hierarchy);
			for(AMS_Agencies_relationhip__c relation : hierarchyW.relations) {
				accountIds.add(relation.Parent_Account__c);
				accountIds.add(relation.Child_Account__c);
			}
		}
		}

		List<AMS_Agencies_Hierarchy__c> hierarchiesToDelete = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Id IN: oldHierarchyIds];
		if(!hierarchiesToDelete.isEmpty()) {
			delete hierarchiesToDelete;
		}

		List<AMS_Agencies_relationhip__c> relationsToDelete = [SELECT Id, Hierarchy__c FROM AMS_Agencies_relationhip__c WHERE Parent_Account__c IN :accountIds OR Child_Account__c IN :accountIds];
		Set<Id> hierarchiesToCheck = new Set<Id>();
		for(AMS_Agencies_relationhip__c relation : relationsToDelete) {
			hierarchiesToCheck.add(relation.Hierarchy__c);
		}

		if(!relationsToDelete.isEmpty()) {
			delete relationsToDelete;
		}

		hierarchiesToDelete = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Id IN :hierarchiesToCheck AND Id NOT IN (SELECT Hierarchy__c FROM AMS_Agencies_relationhip__c)];
		if(!hierarchiesToDelete.isEmpty()) {//Remove empty hierarchies
			delete hierarchiesToDelete;
		}

		if(!hierarchiesToCreate.isEmpty()) {
			insert hierarchiesToCreate;
		}
		
		List<AMS_Agencies_relationhip__c> relationsToInsert = new List<AMS_Agencies_relationhip__c>();
		for(HierarchyWrapper hierarchyW : hierarchies) {
			for(AMS_Agencies_relationhip__c relation : hierarchyW.relations) {
				relation.Id = null;
				relation.Hierarchy__c = hierarchyW.hierarchy.Id;
				relationsToInsert.add(relation);
			}
		}

		if(!relationsToInsert.isEmpty()) {
			insert relationsToInsert;
		}

	}

	private void rollbackOwners(List<AMS_Account_Role__c> owners) {
		Map<Id,Map<Id,AMS_Account_Role__c>> mapAccountToOwners = new Map<Id,Map<Id,AMS_Account_Role__c>>();
		for(AMS_Account_Role__c owner : owners) {
			Map<Id,AMS_Account_Role__c> mapIdToOwner = mapAccountToOwners.get(owner.Account__c);
			if(mapIdToOwner == null) {
				mapIdToOwner = new Map<Id,AMS_Account_Role__c> ();
				mapAccountToOwners.put(owner.Account__c, mapIdToOwner);
			}
			mapIdToOwner.put(owner.Id, owner);
		}

		Id ownerRTId = AMS_Utils.AccountRoleOwnershipRT;
		List<AMS_Account_Role__c> ownersToCheck = [SELECT Id, Account__c FROM AMS_Account_Role__c 
												   WHERE Account__c IN :mapAccountToOwners.keySet() AND RecordTypeId = :ownerRTId AND Active__c = true];

		List<AMS_Account_Role__c> ownersToDelete = new List<AMS_Account_Role__c>();
		for(AMS_Account_Role__c owner : ownersToCheck) {
			AMS_Account_Role__c ownerToCheck = mapAccountToOwners.get(owner.Account__c).get(owner.Id);
			if(ownerToCheck == null) {
				ownersToDelete.add(owner);
			}
		}

		if(!ownersToDelete.isEmpty()) {
			delete ownersToDelete;
		}

		List<AMS_Account_Role__c> ownersToUpdate = new List<AMS_Account_Role__c>();
		for(Map<Id,AMS_Account_Role__c> mapOwners : mapAccountToOwners.values()) {
			for(AMS_Account_Role__c owner : mapOwners.values()) {
				ownersToUpdate.add(owner);
			}			
		}

		update ownersToUpdate;
	}


	public class RollbackConfig {
		public Boolean needHierarchyCheck {get;set;}
		public Boolean needBranchCheck {get;set;}
		public Boolean needOwnersCheck {get;set;}
		public AMS_OSCAR__c oscar {get;set;}

		public RollbackConfig(AMS_OSCAR__c oscar, Boolean needHierarchyCheck, Boolean needBranchCheck, Boolean needOwnersCheck) {
			this.oscar = oscar;
			this.needHierarchyCheck = needHierarchyCheck;
			this.needBranchCheck = needBranchCheck;
			this.needOwnersCheck = needOwnersCheck;
		}
	}

	public class HierarchyWrapper {
		public AMS_Agencies_Hierarchy__c hierarchy {get;set;}
		public List<AMS_Agencies_relationhip__c> relations {get;set;}
		public Id orginalHierarchyId {get;set;}
		public Id accountId {get;set;}
		public Boolean isEmptyHierarchy {get;set;}

		public HierarchyWrapper(Id orginalHierarchyId, Id accountId) {
			this.orginalHierarchyId = orginalHierarchyId;
			this.hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c= 'Hierarchy');
			this.relations = new List<AMS_Agencies_relationhip__c>();
			this.accountId = accountId;
			this.isEmptyHierarchy = accountId <> null;
		}
	}

}