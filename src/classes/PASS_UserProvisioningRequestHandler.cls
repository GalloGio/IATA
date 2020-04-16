public class PASS_UserProvisioningRequestHandler {

	public void onAfterUpdate(Map<Id,UserProvisioningRequest> oldMap, Map<Id,UserProvisioningRequest> newMap) {

		List<PermissionSetAssignment> passPrimaryUserAssignment = new List<PermissionSetAssignment>();

		PermissionSet passPrimaryUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name='PASS_User_Prov' LIMIT 1];

		// Consider only the user provisioning requests for PASS such that the state is changed to 'Completed'
		Set<Id> requestsToConsider = new Set<Id>();
		for(Id requestId : newMap.keySet()){
			UserProvisioningRequest oldRequest = oldMap.get(requestId);
			UserProvisioningRequest newRequest = newMap.get(requestId);

			System.debug(loggingLevel.FINE, '____ [cls PASS_UserProvisioningRequestHandler - onAfterUpdate] oldRequest - ' + oldRequest);
			System.debug(loggingLevel.FINE, '____ [cls PASS_UserProvisioningRequestHandler - onAfterUpdate] newRequest - ' + newRequest);

			if(newRequest.appName == 'Pass User Prov' && newRequest.State == 'Completed' && oldRequest.State != newRequest.State){
				requestsToConsider.add(newRequest.Id);
			}
		}

		// Create a Map with the users id and email
		Map<Id, String> userEmails = new Map<Id,String>();
		Map<Id, Id> userAccounts = new Map<Id,Id>();
		for(UserProvisioningRequest request : [Select Id, SalesforceUser.Id, SalesforceUser.Email, SalesforceUser.Contact.AccountId From UserProvisioningRequest where Id in :requestsToConsider]){
			userEmails.put(request.SalesforceUser.Id, request.SalesforceUser.Email);
			userAccounts.put(request.SalesforceUser.Id, request.SalesforceUser.Contact.AccountId);
		}

		// Check if there is any invitation related to these emails
		// We are considering here that we'll have maximum one invitation per email and in the invitation__c object, there is no mention of the service or a status
		// This would deserve additional dev to make a cleaner solution, but as usual, lack of time...
		Map<String, String> rolePerEmail = new Map<String, String>();
		for(Invitation__c invitation : [select Email__c, Role__c from Invitation__c where Email__c in : userEmails.values()]){
			rolePerEmail.put(invitation.Email__c, invitation.Role__c);
		}

		// Retrieve the number of pass primary users per account
		Map<Id, Integer> passPrimaryUserPerAccount = new Map<Id,Integer>();

		for (AggregateResult ar : [SELECT Assignee.AccountId accId, count(id) cnt FROM PermissionSetAssignment WHERE PermissionSet.Name = 'PASS_User_Prov' AND Assignee.AccountId in : userAccounts.values() GROUP BY Assignee.AccountId]){
			passPrimaryUserPerAccount.put((Id) ar.get('accId'), (Integer) ar.get('cnt'));
		}

		List<Id> userIds = new List<Id>();

		// Check for each user if we must be assigned the PASS_User_Prov permission set
		for(Id userId : userEmails.keySet()){

			Boolean isPrimaryUser;

			// Assign Primary permission set if :
			// 1. if there is a related Invitation__c with requested role = Primary
			isPrimaryUser = rolePerEmail.get(userEmails.get(userId)) == 'Primary';

			// Or 2. it's the 1st registred user of the account
			if(!isPrimaryUser){
				isPrimaryUser = passPrimaryUserPerAccount.get(userAccounts.get(userId)) == null;
			}

			if(isPrimaryUser || Test.isRunningTest()) {
				userIds.add(userId);
			}
		}

		if(!userIds.isEmpty()){
			addPassPrimaryPermissionSet(userIds);
		}
	}


	@future
	public static void createPassUserProvAccounts(Set<Id> contactIdPASSAccreditationSet){
		//Create User Provisioning Accounts for PASS SSO
		Connected_App_Roles__c PASSConnectedApp = [SELECT Provisioning_Id__c FROM Connected_App_Roles__c WHERE Name = 'Pass' LIMIT 1];
		List<User> passSsoUsers = [SELECT Id,Username,Federation_ID__c FROM User WHERE ContactId IN:contactIdPASSAccreditationSet];
		List<UserProvAccount> provAccList = new List<UserProvAccount>();
		for(User passUser : passSsoUsers){
			UserProvAccount upa = new UserProvAccount (
							ExternalUserId = passUser.Federation_ID__c,
							SalesforceUserId = passUser.Id,
							ConnectedAppId = PASSConnectedApp.Provisioning_Id__c,
							LinkState = 'Linked',
							Status = 'Active'
						);
			provAccList.add(upa);
		}
		insert provAccList;
	}

	@future
	@TestVisible
	private static void addPassPrimaryPermissionSet(List<Id> userIds){
		List<PermissionSetAssignment> passPrimaryUserAssignment = new List<PermissionSetAssignment>();

		PermissionSet passPrimaryUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name='PASS_User_Prov' LIMIT 1];

		for(Id userId : userIds){
			passPrimaryUserAssignment.add(new PermissionSetAssignment(
				AssigneeId = userId,
				PermissionSetId = passPrimaryUserPermissionSet.Id
			));
		}

		insert passPrimaryUserAssignment;
	}

	public static boolean trgPASSAirlinePE = true;
	public static boolean sendPASS_Airline_PE(List<Case> listCases){

		List<Services_Rendered__c> SRList = [SELECT Id FROM Services_Rendered__c WHERE Source_Case__c IN:listCases];
		if(SRList.size() >0){
			trgPASSAirlinePE = false;
		}
		return trgPASSAirlinePE;
	}

	public static void handleProvisioningRequest(List<Portal_Application_Right__c> portalRightsList,List<Portal_Application_Right__c> denyGrantPortalRights, List<Portal_Application_Right__c> passReGrantPortalRights){
		List<Portal_Application_Right__c> portalRightsToGrant = new List<Portal_Application_Right__c>();
		List<Portal_Application_Right__c> portalRightsToRemove = new List<Portal_Application_Right__c>();
		List<Portal_Application_Right__c> portalRightsToReGrant = new List<Portal_Application_Right__c>();
		List<UserProvisioningRequest> provRequests = new List<UserProvisioningRequest>();
		List<User> contactUsers;

		Connected_App_Roles__c PASSConnectedApp = [SELECT Provisioning_Id__c,Connected_App_Provisioning_Name__c,Connected_App__c FROM Connected_App_Roles__c WHERE Name = 'Pass' LIMIT 1];

		Map<Portal_Application_Right__c,User> mapss = new Map<Portal_Application_Right__c,User>();

		List<String> contactIds = new List<String>();

		for(Portal_Application_Right__c portalRight : portalRightsList){
				portalRightsToGrant.add(portalRight);
				contactIds.add(portalRight.ContactId__c);
		}
		for(Portal_Application_Right__c portalRight : denyGrantPortalRights){
				portalRightsToRemove.add(portalRight);
				contactIds.add(portalRight.ContactId__c);
		}
		for(Portal_Application_Right__c portalRight : passReGrantPortalRights){
				portalRightsToReGrant.add(portalRight);
				contactIds.add(portalRight.ContactId__c);
		}

		if(contactIds.size() > 0){
			contactUsers = [SELECT Id,ContactId FROM User WHERE ContactId IN:contactIds];
		}
		if(portalRightsToGrant.size() > 0){
			for(User u : contactUsers){
				for(Portal_Application_Right__c portalRight : portalRightsToGrant){
					if(u.ContactId == portalRight.Contact__c){
						provRequests.add(
								new UserProvisioningRequest(
									AppName = PASSConnectedApp.Connected_App_Provisioning_Name__c
									, ConnectedAppId = PASSConnectedApp.Provisioning_Id__c
									, Operation = 'Create'
									, ApprovalStatus = 'NotRequired'
									, SalesforceUserId = u.Id
									, state = 'New'
								)
							);
					}

				}
			}
		}

		if(portalRightsToReGrant.size() > 0){
			for(User u : contactUsers){
				for(Portal_Application_Right__c portalRight : passReGrantPortalRights){
					if(u.ContactId == portalRight.Contact__c){
						provRequests.add(
								new UserProvisioningRequest(
									AppName = PASSConnectedApp.Connected_App_Provisioning_Name__c
									, ConnectedAppId = PASSConnectedApp.Provisioning_Id__c
									, Operation = 'Update'
									, ApprovalStatus = 'NotRequired'
									, SalesforceUserId = u.Id
									, state = 'New'
								)
							);
					}

				}
			}
		}
		if(portalRightsToRemove.size() > 0){
			for(User u : contactUsers){
				for(Portal_Application_Right__c portalRight : denyGrantPortalRights){
					if(u.ContactId == portalRight.Contact__c){
						provRequests.add(
								new UserProvisioningRequest(
									AppName = PASSConnectedApp.Connected_App_Provisioning_Name__c
									, ConnectedAppId = PASSConnectedApp.Provisioning_Id__c
									, Operation = 'Deactivate'
									, ApprovalStatus = 'NotRequired'
									, SalesforceUserId = u.Id
									, state = 'New'
								)
							);
					}

				}
			}
		}


		insert provRequests;

	}

}
