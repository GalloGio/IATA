global class AMS_MajorDefaultCommunicationEmailSender implements Database.Batchable<sObject>, Database.Stateful {
	
	global Set<Id> contactIds {get;set;}
	global Map<Id,List<Id>> mapContactToCase {get;set;}
	global Map<Id,EmailTemplate> mapContactToTemplate {get;set;}
	global List<String> errors {get;set;}
	global ResultReport results {get;set;}
	
	global AMS_MajorDefaultCommunicationEmailSender(Set<Id> contactIds, Map<Id,List<Id>> mapContactToCase, Map<Id,EmailTemplate> mapContactToTemplate) {
		this.contactIds = contactIds;
		this.mapContactToCase = mapContactToCase;
		this.mapContactToTemplate = mapContactToTemplate;
		this.errors = new List<String>();
		this.results = new ResultReport();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT Id, Name, Account.Name, (SELECT Id FROM Users LIMIT 1) FROM Contact WHERE Id IN :contactIds');
	}

   	global void execute(Database.BatchableContext BC, List<Contact> scope) {
		Id orgEmailAddressId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'agencymanagement@iata.org'].Id;
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
		for(Contact c : scope) {
			for(Id caseId : mapContactToCase.get(c.Id)) {
				Case cse = mapCases.get(caseId);
				EmailTemplate template = mapContactToTemplate.get(c.Id);
				EmailMessageWrapper wrapper;

				if(c.Users.isEmpty()) {
					Messaging.SingleEmailMessage mail = mailToContact(c, cse, template);
					wrapper = new EmailMessageWrapper(null, mail);
					wrapper.reportRow = initReportRow(c, cse);
					notifications.add(mail);
				} else {
					wrapper = mailToUser(c.Users[0], c, cse, template);
					wrapper.reportRow = initReportRow(c, cse);
					activities.add(wrapper.activity);
					notifications.add(wrapper.mail);
				}

				emailWrapperLst.add(wrapper);
			}
		}

		try {
			if(!activities.isEmpty()) {
				insert activities;
			}
			Messaging.sendEmail(notifications);
			for(EmailMessageWrapper w : emailWrapperLst) {
				results.rows.add(setExecutionStatus(w.reportRow, ''));
			}
		} catch(Exception e) {
			for(EmailMessageWrapper w : emailWrapperLst) {
				results.rows.add(setExecutionStatus(w.reportRow, e.getMessage().escapeCSV()));
			}
		}
	}

	private static String initReportRow(Contact c, Case cse) {
		String res = '';
		res += c.Account.Name.escapeCSV() + ','; //Airline Name
		res += c.Name.escapeCSV() + ','; //Airline Contact Name
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

	private static EmailMessageWrapper mailToUser(User u, Contact c, Case cse, EmailTemplate template) {
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

		return new EmailMessageWrapper(activity, mail);
	}
	
	global void finish(Database.BatchableContext BC) {
		notifyGroup(this.results);
	}

	public static void notifyGroup(ResultReport results) {
		List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName  = 'AMS_Agency_Default_Notification')];
		List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();
		if(!users.isEmpty()) {
			for(User u : users) {
				Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
				Blob csvReport = results.buildReport();
				csvAttc.setFileName('Airlines notifications report.csv');
	        	csvAttc.setBody(csvReport);
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTargetObjectId(u.Id);
				mail.subject = 'Airlines notifications - ' + Datetime.now();
				mail.setSaveAsActivity(false);
				mail.setPlainTextBody('Please find attached the report of airlines notifications for agencies default.');
				mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
				notifications.add(mail);
			}
		}

		Messaging.sendEmail(notifications);
	}

	public static void sendErrorMessage(List<String> receivers, List<String> errors) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject('Default Agency Batch Errors');
		mail.setPlainTextBody(String.join(errors, '\n'));
		mail.setToAddresses(receivers);
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail}); 
	}

	public class ResultReport {
		public List<String> rows {get;set;}

		public ResultReport() {
			this.rows = new List<String>();
		}

		public Blob buildReport() {
			String header = 'Airline,Contact,Case Number,Agency,Agency IATA Code,Country,Sent,Message\n';
			String body = String.join(rows, '\n');
			Blob attach = Blob.valueOf(header + body);
			return attach;
		}
	}

	public class EmailMessageWrapper {
		public Task activity {get;set;}
		public String reportRow {get;set;} 
		public Messaging.SingleEmailMessage mail {get;set;}

		public  EmailMessageWrapper(Task activity, Messaging.SingleEmailMessage mail) {
			this.activity = activity;
			this.mail = mail;
		}
	}	
}