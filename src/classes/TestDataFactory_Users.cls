@IsTest
public class TestDataFactory_Users {
	public static final Profile DEFAULTPROFILE = [SELECT Id FROM Profile WHERE Name='ISS Portal Airline User (Partner)'];

	/**
	 * Creates a portal user for each input account
	 * input contacts are also modified and require to be updated after inserting users
	 * 
	 * IMPORTANT: INSERT RETURNED USERS AND UPDATE INPUT CONTACTS
	 */
	public static List<User> createPortalUsers(list<Contact> listContact){
		List<User> listUser = new List<User>();

		for(Contact contact: listContact){
			String alias = contact.LastName.replaceAll(' ','_');
			User portalUser = new User(
				Alias = alias.left(8),
				Email= alias + '@testorg.com',
				UserName= alias + '@testorg.com',
				EmailEncodingKey='UTF-8',
				LastName=contact.LastName,
				LanguageLocaleKey='en_US',
				LocaleSidKey='en_US',
				ProfileId = DEFAULTPROFILE.Id,
				ContactId = contact.Id,
				IsActive = true,
				TimeZoneSidKey='America/Los_Angeles'
			);
			//updating input contact
			contact.User_Portal_Status__c = 'Approved Admin';
			contact.Community__c = 'Community__c';
			listUser.add(portalUser);
		}
		
		return listUser;
	}
}