/**
 * @description	  Class containing multiple methods related to the IGOM project inside CS-Portal community.
 */
public without sharing class IGOMCommunityUtil {

	/**
	 * APEX Object containing the data related to a community user
	 */
	public class UserData {
		@AuraEnabled public String fullName;
		@AuraEnabled public String avatarUrl;
		@AuraEnabled public String role;
		@AuraEnabled public Id userId;
		@AuraEnabled public Id contactId;
		public List<Id> contactRoleDetailIds;
		public UserData(User user, List<IGOM_Contact_Role_Detail__c> contactRoleDetails) {
			this.userId = user.Id;
			this.contactId = user.ContactId;
			this.fullname = user.Name;
			this.avatarUrl = user.FullPhotoUrl;
			this.contactRoleDetailIds = new List<Id>();
			if (contactRoleDetails != null) {
				for (IGOM_Contact_Role_Detail__c contactRoleDetail : contactRoleDetails) {
					this.contactRoleDetailIds.add(contactRoleDetail.id);
					this.role = contactRoleDetail.Role__c;
				}
			}
		}

		public UserData(Contact contact, IGOMContactRoleDetailUtil.ContactRoleDetail contactRoleDetail){
			User u = contact.Users.size() != 0 ? contact.Users.get(0) : null;
			this.userId = u?.Id;
			this.fullname = u != null ? u.Name : contact.Firstname + ' ' + contact.Lastname;
			this.avatarUrl = u?.FullPhotoUrl;
			this.contactRoleDetailIds = contactRoleDetail != null ? new List<Id>{contactRoleDetail.id} : new List<Id>{};
			this.role = contactRoleDetail?.role;
			this.contactId = contact.Id;
		}
	}

	private static User currentUser;
	/**
	 * @description	Recover and cache the active user's information
	 * @return		User Active user
	 */
	public static User getCurrentUser() {
		if (currentUser == null) {
			currentUser = [SELECT Id, Name, ContactId, FullPhotoUrl, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
		}
		return currentUser;
	}

	/**
	 * @description	Recover active user's information, containing both the user and the contact role info.
	 * @return		UserData Active user UserData information object
	 */
	@AuraEnabled(cacheable=true)
	public static UserData getUserData() {
		// Get the current user
		User currentUser = getCurrentUser();
		// Query the related contact information from contact role detail
		List<IGOM_Contact_Role_Detail__c> contactRoleDetails =
			[SELECT Account_Contact_Role__r.Contact__r.Name, Role__c
			 FROM IGOM_Contact_Role_Detail__c
			 WHERE Account_Contact_Role__r.Functional_Role__c = :IGOMConstants.GLOBALS.FUNCTIONAL_ROLE_SERVICE
				   AND Account_Contact_Role__r.Contact__c = :currentUser.ContactId];
		// Return the info
		return new UserData(currentUser, contactRoleDetails);
	}

	/**
	 * @description	Get the list of users in a station, both the ones that are in the account related to the station and the
	 * ones that have a contact role in it.
	 * @param		stationId <Station record>
	 * @return		List<UserData> <List of users in the station>
	 */
	@AuraEnabled(cacheable=true)
	public static List<UserData> getUsersInStation(Id stationId){
		Map<Id, Contact> contacts = new Map<Id, Contact>();
		IGOMStationUtil.Station stationInfo = IGOMStationUtil.getIGOMAccountRoleDetailByIds(new List<Id>{stationId}).get(0);

		//Query all the contacts with their community user from station
		for (Contact con : IGOMContactRoleDetailUtil.getContactsInAccount(stationInfo.accountId)){
			contacts.put(con.Id, con);
		}

		List<UserData> userDatas = new List<UserData>();

		Map<Id, IGOMContactRoleDetailUtil.ContactRoleDetail> roleDetailsPerContact = IGOMContactRoleDetailUtil.getRoleDetailsFromContacts(stationId, contacts.keySet());
		Set<Id> roleIds = new Set<Id>();
		if(!roleDetailsPerContact.isEmpty()){
			for(IGOMContactRoleDetailUtil.ContactRoleDetail role : roleDetailsPerContact.values()){
				roleIds.add(role.id);
			}
		}

		Map<Id, IGOMContactRoleDetailUtil.ContactRoleDetail> nonStationRoleDetailsPerContact = IGOMContactRoleDetailUtil.getOtherRoleDetails(stationId, roleIds);
		//Create UserData from all the contacts in station
		for(Id contactId : contacts.keySet()){
			userDatas.add(new UserData(contacts.get(contactId), roleDetailsPerContact.get(contactId)));
		}

		Set<Id> nonStationContacts = new Set<Id>();
		//Create UserData from the contacts that are not in station account but have a role in it
		for(Id contactId : nonStationRoleDetailsPerContact.keySet()){
			IGOMContactRoleDetailUtil.ContactRoleDetail contactRole = nonStationRoleDetailsPerContact.get(contactId);
			if(stationId == contactRole.accountRoleDetailId){
				nonStationContacts.add(contactId);
			}
		}

		// Get contact from other account's information
		for(Contact con : [SELECT Id, Firstname, Lastname FROM Contact WHERE Id IN :nonStationContacts]){
			userDatas.add(new UserData(con, nonStationRoleDetailsPerContact.get(con.Id)));
		}
		return userDatas;
	}

	/**
	 * @description	Get the list of related stations for a specific station.
	 * @param		stationId <Base station record>
	 * @return		IGOMAccountRoleRelationshipsUtil.AllRelationships <All the relationships of the station>
	 */
	@AuraEnabled(cacheable=true)
	public static IGOMAccountRoleRelationshipsUtil.AllRelationships getAllRelatedStations(Id stationId){
		return IGOMAccountRoleRelationshipsUtil.getAllRelationships(stationId);
	}

	/**
	 * @description	Get the list of unrelated stations for a specific station.
	 * @param		stationId <Base station record>
	 * @return		List<IGOMStationUtil.RelatedStation> <All the unrelated stations and the requests made>
	 */
	@AuraEnabled(cacheable=true)
	public static List<IGOMStationUtil.RelatedStation> getUnrelatedStations(Id stationId, String searchTerm){
		IGOMAccountRoleRelationshipsUtil.AllRelationships allRelationship = getAllRelatedStations(stationId);
		List<Id> relatedStations = new List<Id>();
		for (IGOMStationUtil.RelatedStation pStation : allRelationship.parentStations) {
			relatedStations.add(pStation.stationInfo.id);
		}
		for (IGOMStationUtil.RelatedStation cStation : allRelationship.childStations) {
			relatedStations.add(cStation.stationInfo.id);
		}
		for (IGOMStationUtil.RelatedStation gStation : allRelationship.groupStations) {
			relatedStations.add(gStation.stationInfo.id);
		}

		return IGOMAccountRoleRelationshipsUtil.getUnrelatedStations(new Set<Id>(relatedStations), stationId, searchTerm);
	}

	/**
	 * @description	Get the list of users in a station.
	 * @param		stationId <Station record>
	 * @return		List<UserData> <List of users in the station>
	*/
	@AuraEnabled
	public static UserData searchSpecificUserAvoidingStation(Id stationId, String searchTerm){
		// Get all the contacts that contain the search term from different stations
		Contact contactSearched = IGOMContactRoleDetailUtil.getContactsAvoidingStation(new List<Id>{stationId}, searchTerm);
		if(contactSearched != null){
			return new UserData(contactSearched, null);
		}else{
			return null;
		}
	}

	/**
	 * @description	Delete the role of a contact in the sation.
	 * @param		stationId <Station record>
	 * @param		contactId <Contact record>
	*/
	@AuraEnabled
	public static void deleteContactRoleDetail(Id stationId, Id contactId){
		Map<Id, IGOMContactRoleDetailUtil.ContactRoleDetail> rolesPerContact = IGOMContactRoleDetailUtil.getRoleDetailsFromContacts(stationId, new Set<Id>(new List<Id>{contactId}));
		delete new IGOM_Contact_Role_Detail__c(
			Id = rolesPerContact.values().get(0).id
		);
	}

	/**
	 * @description	Method to remove multiple ids from a list of objects.
	 * @param		objectList <List of SObject to remove the ids from.>
	 * @param		idsToRemove <Set of ids of the SObjects to be removed from list.>
	 * @param		fieldApiName <Api name of the field where the ids are going to be filtered from. Field must be an Id.>
	 * @return		List<SObject> <List of the SObjects that do not have the id in idsToRemove.>
	 */
	public static List<sObject> removeItemsFromListByField(List<sObject> objectList, Set<Id> idsToRemove, String fieldApiName){
		Integer i = 0;
		while (i < objectList.size())
		{
			if(idsToRemove.contains((Id) objectList.get(i).get(fieldApiName))){
				objectList.remove(i);
			}else{
				i++;
			}
		}
		return objectList;
	}

	/**
	 * @description Utility method to group a sobject list in a map by one of the fields
	 * @param		sobjects <List of SObjects to group>
	 * @param		groupingField <String of the grouping field>
	 * @return		Map<Object, List<SObject>> <Map having the sobjects grouped in lists by the groupingField key>
	 */
	public static Map<Object, List<SObject>> groupSObjects(List<SObject> sobjects, String groupingField) {
		Map<Object, List<SObject>> groupedSObjects = new Map<Object, List<SObject>>();
		for (SObject sobj : sobjects) {
			final Object groupingKey = sobj.get(groupingField);
			List<SObject> sobjectList = groupedSObjects.get(groupingKey);
			if (sobjectList == null) {
				sobjectList = new List<SObject>();
				groupedSObjects.put(groupingKey, sobjectList);
			}
			sobjectList.add(sobj);
		}
		return groupedSObjects;
	}
}