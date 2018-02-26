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
    string query = 'Select i.Related_Contact__r.Account.Status__c, i.Valid_To_Date__c , i.Related_Contact__r.Id, i.Related_Contact__r.Account.IDCard_Key_Account__c From ID_Card__c i where (i.Valid_To_Date__c = LAST_N_DAYS:60 or i.Valid_To_Date__c = NEXT_MONTH or i.Valid_To_Date__c = THIS_MONTH) and i.Cancellation_Date__c = null and i.Valid_To_Date__c != null and i.Card_Status__c = \'Valid ID Card\' and i.Related_Contact__r.Account.Status__c != \'Terminated\'';



    iDCardsToRemind = Database.query(query);
    System.debug(' * * * iDCardsToRemind ' + iDCardsToRemind);

    Set<ID> contactsID = new Set<id>();
    //add the list to a set to remove duplicates
    for ( ID_Card__c initalID : iDCardsToRemind) {
      contactsID.add(initalID.Related_Contact__r.Id);
    }
    System.debug(' * * * contactsID ' + contactsID);


    //get Contacts related to contactsID
    List<Contact> contactsScope = [Select id, SendIDCardRenewalNotice__c from Contact where id = :contactsID];

    ///////////////////////////////////////////////////////


    // batch to send reminders
    IDCard_RenewalReminder_Batch cBatch2 = new IDCard_RenewalReminder_Batch();
    cBatch2.ContactScope = contactsScope;
    ID batchprocessid2 = Database.executeBatch(cBatch2, 15);


  }

}