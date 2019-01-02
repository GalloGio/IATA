/* Partly based on ISSP_PersonalInformation.cls */

public without sharing class OneIdProfileCompanySettings {
	public OneIdProfileCompanySettings() {
		
	}

	@AuraEnabled
	public static Map<String, String> getUserInfo(){
		Map<String, String> userInformation = new Map<String, String>();
		String userId = Userinfo.getUserId();
		String userEmail = Userinfo.getUserEmail();
		userInformation.put('ID', userId);
		userInformation.put('Email',userEmail);
		return userInformation;
	}

	@AuraEnabled
	public static Contact getUserContact(){
		User user = DAL_ISSP.getUser(Userinfo.getUserId());
		Contact con = DAL_ISSP.getContact(user.ContactId);
       system.debug('aquiiiiiiiiiii' + user);
        system.debug('aquiiiii2' + con);
		return con;
	}

	@AuraEnabled
	public static List<String> getCategoryPicklistValues(){
		Schema.DescribeFieldResult fieldResult = Contact.Membership_Function__c.getDescribe();
		List<Schema.PicklistEntry> fieldPicklist = fieldResult.getPicklistValues();
		List<String> picklist = new List<String>();
		for(Schema.PicklistEntry p : fieldPicklist){
			picklist.add(p.getLabel());
		}
		return picklist;
	}

	@AuraEnabled
	public static List<String> getPreferredLanguagePicklistValues(){
		Schema.DescribeFieldResult fieldResult = Contact.Preferred_Language__c.getDescribe();
		List<Schema.PicklistEntry> fieldPicklist = fieldResult.getPicklistValues();
		List<String> picklist = new List<String>();
		for(Schema.PicklistEntry p : fieldPicklist){
			picklist.add(p.getLabel());
		}
		return picklist;
	}

	@AuraEnabled
	public static void saveProfileEdit(String firstname, String lastname, String phone, String mobilephone, String fax, String jobtitle, String functionpick, String preferredlanguage){

		User user = DAL_ISSP.getUser(Userinfo.getUserId());
		Contact con = DAL_ISSP.getContact(user.ContactId);

		try{
			if(user.ContactId != null){
				Contact newcon = new Contact();
				newcon.Id = user.ContactId;
				newcon.FirstName = firstname;
				newcon.LastName = lastname;
				newcon.Phone = phone;
				newcon.MobilePhone = mobilephone;
				newcon.Fax = fax;
				newcon.Title = jobtitle;
				newcon.Membership_Function__c = functionpick;
				newcon.Preferred_Language__c = preferredlanguage;
				System.debug(con.Membership_Function__c + '    ' + newcon.Membership_Function__c);
				System.debug(con.Preferred_Language__c + '    ' + newcon.Preferred_Language__c);
				update newcon;
			}

		}
		catch(Exception e) {
			System.debug('An unexpected error has occurred: ' + e.getMessage());
		}
	}
}