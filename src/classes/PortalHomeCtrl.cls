public with sharing class PortalHomeCtrl {

	@AuraEnabled
	public static String getUserName() {
		return Userinfo.getFirstName();
	}

}
