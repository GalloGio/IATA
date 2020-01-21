global without sharing class RTSMonthlyDigest implements Schedulable {
	//runs every month on first day at 4a.m.
	public static String CRON_EXP = '0 0 4 1 * ?';

   global void execute(SchedulableContext ctx) {

		List<RTS_Senior_Manager__c> sManagers = RTS_Senior_Manager__c.getAll().values();
		List<String> toAddressesNoUsers = new List<String>();
		List<Id> toAddressesUsers = new List<Id>();

		if(sManagers.isEmpty()){
			System.debug('Warning: No RTS Senior Managemrs found');
			return;
		}

		List<EmailTemplate> eTemplates = [SELECT Id, Subject,Body FROM EmailTemplate WHERE DeveloperName = 'RTS_Monthly_Digest'];
		List<OrgWideEmailAddress> orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];

		if (eTemplates.isEmpty() || orgWideEmail.isEmpty()) {
			System.debug('Warning: No email template or org wide email found');
			return;
		}

		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		for (RTS_Senior_Manager__c sManager: sManagers) {
			if (sManager.Active__c && String.isNotBlank(sManager.User_Id__c))
				toAddressesUsers.add(sManager.User_Id__c);
			else
				toAddressesNoUsers.add(sManager.Email__c);
		}
					/*
			if (sManager.Active__c && String.isNotBlank(sManager.User_Id__c)){
				//EmailTemplate template = eTemplates.get(0);
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTemplateId(eTemplates.get(0).Id);
				mail.setTargetObjectId(sManager.User_Id__c);
				mail.setOrgWideEmailAddressId(orgWideEmail.get(0).Id);
				mail.saveAsActivity = false;
				mails.add(mail);
			}
			else
				toAddressesNoUsers.add(sManager.Email__c);*/

		for(Id targetUser: toAddressesUsers) {
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setTemplateId(eTemplates.get(0).Id);
			email.setTargetObjectId(targetUser);
			email.setOrgWideEmailAddressId(orgWideEmail.get(0).Id);
			email.saveAsActivity = false;
			mails.add(email);
		}

		if(!toAddressesNoUsers.isEmpty()){
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(toAddressesNoUsers);
			email.setTemplateId(eTemplates.get(0).Id);
			email.setTargetObjectId(UserInfo.getUserId());
			email.setOrgWideEmailAddressId(orgWideEmail.get(0).Id);
			email.saveAsActivity = false;
			mails.add(email);
		}	
		

		if(mails.isEmpty()){
			 System.debug('Warning: No active RTS Senior Managers or valid manager\'s email found');
			 return;
		}

		Messaging.sendEmail(mails);
   }
}