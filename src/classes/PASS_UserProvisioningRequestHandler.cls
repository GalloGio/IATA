public class PASS_UserProvisioningRequestHandler {

	public void onAfterUpdate(Map<Id,UserProvisioningRequest> oldMap, Map<Id,UserProvisioningRequest> newMap) {
		System.debug('JCFF PASS_UserProvisioningRequestHandler');
		List<PermissionSetAssignment> passPrimaryUserAssignment = new List<PermissionSetAssignment>();

		PermissionSet passPrimaryUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name='PASS_User_Prov' LIMIT 1];


		System.debug('DB: oldMap '+oldMap);
		System.debug('DB: newMap '+newMap);


		// Consider only the user provisioning requests for PASS such that the state is changed to 'Completed'
		Set<Id> requestsToConsider = new Set<Id>();
		for(Id requestId : newMap.keySet()){
			UserProvisioningRequest oldRequest = oldMap.get(requestId);
			UserProvisioningRequest newRequest = newMap.get(requestId);

			System.debug('DB: oldRequest '+oldRequest.State);
			System.debug('DB: newRequest Name '+newRequest);
			System.debug('DB: newRequest State '+newRequest);

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

			if(isPrimaryUser) {
				userIds.add(userId);
			}
		}

		if(!userIds.isEmpty()){
			addPassPrimaryPermissionSet(userIds);
		}
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
}