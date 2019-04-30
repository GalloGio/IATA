public without sharing class Contact_Roles_Helper {


    public static Contact getContactFromUser(Id userId) {

        List<User> users = [SELECT Id, ContactId, Email FROM User WHERE Id = :userId];
        if(!users.isEmpty()) {
            if(users[0].ContactId != null) {//power user

                List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :users[0].ContactId];
                return contacts[0];

            }else{//standard user
                if(users[0].Email != null) {
                    List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :users[0].Email];
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


    public static Boolean isAccessGranted(String contactRole, String serviceName) {
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

    }

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


    public static List<RecordWrapper> getContactsVisibleToUser(Id userId) {

        Contact con = Contact_Roles_Helper.getContactFromUser(UserId);
        //current user contact role
        List<Account_Contact_Role__c> accountContactRoles  =  [SELECT Id, Account_Role__c FROM Account_Contact_Role__c WHERE Contact__c = :con.Id];

        Set<Id> accountContactIds = new Set<Id>();
        for(Account_Contact_Role__c acr : accountContactRoles) {
            accountContactIds.add(acr.Account_Role__c);
        }
        //users contact roles
        List<Account_Contact_Role__c> allUsersAccountContactRoles = [SELECT Id, Contact__c, Contact_Roles__r.Name, Account_Role__r.Account__r.Name FROM Account_Contact_Role__c WHERE Account_Role__c = :accountContactIds];

        List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Account_Role__r.Account__r.Name FROM Contact_Role_Service_Access__c WHERE Status__c = 'Granted' AND Contact_Role__c IN :allUsersAccountContactRoles];
        Map<Id, Map<String, List<String>>> contactToRolesMap = new Map<Id, Map<String, List<String>>>();
        for(Contact_Role_Service_Access__c access : serviceAccesses) {
            if(contactToRolesMap.get(access.Contact_Role__r.Contact__c) == null) {
                contactToRolesMap.put(access.Contact_Role__r.Contact__c, new Map<String, List<String>>{access.Contact_Role__r.Account_Role__r.Account__r.Name => new List<String>{access.Contact_Role__r.Contact_Roles__r.Name}});
            }else{
                if(contactToRolesMap.get(access.Contact_Role__r.Contact__c).get(access.Contact_Role__r.Account_Role__r.Account__r.Name) == null) {
                    contactToRolesMap.get(access.Contact_Role__r.Contact__c).put(access.Contact_Role__r.Account_Role__r.Account__r.Name, new List<String>{access.Contact_Role__r.Contact_Roles__r.Name});
                }else{
                    contactToRolesMap.get(access.Contact_Role__r.Contact__c).get(access.Contact_Role__r.Account_Role__r.Account__r.Name).add(access.Contact_Role__r.Contact_Roles__r.Name);
                }
            }
        }

        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactToRolesMap.keySet()]);

        List<RecordWrapper> wrappers = new List<RecordWrapper>();

        for(Id contactId : contactToRolesMap.keySet()) {
            Map<String, List<String>> accountToRolesMap = contactToRolesMap.get(contactId);
            for(String accountName : accountToRolesMap.keySet()) {
                RecordWrapper wrapper = new RecordWrapper();
                wrapper.con = contactsMap.get(contactId);
                wrapper.actor = accountName;
                wrapper.roles = accountToRolesMap.get(accountName);
                wrappers.add(wrapper);
            }
        }

        return wrappers;
    }


    public static List<AggregatedRecordWrapper> getAggregatedContactsVisibleToUser(Id userId) {
        List<RecordWrapper> wrappers = getContactsVisibleToUser(userId);

        Map<Contact, AggregatedRecordWrapper> aggregatedWrappersMap = new Map<Contact, AggregatedRecordWrapper>();
        for(RecordWrapper wrapper : wrappers) {
            if(aggregatedWrappersMap.get(wrapper.con) == null) {
                AggregatedRecordWrapper aggregatedWrapper = new AggregatedRecordWrapper();
                aggregatedWrapper.con = wrapper.con;
                aggregatedWrapper.actors = new Set<String>{wrapper.actor};
                aggregatedWrapper.roles = new Set<String>(wrapper.roles);
                aggregatedWrappersMap.put(wrapper.con, aggregatedWrapper);
            }else{
                AggregatedRecordWrapper aggregatedWrapper = aggregatedWrappersMap.get(wrapper.con);
                aggregatedWrapper.actors.add(wrapper.actor);
                aggregatedWrapper.roles.addAll(wrapper.roles);

            }
        }

        return aggregatedWrappersMap.values();

    }


    public class RecordWrapper {

        @AuraEnabled
        public Contact con {get; set;}
        @AuraEnabled
        public String actor {get; set;}
        @AuraEnabled
        public List<String> roles {get; set;}

    }

    public class AggregatedRecordWrapper {
        @AuraEnabled
        public Contact con {get; set;}
        @AuraEnabled
        public Set<String> actors {get; set;}
        @AuraEnabled
        public Set<String> roles {get; set;}

    }


}