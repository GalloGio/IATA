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
	                          from Contact where AccountId IN:allBranches.keySet() and Status__c = 'Active' AND User_Portal_Status__c IN ('Pending Approval', 'Approved Admin', 'Approved User', '') 
							  ORDER BY SortingOrder__c LIMIT:batchSize OFFSET :offset ];

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
	
	/* 
    * @description Return if a specific user has Access to a specific service
    * @return boolean 
    */
	
    @AuraEnabled
    public static Boolean hasAccessToService(string str,string conId) {       
		if(conId==null) conId=CSP_Utils.getLoggedUser().contactId; // if conId, checks current user
        return [select id from Portal_Application_Right__c where Contact__c =:conId and Right__c ='Access Granted' and Application_Name__c like :str limit 1].size()>0;
    }
	
	/*
    *   Wrapper class for returning database operations success / unsuccess
    */
    public class ReturnWrapper {
        @AuraEnabled
        public Boolean success {get; set;}
        @AuraEnabled
        public String returnMessage {get; set;}
        @AuraEnabled
        public String extraDetails {get; set;}

        public ReturnWrapper(){}

        public ReturnWrapper(Boolean successAux, String returnMessageAux, String extraDetailsAux){
            this.success = successAux;
            this.returnMessage = returnMessageAux;
            this.extraDetails = extraDetailsAux;
        }
    }

	/*
    * Method that adds a new Recipient for this case
    */
    @AuraEnabled
    public static ReturnWrapper addNewRecipient(String caseId, String newRecipientEmail){
        ReturnWrapper returnWrapper = new ReturnWrapper();

        String findEmail = newRecipientEmail.trim();
        
        if (findEmail == null || findEmail == ''){
            returnWrapper.success = false;
            returnWrapper.returnMessage = 'No email was provided. ';
            return returnWrapper;
        }

        // find contact with input email
        list<Contact> listContact = [SELECT Id, Email, AccountId FROM Contact WHERE Email = :findEmail AND Status__c = 'Active' LIMIT 1];
        if (listContact.size() != 1) {
            returnWrapper.success = false;
            returnWrapper.returnMessage = Label.ISSP_CCOther_Wrong_Emails.replace('{0}',findEmail);
            return returnWrapper;
        }

        Boolean isDPCUser = false;
        Id profileId = Userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        //Verify if user is a PWC profile
        if (profileName.startsWith('ISS Portal DPC Admin') ) {  isDPCUser = true; }

        //get partner user role id
        Id PARTNER_USER_ROLE = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role'].Id;

        //get the case
        Case caseAux = PortalCasesCtrl.getCaseById(caseId);

        // insert found contact as a team member of the case
        Savepoint sp = Database.setSavepoint();
        try {
            Contact contact = listContact.get(0);
            Id memberId = contact.Id;
            if(isDPCUser) {
                // only add people from Account_Concerned__c by User
                list<User> listUser = [
                    SELECT Id, Contact.AccountId
                    FROM User
                    WHERE ContactId = :contact.Id AND isActive = true AND Contact.AccountId = :caseAux.Account_Concerned__c AND Contact.User_Portal_Status__c IN ('Approved Admin', 'Approved User') ];
                if (!listUser.isEmpty()) {
                    memberId = listUser[0].Id;
                } else {
                    if (contact.AccountId != caseAux.Account_Concerned__c){
                        //if it's DPC, a user is not found and the selected contact is not in the
                        //same Account Concerned then we cannot continue

                        returnWrapper.success = false;
                        returnWrapper.returnMessage = 'User is now in the same account concerned';
                        return returnWrapper;
                    }
                }
            }
            CaseTeamMember teammember = new CaseTeamMember(ParentId = caseAux.Id, MemberId = memberId, TeamRoleId = PARTNER_USER_ROLE);
            System.debug(teammember);
            insert teammember;
            
            if(caseAux.E2CP__AdditionalCC__c != null && caseAux.E2CP__AdditionalCC__c != ''){
                caseAux.E2CP__AdditionalCC__c =  caseAux.E2CP__AdditionalCC__c + ';' + contact.Email;
            }else{
                caseAux.E2CP__AdditionalCC__c = contact.Email;
            }
            update caseAux;

            returnWrapper.success = true;
            returnWrapper.returnMessage = 'Recipient added with success!';

        } catch (DMLException e) {
            String messages = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                messages += ' ' + findemail + ': ' + e.getDmlMessage(i);
            }
            Database.rollback(sp);

            returnWrapper.success = false;
            returnWrapper.returnMessage = messages;
        }

        return returnWrapper;
    }

	/*
    * Method that removes a recipient from this case
    */
    @AuraEnabled
    public static ReturnWrapper removeRecipient(String caseId, String recipientEmail){
        ReturnWrapper returnWrapper = new ReturnWrapper();

        String emailFiltered = recipientEmail==null ? '': recipientEmail.trim();

        Case caseAux = PortalCasesCtrl.getCaseById(caseId);

        Savepoint sp = Database.setSavepoint();
        try {
            List<String> listNews = new List<String>();
            for (String email: caseAux.E2CP__AdditionalCC__c.split(';')) {
                String trimEmail = email.trim();
                if (trimEmail != emailFiltered) {
                    listNews.add(trimEmail);
                }
            }
            caseAux.E2CP__AdditionalCC__c = (String.join(listNews,';'));
            
            update caseAux;

            //get partner user role id
            Id PARTNER_USER_ROLE = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role'].Id;

            list<Contact> listContact = [SELECT Id, AccountId FROM Contact WHERE email = :emailFiltered];
            list<User> listUser = [SELECT Id, Contact.AccountId FROM User WHERE email = :emailFiltered];
            list<CaseTeamMember> listMember = [SELECT id FROM CaseTeamMember
                WHERE ParentId = :caseId AND TeamRoleId = :PARTNER_USER_ROLE AND (MemberId IN :listContact OR MemberId IN :listUser)];
            if (!listMember.isEmpty()) {
                delete listMember;
            }

            returnWrapper.success = true;
            returnWrapper.returnMessage = 'Recipient removed with success!';

        } catch (DMLException e) {
            System.debug('ERROR delTeamMember ' + e.getMessage());
            
            String messages = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                messages += ' ' + emailFiltered + ': ' + e.getDmlMessage(i);
            }
            Database.rollback(sp);

            returnWrapper.success = false;
            returnWrapper.returnMessage = messages;
        }

        return returnWrapper;
    }
}
