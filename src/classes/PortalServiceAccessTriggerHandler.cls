public without sharing class PortalServiceAccessTriggerHandler {

    public static Boolean privetTrigger = false;
    public static Boolean avoidAppTrigger = false;

    public static final String CURRENCYCENTERAPPURL = '/ISSP_CurrencyCenterHome';

    public static Set<Id> IEP_contactIDs;
    public static Map<Id, Id> IEP_contactIDsMap;

    public static void onAfterInsert(list<Portal_Application_Right__c> newPortalApplicationRightList 
                                   , map<ID, Portal_Application_Right__c> newPortalApplicationRightMap) {
        
        SendEmailToPortalAdminToValidateRequest(newPortalApplicationRightList);
        
    }
    
    public static void SendEmailToPortalAdminToValidateRequest(list<Portal_Application_Right__c> newPortalApplicationRightList) {
        ////ENV.EmailTemplateDN.Notify_Admin_of_app_requestVF //Notify_Admin_of_app_requestVF

        System.debug(LoggingLevel.ERROR, '---------> Cá estou eu!!!');

        if (IEP_contactIDs == null) {
            IEP_contactIDs = new Set<Id>();
            IEP_contactIDsMap = new Map<Id, Id>();

            List<Connected_App_Roles__c> rolesAux = [SELECT Role__c FROM Connected_App_Roles__c where Connected_App_Provisioning_Name__c = 'IATA EasyPay (EDENRED)' and Manage_User_Access__c = true];
            Set<String> roles = new Set<String>();
            for(Connected_App_Roles__c r : rolesAux) {
                roles.add(r.Role__c);
            }

            List<Portal_Application_Right__c> parList = [Select Contact__c, contact__r.account.Top_Parent__c From Portal_Application_Right__c where ANG_Portal_Service_Role__c in : roles];

            for(Portal_Application_Right__c p : parList) {
                IEP_contactIDs.add(p.Contact__c);
                IEP_contactIDsMap.put(p.Contact__c, p.contact__r.account.Top_Parent__c);
            }
        }

        System.debug(LoggingLevel.ERROR, '----->' + IEP_contactIDs);

        ID templateId = getEmailTemplateIdByName(ENV.EmailTemplateData.NotifyAdminOfAppRequestVF);

        ID templateID_CNS = getEmailTemplateIdByName (ENV.EmailTemplateData.NotifyAdminOfAppRequestVF_CNS);
        if(String.isBlank(templateId)) {
            system.debug(LoggingLevel.ERROR, 'Email template ' + ENV.EmailTemplateData.NotifyAdminOfAppRequestVF + ' not found');   
            return;
        }
        Set<ID> accountIDs = new Set<ID>();
        for(Portal_Application_Right__c par : newPortalApplicationRightList) {
            if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)) {
                if (!ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    accountIDs.add(par.Account__c);
                }
            } 
        }

        Set<ID> contactIDsIep = new Set<ID>();
        for(Portal_Application_Right__c par : newPortalApplicationRightList) {
            if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)) {
                if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    contactIDsIep.addAll(IEP_contactIDs);
                }
            } 
        }

        map<ID, Set<ID>> accIdToUserIdMap = new map<ID, Set<ID>>();
        for(AccountTeamMember member : getPortalAdmins(accountIDs)) {
            Set<ID> userIDs = accIdToUserIdMap.get(member.AccountId);
            if(null == userIDs)
                userIDs = new Set<ID>();
            userIDs.add(member.UserId);
            accIdToUserIdMap.put(member.AccountId, userIDs);
        }

        map<ID, Set<ID>> accIdToUserIdMapIep = new map<ID, Set<ID>>();
        for(User user : getPortalIepUsers(contactIDsIep)) {
            Set<ID> userIDs = accIdToUserIdMapIep.get(user.ContactId);
            if(null == userIDs)
                userIDs = new Set<ID>();
            userIDs.add(user.id);
            accIdToUserIdMapIep.put(user.contactId, userIDs);
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

                system.debug(LoggingLevel.ERROR, 'Email to admin');

                Set<ID> portalAdminUserIDs;
                if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    if(IEP_contactIDsMap.get(par.contact__c) == par.contact__r.account.Top_Parent__c) {
                        portalAdminUserIDs = accIdToUserIdMap.get(par.contact__c);
                    }
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

                    system.debug(LoggingLevel.ERROR, 'Email to admin : ' + userId);
                    
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

        if(!msgList.isEmpty()){
            Messaging.sendEmail(msgList);
        }
        else 
            system.debug(LoggingLevel.ERROR, 'emials not sent !');
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

    public static list<User> getPortalIepUsers(Set<Id> contactIds) {        
        return 
            [SELECT Id,
                    ContactId
               FROM User 
              WHERE ContactId IN: contactIds]; 
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