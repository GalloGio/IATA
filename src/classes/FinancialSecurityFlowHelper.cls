public with sharing class FinancialSecurityFlowHelper {

    @InvocableMethod (Label='Send Acknowledge')
    public static List<String> sendAcknowledge(List<Id> recordIds) {
        Savepoint sp = Database.setSavepoint();
        try {
            Set<Id> accountIds = new Set<Id>();
            List<Financial_Security__c> fs = [SELECT Id, Account__c, Account__r.Top_Parent__c, Unlimited_Security__c,
                                                Acknowledgment_sent__c, Acknowledge_Sent_Date__c 
                                              FROM Financial_Security__c 
                                              WHERE Id IN :recordIds];

            for(Financial_Security__c f : fs) {
                accountIds.add(f.Account__c);
                if(f.Account__r.Top_Parent__c <> null) {
                    accountIds.add(f.Account__r.Top_Parent__c);
                }
                f.Acknowledgment_sent__c = true;
                f.Acknowledge_Sent_Date__c = Datetime.now();
            }
            
            update fs;
            Map<Id,List<Contact>> mapKeyContacts = getKeyContacts(accountIds);
                        
                        
            return new List<String> {sendEmailNotification(fs, mapKeyContacts)};
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug(e.getStackTraceString());
            return new List<String> {'Error:\n' + e.getMessage() + '\n' + e.getStackTraceString()};
        }        
    }

    private static Map<Id,List<Contact>> getKeyContacts(Set<Id> accountIds) {
        Map<Id,List<Contact>> res = new Map<Id,List<Contact>>();

        List<Account> accounts = [SELECT Id, Top_Parent__c, 
                                    (SELECT Id, Preferred_Language__c
                                     FROM Contacts 
                                     WHERE IsEmailBounced = false AND (Financial_Assessment_Contact__c = true OR User_Portal_Status__c = 'Approved Admin'))
                                  FROM Account
                                  WHERE Id IN :accountIds ORDER BY Top_Parent__c ASC NULLS FIRST];

        for(Account acc : accounts) {
            List<Contact> contacts = new List<Contact>();

            if(!acc.Contacts.isEmpty()) {
                contacts.addAll(acc.Contacts);
            }

            List<Contact> topParentContacts = acc.Top_Parent__c == null ? null : res.get(acc.Top_Parent__c);
            if(topParentContacts <> null) {
                contacts.addAll(topParentContacts);
            }

            if(!contacts.isEmpty()) {
                res.put(acc.Id, contacts);
            }
        }

        return res;
    }

    private static String sendEmailNotification(List<Financial_Security__c> fs, Map<Id,List<Contact>> mapKeyContacts) {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'agencymanagement@iata.org'];

        Map<String,Id> mapTemplates = getEmailTemplates(); 
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        for(Financial_Security__c f : fs) {
            List<Contact> keyContacts = mapKeyContacts.get(f.Account__c);
            
            if(keyContacts == null || keyContacts.isEmpty()) {
                continue;
            }

            for(Contact c : keyContacts) {

                String unlimited = f.Unlimited_Security__c ? 'Unlimited_' : '';
                String templateDevName = 'AMS_FS_Notification_' + unlimited + c.Preferred_Language__c; 
                Id templateId = mapTemplates.get(templateDevName);

                if(templateId == null) {
                    templateDevName = 'AMS_FS_Notification_' + unlimited + 'English';
                    templateId = mapTemplates.get(templateDevName);
                }

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.saveAsActivity = true;
                mail.setTargetObjectId(c.Id);
                mail.setWhatId(f.Id);
                mail.setOrgWideEmailAddressId(owea[0].Id);
                mail.setTemplateId(templateId);
                mailsToSend.add(mail);                                
            }
        }

        if(!mailsToSend.isEmpty()) {
            Messaging.sendEmail(mailsToSend);
            return 'Financial Security acknowledgement was sent successfully.';
        } else {
            return 'Error:\n No Approved Admin or Financial Assessment Contacts found for this Agency.';
        }
    }

    private static Map<String,Id> getEmailTemplates() {
        Map<String,Id> mapTemplates = new Map<String,Id>();

        for(EmailTemplate template : [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'AMS_FS_Notification_%']) {
            mapTemplates.put(template.DeveloperName, template.Id);
        }

        return mapTemplates;
    }

}