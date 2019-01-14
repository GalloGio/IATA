global class vfIECEBC_MosaicoEditor extends vfIECEBC_Controller {
    public ApexPages.StandardController con { get; set; }
    public EBC_Template__c template { get; set; }
    
    public class RejectedSubscriber_Exception extends Exception{}
    public class Template_Not_Using_Mosaico_Template_Exception extends Exception{}
    public class Resource_Not_Ready_Exception extends Exception{}
    
    public Attachment metadata {
        get;
        set;
    }
    public String getMetadataString() {
        return metadata.Body.toString();
    }
    public Attachment templateJSON {
        get;
        set;
    }
    public String getJSONString() {
        return templateJSON.Body.toString();
    }
    public Attachment templateHTML {
        get;
        set;
    }
    public String getHTMLString() {
        return templateHTML.Body.toString();
    }
    
    public vfIECEBC_MosaicoEditor(ApexPages.StandardController stdController) {        
        this.con = stdController;
        
        if (!Test.isRunningTest()) {
        	stdController.addFields(new List<String>{'Parent_Template__c'});
        }
        
        this.template = (EBC_Template__c)stdController.getRecord();
        
        if (String.isBlank(this.template.Parent_Template__c)) {
            throw new Template_Not_Using_Mosaico_Template_Exception('This campaign is not using a Mosaico template');
        }
        
        for(Attachment a : [Select Id, Name, Body From Attachment Where ParentId = :this.template.Id]) {
            if (a.Name == 'metadata.json') this.metadata = a;
            if (a.Name == 'template.json') this.templateJSON = a;
            if (a.Name == 'template.html') this.templateHTML = a;
        }
    }
    
    webService static Boolean saveTemplate(Id templateId, String metadataContent, String JSONContent, String xHtmlContent) {
        EBC_Template__c t = [Select Id, (Select Id, Name From Attachments) From EBC_Template__c Where Id = :templateId AND OwnerId = :UserInfo.getUserId()];
        Blob previousOutput;
        List<Attachment> previousHtmlAttachment = [Select Id, Body From Attachment Where ParentId = :templateId AND name = 'template.html'];
        if (previousHtmlAttachment.size() > 0) previousOutput = previousHtmlAttachment[0].Body;
        
        
        delete [Select Id From EBC_Template_Resource__c Where EBC_Template__c = :t.Id];        
        
        List<Attachment> newAttachments = new List<Attachment>();
        Attachment a;
        
        // Metadata
        a = new Attachment();
        a.Name = 'metadata.json';
        a.ContentType = 'application/json';
        a.Body = Blob.valueOf(metadataContent);
        a.ParentId = t.Id;
        if (t.Attachments.size() > 0) {
            for(Attachment existingAttachment : t.Attachments) {
                if (existingAttachment.name == a.Name) a.Id = existingAttachment.Id;
            }
        }
        newAttachments.add(a);
        
        // JSON
        a = new Attachment();
        a.Name = 'template.json';
        a.ContentType = 'application/json';
        a.Body = Blob.valueOf(JSONContent);
        a.ParentId = t.Id;
        if (t.Attachments.size() > 0) {
            for(Attachment existingAttachment : t.Attachments) {
                if (existingAttachment.name == a.Name) a.Id = existingAttachment.Id;
            }
        }
        newAttachments.add(a);
        
        // Html
		xHtmlContent = xHtmlContent.replaceAll('services/apexrest/Resources/(00P[a-zA-Z0-9]{15})', '{EBCResource' + '{' + '$1' + '}' + '/EBCResource}');

        Pattern p = Pattern.compile(vfIECEBC_Template.regexImagePlaceholder);
        Matcher mo = p.matcher(xHtmlContent);
        
        List<EBC_Template_Resource__c> trs = new List<EBC_Template_Resource__c>();
        List<Id> attachmentIds = new List<Id>();
        while (mo.find()) attachmentIds.add(mo.group(1));
        for(Attachment image : [Select Id, ParentId From Attachment Where Id in :attachmentIds]) {
            trs.add(new EBC_Template_Resource__c(
            	EBC_Resource__c = image.ParentId,
                EBC_Template__c = t.Id
            ));
        }
        insert trs;

        a = new Attachment();
        a.Name = 'template.html';
        a.ContentType = 'text/html';
        a.Body = Blob.valueOf(xHtmlContent);
        Boolean previousOutputChanged = previousOutput != a.Body;
        a.ParentId = t.Id;
        if (t.Attachments.size() > 0) {
            for(Attachment existingAttachment : t.Attachments) {
                if (existingAttachment.name == a.Name) a.Id = existingAttachment.Id;
            }
        }
        newAttachments.add(a);
        
        upsert newAttachments;
        
        if (previousOutputChanged) {
        	t.Is_Tested__c = false;
        	update t;
        }
        
        return true;
    }
    
    public class DailyLimitReached_Exception extends Exception {}
    public class EmptyTemplate_Exception extends Exception {}
    
    public Integer getDailyCount() {
		return getStaticDailyCount(template.Id);        
    }
    
    public static Integer getStaticDailyCount(Id templateId) {
        datetime dt = System.now()-1;
        return Database.countQuery('SELECT count() FROM EBC_Template_Test__c WHERE EBC_Template__c = :templateId AND Event_Date__c >= :dt') + 1;
    }
    
    webService static Integer dailyCount(Id templateId) {
        return getStaticDailyCount(templateId);
    }
    
    webService static void sendTest(Id templateId, String email) {
        Integer dailyCount = getStaticDailyCount(templateId);

        if (dailyCount > 10) {
            throw new DailyLimitReached_Exception('Daily limit of 10 tests for that design/template has been reached.');
        }
        
        EBC_Template__c template = [
            Select
                Id,
                External_Id__c,
            	TriggSend_Id__c,
                Name,
            	Audience__c
            From EBC_Template__c
            Where Id = :templateId
        ];
        
        String body = vfIECEBC_Template.getTemplateHtml(template.Id, true, null, null);
        
        if (body == 'No Content' && !Test.isRunningTest()) {
            throw new EmptyTemplate_Exception('Please fill your template with content and save before sending a test email.');
        }
        
        System.debug('Sending a test email to ' + email);
        
        System.debug(body);
        System.debug(template.External_Id__c);
        if (template.External_Id__c == null) {
            template.External_Id__c = IECEBC_ETTemplateCreate.pushEmailTemplate(String.valueOf(template.Id), 'This is a rendering test for eBroadcast', body, 'HTML');
        } else {
            IECEBC_ETTemplateCreate.updateEmailTemplate(template.External_Id__c, 'This is a rendering test for eBroadcast', body, 'HTML');
        }
        
        String mailingId = 'TEST_' + template.Id + '_'+IECEBC_Utility.generateRandomString(12);
        
        IECEBC_ETTriggeredSendDefinitionCreate.createTriggeredSendDefinition(mailingId, template.External_Id__c, 'EBC', 'f12d235d-74b6-e611-8302-8cdcd4afd9e9');
        IECEBC_ETTriggeredSendDefinitionStart.updateTriggeredSendDefinition(mailingId);
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('AGENCY_NAME', 'Agency Inc.');
        attributes.put('SFID', '1234');
        attributes.put('EMAIL', email);
        
        if (template.Audience__c == 'Agency') {
            attributes.put('AGENCY_STATE', 'Sample State');
            attributes.put('AGENCY_COUNTRY', 'Sample Country');
            attributes.put('AGENCY_ACCREDITATIONCLASS', 'Sample Class');
            attributes.put('AGENCY_LOCATIONTYPE', 'Sample Type');
        } else if (template.Audience__c == 'Agent') {
            attributes.put('AGENT_FIRSTNAME', 'John');
            attributes.put('AGENT_LASTNAME', 'Doe');
        }
        
        IECEBC_ETEmailSend.sendSingleEmail(mailingId, 'TEST_' + email, attributes);
        
        if (IECEBC_ETEmailSend.failureDetails == null) {
            template.Is_Tested__c = true;
            
            EBC_Template_Test__c tt = new EBC_Template_Test__c();
            tt.EBC_Template__c = template.Id;
            tt.Event_Date__c = Datetime.now();
            tt.External_Id__c = mailingId;
            tt.To__c = email;
            insert tt;
            
            template.TriggSend_Id__c = mailingId;
            
            update template;
        } else {
            for(String emailAddress : IECEBC_ETEmailSend.failureDetails.keySet()) {
                System.debug(IECEBC_ETEmailSend.failureDetails.get(emailAddress));
                throw new RejectedSubscriber_Exception('Email Address Rejected');
            }
        }
    }
}