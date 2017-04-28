public without sharing class PortalServiceAccessTriggerHandler {

    public static Boolean privetTrigger = false;
    public static Boolean avoidAppTrigger = false;

    public static final String CURRENCYCENTERAPPURL = '/ISSP_CurrencyCenterHome';

    public static void onAfterInsert(list<Portal_Application_Right__c> newPortalApplicationRightList 
                                   , map<ID, Portal_Application_Right__c> newPortalApplicationRightMap) {
        
        SendEmailToPortalAdminToValidateRequest(newPortalApplicationRightList);
        
    }
    
    public static void SendEmailToPortalAdminToValidateRequest(list<Portal_Application_Right__c> newPortalApplicationRightList) {

        Set<String> roles = ANG_ISSP_IEPMailRecipientsUtils.getIEPRolesManageUserAccess();
    
        ID templateId = getEmailTemplateIdByName(ENV.EmailTemplateData.NotifyAdminOfAppRequestVF);
    
        ID templateID_CNS = getEmailTemplateIdByName (ENV.EmailTemplateData.NotifyAdminOfAppRequestVF_CNS);
        if(String.isBlank(templateId)) {
            system.debug(LoggingLevel.ERROR, 'Email template ' + ENV.EmailTemplateData.NotifyAdminOfAppRequestVF + ' not found');   
            return;
        }
        Set<ID> accountIDs = new Set<ID>();
        Map<id, boolean> cannotManagedPortalAdminMap = new Map<id, boolean>();
        Set<String> accountIDsIepAux = new Set<String>();

        for(Portal_Application_Right__c par : newPortalApplicationRightList) {
            if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)) {
                if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    accountIDsIepAux.add(par.Account__c);
                } else {
                    accountIDs.add(par.Account__c);
                }                
                cannotManagedPortalAdminMap.put(par.Portal_Application__c, par.Portal_Application__r.Cannot_be_managed_by_portal_admin__c);
            } 
        }

        Map<ID, Set<Id>> accIdToUserIdMapIep = ANG_ISSP_IEPMailRecipientsUtils.getRecipients(accountIDsIepAux, roles);

        //
        // Get account's IEP Status to supress mails from beeing send.
        //
        Map<Id, String> iepAccountStatusMap = new Map<Id, String>();

        List<Portal_Application_Right__c> parl = [Select contact__r.account.ANG_IEP_Status_FF__c From Portal_Application_Right__c Where account__c in : accountIDsIepAux];
        
        for(Portal_Application_Right__c par : parl) {
            iepAccountStatusMap.put(par.contact__r.accountId, par.contact__r.account.ANG_IEP_Status_FF__c);
        }

        //
        // Get the users by account. 
        //
        map<ID, Set<ID>> accIdToUserIdMap = new map<ID, Set<ID>>();

        for(AccountTeamMember member : getPortalAdmins(accountIDs)) {
            Set<ID> userIDs = accIdToUserIdMap.get(member.AccountId);
            if(null == userIDs)
                userIDs = new Set<ID>();
            userIDs.add(member.UserId);
            accIdToUserIdMap.put(member.AccountId, userIDs);
        }

        ID standartReplyUserID = getStandartReplyUserID(ENV.Reply_Email);
    
        ID standardReplyUserID_CNS = getStandartReplyUserID(ENV.Reply_Email_CNS);
        list<Messaging.SingleEmailMessage> msgList = new list<Messaging.SingleEmailMessage>();
        for(Portal_Application_Right__c par : newPortalApplicationRightList) {
    
            //if (par.Application_Name__c != 'Treasury Dashboard'){
            if (!par.Application_Name__c.startsWith('Treasury Dashboard') && !par.Application_Name__c.startsWith('Standards Setting Workspace')){
                
                if(!ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)){
                    continue;
                }

                Boolean cannotManagedPortalAdmin = cannotManagedPortalAdminMap.get(par.Portal_Application__c);
                
                // The email to the Portal administrator can only be send when
                // portal_application__c.Cannot_be_managed_by_portal_admin__c = false
                // OR
                // portal_application__c.Cannot_be_managed_by_portal_admin__c = true && portal_application__c = IEP Service && 
                //      IEP Account Status = open
                //
                if( (cannotManagedPortalAdmin == false) ||
                    (cannotManagedPortalAdmin == true && ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c) &&
                     iepAccountStatusMap.get(par.Account__c) == ANG_ISSP_PortalServiceHelper.STATUS_OPEN) ) {

                    Set<ID> portalAdminUserIDs;
                    if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                        System.debug(LoggingLevel.ERROR, 'EasyPay');        
                        portalAdminUserIDs = accIdToUserIdMapIep.get(par.Account__c);
                    } else {
                        portalAdminUserIDs = accIdToUserIdMap.get(par.Account__c);                   
                    }

                    if(null == portalAdminUserIDs) {
                        continue;
                    }

                    for(ID userId : portalAdminUserIDs) {
                        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage(); 
                        if(par.Conctact_is_CNS__c!=null && par.Conctact_is_CNS__c){
                            emailMsg.setTemplateId(templateId_CNS);
                        }else{
                        emailMsg.setTemplateId(templateId);
                        } 
                        emailMsg.setTargetObjectId(userId);
                        emailMsg.saveAsActivity = false;
                        
                        if(!par.Conctact_is_CNS__c && par.Conctact_is_CNS__c!=null){
                            if(null != standartReplyUserID){ emailMsg.setOrgWideEmailAddressId(standartReplyUserID); }
                        else {
                            emailMsg.setReplyTo(ENV.Reply_Email);
                            emailMsg.setSenderDisplayName(ENV.AccessToApplicationServiceRequested_Email_Subject);
                        }

                        }else{
                             if(null != standardReplyUserID_CNS){ emailMsg.setOrgWideEmailAddressId(standardReplyUserID_CNS); }
                            else {
                                emailMsg.setReplyTo(ENV.Reply_Email_CNS);
                                emailMsg.setSenderDisplayName(ENV.AccessToApplicationServiceRequested_Email_Subject_CNS);
                            }
                        }
                        emailMsg.setWhatId(par.ID); 
                        msgList.add(emailMsg);
                    }
                }
            }
        }
    
        if(!msgList.isEmpty()){
            Messaging.sendEmail(msgList);
        }
        else 
            system.debug(LoggingLevel.ERROR, 'Emails not sent !');
    }
    
    public static ID getStandartReplyUserID(String senderAddress) {
        list<OrgWideEmailAddress> owa = [SELECT Id 
                                                //,Address 
                                                //,DisplayName 
                                           FROM OrgWideEmailAddress 
                                          WHERE Address =: senderAddress limit 1];
        return ISSP_Utilities.isNotEmpty(owa) ? owa[0].Id : null;
    } 
    
    public static ID getEmailTemplateIdByName(String name) {
        list<EmailTemplate> tmpList = 
                            [SELECT ID 
                               FROM EmailTemplate 
                              WHERE DeveloperName =: name]; 
        return !tmpList.isEmpty() ? tmpList[0].Id : null;   
    }
    
    public static list<AccountTeamMember> getPortalAdmins(Set<Id> accountIds) {
        
        return 
            [SELECT Id,
                    UserId, 
                    AccountId
                    //TeamMemberRole,
                    //User.Contact.Salutation, 
                    //User.Contact.Name, 
                    //User.Contact.Email,
                    //User.Contact.AccountId,
                    //User.Contact.Account.Name, 
                    //User.Contact.Account.BillingCountry
               FROM AccountTeamMember 
              WHERE AccountId IN: accountIds 
                AND TeamMemberRole=: ENV.TeamMemberRolePL.PortalAdministrator]; 
    }
    
    public static Set<Id> getPortalIepUsers(Set<Id> contactIds) {        
        List<User> ul = [SELECT Id
                          FROM User 
                         WHERE ContactId IN: contactIds]; 
        Set<Id> rs = new Set<Id>();                         
        for(User u : ul) {
            rs.add(u.id);            
        }
        return rs;
    }
    
    public static void manageAccessTD (Set <Id> accessIds, Set <Id> contactIds){
        system.debug('accessIds: ' + accessIds);
        system.debug('contactIds: ' + contactIds);
        List <Portal_Application_Right__c> accessListUpdate = new List <Portal_Application_Right__c>();
        List <Portal_Application_Right__c> accessList =
            [SELECT Id, Contact__c
            FROM Portal_Application_Right__c
            WHERE Application_Name__c LIKE 'Treasury Dashboard%'
            AND Right__c = 'Access Granted'
            AND Contact__c IN :contactIds];
        if (!accessList.isEmpty()){
            system.debug('accessList: ' + accessList);
            for (Portal_Application_Right__c thisAccess : accessList){
                if (!accessIds.contains(thisAccess.Id) && contactIds.contains(thisAccess.Contact__c)){
                    system.debug('accessIds contains id');
                    thisAccess.Right__c = 'Obsolete';
                    accessListUpdate.add(thisAccess);
                }
                else{
                    system.debug('accessIds not contains id');
                }
            }
        }
        if (!accessListUpdate.isEmpty()){
            avoidAppTrigger = true;
            update accessListUpdate;
        }
    }

    /*** Automatically subscribe the new Currency Center users to all the existing Country Profile records***/
    public static void SubscribeNewUsersToAllCountryProfiles(Map<Id, Portal_Application_Right__c> newItems){
        list<EntitySubscription> lstUserSubscriptions = new list<EntitySubscription>();
        set<Id> setRelatedContactIds = new set<Id>();

        // Get contacts that can access the service
        for (Portal_Application_Right__c par : newItems.values()) {
            if (par.Application_Start_URL__c == CURRENCYCENTERAPPURL && par.Right__c == 'Access Granted') {
                setRelatedContactIds.add(par.Contact__c);
            }            
        }

        if (!setRelatedContactIds.isEmpty()) {
            // Get the actual user IDs
            list<Id> lstRelatedUserIds = new list<Id>();
            for (User usr : [SELECT Id, ContactId FROM User WHERE ContactId <> null AND ContactId IN :setRelatedContactIds]) {
                lstRelatedUserIds.add(usr.Id);
            }

            // Get the community Id
            Id communityId = [SELECT Id FROM Network WHERE Name = 'IATA Portal'].Id;

            // Get a list of all existing Country Profiles
            list<Country_Profile__c> lstCountryProfiles = [SELECT Id FROM Country_Profile__c];

            // Create the chatter subscription records
            for (Id userId : lstRelatedUserIds) {
                for (Country_Profile__c cp : lstCountryProfiles) {
                    EntitySubscription newSubscription = new EntitySubscription(SubscriberId = userId, ParentId = cp.Id, NetworkId = communityId);
                    lstUserSubscriptions.add(newSubscription);
                }
            }

            // Insert the records. Will fail if Chatter Feeds has not been previously activated on the Country Profile object
            if (!lstUserSubscriptions.isEmpty()) 
                insert lstUserSubscriptions;
        }
    }
}