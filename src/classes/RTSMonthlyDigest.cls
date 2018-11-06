global without sharing class RTSMonthlyDigest implements Schedulable {
	//runs every month on first day at 4a.m. 
	public static String CRON_EXP = '0 0 4 1 * ?';
   
   global void execute(SchedulableContext ctx) {

        List<RTS_Senior_Manager__c> sManagers = RTS_Senior_Manager__c.getAll().values();
        List<EmailTemplate> eTemplates = [SELECT Id, Subject,Body FROM EmailTemplate WHERE DeveloperName = 'RTS_Monthly_Digest'];
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];

        if (sManagers.isEmpty() || eTemplates.isEmpty() || orgWideEmail.isEmpty()) {
            System.debug('Warning: Senior Management or email template or org wide email not found');
            return;
        }
        
        List<String> toAddresses = new List<String>(); 
        for (RTS_Senior_Manager__c sManager: sManagers) {
            if (sManager.Active__c)
                toAddresses.add(sManager.Email__c);
        }

        EmailTemplate template = eTemplates.get(0);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setTemplateId(template.Id); 
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setOrgWideEmailAddressId(orgWideEmail.get(0).Id);
        mail.saveAsActivity = false;
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }  
}