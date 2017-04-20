public class ANG_ISSP_IEPMailRecipientsUtils {

	//
	// NOTE: The set accountIDs needs the 15 digit ids.
	//
    public static Map<ID, Set<Id>> getRecipients(Set<String> accountIDs, Set<String> roles) {

		//
        // Get all the top parents linked to the accounts.
        //
        List<Portal_Application_Right__c> parl = [Select contact__r.account.Top_Parent__c,
                                                         contact__r.accountId,
                                                         contact__r.account.ANG_IEP_Status_FF__c
                                                    From Portal_Application_Right__c
                                                   Where account__c in : accountIDs];

        //
        // Set with all accountIds and top parent ids
        //
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

        List<Portal_Application_Right__c> parList2 = [Select Account__c,
                                                     Contact__c
                                                From Portal_Application_Right__c
                                               Where ANG_Portal_Service_Role__c in : roles
                                                 And contact__r.accountId in : accountsSet];

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
        Map<ID, Set<Id>> accIdToUserIdMapIep = new map<Id, Set<ID>>();

        for(Id key : IEP_accountIDs.keySet()) {
            Set<Id> userIDsAux = new Set<id>();

            userIDsAux.addAll(PortalServiceAccessTriggerHandler.getPortalIepUsers(IEP_accountIDs.get(key)));

            Set<Id> userIDs = accIdToUserIdMapIep.get(topParents.get(key));

            if(null == userIDs)
                userIDs = new Set<ID>();

            userIDs.addAll(userIDsAux);

            accIdToUserIdMapIep.put(topParents.get(key), userIDs);
        }

        return accIdToUserIdMapIep;
    }

	public static Set<String> getIEPDefaultRoles() {
        List<Connected_App_Roles__c> rolesAux = [SELECT Role__c 
                                                   FROM Connected_App_Roles__c 
                                                  WHERE Connected_App_Provisioning_Name__c = 'IATA EasyPay (EDENRED)' 
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
                                                      WHERE Connected_App_Provisioning_Name__c = 'IATA EasyPay (EDENRED)' 
                                                        AND Manage_User_Access__c = true];

        Set<String> roles = new Set<String>();
        for(Connected_App_Roles__c r : rolesAux) {
            roles.add(r.Role__c);
        }
        return roles;        
    }
}