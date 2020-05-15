global class IDCard_RenewalReminder_Batch implements Database.Batchable<sObject> {


	global  Set<String> vernumbers = new Set<String>();

	global list<Contact> start(Database.BatchableContext BC) {
		List<Contact> contactsScope = [Select id, Email, SendIDCardRenewalNotice__c from Contact where VER_Number_2__c in :vernumbers AND IsEmailBounced = false AND (NOT Email LIKE '%.inactive')];
		return contactsScope;
	}

	global void execute(Database.BatchableContext BC, list<Contact>  scope) {
		for (Contact c : scope) {
			c.SendIDCardRenewalNotice__c = true;
		}
		Update scope;
	}

	global void finish(Database.BatchableContext BC) {}
}
