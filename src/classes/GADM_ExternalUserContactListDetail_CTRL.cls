public without sharing class GADM_ExternalUserContactListDetail_CTRL {

    @AuraEnabled
    public static List<Contact_Roles__c> getAllRoles() {
        List<Contact_Role_Service__c> roleServices = [SELECT Id, Contact_Role__c FROM Contact_Role_Service__c WHERE Service__r.Name = 'GADM'];

        Set<Id> contactRoleIds = new Set<Id>();
        for(Contact_Role_Service__c roleService : roleServices) {
            contactRoleIds.add(roleService.Contact_Role__c);
        }

        return [SELECT Id, Name FROM Contact_Roles__c WHERE Id = :contactRoleIds];
    }

    @AuraEnabled
    public static List<Contact_Roles__c> getGrantedUserRoles(Id contactId) {
        if(contactId != null) {
            Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
            List<Account_Contact_Role__c> contactRoles = [SELECT Id, Contact_Roles__r.Name FROM Account_Contact_Role__c WHERE Contact__c = :contactId AND RecordTypeId = :recordTypeId];
            if(! contactRoles.isEmpty()) {
                List<Contact_Role_Service_Access__c> accesses = [SELECT Id, Contact_Role__r.Contact_Roles__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__c = :contactRoles AND Status__c = 'Granted'];
                Set<Id> contactRoleIds = new Set<Id>();
                for(Contact_Role_Service_Access__c access : accesses) {
                    contactRoleIds.add(access.Contact_Role__r.Contact_Roles__c);
                }

                return [SELECT Id, Name FROM Contact_Roles__c WHERE Id =:contactRoleIds];
            }
        }

        return new List<Contact_Roles__c>();
    }

    @AuraEnabled
    public static List<Contact_Roles__c> getManagingUserGrantedUserRoles() {
        Contact con = Contact_Roles_Helper.getContactFromUser(UserInfo.getUserId());
        return getGrantedUserRoles(con.Id);
    }


    @AuraEnabled
    public static Contact getContactDetails(Id contactId) {
        if(String.isNotBlank(contactId)) {
            return [SELECT Id, Salutation, FirstName, LastName, Email, Phone, Account.Name, Account.IATACode__c, Account.Region__c FROM Contact WHERE Id = :contactId LIMIT 1];
        }
        return new Contact();
    }


    @AuraEnabled
    public static List<Account> getGrantedAccessAccounts(Id contactId) {

        if(contactId != null) {

            Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
            List<Account_Contact_Role__c> contactRoles = [SELECT Id, Account_Role__r.Account__r.Id FROM Account_Contact_Role__c WHERE Contact__c = :contactId AND Contact_Roles__r.Name = 'GADM User' AND RecordTypeId = :recordTypeId];
            Set<Id> accountId = new Set<Id>();
            for(Account_Contact_Role__c role : contactRoles) {
                accountId.add(role.Account_Role__r.Account__r.Id);
            }

            return [SELECT Id, Name FROM Account WHERE Id = :accountId];
        }

        return new List<Account>();
        /*List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id FROM Contact_Role_Service_Access__c WHERE Contact_Role__c = :contactRoles];

        Set<Id> accountIds = new Set<Id>();
        List<Contact_Role_Service_Access__c> accesses = [SELECT Id, Contact_Role__r.Account_Role__r.Account__r.Name FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = :contactId AND Status__c = 'Granted'];
        if(! accesses.isEmpty()) {
            for(Contact_Role_Service_Access__c access : accesses) {
                if(access.Contact_Role__r.Account_Role__r.Account__c != null) {
                    accountIds.add(access.Contact_Role__r.Account_Role__r.Account__c);
                }
            }
            return [SELECT Id, Name FROM Account WHERE Id = :accountIds];
        }

        return new List<Account>();*/
    }

    @AuraEnabled
    public static List<Account> getGrantedAccessAccountsForManagingUser() {

        Contact con = Contact_Roles_Helper.getContactFromUser(UserInfo.getUserId());
        if(con.Id != null) {
            Id functionalId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
            Id groupId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
            List<Account_Contact_Role__c> contactRoles = [SELECT Id, Account_Role__r.Account__r.Id FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND Contact_Roles__r.Name = 'GADM User' AND (RecordTypeId = :functionalId OR RecordTypeId = :groupId)];
            Set<Id> accountId = new Set<Id>();
            for(Account_Contact_Role__c role : contactRoles) {
                accountId.add(role.Account_Role__r.Account__r.Id);
            }

            return [SELECT Id, Name FROM Account WHERE Id = :accountId];
        }

        return new List<Account>();
        /*Contact con = Contact_Roles_Helper.getContactFromUser(UserInfo.getUserId());
        if(con.Id != null) {
            List<Account_Contact_Role__c> contactRoles = [SELECT Id, Account_Role__r.Account__r.Id FROM Account_Contact_Role__c WHERE Contact__c = :con.Id AND Contact_Roles__r.Name = 'GADM User'];
            Set<Id> accountId = new Set<Id>();
            for(Account_Contact_Role__c role : contactRoles) {
                accountId.add(role.Account_Role__r.Account__r.Id);
            }

            return [SELECT Id, Name FROM Account WHERE Id = :accountId];
        }

        return new List<Account>();*/
    }

}