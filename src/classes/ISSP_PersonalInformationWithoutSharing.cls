public without sharing class ISSP_PersonalInformationWithoutSharing {
	
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
        	&& theUserContact.User_Portal_Status__c != 'Regional Administrator'
        	&& theUserContact.User_Portal_Status__c != 'Approved User'
        	&& theUserContact.User_Portal_Status__c != 'Pending Approval')
            return;
            
        try {
        	String currentUserProfile ='';
        	theParentController.portalAdminMap = new map<ID, AccountTeamMember>();
            List<AccountTeamMember> teamMembers = getPortalAdmins(new ID[] {theUserContact.AccountId, theUserContact.Account.ParentId});
            ISSP_Utilities.log(teamMembers);
            
        	for (AccountTeamMember teamMember : teamMembers) {
        		if(theUserContact.Id == teamMember.User.ContactId){
        			if(currentUserProfile == ''){
        				currentUserProfile = teamMember.TeamMemberRole;
        			}
        			else if(currentUserProfile == 'Portal Administrator'){
        				if(teamMember.TeamMemberRole != 'Portal Administrator' ){
        					currentUserProfile = teamMember.TeamMemberRole;
        				}
        			}
        			else if(currentUserProfile == 'Portal Regional Administrator'){
        				if(teamMember.TeamMemberRole != 'Portal Administrator' && teamMember.TeamMemberRole != 'Portal Regional Administrator'){
        					currentUserProfile = teamMember.TeamMemberRole;
        				}
        			}
        		}
        	}
        	/*
        	for (AccountTeamMember teamMember : teamMembers) {
        		if(theUserContact.Id == teamMember.User.ContactId){
        			if(currentUserProfile == ''
        			   || (currentUserProfile == 'Portal Administrator' && teamMember.TeamMemberRole != 'Portal Administrator')
        			   || (currentUserProfile == 'Portal Regional Administrator' && teamMember.TeamMemberRole != 'Portal Administrator' && teamMember.TeamMemberRole != 'Portal Regional Administrator')	
        			  )
        			{
        				currentUserProfile = teamMember.TeamMemberRole;
        			}
        		}
        	}
        	*/
            // fill admins contacts lists
            for (AccountTeamMember teamMember : teamMembers) {
            	if(currentUserProfile == '' || currentUserProfile == 'Manager' || currentUserProfile == 'Collaborator' ){
            		if(teamMember.TeamMemberRole == 'Portal Regional Administrator'){
            			theParentController.portalAdminMap.put(teamMember.User.ContactId, teamMember);
            		}
            	}
            }
            if (theParentController.portalAdminMap.size()==0) {
            	for (AccountTeamMember teamMember : teamMembers) {
            		if (teamMember.TeamMemberRole == 'Portal Administrator'){
            			theParentController.portalAdminMap.put(teamMember.User.ContactId, teamMember);
            		}
            	}
            } 
           
            theParentController.portalAdmins = theParentController.portalAdminMap.values(); 
            
        } catch (Exception e) {
            ISSP_Utilities.log(e);
        }
    }
    
    public static List<AccountTeamMember> getPortalAdmins(list<Id> accountIds) {
		
		list<AccountTeamMember> teamMembers = 
									[SELECT Id,
											UserId, 
											TeamMemberRole,
											User.Contact.User_Portal_Status__c,
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
	
}