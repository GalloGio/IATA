public without sharing class ISSP_UserTriggerHandler {
    
    public static Boolean preventTrigger = false;
    public static Boolean preventOtherTrigger = false;
    public static Boolean preventSISIntegration = false;
    public static void onBeforeInsert(list<User> newUserList, map<Id, User> newUserMap) {
        setPortalUserName(newUserList);
    }
    
    public static void onBeforeUpdate(list<User> newUserList, map<Id, User> newUserMap, list<User> oldUserList, map<Id, User> oldUserMap) {
        //TF - SP9-A5
        Set <Id> contactIdSet = new Set <Id>();
        Set <Id> contactKaviAdd = new Set <Id>();

        for(User oneUser: newUserList) {
        	
            if (oldUserMap.containsKey(oneUser.Id)){
                if (oneUser.Email != oldUserMap.get(oneUser.Id).Email){
                    oneUser.ISSP_Old_Email__c = oldUserMap.get(oneUser.Id).Email;
                }
            }

			if(oldUserMap.get(oneUser.Id).Username != oneUser.Username ||
               oldUserMap.get(oneUser.Id).Phone != oneUser.Phone ||
               oldUserMap.get(oneUser.Id).Fax != oneUser.Fax ||
               oldUserMap.get(oneUser.Id).City != oneUser.City ||
               oldUserMap.get(oneUser.Id).State != oneUser.State ||
               oldUserMap.get(oneUser.Id).Country != oneUser.Country ||
               oldUserMap.get(oneUser.Id).Postalcode != oneUser.Postalcode ||
               oldUserMap.get(oneUser.Id).Mobilephone != oneUser.Mobilephone ||
               oldUserMap.get(oneUser.Id).Street != oneUser.Street){
              
               if(oneUser.contactId != null){
                 contactIdSet.add(oneUser.contactId);
               }
               
               //Code added to consider Kavi internal users
               if(oneUser.ContactKaviId__c != null){
                   contactIdSet.add(oneUser.ContactKaviId__c);
               }
               
            }
        }

        List <Portal_Application_Right__c> appRightList = [SELECT Id, Contact__c FROM Portal_Application_Right__c
                            WHERE Application_Name__c = 'Standards Setting Workspace'
                            AND Right__c = 'Access Granted'
                            AND Contact__c IN :contactIdSet];
         
		for(Portal_Application_Right__c thisRecord : appRightList){
			contactKaviAdd.add(thisRecord.Contact__c);
        }
        
        if(contactKaviAdd.size() > 0){
            HigherLogicIntegrationHelper.pushPersonCompanyMembers('update', contactKaviAdd);
        }
        
        setPortalUserName(newUserList);
    }

    public static void setPortalUserName(list<User> newUserList) {
        
        Set<Id> profileIDs = new Set<ID>();
        Map <Id, String> contactEmailMap = new Map <Id, String>();//TF - SP9-A5
        Set <Id> contactIdSet = new Set <Id>();//TF - SP9-A5
        for(User oneUser: newUserList) {
            if(String.isBlank(oneUser.Email) || !profileByPartnerCommunityLicense.containsKey(oneUser.ProfileId) || !oneUser.isActive ) 
                continue;
                
            oneUser.Username = ISSP_Utilities.buildPortalUserName(oneUser.Email);
            
            //TF - SP9-A5
            if (oneUser.ContactId != null){
                contactEmailMap.put(oneUser.ContactId, oneUser.Email);
                contactIdSet.add(oneUser.ContactId);
            }
            //Code added to consider Internal Users also
            if (oneUser.ContactKaviId__c != null){
                contactEmailMap.put(oneUser.ContactKaviId__c, oneUser.Email);
                contactIdSet.add(oneUser.ContactKaviId__c);
            }

        }
        
        //TF - SP9-A5
        if (!contactEmailMap.isEmpty()){
            system.debug('Will update contact');
            updateContacts(contactEmailMap, contactIdSet);
        }
    }
    
    public static map<ID, Profile> profileByPartnerCommunityLicense {
        get { 
            if(null == profileByPartnerCommunityLicense)
                profileByPartnerCommunityLicense = getProfileByPartnerCommunityLicense();
            return profileByPartnerCommunityLicense;
        }
        set;
    } 
    
    public static map<ID, Profile> getProfileByPartnerCommunityLicense() {
        return new map<ID, Profile> ( 
                        [SELECT Id, Name, 
                                UserLicenseId, 
                                UserLicense.Name  
                           FROM Profile
                          WHERE (UserLicense.Name =: ENV.Partner_Community OR UserLicense.Name =: ENV.Identity)]); 
    }
    
    //TF - SP9-A5
    public static void updateContacts (Map <Id, String> contactEmailMap, Set <Id> contactIdSet ) {
        List <Contact> contactList = [SELECT Id, Email FROM Contact WHERE Id IN : contactIdSet];
        List <Contact> updateContactList = new List <Contact>();
        if (!contactList.isEmpty()){
            for (Contact thisContact : contactList){
                if (contactEmailMap.containsKey(thisContact.Id)){
                    if (thisContact.Email != contactEmailMap.get(thisContact.Id)){
                        thisContact.Email = contactEmailMap.get(thisContact.Id);
                        updateContactList.add(thisContact);
                    }
                }
            }
        }
        if (!updateContactList.isEmpty()){
            system.debug('Updating contacts from future: ' + updateContactList.size());
            preventTrigger = true;
            update updateContactList;
        }
    }
    
    //TF - SP9-A5
    public static void changeEmailFromContact (Map<Id, String> conEmailMap, Map<Id, String> conFirstNameMap, Map<Id, String> conLastNameMap, Set<Id> conEmailIdSet){
        system.debug('In ISSP_UserTriggerHandler.changeEmailFromContact');
        
        List <User> userList = [SELECT Id, Email, ContactId FROM User WHERE ContactId IN :conEmailIdSet];
        List <User> updateUserList = new List <User>();
        if (!userList.isEmpty()){
            for (User thisUser : userList){
                if (conEmailMap.containsKey(thisUser.ContactId)){
                    if (thisUser.Email != conEmailMap.get(thisUser.ContactId)){
                        thisUser.Email = conEmailMap.get(thisUser.ContactId);
                        updateUserList.add(thisUser);
                    }
                }
            }
        }

        //Code extension to consider also Kavi internal users
        List <User> userList2 = [SELECT Id, Email, ContactKaviId__c FROM User WHERE ContactKaviId__c IN :conEmailIdSet];
        //List <User> updateUserList = new List <User>();
        if (!userList2.isEmpty()){
            for (User thisUser : userList2){
                if (conEmailMap.containsKey(thisUser.ContactKaviId__c)){
                    if (thisUser.Email != conEmailMap.get(thisUser.ContactKaviId__c)){
                        thisUser.Email = conEmailMap.get(thisUser.ContactKaviId__c);
                        updateUserList.add(thisUser);
                    }
                }
            }
        }
        //End of Extension
        if (!updateUserList.isEmpty()){
            system.debug('Will update user: ' + updateUserList.size());
            update updateUserList;
        }
        
        // JT - Check for SIS updates
        Boolean callSIS = ISSP_WS_SIS_Callout_Common.SIS_CALLOUTS_ENABLED && !preventSISIntegration;
        system.debug('CALLING WEB SERVICE: ' + callSIS);
        if (callSIS) {
            List <Portal_Application_Right__c> appRightList = [
                SELECT Id, Contact__c FROM Portal_Application_Right__c
                WHERE Application_Name__c = 'SIS'
                AND Right__c = 'Access Granted'
                AND Contact__c IN :conEmailIdSet];

            if (!appRightList.isEmpty()) {
                list<Id> listContactId = new list<Id>();
                for (Portal_Application_Right__c thisRecord : appRightList){
                    listContactId.add(thisRecord.Contact__c);
                }
                ISSP_WS_Utilities.invokeSisModifyUser(listContactId);
            }
        }
    }
    
    public static void calloutSIS_ActivateDeactivateUsers(Set<Id> contactIdAddSet, Set<Id> contactRemoveIdSet){
        Boolean callSIS = ISSP_WS_SIS_Callout_Common.SIS_CALLOUTS_ENABLED && !preventSISIntegration;
        if (callSIS) {
            if (!contactIdAddSet.isEmpty()) {
                ISSP_WS_Utilities.invokeSisActivateUsers(new list<Id>(contactIdAddSet));
            }
            if (!contactRemoveIdSet.isEmpty()) {
                ISSP_WS_Utilities.invokeSisDeactivateUsers(new list<Id>(contactRemoveIdSet));
            }
        }
    }
    
    @future
    public static void updateSIS_permissionSet(Set<Id> contactIdSet, Set<Id> contactRemoveIdSet){
        system.debug('FUTURE METHOD, ADD: ' + contactIdSet);
        system.debug('FUTURE METHOD, REMOVE: ' + contactRemoveIdSet);
        String permissionSetId = '';
        List <PermissionSet> setList = [SELECT Id FROM PermissionSet WHERE Name = 'ISS_Portal_Permission_Set_SIS_users'];
        if (!setList.isEmpty()){
            permissionSetId = setList[0].Id;
        }
        if (permissionSetId != ''){
            if (!contactIdSet.isEmpty()){
                List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIdSet AND IsActive = true];
                Set <Id> userSetId = new Set <Id>();
                Map <Id, Id> userMap = new Map <Id, Id>(); 
                if (!userList.isEmpty()){
                    for (User thisUser : userList){
                        userSetId.add(thisUser.Id);
                        userMap.put(thisUser.Id, thisUser.Id);
                    }
                    List <PermissionSetAssignment> assignmentList = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                                                                    WHERE AssigneeId IN :userSetId
                                                                    AND PermissionSetId = :permissionSetId];
                    if (!assignmentList.isEmpty()){
                        for (PermissionSetAssignment thisAssignment : assignmentList){
                            if (userMap.containsKey(thisAssignment.AssigneeId)){
                                userMap.remove(thisAssignment.AssigneeId);
                            }
                        }
                    }
                    if (!userMap.isEmpty()){
                        List <PermissionSetAssignment> newPermissionList = new List <PermissionSetAssignment>();
                        List <Id> idList = userMap.values();
                        for (Id thisId : idList){
                            PermissionSetAssignment newPermission = new PermissionSetAssignment();
                            newPermission.AssigneeId = thisId;
                            newPermission.PermissionSetId = permissionSetId;
                            newPermissionList.add(newPermission);
                        }
                        insert newPermissionList;
                    }
                }
            }
            if (!contactRemoveIdSet.isEmpty()){
                List <User> userListRemove = [SELECT Id FROM User WHERE ContactId IN :contactRemoveIdSet AND IsActive = true];
                Set <Id> userSetIdRemove = new Set <Id>(); 
                if (!userListRemove.isEmpty()){
                    for (User thisUser : userListRemove){
                        userSetIdRemove.add(thisUser.Id);
                    }
                    List <PermissionSetAssignment> assignmentListRemove = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                                                                    WHERE AssigneeId IN :userSetIdRemove
                                                                    AND PermissionSetId = :permissionSetId];
                    if (!assignmentListRemove.isEmpty()){
                        delete assignmentListRemove;
                    }

                }
            }
        }
    }

    @future
    public static void updateUserPermissionSet(String permisionSetName, Set<Id> contactIdSet, Set<Id> contactRemoveIdSet){
        system.debug('FUTURE METHOD, ADD: ' + contactIdSet);
        system.debug('FUTURE METHOD, REMOVE: ' + contactRemoveIdSet);
        String permissionSetId = '';
        List <PermissionSet> setList = [SELECT Id FROM PermissionSet WHERE Name = :permisionSetName];
        if (!setList.isEmpty()){
            permissionSetId = setList[0].Id;
        }
        if (permissionSetId != ''){
            if (!contactIdSet.isEmpty()){
                List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIdSet AND IsActive = true];
                Set <Id> userSetId = new Set <Id>();
                Map <Id, Id> userMap = new Map <Id, Id>(); 
                if (!userList.isEmpty()){
                    for (User thisUser : userList){
                        userSetId.add(thisUser.Id);
                        userMap.put(thisUser.Id, thisUser.Id);
                    }
                    List <PermissionSetAssignment> assignmentList = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                                                                    WHERE AssigneeId IN :userSetId
                                                                    AND PermissionSetId = :permissionSetId];
                    if (!assignmentList.isEmpty()){
                        for (PermissionSetAssignment thisAssignment : assignmentList){
                            if (userMap.containsKey(thisAssignment.AssigneeId)){
                                userMap.remove(thisAssignment.AssigneeId);
                            }
                        }
                    }
                    if (!userMap.isEmpty()){
                        List <PermissionSetAssignment> newPermissionList = new List <PermissionSetAssignment>();
                        List <Id> idList = userMap.values();
                        for (Id thisId : idList){
                            PermissionSetAssignment newPermission = new PermissionSetAssignment();
                            newPermission.AssigneeId = thisId;
                            newPermission.PermissionSetId = permissionSetId;
                            newPermissionList.add(newPermission);
                        }
                        insert newPermissionList;
                    }
                }
            }
            if (!contactRemoveIdSet.isEmpty()){
                List <User> userListRemove = [SELECT Id FROM User WHERE ContactId IN :contactRemoveIdSet AND IsActive = true];
                Set <Id> userSetIdRemove = new Set <Id>(); 
                if (!userListRemove.isEmpty()){
                    for (User thisUser : userListRemove){
                        userSetIdRemove.add(thisUser.Id);
                    }
                    List <PermissionSetAssignment> assignmentListRemove = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                                                                    WHERE AssigneeId IN :userSetIdRemove
                                                                    AND PermissionSetId = :permissionSetId];
                    if (!assignmentListRemove.isEmpty()){
                        delete assignmentListRemove;
                    }

                }
            }
        }
    }
    
	@future
  	public static void deleteTwoFactor(Set<Id> contactRemove2FAIdSet){
    	List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactRemove2FAIdSet];
    	if (!userList.isEmpty()){
      		Set <Id> userIds = new Set<Id>();
      		for (User thisUser : userList){
        		userIds.add(thisUser.Id);
      		}
        	List <TwoFactorInfo> tfList = [SELECT Id FROM TwoFactorInfo WHERE UserId IN :userIds];
        	if (!tfList.isEmpty())
    			delete tfList;
    		
    		// Remove TD permission set
    		List <PermissionSet> psList = [SELECT Id FROM PermissionSet
    									WHERE Name IN ('ISSP_Treasury_Dashboard_Premium', 'ISSP_Treasury_Dashboard_Basic')];
			Set <Id> psListIds = new Set <Id>();
			for (PermissionSet thisSet : psList){
				psListIds.add(thisSet.Id);
			}
    		List <PermissionSetAssignment> psAssList = [SELECT Id FROM PermissionSetAssignment
    									WHERE AssigneeId IN :userIds AND PermissionSetId IN :psListIds];
        	if (!psAssList.isEmpty())
    			delete psAssList;
        }
		//removeNonTdReportSharing(contactRemove2FAIdSet);
  	}
  	
  	@future
  	public static void updateFederation(Map<Id, String> contactMap){
  		Set <Id> fedIdSet = new Set <Id>();
  		Set <Id> userIdSet = new Set <Id>();
  		Set <Id> contactFedIdSet = contactMap.keySet();
		List <User> userList = [SELECT Id, ContactId, FederationIdentifier, FedContactId__c FROM User WHERE ContactId IN :contactFedIdSet];
		if (!userList.isEmpty()){
			for (User thisUser : userList){
				userIdSet.add(thisUser.Id);
				thisUser.FederationIdentifier = thisUser.FedContactId__c;
				fedIdSet.add(thisUser.FedContactId__c);
			}
			List <User> duplicateUserList = [SELECT Id, FederationIdentifier FROM User WHERE FederationIdentifier IN :fedIdSet];
			if (!duplicateUserList.isEmpty()){
				for (User thisUser : duplicateUserList){
					thisUser.FederationIdentifier = '';
				}
				update duplicateUserList;
			}
			update userList;
			
			// NonTD report sharing
			//addNonTdReportSharing(contactFedIdSet);
			
			// Remove TD permission set
			List <PermissionSet> psList = [SELECT Id, Name FROM PermissionSet
										WHERE Name IN ('ISSP_Treasury_Dashboard_Premium', 'ISSP_Treasury_Dashboard_Basic')];
			Map <String, Id> permissionSetMap = new Map <String, Id>();
			Set <Id> psListIds = new Set <Id>();
			for (PermissionSet thisSet : psList){
				psListIds.add(thisSet.Id);
				permissionSetMap.put(thisSet.Name, thisSet.Id);
			}
			List <PermissionSetAssignment> psAssList = [SELECT Id FROM PermissionSetAssignment
										WHERE AssigneeId IN :userIdSet AND PermissionSetId IN :psListIds];
	    	if (!psAssList.isEmpty())
				delete psAssList;
			// Give correct TD permission set
			List <PermissionSetAssignment> assignList = new List <PermissionSetAssignment>();
			for (User thisUser : userList){
				if (contactMap.containsKey(thisUser.ContactId)){
					if (permissionSetMap.containsKey(contactMap.get(thisUser.ContactId))){
						PermissionSetAssignment newAssign = new PermissionSetAssignment();
						newAssign.AssigneeId = thisUser.Id;
                    	newAssign.PermissionSetId = permissionSetMap.get(contactMap.get(thisUser.ContactId));
                    	assignList.add(newAssign);
					}
				}
			}
			if (!assignList.isEmpty()){
				insert assignList;
			}
		}
		
  	}
  /*
  @future
  public static void addBaggageSharing(Set<Id> contactIds){
  	Set <Id> accountIds = new Set <Id>(); // affected accounts
  	Map <Id, Id> accountMap = new Map <Id, Id>();
  	// affected contacts
  	List <Contact> contactList = [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE Id IN :contactIds];
  	for (Contact thisContact : contactList){
  		if (!accountMap.containsKey(thisContact.AccountId)){
  			accountMap.put(thisContact.AccountId, thisContact.AccountId);
  			accountIds.add(thisContact.AccountId);
  		}
  		if (thisContact.Account.Top_Parent__c != null && thisContact.Account.Top_Parent__c != ''){
  			if (!accountMap.containsKey(thisContact.Account.Top_Parent__c)){
	  			accountMap.put(thisContact.Account.Top_Parent__c, thisContact.Account.Top_Parent__c);
	  			accountIds.add(thisContact.Account.Top_Parent__c);
	  		}
  		}
  	}
  	// with the account list, we'll retrieve all records to share
  	List <PIR_Form__c> formList = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM PIR_Form__c 
  								WHERE Airline_issuing__c IN :accountIds];
  	List <Baggage_Claim__c> claimList = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM Baggage_Claim__c
  								WHERE Parent_PIR_Form__r.Airline_issuing__c IN :accountIds];
	List <Baggage_Claim__c> claimListRO = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM Baggage_Claim__c
  								WHERE Airline_receiving__c IN :accountIds];
  	List <Baggage_Claim_Comment__c> commentList = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM Baggage_Claim_Comment__c
  								WHERE Baggage_Claim__r.Parent_PIR_Form__r.Airline_issuing__c IN :accountIds
  								OR Baggage_Claim__r.Airline_receiving__c IN :accountIds];
  	
  	// lists to handle inserts
  	List <PIR_Form__Share> formShareListAdd = new List <PIR_Form__Share>();
  	List <Baggage_Claim__Share> claimShareListAdd = new List <Baggage_Claim__Share>();
  	List <Baggage_Claim_Comment__Share> commentShareListAdd = new List <Baggage_Claim_Comment__Share>();
  	
  	// users related to affected contacts
	List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIds];
	for (User thisUser : userList){
		
		// handle PIR_Form__c sharing
		for (PIR_Form__c thisForm : formList){
			Boolean addNewForm = true;
			for (PIR_Form__Share thisShare : thisForm.Shares){
				if (thisShare.UserOrGroupId == thisUser.Id){
					addNewForm = false;
				}
			}
			if (addNewForm){
				PIR_Form__Share newFormShare = new PIR_Form__Share();
    			newFormShare.AccessLevel = 'Edit';
    			newFormShare.ParentId = thisForm.Id;
    			newFormShare.UserOrGroupId = thisUser.Id;
    			formShareListAdd.add(newFormShare);
			}
		}
		
		// handle Baggage_Claim__c sharing
		for (Baggage_Claim__c thisClaim : claimList){
			Boolean addNewClaim = true;
			for (Baggage_Claim__Share thisShare : thisClaim.Shares){
				if (thisShare.UserOrGroupId == thisUser.Id){
					addNewClaim = false;
				}
			}
			if (addNewClaim){
				Baggage_Claim__Share newClaimShare = new Baggage_Claim__Share();
    		 	newClaimShare.AccessLevel = 'Edit';
    			newClaimShare.ParentId = thisClaim.Id;
    			newClaimShare.UserOrGroupId = thisUser.Id;
    			claimShareListAdd.add(newClaimShare);
			}
		}
		
		// handle Baggage_Claim__c sharing RO
		for (Baggage_Claim__c thisClaim : claimListRO){
			Boolean addNewClaim = true;
			for (Baggage_Claim__Share thisShare : thisClaim.Shares){
				if (thisShare.UserOrGroupId == thisUser.Id){
					addNewClaim = false;
				}
			}
			if (addNewClaim){
				Baggage_Claim__Share newClaimShare = new Baggage_Claim__Share();
    			newClaimShare.AccessLevel = 'Read';
    			newClaimShare.ParentId = thisClaim.Id;
    			newClaimShare.UserOrGroupId = thisUser.Id;
    			claimShareListAdd.add(newClaimShare);
			}
		}
		
		// handle PIR_Form__c sharing
		for (Baggage_Claim_Comment__c thisComment : commentList){
			Boolean addNewComment = true;
			for (Baggage_Claim_Comment__Share thisShare : thisComment.Shares){
				if (thisShare.UserOrGroupId == thisUser.Id){
					addNewComment = false;
				}
			}
			if (addNewComment){
				Baggage_Claim_Comment__Share newCommentShare = new Baggage_Claim_Comment__Share();
    			newCommentShare.AccessLevel = 'Read';
    			newCommentShare.ParentId = thisComment.Id;
    			newCommentShare.UserOrGroupId = thisUser.Id;
    			commentShareListAdd.add(newCommentShare);
			}
		}
	}
	if (!formShareListAdd.isEmpty()){
		insert formShareListAdd;
	}
	if (!claimShareListAdd.isEmpty()){
		insert claimShareListAdd;
	}
	if (!commentShareListAdd.isEmpty()){
		insert commentShareListAdd;
	}
	
  }
  
  @future
  public static void giveBaggagePermissionSet(Set<Id> contactIds){
	String permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Baggage_Claim_Permission'].Id;
	Set <Id> userSetId = new Set <Id>();
  	Map <Id, Id> userMap = new Map <Id, Id>();
  	List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIds];
	for (User thisUser : userList){
		userSetId.add(thisUser.Id);
		userMap.put(thisUser.Id, thisUser.Id);
	}
	if (permissionSetId != null && permissionSetId != ''){
		List <PermissionSetAssignment> assignmentList = [SELECT Id, AssigneeId FROM PermissionSetAssignment
	                                                    WHERE AssigneeId IN :userSetId
	                                                    AND PermissionSetId = :permissionSetId];
	    if (!assignmentList.isEmpty()){
	        for (PermissionSetAssignment thisAssignment : assignmentList){
	            if (userMap.containsKey(thisAssignment.AssigneeId)){
	                userMap.remove(thisAssignment.AssigneeId);
	            }
	        }
	    }
	    if (!userMap.isEmpty()){
	        List <PermissionSetAssignment> newPermissionList = new List <PermissionSetAssignment>();
	        List <Id> idList = userMap.values();
	        for (Id thisId : idList){
	            PermissionSetAssignment newPermission = new PermissionSetAssignment();
	            newPermission.AssigneeId = thisId;
	            newPermission.PermissionSetId = permissionSetId;
	            newPermissionList.add(newPermission);
	        }
	        insert newPermissionList;
	    }
	}
  }
  
  @future
  public static void removeBaggageSharing(Set<Id> contactIds){
    Set <Id> accountIds = new Set <Id>(); // affected accounts
  	Map <Id, Id> accountMap = new Map <Id, Id>();
  	// affected contacts
  	List <Contact> contactList = [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE Id IN :contactIds];
  	for (Contact thisContact : contactList){
  		if (!accountMap.containsKey(thisContact.AccountId)){
  			accountMap.put(thisContact.AccountId, thisContact.AccountId);
  			accountIds.add(thisContact.AccountId);
  		}
  		if (thisContact.Account.Top_Parent__c != null && thisContact.Account.Top_Parent__c != ''){
  			if (!accountMap.containsKey(thisContact.Account.Top_Parent__c)){
	  			accountMap.put(thisContact.Account.Top_Parent__c, thisContact.Account.Top_Parent__c);
	  			accountIds.add(thisContact.Account.Top_Parent__c);
	  		}
  		}
  	}
  	
  	// with the account list, we'll retrieve all records to remove sharing
  	List <PIR_Form__c> formList = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM PIR_Form__c 
  								WHERE Airline_issuing__c IN :accountIds];
  	List <Baggage_Claim__c> claimList = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM Baggage_Claim__c
  								WHERE Parent_PIR_Form__r.Airline_issuing__c IN :accountIds
  								OR Airline_receiving__c IN :accountIds];
  	List <Baggage_Claim_Comment__c> commentList = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM Baggage_Claim_Comment__c
  								WHERE Baggage_Claim__r.Parent_PIR_Form__r.Airline_issuing__c IN :accountIds
  								OR Baggage_Claim__r.Airline_receiving__c IN :accountIds];
  	
  	// lists to handle deletes
  	List <PIR_Form__Share> formShareListDelete = new List <PIR_Form__Share>();
  	List <Baggage_Claim__Share> claimShareListDelete = new List <Baggage_Claim__Share>();
  	List <Baggage_Claim_Comment__Share> commentShareListDelete = new List <Baggage_Claim_Comment__Share>();
  	
	// users related to affected contacts
	List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIds];
	for (User thisUser : userList){
		
		// handle PIR_Form__c sharing
		for (PIR_Form__c thisForm : formList){
			for (PIR_Form__Share thisShare : thisForm.Shares){
				if (thisShare.UserOrGroupId == thisUser.Id){
					formShareListDelete.add(thisShare);
				}
			}
		}
		
		// handle Baggage_Claim__c sharing
		for (Baggage_Claim__c thisClaim : claimList){
			for (Baggage_Claim__Share thisShare : thisClaim.Shares){
				if (thisShare.UserOrGroupId == thisUser.Id){
					claimShareListDelete.add(thisShare);
				}
			}
		}
		
		// handle Baggage_Claim_Comment__c sharing
		for (Baggage_Claim_Comment__c thisComment : commentList){
			for (Baggage_Claim_Comment__Share thisShare : thisComment.Shares){
				if (thisShare.UserOrGroupId == thisUser.Id){
					commentShareListDelete.add(thisShare);
				}
			}
		}
	}

	if (!formShareListDelete.isEmpty()){
		delete formShareListDelete;
	}
	if (!claimShareListDelete.isEmpty()){
		delete claimShareListDelete;
	}
	if (!commentShareListDelete.isEmpty()){
		delete commentShareListDelete;
	}
  }
  
  @future
  public static void removeBaggagePermissionSet(Set<Id> contactIds){
	String permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Baggage_Claim_Permission'].Id;
	Set <Id> userSetId = new Set <Id>();
  	List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIds];
	for (User thisUser : userList){
		userSetId.add(thisUser.Id);
	}
	if (permissionSetId != null && permissionSetId != ''){
        List <PermissionSetAssignment> assignmentListRemove = [SELECT Id, AssigneeId FROM PermissionSetAssignment
                                                        WHERE AssigneeId IN :userSetId
                                                        AND PermissionSetId = :permissionSetId];
        if (!assignmentListRemove.isEmpty()){
            delete assignmentListRemove;
        }
	}
  }
  */

  	@future
  	public static void addNonTdReportSharing(Set<Id> contactIds){
	  	Set <Id> accountIds = new Set <Id>(); // affected accounts
	  	Map <Id, Id> accountMap = new Map <Id, Id>();
	  	// affected contacts
	  	List <Contact> contactList = [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE Id IN :contactIds];
	  	for (Contact thisContact : contactList){
	  		if (!accountMap.containsKey(thisContact.AccountId)){
	  			accountMap.put(thisContact.AccountId, thisContact.AccountId);
	  			accountIds.add(thisContact.AccountId);
	  		}
	  		if (thisContact.Account.Top_Parent__c != null && thisContact.Account.Top_Parent__c != ''){
	  			if (!accountMap.containsKey(thisContact.Account.Top_Parent__c)){
		  			accountMap.put(thisContact.Account.Top_Parent__c, thisContact.Account.Top_Parent__c);
		  			accountIds.add(thisContact.Account.Top_Parent__c);
		  		}
	  		}
	  	}
	  	// with the account list, we'll retrieve all records to share
	  	List <ISSP_NonTD_Report__c> ReportList = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM ISSP_NonTD_Report__c 
	  								WHERE Account__c IN :accountIds];
	  	
	  	// lists to handle inserts
	  	List <ISSP_NonTD_Report__Share> NonTDReportShareListAdd = new List <ISSP_NonTD_Report__Share>();
	  	
	  	// users related to affected contacts
		List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIds];
		for (User thisUser : userList){
			
			// handle PIR_Form__c sharing
			for (ISSP_NonTD_Report__c thisReport : ReportList){
				Boolean addNewReport = true;
				for (ISSP_NonTD_Report__Share thisShare : thisReport.Shares){
					if (thisShare.UserOrGroupId == thisUser.Id){
						addNewReport = false;
					}
				}
				if (addNewReport){
					ISSP_NonTD_Report__Share newReportShare = new ISSP_NonTD_Report__Share();
	    			newReportShare.AccessLevel = 'Read';
	    			newReportShare.ParentId = thisReport.Id;
	    			newReportShare.UserOrGroupId = thisUser.Id;
	    			NonTDReportShareListAdd.add(newReportShare);
				}
			}		 
		}
		if (!NonTDReportShareListAdd.isEmpty()){
			insert NonTDReportShareListAdd;
		}
  	}

	@future
  	public static void removeNonTdReportSharing(Set<Id> contactIds){
	    Set <Id> accountIds = new Set <Id>(); // affected accounts
	  	Map <Id, Id> accountMap = new Map <Id, Id>();
	  	// affected contacts
	  	List <Contact> contactList = [SELECT Id, AccountId, Account.Top_Parent__c FROM Contact WHERE Id IN :contactIds];
	  	for (Contact thisContact : contactList){
	  		if (!accountMap.containsKey(thisContact.AccountId)){
	  			accountMap.put(thisContact.AccountId, thisContact.AccountId);
	  			accountIds.add(thisContact.AccountId);
	  		}
	  		if (thisContact.Account.Top_Parent__c != null && thisContact.Account.Top_Parent__c != ''){
	  			if (!accountMap.containsKey(thisContact.Account.Top_Parent__c)){
		  			accountMap.put(thisContact.Account.Top_Parent__c, thisContact.Account.Top_Parent__c);
		  			accountIds.add(thisContact.Account.Top_Parent__c);
		  		}
	  		}
  		}
	  	// with the account list, we'll retrieve all records to share
	  	List <ISSP_NonTD_Report__c> ReportList = [SELECT Id, (SELECT Id, UserOrGroupId FROM Shares) FROM ISSP_NonTD_Report__c 
	  								WHERE Account__c IN :accountIds];
  	
	  	// lists to handle inserts
	  	List <ISSP_NonTD_Report__Share> NonTDReportShareListDelete = new List <ISSP_NonTD_Report__Share>();
  
		// users related to affected contacts
		List <User> userList = [SELECT Id FROM User WHERE ContactId IN :contactIds];
		for (User thisUser : userList){
		
			// handle PIR_Form__c sharing
			for (ISSP_NonTD_Report__c thisReport : ReportList){
				for (ISSP_NonTD_Report__Share thisShare : thisReport.Shares){
					if (thisShare.UserOrGroupId == thisUser.Id){
						NonTDReportShareListDelete.add(thisShare);
					}
				}
			}
		}
		if (!NonTDReportShareListDelete.isEmpty()){
			delete NonTDReportShareListDelete;
		}
 	}

    /**
        Deactivate SIS permission for input contacts and send an email to helpdesk
    **/
    public static void alertSISContactsChangingAccount(set<Id> setContactId){
        List <Portal_Application_Right__c> appRightList = [
            SELECT Id, Contact__c, Access_Status_Reason__c
            FROM Portal_Application_Right__c
            WHERE Application_Name__c = 'SIS'
            AND Right__c = 'Access Granted'
            AND Contact__c IN :setContactId];
        if (appRightList.isEmpty()) return;
        
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        list<String> emailsTo = new list<String>();
        if (isSandbox) {
            //emailsTo.add('sisopsuat@iata.org'); // sandbox email
            emailsTo.add('tenaj@iata.org');
            emailsTo.add('shalbakf@iata.org');
        } else {
            emailsTo.add('sishelp@iata.org'); // production email
        }
        
        EmailTemplate templateOK;
        EmailTemplate templateERROR;
        for (EmailTemplate template : [SELECT Id, Name FROM EmailTemplate
            WHERE Name IN ('ISSP WS SIS send alert on Account change', 'ISSP WS SIS send alert on Account change Error')]) {
            if (template.Name == 'ISSP WS SIS send alert on Account change') templateOK = template;
            if (template.Name == 'ISSP WS SIS send alert on Account change Error') templateERROR = template;
        }
        
        // deny access to all application rights
        for (Portal_Application_Right__c right: appRightList) {
            right.Right__c = 'Access Denied';
            right.Access_Status_Reason__c = 'Access denied automatically due to contact moving from account to another';
        }
        
        try{
            list<Messaging.SingleEmailMessage> listEmail = new list<Messaging.SingleEmailMessage>();
            Database.SaveResult[] listResult = Database.update(appRightList, false);
            // create an emails to inform helpdesk
            for (Integer i=0; i<appRightList.size(); i++) { 
                Portal_Application_Right__c right = appRightList[i];
                Database.SaveResult result = listResult[i];
                
                // create an emails to inform helpdesk
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(emailsTo);
                email.setTargetObjectId(right.Contact__c);
                email.setTreatTargetObjectAsRecipient(false);
                email.setSaveAsActivity(false);
                // set email template for a succes or an error
                EmailTemplate template = result.isSuccess()? templateOK: templateERROR;
                email.setTemplateId(template.Id);
                listEmail.add(email);
            }
            // send all emails created
            Messaging.sendEmail(listEmail);
        }catch(Exception  e){
            system.debug('Failed to send email to SIS helpdesk: ' + e.getStackTraceString());
        }
        
    }
}