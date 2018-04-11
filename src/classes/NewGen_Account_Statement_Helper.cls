public with sharing class NewGen_Account_Statement_Helper {

    public static final String SERVICE_ICE = 'ICE';
    public static final String SERVICE_RHC = 'RHC';
    public static final String NAVIGATE_TO_HOME = 'NAVIGATE_TO_HOME';
    public static final String NAVIGATE_TO_ICE_HOME = 'NAVIGATE_TO_ICE_HOME';
    public static final String NAVIGATE_TO_RHC_HOME = 'NAVIGATE_TO_RHC_HOME';
    public static final String NAVIGATE_TO_RHC_RISK_PROFILE = 'NAVIGATE_TO_RHC_RISK_PROFILE';
    public static final String NAVIGATE_TO_USER_REQUEST_ADMIN = 'NAVIGATE_TO_USER_REQUEST_ADMIN';
    public static final String NAVIGATE_TO_SERVICE_REQUEST_ADMIN = 'NAVIGATE_TO_SERVICE_REQUEST_ADMIN';

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
        Send a push notification to all usersToGetNotified 

    */
    public static void sendPushNotification(Set <String> usersToGetNotified, String pushNotificationLabel, List <String> pushNotificationLabelValues, String navigateTo){   
        String title = '';
        String message = '';

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

        System.Debug('PUSH Notificaiton');
        System.Debug(androidPayload);
        System.Debug(androidMsg);
        System.Debug(usersToGetNotified);

        iOSMsg.send('NewGen_APP_IOS_2', usersToGetNotified);
        androidMsg.send('NewGen_APP_Android', usersToGetNotified);

    }
}