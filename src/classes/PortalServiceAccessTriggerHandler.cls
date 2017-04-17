public without sharing class PortalServiceAccessTriggerHandler {

    public static Boolean privetTrigger = false;
    public static Boolean avoidAppTrigger = false;

    public static final String CURRENCYCENTERAPPURL = '/ISSP_CurrencyCenterHome';

    public static void onAfterInsert(list<Portal_Application_Right__c> newPortalApplicationRightList 
                                   , map<ID, Portal_Application_Right__c> newPortalApplicationRightMap) {
        
        SendEmailToPortalAdminToValidateRequest(newPortalApplicationRightList);
        
    }
    
    public static void SendEmailToPortalAdminToValidateRequest(list<Portal_Application_Right__c> newPortalApplicationRightList) {
        ////ENV.EmailTemplateDN.Notify_Admin_of_app_requestVF //Notify_Admin_of_app_requestVF

        List<Connected_App_Roles__c> rolesAux = [SELECT Role__c 
                                                   FROM Connected_App_Roles__c 
                                                  where Connected_App_Provisioning_Name__c = 'IATA EasyPay (EDENRED)' 
                                                    and Manage_User_Access__c = true];
        Set<String> roles = new Set<String>();
        for(Connected_App_Roles__c r : rolesAux) {
            roles.add(r.Role__c);
        }

        //System.debug(LoggingLevel.ERROR, 'Roles->' + roles);

        //
        // Get all the accounts to restrict the query on portal application right.
        //
        Set<String> accountIDsIepAux = new Set<String>();
        for(Portal_Application_Right__c par : newPortalApplicationRightList) {
            if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)) {
                if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    accountIDsIepAux.add(par.Account__c);
                }
            } 
        }            

        //System.debug(LoggingLevel.ERROR, 'accountIDsIepAux->' + accountIDsIepAux);                

        //
        // Get all the top parents linked to the accounts that have the configured roles .
        //
        List<Portal_Application_Right__c> parl = [Select contact__r.account.Top_Parent__c,
                                                         contact__r.accountId
                                                    From Portal_Application_Right__c
                                                   Where account__c in : accountIDsIepAux];

        //System.debug(LoggingLevel.ERROR, 'parl->' + parl);

        Set<String> accountsSet = new Set<String>();

        Map<String, String> topParents = new Map<String, String>();

        for(Portal_Application_Right__c par : parl) {
            if(par.contact__r.account.Top_Parent__c != null) {
                accountsSet.add(par.contact__r.account.Top_Parent__c);
                topParents.put(par.contact__r.account.Top_Parent__c, par.contact__r.accountId);
            }
            accountsSet.add(par.contact__r.accountId);           
            topParents.put(par.contact__r.accountId, par.contact__r.accountId);
        }

        //System.debug(LoggingLevel.ERROR, 'accountsSet->' + accountsSet);
        //System.debug(LoggingLevel.ERROR, 'topParents->' + topParents);

        //
        // Get all portal application right with the top parent linked to the accounts that have the configured roles.
        //
        List<Portal_Application_Right__c> parList2 = [Select Account__c,
                                                             Contact__c
                                                        From Portal_Application_Right__c
                                                       Where ANG_Portal_Service_Role__c in : roles
                                                         And contact__r.accountId in : accountsSet];

        //System.debug(LoggingLevel.ERROR, 'parList2->' + parList2);

        Map<Id, Set<Id>> IEP_accountIDs = new Map<Id, Set<Id>>();

        for(Portal_Application_Right__c p : parList2) {
            Set<ID> contactIDs = IEP_accountIDs.get(p.Account__c);
            if(null == contactIDs)
                contactIDs = new Set<ID>();
            contactIDs.add(p.Contact__c);
            IEP_accountIDs.put(p.Account__c, contactIDs);
        }

        for(Portal_Application_Right__c par : newPortalApplicationRightList) {
            if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)) {
                if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    Set<ID> contactIDs = IEP_accountIDs.get(par.Account__c);
                    if(null == contactIDs)
                        contactIDs = new Set<ID>();
                    contactIDs.add(par.Contact__c);
                    IEP_accountIDs.put(par.Account__c, contactIDs);                                
                }
            } 
        }            

        //System.debug(LoggingLevel.ERROR, 'IEP_accountIDs->' + IEP_accountIDs);

        //--------------------

        ID templateId = getEmailTemplateIdByName(ENV.EmailTemplateData.NotifyAdminOfAppRequestVF);

        ID templateID_CNS = getEmailTemplateIdByName (ENV.EmailTemplateData.NotifyAdminOfAppRequestVF_CNS);
        if(String.isBlank(templateId)) {
            system.debug(LoggingLevel.ERROR, 'Email template ' + ENV.EmailTemplateData.NotifyAdminOfAppRequestVF + ' not found');   
            return;
        }

        //
        // Normal part
        //
        Set<ID> accountIDs = new Set<ID>();
        for(Portal_Application_Right__c par : newPortalApplicationRightList) {
            if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)) {
                if (!ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    accountIDs.add(par.Account__c);
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

        //
        // IEP Part
        //
        map<ID, Set<Id>> accIdToUserIdMapIep = new map<Id, Set<ID>>();

        for(Id key : IEP_accountIDs.keySet()) {
            Set<Id> userIDsAux = new Set<id>();

            //System.debug(LoggingLevel.ERROR, 'key->' + key);
            //System.debug(LoggingLevel.ERROR, 'topParents.get(key)->' + topParents.get(key));

            userIDsAux.addAll(getPortalIepUsers(IEP_accountIDs.get(key)));

            Set<Id> userIDs = accIdToUserIdMapIep.get(topParents.get(key));

            if(null == userIDs)
                userIDs = new Set<ID>();

            userIDs.addAll(userIDsAux);

            accIdToUserIdMapIep.put(topParents.get(key), userIDs);
        }

        //System.debug(LoggingLevel.ERROR, 'accIdToUserIdMapIep->' + accIdToUserIdMapIep);        

        ID standartReplyUserID = getStandartReplyUserID(ENV.Reply_Email);

        ID standardReplyUserID_CNS = getStandartReplyUserID(ENV.Reply_Email_CNS);
        list<Messaging.SingleEmailMessage> msgList = new list<Messaging.SingleEmailMessage>();
        for(Portal_Application_Right__c par : newPortalApplicationRightList) {

            //if (par.Application_Name__c != 'Treasury Dashboard'){
            if (!par.Application_Name__c.startsWith('Treasury Dashboard') && !par.Application_Name__c.startsWith('Standards Setting Workspace')){
                
                if(!ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)){
                    continue;
                }

                //system.debug(LoggingLevel.ERROR, 'Email to admin');

                Set<ID> portalAdminUserIDs;
                if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    System.debug(LoggingLevel.ERROR, 'EasyPay');        
                    portalAdminUserIDs = accIdToUserIdMapIep.get(par.Account__c);
                } else {
                    portalAdminUserIDs = accIdToUserIdMap.get(par.Account__c);                   
                }

                //System.debug(LoggingLevel.ERROR, 'accIdToUserIdMapIep->' + portalAdminUserIDs);        

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

                    //system.debug(LoggingLevel.ERROR, 'Email to admin : ' + userId);
                    
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