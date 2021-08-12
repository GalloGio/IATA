@IsTest
public class TestDataFactory_Users {
	public static final Profile DEFAULTPROFILE = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)'];
	public static final Profile SYSTEMADMINPROFILE = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
	public static final String DEFAULTEMAIL = 'abc@def.com.invalid';

	public static List<User> createPortalUsers(List<Contact> contactList){
		List<User> userList = new List<User>();
		
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');

		for(Contact contact: contactList){
			User user = (User) Schema.getGlobalDescribe().get('User').newSObject();
			Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
			String uniqueName = orgId + dateString + randomInt;
			user.Alias = uniqueName.substring(18, 23);
			user.ContactId = contact.Id;
			user.Email = contact.Email;
			user.EmailEncodingKey = 'UTF-8';
			user.IsActive = true;
			user.LastName = contact.LastName;
			user.LanguageLocaleKey = 'en_US';
			user.LocaleSidKey = 'en_US';
			user.ProfileId = DEFAULTPROFILE.Id;
			user.TimeZoneSidKey = 'America/Los_Angeles';
			user.UserName = uniqueName + '@test' + orgId + '.org';
			userList.add(user);
		}
		return userList;
	}

	public static List<User> createInternalSystemAdminUsers(Integer numberOfRecords){
		List<User> userList = new List<User>();
		
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');

		for(Integer x = 0; x < numberOfRecords; x++){
			User user = (User) Schema.getGlobalDescribe().get('User').newSObject();
			Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
			String uniqueName = orgId + dateString + randomInt;
			user.Alias = uniqueName.substring(18, 23);
			user.Email= DEFAULTEMAIL + 'x';
			user.UserName= uniqueName + '@test' + orgId + '.org';
			user.EmailEncodingKey='UTF-8';
			user.LastName = 'LastName';
			user.LanguageLocaleKey='en_US';
			user.License_Cost_Center__c = 'ISF005CH01';
			user.LocaleSidKey='en_US';
			user.ProfileId = SYSTEMADMINPROFILE.Id;
			user.IsActive = true;
			user.TimeZoneSidKey='America/Los_Angeles';
			userList.add(user);
		}
		return userList;
	}
}