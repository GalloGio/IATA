public without sharing class UserService {
	
	@InvocableMethod(label = 'Check User Status' description = 'Validates that the User related to the Contact Id is Unfrozen with Status is Active and has a Federation Id.' category = 'PortalServiceAccess')
	public static void checkUserStatus (List<Id> contactIdList) {
		List<User> userList = UserSelector.selectUserStatusFields(contactIdList);
		Users users = new Users(userList);
		users.updatePortalUserFrozenCheckbox(FALSE);
		update users.records;
	}

	public class UserServiceException extends Exception{}
}