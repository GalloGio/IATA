public class ContactRoleServiceAccessTriggerHandler {

    public void OnBeforeInsert(List<Contact_Role_Service_Access__c> newObjects) {
        fillUniqueKey(newObjects);
        fillAccountAndContact(newObjects);
    }

    public void OnBeforeUpdate(List<Contact_Role_Service_Access__c> oldObjects, List<Contact_Role_Service_Access__c> updatedObjects, Map<Id, Contact_Role_Service_Access__c> oldMap) {
        fillUniqueKey(updatedObjects);
        fillAccountAndContact(updatedObjects);
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
            system.debug(crsaNew.Service_Name__c);
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

        notifyUserAboutStatusChange(changedOrNewAccesses);
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
        string emailTemplateName = 'Contact_Role_Status_Changed';
        EmailTemplate et = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateName];
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, cnt.Id, access);
        mail.setToAddresses(new List<string>{
                cnt.Email
        });
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(false);
        string body = mail.getHtmlBody();
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

}