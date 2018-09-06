/*
    Class that have methods to help NewGen APP (mobile) integration, like Push Notifications.
    Used in ICE service and NewGen APP (mobile)
*/
public with sharing class NewGen_Account_Statement_Helper {

    public static final String SERVICE_ICE = 'ICE';
    public static final String SERVICE_RHC = 'RHC';
    public static final String NAVIGATE_TO_HOME = 'NAVIGATE_TO_HOME';
    public static final String NAVIGATE_TO_ICE_HOME = 'NAVIGATE_TO_ICE_HOME';
    public static final String NAVIGATE_TO_SERVICE_REQUEST = 'NAVIGATE_TO_SERVICE_REQUEST';
    public static final String NAVIGATE_TO_RHC_HOME = 'NAVIGATE_TO_RHC_HOME';
    public static final String NAVIGATE_TO_RHC_RISK_PROFILE = 'NAVIGATE_TO_RHC_RISK_PROFILE';
    public static final String NAVIGATE_TO_USER_REQUEST_ADMIN = 'NAVIGATE_TO_USER_REQUEST_ADMIN';
    public static final String NAVIGATE_TO_SERVICE_REQUEST_ADMIN = 'NAVIGATE_TO_SERVICE_REQUEST_ADMIN';
    public static final String RECTYPE_PUSH_NOTIFICATION_ATTRIBUTE = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Push_Notification');

    /*
        Get a map containing all account in the input account hirarchy
    */
    public static Map <Id, Account> getAllHierarchies(Set <Id> accountSet) {
        Set <Id> maxParentsId = getMaxParentAccounts(accountSet);
        Map <Id, Account> accountHierarchies = new Map <Id, Account>();
        for(Account account : [Select id, Name, ParentId
                                From Account
                                Where Id =:maxParentsId
                                Or ParentId = :maxParentsId
                                or Parent.ParentId = :maxParentsId
                                or Parent.Parent.ParentId = :maxParentsId
                                or Parent.Parent.Parent.ParentId = :maxParentsId
                                or Parent.Parent.Parent.Parent.ParentId = :maxParentsId]){
            accountHierarchies.put(account.Id, account);
        }
        
        return accountHierarchies;
    }

    /*
        Find Headquart account (parent top account in the hierarchy)
    */
    public static Set <Id> getMaxParentAccounts(Set <Id> accountSet){
        Set <Id> parentAccounts = new Set <Id>();

        List <Account> accountList = new List <Account>([Select id, Name,
                                                            ParentId,
                                                            Parent.ParentId,
                                                            Parent.Parent.ParentId,
                                                            Parent.Parent.Parent.ParentId,
                                                            Parent.Parent.Parent.Parent.ParentId
                                                        From Account
                                                        Where id IN :accountSet ]);

        for(Account account : accountList){
            if (account.ParentId == null ) {
                parentAccounts.add(account.Id);
            }
            else if (account.Parent.ParentId == null ) {
                parentAccounts.add(account.ParentId);
            }
            else if (account.Parent.Parent.ParentId == null ) {
                parentAccounts.add(account.Parent.ParentId);
            }
            else if (account.Parent.Parent.Parent.ParentId == null ) {
                parentAccounts.add(account.Parent.Parent.ParentId);
            }
            else if (account.Parent.Parent.Parent.Parent.ParentId == null ) {
                parentAccounts.add(account.Parent.Parent.Parent.ParentId);
            }
            else {
                parentAccounts.add(account.Parent.Parent.Parent.Parent.ParentId);
            }
        }

        return parentAccounts;
    }


    /*
        Get all the Users associated with an account, but exclude the ones that don't have access to a specific service
    */
    public static Map <Id, Set <String>> getUsersPerAccount(Set <Id> accountSet, String serviceInitials){
        List <User> userList = new List <User> ([SELECT    Id, AccountId, ContactId
                                                 FROM      User 
                                                 WHERE     AccountId IN :accountSet 
                                                 AND       IsActive = true 
                                                 ORDER BY  AccountId]);

        Map <Id, Set <String>> usersPerAccount = new Map <Id, Set <String>>();

        if(!userList.isEmpty()){
            Map <Id, Id> contactPerAccount = new Map <Id, Id>();
            Map <Id, Id> userContactMap = new Map <Id, Id>();

            for(User user : userList){
                contactPerAccount.put(user.ContactId, user.AccountId);
                userContactMap.put(user.ContactId, user.Id);
            }

            List <Portal_Application_Right__c> portalApplicationRights = new List <Portal_Application_Right__c> ([SELECT    Contact__c 
                                                                                                                  FROM      Portal_Application_Right__c
                                                                                                                  WHERE     Right__c = 'Access Granted'
                                                                                                                  AND       Contact__c IN :contactPerAccount.keySet()
                                                                                                                  AND       Portal_Application__r.NewGenAPP_ShortName__c = :serviceInitials]);
            for(Portal_Application_Right__c portalAppRight : portalApplicationRights){
                if (usersPerAccount.containsKey(contactPerAccount.get(portalAppRight.Contact__c))){
                    usersPerAccount.get(contactPerAccount.get(portalAppRight.Contact__c)).add(userContactMap.get(portalAppRight.Contact__c));
                }
                else {
                    usersPerAccount.put(contactPerAccount.get(portalAppRight.Contact__c), new Set <String> { userContactMap.get(portalAppRight.Contact__c) });
                }
            }
        }

        return usersPerAccount;
    }

    /*
        Send a push notification to all admins of new portal contacts 
    */
    public static void sendPushNotificationToAdmins(List <Contact> newPortalContactList){
        
        Set<ID> accountIDs = new Set<ID>();
        for(Contact con : newPortalContactList) {
            accountIDs.add(con.AccountId);
        }

        map<ID, Set<ID>> accIdToUserIdMap = new map<ID, Set<ID>>();
        for(AccountTeamMember member : PortalServiceAccessTriggerHandler.getPortalAdmins(accountIDs)) {
            Set<ID> userIDs = accIdToUserIdMap.get(member.AccountId);
            if(null == userIDs)
                userIDs = new Set<ID>();
            
            userIDs.add(member.UserId);
            accIdToUserIdMap.put(member.AccountId, userIDs);
        }

        for(Contact con : newPortalContactList) {
            Set<ID> portalAdminUserIDs = accIdToUserIdMap.get(con.AccountId);
            if(null == portalAdminUserIDs) continue;

            Set <String> portalAdminUserIDsAsString = (Set<String>)JSON.deserialize(JSON.serialize(portalAdminUserIDs), Set<String>.class);
            NewGen_Account_Statement_Helper.sendPushNotification(portalAdminUserIDsAsString, Label.NewGenApp_PortalUserRequested, 
                null, NewGen_Account_Statement_Helper.NAVIGATE_TO_USER_REQUEST_ADMIN);
        }

    }

    /*
        Send a push notification to all usersToGetNotified 

    */
    public static void sendPushNotification(Set <String> usersToGetNotified, String pushNotificationLabel, List <String> pushNotificationLabelValues, String navigateTo){   
        String title = '';
        String message = '';

        if(usersToGetNotified == null)
            return;

        List <String> usersToBeRemoved = new List <String>();
        // to get the final users list, first need to check in Country Specific Attributes if the country has Push Notifications Disabled or not.
        List <User> userList = new List <User>([SELECT  Id, Contact.Account.IATA_ISO_Country__c
                                                FROM    User
                                                WHERE   Id in :usersToGetNotified]);

        Set <Id> isoCountryIds = new Set <Id>();
        for(User userItem : userList){
            isoCountryIds.add(userItem.Contact.Account.IATA_ISO_Country__c);
        }

        for(IATA_ISO_Country__c c : [SELECT Id , (SELECT    Disabled__c
                                                  FROM      AMS_Country_Specific_Attributes__r
                                                  WHERE     RecordTypeId = :NewGen_Account_Statement_Helper.RECTYPE_PUSH_NOTIFICATION_ATTRIBUTE)
                                     FROM   IATA_ISO_Country__c
                                     WHERE  Id IN :isoCountryIds]){

            for (User userItem : userList){
                if(userItem.Contact.Account.IATA_ISO_Country__c == c.Id){
                    if(c.AMS_Country_Specific_Attributes__r != null){
                        // if there's any configuration, check if Push Notifications are enabled or disabled
                        Boolean isDisabled = false;
                        for(AMS_Country_Specific_Attribute__c att : c.AMS_Country_Specific_Attributes__r){
                            isDisabled = isDisabled || att.Disabled__c;
                        }
                        
                        if(isDisabled){
                            usersToBeRemoved.add(userItem.Id);
                        }
                    }
                }
            }
        }

        if(!usersToBeRemoved.isEmpty()){
            usersToGetNotified.removeAll(usersToBeRemoved); 
        }

        if(usersToGetNotified.isEmpty())
            return;

        if(pushNotificationLabelValues != null){
            message = String.format(pushNotificationLabel, pushNotificationLabelValues);
        }
        else {
            message = pushNotificationLabel;
        }
        
        // Instantiating a notification
        Messaging.PushNotification iOSMsg = new Messaging.PushNotification();
        Messaging.PushNotification androidMsg = new Messaging.PushNotification();

        Map<String, Object> iOSPayload = Messaging.PushNotificationPayload.apple(message, '', null, null);
        iOSPayload.put('title', title);
        iOSPayload.put('message', message);
        iOSPayload.put('navigateTo', navigateTo);

        iOSMsg.setPayload(iOSPayload);
    
        Map <String, Object> androidPayload = new Map<String, Object>();
        androidPayload.put('message', message);
        androidPayload.put('navigateTo', navigateTo);
        androidMsg.setPayload(androidPayload);

        System.Debug('PUSH notification');
        System.Debug(androidPayload);
        System.Debug(androidMsg);
        System.Debug(usersToGetNotified);

        iOSMsg.send('NewGen_APP_IOS', usersToGetNotified);
        androidMsg.send('NewGen_APP_Android', usersToGetNotified);

    }
}