public without sharing class DAL_WithoutSharing {

private static Id USERID = Userinfo.getUserId();

@AuraEnabled(cacheable=false)
public static String performCheckonPoll(String permSetSSO, Integer failedCount){
	List<PermissionSetAssignment> permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: USERID AND PermissionSetId IN (select id from PermissionSet Where name =: permSetSSO)];

	if(!permissionSetList.isEmpty()) {
		return 'Success';
	} else {
		List<UserProvisioningRequest> userProvisioningList = [SELECT id FROM UserProvisioningRequest WHERE SalesforceUserId =: USERID AND State = 'Failed'];
		if(userProvisioningList.size() != failedCount) {
			return 'Error';
		}
	}
	return 'Incomplete';
}

@AuraEnabled(cacheable=true)
public static Map<String, String> getUserOptions(String portalUser){

	Map<String,String> userOptions = new Map<String,String>();

	List<User> userContactAccountOptions = [SELECT id, Contact.Account.ANG_IEP_Status_FF__c, Contact.Authorized_Signatory__c,
	                                        Contact.User_Portal_Status__c, ContactId, Contact.Account.ICCS_Membership_Status__c,
	                                        Contact.Account.Top_Parent__r.ICCS_Membership_Status__c, Contact.Account.Top_Parent__c
	                                        FROM User WHERE Id =:portalUser];

	if(!userContactAccountOptions.isEmpty()) {
		for(User u : userContactAccountOptions) {
			if(u.Contact.Account.ANG_IEP_Status_FF__c != null) {
				userOptions.put('IEP_Status', u.Contact.Account.ANG_IEP_Status_FF__c);
			}
			if(u.Contact.Authorized_Signatory__c != null) {
				userOptions.put('Legal_Auth_Signature', String.valueOf(u.Contact.Authorized_Signatory__c));
			}
			if(u.Contact.User_Portal_Status__c != null  && u.Contact.User_Portal_Status__c != '') {
				userOptions.put('User_Portal_Status', u.Contact.User_Portal_Status__c);
			}
			if(u.ContactId != null) {
				userOptions.put('User_ContactId', u.ContactId);
			}
			if(u.Contact.Account.Top_Parent__c != null) {
				if(u.Contact.Account.Top_Parent__r.ICCS_Membership_Status__c == null) {
					userOptions.put('User_ICCS_Membership_Status', u.Contact.Account.ICCS_Membership_Status__c);
				}else if(u.Contact.Account.Top_Parent__r.ICCS_Membership_Status__c != null) {
					userOptions.put('User_ICCS_Membership_Status', u.Contact.Account.Top_Parent__r.ICCS_Membership_Status__c);
				}
			}
		}
	}
	return userOptions;
}

public static List<Contact> getContactsByAccountId(Id accountId, Integer offset, Integer batchSize){
	//Fetch all account branches/HQs to return a complete hierarchy of account's contacts.
	Map<Id,Account> allBranches = new Map<Id,Account>([select id from account where (id =: accountId or parentId=: accountId or top_parent__c =: accountId)
        and (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer'))]);

	List<Contact> contacts = [select Id, Name, FirstName, LastName, Title, Email, Phone, Fax, OtherPhone,Type_of_Contact__c,
	                          OtherCity, OtherStreet, OtherState,OtherPostalCode, OtherCountry, Function__c, Membership_Function__c,
	                          User_Portal_Status__c, MobilePhone, Preferred_Language__c,Salutation,Airline_Contact_Type__c, Services__c,
	                          Area__c,AccountId, Account.Name,IATA_Code__c,Account.Location_Type__c,Account.IATA_ISO_Country__r.Name,
                              Account_site__c, Account.RecordTypeId, Account.RecordType.Name, Account.BillingCity 
	                          from Contact where AccountId IN:allBranches.keySet() and Status__c = 'Active' ORDER BY Name ASC LIMIT:batchSize OFFSET :offset ];

	if(!contacts.isEmpty()) {
		return contacts;
	}

	return new List<Contact>();
}

public static List<Contact> searchContactsByAccountId(Id accountId, Integer offset, Integer batchSize, String queryString){
	String wildString = queryString +'%';

	//Fetch all account branches/HQs to return a complete hierarchy of account's contacts.
	Map<Id,Account> allBranches = new Map<Id,Account>([select id from account where (id =: accountId or parentId=: accountId or top_parent__c =: accountId)
        and (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer'))]);

	List<Contact> contacts = [select Id, Name, FirstName, LastName, Title, Email, Phone, Fax, OtherPhone,Type_of_Contact__c,
	                          OtherCity, OtherStreet, OtherState,OtherPostalCode, OtherCountry, Function__c, Membership_Function__c,
	                          User_Portal_Status__c, MobilePhone, Preferred_Language__c,Salutation,Airline_Contact_Type__c, Services__c,
	                          Area__c,AccountId, Account.Name,IATA_Code__c,Account.Location_Type__c,Account.IATA_ISO_Country__r.Name,Account.RecordTypeId,Account.RecordType.Name
	                          from Contact
	                          where AccountId IN:allBranches.keySet()
	                          and (FirstName LIKE :wildString OR LastName LIKE :wildString OR Name LIKE :wildString OR Email LIKE :wildString OR Name = :queryString)
                              and Status__c = 'Active'
	                          ORDER BY Name ASC LIMIT:batchSize OFFSET :offset ];

	if(!contacts.isEmpty()) {
		return contacts;
	}

	return new List<Contact>();
}
	  @AuraEnabled
    public static List<Account> getRelatedAccounts(String finalQuery){

	    return Database.query(finalQuery);
    }
}

	//returns user Information wihtout visibility control
	@AuraEnabled
	public static user getUserDetails(Id userId){
		return [select id,userRoleId, UserRole.Name from user where id=:userId];
	}

	@AuraEnabled
	public static void ActivateIEPUsers(List<String> contactIds){
	
		List<User> usersList = [select id, isActive, contactId from User where contactId in : contactIds];
		if(!usersList.isEmpty()) {
			List<User> usersToActivate = new List<User>();
	
			for(User user : usersList) {
				if(!user.isActive) {
					user.isActive = true;
					usersToActivate.add(user);
				}
			}
	
			if(usersToActivate.size() != 0) {
				update usersToActivate;
			}
		}
	
	}
}