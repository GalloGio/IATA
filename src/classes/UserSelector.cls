public class UserSelector {
	public static List<User> selectUserStatusFields(List<Id> contactIdList){
		return [SELECT Id, ContactId, Portal_User_Frozen_Checkbox__c, FederationIdentifier FROM User WHERE ContactId IN :contactIdList];
	}
}
