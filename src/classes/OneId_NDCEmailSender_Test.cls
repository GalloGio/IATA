@isTest
public class OneId_NDCEmailSender_Test {
    
    @isTest
    public static void emailTest() {
        
        String accountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account ac = new Account(RecordTypeId = accountRecordTypeId, Name ='NonAirlineAcc');
        insert ac;
        Account_Role__c acRole = new Account_Role__c(Account__c = ac.Id);
        insert acRole;
        Account_Role_Service__c acServ = new Account_Role_Service__c(Account_Role__c = acRole.Id);
        insert acServ;
        NDC_Account_Service_Detail__c det = new NDC_Account_Service_Detail__c(Account_Role_Service__c = acServ.Id, Contact_Email__c = 'emailrecievertest@example.com', NDC_capable__c = true);
        insert det;
        
        OneId_NDCEmailSender.EmailRequest reqData = new OneId_NDCEmailSender.EmailRequest();
        
        reqData.contactPerson = 'cperson';
		reqData.contactCompanyName = 'cname';
		reqData.contactEmail = 'cemail@example.com';
        reqData.contactRequestOption = 'reqOption';
        reqData.receiverId = acRole.Id;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Mail'; //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        RestContext.request = req;
        RestContext.response= res;
        
        OneId_NDCEmailSender.EmailResponse resp = new OneId_NDCEmailSender.EmailResponse();
        
        test.startTest();
        resp = OneId_NDCEmailSender.email(reqData);
        test.stopTest();
        
        system.assertEquals(TRUE, resp.result);
    }
}