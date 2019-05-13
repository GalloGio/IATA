public without sharing class Contact_Roles_Helper {


    public static Contact getContactFromUser(Id userId) {

        List<User> users = [SELECT Id, ContactId, Email FROM User WHERE Id = :userId];
        if(!users.isEmpty()) {
            if(users[0].ContactId != null) {//power user

                List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id = :users[0].ContactId];
                return contacts[0];

            }else{//standard user
                if(users[0].Email != null) {
                    List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Email = :users[0].Email];
                    if(!contacts.isEmpty()) {//standard user has contact
                        return contacts[0];
                    }else{//standard user does not have contact
                        return new Contact();
                    }

                }
            }
        }

        return new Contact();

    }


    /*public static Boolean isAccessGranted(String contactRole, String serviceName) {
        Contact con = getContactFromUser(UserInfo.getUserId());
        //Contact con = [SELECT Id FROM Contact WHERE Id = '0031x000009eJsuAAE'];

        if(con.Id != null) {
            List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id
                                                                    FROM Contact_Role_Service_Access__c
                                                                    WHERE Contact_Role__r.Contact__c = :con.Id AND
                                                                    Status__c = 'Granted' AND
                                                                    Service__r.Name = :serviceName AND
                                                                    Contact_Role__r.Contact_Roles__r.Name = :contactRole];

            return serviceAccesses.size() > 0;

        }else{
            return false;
        }

    }*/

    public static Map<String, String> getContactAccountDetails(Id contactId) {

        Map<String, String> accountDetails = new Map<String, String>();

        if(String.isNotBlank(contactId)) {
            List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Id = :contactId];
            if(! contacts.isEmpty()) {

                List<Account_Role__c> accountRoles = [SELECT Id, Status__c, Effective_From_Date__c, Effective_To_Date__c FROM Account_Role__c WHERE Account__c = :contacts[0].AccountId AND Account_Roles__r.Name = 'GADM Participant'];
                if(! accountRoles.isEmpty()) {

                    String status = accountRoles[0].Status__c;
                    accountDetails.put('status', status);

                    Date today = Date.today();
                    Boolean effective = (accountRoles[0].Effective_From_Date__c <= today && today<= accountRoles[0].Effective_To_Date__c);
                    accountDetails.put('effective', String.valueOf(effective));

                }
            }
        }

        return accountDetails;
    }


    public static Map<String, String> getAllAvailableRoles(Id contactId, String serviceName) {
        List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Status__c, Contact_Role__r.Contact_Roles__r.Name FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = :contactId AND Service__r.Name = :serviceName];

        Map<String, String> rolesMap = new Map<String, String>();
        for(Contact_Role_Service_Access__c c: serviceAccesses) {
            rolesMap.put(c.Contact_Role__r.Contact_Roles__r.Name, c.Status__c);
        }

        return rolesMap;
    }


    /*public static List<String> getStandardRoles() {
        return new List<String>{'Power User', 'Super User', 'GADM User', 'Data Submitter', 'Data Consumer'};
    }


    public static Set<String> getStandardRolesGrantedToUser(Id userId) {

        List<String> allRoles = getStandardRoles();
        List<Contact_Role_Service__c> roleServices = [SELECT Id, Contact_Role__c FROM Contact_Role_Service__c WHERE Contact_Role__r.Name = :allRoles AND Service__r.Name = 'GADM'];

        Set<Id> existingStandardRoles = new Set<Id>();
        for(Contact_Role_Service__c roleService : roleServices) {
            existingStandardRoles.add(roleService.Contact_Role__c);
        }

        Contact con = getContactFromUser(userId);
        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');

        List<Contact_Role_Service_Access__c> contactRoleServiceAccesses = [SELECT Id, Contact_Role__r.Contact_Roles__r.Name FROM Contact_Role_Service_Access__c WHERE Status__c = 'Granted' AND Contact_Role__r.Contact_Roles__c =:existingStandardRoles AND Contact_Role__r.Contact__c = :con.Id AND Contact_Role__r.RecordTypeId = :functionalRecordTypeId];
        Set<String> grantedRoles = new Set<String>();
        for(Contact_Role_Service_Access__c serviceAccess : contactRoleServiceAccesses) {
            grantedRoles.add(serviceAccess.Contact_Role__r.Contact_Roles__r.Name);
        }
        return grantedRoles;
    }*/

    public static List<Account> getUserAccounts(Id userId) {
        List<Account> accountsToReturn = new List<Account>();

        Contact con = getContactFromUser(userId);

        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
        List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Account_Role__r.Account__c FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND Contact_Roles__r.Name = 'GADM User' AND RecordTypeId = :groupRecordTypeId AND Service_Rendered__c = 'GADM'];

        Set<Id> accountIds = new Set<Id>();
        for(Account_Contact_Role__c accountContactRole : accountContactRoles) {
            accountIds.add(accountContactRole.Account_Role__r.Account__c);
        }

        if(! accountIds.isEmpty()) {
            accountsToReturn = [SELECT Id, Name FROM Account WHERE Id = :accountIds];
        }

        return accountsToReturn;
    }

    public static List<Contact_Roles__c> getAllUserRoles(Id userId, String serviceName) {
        List<Contact_Roles__c> contactRolesToReturn = new List<Contact_Roles__c>();

        Contact con = getContactFromUser(userId);

        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
        List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Contact_Roles__c FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND RecordTypeId = :groupRecordTypeId AND Service_Rendered__c = :serviceName];

        Set<Id> rolesId = new Set<Id>();
        for(Account_Contact_Role__c accountContactRole : accountContactRoles) {
            rolesId.add(accountContactRole.Contact_Roles__c);
        }

        if(! rolesId.isEmpty()) {
            contactRolesToReturn = [SELECT Id, Name, Category__c FROM Contact_Roles__c WHERE Id = :rolesId];
        }

        return contactRolesToReturn;

    }


    public static List<Contact_Roles__c> getGrantedUserRoles(Id userId, String serviceName) {
        List<Contact_Roles__c> contactRolesToReturn = new List<Contact_Roles__c>();

        Contact con = getContactFromUser(userId);

        if(String.isNotBlank(con.AccountId)) {
            Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
            List<Account_Contact_Role__c> accountContactRoles = [SELECT Id FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND Account_Role__r.Account__c = :con.AccountId AND RecordTypeId = :functionalRecordTypeId AND Service_Rendered__c = :serviceName];

            if(! accountContactRoles.isEmpty()) {
                List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Contact_Role__r.Contact_Roles__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__c = :accountContactRoles AND Status__c = 'Granted'];

                Set<Id> roleIds = new Set<Id>();
                for(Contact_Role_Service_Access__c access : serviceAccesses) {
                    roleIds.add(access.Contact_Role__r.Contact_Roles__c);
                }

                contactRolesToReturn = [SELECT Id, Name FROM Contact_Roles__c WHERE Id = :roleIds];
            }

        }

        return contactRolesToReturn;
    }

    public static List<Contact_Roles__c> getGrantedBusinessUnits(Id userId) {

        List<Contact_Roles__c> contactRolesToReturn = new List<Contact_Roles__c>();

        Contact con = getContactFromUser(userId);
        if(con.Id != null) {
            Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
            List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Contact_Role__r.Contact_Roles__c, Contact_Role__r.Contact_Roles__r.Name FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = : con.Id AND Contact_Role__r.RecordTypeId = :groupRecordTypeId AND Contact_Role__r.Contact_Roles__r.Category__c = 'Business Unit' AND Status__c = 'Granted'];
            if(! serviceAccesses.isEmpty()) {
                for(Contact_Role_Service_Access__c crsa : serviceAccesses) {
                    contactRolesToReturn.add(new Contact_Roles__c(Id = crsa.Contact_Role__r.Contact_Roles__c, Name = crsa.Contact_Role__r.Contact_Roles__r.Name));
                }
            }
        }

        return contactRolesToReturn;
    }


    //TODO: generic approach!
    public static List<Contact_Roles__c> getUserRoles(Id userId, Id roleRecordTypeId, String category, String accessStatus) {
        List<Contact_Roles__c> contactRolesToReturn = new List<Contact_Roles__c>();


        return contactRolesToReturn;
    }


    public static List<AggregatedRecordWrapper> getContactsVisibleToUser(Id userId, Boolean isSuperUser, Boolean isGadmUser, List<Id> businessUnits) {

        Contact con = Contact_Roles_Helper.getContactFromUser(UserId);

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');

        //current running user contact role
        List<Account_Contact_Role__c> accountContactRoles  =  [SELECT Id, Account_Role__c FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND RecordTypeId = :groupRecordTypeId AND Service_Rendered__c = 'GADM'];
        System.debug('accountContactRoles:: ' +accountContactRoles);

        Set<Id> accountContactIds = new Set<Id>();
        for(Account_Contact_Role__c acr : accountContactRoles) {
            accountContactIds.add(acr.Account_Role__c);
        }
        //all users contact roles
        List<Account_Contact_Role__c> allUsersAccountContactRoles = [SELECT Id, Contact__c, Contact_Roles__r.Name, Contact_Roles__r.Category__c, Account_Role__r.Account__r.Name FROM Account_Contact_Role__c WHERE Account_Role__c = :accountContactIds AND RecordTypeId = :groupRecordTypeId AND Service_Rendered__c = 'GADM'];
        System.debug('allUsersAccountContactRoles:: ' +allUsersAccountContactRoles);

        Set<Id> contactIds = new Set<Id>();//all users
        //Map<Id, Set<String>> accountsMap = new Map<Id, Set<String>>();//all accounts
        Map<Id, Map<Id, Account_Contact_Role__c>> accountsMap = new Map<Id, Map<Id, Account_Contact_Role__c>>();
        Map<Id, Map<Id, Contact_Role_Service_Access__c>> rolesMap = new Map<Id, Map<Id, Contact_Role_Service_Access__c>>();//all roles
        Map<Id, Map<Id, Contact_Role_Service_Access__c>> businessUnitsMap = new Map<Id, Map<Id, Contact_Role_Service_Access__c>>();//all business units

        //fill users
        for(Account_Contact_Role__c acr : allUsersAccountContactRoles) {
            contactIds.add(acr.Contact__c);
        }

        //fill roles
        List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Contact_Roles__r.Category__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = : contactIds AND Contact_Role__r.RecordTypeId = :functionalRecordTypeId  AND (Contact_Role__r.Contact_Roles__r.Category__c = null OR Contact_Role__r.Contact_Roles__r.Category__c = '') AND Service__r.Name = 'GADM' AND Status__c = 'Granted'];
        System.debug('functionalServiceAccesses:: ' +serviceAccesses);

        for(Contact_Role_Service_Access__c crsa : serviceAccesses) {
            if(rolesMap.get(crsa.Contact_Role__r.Contact__c) == null) {
                rolesMap.put(crsa.Contact_Role__r.Contact__c, new Map<Id, Contact_Role_Service_Access__c>{crsa.Contact_Role__r.Contact_Roles__c => crsa});
            }else{
                rolesMap.get(crsa.Contact_Role__r.Contact__c).put(crsa.Contact_Role__r.Contact_Roles__c, crsa);
            }
        }

        //fill business units
        List<Contact_Role_Service_Access__c> serviceAccesses2 = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Contact_Roles__r.Category__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = : contactIds AND Contact_Role__r.RecordTypeId = :groupRecordTypeId AND Contact_Role__r.Contact_Roles__r.Category__c = 'Business Unit' AND Service__r.Name = 'GADM' AND Status__c = 'Granted'];
        System.debug('functionalServiceAccesses2:: ' +serviceAccesses2);

        for(Contact_Role_Service_Access__c crsa : serviceAccesses2) {
            if(businessUnitsMap.get(crsa.Contact_Role__r.Contact__c) == null) {
                businessUnitsMap.put(crsa.Contact_Role__r.Contact__c, new Map<Id, Contact_Role_Service_Access__c>{crsa.Contact_Role__r.Contact_Roles__c => crsa});
            }else{
                businessUnitsMap.get(crsa.Contact_Role__r.Contact__c).put(crsa.Contact_Role__r.Contact_Roles__c, crsa);
            }

        }

        //fill accounts
        List<Account_Contact_Role__c> accountRoles =  [SELECT Id, Contact__c, Account_Role__r.Account__r.Name, Contact_Roles__r.Category__c FROM Account_Contact_Role__c WHERE Contact__c = :contactIds AND RecordTypeId = :groupRecordTypeId  AND (Contact_Roles__r.Category__c = null OR Contact_Roles__r.Category__c = '') AND Service_Rendered__c = 'GADM'];
        System.debug('accountRoles:: ' +accountRoles);
        for(Account_Contact_Role__c acr : accountRoles) {
            if(accountsMap.get(acr.Contact__c) == null) {
                //accountsMap.put(acr.Contact__c, new Set<String>{acr.Account_Role__r.Account__r.Name});
                accountsMap.put(acr.Contact__c, new Map<Id, Account_Contact_Role__c>{acr.Account_Role__r.Account__c => acr});
            }else{
                accountsMap.get(acr.Contact__c).put(acr.Account_Role__r.Account__c, acr);
            }
        }


        System.debug('contactIds:: ' +contactIds);
        System.debug('accountsMap:: ' +accountsMap);
        System.debug('rolesMap:: ' +rolesMap);
        System.debug('businessUnitsMap:: ' +businessUnitsMap);
        System.debug('isSuperUser:: ' + isSuperUser);

        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Salutation, Email, Phone, Account.Name, Account.IATACode__c, Account.Region__c FROM Contact WHERE Id = :contactIds ORDER BY LastName ASC]);
        System.debug('contactsMap:: ' + contactsMap);

        List<AggregatedRecordWrapper> aggregatedRecordWrappers = new List<Contact_Roles_Helper.AggregatedRecordWrapper>();
        for(Id contactId : contactsMap.keySet()) {//for Power User

            AggregatedRecordWrapper arw = new AggregatedRecordWrapper();
            arw.con = contactsMap.get(contactId);
            //arw.actors = accountsMap.get(contactId);
            arw.actorsData = accountsMap.get(contactId);
            arw.rolesData = rolesMap.get(contactId);
            arw.buData = businessUnitsMap.get(contactId);

            aggregatedRecordWrappers.add(arw);

        }

        if(isSuperUser) {//for Super User
            List<AggregatedRecordWrapper> SuAggregatedRecordWrappers = new List<AggregatedRecordWrapper>();
            for (AggregatedRecordWrapper wr: aggregatedRecordWrappers){
                if (wr.buData == null || wr.buData.isEmpty()){
                    SuAggregatedRecordWrappers.add(wr);
                }
                else {
                    for (Id buid : businessUnits) {
                        if (wr.buData.get(buid) != null) {
                            SuAggregatedRecordWrappers.add(wr);
                        }
                    }
                }


            }
            return SuAggregatedRecordWrappers;

        }

        if(isGadmUser) {//for GADM User

            List<AggregatedRecordWrapper> gadmUserAggregatedRecordWrappers =  new List<AggregatedRecordWrapper>();
            for(AggregatedRecordWrapper wr: aggregatedRecordWrappers) {
                if(wr.con.Id == con.Id) {
                    gadmUserAggregatedRecordWrappers.add(wr);
                }
            }

            return gadmUserAggregatedRecordWrappers;
        }


        System.debug('aggregatedRecordWrappers:: ' +aggregatedRecordWrappers);
        return aggregatedRecordWrappers;

    }


    public class AggregatedRecordWrapper {
        @AuraEnabled
        public Contact con {get; set;}
        //@AuraEnabled
        //public Set<String> actors {get; set;}

        @AuraEnabled
        public Map<Id,Account_Contact_Role__c> actorsData {get; set;}
        @AuraEnabled
        public Set<String> actors {get{
            Set<String> names = new Set<String>();
            if(actorsData != null) {
                for(Account_Contact_Role__c acr : actorsData.values()) {
                    names.add(acr.Account_Role__r.Account__r.Name);
                }
            }
            return names;

        }}

        @AuraEnabled
        public Map<Id, Contact_Role_Service_Access__c> rolesData {get; set;}
        @AuraEnabled
        public Set<String> roles {get{
            Set<String> names = new Set<String>();
            if(rolesData != null) {
                for(Contact_Role_Service_Access__c crsa : rolesData.values()) {
                    names.add(crsa.Contact_Role__r.Contact_Roles__r.Name);
                }
            }
            return names;
        }}


        @AuraEnabled
        public Map<Id,Contact_Role_Service_Access__c> buData {get;set;}
        @AuraEnabled
        public Set<String> businessUnits {get {
            Set<String> names = new Set<String>();
            if (buData != null) {
                for (Contact_Role_Service_Access__c crsa : buData.values()) {
                    names.add(crsa.Contact_Role__r.Contact_Roles__r.Name);
                }
            }
            return names;
        }}

    }


}