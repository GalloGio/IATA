global class AMS_PCI_WizardNotification {

	@InvocableMethod(label = 'Send PCI notification')
	public static void sendNotification(List<Id> caseIds) {
		Id caseId = caseIds[0];
		//AMSU-177 -  added "Contact.Account.IATA_ISO_Country__r.BSP__c,"
		Case cse = [SELECT Id, CaseNumber, IATA_Code__c, ContactId, Contact.Name, AccountId, Account.IATACode__c, Contact.Account.IATA_ISO_Country__r.BSP__c, Contact.Preferred_Language__c FROM Case WHERE Id = :caseId];

		if(cse.contactId == null) {
			return;
		}

		List<User> users = getContactUser(cse.contactId);
		User usr;
		if(users.isEmpty()) {
			return;
		} else {
			usr = users[0];
		}

		//AMSU-177 -  added new BSP Parameter
		EmailTemplate template = getTemplate(cse.Contact.Preferred_Language__c, cse.Contact.Account.IATA_ISO_Country__r.BSP__c);

		if(template == null) {
			return;
		}

		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];
		List<Attachment> attechments = getAttachments(template.Id);
		Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
		emailToSend.saveAsActivity = false;
		emailToSend.setTargetObjectId(usr.Id);
		emailToSend.setOrgWideEmailAddressId(owea[0].Id);

		String subject = template.Subject;
		String htmlBody = template.HtmlValue;
		String textBody = template.Body;

		subject = subject.replace('{!Case.CaseNumber} ', cse.CaseNumber);
        emailToSend.setSubject(subject);

        String caseNumber = cse.CaseNumber == null ? '' : cse.CaseNumber;
        String iatacode = cse.AccountId == null || cse.Account.IATACode__c == null ? '' : cse.Account.IATACode__c;
        String sContactName = String.isBlank(cse.Contact.Name) ? '' : cse.Contact.Name;
        Date dTodayPlus30 = (date.today() + 30);

       	if(!String.isBlank(htmlBody)) {
       		htmlBody = htmlBody.replace('<![CDATA[', '');
            htmlBody = htmlBody.replace('{!Contact.Name}', sContactName);
       		htmlBody = htmlBody.replace('{!Case.CaseNumber}', caseNumber);
            htmlBody = htmlBody.replace('{!Case.IATA_Code__c}', iatacode);
            htmlBody = htmlBody.replace('{!Today()+30}', dTodayPlus30.format());
            htmlBody = htmlBody.replace('{!Case.Id}', cse.Id);
            htmlBody = htmlBody.replace(']]>', '');
            emailToSend.setHtmlBody(htmlBody);
       	}

       	if(!String.isBlank(textBody)) {
       		textBody = textBody.replace('{!Contact.Name}', sContactName);
       		textBody = textBody.replace('{!Case.CaseNumber}', caseNumber);
            textBody = textBody.replace('{!Case.IATA_Code__c}', iatacode);
            textBody = textBody.replace('{!Today()+30}', dTodayPlus30.format());
            textBody = textBody.replace('{!Case.Id}', cse.Id);
       		emailToSend.setPlainTextBody(textBody);
       	}     

       	if(!attechments.isEmpty())  {  		
       		emailToSend.setFileAttachments(getAttachmentsLst(attechments));
       	}

       	if(!Test.isRunningTest()) {
       		Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {emailToSend});
       	}

       	EmailMessage emailMsg = new EmailMessage();
        emailMsg.ToAddress = usr.Email;
        emailMsg.Subject = emailToSend.getSubject();
        emailMsg.HtmlBody = emailToSend.getHtmlBody();
        emailMsg.ParentId = cse.Id; //Attach with the case
        emailMsg.MessageDate = System.now();
        emailMsg.Status = '0';       	
     
        insert emailMsg;           
	}

	//AMSU-177 -  added new BSP Parameter, and made necessary changes on  the method to use it
	public static EmailTemplate getTemplate(String lang, String BSP) {
		String filterBSP = BSP == 'No' ? 'NonBSP_' : '';
		Set<String> devNames = new Set<String> {'AMS_PCI_Compliant_' + filterBSP + lang, 'AMS_PCI_Compliant_' + filterBSP + 'EN'};
		List<EmailTemplate> templates = [SELECT Id, DeveloperName, HtmlValue, Body, Subject
										 FROM EmailTemplate 
										 WHERE DeveloperName IN :devNames];
		Map<String, EmailTemplate> mapTemplates = new Map<String, EmailTemplate>();
		
		for(EmailTemplate template : templates) {
			mapTemplates.put(template.DeveloperName, template);
		}

		return mapTemplates.get('AMS_PCI_Compliant_' + filterBSP + lang) == null ? mapTemplates.get('AMS_PCI_Compliant_' + filterBSP + 'EN') : mapTemplates.get('AMS_PCI_Compliant_' + filterBSP + lang);
	}

	public static List<Attachment> getAttachments(Id templateId) {
		return [SELECT ContentType, Body, ParentId, Id, Name FROM Attachment WHERE ParentId = :templateId];
	}

	public static List<User> getContactUser(Id contactId) {
		return [SELECT Id, ContactId, Email, Account.IATA_ISO_Country__r.BSP__c FROM User WHERE ContactId = :contactId];
	}

	public static List<Messaging.EmailFileAttachment> getAttachmentsLst(List<Attachment> attechments) {
		List<Messaging.EmailFileAttachment> emailAttachs = new list<Messaging.EmailFileAttachment>();
   		for(Attachment attach : attechments) {
   			Messaging.EmailFileAttachment emailAttc = new Messaging.EmailFileAttachment();
            emailAttc.setFileName(attach.Name);
            emailAttc.setBody(attach.Body);
            emailAttc.setContenttype(attach.ContentType);
            emailAttachs.add(emailAttc); 
   		}

   		return emailAttachs;
	}


}