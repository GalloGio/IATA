public without sharing class GADM_ExternalUserContactList_CTRL {


	public class UserInformation {
		@AuraEnabled
		public List<Contact_Roles__c> grantedRoles {get; set;}
		@AuraEnabled
		public List<Contact_Roles__c> grantedBusinessUnits {get; set;}
		@AuraEnabled
		public List<Account> visibleAccounts {get; set;}
	}

	@AuraEnabled
	public static UserInformation getCurrentUserInformation(Id userId) {

		UserInformation info = new UserInformation();
		if(String.isNotBlank(userId)) {
			info.grantedBusinessUnits = getBusinessUnits(userId);
			info.grantedRoles = getGrantedRoles(userId);
			info.visibleAccounts = getVisibleAccounts(userId);
		}

		return info;
	}


	private static List<Contact_Roles__c> getBusinessUnits(Id userId) {

		List<Contact_Roles__c> businessUnitsToReturn = new List<Contact_Roles__c>();

		if(String.isNotBlank(userId)) {
			businessUnitsToReturn = Contact_Roles_Helper.getGrantedBusinessUnits(userId, 'GADM');
		}

		return businessUnitsToReturn;
	}


	private static List<Contact_Roles__c> getGrantedRoles(Id userId) {
		List<Contact_Roles__c> grantedRoles = new List<Contact_Roles__c>();

		if(String.isNotBlank(userId)) {
			grantedRoles = Contact_Roles_Helper.getGrantedUserRoles(userId, 'GADM');
		}

		return grantedRoles;
	}

	private static List<Account> getVisibleAccounts(Id userId) {
		List<Account> visibleAccounts = new List<Account>();

		if(String.isNotBlank(userId)) {
			visibleAccounts = Contact_Roles_Helper.getUserAccounts(userId);
		}

		return visibleAccounts;
	}


	@AuraEnabled
	public static List<Contact_Roles_Helper.AggregatedRecordWrapper> getContactsVisibleToUser(Id userId, Boolean isSuperUser, Boolean isGadmUser, List<Id> businessUnitsIds, Boolean sortDesc) {

		return Contact_Roles_Helper.getContactsVisibleToUser(userId, isSuperUser, isGadmUser, businessUnitsIds, null, sortDesc);
	}



}
