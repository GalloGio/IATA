public class AMS_OscarChangesHelper {

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

		createAccountsSavepoint(mapAccountToOscar);
		createHierarchiesSavepoint(mapFiltredHierarchies, mapAccountToOscar);
		createOwnersSavepoint(mapAllAccountsHierToOscar);
	}

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

	public static void createAccountsSavepoint(Map<Id,Id> mapAccountToOscar) {
		Set<Id> accountIds = mapAccountToOscar.keySet();
		String queryStr = 'SELECT Id, BillingAddress, ShippingAddress';

		List<Schema.FieldSetMember> fields = SObjectType.Account.FieldSets.AMS_Oscar_Savepoint_fields.getFields();
		for(Schema.FieldSetMember f : fields) {
			queryStr += ', ' + f.getFieldPath();
		}

		queryStr += ' FROM Account WHERE Id IN :accountIds';

		List<Account> accounts = Database.query(queryStr);
		List<AMS_Oscar_Change_History__c> recordsToInsert = new List<AMS_Oscar_Change_History__c>();
		for(Account acc : accounts) {
			Id oscarId = mapAccountToOscar.get(acc.Id);
			AccountWrapper aw = accountToWrapper(acc);
			recordsToInsert.add(new AMS_Oscar_Change_History__c(Oscar__c= oscarId, Data__c= JSON.serialize(aw), Type__c= 'Account'));
		}

		insert recordsToInsert;
	}

	public static void createHierarchiesSavepoint(Map<Id, List<AMS_Agencies_relationhip__c>> mapFiltredHierarchies, Map<Id,Id> mapAccountToOscar) {
		List<AMS_Oscar_Change_History__c> recordsToInsert = new List<AMS_Oscar_Change_History__c>();
		for(Id accountId : mapAccountToOscar.keySet()) {
			List<AMS_Agencies_relationhip__c> relations = mapFiltredHierarchies.get(accountId);
			if(relations != null && !relations.isEmpty()) {
				Id oscarId = mapAccountToOscar.get(accountId);
				HierarchyWrapper hw = new HierarchyWrapper(accountId, relations);
				recordsToInsert.add(new AMS_Oscar_Change_History__c(Oscar__c= oscarId, Data__c= JSON.serialize(hw), Type__c= 'Hierarchy'));
			}
		}

		if(!recordsToInsert.isEmpty()) {
			insert recordsToInsert;
		}
	}

	public static void createOwnersSavepoint(Map<Id,Id> mapAccountToOscar) {
		List<String> editableFields = new List<String>();
		Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('AMS_Account_Role__c').getDescribe().fields.getMap();
		for(Schema.SObjectField fieldRef : fields.values()) {
		    Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
		    if(fieldResult.isUpdateable()) {
		        editableFields.add(fieldResult.getname());
		    }
		}

		Set<Id> accountIds = mapAccountToOscar.keySet();
		String queryStr = 'SELECT Id, ' + String.join(editableFields, ', ') + ' FROM AMS_Account_Role__c WHERE Account__c IN :accountIds';

		List<AMS_Account_Role__c> roles = Database.query(queryStr);
		List<AMS_Oscar_Change_History__c> recordsToInsert = new List<AMS_Oscar_Change_History__c>();
		for(AMS_Account_Role__c role : roles) {
			Id oscarId = mapAccountToOscar.get(role.Account__c);
			AMS_Account_Role__c role2 = new AMS_Account_Role__c(Id= role.Id);
			for(String editableField : editableFields) {
				role2.put(editableField, role.get(editableField));
			}
			recordsToInsert.add(new AMS_Oscar_Change_History__c(Oscar__c= oscarId, Data__c= JSON.serialize(role2), Type__c= 'Owner')); 
		}

		if(!recordsToInsert.isEmpty()) {
			insert recordsToInsert;
		}
	}

	@future
	public static void rollbackOscarChanges(Set<Id> oscarIds) {
		List<AMS_Oscar_Change_History__c> records = [SELECT Id, Data__c, Type__c, Oscar__c
													 FROM AMS_Oscar_Change_History__c 
													 WHERE Oscar__c IN :oscarIds];

		if(records.isEmpty()) {
			return;
		}

		List<Account> accountsToRollback = new List<Account>();
		Map<Id, HierarchyWrapper> relationsToRollback = new Map<Id, HierarchyWrapper>();
		List<AMS_Account_Role__c> roles = new List<AMS_Account_Role__c>();

		for(AMS_Oscar_Change_History__c record : records) {
			system.debug('record.Data__c: ' + record.Data__c);
			if(record.Type__c == 'Account') {
				system.debug('record.Data__c: ' + record.Data__c);
				AccountWrapper aw = (AccountWrapper) JSON.deserialize(record.Data__c, AccountWrapper.class);
				accountsToRollback.add(wrapperToAccount(aw));
			} else if(record.Type__c == 'Hierarchy') {
				system.debug('record.Data__c: ' + record.Data__c);
				HierarchyWrapper relations = (HierarchyWrapper) JSON.deserialize(record.Data__c, HierarchyWrapper.class);
				relationsToRollback.put(record.Oscar__c, relations);
			} else if(record.Type__c == 'Owner') {
				system.debug('record.Data__c: ' + record.Data__c);
				AMS_Account_Role__c role = (AMS_Account_Role__c) JSON.deserialize(record.Data__c, AMS_Account_Role__c.class);
				roles.add(role);
			}
		}

		try {
			ISSP_SIS_AccountHandler.BLOCK_EXECUTION = true;
			rollbackOwners(roles);
			rollbackHierarchies(relationsToRollback);
			rollbackAccounts(accountsToRollback);
			createInternalCase(oscarIds);	
		} catch(Exception e) {
			String oscarIdsStr = '' + oscarIds;
			insert new Technical_Logs__c(Operation__c= 'Oscar rollback', Log__c= e.getStackTraceString(), Record__c= oscarIdsStr.substring(0, 254));
		}	
	}

	public static void createInternalCase(Set<Id> oscarIds) {
		Set<String> billableChangeCodes = new Set<String>();
		List<Case> casesToInsert = new List<Case>();

		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;	

		Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Cases (IDFS ISS)').getRecordTypeId();
		
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
				Case cse = new Case();
				Case parentCase = oscar.Cases__r[0];
				cse.ParentId = parentCase.Id;
				cse.AccountId = parentCase.AccountId;
				cse.Region__c = parentCase.Region__c;
				cse.BSPCountry__c = parentCase.BSPCountry__c;
				cse.RecordTypeId = recordTypeId;
				cse.Origin = 'Internal Case';
				cse.CaseArea__c = 'Invoicing';
				cse.Reason1__c = 'Credit Note request';
				cse.Type_of_customer__c = parentCase.Type_of_customer__c;
				cse.ContactId = parentCase.ContactId;
				cse.Subject = parentCase.Subject;
				cse.setOptions(dmo);
				casesToInsert.add(cse);
			}
		}

		if(!casesToInsert.isEmpty()) {
			FutureProcessorControl.inFutureContext = true;
			insert casesToInsert;
		}
	}

	public static void rollbackAccounts(List<Account> accounts) {
		update accounts;
	}

	public static void rollbackHierarchies(Map<Id, HierarchyWrapper> relationsToRollback) {
		Set<Id> accountIds = new Set<Id>();
		Set<Id> hierarchyIdsToCheck = new Set<Id>();
		Set<Id> oldHierarchies = new Set<Id>();
		Set<Id> newHierarchies = new Set<Id>();

		for(HierarchyWrapper hw : relationsToRollback.values()) {
			accountIds.add(hw.accountId);
			for(AMS_Agencies_relationhip__c relation : hw.relations) {
				accountIds.add(relation.Child_Account__c);
				hierarchyIdsToCheck.add(relation.Hierarchy__c);
				oldHierarchies.add(relation.Hierarchy__c);
			}
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
		for(HierarchyWrapper hw : relationsToRollback.values()) {
			if(hw.relations == null || hw.relations.isEmpty()) {
				continue;
			}
			Id hierarchyId = hw.relations[0].Hierarchy__c;
			AMS_Agencies_Hierarchy__c hierarchy = mapHierarchies.get(hierarchyId);
			if(hierarchy == null) {
				hierarchy = hierarchiesToInsert.get(hierarchyId);
			}
			
			for(AMS_Agencies_relationhip__c relation : hw.relations) {
				relation.Hierarchy__c = hierarchy.Id;
				relation.Id = null;
			}
			 

			relationsToInsert.addAll(hw.relations);
		}

		if(!relationsToInsert.isEmpty()) {
			insert relationsToInsert;
		}

	}

	public static void rollbackOwners(List<AMS_Account_Role__c> roles) {
		if(roles.isEmpty()) {
			return;
		}

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

	public class HierarchyWrapper {
		public List<AMS_Agencies_relationhip__c> relations {get;set;}
		public Id accountId {get;set;}

		public HierarchyWrapper(Id accountId, List<AMS_Agencies_relationhip__c> relations) {
			this.accountId = accountId;
			this.relations = relations;
		}
	}

	public static AccountWrapper accountToWrapper(Account acc) {
		AccountWrapper acw = new AccountWrapper();
		acw.accountId = acc.Id;
		acw.topParent = acc.Top_Parent__c;
		acw.parentId = acc.ParentId;
		acw.legalName = acc.Legal_name__c;
		acw.tradeName = acc.TradeName__c;
		acw.accountName = acc.Name;
		acw.iataCode = acc.IATACode__c;
		acw.companyType = acc.Company_Type__c;
		acw.cassNumber = acc.CASS_Number__c;
		acw.shortName = acc.Short_Name__c;
		acw.locationType = acc.Location_Type__c;
		acw.locationClass = acc.Location_Class__c;
		acw.licenseNumber = acc.License_Number__c;
		acw.vat1 = acc.VAT_Number__c;
		acw.vat2 = acc.VAT_Number_2__c;
		acw.gds = acc.GDS__c;
		acw.isoCountry = acc.IATA_ISO_Country__c;
		acw.billingStreet = acc.BillingStreet;
		acw.billingCity = acc.BillingCity;
		acw.billingPostalCode = acc.BillingPostalCode;
		acw.billingState = acc.BillingState;
		acw.billingCountry = acc.BillingCountry;
		acw.shippingStreet = acc.ShippingStreet;
		acw.shippingCity = acc.ShippingCity;
		acw.shippingPostalCode = acc.ShippingPostalCode;
		acw.shippingState = acc.ShippingState;
		acw.shippingCountry = acc.ShippingCountry;
		acw.isoBillingState = acc.IATA_ISO_Billing_State__c;
		acw.isoShippingCountry = acc.IATA_ISO_Shipping_Country__c;
		acw.isoShippingState = acc.IATA_ISO_Shipping_State__c;
		acw.email = acc.Email__c;
		acw.website = acc.Website;
		acw.phone = acc.Phone;
		acw.inAirport = acc.In_a_Airport__c;
		acw.fax = acc.Fax;
		acw.mobile = acc.Mobile__c;
		acw.abbrName = acc.Abbreviated_name__c;
		acw.remittanceFrequency = acc.Remittance_frequency__c;
		acw.linkAgentName = acc.Link_agent_name__c;

		return acw;
	}

	public static Account wrapperToAccount(AccountWrapper acw) {
		Account acc = new Account();
		acc.Id = acw.accountId;
		acc.Top_Parent__c = acw.topParent;
		acc.ParentId = acw.parentId;
		acc.Legal_name__c = acw.legalName;
		acc.TradeName__c = acw.tradeName;
		acc.Name = acw.accountName;
		acc.IATACode__c = acw.iataCode;
		acc.Company_Type__c = acw.companyType;
		acc.CASS_Number__c = acw.cassNumber;
		acc.Short_Name__c = acw.shortName;
		acc.Location_Type__c = acw.locationType;
		acc.Location_Class__c = acw.locationClass;
		acc.License_Number__c = acw.licenseNumber;
		acc.VAT_Number__c = acw.vat1;
		acc.VAT_Number_2__c = acw.vat2;
		acc.GDS__c = acw.gds;
		acc.IATA_ISO_Country__c = acw.isoCountry;
		acc.BillingStreet = acw.billingStreet;
		acc.BillingCity = acw.billingCity;
		acc.BillingPostalCode = acw.billingPostalCode;
		acc.BillingState = acw.billingState;
		acc.BillingCountry = acw.billingCountry;
		acc.ShippingStreet = acw.shippingStreet;
		acc.ShippingCity = acw.shippingCity;
		acc.ShippingPostalCode = acw.shippingPostalCode;
		acc.ShippingState = acw.shippingState;
		acc.ShippingCountry = acw.shippingCountry;
		acc.IATA_ISO_Billing_State__c = acw.isoBillingState;
		acc.IATA_ISO_Shipping_Country__c = acw.isoShippingCountry;
		acc.IATA_ISO_Shipping_State__c = acw.isoShippingState;
		acc.Email__c = acw.email;
		acc.Website = acw.website;
		acc.Phone = acw.phone;
		acc.In_a_Airport__c = acw.inAirport;
		acc.Fax = acw.fax;
		acc.Mobile__c = acw.mobile;
		acc.Abbreviated_name__c = acw.abbrName;
		acc.Remittance_frequency__c = acw.remittanceFrequency;
		acc.Link_agent_name__c = acw.linkAgentName;

		return acc;
	}

	public class AccountWrapper {
		public Id accountId {get;set;}
		public Id topParent {get;set;}
		public Id parentId {get;set;}
		public String legalName {get;set;}
		public String tradeName {get;set;}
		public String accountName {get;set;}
		public String iataCode {get;set;}
		public String companyType {get;set;}
		public String cassNumber {get;set;}
		public String shortName {get;set;}
		public String locationType {get;set;}
		public String locationClass {get;set;}
		public String licenseNumber {get;set;}
		public String vat1 {get;set;}
		public String vat2 {get;set;}
		public String gds {get;set;}
		public Id isoCountry {get;set;}
		public String billingStreet {get;set;}
		public String billingCity {get;set;}
		public String billingState {get;set;}
		public String billingPostalCode {get;set;}
		public String billingCountry {get;set;}
		public String shippingStreet {get;set;}
		public String shippingCity {get;set;}
		public String shippingState {get;set;}
		public String shippingPostalCode {get;set;}
		public String shippingCountry {get;set;}
		public Id isoBillingState {get;set;}
		public Id isoShippingCountry {get;set;}
		public Id isoShippingState {get;set;}
		public String email {get;set;}
		public String website {get;set;}
		public String phone {get;set;}
		public Boolean inAirport {get;set;}
		public String fax {get;set;}
		public String mobile {get;set;}
		public String abbrName {get;set;}
		public String remittanceFrequency {get;set;}
		public Id linkAgentName {get;set;}

		public AccountWrapper() {}
	}
}