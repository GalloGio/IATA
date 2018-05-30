global  class AMS_PCI_Batch_Remainder implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

	private Integer batchScope {get;set;}
	global List<ResultWrapper> lstResult {get;set;}

	global AMS_PCI_Batch_Remainder() {
		this.batchScope = 200;
		this.lstResult = new List<ResultWrapper>();
	}

	global AMS_PCI_Batch_Remainder(Integer batchScope) {
		this.batchScope = batchScope;
		this.lstResult = new List<ResultWrapper>();
	}

	public static void start(String cron, Integer scope) {
        if(!Test.isRunningTest()) {
            System.schedule('AMS PCI Remainder Batch', cron, new AMS_PCI_Batch_Remainder (scope));
        }else{
            System.schedule('AMS PCI Remainder Batch TEST', cron, new AMS_PCI_Batch_Remainder (scope));
        }        
    }

    public static void stop(){
        String sJobName = '';
        if(!Test.isRunningTest()) {
            sJobName = 'AMS PCI Remainder Batch';
        }else{
            sJobName = 'AMS PCI Remainder Batch TEST';
        }
        
        List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :sJobName limit 1]; 
        
        if(SCHEDULE_ID.size() > 0){
            System.abortJob(SCHEDULE_ID[0].Id);
        }
    }
	
	global void execute(SchedulableContext sc) {
		Database.executeBatch(this, this.batchScope);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
		String accountStatus = AMS_Utils.ACC_S0_TERMINATED;
		String reason = 'PCI DSS Compliant';
		List<EmailTemplate> templates = getEmailTemplates('AMS_PCI_Compliant_reminder_%');
		List<String> subjects = new List<String>();

		for(EmailTemplate t : templates) {
			if(!String.isBlank(t.Subject)) {
				subjects.add(t.Subject);
			}
		}

		system.debug('subjects: ' + subjects);
		
		String query = 'SELECT Id, CaseNumber, Oscar__c, Reason1__c, CreatedDate, IATA_Code__c, ContactId, Contact.Name, AccountId, Account.Is_PCI_compliant__c, '; 
		query += ' Account.IATACode__c, Contact.Preferred_Language__c, Account.IATA_ISO_Country__c, Account.IATA_ISO_Country__r.Name, Account.IATA_ISO_Country__r.Region__c FROM Case WHERE';
		query += ' RecordTypeId = :recordTypeId AND Account.Status__c != :accountStatus AND Account.Is_PCI_compliant__c = NULL AND IsClosed = false AND Reason1__c = :reason AND';
		query += ' CreatedDate < LAST_N_DAYS:14 AND Id NOT IN (SELECT ParentId FROM EmailMessage WHERE Subject IN :subjects)';

		system.debug('query: ' + query);
		
		return Database.getQueryLocator(query);	
	}

	global void execute(Database.BatchableContext BC, List<Case> scope) {
		Id orgAddressId = getOrgEmailAddressId('agencymanagement@iata.org');
		List<EmailTemplate> templates = getEmailTemplates('AMS_PCI_Compliant_reminder_%');

		Set<Id> contactsIds = new Set<Id>();
		for(Case cse : scope) {
			if(!String.isBlank(cse.ContactId)) {
				contactsIds.add(cse.ContactId);
			}
		}
		if(contactsIds.isEmpty()) {
			for(Case cse : scope) {
				String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
				String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
				lstResult.add(new ResultWrapper(cse.CaseNumber, '-', countryName, regionName, '-', '-', 'Case without contact', false));
			}
			return;
		}

		List<User> users = [SELECT ContactId, Id, Email FROM User WHERE ContactId = :contactsIds];
		Map<Id,User> contactUserMap = new Map<Id,User>();
		for(User user: users){
			contactUserMap.put(user.ContactId, user);
		}

		Map<String, EmailTemplate> mapTemplates = new Map<String, EmailTemplate>();
		for(EmailTemplate template : templates) {
			mapTemplates.put(template.DeveloperName, template);
		}

		sendNotification(scope, orgAddressId, mapTemplates, contactUserMap, lstResult);
	}

	global void finish(Database.BatchableContext BC) {
		sendReport(lstResult);
	}

	public static Id getOrgEmailAddressId(String orgAddress) {
		List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgAddress];

		if(owea.isEmpty()) {
			return null;
		}

		return owea[0].Id;
	}

	public static List<EmailTemplate> getEmailTemplates(String prefix) {
		List<EmailTemplate> templates = [SELECT Id, DeveloperName, HtmlValue, Body, Subject 
										 FROM EmailTemplate 
										 WHERE DeveloperName LIKE :prefix];

		return templates;
	}

	public static void sendNotification(List<Case> cases, Id orgAddressId, Map<String, EmailTemplate> mapTemplates, Map<Id,User> contactUserMap, List<ResultWrapper> lstResult) {
		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
		List<EmailMessage> emailToInsert = new List<EmailMessage>();

		for(Case cse :cases) {

			if(cse.ContactId == null) {
				String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
				String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
				lstResult.add(new ResultWrapper(cse.CaseNumber, '-', countryName, regionName, '-', '-', 'Case without contact', false));
				continue;
			}

			User usr = contactUserMap.get(cse.contactId);
			if(usr == null) {
				String contactName = cse.Contact.Name;
				String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
				String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
				lstResult.add(new ResultWrapper(cse.CaseNumber, contactName, countryName, regionName, '-', '-', 'Contact without user ', false));
				continue;
			}

			system.debug('has user');

			String emailTemplateName;
			if(String.isBlank(cse.Contact.Preferred_Language__c) || cse.Contact.Preferred_Language__c == 'English') {
				emailTemplateName = 'AMS_PCI_Compliant_reminder_EN';
			} else {
				emailTemplateName = 'AMS_PCI_Compliant_reminder_' + cse.Contact.Preferred_Language__c;
			}	

			EmailTemplate template = mapTemplates.get(emailTemplateName);
			if(template == null && emailTemplateName == 'AMS_PCI_Compliant_reminder_EN') {
				String contactName = cse.Contact.Name;
				String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
				String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
				String preferredLang = String.isBlank(cse.Contact.Preferred_Language__c) ? '-' : cse.Contact.Preferred_Language__c;
				lstResult.add(new ResultWrapper(cse.CaseNumber, contactName, countryName, regionName, preferredLang, emailTemplateName, 'Template not found ', false));
				continue;
			} else if(template == null) {
				emailTemplateName = 'AMS_PCI_Compliant_reminder_EN';
				template = mapTemplates.get('AMS_PCI_Compliant_reminder_EN');
			}

			String subject = template.Subject;

			Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
			emailToSend.saveAsActivity = false;
			emailToSend.setTargetObjectId(usr.Id);
			emailToSend.setOrgWideEmailAddressId(orgAddressId);
			emailToSend.setSubject(subject);

			String iataCode = cse.AccountId == null ? '' : cse.Account.IATACode__c;
			String contactName = cse.Contact.Name;
			Datetime dT = cse.CreatedDate.addDays(30);
    		Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());

			String htmlBody = template.HtmlValue;
			String textBody = template.Body;

			if(!String.isBlank(htmlBody)) {
				htmlBody = htmlBody.replace('<![CDATA[', '');
	            htmlBody = htmlBody.replace('{!Case.Contact}', contactName);
	            htmlBody = htmlBody.replace('{!Case.IATA_Code__c}', iatacode);
	            htmlBody = htmlBody.replace('{!Case.CreatedDate+30}', myDate.format());
            	htmlBody = htmlBody.replace('{!Case.Id}', cse.Id);
	            htmlBody = htmlBody.replace(']]>', '');
	            emailToSend.setHtmlBody(htmlBody);
			} 

			if(!String.isBlank(textBody)) {
				textBody = textBody.replace('{!Case.Contact}}', contactName);
	            textBody = textBody.replace('{!Case.IATA_Code__c}', iatacode);
	            textBody = textBody.replace('{!Case.CreatedDate+30}', myDate.format());
	            textBody = textBody.replace('{!Case.Id}', cse.Id);
	       		emailToSend.setPlainTextBody(textBody);
   			}

   			mailsToSend.add(emailToSend);

   			system.debug('emailToSend: ' + emailToSend);

   			EmailMessage emailMsg = new EmailMessage();
	        emailMsg.ToAddress = usr.Email;
	        emailMsg.Subject = emailToSend.getSubject();
	        emailMsg.HtmlBody = emailToSend.getHtmlBody();
	        emailMsg.ParentId = cse.Id; //Attach with the case
	        emailMsg.MessageDate = System.now();
	        emailMsg.Status = '0';

	        emailToInsert.add(emailMsg);

	        system.debug('emailMsg: ' + emailMsg);

	        String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
	        String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
			String preferredLang = String.isBlank(cse.Contact.Preferred_Language__c) ? '-' : cse.Contact.Preferred_Language__c;
			lstResult.add(new ResultWrapper(cse.CaseNumber, contactName, countryName, regionName, preferredLang, emailTemplateName, 'Success', true));
		}
		
		if(!Test.isRunningTest() && !mailsToSend.isEmpty()) {
			Messaging.SendEmailResult[] EmailResult = Messaging.sendEmail(mailsToSend);
	    	insert emailToInsert;
	 	}
	}

	public void sendReport(List<ResultWrapper> results) {
		String body = 'Case Number,Contact Name, Country, Region, Preferred Language, Template Name, Sended, Error Message\n';

		for(ResultWrapper result : results) {
			body += result.caseNumber + ',' + result.ContactName + ',' + result.countryName + ',' + result.regionName + ',' + result.preferredLang + ',' + result.templateName + ',' + result.sended + ',' + result.errorMessage + '\n';
		}

		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvReport = Blob.valueOf(body);
        csvAttc.setFileName('PCI Remainder report.csv');
        csvAttc.setBody(csvReport);

		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.subject = 'PCI Remainder report';
        message.setPlainTextBody('PCI Remainder report - Check attachment with execution results');
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};        
        
        if(!Test.isRunningTest() && !String.isBlank(Label.AMS_PCI_Remaider_Addresses)) {
        	List<String> emailAddresses = Label.AMS_PCI_Remaider_Addresses.split(';');
        	message.setToaddresses(emailAddresses);
        	Messaging.sendEmail(messages);
    	}
	}

	public class ResultWrapper {

		public String caseNumber {get;set;}
		public String contactName {get;set;}
		public Boolean sended {get;set;}
		public String errorMessage {get;set;}
		public String countryName {get;set;}
		public String regionName {get;set;}
		public String preferredLang {get;set;}
		public String templateName {get;set;}

		public ResultWrapper(String caseNumber, String contactName, String countryName, String regionName, String preferredLang, String templateName, String errorMessage, Boolean sended) {
			this.caseNumber = String.isBlank(caseNumber) ? '' : caseNumber;
			this.contactName = String.isBlank(contactName) ? '' : contactName.escapeCSV();
			this.countryName = String.isBlank(countryName) ? '' : countryName.escapeCSV();
			this.regionName = String.isBlank(regionName) ? '' : regionName.escapeCSV();
			this.errorMessage = String.isBlank(errorMessage) ? '' : errorMessage;
			this.sended = sended;
			this.preferredLang = preferredLang.escapeCSV();
			this.templateName = templateName.escapeCSV();
		}

	}

}