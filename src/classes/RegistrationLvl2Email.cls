public without sharing class RegistrationLvl2Email {

    @InvocableMethod(label='Send Email for lvl 2 Registration' description='Send Email for lvl 2 Registration')
    public static List<Boolean> sendSingleEmail(List<Id> contactIds){   
        //MAX 150 adresses     
        try{             
            
            Id contactId = contactIds.get(0);                     

            //Get address
            Contact contact = [SELECT Name, Email FROM CONTACT WHERE Id = :contactId];
            String address = contact.Email; 

            if(address == null){
                return new List<Boolean>{false};
            }
            
            //Get email template and orgWideEmail
            EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'CSP_Registration_L2_Email_VF'];
            OrgWideEmailAddress orgWideEmail  = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address='noreply@iata.org' Limit 1];    

            Id userId = [Select Id FROM User WHERE ContactId = :contactId].Id;     

            //Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, userId, null);

            message.setReplyTo('noreply@iata.org'); 
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false);  
            message.setTemplateID(emailTemplate.Id);      
            if(orgWideEmail != null){
                message.setOrgWideEmailAddressId(orgWideEmail.Id);
            }else{
                message.setSenderDisplayName('IATA Noreply');
            }                    
                
            message.setTargetObjectId(userId);          
            message.setToAddresses(new List<String>{address});
            
            Id networkId = [SELECT Id FROM Network WHERE Name = 'CS Portal'].Id;
            string url = Network.getLoginURL(networkId).substring(0,Network.getLoginURL(networkId).indexOf('login'));
            url = url + 'my-profile?triggerL2=true';

            
            String plainBody = message.getPlainTextBody();

            if(plainBody != null) {
                plainBody = plainBody.replace('[CustomerName]', contact.Name).replace('[URL]','"'+ url +'" target="_blank"');
                message.setHtmlBody(plainBody);
            }        

            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};

            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            if (results[0].success){
                return new List<Boolean>{true};
            } else {
                return new List<Boolean>{false};
            }
        }catch(Exception e ){
            return new List<Boolean>{false};
        }
    }
}