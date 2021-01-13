/**
 *
 * This class provides methods to assign/remove Permission Sets for FAQs for a given userId.
 *
 * The permission sets, starting with 'FAQ_Visibility' should grant access to certain data categories.
 */

public without sharing class PortalFAQsSharingCtrl {

	PUBLIC STATIC FINAL STRING DEFAULT_METADATA_NAME = 'FAQs_DEFAULT';
	PUBLIC STATIC FINAL STRING CNS_DEFAULT_METADATA_NAME = 'FAQs_DEFAULT_CNS';

	PUBLIC STATIC FINAL STRING FAQ_PERMSET_PREFIX = 'FAQ_Visibility%';
	PUBLIC STATIC FINAL STRING FAQ_PERMSET_PREFIX2 = 'FAQs_Visibility%';

	PRIVATE STATIC FINAL STRING UNKNOWN_VALUE = '--FAQ_UNKNOWN--';
	PRIVATE STATIC FINAL STRING ALL_VALUES = 'All';

	public static Set<Id> availablePermissionSets;
	public static Set<Id> assignedPermissionSets;
	private static Boolean checkOnly = false;


	/**
	 *  This method acceepts userId and checks for existing FAQ permission set assignments.
	 *
	 *  If no assignments are found, assign them.
	 *
	 *  If assignments are found, we validate them against permission sets that are available for the given user. If available and existing permission set assignments are not identical:
	 *      remove existing and assign new.
	 *
	 * @param userId
	 */

	@future
	public static void validateUserFAQsPermissions(Id userId){
		List <PermissionSetAssignment> existingAssignments = [SELECT Id, AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: userId AND (PermissionSet.Name LIKE :FAQ_PERMSET_PREFIX OR PermissionSet.Name LIKE :FAQ_PERMSET_PREFIX2)];
		Set<Id> existingSetIds = new Set<Id>();

		if(!existingAssignments.isEmpty()){
			for(PermissionSetAssignment assignment : existingAssignments){
				existingSetIds.add(assignment.PermissionSetId);
			}

			assignedPermissionSets = existingSetIds;
			checkOnly = true;

			//Check only for available permset ids
			assignFAQsPermissions(userId);

			//Now we might actually want to assign some new permission sets
			checkOnly = false;

			if(availablePermissionSets != null && !availablePermissionSets.containsAll(assignedPermissionSets) || !assignedPermissionSets.containsAll(availablePermissionSets)){
				removeFAQsPermissions(userId);
				assignFAQsPermissions(userId);
			}

		}else{
			assignFAQsPermissions(userId);
		}
	}

	public static void assignFAQsPermissions(Id userId){
		Set<Id> availableSetIds = new Set<Id>();

		User userInfo = [SELECT Id,contact.AccountId,contact.Account.Sector__c,contact.Account.Category__c,contact.Account.IATA_ISO_Country__c,contact.Account.IATA_ISO_Country__r.ISO_Code__c,CNS_Account_or_Agency__c FROM User WHERE Id =:userId];

		String countryCode;
		String accountSector;
		String accountCategory;

		if(userInfo.contact.AccountId != null){
			countryCode = userInfo.contact.Account.IATA_ISO_Country__c != null ? userInfo.contact.Account.IATA_ISO_Country__r.ISO_Code__c : UNKNOWN_VALUE;
			accountSector = userInfo.contact.Account.Sector__c  != null ? userInfo.contact.Account.Sector__c : UNKNOWN_VALUE;
			accountCategory = userInfo.contact.Account.Category__c != null ? userInfo.contact.Account.Category__c : UNKNOWN_VALUE;
		}


		List<String> permsetNames = new List<String>();

		List<PortalFAQs__mdt> settings = new List<PortalFAQs__mdt>();

		if(!userInfo.CNS_Account_or_Agency__c) {
			//Get permission set with a matching Sector -> this value must be matched, no wildcards here.
			Map<Id, PortalFAQs__mdt> sectorSettingsMap = new Map<Id, PortalFAQs__mdt>([
					SELECT Permission_Set_Name__c,Account_Categories__c,Account_Sector__c,ISO_Country_Codes1__c,ISO_Country_Codes2__c,ISO_Country_Codes3__c
					FROM PortalFAQs__mdt
					WHERE Account_Sector__c = :accountSector
			]);

			if (!sectorSettingsMap.isEmpty()) {
				for (PortalFAQs__mdt setting : sectorSettingsMap.values()) {

					List<String> categories = setting.Account_Categories__c != null ? setting.Account_Categories__c.split(';') : new List<String>();
					Set<String> categorySet = new Set<String>();
					categorySet.addAll(categories);

					Boolean matchingCategory = categorySet.contains(accountCategory) || categorySet.contains(ALL_VALUES);

					//If matching category is found, check countries
					if (matchingCategory) {
						List<String> countries1 = setting.ISO_Country_Codes1__c != null ? setting.ISO_Country_Codes1__c.split(',') : new List<String>();
						List<String> countries2 = setting.ISO_Country_Codes2__c != null ? setting.ISO_Country_Codes2__c.split(',') : new List<String>();
						List<String> countries3 = setting.ISO_Country_Codes3__c != null ? setting.ISO_Country_Codes3__c.split(',') : new List<String>();

						Set<String> countrySet = new Set<String>();
						countrySet.addAll(countries1);
						countrySet.addAll(countries2);
						countrySet.addAll(countries3);

						//Country code present or a wildcard found
						Boolean matchingCountry = countrySet.contains(countryCode) || countrySet.contains(ALL_VALUES);

						//If country match found
						if (matchingCountry) {
							permsetNames.add(setting.Permission_Set_Name__c);
						}
					}
				}
			}
		}

		//CNS Accounts have a special setting
		if(userInfo.CNS_Account_or_Agency__c){
			settings = [SELECT Permission_Set_Name__c FROM PortalFAQs__mdt WHERE DeveloperName =: CNS_DEFAULT_METADATA_NAME];
			if(!settings.isEmpty()){
				for(PortalFAQs__mdt setting:settings){
					permsetNames.add(setting.Permission_Set_Name__c);
				}
			}else{
				System.debug('NO FAQ PERMISSION SET TO BE ASSIGN FOR CNS ACC. Default FAQs permission set for CNS is missing.');
				return;
			}
		}

		//If no permission set was found for given criteria, assign default set
		if(permsetNames.isEmpty()){
			settings = [SELECT Permission_Set_Name__c FROM PortalFAQs__mdt WHERE DeveloperName =: DEFAULT_METADATA_NAME];
			if(!settings.isEmpty()){
				for(PortalFAQs__mdt setting:settings){
					permsetNames.add(setting.Permission_Set_Name__c);
				}
			}else{
				System.debug('NO FAQ PERMISSION SET TO BE ASSIGN. Default FAQs permission set is missing.');
				return;
			}
		}

		if(!permsetNames.isEmpty()) {
			List <PermissionSet> setList = [SELECT Id,Name FROM PermissionSet WHERE Name IN:permsetNames];

			if (!setList.isEmpty()) {
				List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
				PermissionSetAssignment newPermission;

				for(PermissionSet permSet : setList){
					newPermission   = new PermissionSetAssignment();
					newPermission.AssigneeId = userId;
					newPermission.PermissionSetId = permSet.Id;
					assignments.add(newPermission);

					availableSetIds.add(permSet.Id);
				}

				if(!assignments.isEmpty()){
					if(!checkOnly){
						insert assignments;
					}else{
						availablePermissionSets = availableSetIds;
					}
				}
			}else{
				System.debug('NO FAQ PERMISSION SETS FOUND.');
				return;
			}
		}
	}


	/**
	 * Removes all Permission Sets for portal FAQs (Data Categories) assigned to User with a given userId.
	 * @param userId
	 */

	public static void removeFAQsPermissions(String userId){


		List <PermissionSetAssignment> assignmentListRemove = [SELECT Id, AssigneeId FROM PermissionSetAssignment
		WHERE AssigneeId =: userId
		AND (PermissionSet.Name LIKE :FAQ_PERMSET_PREFIX OR PermissionSet.Name LIKE :FAQ_PERMSET_PREFIX2)];


		if (!assignmentListRemove.isEmpty()){
			delete assignmentListRemove;
		}
	}

}
