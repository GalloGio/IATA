global  class AMS_PCI_Batch_Remainder implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private Integer batchScope {get;set;}
    global List<ResultWrapper> lstResult {get;set;}

    global AMS_PCI_Batch_Remainder() {
        this.batchScope = 200;
        this.lstResult = new List<ResultWrapper>();
    }

    global AMS_PCI_Batch_Remainder(Integer batchScope) {
        this.batchScope = batchScope;
        this.lstResult = new List<ResultWrapper>();        
    }

    public static void start(String cron, Integer scope) {
        if(!Test.isRunningTest()) {
            System.schedule('AMS PCI Remainder Batch', cron, new AMS_PCI_Batch_Remainder (scope));
        }else{
            System.schedule('AMS PCI Remainder Batch TEST', cron, new AMS_PCI_Batch_Remainder (scope));
        }        
    }

    public static List<Object> loadInitData() {
        Map<String, EmailTemplate> mapTemplates = new Map<String, EmailTemplate>();
        Map<Id,List<Attachment>> mapAttachements = new Map<Id,List<Attachment>>();
        List<EmailTemplate> templates = getEmailTemplates('AMS_PCI_Compliant_reminder_%');
        //AMSU-177
        templates.addAll(getEmailTemplates('AMS_PCI_Compliant_NonBSP_reminder_%'));

        for(EmailTemplate template : templates) {
            mapTemplates.put(template.DeveloperName, template);
            mapAttachements.put(template.Id, new List<Attachment>());
        }

        List<Attachment> attachments = [SELECT Id, Name, ParentId, Body, ContentType
                                        FROM Attachment
                                        WHERE ParentId IN :templates];

        for(Attachment attch : attachments) {
            mapAttachements.get(attch.ParentId).add(attch);
        }

        return new List<Object> {mapTemplates, mapAttachements};
    }

    public static void stop(){
        String sJobName = '';
        if(!Test.isRunningTest()) {
            sJobName = 'AMS PCI Remainder Batch';
        }else{
            sJobName = 'AMS PCI Remainder Batch TEST';
        }
        
        List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :sJobName limit 1]; 
        
        if(SCHEDULE_ID.size() > 0){
            System.abortJob(SCHEDULE_ID[0].Id);
        }
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, this.batchScope);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        String accountStatus = AMS_Utils.ACC_S0_TERMINATED;
        String reason = 'PCI DSS Compliant';        
        Set<String> origins = new Set<String> {'Massive PCI Creation', 'PCI automatic renewal'};     

        List<Object> initLst = loadInitData();
        Map<String, EmailTemplate> mapTemplates = (Map<String, EmailTemplate>) initLst[0];
        Map<Id,List<Attachment>> mapAttachements = (Map<Id,List<Attachment>>) initLst[1];      

        List<EmailTemplate> templates = mapTemplates.values();
        List<String> subjects = new List<String>();

        for(EmailTemplate t : templates) {
            if(!String.isBlank(t.Subject)) {
                subjects.add(t.Subject);
            }
        }

        system.debug('subjects: ' + subjects);

        String query = 'SELECT Id, Subject, CaseNumber, Oscar__c, Account.ANG_PCI_compliance_expiry_date__c, Reason1__c, CreatedDate, IATA_Code__c, ContactId, ';
        query += 'Contact.Name, AccountId, Account.Is_PCI_compliant__c, Account.IATACode__c, Contact.Preferred_Language__c, Account.IATA_ISO_Country__c, ';
        query += 'Account.IATA_ISO_Country__r.Name, Account.IATA_ISO_Country__r.Region__c, ';
        query += 'Contact.Account.IATA_ISO_Country__r.BSP__c, '; //AMSU-177
        query += '(SELECT Subject, CreatedDate FROM EmailMessages WHERE Subject IN :subjects) ';
        query += 'FROM Case ';
        query += 'WHERE RecordTypeId = :recordTypeId AND Account.Status__c != :accountStatus AND IsClosed = false AND Reason1__c = :reason AND Account.ANG_IsNewGenAgency__c = false ';
        query += ' AND Origin IN :origins ';
        query += 'AND (Account.ANG_PCI_compliance_expiry_date__c = NEXT_N_DAYS:30 OR (Account.Is_PCI_compliant__c = null AND CreatedDate < LAST_N_DAYS:14))';
        query += 'AND Do_Not_Send_Notification__c = false'; //AMSU-200

        system.debug('query: ' + query);
        
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Object> initLst = loadInitData();
        Map<String, EmailTemplate> mapTemplates = (Map<String, EmailTemplate>) initLst[0];
        Map<Id,List<Attachment>> mapAttachements = (Map<Id,List<Attachment>>) initLst[1];

        System.debug('Templates: ' + mapTemplates.size());
        System.debug('Attachments: ' + mapAttachements.values().size());

        scope = filterCases((List<Case>) scope); /* remove cases with messages already sent */

        Id orgAddressId = getOrgEmailAddressId('agencymanagement@iata.org');

        Set<Id> contactsIds = new Set<Id>();
        for(Case cse : scope) {
            if(!String.isBlank(cse.ContactId)) {
                contactsIds.add(cse.ContactId);
            }
        }
        if(contactsIds.isEmpty()) {
            for(Case cse : scope) {
                String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
                String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
                lstResult.add(new ResultWrapper(cse.CaseNumber, '-', countryName, regionName, '-', '-', 'Case without contact', false));
            }
            return;
        }

        List<User> users = [SELECT ContactId, Id, Email FROM User WHERE ContactId = :contactsIds];
        Map<Id,User> contactUserMap = new Map<Id,User>();
        for(User user: users){
            contactUserMap.put(user.ContactId, user);
        }

        sendNotification(scope, orgAddressId, mapTemplates, mapAttachements, contactUserMap, lstResult);

    }

    global void finish(Database.BatchableContext BC) {
        sendReport(lstResult);
    }

    /* Remove cases with messages already sent */
    public static List<Case> filterCases(List<Case> cases) {
        List<Case> res = new List<Case>();

        for(Case cse : cases) {
            if(cse.Account.ANG_PCI_compliance_expiry_date__c == null && cse.EmailMessages.isEmpty()) { /* mass creation remainder */
                res.add(cse);
            } else if(cse.Account.ANG_PCI_compliance_expiry_date__c <> null && cse.EmailMessages.size() < 2) { /* renewal remainder */
                Integer daysCounter = Date.today().daysBetween(cse.Account.ANG_PCI_compliance_expiry_date__c);
                if(cse.EmailMessages.size() == 0 && daysCounter > 15) { /* 30 days remainder */
                    System.debug('30 days reminder case: ' + cse);
                    res.add(cse);
                } else if(cse.EmailMessages.size() < 2 && daysCounter < 16) { /* first remainder - 15 days */
                    System.debug('15 days reminder case: ' + cse);
                    if(cse.EmailMessages.size() == 1 && cse.EmailMessages[0].CreatedDate.date().daysBetween(cse.Account.ANG_PCI_compliance_expiry_date__c) > 15) {
                        res.add(cse);
                    } else if(cse.EmailMessages.size() == 0) {
                        res.add(cse);
                    }                    
                }
            }
        }

        return res;
    }

    public static Id getOrgEmailAddressId(String orgAddress) {
        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgAddress];

        if(owea.isEmpty()) {
            return null;
        }

        return owea[0].Id;
    }

    public static List<EmailTemplate> getEmailTemplates(String prefix) {
        List<EmailTemplate> templates = [SELECT Id, DeveloperName, HtmlValue, Body, Subject 
                                         FROM EmailTemplate 
                                         WHERE DeveloperName LIKE :prefix];

        return templates;
    }

    public static void sendNotification(List<Case> cases, Id orgAddressId, Map<String, EmailTemplate> mapTemplates, Map<Id,List<Attachment>> mapAttachements,Map<Id,User> contactUserMap, List<ResultWrapper> lstResult) {
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> emailToInsert = new List<EmailMessage>();

        for(Case cse :cases) {
            
            Boolean isRenewal = cse.Subject.contains('Renewal');

            if(cse.ContactId == null) {
                String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
                String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
                if(!isRenewal) {
                    lstResult.add(new ResultWrapper(cse.CaseNumber, '-', countryName, regionName, '-', '-', 'Case without contact', false));
                }
                continue;
            }

            User usr = contactUserMap.get(cse.contactId);
            if(usr == null) {
                String contactName = cse.Contact.Name;
                String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
                String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
                if(!isRenewal) {
                    lstResult.add(new ResultWrapper(cse.CaseNumber, contactName, countryName, regionName, '-', '-', 'Contact without user ', false));
                }
                continue;
            }

            system.debug('has user');

            //AMSU-177 - add bsp info
            String emailTemplateName = 'AMS_PCI_Compliant'+ (cse.Contact.Account.IATA_ISO_Country__r.BSP__c == 'No' ? '_NonBSP':'') +'_reminder_' + (isRenewal ? 'renewal_' : '');
            if(String.isBlank(cse.Contact.Preferred_Language__c) || cse.Contact.Preferred_Language__c == 'English') {
                emailTemplateName += 'EN';
            } else {
                emailTemplateName += cse.Contact.Preferred_Language__c;
            }   

            if(isRenewal) {
                Integer daysCounter = Date.today().daysBetween(cse.Account.ANG_PCI_compliance_expiry_date__c);
                emailTemplateName += daysCounter < 16 ? '_15' : '_30';
            }

            EmailTemplate template = mapTemplates.get(emailTemplateName);
            if(template == null && emailTemplateName.contains('_EN')) {
                String contactName = cse.Contact.Name;
                String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
                String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
                String preferredLang = String.isBlank(cse.Contact.Preferred_Language__c) ? '-' : cse.Contact.Preferred_Language__c;
                if(!isRenewal) {
                    lstResult.add(new ResultWrapper(cse.CaseNumber, contactName, countryName, regionName, preferredLang, emailTemplateName, 'Template not found ', false));
                }
                continue;
            } else if(template == null) {
                //AMSU-177 - add bsp info
                emailTemplateName = 'AMS_PCI_Compliant'+ (cse.Contact.Account.IATA_ISO_Country__r.BSP__c == 'No' ? '_NonBSP':'') +'_reminder_' + (isRenewal ? 'renewal_' : '');
                emailTemplateName += 'EN';
                if(isRenewal) {
                    Integer daysCounter = Date.today().daysBetween(cse.Account.ANG_PCI_compliance_expiry_date__c);
                    emailTemplateName += daysCounter < 16 ? '_15' : '_30';
                }
                //AMSU-177 - add bsp info
                emailTemplateName = 'AMS_PCI_Compliant'+ (cse.Contact.Account.IATA_ISO_Country__r.BSP__c == 'No' ? '_NonBSP':'') +'_reminder_EN';
                template = mapTemplates.get(emailTemplateName);
            }

            //Hotfix to merge templates dynamically
            Messaging.SingleEmailMessage emailToSend = mergeTemplate(template.Id, cse.contactId, usr.Id, cse.Id, orgAddressId);         
            mailsToSend.add(emailToSend);

            EmailMessage emailMsg = new EmailMessage();
            emailMsg.ToAddress = usr.Email;
            emailMsg.Subject = emailToSend.getSubject();
            emailMsg.HtmlBody = emailToSend.getHtmlBody();
            emailMsg.ParentId = cse.Id; //Attach with the case
            emailMsg.MessageDate = System.now();
            emailMsg.Status = '0';

            emailToInsert.add(emailMsg);

            System.debug('Template Id: ' + template.Id);
            System.debug('Attachments Map: ' + mapAttachements);

            List<Attachment> attachs = mapAttachements.get(template.Id);
            List<Messaging.EmailFileAttachment> emailAttachs = new list<Messaging.EmailFileAttachment>();
            if(attachs != null) {
                for(Attachment attach : attachs){
                    Messaging.EmailFileAttachment emailAttc = new Messaging.EmailFileAttachment();
                    emailAttc.setFileName(attach.Name);
                    emailAttc.setBody(attach.Body);
                    emailAttc.setContenttype(attach.ContentType);

                    emailAttachs.add(emailAttc);    
                }
            }
            emailToSend.setFileAttachments(emailAttachs);

            system.debug('emailMsg: ' + emailMsg);

            String countryName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Name : '-';
            String regionName = cse.AccountId != null && cse.Account.IATA_ISO_Country__c != null ? cse.Account.IATA_ISO_Country__r.Region__c : '-';
            String preferredLang = String.isBlank(cse.Contact.Preferred_Language__c) ? '-' : cse.Contact.Preferred_Language__c;
            if(!isRenewal) {
                lstResult.add(new ResultWrapper(cse.CaseNumber, cse.Contact.Name, countryName, regionName, preferredLang, emailTemplateName, 'Success', true));
            }
        }
        
        if(!Test.isRunningTest() && !mailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] EmailResult = Messaging.sendEmail(mailsToSend);
            insert emailToInsert;
        }
    }

    private static Messaging.SingleEmailMessage mergeTemplate(Id templateId, Id contactId, Id userId, Id caseId, Id oweaId) {
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, contactId, caseId);   
        mail.setOrgWideEmailAddressId(oweaId);
        mail.setTargetObjectId(userId);
        mail.saveAsActivity = false;
        return mail;
    }

    public void sendReport(List<ResultWrapper> results) {
        String body = 'Case Number,Contact Name, Country, Region, Preferred Language, Template Name, Sended, Error Message\n';

        for(ResultWrapper result : results) {
            body += result.caseNumber + ',' + result.ContactName + ',' + result.countryName + ',' + result.regionName + ',' + result.preferredLang + ',' + result.templateName + ',' + result.sended + ',' + result.errorMessage + '\n';
        }

        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvReport = Blob.valueOf(body);
        csvAttc.setFileName('PCI Remainder report.csv');
        csvAttc.setBody(csvReport);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.subject = 'PCI Reminder report';
        message.setPlainTextBody('PCI Reminder report - Check attachment with execution results');
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};        
        
        if(!Test.isRunningTest() && !String.isBlank(Label.AMS_PCI_Remaider_Addresses) && !results.isEmpty()) {
            List<String> emailAddresses = Label.AMS_PCI_Remaider_Addresses.split(';');
            message.setToaddresses(emailAddresses);
            Messaging.sendEmail(messages);
        }
    }

    public class ResultWrapper {

        public String caseNumber {get;set;}
        public String contactName {get;set;}
        public Boolean sended {get;set;}
        public String errorMessage {get;set;}
        public String countryName {get;set;}
        public String regionName {get;set;}
        public String preferredLang {get;set;}
        public String templateName {get;set;}

        public ResultWrapper(String caseNumber, String contactName, String countryName, String regionName, String preferredLang, String templateName, String errorMessage, Boolean sended) {
            this.caseNumber = String.isBlank(caseNumber) ? '' : caseNumber;
            this.contactName = String.isBlank(contactName) ? '' : contactName.escapeCSV();
            this.countryName = String.isBlank(countryName) ? '' : countryName.escapeCSV();
            this.regionName = String.isBlank(regionName) ? '' : regionName.escapeCSV();
            this.errorMessage = String.isBlank(errorMessage) ? '' : errorMessage;
            this.sended = sended;
            this.preferredLang = preferredLang.escapeCSV();
            this.templateName = templateName.escapeCSV();
        }

    }

}