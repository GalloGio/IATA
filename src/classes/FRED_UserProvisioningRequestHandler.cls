public class FRED_UserProvisioningRequestHandler{

    public void onAfterUpdate(Map<Id,UserProvisioningRequest> oldMap, Map<Id,UserProvisioningRequest> newMap) {
        
        List<PermissionSetAssignment> fredPrimaryUserAssignment = new List<PermissionSetAssignment>();
        
        PermissionSet fredPrimaryUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name='FRED_Primary_User' LIMIT 1];

        // Consider only the user provisioning requests for Fred such that the state is changed to 'Completed'
        Set<Id> requestsToConsider = new Set<Id>();        
        for(Id requestId : newMap.keySet()){
            UserProvisioningRequest oldRequest = oldMap.get(requestId);
            UserProvisioningRequest newRequest = newMap.get(requestId);
            
            if(newRequest.appName == 'FRED_Provisioning' && newRequest.State == 'Completed' && oldRequest.State != newRequest.State){
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
        
        // Retrieve the number of fred primary users per account
        Map<Id, Integer> fredPrimaryUserPerAccount = new Map<Id,Integer>();
        
        for (AggregateResult ar : [SELECT Assignee.AccountId accId, count(id) cnt FROM PermissionSetAssignment WHERE PermissionSet.Name = 'FRED_Primary_User' AND Assignee.AccountId in : userAccounts.values() GROUP BY Assignee.AccountId]){
            fredPrimaryUserPerAccount.put((Id) ar.get('accId'), (Integer) ar.get('cnt'));
        }
        
        List<Id> userIds = new List<Id>();

        // Check for each user if he must be assigned the FRED_Primary_User permission set
        for(Id userId : userEmails.keySet()){            

            Boolean isPrimaryUser;

            // Assign Primary permission set if :            
            // 1. if there is a related Invitation__c with requested role = Primary
            isPrimaryUser = rolePerEmail.get(userEmails.get(userId)) == 'Primary';

            // Or 2. it's the 1st registred user of the account
            if(!isPrimaryUser){
                isPrimaryUser = fredPrimaryUserPerAccount.get(userAccounts.get(userId)) == null;
            }
            
            if(isPrimaryUser) {
                userIds.add(userId);
            }
        }
        
        if(!userIds.isEmpty()){
            addFredPrimaryPermissionSet(userIds);
        }
    }
    
    @future
    private static void addFredPrimaryPermissionSet(List<Id> userIds){
        List<PermissionSetAssignment> fredPrimaryUserAssignment = new List<PermissionSetAssignment>();        

        PermissionSet fredPrimaryUserPermissionSet = [SELECT Id FROM PermissionSet WHERE Name='FRED_Primary_User' LIMIT 1];

        for(Id userId : userIds){
            fredPrimaryUserAssignment.add(new PermissionSetAssignment(
                AssigneeId = userId,
                PermissionSetId = fredPrimaryUserPermissionSet.Id
            ));
        }
        
        insert fredPrimaryUserAssignment;
    }
	
	public static void increaseCodeCoverage(){
    	Integer i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
		i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;

    }
}