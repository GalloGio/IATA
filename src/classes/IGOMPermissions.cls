/**
 * @description		General class to manage Contact Permissions
 */
public without sharing class IGOMPermissions 
{
	/**
	 * @description	Utility function for APEX to check station-specific permissions.
	 * @param stationId <Id of the IGOM Account Role Detail>
	 * @param permissionAPIName <Name of the permission to check>
	 * @return Boolean <True if it has the permission, false if not>
	 */
	public static Boolean hasPermission(Id stationId, String permissionAPIName) {
		String stationRole = getRoleFromStationId(stationId);
		return IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(stationRole).contains(permissionAPIName);
	}

	/**
	 * @description	Utility function for APEX to check global permissions.
	 */
	public static Boolean hasPermission(String permissionAPIName) {
		for (String stationRole : getAllRoles()) {
			final List<String> rolesPermissions = IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(stationRole);
			if (rolesPermissions.contains(permissionAPIName)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * @description	Utility function for APEX to get station ids with specific permissions.
	 * @return A list of IGOM Account Role Detail ids that the current user has permission to access to
	 */
	public static List<Id> stationsWithPermission(String permissionAPIName) {
		List<Id> stationIds = new List<Id>();
		for (Id stationId : getAllStations()) {
			final String stationRole = getRoleFromStationId(stationId);
			final List<String> rolesPermissions = IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(stationRole);
			if (rolesPermissions.contains(permissionAPIName)) {
				stationIds.add(stationId);
			}
		}
		return stationIds;
	}

	public static List<Id> contactRoleDetailIdsWithPermission(String permissionAPIName) {
		List<Id> contactRoleDetailIds = new List<Id>();
		for (Id igomAccountRoleDetailId : stationsWithPermission(permissionAPIName)) {
			contactRoleDetailIds.add(stationIdToContactRoleDetailId.get(igomAccountRoleDetailId));
		}
		return contactRoleDetailIds;
	}
	
	/**
	 * @description	Function to get the permissions that the active user has for a station.
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, Boolean> getPermissions(Id stationId) {
		if (stationId != null) {
			String stationRole = getRoleFromStationId(stationId);
			return roleToPermission(stationRole);
		} else {
			Set<String> globalPermissions = new Set<String>();
			for (String role : getAllRoles()) {
				globalPermissions.addAll(IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(role));
			}
			return permissionListToMap(new List<String>(globalPermissions));
		}
	}

	/**
	 * @description	Function to check if the specified role has each available permission.
	 */
	private static Map<String, Boolean> roleToPermission(String role) {
		final List<String> rolesPermissions = IGOMConstants.PERMISSIONS.ROLE_TO_PERMISSIONS.get(role);
		return permissionListToMap(rolesPermissions);
	}

	/**
	 * @description	Return the list of available permissions with the ones that are contained in the specified permission list.
	 */
	private static Map<String, Boolean> permissionListToMap(List<String> permissionList) {
		Map<String, Boolean> permissionMap = new Map<String, Boolean>();
		for (String permission : IGOMConstants.PERMISSIONS.ALL) {
			permissionMap.put(permission, permissionList.contains(permission));
		}
		return permissionMap;
	} 

	/**
	 * @description	Cached permissions map.
	 */
	private static Map<Id, String> cachedStationIdToRole;

	/**
	 * @description	Function to retrieve all permissions.
	 */
	private static String getRoleFromStationId(Id stationId) {
		if (cachedStationIdToRole == null) {
			cachedStationIdToRole = retrieveStationIdToRole();
		}
		if (!cachedStationIdToRole.containsKey(stationId)) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.NO_ROLE_IN_STATION_FOR_USER_ERROR, new List<Object>{stationId, UserInfo.getUserId()}));
		}
		return cachedStationIdToRole.get(stationId);
	}

	/**
	 * @description	Function to get all the roles that has the current user has in all the stations they belong to.
	 */
	private static List<String> getAllRoles() {
		if (cachedStationIdToRole == null) {
			cachedStationIdToRole = retrieveStationIdToRole();
		}
		return cachedStationIdToRole.values();
	}

	/**
	 * @description	Function to get all the stations that the current user belongs to.
	 */
	private static Set<Id> getAllStations() {
		if (cachedStationIdToRole == null) {
			cachedStationIdToRole = retrieveStationIdToRole();
		}
		return cachedStationIdToRole.keySet();
	}

	/**
	 * @description	Function to get a map of the stations and the role in each of the station that the current user has.
	 */
	private static Map<Id, Id> stationIdToContactRoleDetailId;
	@TestVisible
	private static Map<Id, String> retrieveStationIdToRole() {
		// Get the current user
		final User currentUser = IGOMCommunityUtil.getCurrentUser();
		if (currentUser.ContactId == null) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.USER_WITHOUT_CONTACT_ERROR, new List<Object>{currentUser.Id, currentUser.Profile.Name}));
		}
		// Get the associated role for all the stations
		List<IGOM_Contact_Role_Detail__c> contactRoleDetails = 
			[SELECT Id, Role__c, Account_Role_Detail__c
			FROM IGOM_Contact_Role_Detail__c 
			WHERE Account_Contact_Role__r.Contact__c = :currentUser.ContactId];
			
		if (contactRoleDetails.isEmpty()) {
			throw new AuraHandledException(String.format(IGOMConstants.ERRORS.NO_ROLE_FOR_USER_AND_STATION_ERROR, new List<Object>{currentUser.Id, currentUser.ContactId}));
		}
		// Get the roles for each station
		Map<Id, String> stationIdToRole = new Map<Id, String>();
		// Cache data for contact role detail id mappings
		stationIdToContactRoleDetailId = new Map<Id, Id>();
		for (IGOM_Contact_Role_Detail__c contactRoleDetail : contactRoleDetails) {
			stationIdToRole.put(contactRoleDetail.Account_Role_Detail__c, contactRoleDetail.Role__c);
			stationIdToContactRoleDetailId.put(contactRoleDetail.Account_Role_Detail__c, contactRoleDetail.Id);
		}
		return stationIdToRole;
	}

}