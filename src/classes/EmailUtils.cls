public class EmailUtils {
	public static List<EmailTemplate> getEmailTemplates(String prefix) {
        List<EmailTemplate> templates = [SELECT Id, DeveloperName, HtmlValue, Body, Subject 
                                         FROM EmailTemplate 
                                         WHERE DeveloperName LIKE :prefix ];
        return templates;
    }

    public static Id getOrgEmailAddressId(String orgAddress) {
        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgAddress];

        if(owea.isEmpty()) return null;

        return owea[0].Id;
    }

    public static List<Messaging.SingleEmailMessage> createEmails(List<Contact> recipients, String templateId, String orgAddress, String whatId) {
        Map<String, EmailTemplate> templatesMap = new Map<String, EmailTemplate>();
        Map<Id, EmailTemplate> contactEmailTemplateMap = new Map<Id, EmailTemplate>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templates = getEmailTemplates(templateId + '_%');

        system.debug('### sendEmailAlert - recipients: ' + recipients);

        for(EmailTemplate template : templates) {
            templatesMap.put(template.DeveloperName, template);
        }

        system.debug('### sendEmailAlert - templatesMap: ' + templatesMap);

        for(Contact con : recipients) {
            String emailTemplateName = templateId;

            system.debug('### sendEmailAlert - con.Preferred_Language__c: ' + con.Preferred_Language__c);

            if(!String.isBlank(con.Preferred_Language__c) && (templatesMap.containsKey(emailTemplateName + '_' + con.Preferred_Language__c))) {       
                emailTemplateName += '_' + con.Preferred_Language__c;
            } else {
                emailTemplateName += '_English';
            }

            system.debug('### sendEmailAlert - emailTemplateName: ' + emailTemplateName);

            EmailTemplate template = templatesMap.get(emailTemplateName);

            if(template == null) {
              throw new AMS_ApplicationException('Email template not found: ' + emailTemplateName);
              //return;
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(getOrgEmailAddressId(orgAddress)); 
            system.debug('### sendEmailAlert - whatId: ' + whatId);
            if(!String.isBlank(whatId)) mail.setWhatId(whatId);
            //mail.setToAddresses(new List<String> { con.Email });
            mail.setTemplateId(template.Id);
            mail.setTargetObjectId(con.Id);
            //mail.setSubject(template.Subject);

            emailsToSend.add(mail);               
        }

        return emailsToSend;
    }
}