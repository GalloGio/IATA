public class ANG_ISSP_IEPMailRecipientsUtils {

    //
    // NOTE: The set accountIDs needs the 15 digit ids.
    //
    public static Map<String, Set<Id>> getRecipients(Set<Id> accountIDs, Set<String> roles) {

        Map<Id, String> topParents = new Map<Id, String>();

        Map<Id, List<AMS_Agencies_relationhip__c>> hier = AMS_HierarchyHelper.getAccountsHierarchies(accountIDs);

        Set<id> accountIDsSet = new Set<id>();

        for(String accountId : accountIDs) {
            List<AMS_Agencies_relationhip__c> amsl = hier.get(accountId);
            accountIDsSet.add(accountId);
            topParents.put(accountId, String.valueOf(accountId).substring(0, 15));

            for (AMS_Agencies_relationhip__c ams : amsl) {
                if(ams.Child_Account__c != null) {
                    accountIDsSet.add(ams.Child_Account__c);
                    topParents.put(ams.Child_Account__c, String.valueOf(accountId).substring(0, 15));
                }
                if(ams.Parent_Account__c != null) {
                    accountIDsSet.add(ams.Parent_Account__c);
                    topParents.put(ams.Parent_Account__c, String.valueOf(accountId).substring(0, 15));
                }
            }
        }

        //System.debug('topParents--->' + topParents);
        //System.debug('roles--->' + roles);
        //System.debug('accountIDs--->' + accountIDs);

        List<Portal_Application_Right__c> parList2 = [Select Account__c,
                                                     Contact__c
                                                From Portal_Application_Right__c
                                               Where ANG_Portal_Service_Role__c in : roles
                                                 And right__c = 'Access Granted'
                                                 And contact__r.accountId in : accountIDsSet];

        //System.debug('parList2-->' + parList2);

        //
        // Set with all contacts per account
        //                                                         
        Map<Id, Set<Id>> IEP_accountIDs = new Map<Id, Set<Id>>();

        for(Portal_Application_Right__c p : parList2) {
            Set<ID> contactIDs = IEP_accountIDs.get(p.Account__c);
            if(null == contactIDs)
                contactIDs = new Set<ID>();
            contactIDs.add(p.Contact__c);
            IEP_accountIDs.put(p.Account__c, contactIDs);
        }                                                                

        //
        // Get the users by account
        //
        Map<String, Set<Id>> accIdToUserIdMapIep = new map<String, Set<ID>>();

        for(Id key : IEP_accountIDs.keySet()) {
            Set<Id> userIDsAux = new Set<id>();

            userIDsAux.addAll(PortalServiceAccessTriggerHandler.getPortalIepUsers(IEP_accountIDs.get(key)));

            Set<Id> userIDs = accIdToUserIdMapIep.get(topParents.get(key));

            if(null == userIDs)
                userIDs = new Set<ID>();

            userIDs.addAll(userIDsAux);

            accIdToUserIdMapIep.put(topParents.get(key), userIDs);
        }

        System.debug('accIdToUserIdMapIep-->' + accIdToUserIdMapIep); 

        return accIdToUserIdMapIep;
    }

    public static Set<String> getIEPDefaultRoles() {
        List<Connected_App_Roles__c> rolesAux = [SELECT Role__c 
                                                   FROM Connected_App_Roles__c 
                                                  WHERE Connected_App__c = 'IATA EasyPay (EDENRED)' 
                                                    AND Default_User_Role__c = true];
        
        Set<String> roles = new Set<String>();
        for(Connected_App_Roles__c r : rolesAux) {
            roles.add(r.Role__c);
        }
        return roles;
    }

    public static Set<String> getIEPRolesManageUserAccess() {
        List<Connected_App_Roles__c> rolesAux = [SELECT Role__c 
                                                   FROM Connected_App_Roles__c 
                                                  WHERE Connected_App__c = 'IATA EasyPay (EDENRED)' 
                                                    AND Manage_User_Access__c = true];

        Set<String> roles = new Set<String>();
        for(Connected_App_Roles__c r : rolesAux) {
            roles.add(r.Role__c);
        }
        return roles;        
    }
}