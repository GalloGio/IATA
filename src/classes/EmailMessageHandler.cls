public with sharing class EmailMessageHandler {
	
	/*
	 * Set the the NOI Sent Date on the parent case to now() every time that an email message is sent and:
	 * - it is attached to a SIDRA case
	 * - it has an attachment that contains "Notice of Irregularity" 
	 * Trigger on EmailMessage that checks the attachment linked to the parent case: the attachment is the result of a Conga merge operation and is automatically attached
	 * to the parent case by Conga. Solution chosen because at this time SF cannot detect the attachment on the outbound email message, and Attachment triggers doesn't trigger 
	 * on EmailMessage attachments. 
	 */
	public static void SetTheNOISentDateOnParentCase (list<EmailMessage> lstTriggerNew) {
		ID SIDRAcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
		
		Set<String> cids = new Set<String>();
		map<String, EmailMessage> messagesPerCaseId = new Map<String, EmailMessage>();
		for (EmailMessage myEmail : lstTriggerNew) {
			cids.add(myEmail.ParentId);
			messagesPerCaseId.put(myEmail.ParentId, myEmail);
		}
		
		// select all parent SIDRA cases and their last attachment
		Case[] parentSIDRACases = [SELECT Id, RecordTypeId, NOI_sent__c, 
										(SELECT Id, Name FROM Attachments ORDER BY Id DESC LIMIT 1) 
									FROM Case 
									WHERE Id IN :cids AND RecordTypeId = :SIDRAcaseRecordTypeID];
		
		// Get the Ids of SIDRA cases and get the last attachments related to each them into a map
		Set<String> setSidraCaseIds = new Set<String>();
		map<Id, Attachment> mapAttachmentsPerCaseId = new map<Id, Attachment>(); 
		
		for (Case c : parentSIDRACases) {
			setSidraCaseIds.add(c.Id);
			for (Attachment att : c.Attachments) {
				mapAttachmentsPerCaseId.put(c.Id, att);
			}
		}
		
		List<case> cases2update = new List<case>();
		
		for (Case parentCase : parentSIDRACases) {
			EmailMessage myEmail = messagesPerCaseId.get(parentCase.Id);
			
			// if parent is SIDRA case && email is a notice of irregularity, then update the NOI Sent field to NOW()
			// Added condition to populate field only one time.
			if (myEmail.Incoming == false && 
				mapAttachmentsPerCaseId.get(parentCase.Id) != null &&
				mapAttachmentsPerCaseId.get(parentCase.Id).Name.contains('Notice of Irregularity') && parentCase.NOI_sent__c == null) 
			{
					parentCase.NOI_sent__c = datetime.now();
					cases2update.add(parentCase);
			}
		}
		
		if (!cases2update.isEmpty()) {
			update cases2update;
		}
		
	}
	
	
	/*
	 * This method prevents the deletion of email messages
	 */
	public static void PreventEmailDeletion(list<EmailMessage> lstTriggerOld) {
		for (EmailMessage em : lstTriggerOld) {
			em.addError('You are not allowed to delete this Email message.');
		}
	}

	/*
	 * If an email message related to a case closed for more than 2 weeks is received
	 * and this case is in one of the selected recordtypes then
	 * a warning email is sent to the sender
	 */
	public static final String ORG_ADDRESS_FROM = 'noreply@iata.org';
	public static final list<String> LIST_VALID_RT = new list<String>{'Cases_Global','CasesEurope','CasesAmericas','CasesMENA','ExternalCasesIDFSglobal','Cases_China_North_Asia','ComplaintIDFS'};
	public static void sendEmailToSenderWhenCaseClosed(list<EmailMessage> listNewEmail) {
		// create a map with parent cases as key and their emails as value
		map<Id,list<EmailMessage>> mapCaseIdEmail = new map<Id,list<EmailMessage>>();
		for (EmailMessage em : listNewEmail) {
			if (em.ParentId!=null && em.ParentId.getSobjectType()==Schema.Case.SObjectType) {
				list<EmailMessage> listEmails = mapCaseIdEmail.get(em.ParentId);
				if (listEmails==null) {
					listEmails = new list<EmailMessage>();
				}
				listEmails.add(em);
				mapCaseIdEmail.put(em.ParentId, listEmails);
			}
		}
		
		// find, in previously selected cases, those that fit the conditions:
		// a valid RT and closed fror more than 2 weeks
		map<Id,Case> mapCases = new map<Id,Case>();
		for (Case cse: [
				SELECT Id, ClosedDate, ContactId,
					contact.CNS_Contact__c, contact.Preferred_Language__c, account.Source_System__c
				FROM Case
				WHERE id IN :mapCaseIdEmail.keyset()
				AND RecordType.DeveloperName IN :LIST_VALID_RT]
				) {
			if (cse.ClosedDate < Date.today().addDays(-14)) {
				mapCases.put(cse.Id, cse);
			}
		}
		
		if (mapCases.isEmpty()) return;
		
		OrgWideEmailAddress orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE address = :ORG_ADDRESS_FROM];
		//Finally, send and email to all found cases
		list<Messaging.SingleEmailMessage> listSendEmail = new list<Messaging.SingleEmailMessage>();
		for (Case cse: mapCases.values()) {
			for (EmailMessage emailMessage: mapCaseIdEmail.get(cse.Id) ) {
				if (emailMessage.FromAddress != ORG_ADDRESS_FROM) {
					id templateId = findCloseCaseTemplateId(cse.Contact, cse.Account);
					if (templateId == null ){
						System.debug('ERROR EmailMessageHandler.cls sendEmailToSenderWhenCaseClosed() case ' +  cse.ID + ' could not find any template');
					} else {
						Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
						email.setTargetObjectId(cse.ContactId);
						email.setWhatId(cse.Id);
						email.setOrgWideEmailAddressId(orgAddress.Id);
						email.setToAddresses(new list<String>{emailMessage.FromAddress});
						email.setTemplateId(templateId);
						listSendEmail.add(email);
					}
				}
			}
		}

		// send emails created if exist
		if (!listSendEmail.isEmpty()) Messaging.sendEmail(listSendEmail);
	}
	
	public static map<String,Id> CASE_CLOSED_TEMPLATES;
	public static final String STR_DEFAULT = 'Default';
	public static Id findCloseCaseTemplateId(Contact contact, Account account) {
		if (CASE_CLOSED_TEMPLATES==null) {
			CASE_CLOSED_TEMPLATES = new map<String,Id>();
			for (Case_Closed_Templates__c record: Case_Closed_Templates__c.getall().values() ) {
				String key = record.Language__c + ' ' + record.CNS_Contact__c + ' ' + record.Source_System__c;
				CASE_CLOSED_TEMPLATES.put(key, record.Template_Id__c);
			}
		}
		// find a ll possibilities from the specific custom setting to the default one
		Id templateId;
		templateId = CASE_CLOSED_TEMPLATES.get(contact.Preferred_Language__c + ' ' + contact.CNS_Contact__c + ' ' + account.Source_System__c);
		if (templateId!=null) return templateId;
		
		templateId = CASE_CLOSED_TEMPLATES.get(contact.Preferred_Language__c + ' ' + contact.CNS_Contact__c + ' ' + STR_DEFAULT);
		if (templateId!=null) return templateId;
		
		templateId = CASE_CLOSED_TEMPLATES.get(contact.Preferred_Language__c + ' ' + STR_DEFAULT + ' ' + account.Source_System__c);
		if (templateId!=null) return templateId;
		
		templateId = CASE_CLOSED_TEMPLATES.get(contact.Preferred_Language__c + ' ' + STR_DEFAULT + ' ' + STR_DEFAULT);
		if (templateId!=null) return templateId;
		
		templateId = CASE_CLOSED_TEMPLATES.get(STR_DEFAULT + ' ' + contact.CNS_Contact__c + ' ' + account.Source_System__c);
		if (templateId!=null) return templateId;
		
		templateId = CASE_CLOSED_TEMPLATES.get(STR_DEFAULT + ' ' + contact.CNS_Contact__c + ' ' + STR_DEFAULT);
		if (templateId!=null) return templateId;
		
		templateId = CASE_CLOSED_TEMPLATES.get(STR_DEFAULT + ' ' + STR_DEFAULT + ' ' + account.Source_System__c);
		if (templateId!=null) return templateId;
		
		templateId = CASE_CLOSED_TEMPLATES.get(STR_DEFAULT + ' ' + STR_DEFAULT + ' ' + STR_DEFAULT);
		if (templateId!=null) return templateId;
		
		return null;
	}


	//ACAMBAS - WMO-395: Begin
	
	public static void sendEmailToSenderWhenCaseOpened(list<EmailMessage> listNewEmail) {
		// create a map with parent cases as key and their emails as value
		Map<Id, list<EmailMessage>> mapCaseIdEmail = new Map<Id, list<EmailMessage>>();

		//system.debug('### EmailMessageHandler -----------------------------------------');

		for(EmailMessage em : listNewEmail) {
			if(em.ParentId != null && em.ParentId.getSobjectType() == Schema.Case.SObjectType && em.Incoming == true) {

				list<EmailMessage> listEmails = mapCaseIdEmail.get(em.ParentId);

				if (listEmails == null) {
					listEmails = new list<EmailMessage>();
				}

				listEmails.add(em);
				mapCaseIdEmail.put(em.ParentId, listEmails);
			}
		}

		//system.debug('### EmailMessageHandler - mapCaseIdEmail: ' + mapCaseIdEmail);

		List<String> validRTList = new List<String>();

		List<Case_RTs_for_Auto_Reply_Email__c> eligibleCaseRTs = [SELECT Record_Type_Name__c FROM Case_RTs_for_Auto_Reply_Email__c];

		//system.debug('### EmailMessageHandler - eligibleCaseRTs: ' + eligibleCaseRTs);

		for(Case_RTs_for_Auto_Reply_Email__c cs : eligibleCaseRTs) {
	        validRTList.add(cs.Record_Type_Name__c);
      	}

      	system.debug('### EmailMessageHandler - validRTList: ' + validRTList);

      	// find, in previously selected cases, those that have a valid RT
		List<Case> eligibleCases = [SELECT Id, ClosedDate, ContactId, RecordType__c,
										contact.CNS_Contact__c, contact.Preferred_Language__c, account.Source_System__c
									FROM Case
									WHERE id IN :mapCaseIdEmail.keyset() AND RecordType__c IN :validRTList];

		//system.debug('### EmailMessageHandler - eligibleCases: ' + eligibleCases);
		
		Map<Id, Case> mapCases = new Map<Id, Case>();
		Set<Id> contactIds = new Set<Id>();

		for(Case cse: eligibleCases) {
			mapCases.put(cse.Id, cse);
			contactIds.add(cse.ContactId);
		}
		
		if(mapCases.isEmpty()) return;

        List<Contact> contactList = [SELECT Id, Preferred_Language__c FROM Contact WHERE Id IN :contactIds];

        //system.debug('### EmailMessageHandler - contactList: ' + contactList);

        List<Messaging.SingleEmailMessage> emailsToSend = new list<Messaging.SingleEmailMessage>();

		for(Case cse: mapCases.values()) {
			for(EmailMessage emailMessage: mapCaseIdEmail.get(cse.Id)) {
				emailsToSend.addAll(EmailUtils.createEmails(contactList, 'Portal_Case_Comment_Autoreply', 'noreply@iata.org', cse.Id));
			}
		}

		if(emailsToSend.size() > 0) {
            system.debug('### EmailMessageHandler - sendEmailToSenderWhenCaseOpened: ' + emailsToSend);
            Messaging.sendEmail(emailsToSend);
        }
	}

	//ACAMBAS - WMO-395: End
	
}