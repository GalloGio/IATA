global with sharing class IDCard_CleanUp_RenewalReminder_Scheduler implements Schedulable {

  public static String CRON_EXP =  '0 20 * * * ?';
  //public static String CRON_EXP =  '0 30 * * * ?';
  public static Integer DAY = 1;


  global void execute(SchedulableContext SC) {
	CleanUp_RenewalReminder(DAY);
  }


  public static void CleanUp_RenewalReminder (Integer d) {

	/**
	list<ID_Card_Application__c> unpaidIDCardApplication = new list<ID_Card_Application__c>();
	// list<ID_Card__c> unpaidIDCardApplication_IDCard = new list<ID_Card__c>();
	Datetime myDate = datetime.now().addDays(-1);

	// Get the list of ID Card Application that are unpaid (that have not case associated)
	unpaidIDCardApplication = [SELECT i.Id FROM ID_Card_Application__c i WHERE i.Id NOT IN (SELECT c.Related_ID_Card_Application__c FROM Case c where c.RecordType.Name = 'ID Card Application') AND i.LastModifiedDate <= :myDate ];

	//deletion is done in the batch
	// delete unpaidIDCardApplication;

	//calling batch to delete
	IDCard_CleanUp_Batch cBatch1 = new IDCard_CleanUp_Batch();
	cBatch1.UnpaidIDCardApplication  = unpaidIDCardApplication ;
	ID batchprocessid1 = Database.executeBatch(cBatch1,15);

	*/




	//6/18/2013 R.A: Sets a flag for contacts to be notified in case of ID Card Renewal
	////////////////////////////////////////////////////////////////////////////////////

	//get list of Contacts from IDCards who has ID Cards that meet expirey date -60 -30 0 +30
	/**
	Date last60D = date.today().addDays(-60);
	Date last30D = date.today().addDays(-30);
	Date next30D = date.today().addDays(30);

	//used to remove leading zeros from date params
	String next30 = String.valueOf(next30D);
	String last30 = String.valueOf(last30D);
	String last60 = String.valueOf(last60D);
	System.debug('*** Dates  '+ last60+last30+next30);
	*/
	list<ID_Card__c> iDCardsToRemind = new list<ID_Card__c>();
	/*
	String query = 'Select i.Valid_To_Date__c , i.Related_Contact__r.Id From ID_Card__c i where '
	+'(i.Valid_To_Date__c = Today or i.Valid_To_Date__c ='+last60+' or i.Valid_To_Date__c ='+last30+' or i.Valid_To_Date__c ='+next30+')'
	 +'and i.Cancellation_Date__c = null  and i.Valid_To_Date__c != null  and i.Card_Status__c = \'Printed/Delivered\'';
	*/
	//string query = 'Select i.Valid_To_Date__c , i.Related_Contact__r.Id, i.Related_Contact__r.Account.IDCard_Key_Account__c  From ID_Card__c i where (i.Valid_To_Date__c = LAST_N_DAYS:60 or i.Valid_To_Date__c = NEXT_MONTH or i.Valid_To_Date__c = THIS_MONTH)  and i.Cancellation_Date__c = null  and i.Valid_To_Date__c != null  and i.Card_Status__c = \'Printed/Delivered\'  and i.Related_Contact__r.Account.IDCard_Key_Account__c = false';

	//string query = 'Select i.Related_Contact__r.Account.Status__c, i.Valid_To_Date__c , i.Related_Contact__r.Id, i.Related_Contact__r.Account.IDCard_Key_Account__c From ID_Card__c i where (i.Valid_To_Date__c = LAST_N_DAYS:60 or i.Valid_To_Date__c = NEXT_MONTH or i.Valid_To_Date__c = THIS_MONTH) and i.Cancellation_Date__c = null and i.Valid_To_Date__c != null and i.Card_Status__c = \'Printed/Delivered\' and i.Related_Contact__r.Account.IDCard_Key_Account__c = false and i.Related_Contact__r.Account.Status__c != \'Terminated\'';
	
/* TA-ENHC0013710
	string query = 'Select i.Related_Contact__r.Account.Status__c, i.Valid_To_Date__c , i.Related_Contact__r.Id, i.Related_Contact__r.Account.IDCard_Key_Account__c From ID_Card__c i where (i.Valid_To_Date__c = LAST_N_DAYS:60 or i.Valid_To_Date__c = NEXT_MONTH or i.Valid_To_Date__c = THIS_MONTH) and i.Cancellation_Date__c = null and i.Valid_To_Date__c != null and i.Card_Status__c = \'Valid ID Card\' and i.Related_Contact__r.Account.Status__c != \'Terminated\'';*/

	string query = 'Select Valid_To_Date__c, VER_Number__c, Is_Active_Card__c, Card_Status__c From ID_Card__c where (Valid_To_Date__c >= 2012-01-01) and Valid_To_Date__c != null and Card_Status__c != \'Cancelled ID Card\' and Agency_Status__c != \'Terminated\' AND RecordType.Name = \'AIMS\' AND IDCard_Key_Account__c = false ORDER BY VER_Number__c DESC LIMIT 49000';

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
