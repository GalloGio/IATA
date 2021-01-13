public without sharing class ISSP_PermissionFilterFactory {

	public interface IPermissionFilter {

		Boolean isUserPermittedFor(sObject oneData, String fieldName);
		Boolean isDataEmpty(sObject oneData, String fieldName);
	}

	public class ProfilePermissionFilter implements IPermissionFilter {

		private String profileId15;

		public ProfilePermissionFilter() {
			this.profileId15 = UserInfo.getProfileId().substring(0,15);
		}

		public ProfilePermissionFilter(ID profileId) {
			this.profileId15 = ((String)profileId).substring(0,15);
		}

		public Boolean isDataEmpty(sObject oneData, String profileIdHolder_FieldName) {
			return String.isBlank((String)oneData.get(profileIdHolder_FieldName)); //'Profiles_Id__c';
		}

		public Boolean isUserPermittedFor(sObject oneData, String profileIdHolder_FieldName) {
			String value = (String)oneData.get(profileIdHolder_FieldName); //'Profiles_Id__c';
			Set<String> profilesIdSet = new Set<string>(value.split(';'));
			return profilesIdSet.contains(profileId15);
		}

	}

	public class  PermissionSetFilter implements IPermissionFilter {
		private Set<Id> permissionSetForUserSet;
		private String  permissionSetHolder_FieldName;

		public PermissionSetFilter(Set<ID> permissionSetIDs) {
			this.permissionSetForUserSet = getPermissionSetForUserSet(permissionSetIDs, UserInfo.getUserId());
		}

		public PermissionSetFilter(ID userId, Set<ID> permissionSetIDs) {
			this.permissionSetForUserSet = getPermissionSetForUserSet(permissionSetIDs, userId);
		}

		public Boolean isDataEmpty(sObject oneData, String permissionSetHolder_FieldName) {
			return String.isBlank((String)oneData.get(permissionSetHolder_FieldName));//'Permission_set__c';
		}

		public Boolean isUserPermittedFor(sObject oneData, String permissionSetHolder_FieldName) {
			String value = (String)oneData.get(permissionSetHolder_FieldName);//'Permission_set__c';
			Set<String> permissionSetIds = new Set<string>(value.split(';'));


			for(ID permisSetId : permissionSetIds) {
				if(permissionSetForUserSet.contains(ID.valueOf(permisSetId))) {
					return true;
				}
			}
			return false;
		}
	}



	public static set<ID> getPermissionSetForUserSet(set<ID> permissionSetIDs, ID userId) {
		set<ID> permissionSetForUserSet = new Set<ID>();
		for(PermissionSet onePermissionSet :  getPermissionSetById(permissionSetIDs, userId)) {
			if(ISSP_Utilities.isNotEmpty(onePermissionSet.Assignments)) {
				permissionSetForUserSet.add(onePermissionSet.Id);
			}
		}
  		return permissionSetForUserSet;

	}

	public static list<PermissionSet> getPermissionSetById(set<ID> permissionSetIDs, ID userId) {
		return
			[SELECT Id
				  ,(SELECT Id, PermissionSetId, AssigneeId
				  	  FROM Assignments
				  	 WHERE AssigneeId =: userId)
			   FROM PermissionSet
			  WHERE Id IN : permissionSetIDs];
	}
	/**
	 *  Factories functions
	 */
	public static ProfilePermissionFilter createProfilePermissionFilter() {
		return 	new ProfilePermissionFilter();
	}

	public static PermissionSetFilter createPermissionSetFilter(List<sObject> settingList, String fieldName) {

		Set<ID> permissionSetIDs = new Set<ID>();
		for(Sobject caseListViewItem : settingList){
			String valueField = (String)caseListViewItem.get(fieldName); //Permission_set__c
			if(String.isNotBlank(valueField)) {
				for(String permisSetStr : valueField.split(';')) {
					if(String.isNotBlank(permisSetStr))
						permissionSetIDs.add(ID.valueOf(permisSetStr));
				}
			}
		}

		return new PermissionSetFilter(permissionSetIDs);
	}
}
