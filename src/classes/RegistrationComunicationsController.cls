public without sharing class RegistrationComunicationsController {

    private static String ALL = 'all';
    private static String NONE = 'none';
    private static String SOME = 'some';
    private static String EMAIL = 'email';
    private static String NOTIFICATION = 'notification';


    @AuraEnabled
    public static Map<String,Boolean> sendSingleLevel2RegistrationAlert(Id contactId){
        Map<String,Boolean> result = new Map<String,Boolean>();
        if(contactId == null){
            return new Map<String,Boolean>{EMAIL => false,NOTIFICATION => false};
        }
        Boolean notificationRes = createSingleNotification(contactId);
        Boolean emailRes = sendSingleEmail(contactId);

        if(notificationRes || emailRes){
            updateLastNotificationDate(new List<Id>{contactId});
        }

        result.put(NOTIFICATION,notificationRes);
        result.put(EMAIL,emailRes);
        return result;
    }

    @AuraEnabled
    public static Map<String,String> sendBatchLevel2RegistrationAlert(List<Id> contactIds){

        if(contactIds == null || contactIds.size() == 0){
            return new Map<String,String>{EMAIL => NONE,NOTIFICATION => NONE};
        } 

        Map<String,String> result = new Map<String,String>();

        String notificationRes = createBatchNotification(contactIds);
        String emailRes = sendBatchEmail(contactIds);

        if(notificationRes != NONE || emailRes != NONE){
            updateLastNotificationDate(contactIds);
        }

        result.put(NOTIFICATION,notificationRes);
        result.put(EMAIL, emailRes);

        return result;
     }

    private static Boolean sendSingleEmail(Id contactId){   
        //MAX 150 adresses     
        try{         
            List<Boolean> results = RegistrationLvl2Email.sendSingleEmail(new List<Id>{contactId});     
            return results.get(0);               
        }catch(Exception e ){
            return false;
        }
    }

    private static String sendBatchEmail(List<Id> contactIds){
        // ################################## LIMIT 5000 a day

        try{
            Map<Id,Contact> contacts = new Map<Id,Contact>([SELECT Name, Email FROM Contact Where Id IN :contactIds]);

            //MAX 150 adresses 
            Map<Id,String> addresses = new Map<Id,String>();
            //Inicialize results as failed AND Inicialize list of addresses
           
            for (Contact contact : contacts.values()) {
                addresses.put(contact.Id,contact.Email);
            }

            //Get email template and orgWideEmail
            EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'CSP_Registration_L2_Email_VF'];
            OrgWideEmailAddress orgWideEmail  = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address='noreply@iata.org' Limit 1];     

            List<User> users = [Select Id, ContactId, LanguageLocaleKey FROM User WHERE ContactId IN :contactIds];
            Map<Id,User> userByContact = new Map<Id,User>(); 

            for(User user : users){
                userByContact.put(user.ContactId,user);
            }

            Map<String,Messaging.SingleEmailMessage> templatesByLanguage = new Map<String,Messaging.SingleEmailMessage>(); 
            Messaging.SingleEmailMessage message;

            for(User user :users){
                if(!templatesByLanguage.containsKey(user.LanguageLocaleKey)){
                    message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, user.Id, null);
                    templatesByLanguage.put(user.LanguageLocaleKey, message);
                }
            }

            String url = getPortalProfileUrl();
            Id currentuserId;
            String plainBody = null;
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();               

            for(Contact contact : contacts.values()){
                User currentuser = userByContact.get(contact.Id);
                message = templatesByLanguage.get(currentuser.LanguageLocaleKey);

                message.setReplyTo('noreply@iata.org'); 
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false);  
                message.setTemplateID(emailTemplate.Id);      
                if(orgWideEmail != null){
                    message.setOrgWideEmailAddressId(orgWideEmail.Id);
                }else{
                    message.setSenderDisplayName('IATA Noreply');
                }    
                message.setTargetObjectId(currentuserId);       
                message.setToAddresses(new List<String>{contact.Email});

                plainBody = message.getPlainTextBody();
                message.setHtmlBody(plainBody.replace('[CustomerName]', contact.Name).replace('[URL]','"'+  url +'" target="_blank"'));
                messages.add(message);
            }
            
            Messaging.SendEmailResult[] resultSet;
            Boolean someFailed = false;
            Boolean someSucceded = false;
           
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            // message.setTargetObjectIds(contactIds);   
            for(Messaging.SendEmailResult result : results){
                if(!result.success){
                    someFailed = true;
                }else{
                    someSucceded = true;
                }
            }           
            if(!someFailed){
                return ALL;
            } else if(!someSucceded) {
                return NONE;
            } else{
                return SOME;
            }
            
        }catch(Exception e ){
            return NONE;
        }
    }
    
    private static Boolean  createSingleNotification(Id contactId){

        return (createSingleNotification(new List<Id>{contactId})).get(0);
    }

    private static String createBatchNotification(List<Id> contactIds){

        Map<Id,Contact> contacts = new Map<Id,Contact>([SELECT Id, Name, Preferred_Language__c FROM CONTACT WHERE Id IN :contactIds]);

        List<User> users = [Select Id,ContactId, LanguageLocaleKey FROM User WHERE ContactId IN :contactIds];

        Notification_template__c notificationTemplate = 
    				[SELECT Subject__c, Name, Message__c, Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
                	Expire_in_days__c, CriticalNotification__c, LanguageLocaleKey__c,Alert_Contact_By_Push_Notification__c
                    FROM Notification_template__c 
                    WHERE  Identifier__c = 'Lvl 2 Registration reminder'];

        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'CSP_Regist_L2_Portal_Notification_VF'];

        if(notificationTemplate == null || emailTemplate == null){
            return NONE;
        }    

        String headerImageUrl;
        Document doc = [Select id From Document Where name= 'CSP_Notification_Header_Image'];
        if(doc != null) headerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+doc.Id+'&oid='+userinfo.getorganizationid();       

        List<Notification__c> notifications = new List<Notification__c>();    
        Messaging.SingleEmailMessage message;
        Contact contact;
        String url = getPortalProfileUrl();

        Map<String,Messaging.SingleEmailMessage> templatesByLanguage = new Map<String,Messaging.SingleEmailMessage>();
        
        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Integer maxLanguages = ple.size();

        for(User user :users){
            if(!templatesByLanguage.containsKey(user.LanguageLocaleKey)){
                message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, user.Id, null);
                templatesByLanguage.put(user.LanguageLocaleKey, message);
            }
            if(templatesByLanguage.size() == maxLanguages){
                break;
            }
        }

        for(User user :users){

            contact = contacts.get(user.ContactId);
            message = templatesByLanguage.get(user.LanguageLocaleKey);

            notifications.add( new Notification__c(
                Contact__c = user.ContactId,
                Message__c = message.getPlainTextBody().replace('[CustomerName]',contact.Name).replace('[URL]','"'+  url +'" target="_blank"').replace('[HeaderUrl]',headerImageUrl),
                Alert_Contact_By_Email__c = notificationTemplate.Alert_Contact_By_Email__c,
                Alert_Contact_By_Push_Notification__c = notificationTemplate.Alert_Contact_By_Push_Notification__c,
                Subject__c = message.getSubject(),
                Type__c = notificationTemplate.Type__c,
                Notificatin_color__c = notificationTemplate.Notification_color__c,
                Notification_Campagne_Name__c = '',
                Critical_notification__c = notificationTemplate.CriticalNotification__c,
                Expiry_date__c = system.Now() + notificationTemplate.Expire_in_days__c
            ));
        }

        Database.SaveResult[] srList;
        try{
            srList = Database.insert(notifications,false);
        }catch(Exception e){            
            return NONE;
        }

        Boolean someFailed = false;
        Boolean someSucceded = false;

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                 someSucceded = true;
            }else{
                someFailed = true;
            }
        }
        if(!someFailed){
            return ALL;
        }else if(!someSucceded){
            return NONE;
        }
        return SOME;
    }
    
    @InvocableMethod(label='Creates notification for lvl 2 Registration' description='Creates notification for lvl 2 Registration')
    public static List<Boolean> createSingleNotification(List<Id> contactIds){

        Id contactId = contactIds.get(0);

        Contact contact = [SELECT Name, Preferred_Language__c FROM CONTACT WHERE Id = :contactId];

        Notification_template__c notificationTemplate = 
    				[SELECT Subject__c, Name, Message__c, Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
                	Expire_in_days__c, CriticalNotification__c, LanguageLocaleKey__c,Alert_Contact_By_Push_Notification__c
                    FROM Notification_template__c 
                    WHERE  Identifier__c = 'Lvl 2 Registration reminder'];

        //Get email template 
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'CSP_Regist_L2_Portal_Notification_VF'];

        if(notificationTemplate == null || emailTemplate == null){
            return new List<Boolean>{false};
        }        

        Id userId = [Select Id FROM User WHERE ContactId = :contactId].Id;     

        //Load the template with the user language
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, userId, null);

        String headerImageUrl='';
        List<Document> docs = [Select id From Document Where name= 'CSP_Notification_Header_Image'];
        if(docs.size() != 0){
             headerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+ (docs.get(0)).Id+'&oid='+userinfo.getorganizationid();
        }
        String url =  getPortalProfileUrl();

        Notification__c notification = new Notification__c(
            Contact__c = contactId,
            Message__c = message.getPlainTextBody().replace('[CustomerName]',contact.Name).replace('[URL]','"'+  url +'" target="_blank"').replace('[HeaderUrl]',headerImageUrl),
            Alert_Contact_By_Email__c = notificationTemplate.Alert_Contact_By_Email__c,
            Alert_Contact_By_Push_Notification__c = notificationTemplate.Alert_Contact_By_Push_Notification__c,
            Subject__c = message.getSubject(),
            Type__c = notificationTemplate.Type__c,
            Notificatin_color__c = notificationTemplate.Notification_color__c,
            Notification_Campagne_Name__c = '',
            Critical_notification__c = notificationTemplate.CriticalNotification__c,
            Expiry_date__c = system.Now() + notificationTemplate.Expire_in_days__c
        );
        
        try{
            insert notification;
        }catch(Exception e){           
            return new List<Boolean>{false};
        }
        return new List<Boolean>{true};
    }

    private static Boolean updateLastNotificationDate(List<Id> contactIds){
        List<Contact> contacts = [SELECT Id,Last_registration_notification_date__c FROM Contact WHERE Id IN :contactIds];
        for(Contact c :contacts){
            c.Last_registration_notification_date__c = System.today();
        }
        try{
            update contacts;
        }catch(Exception e){
            return false;
        }
        return true;
    }


    static private String getPortalProfileUrl(){
        Id networkId = [SELECT Id FROM Network WHERE Name = 'CS Portal'].Id;
        string url = Network.getLoginURL(networkId).substring(0,Network.getLoginURL(networkId).indexOf('login'));
        url = url + 'my-profile?triggerL2=true';
        return url;
    }
}