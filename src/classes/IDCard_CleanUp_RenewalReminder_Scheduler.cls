global with sharing class IDCard_CleanUp_RenewalReminder_Scheduler implements Schedulable {

	//First monday of each month
	public static String CRON_EXP =  '0 0 0 ? * 2#1 *';
	public static Integer DAY = 1;


  global void execute(SchedulableContext SC) {
	CleanUp_RenewalReminder(DAY);
  }


  public static void CleanUp_RenewalReminder (Integer d) {

	list<ID_Card__c> iDCardsToRemind = new list<ID_Card__c>();

	string query = 'Select Valid_To_Date__c, VER_Number__c, Is_Active_Card__c, Card_Status__c From ID_Card__c ' +
	'where (Valid_To_Date__c >= 2012-01-01) and Valid_To_Date__c != null and Card_Status__c != \'Cancelled ID Card\' '+
	'and Agency_Status__c != \'Terminated\' AND RecordType.Name = \'AIMS\' AND IDCard_Key_Account__c = false ' + 
	'AND Valid_To_Date__c >= LAST_N_DAYS:60 AND Valid_To_Date__c <= NEXT_N_DAYS:60 ' +
	'ORDER BY VER_Number__c DESC LIMIT 49000';

	iDCardsToRemind = Database.query(query);
	Set<String> vernumbers = new Set<String>();
	Set<String> vernumbersToDiscard = new Set<String>();
	//add the list to a set to remove duplicates
	for ( ID_Card__c initalID : iDCardsToRemind) {
		vernumbers.add(initalID.VER_Number__c);
		if(initalID.Valid_To_Date__c > date.parse('2020-07-15') && (initalID.Is_Active_Card__c || initalID.Card_Status__c == 'Valid ID Card'))
			vernumbersToDiscard.add(initalID.VER_Number__c);
	}
	vernumbers.removeAll(vernumbersToDiscard);
	
	Case[] pendingCases = [Select Id, Related_ID_Card_Application__r.VER_Number__c From Case where Related_ID_Card_Application__r.VER_Number__c IN :vernumbers and RecordType.Name = 'ID Card Application' and Status != 'Closed'];

	for(Case c: pendingCases){
		vernumbersToDiscard.add(c.Related_ID_Card_Application__r.VER_Number__c);
	}

	vernumbers.removeAll(vernumbersToDiscard);

	// batch to send reminders
	IDCard_RenewalReminder_Batch cBatch2 = new IDCard_RenewalReminder_Batch();
	cBatch2.vernumbers = vernumbers;
	ID batchprocessid2 = Database.executeBatch(cBatch2, 15);
  }

}
