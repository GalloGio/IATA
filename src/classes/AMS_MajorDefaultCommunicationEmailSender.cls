global class AMS_MajorDefaultCommunicationEmailSender implements Database.Batchable<sObject>, Database.Stateful {
	
	global Set<Id> contactIds {get;set;}
	global Map<Id,List<Id>> mapContactToCase {get;set;}
	global Map<Id,EmailTemplate> mapContactToTemplate {get;set;}
	global List<String> errors {get;set;}
	global ResultReport results {get;set;}
	global Id orgEmailAddressId {get;set;}
	global Blob emailExampleContent {get;set;}
	global Set<Id> onlyExternalNotification {get;set;}
	
	global AMS_MajorDefaultCommunicationEmailSender(Set<Id> contactIds, Map<Id,List<Id>> mapContactToCase, Map<Id,EmailTemplate> mapContactToTemplate, Set<Id> onlyExternalNotification) {
		this.contactIds = contactIds;
		this.mapContactToCase = mapContactToCase;
		this.mapContactToTemplate = mapContactToTemplate;
		this.errors = new List<String>();
		this.results = new ResultReport();
		this.onlyExternalNotification = onlyExternalNotification;
		this.orgEmailAddressId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'agencymanagement@iata.org'].Id;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, Name, Email, Account.Name, (SELECT Id FROM Users LIMIT 1) FROM Contact WHERE Id IN :contactIds');
	}

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
		List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();
		List<Task> activities = new List<Task>();
		List<EmailMessageWrapper> emailWrapperLst = new List<EmailMessageWrapper>();

		//load cases data
		Set<Id> caseIds = new Set<Id>();
		for(Contact c : scope) {
			for(Id caseId : mapContactToCase.get(c.Id)) {
				caseIds.add(caseId);
			}
		}

		Map<Id,Case> mapCases = new Map<Id,Case>([SELECT Id, CaseNumber, Account.Name, BSPCountry__c, Account.IATACode__c FROM Case WHERE Id IN :caseIds]);

		//merge template
		EmailMessageWrapper wrapper;
		for(Contact c : scope) {
			for(Id caseId : mapContactToCase.get(c.Id)) {
				Case cse = mapCases.get(caseId);
				EmailTemplate template = mapContactToTemplate.get(c.Id);			
				Boolean notifiyInternalGroup = !onlyExternalNotification.contains(caseId);
				if(c.Users.isEmpty()) {
					Messaging.SingleEmailMessage mail = mailToContact(c, cse, template);
					wrapper = new EmailMessageWrapper(null, mail, notifiyInternalGroup);
					wrapper.reportRow = initReportRow(c, cse);
					notifications.add(mail);
				} else {
					wrapper = mailToUser(c.Users[0], c, cse, template, notifiyInternalGroup);
					wrapper.reportRow = initReportRow(c, cse);
					activities.add(wrapper.activity);
					notifications.add(wrapper.mail);
				}

				wrapper.mail.setOrgWideEmailAddressId(this.orgEmailAddressId);
				emailWrapperLst.add(wrapper);
			}
		}

		try {
			if(!activities.isEmpty()) {
				insert activities;
			}
			Messaging.sendEmail(notifications);
			for(EmailMessageWrapper w : emailWrapperLst) {
				if(w.notifiyInternalGroup) {
				results.rows.add(setExecutionStatus(w.reportRow, ''));
			}
			}

			this.emailExampleContent = Blob.valueOf(wrapper.mail.getHTMLBody());
		} catch(Exception e) {
			for(EmailMessageWrapper w : emailWrapperLst) {
				if(w.notifiyInternalGroup) {
				results.rows.add(setExecutionStatus(w.reportRow, e.getMessage().escapeCSV()));
			}
		}
	}
	}

	private static String initReportRow(Contact c, Case cse) {
		String res = '';
		res += c.Account.Name.escapeCSV() + ','; //Airline Name
		res += c.Name.escapeCSV() + ','; //Airline Contact Name
		res += c.Email + ',';
		res += cse.CaseNumber + ',';
		res += cse.Account.Name.escapeCSV() + ','; //Agency Name
		res += cse.Account.IATACode__c + ',';
		res += cse.BSPCountry__c.escapeCSV() + ',';
		return res;
	}

	private static String setExecutionStatus(String row, String errorMessage) {
		return row + String.isBlank(errorMessage) + ',' + errorMessage;
	}

	private static Messaging.SingleEmailMessage mailToContact(Contact c, Case cse, EmailTemplate template) {
		Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, c.Id, cse.Id);
		return mail;
	}

	private static EmailMessageWrapper mailToUser(User u, Contact c, Case cse, EmailTemplate template, Boolean notifiyInternalGroup) {
		Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, c.Id, cse.Id);
		mail.setTargetObjectId(u.Id);
		mail.setSaveAsActivity(false);

		Task activity = new Task();
		activity.WhatId = cse.Id;
		activity.WhoId = c.Id;
		activity.Subject = 'Email: ' + mail.getSubject();
		activity.Status = 'Completed';
		activity.Description = mail.getPlainTextBody();
		activity.ActivityDate = Date.today();

		return new EmailMessageWrapper(activity, mail, notifiyInternalGroup);
	}
	
	global void finish(Database.BatchableContext BC) {
		if(!this.results.rows.isEmpty()) {
		notifyGroup(this.results, this.mapContactToCase, this.emailExampleContent);
	}
	}

	public static void notifyGroup(ResultReport results, Map<Id,List<Id>> mapContactToCase, Blob emailExampleContent) {
		List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName  = 'AMS_Agency_Default_Notification')];
		EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Internal_Major_default_notification'];
		List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();

		Id tmpContactId = new List<Id> (mapContactToCase.keySet())[0];
		Id caseId = mapContactToCase.get(tmpContactId)[0];

		if(!users.isEmpty()) {
			for(User u : users) {
				Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
				Blob csvReport = results.buildReport();
				csvAttc.setFileName('Airlines notifications report.csv');
	        	csvAttc.setBody(csvReport);

	        	Messaging.EmailFileAttachment exampleAttc = new Messaging.EmailFileAttachment();
				exampleAttc.setFileName('Notification Example.html');
	        	exampleAttc.setBody(emailExampleContent);

	        	Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, u.Id, caseId);
				mail.setTargetObjectId(u.Id);
				mail.setSaveAsActivity(false);
				mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc, exampleAttc});
				notifications.add(mail);
			}
		}

		Messaging.sendEmail(notifications);
	}

	public class ResultReport {
		public List<String> rows {get;set;}

		public ResultReport() {
			this.rows = new List<String>();
		}

		public Blob buildReport() {
			String header = 'Airline,Contact,Email,Case Number,Agency,Agency IATA Code,Country,Sent,Message\n';
			String body = String.join(rows, '\n');
			Blob attach = Blob.valueOf(header + body);
			return attach;
		}
	}

	public class EmailMessageWrapper {
		public Task activity {get;set;}
		public String reportRow {get;set;} 
		public Messaging.SingleEmailMessage mail {get;set;}
		public Boolean notifiyInternalGroup {get;set;}

		public  EmailMessageWrapper(Task activity, Messaging.SingleEmailMessage mail, Boolean notifiyInternalGroup) {
			this.activity = activity;
			this.mail = mail;
			this.notifiyInternalGroup = notifiyInternalGroup;
		}
	}	
}