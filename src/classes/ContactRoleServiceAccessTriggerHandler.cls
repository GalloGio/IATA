public without sharing class ContactRoleServiceAccessTriggerHandler {

    public void OnBeforeInsert(List<Contact_Role_Service_Access__c> newObjects) {
        fillUniqueKey(newObjects);
        fillAccountAndContact(newObjects);
    }


    public void OnAfterInsert(List<Contact_Role_Service_Access__c> newObjects) {
        Set<Id> newObjectIds = new Set<Id>();
        for(Contact_Role_Service_Access__c access : newObjects) {
            newObjectIds.add(access.Id);
        }
        grandAccessToGadmCategoryFiles(newObjectIds);
    }

    public void OnBeforeUpdate(List<Contact_Role_Service_Access__c> oldObjects, List<Contact_Role_Service_Access__c> updatedObjects, Map<Id, Contact_Role_Service_Access__c> oldMap) {
        fillUniqueKey(updatedObjects);
        fillAccountAndContact(updatedObjects);
    }


    public void OnAfterUpdate(List<Contact_Role_Service_Access__c> newObjects, Map<Id, Contact_Role_Service_Access__c> oldMap) {
        Set<Id> grantedAdded = new Set<Id>();
        Set<Id> grantedRemoved = new Set<Id>();

        for(Contact_Role_Service_Access__c access : newObjects) {
            Contact_Role_Service_Access__c oldObj = oldMap.get(access.Id);

            if(access.Status__c == 'Granted' && oldObj.Status__c != 'Granted') {
                grantedAdded.add(access.Id);
            }

            if(access.Status__c != 'Granted' && oldObj.Status__c == 'Granted') {
                grantedRemoved.add(access.Id);
            }
        }

        grandAccessToGadmCategoryFiles(grantedAdded);
        removeAccessToGadmCategoryFiles(grantedRemoved, Trigger.isDelete);
    }


    public void OnAfterDelete(List<Contact_Role_Service_Access__c> oldObjects) {
        Set<Id> contactIds = new Set<Id>();
        for(Contact_Role_Service_Access__c access : oldObjects) {
            contactIds.add(access.Contact__c);
        }

        removeAccessToGadmCategoryFiles(contactIds, Trigger.isDelete);
    }

    public static List<NotificationWrapper> notifyUserAboutStatusChange(List<Contact_Role_Service_Access__c> changedAccesses){
        Set<Id> contactIds = new Set<Id>();
        List<NotificationWrapper> statusChangedWithContacts = new List<NotificationWrapper>();
        for (Contact_Role_Service_Access__c crsaNew : changedAccesses) {
            statusChangedWithContacts.add(new NotificationWrapper(crsaNew.Id, crsaNew.Contact__c, crsaNew.Status__c, crsaNew.Contact_Roles_Name__c));
            contactIds.add(crsaNew.Contact__c);
        }

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id =: contactIds]);
        Set<Id> grantedContacts = getGrantedContacts(contactIds);
        for(NotificationWrapper wrapper: statusChangedWithContacts) {
            if(!grantedContacts.contains(wrapper.ContactId) && wrapper.Role != 'GADM User' && wrapper.Role != 'Service Power User') {continue;}
            Contact cnt = contacts.get(wrapper.ContactId);
            if(cnt != null) {
                allmsg.add(createNotification(wrapper.AccessId, cnt, wrapper.Status));
            }
        }

        try {
            Messaging.sendEmail(allmsg, false);
        } catch (Exception e) {
            system.debug(e);
        }

        return statusChangedWithContacts;
    }

    public static void notifyUserAboutStatusChange(Map<Id, Contact_Role_Service_Access__c> oldValues, List<Contact_Role_Service_Access__c> newValues){

        List<Contact_Role_Service_Access__c> changedOrNewAccesses = new List<Contact_Role_Service_Access__c>();
        for (Contact_Role_Service_Access__c crsaNew : newValues) {
            if(crsaNew.Service_Name__c == 'GADM') {
                Contact_Role_Service_Access__c crsaOld = oldValues.get(crsaNew.Id);
                if (crsaOld != null) {
                    if (crsaNew.Status__c != crsaOld.Status__c) {
                        changedOrNewAccesses.add(crsaNew);
                    }
                } else {
                    changedOrNewAccesses.add(crsaNew);
                }
            }
        }
        nofifyInternalGADMUsers(changedOrNewAccesses);
        notifyUserAboutStatusChange(changedOrNewAccesses);
    }

    private static void nofifyInternalGADMUsers(List<Contact_Role_Service_Access__c> changedOrNewAccesses) {
        List<Contact_Role_Service_Access__c> powerUsers = new List<Contact_Role_Service_Access__c>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        for(Contact_Role_Service_Access__c access: changedOrNewAccesses){
             if(access.Contact_Roles_Name__c == 'Service Power User'){
                 powerUsers.add(access);
             }
        }

        List<User> users = GADM_InternalUsersHandler.getUsersFromGroup('GADM Internal Users Notification Group');

        for(Contact_Role_Service_Access__c puAccess: powerUsers) {
            for (User u : users) {
                allmsg.add(createNotification(puAccess.Id, u, puAccess.Status__c));
            }
        }

        try {
            Messaging.sendEmail(allmsg, false);
        } catch (Exception e) {
            system.debug(e);
        }
    }

    private static Set<Id> getGrantedContacts(Set<Id> contactIds){
        List<Contact_Role_Service_Access__c> usersAccess = [
                SELECT Account__c, Contact__c, Email_Address__c, Contact_Roles_Name__c, Status__c
                FROM Contact_Role_Service_Access__c
                WHERE Contact__c = :contactIds AND Status__c = 'Granted' AND Contact_Roles_Name__c = 'GADM User' AND Service__r.Name = 'GADM'
        ];

        Map<Id, Set<Id>> submittersAndSuperUsers = new Map<Id, Set<Id>>();

        Set<Id> grantedContacts = new Set<Id>();
        for(Contact_Role_Service_Access__c access: usersAccess){
            if(access.Contact_Roles_Name__c == 'GADM User' && access.Status__c == 'Granted') {
                grantedContacts.add(access.Contact__c);
            }
        }

        return grantedContacts;
    }
    public class NotificationWrapper{
        public Id AccessId {get;set;}
        public Id ContactId {get;set;}
        public string Status {get;set;}
        public string Role {get;set;}

        public notificationWrapper(Id accessId, Id contactId, string status, string role){
            this.Status = status;
            this.AccessId = accessId;
            this.ContactId = contactId;
            this.Role = role;
        }
    }

    private static Messaging.SingleEmailMessage createNotification(Id access, Contact cnt, string status) {
        return createNotification(access, cnt.Email, cnt.Id, status, 'Contact_Role_Status_Changed');
    }

    private static Messaging.SingleEmailMessage createNotification(Id access, User usr, string status) {
        return createNotification(access, usr.Email, usr.Id, status, 'Contact_Role_Status_Changed');
}

    private static Messaging.SingleEmailMessage createNotification(Id access, string emailAddress, Id person, string status, string emailTemplateName) {
        Id iataNoReplyId = null;
        OrgWideEmailAddress[] iataNoReply = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];
        if(iataNoReply != null && iataNoReply.size() > 0){
            iataNoReplyId = iataNoReply.get(0).Id;
        }

        string tense = status.toUpperCase() == 'PENDING' ? 'is' : 'has been';
        emailTemplateName = 'Contact_Role_Status_Changed';
        EmailTemplate et = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateName];
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, person, access);
        String bodyText = mail.getPlainTextBody();
        String replacedTextbody = bodyText.replace('*tense*', tense);
        mail.setPlainTextBody(replacedTextBody);
        String bodyHtml = mail.getHtmlBody();
        String replacedHtmlBody = bodyHtml.replace('*tense*', tense);
        mail.setHtmlBody(replacedHtmlBody);

        mail.setToAddresses(new List<string>{
                emailAddress
        });
        if(iataNoReplyId != null) {
            mail.setOrgWideEmailAddressId(iataNoReplyId);
        }
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(false);
        return mail;
    }


    private void fillUniqueKey(List<Contact_Role_Service_Access__c> newObjects) {
        for(Contact_Role_Service_Access__c newObject : newObjects) {
            newObject.UniqueKey__c = String.ValueOf(newObject.Service__c).left(15) + '_' + String.valueOf(newObject.Contact_Role__c).left(15);
        }
    }



    private void fillAccountAndContact(List<Contact_Role_Service_Access__c> newObjects) {
        Set<Id> accountContactRoleIds = new Set<Id>();
        for(Contact_Role_Service_Access__c serviceAccess : newObjects) {
            accountContactRoleIds.add(serviceAccess.Contact_Role__c);
        }
        //fill Contact and Account
        Map<Id, Account_Contact_Role__c> contactRoleToContactMap = new Map<Id, Account_Contact_Role__c>([SELECT Id, Contact__c, Account_Role__r.Account__c FROM Account_Contact_Role__c WHERE Id = :accountContactRoleIds]);
        for(Contact_Role_Service_Access__c serviceAccess : newObjects) {
            if(contactRoleToContactMap.get(serviceAccess.Contact_Role__c).Contact__c != null) {
                serviceAccess.Contact__c = contactRoleToContactMap.get(serviceAccess.Contact_Role__c).Contact__c;
            }
            if(contactRoleToContactMap.get(serviceAccess.Contact_Role__c).Account_Role__r.Account__c != null) {
                serviceAccess.Account__c = contactRoleToContactMap.get(serviceAccess.Contact_Role__c).Account_Role__r.Account__c;
            }

        }

    }

    @Future
    private static void grandAccessToGadmCategoryFiles(Set<Id> newObjectsIds) {

        List<Contact_Role_Service_Access__c> enrichObjects = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Service_Rendered__c, Status__c FROM Contact_Role_Service_Access__c WHERE Id = :newObjectsIds];

        Set<Id> contactIds = new Set<Id>();

        for(Contact_Role_Service_Access__c access : enrichObjects) {
            if(access.Contact_Role__r.Service_Rendered__c == 'GADM' && access.Contact_Role__r.Contact_Roles__r.name == 'GADM Data Consumer' && access.Status__c == 'Granted') {
                contactIds.add(access.Contact_Role__r.Contact__c);
            }
        }

        List<User> relatedUsers = [SELECT Id FROM User WHERE ContactId = :contactIds];

        if(! relatedUsers.isEmpty()) {

            List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Files_Folder__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];
            if(gadmSettings.isEmpty()) {
                return;
            }
            if(String.isBlank(gadmSettings[0].Files_Folder__c)) {
                return;
            }

            List<ContentWorkspace> gadmWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c LIMIT 1];
            List<ContentWorkspacePermission> viewer = [SELECT Id FROM ContentWorkspacePermission WHERE Name = 'Viewer'];

            if(! gadmWorkspace.isEmpty() && !viewer.isEmpty()) {

                List<ContentWorkspaceMember> existingMembers = [SELECT Id, MemberId FROM ContentWorkspaceMember WHERE ContentWorkspaceId = :gadmWorkspace[0].Id];

                Set<Id> existingMembersIds = new Set<Id>();
                for(ContentWorkspaceMember member : existingMembers) {
                    existingMembersIds.add(member.MemberId);
                }

                Set<Id> relatedUsersIds = new Set<Id>();
                for(User u : relatedUsers) {
                    relatedUsersIds.add(u.Id);
                }

                Set<Id> usersToAddIds = new Set<Id>();
                for(Id relatedUserId : relatedUsersIds) {
                    if(!existingMembersIds.contains(relatedUserId)) {
                        usersToAddIds.add(relatedUserId);
                    }
                }

                List<ContentWorkspaceMember> membersToAdd = new List<ContentWorkspaceMember>();
                for(Id userToAdd : usersToAddIds) {
                    ContentWorkspaceMember newMember = new ContentWorkspaceMember();
                    newMember.ContentWorkspaceId = gadmWorkspace[0].Id;
                    newMember.ContentWorkspacePermissionId = viewer[0].Id;
                    newMember.MemberId = userToAdd;

                    membersToAdd.add(newMember);
                }

                if(! membersToAdd.isEmpty()) {
                    insert membersToAdd;
                }

            }

        }


    }

    @Future
    private static void removeAccessToGadmCategoryFiles(Set<Id> newObjectsIds, Boolean isDelete) {

        Set<Id> contactIds = new Set<Id>();

        if(isDelete) {
            contactIds = newObjectsIds;
        }else {
            List<Contact_Role_Service_Access__c> enrichObjects = [SELECT Id, Contact_Role__r.Contact__c, Contact_Role__r.Contact_Roles__r.Name, Contact_Role__r.Service_Rendered__c FROM Contact_Role_Service_Access__c WHERE Id = :newObjectsIds];

            for(Contact_Role_Service_Access__c access : enrichObjects) {
                if(access.Contact_Role__r.Service_Rendered__c == 'GADM' && access.Contact_Role__r.Contact_Roles__r.Name == 'GADM Data Consumer') {
                    contactIds.add(access.Contact_Role__r.Contact__c);
                }
            }

        }

        List<User> relatedUsers = [SELECT Id FROM User WHERE ContactId = :contactIds];

        if(! relatedUsers.isEmpty()) {

            List<GADM_Settings__mdt> gadmSettings = [SELECT Id, Files_Folder__c FROM GADM_Settings__mdt WHERE DeveloperName = 'GADM' LIMIT 1];
            if(gadmSettings.isEmpty()) {
                return;
            }
            if(String.isBlank(gadmSettings[0].Files_Folder__c)) {
                return;
            }

            List<ContentWorkspace> gadmWorkspace = [SELECT Id FROM ContentWorkspace WHERE Name = :gadmSettings[0].Files_Folder__c LIMIT 1];
            List<ContentWorkspacePermission> viewer = [SELECT Id FROM ContentWorkspacePermission WHERE Name = 'Viewer'];

            if(! gadmWorkspace.isEmpty() && !viewer.isEmpty()) {

                List<ContentWorkspaceMember> existingMembers = [SELECT Id, MemberId FROM ContentWorkspaceMember WHERE ContentWorkspaceId = :gadmWorkspace[0].Id];

                Set<Id> existingMembersIds = new Set<Id>();
                for(ContentWorkspaceMember member : existingMembers) {
                    existingMembersIds.add(member.MemberId);
                }

                Set<Id> relatedUsersIds = new Set<Id>();
                for(User u : relatedUsers) {
                    relatedUsersIds.add(u.Id);
                }

                Set<Id> usersToRemoveIds = new Set<Id>();
                for(Id relatedUserId : relatedUsersIds) {
                    if(existingMembersIds.contains(relatedUserId)) {
                        usersToRemoveIds.add(relatedUserId);
                    }
                }

                List<ContentWorkspaceMember> membersToRemove = [SELECT Id FROM ContentWorkspaceMember WHERE ContentWorkspaceId = :gadmWorkspace[0].Id AND ContentWorkspacePermissionId = :viewer[0].Id AND MemberId = :usersToRemoveIds];

                if(! membersToRemove.isEmpty()) {
                    delete membersToRemove;
                }

            }

        }


    }

}