global class ISSP_PortalUserFreeze_Batch implements Database.Batchable<SOBJECT>, Database.Stateful, Schedulable {


	global static String scheduleIt() {

		return scheduleIt('0 0 1 * * ?');
	}

	global static String scheduleIt(String cron) {

		 	ISSP_PortalUserFreeze_Batch cls = new ISSP_PortalUserFreeze_Batch();

		return System.schedule(Test.isRunningTest() ? 'Freeze portal users Test' + Datetime.now().getTime() : 'Freeze portal users', cron, cls);
		}

		global void execute(SchedulableContext sc){
			//check if there are 5 active batch jobs
		//In some cases, might need to add "Status='Queued' " to the criteria
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){
			ISSP_PortalUserFreeze_Batch cls = new ISSP_PortalUserFreeze_Batch();
				database.executebatch(cls);
		} else {
				//schedule this same schedulable class again in 30 mins
	 			ISSP_PortalUserFreeze_Batch newInstance = new ISSP_PortalUserFreeze_Batch();
	 			Datetime dt = Datetime.now() + (0.024305); // i.e. 30 mins
	 			String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
	 			Id schedId = System.Schedule('Freeze portal users'+timeForScheduler,timeForScheduler,newInstance);
		}
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		DateTime minus90days = system.now() - 90;
		DateTime minus30days = system.now() - 30;
		if (!test.isRunningtest()){
	 			return Database.getQueryLocator([SELECT Id, ContactId, Email, LastLoginDate, CreatedDate
	 										FROM User WHERE
	 										IsActive = true
	 										AND UserType = 'PowerPartner'
	 										AND Portal_User_Frozen_Checkbox__c = false
	 										//AND
	 										//Email IN ('tiago.ferreira+sp08_43@kerensen.com',
	 										//			'tiago.ferreira+sp08_42@kerensen.com')
	 										AND
	 										(LastLoginDate < :minus90days OR (LastLoginDate = null AND CreatedDate < :minus90days)
	 										OR
	 										(Contact.Account.RecordType.Name = 'Standard Account' AND (LastLoginDate < :minus30days OR (LastLoginDate = null AND CreatedDate < :minus30days)))
	 										)
											]);
		}
		else{
			return Database.getQueryLocator([SELECT Id, ContactId, Email, LastLoginDate, CreatedDate
	 										FROM User WHERE
	 										Email = 'ISSPPortalUserFreezeBatchTest@ISSPPortalUserFreezeBatchTest.com'
											]);
		}
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
 		DateTime minus90days = system.now() - 90;
		DateTime minus30days = system.now() - 30;
		IECTestUtil.trgPortalUserAfterInserUpdate = true;//avoid @future in trigger
		Id replyToId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'].Id;
		//String template90Id = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ISSP_account_freeze'].Id;
		//String template75Id = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ISSP_75_days_warning'].Id;
		List<User> userList = scope;
		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
		for(User thisUser : userList) {
			Boolean inactive30 = false;
			Boolean inactive90 = false;
			if (test.isRunningtest()){
				inactive90 = true;
				inactive30 = true;
			}

			if (thisUser.LastLoginDate < minus90days || (thisUser.LastLoginDate == null && thisUser.CreatedDate < minus90days)){
				inactive90 = true;
			}else if(thisUser.Contact.Account.RecordType.Name = 'Standard Account' && (thisUser.LastLoginDate < minus90days || 
			(thisUser.LastLoginDate == null && thisUser.CreatedDate < minus90days)){
				inactive30 = true;
			}

			// no login for over 90 days, inactivate user
			if (inactive90 || inactive30){
				thisUser.IsActive = false;
				thisUser.Portal_User_Frozen_Checkbox__c = true;
			}
		}
		Database.saveResult[] userResult;
		userResult = Database.update(userList, false);
		String message = 'FINAL\n';
		for (Database.saveResult thisResult : userResult){
			if (!thisResult.isSuccess()){
				message += 'ERROR: ' + thisResult + '\n';
			}
		}
		if(message.contains('ERROR:')){
			TransformationHelper.sendEmailSupport('[ISSP_PortalUserFreeze_Batch] ' ,  message);
		}
	 	}

	 	global void finish(Database.BatchableContext BC) {
	 	}
}
