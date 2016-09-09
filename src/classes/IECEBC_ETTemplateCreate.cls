public class IECEBC_ETTemplateCreate {
    class UnexpectedResponse_Exception extends Exception{}
    
    // Create the email template in ExactTarget using SOAP API (XML)  
    public static String pushEmailTemplate(String name, String subject, String body, String bodyType){
        Http http = new Http();
        
        string bodyContent = 
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
            '<Objects xsi:type="Email">' +
            '<ObjectID xsi:nil="true"/>' +
            '<Name>' + IECEBC_ETHelper.xmlEncode(name) + '</Name>' +
            '<Description>HTML template of ' + IECEBC_ETHelper.xmlEncode(name) + '</Description>' +
            '<HTMLBody><![CDATA[' + body + ']]></HTMLBody>' +
            '<Subject>' + IECEBC_ETHelper.xmlEncode(subject) + '</Subject>' +
            '<EmailType>' + IECEBC_ETHelper.xmlEncode(bodyType) + '</EmailType>' +
            '<IsHTMLPaste>true</IsHTMLPaste>' +
            '</Objects>' +
            '</CreateRequest>';
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);     
        
        HttpResponse res = http.send(req);
        String bodyRes = res.getBody();
        String templateId = '';
        if (res.getStatusCode() == 200) { 
            system.debug('Email Template is ready!');
            
            if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
                System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
                throw new UnexpectedResponse_Exception('Unexpected Response');
            }
            
            templateId = IECEBC_ETHelper.parse(res, 'NewID');
            system.debug('Email template creation finishes with id :' + templateId);
            return templateId;
        } else{
            System.debug(res);
            throw new UnexpectedResponse_Exception('Unexpected Response');
        }        
    }     
    
    // retrieve the email template attachments list from SFDC using the email template ID
    static String getEmailTempalteAttachments(Id emailTempId) { 
        String att = '';
        List<Attachment> attachments = [Select Id, ParentId, Name, body, ContentType From Attachment where ParentId = :emailTempId];
        
        for(Attachment a : attachments){                      
            if(a.ContentType.Contains('text'))
            {
                att =+ '<br/>' + a.body.toString();
            }
            else{
                if(a.ContentType.Contains('image'))
                {
                    att =+ '<br/> image';
                }              
            }
        }                
        return att;
    }
    
    // Create the email template in ExactTarget using SOAP API (XML)  
    public static String createEmailTemplate(Id emailTempId, String campaignName, String contactType){
        Http http = new Http();
        String emailAttachments = getEmailTempalteAttachments(emailTempId);
        EBC_Template__c emailTemplate = [Select Name from EBC_Template__c where id =:emailTempId];
        String emailTemplateName = emailTemplate.Name + ' for ' + campaignName;
        
        string requiredCode = '<table cellpadding="2" cellspacing="0" width="600" ID="Table5" Border=0><tr><td><font face="verdana" size="1" color="#444444">This email was sent to:  %%emailaddr%% <br><br><b>Email Sent By:</b> %%Member_Busname%%<br>%%Member_Addr%% %%Member_City%%, %%Member_State%%, %%Member_PostalCode%%, %%Member_Country%%<br><br></font></td></tr></table>' + 
            '<a href="%%profile_center_url%%" alias="Update Profile">Update Profile</a>';
        string bodyContent = 
            '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
            '<Objects xsi:type="Email">' +
            '<ObjectID xsi:nil="true"/>' +
            '<Name>' +
            IECEBC_ETHelper.xmlEncode(emailTemplateName) +
            '</Name>' +
            '<Description>This is a new Summer Time Campaign Template !!! </Description>' +
            '<HTMLBody><![CDATA[' +
            emailAttachments +
            requiredCode +
            ']]></HTMLBody>' +
            '<Subject>Email Test</Subject>' +
            '<EmailType>HTML</EmailType>' +
            '<IsHTMLPaste>true</IsHTMLPaste>' +
            '</Objects>' +
            '</CreateRequest>';
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);     
        
        HttpResponse res = http.send(req);
        String bodyRes = res.getBody();
        String templateId = '';
        if (res.getStatusCode() == 200) { 
            system.debug('Email Template is ready!');
            templateId = IECEBC_ETHelper.parse(res, 'NewID');
            system.debug('Email template creation finishes with id :' + templateId);
            IECEBC_ETTriggeredSendDefinitionCreate.createTriggeredSendDefinition(templateId, contactType, campaignName);
            return templateId;
        }else{
            system.debug('This is a bad request, email template is failed to sent to ET!');
            return null;
        }        
    }     
    
    // Update email template in ExactTarget using SOAP API (XML)  
    public static void updateEmailTemplate(String emailTempId, String subject){
        updateEmailTemplate(emailTempId, subject, null, null);
    }
    // Update email template in ExactTarget using SOAP API (XML)  
    public static void updateEmailTemplate(String emailTempId, String subject, String body, String bodyType){
        Http http = new Http();
        
        string bodyContent = ''
            + '<UpdateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
            + '<Options/>'
            + '<Objects xsi:type="ns1:Email" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'
            + '<ID>' + IECEBC_ETHelper.xmlEncode(emailTempId) + '</ID>'
            ;
        if (body != null) {
            bodyContent += '<HTMLBody><![CDATA[' + body + ']]></HTMLBody>';
        }
        if (bodyType != null) {
            bodyContent += '<EmailType>' + IECEBC_ETHelper.xmlEncode(bodyType) + '</EmailType>';
        }
        if (subject != null) {
            bodyContent += '<Subject>' + IECEBC_ETHelper.xmlEncode(subject) + '</Subject>';
        }
        bodyContent += '</Objects>' 
            + '</UpdateRequest>';
        
        HttpRequest req = new HttpRequest();
        req.setTimeout(IECEBC_ETInit.TimeOut);
        IECEBC_ETHelper.SetSoapRequest(req, 'Update', bodyContent);     
        
        HttpResponse res = http.send(req);
        String bodyRes = res.getBody();
        String templateId = '';
        if (res.getStatusCode() == 200) {            
            if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
                System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
                throw new UnexpectedResponse_Exception('Unexpected Response');
            }else{
                system.debug('Email Template is updated!');
            }
        } else{
            System.debug(res);
            throw new UnexpectedResponse_Exception('Unexpected Response');
        }        
    }
}