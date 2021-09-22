public without sharing class InvitationService {
	@AuraEnabled
	public static void inviteUsers(List<EncodedInvitation> encodedInvitationList){
		//create Invitation domain class
		Invitations invitations = new Invitations();

		//verify required data is present in encodedInvitationList
		try{
			invitations.verifyInvitation(decodeInvitation(encodedInvitationList));
		}catch(InvitationServiceException e){
			throw e;
		}

		//create set for ease of checking for presence of email address and account id
		Set<String> invitationEmailAddressSet = new Set<String>();
		Set<Id> accountIdSet = new Set<Id>();
		//get existing invitations for portal service where email or account exists in invitation
		Set<EncodedInvitation> existingEncodedInvitationSet = getExistingInvitationSet(encodedInvitationList,invitationEmailAddressSet, accountIdSet);

		//initialise set of original requested EncodedInvitation
		Set<EncodedInvitation> requestedEncodedInvitationSet = new Set<EncodedInvitation>(encodedInvitationList);

		//initialise list of records to modify
		List<Invitation__c> invitationsToUpsert = new List<Invitation__c>();

		//get functional role for service id
		Id portalApplicationId = requestedEncodedInvitationSet.iterator().next().portalApplicationId;
		String functionalRole = PortalApplicationSelector.selectFunctionalRoleMapByServiceIdSet(new Set<Id>{portalApplicationId}).values().get(0).Functional_Role__c;

		//iterate requested invitations and if existing is not present, create. if present, update status and add to list to be upserted
		for(EncodedInvitation requestedEncodedInvitation : requestedEncodedInvitationSet){
			//if requested invitation does not exist, create
			if(!existingEncodedInvitationSet.contains(requestedEncodedInvitation)){
				requestedEncodedInvitation.status = invitations.ACTIVE;
				requestedEncodedInvitation.functionalRole = functionalRole;
				invitationsToUpsert.add(decodeInvitation(new List<EncodedInvitation>{requestedEncodedInvitation}).get(0));
			} else {
				//existing invitiation exists for requested: retrieve from set
				Iterator<EncodedInvitation> iterator = existingEncodedInvitationSet.iterator();
				while(iterator.hasNext()){
					EncodedInvitation existingEncodedInvitation = iterator.next();
					if(existingEncodedInvitation.status != invitations.COMPLETED){
						existingEncodedInvitation.status = invitations.ACTIVE;
						invitationsToUpsert.add(decodeInvitation(new List<EncodedInvitation>{existingEncodedInvitation}).get(0));
					} else if(existingEncodedInvitation.status == invitations.COMPLETED){
						requestedEncodedInvitation.status = invitations.ACTIVE;
						requestedEncodedInvitation.functionalRole = functionalRole;
						invitationsToUpsert.add(decodeInvitation(new List<EncodedInvitation>{requestedEncodedInvitation}).get(0));
					}
					break;
				}
			}
		}

		try{
			upsertRecords(invitationsToUpsert);
		} catch(Exception e){
			throw e;
		}
	}

	@AuraEnabled
	//only the invitation record id is sent in the encodedInvitationList
	public static void cancelInvitation(List<EncodedInvitation> encodedInvitationList){	
		//create set of invitation ids
		Set<Id> cancelledInvitationIdSet = new Set<Id>();
		for(EncodedInvitation encodedInvitation : encodedInvitationList){
			cancelledInvitationIdSet.add(encodedInvitation.id);
		}
		//query for existing invitations
		//todo move to invitationselector class
		List<Invitation__c> invitationList = [SELECT Id, Status__c FROM Invitation__c WHERE Id IN :cancelledInvitationIdSet];
		//create Invitation domain class
		Invitations invitations = new Invitations(invitationList);
		//update status' on records
		invitations.updateStatus(invitations.CANCELLED);

		//commit updated invitations to DB
		try{
			update invitations.records;
		} catch(Exception e){
			throw e;
		}
	}

	@AuraEnabled(cacheable=true)
	public static Id getUserContactRoleAccountId(Id loggedInUserId, Id portalApplicationId){
		try {
			//todo move to PortalApplicationSelector
			String functionalRole = [SELECT Functional_Role__c FROM Portal_Applications__c WHERE Id = :portalApplicationId LIMIT 1].Functional_Role__c;

			//todo move to AccountContactRoleSelector
			return [
				SELECT Account_Role__r.Account__c 
				FROM Account_Contact_Role__c 
				WHERE Functional_Role__c = :functionalRole
				AND Account_Role__r.Functional_Role__c =:functionalRole
				AND Contact__c IN (
					SELECT ContactId 
					FROM User 
					WHERE Id = :loggedInUserId
				) 
				LIMIT 1
			].Account_Role__r.Account__c;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	//only invitations for a single portal application can be checked for at a time
	//using the portalApplication defined in the first invitationrequest
	public static void checkForInvitations(Id portalApplicationId, User user){
		String email = user.Contact.Email;
		SavePoint savePoint = Database.setSavePoint();
		try {
			//create domain classes
			Invitations invitations = new Invitations();
			PortalApplicationRights portalApplicationRights = new PortalApplicationRights();

			//get active invitations for portal service and email
			List<Invitation__c> invitationList = InvitationSelector.selectMapByServiceIdEmailSetAndStatus(portalApplicationId, new Set<String>{email}, invitations.ACTIVE);
			//if no invitations then provision the user as normal
			if(invitationList.isEmpty())
				ISSP_AvailableServices.newAppsRequest(portalApplicationId, '', user.ContactId);

			Set<String> emailSet = new Set<String>();
			for(Invitation__c invitation : invitationList){
				emailSet.add(invitation.Email__c);
			}
			Map<String,Contact> emailContactMap = ContactSelector.selectEmailContactMapByEmails(emailSet);
			//create a map of invitationId, Contact
			Map<Id, Contact> inviteIdContactMap = new Map<Id, Contact>();
			for(Invitation__c invitation : invitationList){
				inviteIdContactMap.put(invitation.Id, emailContactMap.get(invitation.Email__c));
			}

			//get existing portalapplicationright record for contact + service (may already exist as access denied)
			List<Portal_Application_Right__c> existingPortalApplicationRightList = [SELECT Id, Contact__c, Portal_Application__c FROM Portal_Application_Right__c WHERE Portal_Application__c = :portalApplicationId AND Contact__c = :user.ContactId];
			//create map Contact Id + Portal_Application_Right__c
			Map<Id, Portal_Application_Right__c> contactPortalApplicationRightMap = new Map<Id, Portal_Application_Right__c>();
			for(Portal_Application_Right__c portalApplicationRight : existingPortalApplicationRightList){
				contactPortalApplicationRightMap.put(portalApplicationRight.Contact__c, portalApplicationRight);
			}

			List<Portal_Application_Right__c> portalApplicationRightList = portalApplicationRights.createDefaultPortalApplicationRight(invitationList.size());
			for(Integer x = 0 ; x < invitationList.size(); x++){
				Invitation__c invitation = invitationList.get(x);
				Portal_Application_Right__c portalApplicationRight = portalApplicationRightList.get(x);
				Id existingContactId = inviteIdContactMap.get(invitation.Id).Id;

				if(contactPortalApplicationRightMap.get(existingContactId) != null){
					portalApplicationRightList.set(x, contactPortalApplicationRightMap.get(existingContactId));
					portalApplicationRight = portalApplicationRightList.get(x);
				} else{
					portalApplicationRight.Portal_Application__c = invitation.ServiceId__c;
					portalApplicationRight.Contact__c = existingContactId;
				}
				portalApplicationRight.Right__c = portalApplicationRights.ACCESSGRANTED;
				portalApplicationRight.Is_Invitation__c = TRUE;
			}
			upsert portalApplicationRightList;
		} catch (Exception e) {
			Database.rollback(savePoint);
			throw new AuraHandledException(e.getMessage() + ' = ' + e.getStackTraceString());
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<EncodedInvitation> getInvitationList(Id portalApplicationId){
		try {
			//todo move to individual method in invitationselector
			List<Invitation__c> invitationList = InvitationSelector.selectQuery('Id, Account__c, Email__c, Role_Name__c, Status__c, ServiceId__c, Functional_Role__c', 'ServiceId__c = \'' + portalApplicationId + '\'', null);
			return encodeInvitation(invitationList);	
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Map<Id,Boolean> isServiceAdministrator(Id portalApplicationId, List<Id> userIdList){
		try {
			//map to store return data
			Map<Id,Boolean> userIdIsServiceAdminMap = new Map<Id,Boolean>();
			//retreive functional role from service Id
			Map<Id, Portal_Applications__c> portalApplicationMap = PortalApplicationSelector.selectFunctionalRoleMapByServiceIdSet(new Set<Id>{portalApplicationId});
			if (portalApplicationMap.isEmpty())
				return new Map<Id,Boolean>();

			Map<Id,Account_Contact_Role__c> accountContactRoleMap = AccountContactRoleSelector.selectUserIdMapByUserIdSetAndFunctionalRole(new Set<Id>(userIdList), portalApplicationMap.values().get(0).Functional_Role__c);
			for(Id id : accountContactRoleMap.keySet()){
				userIdIsServiceAdminMap.put(id, accountContactRoleMap.get(id).Is_Service_Administrator__c);
			}
			return userIdIsServiceAdminMap;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	//returns a list of invitable roles for a provided PortalApplicationId
	@AuraEnabled(cacheable=true)
	public static List<String> getInvitableRoles(Id portalApplicationId){
		try {
			List<String> invitableRoleList = new List<String>();
			//get functional role for the portal application id provided
			String functionalRole = PortalApplicationSelector.selectFunctionalRoleMapByServiceIdSet(new Set<Id>{portalApplicationId}).get(portalApplicationId).Functional_Role__c;
			//get all ContactRoleDetail mdt where CRD.Functional_Role__c == function role of service id
			List<Contact_Role_Detail__mdt> contactRoleDetail_mdtList = ContactRoleDetail_mdt_Selector.selectRolesByFunctionalRole(functionalRole);
			if(!contactRoleDetail_mdtList.IsEmpty()){
				for(Contact_Role_Detail__mdt contactRoleDetail_mdt : contactRoleDetail_mdtList){
					invitableRoleList.add(contactRoleDetail_mdt.Role_Name__c);
				}
			}
			return invitableRoleList;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
		}
	}

	//converts the input EncodedInvitations into Invitation__c records
	public static List<Invitation__c> decodeInvitation(List<EncodedInvitation> encodedInvitationList){
		//set of unique role names (label value)
		Set<String> userRoleNameSet = new Set<String>();
		//get all role names to be decoded
		for(EncodedInvitation encodedInvitation : encodedInvitationList){
			userRoleNameSet.add(encodedInvitation.userRole);
		}
		
		List<Invitation__c> invitationList = new List<Invitation__c>();
		for(EncodedInvitation encodedInvitation : encodedInvitationList){
			Invitation__c invitation = new Invitation__c(
				Id = encodedInvitation.id,
				Email__c = encodedInvitation.emailAddress,
				ServiceId__c = encodedInvitation.portalApplicationId,
				Role_Name__c = encodedInvitation.userRole,
				Account__c = encodedInvitation.accountId,
				Status__c = encodedInvitation.status,
				Functional_Role__c = encodedInvitation.functionalRole
			);
			invitationList.add(invitation);
		}
		return invitationList;
	}

	//converts the input Invitation__c into EncodedInvitations
	public static  List<EncodedInvitation> encodeInvitation(List<Invitation__c> invitationList){		
		List<EncodedInvitation> encodedInvitationList = new List<EncodedInvitation>();
		for(Invitation__c invitation : invitationList){
			//create EncodedInvitation and add to Set<EncodedInvitation> existingInvitationSet
			EncodedInvitation encodedInvitation = new EncodedInvitation();
			encodedInvitation.Id = invitation.Id;
			encodedInvitation.emailAddress = invitation.Email__c;
			encodedInvitation.portalApplicationId = invitation.ServiceId__c;
			encodedInvitation.userRole = invitation.Role_Name__c;
			encodedInvitation.accountId = invitation.Account__c;
			encodedInvitation.status = invitation.Status__c;
			encodedInvitation.functionalRole = invitation.Functional_Role__c;
			encodedInvitationList.add(encodedInvitation);
		}
		return encodedInvitationList;
	}

	//inner class to represent an instance of an invitation record enabling implemention of equals comparison method
	public class EncodedInvitation {
		@AuraEnabled public Id id {get;set;}
		@AuraEnabled public String emailAddress {get;set;}
		@AuraEnabled public Id portalApplicationId {get;set;}
		@AuraEnabled public String userRole {get;set;}
		@AuraEnabled public Id accountId {get;set;}
		@AuraEnabled public String status {get;set;}
		public String functionalRole;

		public Boolean equals(Object obj){
			if(obj instanceof EncodedInvitation){
				EncodedInvitation encodedInvitation = (EncodedInvitation) obj;
				return (
					(emailAddress == encodedInvitation.emailAddress) && 
					(portalApplicationId == encodedInvitation.portalApplicationId) &&
					(userRole == encodedInvitation.userRole) &&
					(accountId == encodedInvitation.accountId)
				);
			}
			return false;
		}

		public Integer hashCode(){
			return 13 + 
				(31 * System.hashCode(emailAddress == null ? '' : emailAddress)) + 
				(31* System.hashCode(portalApplicationId == null ? '' : portalApplicationId)) +
				(31 * System.hashCode(userRole == null ? '' : portalApplicationId)) +
				(31 * System.hashCode(accountId == null ? '' : accountId));
		}
	}

	private static Set<EncodedInvitation> getExistingInvitationSet(List<EncodedInvitation> encodedInvitationList, Set<String> invitationEmailAddressSet, Set<Id> accountIdSet){
		//populate sets
		for(EncodedInvitation encodedInvitation : encodedInvitationList){
			invitationEmailAddressSet.add(encodedInvitation.emailAddress);
			accountIdSet.add(encodedInvitation.accountId);
		}

		List<Invitation__c> existingInvitationList = InvitationSelector.selectByServiceIdAndEmailSetOrAccountSet(encodedInvitationList.get(0).portalApplicationId, invitationEmailAddressSet, accountIdSet);
		//initialise set of existing EncodedInvitation
		return new Set<EncodedInvitation>(encodeInvitation(existingInvitationList));
	}

	private static void upsertRecords(List<Invitation__c> invitationList){
		try {			
			SavePoint sp = Database.setSavePoint();
			try{
				upsert(invitationList);
			}
			catch (Exception e){
				Database.rollback(sp);
				throw new InvitationServiceException('PortalServiceAccess.inviteUsers failed: ' + e.getStackTraceString(), e);
			}
		} catch (Exception e) {
			throw new AuraHandledException('PortalServiceAccess.inviteUsers failed: ' + e.getStackTraceString());
		}
	}

	public class InvitationServiceException extends Exception {}
}