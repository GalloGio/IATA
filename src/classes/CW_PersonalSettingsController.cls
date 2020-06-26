/**
 * @description		Controller of cwPersonalSettings component, it is used to retrieve information about the current user
 */
public with sharing class CW_PersonalSettingsController {
	public CW_PersonalSettingsController() {
	}
	/**
	 * @description		getUserSettingsInfo: retrieve info of the current user
	 * @return			UserWrapper serialized with the needed info in the front side
	 */
	@auraEnabled(cacheable=true)
	public static String getUserSettingsInfo() {
		try {
			UserWrapper userContainer;
			if (UserInfo.getUserType() == 'Guest') {
				userContainer = new UserWrapper(UserInfo.getUserType());
			} else {
				User user = [
					SELECT SmallPhotoUrl, FullPhotoUrl, Email
					FROM User
					WHERE id = :UserInfo.getUserId()
					LIMIT 1
				];
				userContainer = new UserWrapper(user);
			}
			return JSON.serialize(userContainer);
		} catch (Exception exc) {
			return JSON.serialize(new UserWrapper('exception'));
		}
	}

	/**
	 * @description		UserWrapper: object to storage info related to the current user
	 */
	public class UserWrapper {
		public String photolinkfull { get; set; }
		public String photolinksmall { get; set; }
		public String name { get; set; }
		public String userName { get; set; }
		public String userRole { get; set; }
		public String email {get;set;}

		public UserWrapper(User user) {
			this.photolinkfull = user.FullPhotoUrl;
			this.photolinksmall = user.SmallPhotoUrl;
			this.name = UserInfo.getName();
			this.userName = UserInfo.getUserName();
			this.userRole = UserInfo.getUserType();
			this.email = user.Email;
		}
		public UserWrapper(String usertype) {
			this.userRole = usertype;
		}
	}
}