public without sharing class OneId_RegistrationHelper_GADM {


    public static Account_Role__c createAccountRole(Account acc) {

        Id defaultRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'Default');

        List<Account_Role__c> accountRoles = [SELECT Id FROM Account_Role__c WHERE Account__c = :acc.Id AND Account_Roles__r.Name = 'GADM Participant'];

        if(accountRoles.isEmpty()) {//GADM Participant account role does not exist for account

            List<Account_Roles__c> gadmParticipants = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant'];

            Account_Role__c role = new Account_Role__c();
            role.RecordTypeId = defaultRecordTypeId;
            role.Account__c = acc.Id;
            role.Account_Roles__c = gadmParticipants[0].Id;
            role.Status__c = 'Inactive';

            database.insert(role);

            List<Account_Role_Services__c> roleServices = [SELECT Id FROM Account_Role_Services__c WHERE Portal_Service__r.Name = 'GADM' AND Account_Roles__r.Name = 'GADM Participant'];
            Account_Role_Service__c roleService = new Account_Role_Service__c();
            roleService.Account_Role_Services__c = roleServices[0].Id;
            roleService.Account_Role__c = role.Id;

            database.insert(roleService);

            GADM_Account_Service_Detail__c serviceDetail = new GADM_Account_Service_Detail__c();
            serviceDetail.Account_Role_Service__c = roleService.Id;

            database.insert(serviceDetail);

            return role;

        }else{//GADM Participant account role for account already exists
            return accountRoles[0];
        }

    }


    public static void createContactRole(Contact con, Account_Role__c accountRole, Boolean isPowerUser) {

        Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');
        List<Contact_Roles__c> contactRoles = [SELECT Id, Name FROM Contact_Roles__c WHERE (Name = 'GADM User' OR Name = 'Service Power User') AND RecordTypeId = :externalRecordTypeId];

        Contact_Roles__c gadmUser = new Contact_Roles__c();
        Contact_Roles__c  powerUser = new Contact_Roles__c();

        for(Contact_Roles__c role : contactRoles) {
            if(role.Name == 'GADM User') {
                gadmUser = role;
            }
            if(role.Name == 'Service Power User') {
                powerUser = role;
            }
        }

        Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');

        List<Account_Contact_Role__c> toInsert = new List<Account_Contact_Role__c>();

        Account_Contact_Role__c accountContactRole2 = new Account_Contact_Role__c();
        accountContactRole2.Contact__c = con.Id;
        accountContactRole2.Contact_Roles__c = gadmUser.Id;
        accountContactRole2.Account_Role__c = accountRole.Id;
        accountContactRole2.Service_Rendered__c = 'GADM';
        accountContactRole2.RecordTypeId = functionalRecordTypeId;

        toInsert.add(accountContactRole2);

        if(isPowerUser) {//Power User and GADM User
            Account_Contact_Role__c accountContactRole3 = new Account_Contact_Role__c();
            accountContactRole3.Contact__c = con.Id;
            accountContactRole3.Contact_Roles__c = powerUser.Id;
            accountContactRole3.Account_Role__c = accountRole.Id;
            accountContactRole3.Service_Rendered__c = 'GADM';
            accountContactRole3.RecordTypeId = functionalRecordTypeId;

            toInsert.add(accountContactRole3);
        }

        if(!toInsert.isEmpty()) {
            database.insert(toInsert);
        }

        List<Contact_Role_Service_Access__c> contactRolesServiceAccessToInsert = new List<Contact_Role_Service_Access__c>();

        List<Portal_Applications__c> services = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM' LIMIT 1];

        for(Account_Contact_Role__c contactRole : toInsert) {
            Contact_Role_Service_Access__c serviceAccess = new Contact_Role_Service_Access__c();
            serviceAccess.Contact_Role__c = contactRole.Id;
            serviceAccess.Status__c = 'Pending';
            serviceAccess.Service__c = services[0].Id;

            contactRolesServiceAccessToInsert.add(serviceAccess);
        }

        if(!contactRolesServiceAccessToInsert.isEmpty()) {
            database.insert(contactRolesServiceAccessToInsert);
        }

    }

}