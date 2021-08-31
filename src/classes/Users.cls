public inherited sharing class Users {
	public static final Profile DEFAULTPROFILE = [SELECT Id FROM Profile WHERE Name='ISS Portal Airline User (Partner)'];
	public List<User> records { get; private set; }

	public Users(){
		records = new List<User>();
		// initialise();
	}
	
	public Users(List<User> userList){
		records = userList.clone();
		// initialise();
	}
		
	// perform any domain class initialisation logic
	// private void initialise(){
	// }
	
	/* Commented because the methods are dummy and are impacting the release due to the lack of coverage
	public void onAfterInsert(){
	}
	public void onAfterUpdate(Map<Id, User> oldRecordMap){
	}
	public void onAfterDelete(){
	}
	public void onAfterUndelete(){
	}*/

	public void onBeforeInsert(){
		try {
			preventInternalUserRegisteringAsExternal(null);
		} catch (Exception e) {
			throw new UserDomainException(e.getMessage());
		}
	}
	public void onBeforeUpdate(Map<Id, User> oldRecordMap){
		try {
			preventInternalUserRegisteringAsExternal(oldRecordMap);
		} catch (Exception e) {
			throw new UserDomainException(e.getMessage());
		}
	}

	/*Commented because the methods are dummy and are impacting the release due to the lack of coverage
	public void onBeforeDelete(){
	} */

	//return a 'default' User record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public List<User> createDefaultPortalUser(List<Contact> contactList){
		for(Integer x = 0; x < contactList.size(); x++){
			Contact contact = contactList.get(0);
			User user = (User) Schema.getGlobalDescribe().get('User').newSObject();
			String alias = contact.LastName.replaceAll(' ','_');
			user.Alias = alias.left(8);
			user.Email= contact.Email;
			user.UserName= alias + '@testorg.com';
			user.EmailEncodingKey='UTF-8';
			user.LastName=contact.LastName;
			user.LanguageLocaleKey='en_US';
			user.LocaleSidKey='en_US';
			user.ProfileId = DEFAULTPROFILE.Id;
			user.ContactId = contact.Id;
			user.IsActive = true;
			user.TimeZoneSidKey='America/Los_Angeles';
			records.add(user);
		}
		return records;
	}

	private void preventInternalUserRegisteringAsExternal(Map<Id, User> oldRecordMap){
		List<User> userList = new List<User>();
		//if oldRecordMap == null then isUpdate == false
		if(oldRecordMap == null){
			//only consider external users
			for(User user : records){
				if(user.ContactId != null)
					userList.add(user);
			}
		} else{
			//only consider external users
			for(User user : oldRecordMap.values()){
				if(user.ContactId != null)
					userList.add(user);
			}
		}

		//get list of disallowed domain names
		List<IATA_Email_Domain_Name__mdt> iataEmailDomainNameList = [SELECT MasterLabel FROM IATA_Email_Domain_Name__mdt WHERE Allowed_for_Portal_Users__c = FALSE];
		//create set for easy 'contains' check
		Set<String> disallowedEmailDomainSet = new Set<String>();
		for(IATA_Email_Domain_Name__mdt iataEmailDomainName : iataEmailDomainNameList){
			disallowedEmailDomainSet.add(iataEmailDomainName.MasterLabel);
		}

		if(userList != null && !userList.isEmpty()){
			for(User user : userList){
				String userEmailDomain = user.Email.substringAfterLast('@');
				if(disallowedEmailDomainSet.contains(userEmailDomain) || disallowedEmailDomainSet.contains(userEmailDomain.substringBeforeLast('.')))
					user.addError('Email Domain is disallowed');
			}
		}
	}

	public class UserDomainException extends Exception {}
}