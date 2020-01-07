public class clsLanguageExtension {

		public clsLanguageExtension(ApexPages.StandardController stdController) {
		}

		public String getLocale() {

				User[] users = [Select u.LanguageLocaleKey From User u where u.Id =: UserInfo.getUserId()];

				if (users != null && users.size() > 0)
						return users[0].LanguageLocaleKey;
				else
						return '';

		//return UserInfo.getLocale();
		}
}
