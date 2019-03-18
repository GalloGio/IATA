public class HigherLogicIntegrationHelper {

	public static Boolean preventTrigger = false;
	
	public static String PUSH_MEMBERS = 'PUSH_MEMBERS';
	public static String PUSH_INTERNAL_MEMBERS = 'PUSH_INTERNAL_MEMBERS';
	public static String PUSH_EXISTING_MEMBERS = 'PUSH_EXISTING_MEMBERS';
	public static String DISABLE_EXISTING_MEMBERS = 'DISABLE_EXISTING_MEMBERS';
	public static String GRANT_ACCESS = 'GRANT_ACCESS';
	public static String REMOVE_ACCESS = 'REMOVE_ACCESS';
	
	private static Map<String,Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();

	private static String AGENCY_RECORD_TYPE_ID = recordTypesMap.get('IATA_Agency').getRecordTypeId();
	private static String BRANCH_RECORD_TYPE_ID = recordTypesMap.get('IATA_Airline_BR').getRecordTypeId();
	private static String HEADQUARTER_RECORD_TYPE_ID = recordTypesMap.get('IATA_Airline').getRecordTypeId();
	
    private static List<Account> fetchAccountRecords(Set<Id> accountIdSet){
    	
    	List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				Name,
				Website,
				Email__c,
				BillingCity,
				BillingState,
				BillingStreet,
				BillingCountry,
				BillingPostalCode
			 FROM 
			 	Account 
			 WHERE
			 	Id IN :accountIdSet
			]
		);
		
		return accountLst;

	}
	
	/**
	* Fetch the correct account Id considering 
	* the record type, parent accounts and airline type
	*
	* @param accountId: Id
	* @param recordTypeId: Id
	* @param airlineType: String
	* @param parentId: Id
	* @param parent2Id: Id
	*
	* @return Id: accountId
	*
	*/
	private static Id fetchAssociatedAccountId(Id accountId, Id recordTypeId, String airlineType, Id parentId, Id parent2Id){
					
		if(recordTypeId == BRANCH_RECORD_TYPE_ID && airlineType == 'Branch' && parentId != null){
			return parentId;
		}
		
		if(recordTypeId == AGENCY_RECORD_TYPE_ID && parentId != null && parent2Id == null){
			return parentId;
		}
		
		if(recordTypeId == AGENCY_RECORD_TYPE_ID && parentId != null && parent2Id != null){
			return parent2Id;
		}
		
		return accountId;
		
	}
	
	/*
	* Push all given accounts details into HigherLogic
	*
	* @param accountIdSet: Set<Id>
	* @param legacyContactMap: Map<Id, Id>
	*
	*/
	@future(callout=true)	
	public static void pushCompanyMembers(Set<Id> accountIdSet, Map<Id, Id> legacyContactMap){
		
		List<Account> accountLst = fetchAccountRecords(accountIdSet);
		
		if(!accountLst.isEmpty()){
			HigherLogicIntegrationWS.pushMembers(accountLst, legacyContactMap, null);
			HigherLogicIntegrationWS.flushWebServiceLogs();
		}
		
	}
	
	/**
	* Push all users detail into HigherLogic
	*
	* @param usersToPushLst: List<User>
	* @param activeUserMap: Map<Id, Boolean>
	*
	*/
	public static void pushPersonMembers(List<User> usersToPushLst, Map<Id, Boolean> activeUserMap){
		
		if(!usersToPushLst.isEmpty()){
			HigherLogicIntegrationWS.pushMembers(usersToPushLst, null, activeUserMap);
			HigherLogicIntegrationWS.flushWebServiceLogs();
		}
		
	}
	
	/**
	* Updates an existing relationship in Higher Logic
	*
	* @param contactIdSet 
	*
	*/
	@future(callout=true)
	public static void updateMembersRelationships(Set<Id> contactIdSet){
		
		List<User> newUsersLst = new List<User>(
			[SELECT 
				Id,
				ContactId,
				ContactKaviId__c,
				Contact.AccountId,
				Contact.Account.ParentId,
				Contact.Account.RecordTypeId,
				Contact.Account.Parent.ParentId,
				Contact.Account.Field_Head_Office__c
			 FROM
			 	User 
			 WHERE
			 	ContactId IN :contactIdSet
			 OR ContactKaviId__c IN :contactIdSet
			]
		);

		Map<Id, Id> contactIdMap = new Map<Id, Id>();

		for(User newUser : newUsersLst){
			Id accId = fetchAssociatedAccountId(newUser.Contact.AccountId, newUser.Contact.Account.RecordTypeId, newUser.Contact.Account.Field_Head_Office__c, newUser.Contact.Account.ParentId, newUser.Contact.Account.Parent.ParentId);
			contactIdMap.put(accId, newUser.ContactId != null ? newUser.ContactId : newUser.ContactKaviId__c);
		}
		
		Set<Id> accountIdSet = new Set<Id>(contactIdMap.keySet());
		
		List<Account> accountLst = fetchAccountRecords(accountIdSet);
		
		HigherLogicIntegrationWS.pushMembers(accountLst, contactIdMap, null);
		HigherLogicIntegrationWS.flushWebServiceLogs();
		
	}

	public static List<String> getQueryFields() {
		return new List<String>{
			'Id',
			'ContactKaviId__c',
			'Username',
			'Title',
			'FirstName',
			'LastName',
			'Phone',
			'Fax',
			'IsActive',
			'City',
			'MobilePhone',
			'State',
			'Country',
			'Street',
			'Email',
			'PostalCode',
			'ContactId',
			'Contact.Account.RecordTypeId',
			'Contact.Account.Field_Head_Office__c',
			'Contact.AccountId',
			'Contact.Account.Name',
			'Contact.Account.ParentId',
			'Contact.Account.Parent.ParentId'
		};
	}
	
	/**
	* Processes each User/Account pair 
	* and pushes their detail into HigherLogic
	*
	* @param operation: String
	* @param contactIdSet: Set<Id>
	* @param provAcctId: Id
	*
	*/
	@future(callout=true)
	public static void pushPersonCompanyMembers(String operation, Set<Id> contactIdSet, Id provAcctId){
	
		String whereClause = '';
		if (operation == PUSH_INTERNAL_MEMBERS){
			whereClause += ' ContactKaviId__c IN :contactIdSet ';
		}
		else {
			whereClause += ' ContactId IN :contactIdSet ';
		}

		String usersQuery = String.format('SELECT {0} FROM User WHERE {1}', 
			new List<String>{String.join(getQueryFields(), ', '),
			whereClause}
		);			
				
		List<User> userLst = (List<User>) Database.query(usersQuery);
		
		List<sObject> membersToPushLst = new List<sObject>();
		
		Map<Id, User> newUsersMap = new Map<Id, User>(userLst);

		List<Portal_Application_Right__c> portalAppRightsLst = new List<Portal_Application_Right__c>(
			[SELECT
				Id,
				Right__c,
				ContactId__c,
				Kavi_user__c
			 FROM
			 	Portal_Application_Right__c
			 WHERE
			 	 Contact__c IN :contactIdSet
			 AND Portal_Application__r.Name = 'Standards Setting Workspace'
			]
		);
		
		Map<Id, Portal_Application_Right__c> contactRightsMap = new Map<Id, Portal_Application_Right__c>();

		for (Portal_Application_Right__c par : portalAppRightsLst){
			contactRightsMap.put(par.ContactId__c, par);
		}
		
		Set<Id> newAccountsIds = new Set<Id>();
		Map<Id, Id> contactIdMap = new Map<Id, Id>();
		Map<Id, Boolean> activeUserMap = new Map<Id, Boolean>();
		
		for(User newUser : userLst){
			
			Id contactId = newUser.ContactId != null ? newUser.ContactId : newUser.ContactKaviId__c;

			if(!contactRightsMap.containsKey(contactId)){
				activeUserMap.put(newUser.Id, false);

				if(operation != DISABLE_EXISTING_MEMBERS) newUsersMap.remove(newUser.Id);
			}else{
				String access = contactRightsMap.get(contactId).Right__c;
				
				activeUserMap.put(newUser.Id, access == 'Access Granted');
			}

			if(operation == PUSH_EXISTING_MEMBERS|| operation == DISABLE_EXISTING_MEMBERS){
				continue;	
			}
			
			Id accId = provAcctId;
			
			if (operation == PUSH_MEMBERS){
				accId = fetchAssociatedAccountId(newUser.Contact.AccountId,newUser.Contact.Account.RecordTypeId, newUser.Contact.Account.Field_Head_Office__c, newUser.Contact.Account.ParentId, newUser.Contact.Account.Parent.ParentId);
			}

			newAccountsIds.add(accId);
			contactIdMap.put(accId, contactId);

		}
		
		if(newUsersMap.isEmpty()) return;

		if(operation == PUSH_EXISTING_MEMBERS || operation == DISABLE_EXISTING_MEMBERS){
			HigherLogicIntegrationWS.pushMembers(newUsersMap.values(), null, activeUserMap);
			HigherLogicIntegrationWS.flushWebServiceLogs();
			return;
		}
		
		List<Account> accountLst = fetchAccountRecords(newAccountsIds);
		
		membersToPushLst.addAll(accountLst);
		membersToPushLst.addAll(newUsersMap.values());
		
		HigherLogicIntegrationWS.pushMembers(membersToPushLst, contactIdMap, activeUserMap);
		
		Boolean hasChanged = false;
		for(User newUser : newUsersMap.values()){
			
			Id contactId = newUser.ContactId != null ? newUser.ContactId : newUser.ContactKaviId__c;
			
			if(contactRightsMap.containsKey(contactId)){
				contactRightsMap.get(contactId).Kavi_user__c = true;
				hasChanged = true;
			}
			
		}

		if(hasChanged) update contactRightsMap.values();	
		
		HigherLogicIntegrationWS.flushWebServiceLogs();
		
	}
	
	/**
	* Assigns or removes the Higher Logic Permission Set
	* to the users related to the given contacts
	*
	* @param contactIdSet: Set<Id>
	* @param action: String
	*
	*/
	@future(callout=true) 
	public static void assignHLPermissionSet(Set<Id> contactIdSet, String action){

		PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'HL_UsersAccess'][0];
		
		List<User> userLst = new List<User>(
			[SELECT 
				Id
			 FROM 
			 	User 
			 WHERE 
			 	ContactId IN :contactIdSet
			]
		);

		if(action == GRANT_ACCESS){
			
			List<PermissionSetAssignment> grantPSALst  = new List<PermissionSetAssignment>();
			
			for(User usr : userLst){
				grantPSALst.add(new PermissionSetAssignment(PermissionSetId = permSet.Id, AssigneeId = usr.Id));
			}
			
			if(!grantPSALst.isEmpty()){
				insert grantPSALst;
			}
			
		}
		else if(action == REMOVE_ACCESS){
		
			List<PermissionSetAssignment> removePSALst  = new List<PermissionSetAssignment>(
				[SELECT
					Id
				 FROM 
					PermissionSetAssignment
				 WHERE
				 	AssigneeId IN :userLst
				 AND
				 	PermissionSetId = :permSet.Id
				]
			);

			if(!removePSALst.isEmpty()){ 
				delete removePSALst;
			}
			
		}
		
	}

}