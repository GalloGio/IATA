@isTest
public class UserprovisioningRequestControllerTests {
    
    @isTest
    static void validateRetryUserProvisioningRequestsOneRecord() {
		UserProvisioningRequest upr = new UserProvisioningRequest(AppName='Test', State='Failed',ApprovalStatus='NotRequired', Operation='Deactivate');
        List<UserProvisioningRequest> uprList = new List<UserProvisioningRequest>(); 
        uprList.add(upr);
        UserProvisioningRequestController.retryUserProvisioningRequests(uprList);
        
        UserProvisioningRequest retriedUpr = [SELECT AppName, Id FROM userProvisioningRequest WHERE State='retried'];
        UserProvisioningRequest newUpr = [SELECT AppName, Id FROM userProvisioningRequest WHERE State='new'];
        
		System.assertEquals(retriedUpr.Id, upr.Id);
        System.assertEquals(newUpr.AppName, upr.AppName);
    }
    
    @isTest
    static void manuallyCompleteUserProvisioningRequest() {
        UserProvisioningRequest upr = new UserProvisioningRequest(AppName='Test', State='Failed', ApprovalStatus='NotRequired', Operation='Deactivate');
        List<UserProvisioningRequest> uprList = new List<UserProvisioningRequest>();
        uprList.add(upr);
        UserProvisioningRequestController.manuallyCompleteUserProvisioningRequest(uprList);
        
        UserProvisioningRequest manuallyCompletedUpr = [SELECT Id FROM UserProvisioningRequest WHERE State='Manually Completed'];
        
        System.assertEquals(manuallyCompletedUpr.Id, upr.Id);
    }
    
    @isTest
    static void validateGetFailedRequestsOnlyFailed() {
		UserProvisioningRequest upr = new UserProvisioningRequest(AppName='Test', State='Failed', ApprovalStatus='NotRequired', Operation='Deactivate');
        insert upr;
        
        List<UserProvisioningRequest> failedUprs = new List<UserProvisioningRequest>();
        failedUprs = UserProvisioningRequestController.getFailedRequests();
        
        System.assertEquals(failedUprs.get(0).Id, upr.Id);
    }
    
    @isTest
    static void validateGetFailedRequestsMixed() {
        UserProvisioningRequest failedUpr = new UserProvisioningRequest(AppName='FailedTest', State='Failed', ApprovalStatus='NotRequired', Operation='Deactivate');
        insert failedUpr;
        UserProvisioningRequest succeededUpr = new UserProvisioningRequest(AppName='Test', State='Completed', ApprovalStatus='NotRequired', Operation='Deactivate');
        insert succeededUpr;
        
        List<UserProvisioningRequest> failedUprs = new List<UserProvisioningRequest>();
        failedUprs = UserProvisioningRequestController.getFailedRequests();
        
        System.assertEquals(failedUprs.size(), 1);
        System.assertEquals(failedUprs.get(0).Id, failedUpr.Id);
    }
    
    @isTest
    static void validateGetFailedRequestsNoResults() {
        UserProvisioningRequest succeededUpr = new UserProvisioningRequest(AppName='Test', State='Completed', ApprovalStatus='NotRequired', Operation='Deactivate');
        insert succeededUpr;
        
        List<UserProvisioningRequest> failedUprs = new List<UserProvisioningRequest>();
        failedUprs = UserProvisioningRequestController.getFailedRequests();
        
        System.assertEquals(failedUprs.size(), 0);
    }
    
    @isTest
    static void validateGetAllRequestsOnlyFailed() {
        UserProvisioningRequest upr = new UserProvisioningRequest(AppName='Test', State='Failed', ApprovalStatus='NotRequired', Operation='Deactivate');
        insert upr;
        
        List<UserProvisioningRequest> failedUprs = new List<UserProvisioningRequest>();
        failedUprs = UserProvisioningRequestController.getAllRequests();
        
        System.assertEquals(failedUprs.get(0).Id, upr.Id);
    }

    @isTest
    static void validateGetAllRequestsMixed() {
		UserProvisioningRequest failedUpr = new UserProvisioningRequest(AppName='FailedTest', State='Failed', ApprovalStatus='NotRequired', Operation='Deactivate');
        insert failedUpr;
        UserProvisioningRequest succeededUpr = new UserProvisioningRequest(AppName='Test', State='Completed', ApprovalStatus='NotRequired', Operation='Deactivate');
        insert succeededUpr;
        
        List<UserProvisioningRequest> allUprs = new List<UserProvisioningRequest>();
        allUprs = UserProvisioningRequestController.getAllRequests();
        Set<Id> allUprSet = new Set<Id>();
        for (UserProvisioningRequest upr: allUprs)
        {
			allUprSet.add(upr.Id);
        }
        
        System.assertEquals(allUprs.size(), 2);
        System.assert(allUprSet.contains(failedUpr.Id));
        System.assert(allUprSet.contains(succeededUpr.Id));
    }
    
    @isTest
    static void validateGetAllRequestsNoResults() {
        List<UserProvisioningRequest> allUprs = new List<UserProvisioningRequest>();
        allUprs = UserProvisioningRequestController.getAllRequests();
        
        System.assertEquals(allUprs.size(), 0);
    }
    
    @isTest
    static void validateGetRequestLogOneRecord() { 
        List<UserProvisioningLog> uprLog = new List<UserProvisioningLog>();
        UserProvisioningRequest upr = new UserProvisioningRequest(AppName='Test', State='Completed', ApprovalStatus='NotRequired', Operation='Deactivate');
		insert upr;
        
        UserProvisioningLog upl = new UserProvisioningLog(Status='Failed', UserProvisioningRequestId=upr.Id);
        insert upl;
        
        uprLog = UserProvisioningRequestController.getRequestLogs(upr.Id);
        
        System.assertEquals(1, uprLog.size());   
    }
    
    @isTest
    static void validateGetRequestLogNullRecord() { 
        List<UserProvisioningLog> uprLog = new List<UserProvisioningLog>();
        
        uprLog = UserProvisioningRequestController.getRequestLogs(null);
        System.assertEquals(0, uprLog.size());   
    }
    
    @isTest
    static void validateGetRequestLogNoRecords() { 
        List<UserProvisioningLog> uprLog = new List<UserProvisioningLog>();
        UserProvisioningRequest upr = new UserProvisioningRequest(AppName='Test', State='Completed', ApprovalStatus='NotRequired', Operation='Deactivate');
		insert upr;
        
        UserProvisioningLog upl = new UserProvisioningLog(Status='Failed');
        insert upl;
        
        uprLog = UserProvisioningRequestController.getRequestLogs(upr.Id);
        
        System.assertEquals(0, uprLog.size());   
    }
    
    @isTest
    static void validateGetFailedRequestsByAppNameSearch() {
        UserProvisioningRequest upr = new UserProvisioningRequest(AppName='Test', State='Failed', ApprovalStatus='NotRequired', Operation='Deactivate');
        UserProvisioningRequest upr2 = new UserProvisioningRequest(AppName='NoAppear', State='Failed', ApprovalStatus='NotRequired', Operation='Create');
        insert upr;
        insert upr2;
        
        List<UserProvisioningRequest> failedUprs = new List<UserProvisioningRequest>();
        failedUprs = UserProvisioningRequestController.getFailedRequestsBySearch('Test');
        
        System.assertEquals(failedUprs.size(), 1);
        System.assertEquals(failedUprs.get(0).Id, upr.Id);    
    }
    
    @isTest
    static void validateGetAllRequestsByAppNameSearch() {
        UserProvisioningRequest upr = new UserProvisioningRequest(AppName='Test', State='Failed', ApprovalStatus='NotRequired', Operation='Deactivate');
        UserProvisioningRequest upr2 = new UserProvisioningRequest(AppName='NoAppear', State='Failed', ApprovalStatus='NotRequired', Operation='Create');
        insert upr;
        insert upr2;
        
        List<UserProvisioningRequest> failedUprs = new List<UserProvisioningRequest>();
        failedUprs = UserProvisioningRequestController.getAllRequestsBySearch('Test');
        
        System.assertEquals(failedUprs.size(), 1);
        System.assertEquals(failedUprs.get(0).Id, upr.Id);    
    }
}