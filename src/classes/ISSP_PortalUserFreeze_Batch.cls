global class ISSP_PortalUserFreeze_Batch implements Database.Batchable<SOBJECT>, Database.Stateful, Schedulable {

	global Set<Id> inactivateUserIds;

	global static String scheduleIt() {
		 
		return scheduleIt('0 0 1 * * ?');
	}
	
	global static String scheduleIt(String cron) {	
		
	   	ISSP_PortalUserFreeze_Batch cls = new ISSP_PortalUserFreeze_Batch();

		return System.schedule('Freeze portal users', cron, cls);
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
		DateTime minus75days = system.now() - 75;
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
   										//OR
   										//LastLoginDate < :minus75days OR (LastLoginDate = null AND CreatedDate < :minus75days)
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
   		system.debug('ON EXECUTE');
   		DateTime minus90days = system.now() - 90;
		DateTime minus75days = system.now() - 75;
		IECTestUtil.trgPortalUserAfterInserUpdate = true;//avoid @future in trigger
		Id replyToId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'].Id;
		//String template90Id = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ISSP_account_freeze'].Id;
		//String template75Id = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ISSP_75_days_warning'].Id; 
		inactivateUserIds = new Set<Id>();
		List<User> userList = scope;
		system.debug('userList: ' + userList);
		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
   		for(User thisUser : userList) {
   			Boolean inactive75 = false;
   			Boolean inactive90 = false;
   			if (test.isRunningtest()){
   				inactive90 = true;
			}
   			if (thisUser.LastLoginDate < minus90days || (thisUser.LastLoginDate == null && thisUser.CreatedDate < minus90days)){
   				inactive90 = true;
   			}

   			/*
   			else if (thisUser.LastLoginDate < minus75days || (thisUser.LastLoginDate == null && thisUser.CreatedDate < minus75days)){
   				inactive75 = true;
   			}
   			*/
   			
   			// no login for over 90 days, inactivate user
   			if (inactive90){
	   			thisUser.IsActive = false;
	   			thisUser.Portal_User_Frozen_Checkbox__c = true;

		        /*
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTargetObjectId(thisUser.Id);
				mail.setTemplateId(template90Id);
				mail.setWhatId(thisUser.Id);
				mail.saveAsActivity = false;
				mail.setOrgWideEmailAddressId(replyToId);
				mailsToSend.add(mail);
				*/	
   			}
   			// no login for over 75 days, warn user
   			   				/*
   			else if (inactive75){
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTargetObjectId(thisUser.Id);
				mail.setTemplateId(template75Id);
				mail.setWhatId(thisUser.Id);
				mail.saveAsActivity = false;
				mail.setOrgWideEmailAddressId(replyToId);
				mailsToSend.add(mail);
   			}
			*/
   		}
   		Database.saveResult[] userResult;
   		userResult = Database.update(userList, false);
   		String message = 'FINAL\n';
   		for (Database.saveResult thisResult : userResult){
   			if (thisResult.isSuccess()){
   				//message += 'Success for: ' + thisResult.getId() + '\n';
   				inactivateUserIds.add(thisResult.getId());
   			}
   			else{
   				message += 'ERROR: ' + thisResult + '\n';
   			}
   		}
   		transformationHelper.sendSFDevsAlertMessage('BATCH RESULT ' ,  message,  new list<string>{'nunesr@iata.org','beatrizr@iata.org'});

   		/*
   		Messaging.sendEmailResult[] sendEmailResults = new List<Messaging.Sendemailresult>();
   		if (mailsToSend.size() > 0){
            sendEmailResults = Messaging.sendEmail(mailstoSend, false);
        }
        */
   	}
   	
   	global void finish(Database.BatchableContext BC) {
   		/*
   		system.debug('ON FINISH');
   		system.debug('ON FINISH: ' + inactivateUserIds);
   		Set <Id> inactivateContactIds = new Set <Id>();
   		List <User> finishUserList = [SELECT ContactId FROM User WHERE Id IN :inactivateUserIds];
   		if (!finishUserList.isEmpty()){
   			for (User thisUser : finishUserList){
   				inactivateContactIds.add(thisUser.ContactId);
   			}
   			List <Contact> contactList = [SELECT Id, Portal_User_Frozen__c FROM Contact WHERE Id IN :inactivateContactIds];
	   		for (Contact thisContact : contactList){
	   			thisContact.Portal_User_Frozen__c = true;
	   		}
	   		Database.saveResult[] contactResult;
	   		contactResult = Database.update(contactList, false);
	   		String message = 'FINAL\n';
	   		for (Database.saveResult thisResult : contactResult){
	   			if (!thisResult.isSuccess()){
	   				message += 'ERROR: ' + thisResult + '\n';
	   			}
	   		}
	   		transformationHelper.sendSFDevsAlertMessage('BATCH RESULT CONTACT' ,  message,  new list<string>{'tiago.ferreira@kerensen.com'});
   		}
   		*/
   	}
}