/**
This Job class is used to reset to next years the Account field ID_Card_Corporate_Validation_Date__c
This field is used to determine, on key account, a corporate date for ID card valididity

This batch will reset up to 48h before term to next year Or next tyo years.
Next two years involve feature being set in ID_Card_KeyAccount_features__c list


*/
global  class IDCard_Account_Renewal_Updater_Scheduler implements Schedulable{

	public static String CRON_EXP =  '0 20 * * * ?';
	//public static String CRON_EXP =  '0 30 * * * ?';
	public static Integer DAY = 1;


	global void execute(SchedulableContext SC) {
		Date today = System.today();
		Date dayPlus1 = today.addDays(1);
		List<Account> accountToUpdate = [select Id,ID_Card_Corporate_Validation_Date__c,ID_Card_KeyAccount_features__c from Account where ID_Card_Corporate_Validation_Date__c!=null and  ID_Card_Corporate_Validation_Date__c> TODAY and ID_Card_Corporate_Validation_Date__c = NEXT_N_DAYS:2 ];
		for(Account acc:accountToUpdate){
			Date accDate = acc.ID_Card_Corporate_Validation_Date__c;
			if(acc.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_2_Years_validity)){
				accDate.addYears(2);
			}else
				accDate.addYears(1);
			acc.ID_Card_Corporate_Validation_Date__c = accDate;
		}
		update accountToUpdate;
	}


}
