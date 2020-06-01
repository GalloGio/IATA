global with sharing class IDCard_CleanUp_RenewalReminder_Scheduler implements Schedulable {

	//First monday of each month
	public static String CRON_EXP =  '0 0 0 ? * 2#1 *';

	global void execute(SchedulableContext SC) {
		cleanUp_RenewalReminder();
	}

	public static void cleanUp_RenewalReminder () {

	//Select the ID cards that the validation date sits between previous 60 days and next 60 days from the current date
		List<ID_Card__c> iDCardsToRemind = [SELECT Id, Valid_To_Date__c , Related_Contact__c, Related_Contact__r.Account.IDCard_Key_Account__c
										FROM ID_Card__c 
										WHERE Cancellation_Date__c = null AND Valid_To_Date__c != null 
										AND Valid_To_Date__c >= LAST_N_DAYS:60 AND Valid_To_Date__c <= NEXT_N_DAYS:60 
										AND Card_Status__c = :IDCardUtil.CARDSTATUS_VALID AND Related_Contact__r.Account.Status__c != 'Terminated'];
		System.debug(loggingLevel.Debug, '[cls IDCard_CleanUp_RenewalReminder_Scheduler - cleanUp_RenewalReminder] iDCardsToRemind - ' + iDCardsToRemind);

		Set<ID> contactsID = new Set<id>();
		//add the list to a set to remove duplicates
		for ( ID_Card__c initalID : iDCardsToRemind) {
			contactsID.add(initalID.Related_Contact__c);
		}
		System.debug(loggingLevel.Debug, '[cls IDCard_CleanUp_RenewalReminder_Scheduler - cleanUp_RenewalReminder] contactsID - ' + contactsID);

		//get Contacts related to contactsID
		List<Contact> contactsScope = [Select id, SendIDCardRenewalNotice__c from Contact where id = :contactsID];

		// batch to send reminders
		IDCard_RenewalReminder_Batch idcardRenewalBatch = new IDCard_RenewalReminder_Batch();
		idcardRenewalBatch.ContactScope = contactsScope;
		ID batchprocessid2 = Database.executeBatch(idcardRenewalBatch, 15);
	}

}