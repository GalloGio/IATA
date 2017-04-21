public class UserProvisioningRequestController {
    @AuraEnabled
    public static List<UserProvisioningRequest> getFailedRequests(){
		return [SELECT AppName, CreatedDate, SalesforceUser.Name, Operation, State, LastModifiedDate, UserProvAccount.ExternalUsername, RetryCount 
                FROM userProvisioningRequest 
                WHERE State = 'Failed'
                ORDER BY LastModifiedDate DESC];
    }
    
    @AuraEnabled
    public static List<UserProvisioningRequest> getFailedRequestsBySearch(String searchKey){
        searchKey = '%' + searchKey + '%';
		return [SELECT AppName, CreatedDate, SalesforceUser.Name, Operation, State, LastModifiedDate, UserProvAccount.ExternalUsername, RetryCount 
                FROM userProvisioningRequest 
                WHERE State = 'Failed' AND (AppName LIKE :searchkey OR SalesforceUser.Name LIKE :searchkey OR Operation LIKE :searchkey OR State LIKE :searchkey OR UserProvAccount.ExternalUsername LIKE :searchkey)
                ORDER BY LastModifiedDate DESC];
    }
    
    @AuraEnabled
    public static List<UserProvisioningRequest> getAllRequests(){
		return [SELECT AppName, CreatedDate, SalesforceUser.Name, Operation, State, LastModifiedDate, UserProvAccount.ExternalUsername, RetryCount 
                FROM userProvisioningRequest 
                ORDER BY LastModifiedDate DESC];
    }
    
    @AuraEnabled
    public static List<UserProvisioningRequest> getAllRequestsBySearch(String searchKey){
        searchKey = '%' + searchKey + '%';
		return [SELECT AppName, CreatedDate, SalesforceUser.Name, Operation, State, LastModifiedDate, UserProvAccount.ExternalUsername, RetryCount 
                FROM userProvisioningRequest 
                WHERE (AppName LIKE :searchkey OR SalesforceUser.Name LIKE :searchkey OR Operation LIKE :searchkey OR State LIKE :searchkey OR UserProvAccount.ExternalUsername LIKE :searchkey)
                ORDER BY LastModifiedDate DESC];
    }
    
    @AuraEnabled
    public static List<UserProvisioningLog> getRequestLogs(String record){
        return [SELECT CreatedDate, Details FROM userProvisioningLog WHERE UserProvisioningRequestId = :record ORDER BY CreatedDate];
    }
    
    @AuraEnabled
    public static void retryUserProvisioningRequests(UserProvisioningRequest[] failedRequestList){
        List<UserProvisioningRequest> newRetryRequests = new List<UserProvisioningRequest>();
        List<UserProvisioningRequest> updatedFailedRequests = new List<UserProvisioningRequest>();

        for(UserProvisioningRequest failedRequest : failedRequestList){
            // Create new UPR record for each failed request. Update to reflect
            // new status, the record they were cloned from, and incremented retry count
            UserProvisioningRequest newRetryRequest = failedRequest.clone();   
            newRetryRequest.state = 'New';
            newRetryRequest.ApprovalStatus = 'NotRequired';
            newRetryRequest.RetryCount = (newRetryRequest.RetryCount == NULL ? 1 : newRetryRequest.RetryCount + 1);
            newRetryRequest.ParentId = failedRequest.id;
            newRetryRequests.add(newRetryRequest);
            
            failedRequest.state = 'Retried';
            updatedFailedRequests.add(failedRequest);
        }   
        insert newRetryRequests;
        upsert updatedFailedRequests;
    }
    
    @AuraEnabled
    public static void manuallyCompleteUserProvisioningRequest(List<UserProvisioningRequest> completedRequests){
        List<UserProvisioningRequest> completedRequestList = new List<UserProvisioningRequest>();
        for(UserProvisioningRequest completedRequest : completedRequests){
            completedRequest.state = 'Manually Completed';
            completedRequestList.add(completedRequest);
        }
        upsert completedRequestList;
    }
}