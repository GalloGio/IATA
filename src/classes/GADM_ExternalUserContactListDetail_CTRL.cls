public without sharing class GADM_ExternalUserContactListDetail_CTRL {

    /*@AuraEnabled
    public static List<Contact_Roles__c> getAllRoles() {
        List<Contact_Role_Service__c> roleServices = [SELECT Id, Contact_Role__c FROM Contact_Role_Service__c WHERE Service__r.Name = 'GADM'];

        Set<Id> contactRoleIds = new Set<Id>();
        for(Contact_Role_Service__c roleService : roleServices) {
            contactRoleIds.add(roleService.Contact_Role__c);
        }

        return [SELECT Id, Name FROM Contact_Roles__c WHERE Id = :contactRoleIds];
    }*/

    /*@AuraEnabled
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
    }*/

    /*@AuraEnabled
    public static List<Contact_Roles__c> getManagingUserGrantedUserRoles() {
        Contact con = Contact_Roles_Helper.getContactFromUser(UserInfo.getUserId());
        return getGrantedUserRoles(con.Id);
    }*/


    /*@AuraEnabled
    public static Contact getContactDetails(Id contactId) {
        if(String.isNotBlank(contactId)) {
            return [SELECT Id, Salutation, FirstName, LastName, Email, Phone, Account.Name, Account.IATACode__c, Account.Region__c FROM Contact WHERE Id = :contactId LIMIT 1];
        }
        return new Contact();
    }*/


    /*@AuraEnabled
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

    }*/

    /*@AuraEnabled
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

    }*/

    @AuraEnabled
    public static UserManagementData prepareManagementData(String currentUserData, String selectedUserData, Boolean isSuperUser, boolean isPowerUser) {
        GADM_ExternalUserContactList_CTRL.UserInformation currentUserInfo = (GADM_ExternalUserContactList_CTRL.UserInformation)JSON.deserialize(currentUserData, GADM_ExternalUserContactList_CTRL.UserInformation.class);
        Contact_Roles_Helper.AggregatedRecordWrapper selectedUserInfo = (Contact_Roles_Helper.AggregatedRecordWrapper)JSON.deserialize(selectedUserData, Contact_Roles_Helper.AggregatedRecordWrapper.class);
        System.debug('currentUserInfo:: ' + currentUserInfo);
        System.debug('selectedUserInfo:: ' + selectedUserInfo);

        //current user
        List<Contact_Roles__c> currentUserRoles = currentUserInfo.grantedRoles;
        List<Contact_Roles__c> currentUserBusinessUnits = currentUserInfo.grantedBusinessUnits;
        List<Account> currentUserActors = currentUserInfo.visibleAccounts;

        //selected user
        Map<Id, Contact_Role_Service_Access__c> roles = selectedUserInfo.rolesData;
        Map<Id,Contact_Role_Service_Access__c> businessUnits = selectedUserInfo.buData;
        Map<Id,Account_Contact_Role__c> actors = selectedUserInfo.actorsData;

        List<Contact_Roles__c> selectedUserRoles = new List<Contact_Roles__c>();
        List<Contact_Roles__c> selectedUserBusinessUnits = new List<Contact_Roles__c>();
        List<Account> selectedUserActors = new List<Account>();


        if(! roles.isEmpty()) {
            for(Id roleId : roles.keySet()) {
                Contact_Roles__c role = new Contact_Roles__c();
                role.Id = roleId;
                role.Name = roles.get(roleId).Contact_Role__r.Contact_Roles__r.Name;
                selectedUserRoles.add(role);
            }
        }

        if(! businessUnits.isEmpty()) {
            for(Id buId : businessUnits.keySet()) {
                Contact_Roles__c businessUnit = new Contact_Roles__c();
                businessUnit.Id = buId;
                businessUnit.Name = businessUnits.get(buId).Contact_Role__r.Contact_Roles__r.Name;
                selectedUserBusinessUnits.add(businessUnit);
            }
        }

        if(! actors.isEmpty()) {
            for(Id actorId : actors.keySet()) {
                Account actor = new Account();
                actor.Id = actorId;
                actor.Name = actors.get(actorId).Account_Role__r.Account__r.Name;
                selectedUserActors.add(actor);
            }
        }

        UserManagementData managementData = new UserManagementData();

        managementData.roles = new Map<Id, GADM_ExternalUserContactListDetail_CTRL.Role>();
        managementData.businessUnits = new Map<Id, GADM_ExternalUserContactListDetail_CTRL.BusinessUnit>();
        managementData.actors = new Map<Id, GADM_ExternalUserContactListDetail_CTRL.Actor>();

        Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');
        List<Contact_Role_Service__c> contactRoleServices = [SELECT Id, Contact_Role__c FROM Contact_Role_Service__c WHERE Service__r.Name = 'GADM' AND Contact_Role__r.RecordTypeId = :externalRecordTypeId AND (Contact_Role__r.Category__c = '' OR Contact_Role__r.Category__c = null)];

        Set<Id> contactRolesIds = new Set<Id>();
        for(Contact_Role_Service__c service : contactRoleServices) {
            contactRolesIds.add(service.Contact_Role__c);
        }

        List<Contact_Roles__c> standardGadmRoles = [SELECT Id, Name FROM Contact_Roles__c WHERE Id = :contactRolesIds];
        System.debug('standardGadmRoles:: ' + standardGadmRoles);
		
        for(Contact_Roles__c role : standardGadmRoles) {
            //power user role cannot be taken
            if(role.Name == 'Service Power User') {
                if(isPowerUser){
                    Role dataRole = new Role();
                    dataRole.role = role;
                    dataRole.isChecked = selectedUserRoles.contains(role);
                    dataRole.isEditable = false;
                    managementData.roles.put(role.Id, dataRole);
                } else{
                    continue;
                }                
            }
            else if(role.Name == 'Service Super User') {
                if(isPowerUser){
                    Role dataRole = new Role();
                    dataRole.role = role;
                    dataRole.isChecked = selectedUserRoles.contains(role);
                    dataRole.isEditable = true;
                    managementData.roles.put(role.Id, dataRole);
                } else if(isSuperUser) {
                    Role dataRole = new Role();
                    dataRole.role = role;
                    dataRole.isChecked = selectedUserRoles.contains(role);
                    dataRole.isEditable = false;
                    managementData.roles.put(role.Id, dataRole);
                } else{
                    continue;
                }
            } else {
                Role dataRole = new Role();
                dataRole.role = role;
                dataRole.isChecked = selectedUserRoles.contains(role);
                dataRole.isEditable = true;
                managementData.roles.put(role.Id, dataRole);
            }
           

            //managementData.roles.put(role.Id, dataRole);
        }

        /*for(Contact_Roles__c seRole : selectedUserRoles) {
            if(managementData.roles.get(seRole.Id) == null) {
                Role dataRole = new Role();
                dataRole.role = seRole;
                dataRole.isChecked = true;
                dataRole.isEditable = currentUserRoles.contains(seRole);

                managementData.roles.put(seRole.Id, dataRole);
            }

        }*/

        for(Contact_Roles__c cuBusinessUnit : currentUserBusinessUnits) {
            BusinessUnit businessUnit = new BusinessUnit();
            businessUnit.businessUnit = cuBusinessUnit;
            businessUnit.isChecked = selectedUserBusinessUnits.contains(cuBusinessUnit);
            businessUnit.isEditable = true;

            managementData.businessUnits.put(cuBusinessUnit.Id, businessUnit);
        }

        for(Contact_Roles__c seBusinessUnit : selectedUserBusinessUnits) {
            if(managementData.businessUnits.get(seBusinessUnit.Id) == null) {
                BusinessUnit businessUnit = new BusinessUnit();
                businessUnit.businessUnit = seBusinessUnit;
                businessUnit.isChecked = true;
                businessUnit.isEditable = currentUserBusinessUnits.contains(seBusinessUnit);

                managementData.businessUnits.put(seBusinessUnit.Id, businessUnit);
            }
        }


        for(Account cuActor : currentUserActors) {
            Actor actor = new Actor();
            actor.actor = cuActor;
            actor.isChecked = selectedUserActors.contains(cuActor);
            actor.isEditable = true;

            managementData.actors .put(cuActor.Id, actor);
        }

        for(Account seActor : selectedUserActors) {
            if(managementData.actors.get(seActor.Id) == null) {
                Actor actor = new Actor();
                actor.actor =seActor;
                actor.isChecked = true;
                actor.isEditable = currentUserActors.contains(seActor);

                managementData.actors.put(seActor.Id, actor);
            }
        }



        return managementData;

    }


    @AuraEnabled
    public static boolean saveManagementData(String originalData, String modifiedData, String selectedUserInfo) {

        UserManagementData original = (UserManagementData)JSON.deserialize(originalData, UserManagementData.class);
        UserManagementData modified = (UserManagementData)JSON.deserialize(modifiedData, UserManagementData.class);
        Contact_Roles_Helper.AggregatedRecordWrapper userInfo = (Contact_Roles_Helper.AggregatedRecordWrapper)JSON.deserialize(selectedUserInfo, Contact_Roles_Helper.AggregatedRecordWrapper.class);

        System.debug('original:: ' + original);
        System.debug('modified:: ' + modified);
        System.debug('userInfo:: ' + userInfo);


        //roles:
        Map<Id, Role> originalRoles = original.roles;
        Map<Id, Role> modifiedRoles = modified.roles;
        Map<Id, Contact_Role_Service_Access__c> userRoles = userInfo.rolesData;

        //business units
        Map<Id, BusinessUnit> originalBusinessUnits = original.businessUnits;
        Map<Id, BusinessUnit> modifiedBusinessUnits = modified.businessUnits;
        Map<Id, Contact_Role_Service_Access__c> userBusinessUnits = userInfo.buData;


        //actors
        Map<Id, Actor> originalActors = original.actors;
        Map<Id, Actor> modifiedActors = modified.actors;
        Map<Id, Account_Contact_Role__c> userActors = userInfo.actorsData;

        Contact con  = userInfo.con;


        System.debug('contact::' + con);

        System.debug('originalRoles:: ' + originalRoles);
        System.debug('modifiedRoles:: ' + modifiedRoles);
        System.debug('userRoles:: ' + userRoles);


        Savepoint sp = Database.setSavepoint();

        try{

            handleRoles(originalRoles, modifiedRoles, userRoles, con);
            handleBusinessUnits(originalBusinessUnits, modifiedBusinessUnits, userBusinessUnits, con);
            handleActors(originalActors, modifiedActors, userActors, con);

            return true;

        }catch(Exception e) {

            Database.rollback(sp);

            return false;

        }

    }


    private static void handleRoles(Map<Id, Role> originalRoles, Map<Id, Role> modifiedRoles, Map<Id, Contact_Role_Service_Access__c> userRoles, Contact con) {
        List<Contact_Role_Service_Access__c> accessDeniedToUpdate = new List<Contact_Role_Service_Access__c>();
        List<Id> rolesForAccessGrantedIds = new List<Id>();


        for(Id origRoleId : originalRoles.keySet()) {

            //was checked and now is not - we have crsa
            if(originalRoles.get(origRoleID).isChecked) {
                if(! modifiedRoles.get(origRoleID).isChecked) {
                    //role was de-selected
                    Contact_Role_Service_Access__c access = userRoles.get(origRoleID);
                    access.Status__c = 'Denied';
                    accessDeniedToUpdate.add(access);
                }
            }
            //was not checked and now is - find out i crsa exist (and change to granted) or create new crsa
            if(! originalRoles.get(origRoleId).isChecked) {
                if(modifiedRoles.get(origRoleId).isChecked) {
                    System.debug('here! - origId::' + origRoleId);
                    Contact_Roles__c role = originalRoles.get(origRoleId).Role;
                    System.debug('role::' + role);
                    rolesForAccessGrantedIds.add(role.Id);
                }
            }
        }

        System.debug('rolesForAccessGrantedIds::' + rolesForAccessGrantedIds);
        if(! rolesForAccessGrantedIds.isEmpty()) {


            Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
            List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Contact_Roles__r.Category__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = : con.Id AND Contact_Role__r.Contact_Roles__c = :rolesForAccessGrantedIds AND Contact_Role__r.RecordTypeId = :functionalRecordTypeId  AND (Contact_Role__r.Contact_Roles__r.Category__c = null OR Contact_Role__r.Contact_Roles__r.Category__c = '') AND Service__r.Name = 'GADM' AND Status__c != 'Granted'];

            List<Contact_Role_Service_Access__c> accessGrantedToUpdate = new List<Contact_Role_Service_Access__c>();
            List<Id> rolesToGranted = new List<Id>();


            if(! serviceAccesses.isEmpty()) {
                for(Contact_Role_Service_Access__c access : serviceAccesses) {
                    if(rolesForAccessGrantedIds.contains(access.Contact_Role__r.Contact_Roles__c)) {
                        accessGrantedToUpdate.add(access);
                        rolesToGranted.add(access.Contact_Role__r.Contact_Roles__c);
                    }/*else{
                        createNewRolesIds.add(access.Contact_Role__r.Contact_Roles__c);
                    }*/
                }
            }

            //change access to granted
            for(Contact_Role_Service_Access__c access : accessGrantedToUpdate) {
                access.Status__c = 'Granted';
            }

            List<Id> createNewRolesIds = new List<Id>();
            for(Id newRoleToGrand : rolesForAccessGrantedIds) {
                if(! rolesToGranted.contains(newRoleToGrand)){
                    createNewRolesIds.add(newRoleToGrand);
                }
            }
            System.debug('createNewRolesIds:: ' + createNewRolesIds);
            //create new granted access
            if(! createNewRolesIds.isEmpty()) {

                List<Portal_Applications__c> gadm = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM'];
                List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Account_Role__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact__c = :con.Id AND Contact_Roles__r.Name = 'GADM User'];

                Map<Id, Account_Contact_Role__c> accountContactRolesToCreate = new Map<Id, Account_Contact_Role__c>();
                Map<id, Contact_Role_Service_Access__c> accessToCreate = new Map<Id, Contact_Role_Service_Access__c>();

                for(Id roleId : createNewRolesIds) {

                    Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
                    accountContactRole.Contact__c = con.Id;
                    accountContactRole.Contact_Roles__c = roleId;
                    accountContactRole.Service_Rendered__c = 'GADM';
                    accountContactRole.RecordTypeId = functionalRecordTypeId;
                    accountContactRole.Account_Role__c = accountContactRoles[0].Account_Role__c;
                    accountContactRolesToCreate.put(roleId, accountContactRole);

                    Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
                    access.Service__c = gadm[0].Id;
                    access.Status__c = 'Granted';
                    accessToCreate.put(roleId, access);
                }

                System.debug('accountContactRolesToCreate::' + accountContactRolesToCreate);
                System.debug('accessToCreate::' + accessToCreate);

                insert accountContactRolesToCreate.values();

                for(Id roleId : accountContactRolesToCreate.keySet()) {
                    Account_Contact_Role__c acr = accountContactRolesToCreate.get(roleId);
                    Contact_Role_Service_Access__c crsa = accessToCreate.get(roleId);
                    crsa.Contact_Role__c = acr.Id;
                }


                insert accessToCreate.values();
            }

            update accessGrantedToUpdate;

        }

        System.debug('accessDeniedToUpdate::' + accessDeniedToUpdate);
        update accessDeniedToUpdate;

    }


    private static boolean handleBusinessUnits(Map<Id, BusinessUnit> originalBusinessUnits, Map<Id, BusinessUnit> modifiedBusinessUnits, Map<Id, Contact_Role_Service_Access__c> userBusinessUnits, Contact con) {

        boolean result = true;

        List<Contact_Role_Service_Access__c> accessDeniedToUpdate = new List<Contact_Role_Service_Access__c>();
        List<Id> businessUnitsForAccessGrantedIds = new List<Id>();

        for(Id origBuId : originalBusinessUnits.keySet()) {

            //was checked and now is not - we have crsa
            if(originalBusinessUnits.get(origBuId).isChecked) {
                if(! modifiedBusinessUnits.get(origBuId).isChecked) {
                    //role was de-selected
                    Contact_Role_Service_Access__c access = userBusinessUnits.get(origBuId);
                    access.Status__c = 'Denied';
                    accessDeniedToUpdate.add(access);
                }
            }
            //was not checked and now is - find out i crsa exist (and change to granted) or create new crsa
            if(! originalBusinessUnits.get(origBuId).isChecked) {
                if(modifiedBusinessUnits.get(origBuId).isChecked) {
                    System.debug('here! - origId::' + origBuId);
                    Contact_Roles__c businessUnit = originalBusinessUnits.get(origBuId).BusinessUnit;
                    System.debug('bu::' + businessUnit);
                    businessUnitsForAccessGrantedIds.add(businessUnit.Id);
                }
            }
        }

        System.debug('businessUnitsForAccessGrantedIds::' + businessUnitsForAccessGrantedIds);
        if(! businessUnitsForAccessGrantedIds.isEmpty()) {

            Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
            List<Contact_Role_Service_Access__c> serviceAccesses = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Contact_Roles__r.Category__c FROM Contact_Role_Service_Access__c WHERE Contact_Role__r.Contact__c = : con.Id AND Contact_Role__r.Contact_Roles__c = :businessUnitsForAccessGrantedIds AND Contact_Role__r.RecordTypeId = :groupRecordTypeId AND Contact_Role__r.Contact_Roles__r.Category__c = 'Business Unit' AND Service__r.Name = 'GADM' AND Status__c != 'Granted'];

            List<Contact_Role_Service_Access__c> accessGrantedToUpdate = new List<Contact_Role_Service_Access__c>();
            List<Id> businessUnitsToGranted = new List<Id>();


            if(! serviceAccesses.isEmpty()) {
                for(Contact_Role_Service_Access__c access : serviceAccesses) {
                    if(businessUnitsForAccessGrantedIds.contains(access.Contact_Role__r.Contact_Roles__c)) {
                        accessGrantedToUpdate.add(access);
                        businessUnitsToGranted.add(access.Contact_Role__r.Contact_Roles__c);
                    }
                }
            }

            //change access to granted
            for(Contact_Role_Service_Access__c access : accessGrantedToUpdate) {
                access.Status__c = 'Granted';
            }

            List<Id> createNewBusinessUnitIds = new List<Id>();
            for(Id newRoleToGrand : businessUnitsForAccessGrantedIds) {
                if(! businessUnitsToGranted.contains(newRoleToGrand)){
                    createNewBusinessUnitIds.add(newRoleToGrand);
                }
            }
            System.debug('createNewBusinessUnitIds:: ' + createNewBusinessUnitIds);
            //create new granted access
            if(! createNewBusinessUnitIds.isEmpty()) {

                List<Portal_Applications__c> gadm = [SELECT Id FROM Portal_Applications__c WHERE Name = 'GADM'];
                Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
                List<Account_Contact_Role__c> accountContactRoles = [SELECT Id, Account_Role__c FROM Account_Contact_Role__c WHERE RecordTypeId = :functionalRecordTypeId AND Contact__c = :con.Id AND Contact_Roles__r.Name = 'GADM User'];
                System.debug('accountContactRoles:: ' + accountContactRoles);

                Map<Id, Account_Contact_Role__c> accountContactRolesToCreate = new Map<Id, Account_Contact_Role__c>();
                Map<id, Contact_Role_Service_Access__c> accessToCreate = new Map<Id, Contact_Role_Service_Access__c>();

                for(Id roleId : createNewBusinessUnitIds) {

                    Account_Contact_Role__c accountContactRole = new Account_Contact_Role__c();
                    accountContactRole.Contact__c = con.Id;
                    accountContactRole.Contact_Roles__c = roleId;
                    accountContactRole.Service_Rendered__c = 'GADM';
                    accountContactRole.RecordTypeId = groupRecordTypeId;
                    accountContactRole.Account_Role__c = accountContactRoles[0].Account_Role__c;
                    accountContactRolesToCreate.put(roleId, accountContactRole);

                    Contact_Role_Service_Access__c access = new Contact_Role_Service_Access__c();
                    access.Service__c = gadm[0].Id;
                    access.Status__c = 'Granted';
                    accessToCreate.put(roleId, access);
                }

                System.debug('accountContactRolesToCreate::' + accountContactRolesToCreate);
                System.debug('accessToCreate::' + accessToCreate);

                insert accountContactRolesToCreate.values();

                for(Id roleId : accountContactRolesToCreate.keySet()) {
                    Account_Contact_Role__c acr = accountContactRolesToCreate.get(roleId);
                    Contact_Role_Service_Access__c crsa = accessToCreate.get(roleId);
                    crsa.Contact_Role__c = acr.Id;
                }


                insert accessToCreate.values();
            }

            update accessGrantedToUpdate;

        }

        System.debug('accessDeniedToUpdate::' + accessDeniedToUpdate);
        update accessDeniedToUpdate;


        return result;

    }



    private static boolean handleActors(Map<Id, Actor> originalActors, Map<Id, Actor> modifiedActors, Map<Id, Account_Contact_Role__c> userActors, Contact con) {

        Id groupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Group');
        List<Account_Contact_Role__c> toDelete = new List<Account_Contact_Role__c>();
        List<Id> accIdtoCreate = new List<Id>();

        for(Id origActorId : originalActors.keySet()) {
            //was checked and now is not - we have crsa
            if(originalActors.get(origActorId).isChecked) {
                if(! modifiedActors.get(origActorId).isChecked) {
                    //role was de-selected
                    Account_Contact_Role__c accountContactRole = userActors.get(origActorId);
                    toDelete.add(accountContactRole);
                }
            }
            //was not checked and now is - find out i crsa exist (and change to granted) or create new crsa
            if(! originalActors.get(origActorId).isChecked) {
                if(modifiedActors.get(origActorId).isChecked) {
                    System.debug('here! - origId::' + origActorId);
                    Account acc = originalActors.get(origActorId).actor;
                    System.debug('acc::' + acc);
                    accIdtoCreate.add(acc.Id);
                }
            }
        }

        if(! toDelete.isEmpty()) {
            delete toDelete;
        }


        if(! accIdtoCreate.isEmpty()) {

            List<Account_Contact_Role__c> accountContactRolesToCreate = new List<Account_Contact_Role__c>();

            List<Account_Role__c> accountRoles = [SELECT Id, Account__c FROM Account_Role__c WHERE Account__c = :accIdtoCreate AND Account_Roles__r.Name = 'GADM Participant'];
            List<Contact_Roles__c> roles = [SELECT Id FROM Contact_Roles__c WHERE Name = 'GADM User'];

            Map<Id, Account_Role__c> accIdToAccountRoleMap = new Map<Id, Account_Role__c>();
            for(Account_Role__c accountRole : accountRoles) {
                accIdToAccountRoleMap.put(accountRole.Account__c, accountRole);
            }

            for(Id accId : accIdtoCreate) {
                Account_Contact_Role__c acr = new Account_Contact_Role__c();
                acr.Service_Rendered__c = 'GADM';
                acr.Contact__c = con.Id;
                acr.Account_Role__c = accIdToAccountRoleMap.get(accId).Id;
                acr.RecordTypeId = groupRecordTypeId;
                acr.Contact_Roles__c = roles[0].Id;

                accountContactRolesToCreate.add(acr);
            }

            if(! accountContactRolesToCreate.isEmpty()) {
                insert accountContactRolesToCreate;
            }


        }


        boolean result = true;
        return  result;
    }


    public class UserManagementData {
        @AuraEnabled
        public Map<Id, Role> roles {get; set;}
        @AuraEnabled
        public Map<Id, BusinessUnit> businessUnits {get; set;}
        @AuraEnabled
        public Map<Id, Actor> actors {get; set;}

    }

    public class Role {
        @AuraEnabled
        public Contact_Roles__c role {get; set;}
        @AuraEnabled
        public Boolean isChecked {get; set;}
        @AuraEnabled
        public Boolean isEditable {get; set;}
    }

    public class BusinessUnit {
        @AuraEnabled
        public Contact_Roles__c businessUnit {get; set;}
        @AuraEnabled
        public Boolean isChecked {get; set;}
        @AuraEnabled
        public Boolean isEditable {get; set;}
    }

    public Class Actor {
        @AuraEnabled
        public Account actor {get; set;}
        @AuraEnabled
        public Boolean isChecked {get; set;}
        @AuraEnabled
        public Boolean isEditable {get; set;}
    }

}