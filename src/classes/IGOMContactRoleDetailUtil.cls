/**
 * @description	  Class to contain all the functions related to the IGOM_Contact_Role_Detail__c object
 */
public without sharing class IGOMContactRoleDetailUtil{
	
	/**
	 * DAO Object containing the data from a IGOM_Contact_Role_Detail__c record
	 */
	public class ContactRoleDetail {
		public Id id;
		public Id contactRoleId;
		public Id accountRoleDetailId;
		public String role;

		public ContactRoleDetail(IGOM_Contact_Role_Detail__c contactRoleDetail) {
			id = contactRoleDetail.Id;
			contactRoleId = contactRoleDetail.Account_Contact_Role__c;
			accountRoleDetailId = contactRoleDetail.Account_Role_Detail__c;
			role = contactRoleDetail.Role__c;
		}
	}

	/**
	 * @description	Method to set a role to a contact on a station
	 * @param		roleType <Type of role to set>
	 * @param		contactId <Contact id>
	 * @param		stationId <Active station id>
	 * @return		IGOM_Contact_Role_Detail__c <Set role>
	 */
	@AuraEnabled
	public static IGOM_Contact_Role_Detail__c setRoleDetailToContact(String roleType, Id contactId, Id stationId){
		List<IGOM_Contact_Role_Detail__c> roles = [SELECT Id, Name, Role__c,
		Account_Role_Detail__c, Account_Role_Detail__r.Account_Role__c,
		Account_Contact_Role__c, Account_Contact_Role__r.Contact__c
		FROM IGOM_Contact_Role_Detail__c WHERE Account_Role_Detail__c = :stationId 
		AND Account_Contact_Role__r.Contact__c = :contactId LIMIT 1];
		IGOM_Contact_Role_Detail__c role;
		// Check if roles exist to update existing one
		if(!roles.isEmpty()){
			role = roles.get(0);
			role.Role__c = roleType;
		}else{
			// Create a new contact role detail if it does not exist 
			IGOM_Account_Role_Detail__c accountRoleDetail = [SELECT Id, Account_Role__c, Account_Role__r.Account__c
			FROM IGOM_Account_Role_Detail__c WHERE Id = :stationId LIMIT 1];

			List<Account_Contact_Role__c> accountContactRoles = [SELECT Id FROM Account_Contact_Role__c
			WHERE Contact__c = :contactId AND Account__c = :accountRoleDetail.Account_Role__r.Account__c AND
			Functional_Role__c = :IGOMConstants.GLOBALS.FUNCTIONAL_ROLE_SERVICE];

			//When no account contact role existed, create one to assign to contact role detail
			Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
			Account_Contact_Role__c accountContactRole;
			if(accountContactRoles.isEmpty()){
				accountContactRole = new Account_Contact_Role__c(
					RecordTypeId = functionalRecordTypeId,
					Contact__c = contactId,
					Account__c = accountRoleDetail.Account_Role__r.Account__c,
					Status__c = 'Active',
					Service_Rendered__c = IGOMConstants.GLOBALS.SERVICE_RENDERED_NAME
				);
				accountContactRole.Account_Role__c = accountRoleDetail.Account_Role__c;
				insert accountContactRole;
			}else{
				accountContactRole = accountContactRoles.get(0);
			}
			
			role = new IGOM_Contact_Role_Detail__c(
				Account_Role_Detail__c = accountRoleDetail.Id,
				Account_Contact_Role__c = accountContactRole.Id,
				Role__c = roleType //If multiple roles are allowed, put all of them joined by ';'
			);
		}
		upsert role;
		return role;
	}

	/**
	 * @description	Method to recover all the role details for a list of users and a single station
	 * @param		stationId <Active station id>
	 * @param		contactIds <Set of Contact ids>
	 * @return		Map<Id, ContactRoleDetail> <Contact Role per contact in station>
	 */
	public static Map<Id, ContactRoleDetail> getRoleDetailsFromContacts(Id stationId, Set<Id> contactIds){
		if(stationId != null && !contactIds.isEmpty()){
			//Get station from id
			IGOMStationUtil.Station stationInfo = IGOMStationUtil.getIGOMAccountRoleDetailByIds(new List<Id>{stationId}).get(0);
			
			//Get account contact roles from station and contacts
			Map<Id, Id> contactIdPerAccountContactRoleId = new Map<Id, Id>();
			for (Account_Contact_Role__c accContRole : [SELECT Id, Contact__c FROM Account_Contact_Role__c 
			WHERE Contact__c IN :contactIds AND Account_Role__c = :stationInfo.accountRoleId]) {
				contactIdPerAccountContactRoleId.put(accContRole.Id, accContRole.Contact__c);
			}
		
			Map<Id, ContactRoleDetail> roleDetailPerContact = new Map<Id, ContactRoleDetail>();
			if(!contactIdPerAccountContactRoleId.values().isEmpty()){
				//Get the role details from recovered information
				for(IGOM_Contact_Role_Detail__c roleDetail : [SELECT Id, Role__c, Account_Contact_Role__c, Account_Role_Detail__c
				FROM IGOM_Contact_Role_Detail__c WHERE Account_Contact_Role__c IN :contactIdPerAccountContactRoleId.keySet()
				AND Account_Role_Detail__c = :stationInfo.id AND Account_Contact_Role__r.Account__c = :stationInfo.accountId]){
					roleDetailPerContact.put(
						contactIdPerAccountContactRoleId.get(roleDetail.Account_Contact_Role__c),
						new ContactRoleDetail(roleDetail));
				}
				if(!roleDetailPerContact.isEmpty()){
					return roleDetailPerContact;
				}
			}
		}
		return new Map<Id, ContactRoleDetail>();
	}

	/**
	 * @description	Method to recover all the role details in a station avoiding certain role details
	 * @param		stationId <Active station id>
	 * @param		contactRoleDetails <Contact role details to avoid searching>
	 * @return		Map<Id, ContactRoleDetail> <Contact Role per contact in station>
	 */
	public static Map<Id, ContactRoleDetail> getOtherRoleDetails(Id stationId, Set<Id> contactRoleDetails){
		Map<Id, ContactRoleDetail> roleDetailPerContact = new Map<Id, ContactRoleDetail>();
		for(IGOM_Contact_Role_Detail__c roleDetail : [SELECT Id, Role__c, Account_Contact_Role__c, Account_Role_Detail__c,
		Account_Contact_Role__r.Contact__c FROM IGOM_Contact_Role_Detail__c WHERE Id NOT IN :contactRoleDetails
		AND Account_Role_Detail__c = :stationId]){
			roleDetailPerContact.put(roleDetail.Account_Contact_Role__r.Contact__c, new ContactRoleDetail(roleDetail));
		}
		return roleDetailPerContact;
	}

	/**
	 * @description	Method to retrieve the contacts in the stations that are not avoided by search term
	 * @param		stationsToAvoid <List of the ids of the stations that want to be avoided>
	 * @param		searchTerm <Term to identify the contact>
	 * @return		Contact <Contact found>
	 */
	public static Contact getContactsAvoidingStation(List<Id> stationsToAvoid, String searchTerm){
		List<IGOMStationUtil.Station> stationsToAvoidInfo = IGOMStationUtil.getIGOMAccountRoleDetailByIds(stationsToAvoid);
		Set<Id> accountsToAvoid = new Set<Id>();
		for(IGOMStationUtil.Station st : stationsToAvoidInfo){
			accountsToAvoid.add(st.accountId);
		}

		//Protect against SOQL injection
		String searchTermProtected = '%' + searchTerm + '%';
		String query = 'SELECT Id, FirstName, LastName, (SELECT Id, Name, FullPhotoUrl FROM Users) FROM Contact WHERE AccountId NOT IN :accountsToAvoid '+
		'AND Name LIKE :searchTermProtected LIMIT 1';
		try {
			return (Contact)Database.query(query);	
		} catch (QueryException qe) {
			return null;
		}
	}

	/**
	 * @description	Method to get all the contacts in an account
	 * @param		accountId <Account to get contacts from>
	 * @return		List<Contact> <Contacts in account>
	 */
	public static List<Contact> getContactsInAccount(Id accountId){
		return [SELECT Id, FirstName, LastName, (SELECT Id, Name, FullPhotoUrl FROM Users) FROM Contact WHERE AccountId = :accountId];
	}
}