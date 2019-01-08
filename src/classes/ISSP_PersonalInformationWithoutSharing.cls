public class ISSP_PersonalInformationWithoutSharing {
	
	ISSP_PersonalInformation theParentController { get; set; }
	public Contact theUserContact { get; set; }
	public String ifapName {get; set;}
    public String ifapEmail {get; set;}
	
	public ISSP_PersonalInformationWithoutSharing(ISSP_PersonalInformation parentController) {
		theParentController = parentController;
		theUserContact = theParentController.con;
		loadPortalAdmins(); 
	}
	
	public void loadPortalAdmins() {
        //TF - SP10-N1 - IFAP contact
        ifapName = '';
		ifapEmail = '';
    	if (theUserContact.User_Portal_Status__c == 'Approved Admin'){
			List <Contact> ifapList = [SELECT Id, Name, Email,
									(SELECT Id FROM Portal_Application_Rights__r
									WHERE Right__c = 'Access Granted'
									AND Portal_Application__r.Name = 'IFAP')
									FROM Contact WHERE AccountId = :theUserContact.AccountId];
			if (!ifapList.isEmpty()){
				for (Contact thisContact : ifapList){
					if (!thisContact.Portal_Application_Rights__r.isEmpty()){
						ifapName = thisContact.Name;
						ifapEmail = thisContact.Email;
						break;
					}
				}
			}
    	}
		
        if (theUserContact.User_Portal_Status__c != 'Active'
            && theUserContact.User_Portal_Status__c != 'Approved Admin' //WMO-386  
        	&& theUserContact.User_Portal_Status__c != 'Regional Administrator'
        	&& theUserContact.User_Portal_Status__c != 'Approved User'
        	&& theUserContact.User_Portal_Status__c != 'Pending Approval')
            return;
            
        //WMO-386  
        try {
        	String currentUserProfile ='';
            
            List<Id> accountIds = new List<Id> {theUserContact.AccountId, theUserContact.Account.ParentId};
            List<ISSP_PersonalInformation.UserWrapper> admins = getPortalAdminAndSuperUsers(accountIds);

            ISSP_Utilities.log(admins);

            for(ISSP_PersonalInformation.UserWrapper admin : admins) {
                if(theUserContact.Id == admin.contactId) {
                    if(String.isBlank(currentUserProfile)) {
                        currentUserProfile = admin.userRole;
                    } else if(currentUserProfile.contains('Portal Administrator')){
                        if(!admin.userRole.contains('Portal Administrator')) {
                            currentUserProfile = admin.userRole;
        			}
                    } else if(currentUserProfile.contains('Portal Regional Administrator')){
                        if(!admin.userRole.contains('Portal Administrator') && !admin.userRole.contains('Portal Regional Administrator')){
                            currentUserProfile = admin.userRole;
        				}
        			}
        				}
        			}

            for (ISSP_PersonalInformation.UserWrapper admin : admins) {
                if (admin.userRole.contains('Portal Administrator') || admin.userRole.contains('SIS Super User')) {
                    theParentController.listAdmins.add(admin);
        		}
        	}
        } catch (Exception e) {
            ISSP_Utilities.log(e);
        }
    }
    
    public static List<AccountTeamMember> getPortalAdmins(list<Id> accountIds) {
		
		list<AccountTeamMember> teamMembers = 
									[SELECT Id,
											UserId, 
											TeamMemberRole,
											User.Contact.Salutation, 
											User.Contact.Name, 
											User.Contact.Email,
											User.Contact.AccountId,
											User.Contact.Account.Name, 
											User.Contact.Account.BillingCountry
									   FROM AccountTeamMember 
									  WHERE accountId IN: accountIds 
									    AND (TeamMemberRole='Portal Administrator' 
									  	     OR TeamMemberRole='Portal Regional Administrator')];
				
		return teamMembers;
		
	}
	
    //WMO-386 - add SIS Super User to list of admin contacts
    public static List<ISSP_PersonalInformation.UserWrapper> getPortalAdminAndSuperUsers(List<Id> accountIds) {
        List<Contact> contacts = [SELECT Id, Name, Salutation, Email, Account.BillingCountry, AccountId
                                  FROM Contact
                                  WHERE AccountId IN :accountIds AND SIS_Contact_Type__c = 'Super User' AND
                                    Status__c = 'Active' AND Account.SIS_Status__c = 'Active'];

        Set<String> roles = new Set<String> {'Portal Administrator', 'Portal Regional Administrator'};
        List<AccountTeamMember> members = [SELECT Id, UserId, TeamMemberRole, User.ContactId, User.Contact.Salutation,
                                                User.Contact.Name, User.Contact.Email, User.Contact.AccountId,
                                                User.Contact.Account.Name, User.Contact.Account.BillingCountry, AccountId
                                           FROM AccountTeamMember
                                           WHERE AccountId IN :accountIds AND TeamMemberRole IN :roles];

        Map<Id,ISSP_PersonalInformation.UserWrapper> mapContacts = new Map<Id,ISSP_PersonalInformation.UserWrapper>();
        for(AccountTeamMember member : members) {
            ISSP_PersonalInformation.UserWrapper uw = new ISSP_PersonalInformation.UserWrapper(member.User.Contact.Salutation, member.User.Contact.Name, 
                member.User.Contact.Email, member.User.Contact.Account.BillingCountry, member.TeamMemberRole, member.User.Contact.AccountId, member.User.ContactId);
            mapContacts.put(member.User.ContactId, uw);
        }

        for(Contact c : contacts) {
            ISSP_PersonalInformation.UserWrapper uw = mapContacts.get(c.Id);
            if(uw == null) {
                uw = new ISSP_PersonalInformation.UserWrapper(c.Salutation, c.Name, c.Email, c.Account.BillingCountry, 'SIS Super User', c.AccountId, c.Id);
                mapContacts.put(c.Id, uw);
            } else {
                uw.userRole += 'and SIS Super User';
            }
        }

        return mapContacts.values();
    }
}