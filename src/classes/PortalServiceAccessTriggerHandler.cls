/**
    Handler class for trigger Portal_Application_Right__c
**/
public without sharing class PortalServiceAccessTriggerHandler {

    public static Boolean privetTrigger = false;
    public static Boolean avoidAppTrigger = false;

    public static final String CURRENCYCENTERAPPURL = '/ISSP_CurrencyCenterHome';

    public static void onAfterInsert(list<Portal_Application_Right__c> newPortalApplicationRightList 
                                   , map<ID, Portal_Application_Right__c> newPortalApplicationRightMap) {
        
        SendEmailToPortalAdminToValidateRequest(newPortalApplicationRightList);
        updateParentContactForInsert(newPortalApplicationRightList);
    }
    
    public static void onAfterUpdate(map<ID, Portal_Application_Right__c> newPortalApplicationRightMap 
                                   , map<ID, Portal_Application_Right__c> oldPortalApplicationRightMap) {
        
        updateParentContactForUpdate(newPortalApplicationRightMap, oldPortalApplicationRightMap);
    }
    
    public static void onAfterDelete(list<Portal_Application_Right__c> newPortalApplicationRightOld) {
        
        updateParentContactForInsert(newPortalApplicationRightOld);
    }
    
    public static void SendEmailToPortalAdminToValidateRequest(list<Portal_Application_Right__c> newPortalApplicationRightList) {

        Set<String> roles = ANG_ISSP_IEPMailRecipientsUtils.getIEPRolesManageUserAccess();
    
        ID templateId = getEmailTemplateIdByName(ENV.EmailTemplateData.NotifyAdminOfAppRequestVF);
    
        ID templateID_CNS = getEmailTemplateIdByName (ENV.EmailTemplateData.NotifyAdminOfAppRequestVF_CNS);

        ID templateIdIEPAprove = getEmailTemplateIdByName(ENV.EmailTemplateData.ISSP_ApprovalOfIATAEasyPayUsers);

        if(String.isBlank(templateId) && String.isBlank(templateID_CNS) && String.isBlank(templateIdIEPAprove)) {
            system.debug(LoggingLevel.ERROR, 'No email template found');   
            return;
        }

        Set<Id> ids = new Set<Id>();
        for(Portal_Application_Right__c par : newPortalApplicationRightList) {
            ids.add(par.id);
        }

        Set<ID> accountIDs = new Set<ID>();
        Map<id, boolean> cannotManagedPortalAdminMap = new Map<id, boolean>();
        Map<id, boolean> requestByUserMap = new Map<id, boolean>();
        Set<Id> accountIDsIepAux = new Set<Id>();

        Map<ID,Portal_Application_Right__c> parMapAux = new Map<ID,Portal_Application_Right__c>([Select id, Right__c, Contact__c, Application_Name__c, Account__c, Portal_Application__r.Cannot_be_managed_by_portal_admin__c, Contact__r.User_Portal_Status__c from Portal_Application_Right__c  where id in :ids]);  

        User currentUser = [Select contactId from User where id =: UserInfo.getUserId() limit 1];

        //for(Portal_Application_Right__c par : newPortalApplicationRightList) {
        for(Portal_Application_Right__c par : parMapAux.values()) {
            if(ENV.AccessStatusPL.AccessRequested.equalsIgnoreCase(par.Right__c)) {
                if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                    if(par.Account__c != null) accountIDsIepAux.add(par.Account__c);
                } else {
                    if(par.Account__c != null) accountIDs.add(par.Account__c);
                }
                requestByUserMap.put(par.Portal_Application__c, par.Contact__c == currentUser.contactId);
                cannotManagedPortalAdminMap.put(par.Portal_Application__c, par.Portal_Application__r.Cannot_be_managed_by_portal_admin__c);
            } 
        }

        Map<String, Set<Id>> accIdToUserIdMapIep = ANG_ISSP_IEPMailRecipientsUtils.getRecipients(accountIDsIepAux, roles);

        System.debug('PortalServiceAccessTriggerHandler__SendEmailToPortalAdminToValidateRequest   accIdToUserIdMapIep-->' + accIdToUserIdMapIep);

        //
        // Get account's IEP Status to supress mails from beeing send.
        //
        Map<Id, String> iepAccountStatusMap = new Map<Id, String>();

        List<Account> accountStatusList = [Select Id, ANG_IEP_Status_FF__c From Account Where Id in : accountIDsIepAux];
        
        for(Account a : accountStatusList) {
            iepAccountStatusMap.put(String.valueOf(a.Id).substring(0, 15), a.ANG_IEP_Status_FF__c);
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

                Boolean cannotManagedPortalAdminFlag = cannotManagedPortalAdminMap.get(par.Portal_Application__c);
                
                // The email to the Portal administrator can only be send when
                // portal_application__c.Cannot_be_managed_by_portal_admin__c = false
                // OR
                // portal_application__c.Cannot_be_managed_by_portal_admin__c = true && portal_application__c = IEP Service && 
                //      IEP Account Status = open && the request was made by the portal user.
                //                
                if(((cannotManagedPortalAdminFlag == false) ||
                    (cannotManagedPortalAdminFlag == true && ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c) &&
                     iepAccountStatusMap.get(par.Account__c) == ANG_ISSP_PortalServiceHelper.STATUS_OPEN)) && ( 
                        (par.Application_Name__c == 'Global Default Insurance (GDI)' && parMapAux.get(par.id).Contact__r.User_Portal_Status__c != 'Approved Admin' ) 
                        || parMapAux.get(par.id).Application_Name__c != 'Global Default Insurance (GDI)' ) ) {

                    Set<ID> portalAdminUserIDs;
                    if (ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {
                        System.debug('--->EasyPay---->' + par.Account__c);
                        portalAdminUserIDs = accIdToUserIdMapIep.get(par.Account__c);
                    } else {
                        portalAdminUserIDs = accIdToUserIdMap.get(par.Account__c);                   
                    }

                    if(null == portalAdminUserIDs) {
                        continue;
                    }

                    for(ID userId : portalAdminUserIDs) {
                        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage(); 
                        if(!requestByUserMap.get(par.Portal_Application__c) && ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c)) {                            
                            emailMsg.setTemplateId(templateIdIEPAprove);
                        } else {
                            if(par.Conctact_is_CNS__c!=null && par.Conctact_is_CNS__c){
                                emailMsg.setTemplateId(templateId_CNS);
                            }else{
                                emailMsg.setTemplateId(templateId);
                            } 
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
                        if(requestByUserMap.get(par.Portal_Application__c)) {
                            emailMsg.setWhatId(par.ID); 
                        }
                        msgList.add(emailMsg);
                    }
                }
            }
        }

        if(!msgList.isEmpty()){
            System.debug('Mails send : ' + msgList.size());
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
    
    /**
        Find related contacts to update fields but only when the access is granted
    **/
    private static void updateParentContactForInsert(list<Portal_Application_Right__c> listRights) {
        // find related contacts
        list<Id> listContactId = new list<Id>();
        for (Portal_Application_Right__c right: listRights) {
            if (right.Right__c=='Access Granted') {
                listContactId.add(right.Contact__c);
            }
        }
        updateParentContactServices(listContactId);
    }
    
    /**
        Find related contacts to update fields but only for changes in Field Right__c
    **/
    private static void updateParentContactForUpdate( map<ID, Portal_Application_Right__c> mapNews, 
                                            map<ID, Portal_Application_Right__c> mapOlds) {
        // find related contacts
        list<Id> listContactId = new list<Id>();
        for (Portal_Application_Right__c rightNew: mapNews.values()) {
            Portal_Application_Right__c rightOld = mapOlds.get(rightNew.Id);
            if (rightNew.Right__c!=rightOld.Right__c) {
                listContactId.add(rightNew.Contact__c);
            }
        }
        updateParentContactServices(listContactId);
    }
    
    /**
        Query input contacts to update the field Available_Services__c
    **/
    public static void updateParentContactServices(list<Id> listContactId) {
        if (listContactId.isEmpty()) return;
        list<Contact> listContact = [
            SELECT Id, ID_Card_Holder__c,
                (SELECT Id, Application_Name__c,  Portal_Application__r.Application_icon_URL__c
                FROM Portal_Application_Rights__r WHERE Right__c = 'Access Granted')
            FROM Contact
            WHERE Id IN :listContactId];
        // assign services to these contacts
        for (Contact contact: listContact) {
            list<String> listServices = new list<String>();
            list<String> listImages = new list<String>();
            for (Portal_Application_Right__c right: contact.Portal_Application_Rights__r) {
                listServices.add(right.Application_Name__c);
                listImages.add('<img src="' + right.Portal_Application__r.Application_icon_URL__c + '" alt="' + right.Application_Name__c + '" title="' + right.Application_Name__c + '" border="0" height="40" width="40"/>');
            }
            //special service for ID Card Holder
            if (contact.ID_Card_Holder__c) {
                listServices.add(IdCardUtil.IDCARD_SERVICE_NAME);
                listImages.add(IdCardUtil.getCardHolderImageHtml());
            }
            contact.Available_Services__c = String.join(listServices,';');
            contact.Available_Services_Images__c = String.join(listImages,' ');
        }
        update listContact;
    }

}