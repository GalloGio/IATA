global class ANG_FOPOSCARNotificationBatch implements Database.Batchable<Case>, Database.Stateful  {
	/*
	 Will run every day and send email and Portal notification if:
		a) The FOP OSCAR is not submitted by the agent within 15 days (creation date + 15 days) => Reminder
		b) The FOP OSCAR is not submitted by the agent within 30 days (creation date + 30 days) => Non Compliance

		c) The Annual Revalidation is not submitted by the agent within 15 days (creation date + 15 days) => Reminder
		d) The Annual Revalidation is not submitted by the agent within 21 days (creation date + 21 days) => Reminder
		e) The Annual Revalidation is not submitted by the agent within 27 days (creation date + 27 days) => Reminder

		f) The Annual Revalidation is not submitted by the agent and the Administrative non-compliance step is passed within 15 days (creation date + 45 days) => Reminder
		g) The Annual Revalidation is not submitted by the agent and the Administrative non-compliance step is passed within 21 days (creation date + 51 days) => Reminder
		h) The Annual Revalidation is not submitted by the agent and the Administrative non-compliance step is passed within 27 days (creation date + 57 days) => Reminder
	*/

	// FOP OSCAR was mass created if Origin is the following:
	public static final String MASSIVE_FOP_ORIGIN = 'Massive FOP Creation';
	public static final String AUTOMATIC_RENEWAL_FOP_ORIGIN = 'FoP automatic renewal';
	public static final String ANN_REV_REASON = 'Annual revalidation';

	private static final String RECTYPE_OSCARCOMM = AMS_Utils.RECTYPE_OSCARCOMM;
	private static final String RECTYPE_NEWGENFOP = AMS_Utils.RECTYPE_NEWGENFOP;
	private static final Set<String> MASS_FOP_QUEUES = AMS_Utils.MASS_FOP_QUEUES;
	private static final String ANN_REV_QUEUE = 'Annual Revalidation';

	// Portal Notification and Email templates identifiers
	public static final String FOP_REMINDER_TEMPLATE_ID = 'ANG_Mass_FOP_OSCAR_Reminder';
	public static final String FOP_NONCOMPLIANCE_TEMPLATE_ID = 'ANG_Mass_FOP_OSCAR_NonCompliance';
	public static final String RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID = 'ANG_PCI_RENEWAL_NonCompliance';
	public static final String ANNUAL_REV_REMINDER = 'ANG_Annual_Revalidation_Reminder';
	public static final String ANNUAL_REV_DEADLINE_REMINDER = 'ANG_Annual_Revalidation_Deadline_Reminder';

	public static final Set<String> emailTemplates = new Set<String>{
		FOP_REMINDER_TEMPLATE_ID,
		FOP_NONCOMPLIANCE_TEMPLATE_ID,
		RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID,
		ANNUAL_REV_REMINDER,
		ANNUAL_REV_DEADLINE_REMINDER
	};

	//Templates Names to use
	private Map<String,String> notificationTemplates;
	private Map<String,String> notificationTemplatesInverted;

	//dates:
	private Date DATE_REMINDER_15;
	private Date DATE_REMINDER_30;
	private Date DATE_REMINDER_21;
	private Date DATE_REMINDER_27;

	private List<String> errors = new List<String>();

	global ANG_FOPOSCARNotificationBatch() {
		simulateRunOnDate(System.today());
	}

	public void simulateRunOnDate(Date simulatedDate) {
		DATE_REMINDER_15 = simulatedDate.addDays(-15);
		DATE_REMINDER_30 = simulatedDate.addDays(-30);
		DATE_REMINDER_21 = simulatedDate.addDays(-21);
		DATE_REMINDER_27 = simulatedDate.addDays(-27);
	}

	global Iterable<Case> start(Database.BatchableContext BC) {
		notificationTemplates = new Map<String, String>();
		notificationTemplatesInverted = new Map<String, String>();

		for (Notification_template__c nt: [SELECT Id, Name, Identifier__c 
										FROM Notification_Template__c 
										WHERE Identifier__c IN :emailTemplates]) {
			notificationTemplates.put(nt.Identifier__c,nt.Name);
			notificationTemplatesInverted.put(nt.Name,nt.Identifier__c);
		}

		Set<Id> fopQueueIds = new Set<Id>();
		Id annualRevQueueId;

		for (Group groupQueue: [SELECT Id, Name 
								FROM Group 
								WHERE (Name IN :MASS_FOP_QUEUES OR Name = :ANN_REV_QUEUE)
									AND Type = 'Queue']) {
			if (MASS_FOP_QUEUES.contains(groupQueue.Name)) {
				fopQueueIds.add(groupQueue.Id);
			} else {
				annualRevQueueId = groupQueue.Id;
			}
		}

		return (Iterable<Case>) Database.getQueryLocator([SELECT Id, ContactId, ContactEmail, AccountId, CreatedDate, Origin, Reason1__c,
															OSCAR__c,
															OSCAR__r.ANG_Administrative_non_compliance_date__c,
															OSCAR__r.STEP43__c,
															OSCAR__r.createdDate,
															Contact.Id,
															Contact.Name,
															Contact.Email,
															Contact.Preferred_Language__c,
															Contact.BSP_CASS_Payment_contact__c,
															Contact.Financial_Assessment_Contact__c,
															Contact.Account.IataCode__c,
															Contact.Account.Name,
															Contact.Account.ANG_PCI_compliance_expiry_date__c,
															Owner.Name
														  FROM Case
														  WHERE RecordtypeID = :RECTYPE_OSCARCOMM
															  AND ((OSCAR__r.RecordTypeId = :RECTYPE_NEWGENFOP
																	AND (Origin = :MASSIVE_FOP_ORIGIN
																		OR Origin = :AUTOMATIC_RENEWAL_FOP_ORIGIN)
																	AND OwnerId IN :(Test.isRunningTest() ? new Set<Id>{UserInfo.getUserId()} : fopQueueIds)
																	AND (DAY_ONLY(CreatedDate) = :DATE_REMINDER_15
																		OR DAY_ONLY(CreatedDate) = :DATE_REMINDER_30))
																OR (OSCAR__r.RecordTypeId = :AMS_Utils.RECTYPE_NEWGENANNUALREVAL
																	AND Reason1__c = :ANN_REV_REASON
																	AND OwnerId = :(Test.isRunningTest() ? UserInfo.getUserId() : annualRevQueueId)
																	AND ((OSCAR__r.STEP43__c = :AMS_Utils.PASSED
																			AND OSCAR__r.ANG_Administrative_non_compliance_date__c IN (:DATE_REMINDER_15, :DATE_REMINDER_21, :DATE_REMINDER_27))
																			OR (OSCAR__r.STEP43__c != :AMS_Utils.PASSED
																				AND DAY_ONLY(CreatedDate) IN (:DATE_REMINDER_15, :DATE_REMINDER_21, :DATE_REMINDER_27)))
																	AND OSCAR__r.Status__c NOT IN ( :AMS_Utils.OSCAR_CLOSED, :AMS_Utils.OSCAR_CLOSED_NOT_ACCEPTED,
																									:AMS_Utils.OSCAR_CLOSED_REJECTED, :AMS_Utils.OSCAR_CLOSED_WITHDRAWN )))]);
	}

	global void execute(Database.BatchableContext BC, List<Case> scope) {
		Map<Id,Case> reminderCases = new Map<Id,Case>();
		Map<Id,Case> nonComplianceCases = new Map<Id,Case>();
		Map<Id,Case> renewalReminderCases = new Map<Id,Case>();
		Map<Id,Case> renewalNonComplianceCases = new Map<Id,Case>();

		Map<Id,Case> annualRevReminderCases = new Map<Id,Case>();
		Map<Id,Case> annualRevDeadlineReminderCases = new Map<Id,Case>();
		
		Map<String,Map<Id,Case>> casesByTemplateName =  new Map<String,Map<Id,Case>>();
		Map<Id,List<Contact>> mapCaseContacts = new Map<Id,List<Contact>>();

		// Find any Contact for each account that could receive the same notification as the case owner
		map<Id,Account> mapAccountContacts = findExtraRecipientsInAccounts(scope);

		for (Case cse :scope) {
			Date dt = Date.newInstance(cse.CreatedDate.year(), cse.CreatedDate.month(), cse.CreatedDate.day());

			if (dt == DATE_REMINDER_15 || cse.OSCAR__r.ANG_Administrative_non_compliance_date__c == DATE_REMINDER_15) {
				if(cse.origin == MASSIVE_FOP_ORIGIN) {
					Account account = mapAccountContacts.get(cse.AccountId);
					List<Contact> listExtraRecipients = account?.Contacts;
					populateContactsMap(reminderCases, cse, mapCaseContacts, listExtraRecipients);
				} else if (cse.Reason1__c == ANN_REV_REASON) {
					populateAnnualRevalidationContactMap(annualRevDeadlineReminderCases, annualRevReminderCases, cse, mapCaseContacts);
				}
			} else if (dt == DATE_REMINDER_30) {
				if (cse.origin == MASSIVE_FOP_ORIGIN) {
					populateContactsMap(nonComplianceCases, cse, mapCaseContacts, null);
				} else if (cse.origin == AUTOMATIC_RENEWAL_FOP_ORIGIN) {
					Account account = mapAccountContacts.get(cse.AccountId);
					List<Contact> listExtraRecipients = account?.Contacts;
					populateContactsMap(renewalNonComplianceCases, cse, mapCaseContacts, listExtraRecipients);
				}
			} else if ((dt == DATE_REMINDER_21 || dt == DATE_REMINDER_27 || cse.OSCAR__r.ANG_Administrative_non_compliance_date__c == DATE_REMINDER_21 || cse.OSCAR__r.ANG_Administrative_non_compliance_date__c == DATE_REMINDER_27) && cse.Reason1__c == ANN_REV_REASON) {
				populateAnnualRevalidationContactMap(annualRevDeadlineReminderCases, annualRevReminderCases, cse, mapCaseContacts);
			}

		}
		
		if(!reminderCases.isEmpty()) {
			casesByTemplateName.put(notificationTemplates.get(FOP_REMINDER_TEMPLATE_ID),reminderCases);
		}

		if(!nonComplianceCases.isEmpty()) {
			casesByTemplateName.put(notificationTemplates.get(FOP_NONCOMPLIANCE_TEMPLATE_ID),nonComplianceCases);
		}

		if(!renewalNonComplianceCases.isEmpty()) {
			casesByTemplateName.put(notificationTemplates.get(RENEWAL_FOP_NONCOMPLIANCE_TEMPLATE_ID),renewalNonComplianceCases);
		}

		if(!annualRevReminderCases.isEmpty()) {
			casesByTemplateName.put(notificationTemplates.get(ANNUAL_REV_REMINDER), annualRevReminderCases);
		}

		if(!annualRevDeadlineReminderCases.isEmpty()) {
			casesByTemplateName.put(notificationTemplates.get(ANNUAL_REV_DEADLINE_REMINDER), annualRevDeadlineReminderCases);
		}

		try{
			ANG_OscarProcessHelper.sendFOPPortalNotificationAndEmail(casesByTemplateName, mapCaseContacts, notificationTemplatesInverted);
		}catch(Exception e){
			errors.add('Error running batch containing Case IDs: '+String.join(mapCaseContacts.values(),',')+' - '+e.getMessage()+' - '+e.getStackTraceString()+'/n');
		}
	}

	private void populateAnnualRevalidationContactMap(Map<Id,Case> annualRevDeadlineReminderCases, Map<Id,Case> annualRevReminderCases, Case cse, Map<Id,List<Contact>> mapCaseContacts) {
		if (cse.OSCAR__r.STEP43__c == AMS_Utils.PASSED) {
			populateContactsMap(annualRevDeadlineReminderCases, cse, mapCaseContacts, null);
		} else {
			populateContactsMap(annualRevReminderCases, cse, mapCaseContacts, null);
		}
	}

	private void populateContactsMap(Map<Id,Case> caseMap, Case cse, Map<Id,List<Contact>> mapCaseContacts, list<Contact> listExtraRecipients) {
		caseMap.put(cse.id, cse);

		List<Contact> listContacts = mapCaseContacts.get(cse.Id);
		if (listContacts == null) {
			listContacts = new List<Contact>();
		}
		listContacts.add(cse.Contact);
		if (listExtraRecipients!=null) {
			listContacts.addAll(listExtraRecipients);
		}
		// make the list unique
		map<Id,Contact> mapUniqueContact = new map<Id,Contact>();
		for (Contact contact: listContacts) {
			mapUniqueContact.put(contact.Id, contact);
		}
		mapCaseContacts.put(cse.Id,mapUniqueContact.values());
	}

	/**
	 * Creates a map with an Account Id and a set of all contacts that will receive a notification
	 */
	private map<Id,Account> findExtraRecipientsInAccounts(list<Case> listCase) {
		//Find accounts related to the incoming cases
		list<Id> listAccountId = new list<Id>();
		for (Case cse :listCase) {
			listAccountId.add(cse.AccountId);
		}

		return new map<Id,Account>(
			[SELECT Id,
				(SELECT Id, Email, Name, Preferred_Language__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c,
					Account.IataCode__c, Account.Name, Account.ANG_PCI_compliance_expiry_date__c
				FROM Contacts
				WHERE Status__c = :AMS_Utils.ACTIVE
				AND IsEmailBounced = false
				AND (
					User_Portal_Status__c = :AMS_Utils.CONTACT_TYPE_ADMIN
					OR BSP_CASS_Payment_contact__c = true
				))
			FROM Account
			WHERE Id IN :listAccountId]);
	}

	global void finish(Database.BatchableContext BC) {
		if(!errors.isEmpty()){
			String errorMsg = 'Error(s) running ANG_FOPOSCARNotificationBatch:/n'+String.join(errors,',');

			//send email w/ errors
			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			for (SalesforceSupportEmails__c supportEmail: SalesforceSupportEmails__c.getAll().values()){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTargetObjectId(supportEmail.Support_User_Id__c);
				mail.setSubject('ANG_FOPOSCARNotificationBatch Completed With Errors');
				mail.setSenderDisplayName('Batch Processing Completed');
				mail.setPlainTextBody('Batch Process has been completed. EndTime ' + system.now() + '\n\nERRORS:\n' +errorMsg);
				mail.setSaveAsActivity(false);
				mails.add(mail);
			}

			if (!mails.isEmpty()){
				Messaging.sendEmail(mails);
			}
		}
	}

}
