public without sharing class CW_PrivateAreaController {
	@AuraEnabled(cacheable=true)
	public static String getUserFacilities(String fromAccId) {
		
		User u = [Select AccountId, ContactId from User WHERE Id = :UserInfo.getUserId()];
		String accId = fromAccId != null ? fromAccId : u.AccountId;
		Account receivedAccount = [SELECT id, Name, Global_ID__c, Global_Ultimate_Account_Global_ID__c FROM Account WHERE Id = :accId];
		String globalId = receivedAccount.Global_ID__c;
		String globalUltimateId = receivedAccount.Global_Ultimate_Account_Global_ID__c;
		List<Account> acc = [SELECT id, Name FROM Account WHERE Global_ID__c != null AND Global_ID__c = :globalUltimateId];

		List<Account_Role_Relationship__c> userOpsHierarchy = [SELECT Relationship_Name__c, Ops_Hierarchy_Group__c, To__c, To__r.Account__c FROM Account_Role_Relationship__c WHERE From__r.Account__c = :accId];
		List<Account_Role_Relationship__c> completeOpsHierarchy = retrieveCompleteHierarchy(userOpsHierarchy);
		String defaultOpsHierarchyName = acc.isEmpty() ? !userOpsHierarchy.isEmpty() ? userOpsHierarchy[0].Ops_Hierarchy_Group__c : receivedAccount.Name: acc[0].Name;

		Map<Id, Account> allHierarchy = queryAllHierarchy(accId, completeOpsHierarchy, globalId, globalUltimateId);

		List<ICG_Account_Role_Detail__c> stations = queryStations(u, allHierarchy);

		Set<Id> accRolesIds = generateAccRoleIds(allHierarchy);
		Map<Id, Account_Role__c> accRolesList = new Map<Id, Account_Role__c>([SELECT id, Account__c, Account__r.Name, (SELECT id, From__c, To__c, To__r.Account__c, Relationship_Name__c FROM From_Relationships__r), (SELECT id, Status__c, isApproved__c, isPendingApproval__c, createdDate FROM ICG_Contact_Role_Details__r WHERE Account_Contact_Role__r.Contact__c = :u.ContactId AND ICG_Role__c = 'Company Admin') FROM Account_Role__c WHERE Id IN :accRolesIds]);

		Map<Id, String> mapAccRoleOpsHierarchy = generateMapAccRoleOpsHierarchy(accRolesList);
		mapAccRoleOpsHierarchy = mapAccountRolesOpsHierarchy(accRolesList, mapAccRoleOpsHierarchy, defaultOpsHierarchyName);
		Map<String, GroupDataWrapper> mapGroup = generateMapGroup(accRolesList, mapAccRoleOpsHierarchy);
		Map<Id, List<ICG_Account_Role_Detail__c>> mapAccountIdStationsList = generateMapAccountIdStationsList(stations);

		Map<String, OpsHierarchyDataWrapper> stationsByOpsHierarchy = generateStationsByOpsHierarchy(allHierarchy, mapAccRoleOpsHierarchy, mapGroup, mapAccountIdStationsList, defaultOpsHierarchyName);
		return JSON.serialize(stationsByOpsHierarchy);
	}

	private static Map<String, GroupDataWrapper> generateMapGroup(Map<Id, Account_Role__c> accRolesList, Map<Id, String> mapAccRoleOpsHierarchy){
		Map<String, GroupDataWrapper> mapGroup = new Map<String, GroupDataWrapper>();
		for (Account_Role__c accrol : accRolesList.values()) {
			for (ICG_Contact_Role_Detail__c crd : accrol.ICG_Contact_Role_Details__r) {
				String groupName = mapAccRoleOpsHierarchy.get(accrol.Id);
				if (crd.isApproved__c) {
					mapGroup.put(groupName, new GroupDataWrapper(crd.Id, crd.CreatedDate, crd.Status__c, true, false));
				} else if (mapGroup.get(groupName) == null && crd.isPendingApproval__c) {
					mapGroup.put(groupName, new GroupDataWrapper(crd.Id, crd.CreatedDate, crd.Status__c, false, true));
				}
			}
		}

		return mapGroup;
	}

	private static Map<Id, String> mapAccountRolesOpsHierarchy(
		Map<Id, Account_Role__c> accRolesList,
		Map<Id, String> mapAccRoleOpsHierarchy, 
		String defaultOpsHierarchyName
	){
		for (Account_Role__c accrol : accRolesList.values()) {
			String groupName = accrol.From_Relationships__r.size() > 0 && accrol.From_Relationships__r[0].To__c != null && mapAccRoleOpsHierarchy.get(accrol.From_Relationships__r[0].To__r.Account__c) != null ? mapAccRoleOpsHierarchy.get(accrol.From_Relationships__r[0].To__r.Account__c) : defaultOpsHierarchyName;
			mapAccRoleOpsHierarchy.put(accrol.Id, groupName);
		}

		return mapAccRoleOpsHierarchy;
	}

	private static Map<Id, List<ICG_Account_Role_Detail__c>> generateMapAccountIdStationsList(List<ICG_Account_Role_Detail__c> stations){
		Map<Id, List<ICG_Account_Role_Detail__c>> mapAccountIdStationsList = new Map<Id, List<ICG_Account_Role_Detail__c>>();
		//Group stations by Account
		for (ICG_Account_Role_Detail__c st : stations) {
			if (mapAccountIdStationsList.get(st.Account_Role__r.Account__c) == null) {
				mapAccountIdStationsList.put(st.Account_Role__r.Account__c, new List<ICG_Account_Role_Detail__c>());
			}
			mapAccountIdStationsList.get(st.Account_Role__r.Account__c).add(st);
		}

		return mapAccountIdStationsList;
	}

	private static Map<Id, String> generateMapAccRoleOpsHierarchy(Map<Id, Account_Role__c> accRolesList){
		Map<Id, String> mapAccRoleOpsHierarchy = new Map<Id, String>();
		for (Account_Role__c accrol : accRolesList.values()) {
			for (Account_Role_Relationship__c acrr : accrol.From_Relationships__r) {
				if (acrr.Relationship_Name__c != null){
					mapAccRoleOpsHierarchy.put(accrol.Account__c, acrr.Relationship_Name__c);
				}
			}
		}
		return mapAccRoleOpsHierarchy;
	}

	private static Map<String, OpsHierarchyDataWrapper> generateStationsByOpsHierarchy(
		Map<Id, Account> allHierarchy,
		Map<Id, String> mapAccRoleOpsHierarchy,
		Map<String, GroupDataWrapper> mapGroup,
		Map<Id, List<ICG_Account_Role_Detail__c>> mapAccountIdStationsList,
		String defaultOpsHierarchyName
	){
		Map<String, OpsHierarchyDataWrapper> stationsByOpsHierarchy = new Map<String, OpsHierarchyDataWrapper>();
		for (Account acco : allHierarchy.values()) {
			String groupName = !acco.Account_Roles__r.isEmpty() && mapAccRoleOpsHierarchy.get(acco.Account_Roles__r[0].Id) != null  ? mapAccRoleOpsHierarchy.get(acco.Account_Roles__r[0].Id) : defaultOpsHierarchyName;
			if (stationsByOpsHierarchy.get(groupName) == null) {
				stationsByOpsHierarchy.put(groupName, new OpsHierarchyDataWrapper(mapGroup.get(groupName), new List<CompanyWrapper>()));
			}
			stationsByOpsHierarchy.get(groupName).companyList.add(new CompanyWrapper(acco, mapAccountIdStationsList.get(acco.Id)));
		}

		return stationsByOpsHierarchy;
	}

	private static Set<Id> generateAccRoleIds(Map<Id, Account> allHierarchy){
		Set<Id> accRolesIds = new Set<Id>();
		for (Account accnt : allHierarchy.values()) {
			for (Account_Role__c ar : accnt.Account_Roles__r) {
				accRolesIds.add(ar.Id);
			}
		}

		return accRolesIds;
	}

	private static List<ICG_Account_Role_Detail__c> queryStations(User u, Map<Id, Account> allHierarchy){
		return [SELECT id, name, Formatted_Address__c, Global_ID__c, isApproved__c, nearest_Airport__r.Code__c, isPendingApproval__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, City_FOR__c, RecordType.Name, CreatedDate, CreatedById, RecordType.DeveloperName, RecordTypeId, Street_Nr_FOR__c, Postal_Code_FOR__c, Status__c, logoUrl__c, Account_Role__c, Account_Role__r.Account__c, (SELECT id, ICG_Role__c, Status__c, isPendingApproval__c, isApproved__c FROM ICG_Contact_Role_Details__r WHERE Account_Contact_Role__r.contact__c = :u.ContactId), 
		(SELECT id, name, RecordType.DeveloperName, ICG_Certification__r.Name, ICG_Certification__r.Label__c, Certification_Id__c, Status__c, Sticker_Id__c, Issue_Date__c, Expiration_Date__c, ToLabel(CEIV_Scope_List__c), ToLabel(SFOC_Scope__c), CreatedDate, ICG_Certification__r.Certification_Type__c, ICG_Account_Role_Detail__r.Name FROM ICG_Capability_Assignment_Groups__r WHERE Is_Expired__c = false AND Is_Active__c = true AND RecordType.DeveloperName != 'No_Certification_Required	' ORDER BY Issue_Date__c DESC NULLS LAST) 
		FROM ICG_Account_Role_Detail__c WHERE Account_Role__r.Account__c IN :allHierarchy.keySet() ORDER BY Account_Role__r.Account__r.Name ASC, Name ASC];
	}

	private static List<Account_Role_Relationship__c> retrieveCompleteHierarchy(List<Account_Role_Relationship__c> userOpsHierarchy){
		List<Account_Role_Relationship__c> completeOpsHierarchy = new List<Account_Role_Relationship__c>();
		if (!userOpshierarchy.isEmpty()) {
			completeOpsHierarchy.addAll([SELECT Relationship_Name__c, Ops_Hierarchy_Group__c, From__c, From__r.Account__c, To__c, To__r.Account__c FROM Account_Role_Relationship__c WHERE (Ops_Hierarchy_Group__c != null AND Ops_Hierarchy_Group__c = :userOpsHierarchy[0].Ops_Hierarchy_Group__c) OR (To__c != null AND To__c = :userOpsHierarchy[0].To__c) OR (From__c != null AND From__c = :userOpsHierarchy[0].To__c)]);
		}
		return completeOpsHierarchy;
	}

	private static Map<Id, Account> queryAllHierarchy(String accId, List<Account_Role_Relationship__c> completeOpsHierarchy, String globalId, String globalUltimateId){
		Set<Id> accountsToSearch = new Set<Id>();
		accountsToSearch.add(accId);
		for (Account_Role_Relationship__c arr : completeOpsHierarchy) {
			accountsToSearch.add(arr.From__r.Account__c);
		}

		return new Map<Id, Account>([SELECT id, name, Global_Ultimate_Account_Global_ID__c, Global_ID__c, Business_Postal_Code__c, Business_City__c, Business_City__r.Name, Business_Street__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Business_City_Name__c, Iso_State__c, Iso_State__R.Name, Business_State_Name__c, Business_Geo_Coordinates__Latitude__s, Business_Geo_Coordinates__Longitude__s, Sector__c,Category__c, (SELECT id FROM Account_Roles__r WHERE Functional_Role__c = 'One Source') FROM Account WHERE Id IN :accountsToSearch OR (Global_Ultimate_Account_Global_ID__c != null AND (Global_Ultimate_Account_Global_ID__c = :globalUltimateId OR Global_Ultimate_Account_Global_ID__c = :globalId))]); 
	}

	@AuraEnabled(cacheable=true)
	public static String getUserInfo() {
		User u = [SELECT Id, Name, Email, ContactId, AccountId, Account.Name, Account.Global_Ultimate_Account_Global_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
		return JSON.serialize(u);
	}
	@AuraEnabled(cacheable=true)
	public static Boolean isProductionEnvironment() {
		return UserInfo.getOrganizationId().substring(0, 15) == '00D2000000008TF';
	}
	@AuraEnabled(cacheable=true)
	public static String getUserCompanyInfo(String accountId) {
		Account userAccount = new Account();
		User currentUser = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()];
		if (currentUser.AccountId != null || accountId != null) {
			String accIdToSearch = accountId != null ? accountId : currentUser.AccountId;
			userAccount = [SELECT id, Business_City__c, Business_City__r.Name, Business_City_Name__c, Business_Street__c, Business_Postal_Code__c, Iso_State__r.Name, Iso_State__c, IATA_ISO_Country__r.Name, IATA_ISO_Country__c, Business_State_Name__c, Business_Geo_Coordinates__Latitude__s, Business_Geo_Coordinates__Longitude__s FROM Account WHERE Id = :accIdToSearch];
		}
		return JSON.serialize(userAccount);
	}

	@AuraEnabled(cacheable=true)
	public static String getActiveCertifications() {
		List<String> listValidationPrograms = String.isNotBlank(CW_Utilities.VALIDATION_PROGRAMS ) ? CW_Utilities.VALIDATION_PROGRAMS.split(',') : new List<String>();
		return JSON.serialize([SELECT Id, Description__c, link__c, Name, Label__c, Certification_Type__c, Expiration_Period__c, is_visible__C, Image__c, Applicable_to__c FROM ICG_Certification__c WHERE is_visible__C = true AND ValidationPrograms__c IN: listValidationPrograms ORDER BY Order__c]);
	}

	@AuraEnabled(cacheable=true)
	public static String getGxaSSOUrl() {
		List<AppMenuItem> gxaSSOApp = [SELECT StartUrl FROM AppMenuItem WHERE Name = 'GxA'];
		String gxaUrl = gxaSSOApp.isEmpty() ? '#' : gxaSSOApp[0].startUrl;
		return gxaUrl;
	}

	public class OpsHierarchyDataWrapper {
		public String id { get; set; }
		public Datetime createdDate { get; set; }
		public String status { get; set; }
		public Boolean isCompanyAdmin { get; set; }
		public Boolean isPendingCompanyAdmin { get; set; }
		public List<CompanyWrapper> companyList { get; set; }

		public OpsHierarchyDataWrapper(GroupDataWrapper groupData, List<CompanyWrapper> cwrap) {
			if (groupData != null) {
				this.id = groupData.id;
				this.createdDate = groupData.createdDate;
				this.status = groupData.status;
				this.isCompanyAdmin = groupData.isCompanyAdmin;
				this.isPendingCompanyAdmin = groupData.isPendingCompanyAdmin;
			} else {
				this.isCompanyAdmin = false;
				this.isPendingCompanyAdmin = false;
			}
			this.companyList = cwrap;
		}
	}

	public class GroupDataWrapper {
		public String id { get; set; }
		public Datetime createdDate { get; set; }
		public String status { get; set; }
		public Boolean isCompanyAdmin { get; set; }
		public Boolean isPendingCompanyAdmin { get; set; }
		public GroupDataWrapper(String id, Datetime createdDate, String status, Boolean isCompanyAdmin, Boolean isPendingCompanyAdmin) {
			this.id = id;
			this.createdDate = createdDate;
			this.status = status;
			this.isCompanyAdmin = isCompanyAdmin;
			this.isPendingCompanyAdmin = isPendingCompanyAdmin;
		}
	}

	public class CompanyWrapper {
		public Account accountInfo { get; set; }
		public List<ICG_Account_Role_Detail__c> stations { get; set; }
		public CompanyWrapper(Account acc, List<ICG_Account_Role_Detail__c> stations) {
			this.accountInfo = acc;
			this.stations = stations;
		}
	}

	@AuraEnabled(cacheable=true)
	public static Boolean userHasOneSourceAccess() {
		Id oneSourceServiceId = CW_LoginController.getOneSourceServiceId();
		Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.ServiceAccess');
		return sessionPart != null && oneSourceServiceId != null && ((Boolean) sessionPart.get(oneSourceServiceId)) == true;
	}
}