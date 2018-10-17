/*
    Class that create a notification to Portal Users
    Used in Portal and NewGen APP (mobile)
*/
public with sharing class ISSP_CreateNotification {

    public static Boolean privetTrigger = false;

    public static map<Schema.sObjectType,string> objTypecontactIdMap = new map<Schema.sObjectType,string>{Case.getSObjectType()=>'ContactId',Contact.getSObjectType()=>'Id',Portal_Application_Right__c.getSObjectType()=>'Contact__c'};
    
    public static void CreateNotificationForSobjectList(list<sObject> sObjList){
        list<string> tList = new  list<string>();
        string contactField = objTypecontactIdMap.get(sObjList[0].Id.getSObjectType());
        set<string> contactsIdSet = new set<string>();
        set<string> templatesNameSet = new set<string>();
        for(sObject obj : sObjList){
            contactsIdSet.add(string.valueOf(obj.get(contactField)));
             if(String.isNotEmpty((String)obj.get('Notification_template__c')))
                for(string str:string.valueOf(obj.get('Notification_template__c')).split(';')){
                    if(str != ''){
                        templatesNameSet.add(str);
                    }
                }
        }
        if(templatesNameSet.size()==0) return;

        map<string,set<string>> ContactsAdminsSetMap = getAllContactsAdmins(contactsIdSet);
        map<string,boolean> isAdminsNotificationMap = new map<string,boolean>();

        for(Notification_template__c nt : [select Id,Admins_Users__c,Name from Notification_template__c where Name in:templatesNameSet]){+
            System.debug(loggingLevel.FINE, '____ [cls ISSP_CreateNotification - CreateNotificationForSobjectList] nt - ' + nt);
            isAdminsNotificationMap.put(nt.Name,false);
            if(nt.Admins_Users__c == 'Administrators'){
                isAdminsNotificationMap.put(nt.Name,true);
            }
        }
        
        System.debug(loggingLevel.FINE, '____ [cls ISSP_CreateNotification - CreateNotificationForSobjectList] isAdminsNotificationMap - ' + isAdminsNotificationMap);
        System.debug(loggingLevel.FINE, '____ [cls ISSP_CreateNotification - CreateNotificationForSobjectList] ContactsAdminsSetMap - ' + ContactsAdminsSetMap);

        for(sObject obj :sObjList){
            if(obj.get('Notification_template__c') != null && obj.get('Notification_template__c') != '')
                for(string str:string.valueOf(obj.get('Notification_template__c')).split(';')){
                    if(str != ''){
                        tList.add(obj.get(contactField)+':'+str);
                        if(isAdminsNotificationMap.containsKey(str) && isAdminsNotificationMap.get(str) && ContactsAdminsSetMap.containsKey(string.valueOf(obj.get(contactField)))){
                            for(string conId : ContactsAdminsSetMap.get(string.valueOf(obj.get(contactField)))){
                                tList.add(conId+':'+str);
                            }
                        }
                    }
                }
          obj.put('Notification_template__c','');
        }
        if(tList.size()>0)
            createNotification(tList);  
    }
    
    public static void createNotification(List<String> tList) {
        createNotification(tList, true);
    }

    public static List<Notification__c> createNotification(list<string> tList, Boolean insertNotifications){
        try{
            map<string,set<string>> tMap = createSetMapFromList(tList,0,1);
            set<string> notificationNameSet = getNotificationNameSet(tMap);
            
            map<string,string> languageMap = getLanguagesMap();
            map<string,string> contactLanguageMap = new map<string,string>();
            for(User user : [Select u.LanguageLocaleKey, u.ContactId From User u where ContactId in:tMap.keySet()]){
                contactLanguageMap.put(user.ContactId,languageMap.get(user.LanguageLocaleKey));
            }
            
            map<string,Notification_template__c> notificationTemplateMap = new map<string,Notification_template__c>();
            map<string,map<string,Notification_template__c>> notificationTemplateTranslateMap = new  map<string,map<string,Notification_template__c>>();
            
            list<Notification__c> newNotificationList = new list<Notification__c>();
            
            list <Notification_template__c> NotificationTemplateList = 
                [Select n.Subject__c, n.Name, n.Message__c, n.Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
                    Expire_in_days__c, CriticalNotification__c,Alert_Contact_By_Push_Notification__c, 
                    (Select Subject__c, Name, Message__c, Language__c,Type__c,Notification_color__c,Alert_Contact_By_Email__c,
                    Expire_in_days__c, CriticalNotification__c, Alert_Contact_By_Push_Notification__c From Notification_templates__r)
                     From Notification_template__c n  where  Name in:notificationNameSet ];
            for(Notification_template__c nt: NotificationTemplateList){
                notificationTemplateMap.put(nt.Name,nt);
                notificationTemplateTranslateMap.put(nt.Name,new map<string,Notification_template__c>());
                for(Notification_template__c ntTranslate:nt.Notification_templates__r){
                    notificationTemplateTranslateMap.get(nt.Name).put(ntTranslate.Language__c,ntTranslate);
                }
            }
            
            for(string parentId : tMap.keySet()){
                for(string rempId : tMap.get(parentId)){
                    Notification_template__c nt = notificationTemplateMap.get(rempId);
                    if(notificationTemplateTranslateMap.get(rempId).get(contactLanguageMap.get(parentId)) != null) nt = notificationTemplateTranslateMap.get(rempId).get(contactLanguageMap.get(parentId));

                    Notification__c notification = new Notification__c(
                        Contact__c = parentId,
                        Message__c = nt.Message__c,
                        Alert_Contact_By_Email__c = nt.Alert_Contact_By_Email__c,
                        Alert_Contact_By_Push_Notification__c = nt.Alert_Contact_By_Push_Notification__c,
                        Subject__c = nt.Subject__c
                        ,Type__c = nt.Type__c
                        ,Notificatin_color__c = nt.Notification_color__c 
                        ,Notification_Campagne_Name__c = ISSP_CampaignNotificationBatch.notificationCampagneName
                        ,Critical_notification__c = nt.CriticalNotification__c
                        ,Expiry_date__c = (nt.Expire_in_days__c != null ? system.Now() + nt.Expire_in_days__c : null)
                    );
                    newNotificationList.add(notification);
                }
            }
            
            if(insertNotifications) insert newNotificationList;

            return newNotificationList;
           
        }catch(Exception e){
            system.debug('\n\n\n\n Exception : '+e.getMessage()+'\n\n\n\n');
            return new List<Notification__c>();
        }
        
   }
   
   private static map<string,set<string>> createSetMapFromList(list<string> tList,integer key,integer value){
        map<string,set<string>> tMap = new  map<string,set<string>>();
        for(string str:tList){
           if(tMap.get(str.split(':')[key])==null) tMap.put(str.split(':')[key],new set<string>());
           tMap.get(str.split(':')[key]).add(str.split(':')[value]);
        }
        return tMap;
   }
   
   
   private static  set<string> getNotificationNameSet(map<string,set<string>> tMap){
        set<string> roleNameSet = new set<string>();
        for(string str:tMap.keySet()){
           roleNameSet.addAll(tMap.get(str));
        }
        return roleNameSet;
   }
   
   private static  map<string,set<string>> getAllContactsAdmins(set<string> contactsSet){
       map<Id,Id> topAccountContact = new  map<Id,Id>();
       map<string,set<string>> contactAdminMap = new map<string,set<string>>();
       
       for(Contact con: [select Id,AccountId,Account.Top_Parent__c from Contact where Id in :contactsSet]){
            if(con.Account.Top_Parent__c!=null && con.AccountId!=null){
                //commenting lines below cause they will never occur
                //if(con.Account.Top_Parent__c==null) topAccountContact.put(con.AccountId,con.Id);
                //else 
                topAccountContact.put(con.Account.Top_Parent__c,con.Id);
             }
            contactAdminMap.put(con.Id,new set<string>());
       }
       for(Contact con: [select Id,AccountId,Account.Top_Parent__c from Contact where Account.Top_Parent__c in :topAccountContact.keySet() 
                                                                                   and User_Portal_Status__c='Approved Admin']){
            string topAccId = con.Account.Top_Parent__c;
            if(topAccId == null) topAccId = con.AccountId;
            
            contactAdminMap.get(topAccountContact.get(topAccId)).add(con.Id);
       }
       return contactAdminMap;
   }
   
   
    
    public static map<string,string> getLanguagesMap()
    {
      Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      map<string,string> languageMap = new map<string,string>();
      
      for( Schema.PicklistEntry f : ple)
      {
          languageMap.put( f.getValue(),f.getLabel());
      }       
       return languageMap;
    }
   
    /*not used anywhere
    public static void debug(string str,string mes){
        system.debug('n\n\n\n'+str+' : '+ mes +'\n\n\n\n');
    }
    public static void debug(string str,map<string,string> mes){
        system.debug('n\n\n\n'+str+' : '+ mes +'\n\n\n\n');
    }
    public static void debug(string str,set<Id> mes){
        system.debug('n\n\n\n'+str+' : '+ mes +'\n\n\n\n');
    }
    public static void debug(string str,map<Id,Id> mes){
        system.debug('n\n\n\n'+str+' : '+ mes +'\n\n\n\n');
    }*/



    //INC253595 - Start

    public static void SendEmailToPortalAdminNewContact(list<Contact> newPortalContactList) {
        
        system.debug('SendEmailToPortalAdminNewContact starting...' + newPortalContactList);
        ID templateId = PortalServiceAccessTriggerHandler.getEmailTemplateIdByName(ENV.EmailTemplateData.NotifyAdminNewContact);
        System.debug('templateId==>'+templateId);
        if(String.isBlank(templateId)) {
            system.debug(LoggingLevel.ERROR, 'Email template ' + ENV.EmailTemplateData.NotifyAdminNewContact + ' not found');   
        }
        Set<ID> accountIDs = new Set<ID>();
        for(Contact con : newPortalContactList) {
                accountIDs.add(con.AccountId);
        }
        
        System.debug('zZzZ accountIDs==>'+accountIDs);
        map<ID, Set<ID>> accIdToUserIdMap = new map<ID, Set<ID>>();
        for(AccountTeamMember member : PortalServiceAccessTriggerHandler.getPortalAdmins(accountIDs)) {
            Set<ID> userIDs = accIdToUserIdMap.get(member.AccountId);
            if(null == userIDs)
                userIDs = new Set<ID>();
            
            userIDs.add(member.UserId);
            accIdToUserIdMap.put(member.AccountId, userIDs);
        }
        
        ID standartReplyUserID = PortalServiceAccessTriggerHandler.getStandartReplyUserID(ENV.Reply_Email);
        System.debug('zZzZ standartReplyUserID==>'+standartReplyUserID);    
        
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        for(Contact con : newPortalContactList) {
            System.debug('con==>'+con + 'accountMap ' + accIdToUserIdMap);
                     
            Set<ID> portalAdminUserIDs = accIdToUserIdMap.get(con.AccountId);
            if(null == portalAdminUserIDs) continue;
            
            if(String.isNotBlank(templateId)) {
                for(ID userId : portalAdminUserIDs) {
                    Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage(); 
                    emailMsg.setTemplateId(templateId);
                    emailMsg.setTargetObjectId(userId);
                    emailMsg.saveAsActivity = false;
                    
                    if(null != standartReplyUserID)
                        emailMsg.setOrgWideEmailAddressId(standartReplyUserID);
                    else {
                        emailMsg.setReplyTo(ENV.Reply_Email);
                        emailMsg.setSenderDisplayName(ENV.AccessToApplicationServiceRequested_Email_Subject);
                    }
                    emailMsg.setWhatId(con.id); 
                    msgList.add(emailMsg);
                }
            }

            // NewGen Mobile APP Start
            Set <String> portalAdminUserIDsAsString = (Set<String>)JSON.deserialize(JSON.serialize(portalAdminUserIDs), Set<String>.class);
            NewGen_Account_Statement_Helper.sendPushNotification(portalAdminUserIDsAsString, Label.NewGenApp_PortalUserRequested, 
                null, NewGen_Account_Statement_Helper.NAVIGATE_TO_USER_REQUEST_ADMIN);
            // NewGen Mobile APP End
        }
        System.debug('zZzZ msgList==>'+msgList);
        if(!msgList.isEmpty()){
            Messaging.sendEmail(msgList);
        }
        else 
            system.debug(LoggingLevel.ERROR, 'emails not sent !');
    }
   
    //INC253595 - End
   
}