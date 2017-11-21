public with sharing class sendSingleTrackedEmailController {

    public map<String,Sender_Tracked_Emails__c> SENDER_TRACKED_EMAILS = Sender_Tracked_Emails__c.getAll();

    public Tracked_Email__c email {get; set;}

    public Case cse {get;set;}
   
    public Boolean isInConsole {get;set;}
	public String processStatus {get;set;}

	public Boolean setHtmlBodyFromJavascript {get;set;}
	public String templateBody {set;get;}
   
    // This variable is not used anymore. It stays here for deployment reasons
    public Boolean isNew {
        get {return this.email.Id==null;}
    }

    public String caseThreadId {get{if(caseThreadId == null){caseThreadId = '';} return caseThreadId;} set;}

    public sendSingleTrackedEmailController thisController {
        get{ return this; }
    }
    
    public Boolean showTemplatePanel {get;set;}
    public Boolean showRecipientsPanel {get;set;}
    public Boolean showAttachmentsPanel {get;set;}
    public Boolean showPreviewPanel {get;set;}
    
    public Map<String, SelectTrackedEmailAttachmentsController.DocumentSkeleton> documentMap{
        get{
            if(documentMap == null){
                documentMap = new Map<String,SelectTrackedEmailAttachmentsController.DocumentSkeleton>();
            }
            return documentMap;
        }
        set;
    }
    
    public List<String> documents {get{return new List<String>(documentMap.keySet());}}
    
    public Boolean isDocumentMapEmpty{
        get{
            return documentMap == null || documentMap.isEmpty();
        }
    }
    
    public Set<Id> uploadedDocuments = new Set<Id>();
    
    public String selectedFrom {
        get{
            if(selectedFrom == null && ApexPages.currentPage().getParameters().get('sender') != null){
                selectedFrom = ApexPages.currentPage().getParameters().get('sender');
            }
            else if(email.FromAddress__c != null){
                selectedFrom = email.FromAddress__c;
            }
            else{
                selectedFrom = 'agencymanagement@iata.org';
            }
            return selectedFrom;
        }
        set {
            email.FromAddress__c = value;
            for(String name : SENDER_TRACKED_EMAILS.keySet()){
                if(SENDER_TRACKED_EMAILS.get(name).email__c == value){
                    email.FromName__c = name;
                }
            }
        }
    }

    public list<SelectOption> fromAddresses; 
    
    public list<SelectOption> getFromAddresses() {
        if(fromAddresses == null){
            fromAddresses = new List<SelectOption>();
            for ( Sender_Tracked_Emails__c ste: SENDER_TRACKED_EMAILS.values() ) {
                String value = '"' + ste.name + '" <' + ste.email__c + '>';
                fromAddresses.add(new SelectOption(ste.email__c, value));
            }
        }
        return fromAddresses;
    }

    public EmailTemplate emailTemplate {get;set;}

    public String bodyHeader {get;set;}
    public String bodyFooter {get;set;}
    
    public String rawText {get;set;}
    public String plainText {get;set;}
    
    public Boolean isBodyEditable {
        get{ if(isBodyEditable == null){ isBodyEditable = true; } return isBodyEditable;}
        set; 
    }
    
    public Boolean isSwitchable {
        get{ if(isSwitchable == null){ isSwitchable = true; } return isSwitchable;}
        set;
    }
    
    public Boolean isHtml {
        get{ if(isHtml == null){ isHtml = true; } return isHtml;}
        set;
    }
    
/*    public Boolean sendEmail {
        get{ if(sendEmail == null){ sendEmail = false; } return sendEmail;}
        set;
    }*/
    
    public sendSingleTrackedEmailController(ApexPages.StandardController stdController) {
        list<String> listFields = new list<String>{'ToContact__c', 'TextBody__c', 'Html_Body__c', 'Subject__c', 'Signaturit_Id__c', 'FromAddress__c', 'FromName__c', 'CcAddress__c', 'Case__c', 'BccAddress__c', 'AdditionalTo__c'};
        if (!Test.IsRunningtest()) stdController.addFields(listFields);
        email = (Tracked_Email__c)stdController.getRecord();

        String isInConsoleParameter = ApexPages.currentPage().getParameters().get('isInConsole');
        isInConsole = isInConsoleParameter == 'true';
        
		setHtmlBodyFromJavascript = false;
    }

	public void templateSetFromJavascript(){
		setHtmlBodyFromJavascript = false;
	}

    public void initPage(){
        if (email != null && email.Id == null ) {
            try{
				email = createNewEmail();
            }
            catch(Exception e){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A valid case is required' ));
            }

            String templateId = ApexPages.currentPage().getParameters().get('templateId');
            if(templateId != null){
	            try{
					setTemplate((Id) templateId);
	            }
	            catch(Exception e){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'templateId parameter \'' + templateId + '\' is not a valid Email Template Id' ));
	            }
            }
            else{
                String templateDeveloperName = ApexPages.currentPage().getParameters().get('template');
                if(templateDeveloperName != null){
		            try{
						setTemplate(templateDeveloperName);
		            }
		            catch(Exception e){
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'template parameter \'' + templateDeveloperName + '\' is not a valid Email Template Name' ));
		            }
                }
            }
        }
        
        bodyHeader = '';
        bodyFooter = '';
    }

    private Tracked_Email__c createNewEmail() {
        String originalEmail = ApexPages.currentPage().getParameters().get('originalEmail');
        String action = ApexPages.currentPage().getParameters().get('action');
        String reason = ApexPages.currentPage().getParameters().get('caseUpdateType');
        
        String toContactId = '';
        String additionalTo = '';
        String ccAddress = '';
        String bccAddress = '';
        String subject = '';
        String textBody = '';
        String htmlBody = '';
        
        if(originalEmail == null || (action != 'ReplyTo' && action != 'ReplyToAll' && action != 'Forward')){
            Id caseId = ApexPages.currentPage().getParameters().get('case');
            cse = [Select Id, AccountId, Account.name, Contact.email, Contact.name, Case_Thread_ID__c from Case where Id = :caseId ];
        
			toContactId = cse.ContactId;

			// Update contact if a valid toContact parameter is set in the URL
			String toContactParameter = ApexPages.currentPage().getParameters().get('toContact');
        	if(toContactParameter != null){
        		List<Contact> parameterContact = [select Id from Contact where Id =: toContactParameter];
        		if(!parameterContact.isEmpty()){
        			toContactId = parameterContact[0].Id;
        		}
        	}
            
            caseThreadId = cse.Case_Thread_ID__c;
        }
        else{
            Tracked_Email__c email = [select Id, Case__c, FromName__c, FromAddress__c, ToContact__c, CreatedDate, Email__c, AdditionalTo__c, CcAddress__c, Subject__c, BccAddress__c, Html_Body__c, TextBody__c from Tracked_Email__c where Id =: originalEmail];
            
            cse = [Select Id, AccountId, Account.name, Contact.email, Contact.name, Case_Thread_ID__c from Case where Id = :email.Case__c ];

            caseThreadId = cse.Case_Thread_ID__c;

            rawText = SignaturitUtils.pStyle + '<br/><br/><br/>'
                        + '--------------- Original Message ---------------<br/>'
                        + '<b>From:</b> "' + email.FromName__c + '" <' + email.FromAddress__c + '> [' + email.FromAddress__c + ']<br/>'
                        + '<b>Sent:</b> '+ email.CreatedDate +'<br/>'
                        + '<b>To:</b> '+ email.Email__c + (email.AdditionalTo__c != null && email.AdditionalTo__c !='' ? ';' + email.AdditionalTo__c : '') + '<br/>'
                        + '<b>Cc:</b> '+  (email.CcAddress__c != null && email.CcAddress__c !='' ? ';' + email.CcAddress__c : '')+ '<br/>'
                        + '<b>Subject:</b> '+ email.Subject__c + '<br/><br/>'
                        + email.Html_Body__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
                        
            isHtml = true;
            
            if(action == 'ReplyTo'){
                subject = 'RE: ' + email.Subject__c;
                toContactId = email.ToContact__c;
            }
            else if(action == 'ReplyToAll'){
                subject = 'RE: ' + email.Subject__c;
                toContactId = email.ToContact__c;

                additionalTo = email.AdditionalTo__c;
                ccAddress = email.CcAddress__c;
                bccAddress = email.BccAddress__c;
            }
            else{
                subject = 'FW: ' + email.Subject__c;
                toContactId = null;
                
                // Add attachments of the original email if any
                List<Attachment> attachments = [select Id, Name, BodyLength from Attachment where parentId =: originalEmail];
                
                if(!attachments.isEmpty()){        
                    for(Attachment attachment : attachments){
                        documentMap.put(attachment.Id, new SelectTrackedEmailAttachmentsController.DocumentSkeleton(attachment.Name, attachment.BodyLength, 'original attachment'));
                    }
                }
            }
        }
        
        return new Tracked_Email__c(
            Case__c = cse.Id,
            ToContact__c = toContactId,
            AdditionalTo__c = additionalTo,
            CcAddress__c = ccAddress,
            BccAddress__c = bccAddress,
            Subject__c = subject,
            TextBody__c = textBody,
            Html_Body__c = htmlBody,
            Status__c = 'Queued',
            Reason__c = reason
        );
    }
    
    // This method is not used anymore. It stays here for deployment reasons
    public void applyTemplate(){
    }
    
    public void setTemplate(String templateDeveloperName){
        emailTemplate = [select Id, Name, Subject, Body, HtmlValue, Markup, BrandTemplateId, TemplateStyle, TemplateType, Encoding from EmailTemplate where DeveloperName = :templateDeveloperName][0];
        setTemplate();    
    }
    
    public void setTemplate(Id templateId){
        emailTemplate = [select Id, Name, Subject, Body, HtmlValue, Markup, BrandTemplateId, TemplateStyle, TemplateType, Encoding from EmailTemplate where Id = :templateId];
        setTemplate();    
    }
    
    public void setTemplate(){        
        // Send a fake email with this message in order to update the subject and the body if necessary
        Tracked_Email__c trackedEmail = SignaturitRest.sendDummyEmail(new List<SignaturitRest.DummyEmail>{new SignaturitRest.DummyEmail(emailTemplate, cse, email.ToContact__c)})[0];		

        // Update data
        email.Subject__c = trackedEmail.Subject__c;
        
        bodyHeader = '';
        bodyFooter = '';

        // Update data depending on the template type
        if(emailTemplate.TemplateType == 'custom'){
            rawText = SignaturitUtils.pStyle + trackedEmail.Html_Body__c;

            isHtml = true;
            isBodyEditable = false;
            isSwitchable = false;
        }
        else if(emailTemplate.TemplateType == 'html'){

        	setHtmlBodyFromJavascript = true;

			System.debug('emailTemplate.HtmlValue : ' + emailTemplate.HtmlValue);
			System.debug('trackedEmail.Html_Body__c : ' + trackedEmail.Html_Body__c);
			
			// Retrieve the tEditID parameter of the <td> tag enclosing the body in the template
			Integer int1 = emailTemplate.HtmlValue.indexOf('![CDATA[');
			
			if(emailTemplate.TemplateStyle == 'formalLetter'){
				int1 = emailTemplate.HtmlValue.indexOf('![CDATA[', int1+1);
			}
			
			String templateHeader = emailTemplate.HtmlValue.substring(0, int1);	
			System.debug('template header : ' + templateHeader);
	
			Integer int2 = templateHeader.lastIndexOf('tEditID="') + 'tEditID="'.length();			
			String tdParameters = templateHeader.substring(int2);
			System.debug('td parameters : ' + tdParameters);
	
			Integer int3 = tdParameters.indexOf('"');
			String tEditID = tdParameters.substring(0, int3);
			System.debug('tEditID : ' + tEditID);



			// Search for the tEditID in the tracked email body
			Integer int4 = trackedEmail.Html_Body__c.lastIndexOf(tEditID);
			Integer int5 = trackedEmail.Html_Body__c.indexOf('>', int4) + 1;
			
			// Header of the tracked email ends with the <td> tag containing the tEditID parameter
			bodyHeader = trackedEmail.Html_Body__c.substring(0, int5);
			System.debug('tracked email header : ' + bodyHeader);

            // Now we have to find the related </td> closing tag
			String workingCopy = trackedEmail.Html_Body__c.substring(int5);
            Integer openedTDTags = 0;
            Integer closingTabIndex1;
            Integer startIndex1 = -1;

			System.debug('Working copy : ' + workingCopy);

            while(openedTDTags >= 0){
                Integer nextOpeningTDTagIndex = workingCopy.indexOf('<td', startIndex1 + 1);
                Integer nextClosingTDTagIndex = workingCopy.indexOf('</td>', startIndex1 + 1);

                if(nextOpeningTDTagIndex == nextClosingTDTagIndex){
					// We might have a malformed template here, but at least we leave the loop
					break;
				}
                if(nextOpeningTDTagIndex < nextClosingTDTagIndex && nextOpeningTDTagIndex != -1){
                    openedTDTags++;
                    startIndex1 = nextOpeningTDTagIndex;
                }
                else{
                    openedTDTags--;
                    startIndex1 = nextClosingTDTagIndex;
	            }
            }
            
			// Body of the tracked email ends before the </td> tag we just found
			templateBody =  SignaturitUtils.pStyle + workingCopy.substring(0, startIndex1).replace('\'','\\\'').replaceAll('\r\n', ' ').replaceAll('\n\r', ' ').replaceAll('\n', ' ');

			// What remains of the string is the tracked email footer
			bodyFooter = workingCopy.substring(startIndex1);

            bodyHeader = addPx(bodyHeader);
            bodyFooter = addPx(bodyFooter);
            
            System.debug('bodyheader after setTemplate\r\n' + bodyHeader + '\r\n');
            System.debug('templateBody after setTemplate\r\n' + templateBody + '\r\n');
            System.debug('bodyfooter after setTemplate\r\n' + bodyFooter + '\r\n');
            
            isHtml = true;
            isBodyEditable = true;
            isSwitchable = false;
        }
        else if(emailTemplate.TemplateType == 'text'){
            plainText = trackedEmail.TextBody__c;
            
            isHtml = false;
            isBodyEditable = true;
            isSwitchable = true;
        }
        else if(emailTemplate.TemplateType == 'visualforce'){
            if(emailTemplate.Markup.contains('messaging:htmlEmailBody')){
                rawText = SignaturitUtils.pStyle + trackedEmail.Html_Body__c;

                isHtml = true;
                isBodyEditable = false;
                isSwitchable = false;
            }
            else{
                plainText = trackedEmail.TextBody__c;

                isHtml = false;
                isBodyEditable = true;
                isSwitchable = true;
            }
        }
        
        // Handle Template attachments
        // if we change for a new template, attachments of the preivous template must be removed
        for(String key : documentMap.keySet()){
            if(documentMap.get(key).type == 'template attachment'){
                documentMap.remove(key);
            }
        }
          
        //Add selected template attachments if any
        List<Attachment> templateAttachments = [select Name, BodyLength from Attachment where ParentId =: emailTemplate.Id];

        for(Attachment attachment : templateAttachments){
            documentMap.put(attachment.Id, new SelectTrackedEmailAttachmentsController.DocumentSkeleton(attachment.Name, attachment.BodyLength, 'template attachment'));
        }
    }
    
    private String addPx(String incompleteString){
        List<String> parts = incompleteString.split('height:');
        
        String completeString = parts[0];
        
        for(Integer i = 1; i < parts.size(); i++){
            String value = parts[i].substringBefore(';');

            completeString += 'height:' + value;
            if(! value.endsWith('px')){
                completeString += 'px';
            }
            completeString += ';' + parts[i].substringAfter(';');
        }
        
        return completeString;
    }
    
    public void switchToHtml(){
        isHtml = true;
        rawText = SignaturitUtils.pStyle + plainText.replaceAll('\r\n', '<br>').replaceAll('\n\r', '<br>').replaceAll('\n', '<br>');
    }

    public void switchToTextOnly(){
        isHtml = false;
        plainText = rawText != null? rawText.replace(SignaturitUtils.pStyle, '').replaceAll('</p>', '</p><br/>').stripHtmlTags() : '';
    }
    
    public void discardTemplate(){
        emailTemplate = null;
        bodyHeader = '';
        bodyFooter = '';
        rawText = '';
        plainText = '';
        isBodyEditable = null;
        isSwitchable = null;
        isHtml = null;
        
        //Discard documents or not?
        // documentMap.clear();
    }

    // Check that mandatory fields are filled
    private Boolean checkFields() {
        Boolean result = true;

        if (email.ToContact__c == null && (email.AdditionalTo__c == '' || email.AdditionalTo__c == null)) {
            email.ToContact__c.addError('At least one of the two fields \'To\' or \'Additional To\' must be filled');
            email.AdditionalTo__c.addError('At least one of the two fields \'To\' or \'Additional To\' must be filled');
            result = false;
        }
        
        Pattern emailPattern = Pattern.compile('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,15}|[0-9]{1,3})');
        
        // Check Additional To addresses
        if(email.AdditionalTo__c != null && email.AdditionalTo__c != ''){
            List<String> addresses = email.AdditionalTo__c.normalizeSpace().replace(' ',';').split(';');
            String message = 'The format of the following address(es) is not valid:';
            Integer errorNumber = 0;
            for(String address : addresses){
                if(address != '' && !emailPattern.matcher(address).matches()){
                    message += '<br/>' + ++errorNumber + '. ' + address;
                }
            }
            if(errorNumber > 0){
                email.AdditionalTo__c.addError(message);
                result = false;
            }        
        }
        
        // Check CC addresses
        if(email.CcAddress__c != null){
            List<String> addresses = email.CcAddress__c.normalizeSpace().replace(' ',';').split(';');
            String message = 'The format of the following address(es) is not valid:';
            Integer errorNumber = 0;
            for(String address : addresses){
                if(address != '' && !emailPattern.matcher(address).matches()){
                    message += '<br/>' + ++errorNumber + '. ' + address;
                }
            }
            if(errorNumber > 0){
                email.CcAddress__c.addError(message);
                result = false;
            }        
        }
        
        if(email.BccAddress__c != null){
            List<String> addresses = email.BccAddress__c.normalizeSpace().replace(' ',';').split(';');
            String message = 'The format of the following address(es) is not valid:';
            Integer errorNumber = 0;
            for(String address : addresses){
                if(address != '' && !emailPattern.matcher(address).matches()){
                    message += '<br/>' + ++errorNumber + '. ' + address;
                }
            }
            if(errorNumber > 0){
                email.BccAddress__c.addError(message);
                result = false;
            }        
        }       
        
        if (email.Subject__c == null || email.Subject__c == '') {
            email.Subject__c.addError('Field is mandatory');
            result = false;
        }
        if (email.Html_Body__c == null ) {
            email.Html_Body__c.addError('Field is mandatory');
            result = false;
        }

        return result;
    }
    
    public PageReference deleteAttachment(){
        SelectTrackedEmailAttachmentsController.DocumentSkeleton doc = documentMap.remove(documentToDelete);

        if(doc.type == 'uploaded document'){
            Document document = [select Id from Document where Id =: documentToDelete];
            delete document;
        }

        return null;
    }
    
    public String documentToDelete {get;set;}
    
    public PageReference sendTrackedEmail(){
        if (!checkFields()){
            return null;
        }
        
        email.Has_Attachment__c = documentMap.keySet().size() > 0;
        
        if(!email.Subject__c.endsWith(caseThreadId)){
            email.Subject__c += caseThreadId != '' ? ' ' + caseThreadId : '';
        }
        
        if(isHtml){
            email.IsHtml__c = true;
            if(Test.isRunningTest()){
                email.Html_Body__c = (rawText != null? rawText.unescapeHtml4() : '');
            }
            else{
                System.debug('rawText when sending\r\n' + rawText);
                
                email.Html_Body__c = bodyHeader + (rawText != null? rawText.unescapeHtml4() : '') + bodyFooter;
                if(!email.Html_Body__c.contains(caseThreadId)){
                    email.Html_Body__c += caseThreadId != '' ? '<br/><br/>' + caseThreadId : '';
                }
                
                System.debug('email.Html_Body__c\r\n' + email.Html_Body__c);
                
            }
            email.TextBody__c = (rawText != null? rawText.replaceAll('</p>', '</p><br/>').stripHtmlTags() : '');

            if(!email.TextBody__c.contains(caseThreadId)){
                email.TextBody__c += caseThreadId != '' ? '\r\n' + caseThreadId : '';
            }

        }
        else{
            email.IsHtml__c = false;
            email.Html_Body__c = (plainText != null ? plainText.replaceAll('\r\n', '<br>').replaceAll('\n\r', '<br>').replaceAll('\n', '<br>') : '');

            if(!email.Html_Body__c.contains(caseThreadId)){
                email.Html_Body__c += caseThreadId != '' ? '<br/><br/>' + caseThreadId : '';
            }
            
            email.TextBody__c = (plainText != null ? plainText : '');
            if(!email.TextBody__c.contains(caseThreadId)){
                email.TextBody__c += caseThreadId != '' ? '\r\n' + caseThreadId : '';
            }
        }
        
        //Update the recipients fields if not well formated
        if(email.AdditionalTo__c != null){
			email.AdditionalTo__c = email.AdditionalTo__c.normalizeSpace().replace('; ',';').replace(' ;',';').replace(' ',';');
			
			List<String> addressList = email.AdditionalTo__c.split(';');			
			List<String> cleanAddressList = new List<String>();

			for(String address : addressList){
				if(address != ''){
					cleanAddressList.add(address);
				}
        }
			
			email.AdditionalTo__c = String.join(cleanAddressList, ';');
		}
        if(email.CcAddress__c != null){
			email.CcAddress__c = email.CcAddress__c.normalizeSpace().replace('; ',';').replace(' ;',';').replace(' ',';');
			
			List<String> addressList = email.CcAddress__c.split(';');			
			List<String> cleanAddressList = new List<String>();

			for(String address : addressList){
				if(address != ''){
					cleanAddressList.add(address);
				}
			}
			
			email.CcAddress__c = String.join(cleanAddressList, ';');
        }
        if(email.BccAddress__c != null){
			email.BccAddress__c = email.BccAddress__c.normalizeSpace().replace('; ',';').replace(' ;',';').replace(' ',';');
			
			List<String> addressList = email.BccAddress__c.split(';');			
			List<String> cleanAddressList = new List<String>();

			for(String address : addressList){
				if(address != ''){
					cleanAddressList.add(address);
				}
			}
			
			email.BccAddress__c = String.join(cleanAddressList, ';');
        }

		// When sending manually several emails in a row, the "UNABLE_TO_LOCK_ROW" DML Exception might happen when inserting the tracked email
		// To prevent as much as possible, we'll make up to 5 attempts to insert the tracked email
		// If it fails, a message will be displayed to the user
		for(Integer i = 0; i < 5; i++){
			try{
				insert email;
				System.debug('Tracked Email ' + email.Subject__c + ' : insert successfull on attempt ' + (i+1));
				break;
			}
			catch (System.DMLException ex) {
				System.debug('Tracked Email ' + email.Subject__c + ' : insert error on attempt ' + (i+1));
				if(i == 4){
					System.debug('Tracked Email ' + email.Subject__c + ' : ABORTING insertion');
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'System was not able to send your tracked email, please try again.'));
					return null;
				}
			}
		}

        // Create Attachments linked to the Tracked Email record
        List<Attachment> attachments = new List<Attachment>();

        // This list will contain salesforce documents and uploaded documents
        List<Document> documents = [select Name, Body, ContentType from Document where Id in :documentMap.keySet()];
        for(Document document : documents){
            Attachment attachment = new Attachment(
                                            OwnerId = UserInfo.getUserId(),
                                            ParentId = email.Id,
                                            IsPrivate = false,
                                            Body = document.Body,
                                            Name = document.Name);
            attachments.add(attachment);
        }

        // This list will contain original email attachments (in case of forward) and template attachments 
        List<Attachment> atts = [select Name, Body, ContentType from Attachment where Id in :documentMap.keySet()];
        for(Attachment att : atts){
            Attachment attachment = new Attachment(
                                            OwnerId = UserInfo.getUserId(),
                                            ParentId = email.Id,
                                            IsPrivate = false,
                                            Body = att.Body,
                                            Name = att.Name);
            attachments.add(attachment);
        }
        
        insert attachments;
        
        //delete the uploaded documents
        List<String> uploadedDocumentIds = new List<String>();
        for(String key : documentMap.keySet()){
            if(documentMap.get(key).type == 'uploaded document'){
                uploadedDocumentIds.add(key);
            }
        }
        
        if(!uploadedDocumentIds.isEmpty()){
            List<Document> documentsToDelete = [select Id from Document where Id in : uploadedDocumentIds];
            delete documentsToDelete;
        }
        
        sendSingleTrackedEmailController.sendTrackedEmailFuture(new List<Id> {email.Id});

        processStatus = 'sent';

        if(!isInConsole){
	        String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
	        String url = retUrl==null? '/' + cse.Id : retURL;
	        PageReference pageref = new PageReference(url);
	        pageref.setRedirect(true);
	        return pageref;
	    }
        else{
        	return null;
    	}
    }

    // We use a future method to double the Heap Size limit (6Mb -> 12 Mb)
    @future(callout=true)
    public static void sendTrackedEmailFuture(List<Id> trackedEmailIds) {
        List<Tracked_Email__c> trackedEmails = [select Id, Name, Status__c, FromAddress__c, Email__c, ToContact__r.Name, ToContact__r.Email, Case__c, Html_Body__c, TextBody__c, AdditionalTo__c, CcAddress__c, BccAddress__c, Subject__c, FromName__c, Reason__c, OwnerId, Case__r.Id, Case__r.CaseNumber, Case__r.Case_Thread_ID__c from Tracked_Email__c where Id in: trackedEmailIds];

        SignaturitUtils.sendTrackedEmails(trackedEmails);
    }
    
    // Delete email and its attachments if sending fails
    private void deleteEmail(){
        // delete tracked email and attachments
        List<Attachment> attachments = [select Id from Attachment where parentId =:email.id];
        if(!attachments.isEmpty()){
            delete attachments;
        }
        delete email;
    }
    
    /**
    Redirect to retURL or home without doing changes
    **/
    public PageReference cancel() {
        processStatus = 'cancelled';
        if(!isInConsole){
        String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
        String url = retUrl==null? '/' + cse.Id : retURL;
        PageReference pageref = new PageReference(url);
        pageref.setRedirect(true);
        return pageref;
    }
        else{
        	return null;
        }
    }

    public PageReference showRecipientsPanel(){ 
        showRecipientsPanel = true;
        return null;
    }

    public PageReference showTemplatePanel(){
    	if(email.ToContact__c != null){
    		showTemplatePanel = true;
        }
        else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'If you want to use a template, the "To" field must be filled.'));
        }
        return null;
    }
     
    public PageReference showAttachmentsPanel(){ 
        showAttachmentsPanel = true;
        return null;
    }
     
    public PageReference showPreviewPanel(){ 
        showPreviewPanel = true;
        return null;
    }
}