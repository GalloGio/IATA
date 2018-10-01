public without sharing class AMS_OSCAR_Savepoint implements Queueable {

	private static final Set<String> HIERARCHY_CHANGES = new Set<String> {'Location type', 'Minor Shareholding', 'Major Shareholding', 'Ownership to non-IATA Agent', 
																			'Ownership to IATA Agent'};
	private static final Set<String> BRANCH_CHANGES = new Set<String> {'Name', 'Legal status', 'Location type', 'Minor Shareholding', 'Major Shareholding', 
																			'Ownership to non-IATA Agent', 'Ownership to IATA Agent', 'VMFR'};
	private static final Set<String> OWNERS_CHANGES = new Set<String> {'Minor Shareholding', 'Major Shareholding', 'Ownership to non-IATA Agent', 
																			'Ownership to IATA Agent'};

	private List<AMS_OSCAR__c> oscars {get;set;}
	private Set<Id> oscarAccountsIds {get;set;}
	private Map<Id,Id> mapAccountIdToOscarId {get;set;}
	private Map<Id, List<AMS_Agencies_relationhip__c>> mapHierarchies {get;set;}
	private Set<Id> oscarsToSaveHierarchy {get;set;}
	private Set<Id> oscarsToSaveOwners {get;set;}


	public AMS_OSCAR_Savepoint(List<AMS_OSCAR__c> oscars) {
		this.oscars = oscars;
		this.mapAccountIdToOscarId = new Map<Id,Id>();
		this.oscarAccountsIds = new Set<Id>();
		this.oscarsToSaveHierarchy = new Set<Id>();
		this.oscarsToSaveOwners = new Set<Id>();
		init();
	}

	private void init() {
		for(AMS_OSCAR__c oscar : oscars) {
			mapAccountIdToOscarId.put(oscar.Account__c, oscar.Id);
			oscarAccountsIds.add(oscar.Account__c);
			List<String> typesOfChange = oscar.Type_of_change__c.split(';');
			for(String change : typesOfChange) {
				if(HIERARCHY_CHANGES.contains(change)) {
					oscarsToSaveHierarchy.add(oscar.Id);
				}
				if(OWNERS_CHANGES.contains(change)) {
					oscarsToSaveOwners.add(oscar.Id);
				}
			}
		}		
	}

	public void execute(QueueableContext context) {
		deletePreviousSavepoint();
		createSavepoint();
	}

	public void deletePreviousSavepoint() {
		Set<Id> oscarIds = new Set<Id>();
		for(AMS_OSCAR__c oscar : oscars) {
			oscarIds.add(oscar.Id);
		}

		List<Technical_Logs__c> svps = [SELECT Id FROM Technical_Logs__c WHERE Record__c IN :oscarIds AND Operation__c = 'Rollback'];
		if(!svps.isEmpty()) {
			delete svps;
		}
	} 

	public void createSavepoint() {
		system.debug('Savepoint: ' + oscars);
		searchHierarchies();
		List<Technical_Logs__c> recordsToInsert = new List<Technical_Logs__c>();
		recordsToInsert.addAll(createAccountsSavepoint());
		recordsToInsert.addAll(createHierarchySavepoint());
		recordsToInsert.addAll(createOwnersSavepoint());

		system.debug('Backup Data: ' + recordsToInsert);

		insert recordsToInsert;
	}	

	private void searchHierarchies() {
		mapHierarchies = AMS_HierarchyHelper.getAccountsHierarchies(oscarAccountsIds);
		for(Id accountId : mapHierarchies.keySet()) {
			Id oscarId = mapAccountIdToOscarId.get(accountId);
			List<AMS_Agencies_relationhip__c> relations = mapHierarchies.get(accountId);
			
			if(relations == null) {
				continue;
			}

			for(AMS_Agencies_relationhip__c relation : relations) {
				mapAccountIdToOscarId.put(relation.Parent_Account__c, oscarId);
				mapAccountIdToOscarId.put(relation.Child_Account__c, oscarId);
			}
		}
	}

	private List<Technical_Logs__c> createAccountsSavepoint() {
		List<Technical_Logs__c> result = new List<Technical_Logs__c>();
		Set<Id> accountIds = mapAccountIdToOscarId.keySet();

		List<Schema.FieldSetMember> fields = SObjectType.Account.FieldSets.AMS_Oscar_Savepoint_fields.getFields();
		List<String> fieldsStr = new List<String>();
		for(Schema.FieldSetMember f : fields) {
			fieldsStr.add(f.getFieldPath());
		}

		String queryStr =  'SELECT ' + String.join(fieldsStr, ', ') + ' FROM Account WHERE Id IN :accountIds';

		List<Account> accounts = Database.query(queryStr);

		for(Account acc : accounts) {
			Id oscarId = mapAccountIdToOscarId.get(acc.Id);
			result.add(generateSavepointRecord(acc, fields, 'Account', oscarId));
		}

		return result;
	}

	private List<Technical_Logs__c> createHierarchySavepoint() {
		List<Technical_Logs__c> result = new List<Technical_Logs__c>();
		List<Schema.FieldSetMember> fields = SObjectType.AMS_Agencies_relationhip__c.FieldSets.AMS_Oscar_Savepoint_fields.getFields();
		for(Id accountId : mapHierarchies.keySet()) {
			Id oscarId = mapAccountIdToOscarId.get(accountId);
			if(!oscarsToSaveHierarchy.contains(oscarId)) {
				continue;
			}
			List<AMS_Agencies_relationhip__c> relations =  mapHierarchies.get(accountId); 
			for(AMS_Agencies_relationhip__c relation : relations) {
				result.add(generateSavepointRecord(relation, fields, 'Relation', oscarId));
			}
		}

		return result;
	}

	private List<Technical_Logs__c> createOwnersSavepoint() {
		List<Technical_Logs__c> result = new List<Technical_Logs__c>();
		Set<Id> accountIds = mapAccountIdToOscarId.keySet();
		Id ownerRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		
		List<String> fieldsStr = new List<String>();

		List<Schema.FieldSetMember> fields = SObjectType.AMS_Account_Role__c.FieldSets.AMS_Oscar_Savepoint_fields.getFields();
		for(Schema.FieldSetMember f : fields) {
			fieldsStr.add(f.getFieldPath());
		}

		String queryStr = 'SELECT ' + String.join(fieldsStr, ', ') + ' FROM AMS_Account_Role__c WHERE Active__c = true AND RecordTypeId = :ownerRTId AND Account__c IN :accountIds';

		List<AMS_Account_Role__c> owners = Database.query(queryStr);
		Map<Id,Set<Id>> mapOscarToContactO = new Map<Id,Set<Id>>();
		Map<Id,Set<Id>> mapOscarToAccountO = new Map<Id,Set<Id>>();
		Map<Id,Id> mapIdToOscar = new Map<Id,Id>();
		for(AMS_Account_Role__c owner : owners) {
			Id oscarId = mapAccountIdToOscarId.get(owner.Account__c);
			if(!oscarsToSaveOwners.contains(oscarId)) {
				continue;
			}
			result.add(generateSavepointRecord(owner, fields, 'Owner', oscarId));
			if(owner.Contact__c != null) {
				addIdToMap(mapOscarToContactO, oscarId, owner.Contact__c);
				mapIdToOscar.put(owner.Contact__c, oscarId);
			} else if(owner.Owner_Account__c != null) {
				addIdToMap(mapOscarToAccountO, oscarId, owner.Owner_Account__c);
				mapIdToOscar.put(owner.Owner_Account__c, oscarId);
			}
		}

		Set<Id> contactOwIds = getAllValues(mapOscarToContactO);
		Set<Id> accountOwIds = getAllValues(mapOscarToAccountO); 

		if(!contactOwIds.isEmpty()) {
			fieldsStr = new List<String>();
			fields = SObjectType.Contact.FieldSets.AMS_Oscar_Savepoint_Owner_fields.getFields();
			for(Schema.FieldSetMember f : fields) {
				fieldsStr.add(f.getFieldPath());
			}

			queryStr = 'SELECT ' + String.join(fieldsStr, ', ') + ' FROM Contact WHERE Id IN :contactOwIds';

			List<Contact> contactsOW = (List<Contact>) Database.query(queryStr);
			for(Contact con : contactsOW) {
				result.add(generateSavepointRecord(con, fields, 'Contact Owner', mapIdToOscar.get(con.id)));
			}
		}

		if(!accountOwIds.isEmpty()) {
			fieldsStr = new List<String>();
			fields = SObjectType.Account.FieldSets.AMS_Oscar_Savepoint_Owner_fields.getFields();
			for(Schema.FieldSetMember f : fields) {
				fieldsStr.add(f.getFieldPath());
			}

			queryStr = 'SELECT ' + String.join(fieldsStr, ', ') + ' FROM Account WHERE Id IN :accountOwIds';

			List<Account> accoutOW = (List<Account>) Database.query(queryStr);
			for(Account acc : accoutOW) {
				result.add(generateSavepointRecord(acc, fields, 'Account Owner', mapIdToOscar.get(acc.id)));
			}
		}
		
		return result;
	}

	private void addIdToMap(Map<Id,Set<Id>> mapOscarToIds, Id oscarId, Id idToAdd) {
		Set<Id> ids = mapOscarToIds.get(oscarId);
		if(ids == null) {
			ids = new Set<Id>();
			mapOscarToIds.put(oscarId, ids);
		}
		ids.add(idToAdd);
	}

	private Set<Id> getAllValues(Map<Id,Set<Id>> mapOscarToIds) {
		Set<Id> res = new Set<Id>();
		for(Id oscarId : mapOscarToIds.keySet()) {
			for(Id recordId : mapOscarToIds.get(oscarId)) {
				res.add(recordId);
			}
		}

		return res;
	}

	private Technical_Logs__c generateSavepointRecord(SObject record, List<Schema.FieldSetMember> fields, String entity, Id oscarId) {
		Map<String,Object> fieldsToSerialize = new Map<String,Object>(); 
		for(Schema.FieldSetMember f : fields) {
			String fieldAPI = f.getFieldPath();
			fieldsToSerialize.put(fieldAPI, record.get(fieldAPI));
		}

		return new Technical_Logs__c(Log__c= JSON.serialize(fieldsToSerialize), Status__c= entity, Record__c= oscarId, Operation__c= 'Rollback');
	}

}
