@RestResource(urlMapping='/Mail/*')
global with sharing class OneId_NDCEmailSender {
    
    private static final String errormsg='';
    
    global class EmailRequest {
        public String contactPerson;
        public String contactCompanyName;
        public String contactEmail;
        public String contactRequestOption;
        public String receiverId;
    }
    
    global class EmailResponse {
        public Boolean result;
    }
    
	@HttpPost
    global static EmailResponse email(EmailRequest reqData) {
        
        RestResponse res = RestContext.response;
        String troubleshooting = Label.NDC_Troubleshooting;
        
        res.addHeader('Content-Type', 'application/json');
        
        EmailResponse ucr = new EmailResponse();
        
        try{
            List<NDC_Account_Service_Detail__c> recieverAccRoleDet = [SELECT Id, Contact_Email__c, Account_Role_Service__r.Account_Role__r.Account__r.Name 
                                                                      FROM NDC_Account_Service_Detail__c 
                                                                      WHERE Account_Role_Service__r.Account_Role__c =: reqData.receiverId LIMIT 1];
            
            if (recieverAccRoleDet.size() > 0) {
                
                String templateContact = '{0} from {1} is interested in partnering with you in an NDC deployment; Contact Request is about: {2}; Please find the contact details below: {3}';
                List<Object> parameters = new List<Object> {reqData.contactPerson, reqData.contactCompanyName, reqData.contactRequestOption, reqData.contactEmail};
                    
                    OrgWideEmailAddress address = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];
                
                Messaging.SingleEmailMessage contactMessage = new Messaging.SingleEmailMessage();
                contactMessage.toAddresses = new String[] { recieverAccRoleDet[0].Contact_Email__c };
                    contactMessage.optOutPolicy = 'FILTER';
                contactMessage.setSaveAsActivity(false);
                contactMessage.subject = 'NDC Matchmaker - New Contact Request';
                contactMessage.plainTextBody = string.format(templateContact, parameters);
                contactMessage.setOrgWideEmailAddressId(address.Id);
                
                Messaging.SingleEmailMessage responseMessage = new Messaging.SingleEmailMessage();
                responseMessage.toAddresses = new String[] { reqData.contactEmail };
                    responseMessage.optOutPolicy = 'FILTER';
                responseMessage.setSaveAsActivity(false);
                responseMessage.subject = 'NDC Matchmaker - New Contact Request Confirmation';
                responseMessage.HtmlBody = 'Thank you for using the NDC Matchmaker. Your contact request has been sent to ' +
                    						  recieverAccRoleDet[0].Account_Role_Service__r.Account_Role__r.Account__r.Name + 
                                              '. If you did not trigger this contact request, please contact the NDC team ' + 
                    											   			  								    '<a href="' + 
                    																					    troubleshooting + 
                    																					     '">here.</a>';
                responseMessage.setOrgWideEmailAddressId(address.Id);
                
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {contactMessage, responseMessage};
                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(messages);
                
                if(resultMail[0].isSuccess()){
                    res.statusCode=200;
                    ucr.result = TRUE;
                    
                    
                }
                else{
                    res.statusCode=500;
                    ucr.result = FALSE;
                }
            } else {
                res.statusCode=500;
                ucr.result = FALSE;
            }
            
        } catch (Exception ex){
            res.statusCode=500;
            ucr.result = FALSE;
        }
        return ucr;
    }
}