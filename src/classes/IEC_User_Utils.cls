public without sharing class IEC_User_Utils {
	
	private static IEC_User_Utils instance = null;

	public String userEmail {get;set;}
	public String userLoginStatus {get;set;}
	public Id userId {get;set;}
	public String userZipCode {get;set;}
	public String userCity {get;set;}
	public String userCountry {get;set;}
	public String userRegion {get;set;}	
	public String userCompany {get;set;}
	public String userSessionId  {get;set;}
	public String userMemberStatus {get;set;}
	public String userGender {get; set;}

	private IEC_User_Utils() {
		User usr = [SELECT Id, Email, UserType, Contact.Gender__c, Contact_Account_Region__c, Contact_Account_Country__c, Contact_Account_Name__c, Contact.Name,
						Profile.Name, Contact.Account.BillingCity, Contact.Account.BillingPostalCode
				 	FROM User 
				 	WHERE Id = :UserInfo.getUserId()];

		userEmail = usr.Email;
		userLoginStatus = usr.UserType.contains('Guest') ? 'Logged Out' : 'Logged In';
		userMemberStatus = usr.UserType.contains('Guest') ? 'No' : 'Yes';
		userId = usr.Id;
		userZipCode = usr.Contact == null || usr.Contact.Account == null ? 'Unknown' : usr.Contact.Account.BillingPostalCode;
		userCity = usr.Contact == null || usr.Contact.Account == null ? 'Unknown' : usr.Contact.Account.BillingCity;
		userCountry = String.isBlank(usr.Contact_Account_Country__c) ? 'Unknown' : usr.Contact_Account_Country__c;
		userRegion = String.isBlank(usr.Contact_Account_Region__c) ? 'Unknown' : usr.Contact_Account_Region__c;
		userCompany = String.isBlank(usr.Contact_Account_Name__c) ? 'Unknown' : usr.Contact_Account_Name__c;
		userGender = String.isBlank(usr.Contact.Gender__c) ? 'Unknown' : usr.Contact.Gender__c;
		userSessionId = UserInfo.getSessionId();
	}

	public static IEC_User_Utils getInstance() {
		if(instance == null || instance.userSessionId != UserInfo.getSessionId()) {
			instance = new IEC_User_Utils();
		}
		return instance;
	}

}