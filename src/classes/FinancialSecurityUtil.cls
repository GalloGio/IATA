/*
 * This class contains helper methods for the trigger FinancialSecurityHandler.
 * These methods handle the creation of the renewal cases for Financial Security records
 * that are close to expiry.
 */
public with sharing class FinancialSecurityUtil {

	/*
	 *  WMO-470 variable to avoid trigger to run again when we are resetting the field "Send_FS_acknowledgment__c"
	 */
	public static Boolean acknowledgeRunning = false;

	/*
	 *  Handles the actions of the Before Update trigger for Financial Security records
	 */
	public static void HandleFSBeforeUpdate (Map<Id, Financial_Security__c> mapTriggerNew, Map<Id, Financial_Security__c> mapTriggerOld) {
		// Create a renewal Case for all the Financial_Security__c records that are switched to the status "close to expiry"

		// Select the IDs of the Financial Security records of interest
		List<Id> lstFSRecordIds = new List<Id>();
		// Select the IDs of the related accounts
		List<Id> lstRelatedAccountIds = new List<Id>();

		for (Financial_Security__c fs : mapTriggerNew.values()) {
			if (fs.Security_Status__c == 'Close to Expiry Date' && mapTriggerOld.get(fs.Id).Security_Status__c != 'Close to Expiry Date') {
				lstFSRecordIds.add(fs.Id);
				lstRelatedAccountIds.add(fs.Account__c);
			}
		}

		// Get extra information on these FS records (information not available in the Trigger.new map, like the account name)
		List<Financial_Security__c> lstFSRecordsWithExtraInfo = [
			SELECT Id, Name, Region__c, Account_Country__c, IATA_code__c, Expiry_Date__c, Account__c, Account__r.Name, Account__r.Industry, Account__r.Type,
				Financial_Institution__r.Name, Amount__c, Security_Type__c, Remarks__c
			FROM Financial_Security__c
			WHERE Financial_Institution__r.RecordType.DeveloperName = 'Generic_FI'
			AND Id IN :lstFSRecordIds];

		// Get all financial assessment contacts from the accounts related to the FS records (keep 1 contact per account), to add them on the cases
		List<Contact> lstFAContacts = [SELECT Id, AccountId FROM Contact WHERE Financial_Assessment_Contact__c = true AND AccountId IN :lstRelatedAccountIds];
		map<Id, Id> mapFAContactIdsPerAccountIds = new map<Id, Id>();
		for (Contact c : lstFAContacts) {
			mapFAContactIdsPerAccountIds.put(c.AccountId, c.Id);
		}


		// a map to hold the newly created cases per the corresponding Financial Security record Id
		Map<Id, Case> mapNewCasesPerFSId = new Map<Id, Case>();

		// create the renewal cases for the records of interest
		for (Financial_Security__c fs : lstFSRecordsWithExtraInfo) {
			// create the case object
			Case tmpCase = CaseFactory.CreateFinancialSecurityCase(fs, false);

			// fill in the contact info, if available
			tmpCase.ContactId = mapFAContactIdsPerAccountIds.get(fs.Account__c);

			mapNewCasesPerFSId.put(fs.Id, tmpCase);
		}

		if (!mapNewCasesPerFSId.values().isEmpty()) {
			try {
				insert mapNewCasesPerFSId.values();

				// take the newly created cases Ids and fill it on the original Financial Security record
				for (Id fsId : mapNewCasesPerFSId.keyset()) {
					mapTriggerNew.get(fsId).Renewal_Case__c = mapNewCasesPerFSId.get(fsId).Id;
				}

			} catch (Exception e) {
				system.debug('## ERROR: ' + e.getMessage());
			}
		}
	}

	/*
	 *  WMO-470
	 *  Method to send the acknowledgement, because regions have different processes to sent the acknowledge (through a button or
	 *  by a dataloader), was requested to create a checkbox to control when to send the acknowledge. So when the field is set to "true"
	 *  we send the acknowledge a after that we reset the value to "false"
	 */
	public static void sendAcknowledge(List<Financial_Security__c> records) {
		Set<Id> accountIds = new Set<Id>();
		List<Financial_Security__c> recordsToProcess = new List<Financial_Security__c>();

		for(Financial_Security__c record : records) {
			if(record.Send_FS_acknowledgment__c) {
				accountIds.add(record.Account__c);
				recordsToProcess.add(record);
			}
		}

		if(accountIds.isEmpty()) {
			return;
		}

		//Retrieve top parent ids
		for(Account acc : [SELECT Id, Top_Parent__c FROM Account WHERE Id IN :accountIds]) {
			if(acc.Top_Parent__c != null) {
				accountIds.add(acc.Top_Parent__c);
			}
		}

		//Retrieve all admin and fa contact users for each agency hierarchy
		Map<Id,List<Contact>> mapAccountContacts = getContactsMap(accountIds);

		//Retrive email templates
		Map<String,EmailTemplate> mapTemplates = getEmailTemplates();

		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'agencymanagement@iata.org'];
		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
		Set<Financial_Security__c> recordsToUpdate = new Set<Financial_Security__c>();
		for(Financial_Security__c fs : recordsToProcess) {
			List<Contact> contacts = mapAccountContacts.get(fs.Account__c);
			if(contacts == null) {
				fs.addError('No Admin or Financial Assessment Signatory contact.');
				continue;
			}
			for(Contact c : contacts) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.saveAsActivity = false;
				mail.setTargetObjectId(c.Id);
				mail.setWhatId(fs.Id);
				mail.setOrgWideEmailAddressId(owea[0].Id);
				mail.setTemplateId(getTemplateByContact(c,fs,mapTemplates).Id);
				mailsToSend.add(mail);

				Financial_Security__c recordToUpdate = new Financial_Security__c(
					Id= fs.Id,
					Send_FS_acknowledgment__c= false,
					Acknowledgment_sent__c= true,
					Acknowledge_Sent_Date__c= Datetime.now()
				);
				recordsToUpdate.add(recordToUpdate);
			}
		}

		if(!mailsToSend.isEmpty()) {
			if(!Test.isRunningTest()) {
				Messaging.sendEmail(mailsToSend);
			}
			acknowledgeRunning = true;
			update new List<Financial_Security__c>(recordsToUpdate);
		}
	}

	private static EmailTemplate getTemplateByContact(Contact con, Financial_Security__c fs, Map<String,EmailTemplate> mapTemplates) {
		String templateName = fs.Unlimited_Security__c ? 'Unlimited_' : '';
		String lang = String.isBlank(con.Preferred_Language__c) ? 'English' : con.Preferred_Language__c;

		EmailTemplate res = mapTemplates.get(templateName + lang);
		if(res == null) {
			res = mapTemplates.get(templateName + 'English');
		}

		return res;
	}

	private static Map<String,EmailTemplate> getEmailTemplates() {
		Map<String,EmailTemplate> mapLangToTemplate = new Map<String,EmailTemplate>();
		List<EmailTemplate> templates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'AMS_FS_Notification%'];
		for(EmailTemplate t : templates) {
			List<String> parsedName = t.DeveloperName.split('_');
			String lang = (t.DeveloperName.contains('Unlimited') ? 'Unlimited_' : '') + parsedName[parsedName.size() - 1];
			mapLangToTemplate.put(lang,t);
		}

		return mapLangToTemplate;
	}

	private static Map<Id,List<Contact>> getContactsMap(Set<Id> accountIds) {
		Map<Id,List<Contact>> mapAccountContacts = new Map<Id,List<Contact>>();
		List<Contact> contacts = [
			SELECT Id, AccountId, Account.Top_Parent__c, Preferred_Language__c
			FROM Contact
			WHERE AccountId IN :accountIds AND IsEmailBounced = false AND (NOT Email LIKE '%.inactive') AND
				(Financial_Assessment_Contact__c = true OR User_Portal_Status__c = 'Approved Admin')
			ORDER BY Account.Top_Parent__c ASC NULLS FIRST
		];

		for(Contact c : contacts) {
			List<Contact> accountContacts = mapAccountContacts.get(c.AccountId);
			if(accountContacts == null) {
				accountContacts = new List<Contact>();
				mapAccountContacts.put(c.AccountId,accountContacts);
			}
			accountContacts.add(c);

			if(c.Account.Top_Parent__c != null) {
				List<Contact> topParentContacts = mapAccountContacts.get(c.Account.Top_Parent__c);
				if(topParentContacts != null) {
					accountContacts.addAll(topParentContacts);
				}
			}
		}

		return mapAccountContacts;
	}
}
