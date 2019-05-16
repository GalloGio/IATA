public without sharing class CSP_Utils {

    /* 
    * @description Return field labels. It needs to pass the sObject and the necessary fields to retrieve
    * @params String sObjectType, List<String> sObjectFields
    * @return Map<String,String>
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSelectedColumns(String sObjectType, List<String> sObjectFields) {
        Map<String, String> allFieldsLabel = new Map<String, String>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectType).getDescribe().fields.getMap();

        for(String fields : sObjectFields) {
            String fieldName = fieldMap.get(fields).getDescribe().getName();
            String fieldLabel = fieldMap.get(fields).getDescribe().getLabel();

            if(sObjectFields.contains(fieldName)) {
                allFieldsLabel.put(fieldName, fieldLabel);
            }
        }

        return allFieldsLabel;
    }

    /* 
    * @description Return list of notifications for a specific contact. It needs to pass contact Id to get the respective notifications
    * @params String contactId
    * @return List<Notification__c>
    */
    public static List<Notification__c> getContactNotifications(String contactId) {

        return [SELECT Id, Subject__c, CreatedDate, Number_of_views__c 
                FROM Notification__c 
                WHERE Contact__c =: contactId 
                    AND (Number_of_views__c = 0 OR Number_of_views__c = null) 
                    AND Archive__c = false 
                ORDER BY Critical_notification__c DESC, CreatedDate DESC];
    }
    
    /* 
    * @description Return list of portal users to approve. It needs to pass top parent Id to get the respective pending contacts to be approved
    * @params String topParentId
    * @return List<Contact>
    */
    public static List<Contact> getContactsToApprove(String topParentId) {

        return [SELECT Id 
                FROM Contact 
                WHERE (Account.Top_Parent__c =: topParentId OR AccountId =: topParentId) 
                    AND User_Portal_Status__c = 'Pending Approval'];
    }

    /* 
    * @description Return list of portal users to approve. It needs to pass top parent Id to get the respective pending contacts
    * @params String topParentId
    * @return List<Notification__c>
    */
    public static List<Portal_Application_Right__c> getPortalAppRightsToApprove(String topParentId) {

        return [SELECT Id 
                FROM Portal_Application_Right__c 
                WHERE Contact__r.AccountId =: topParentId 
                    AND Right__c = 'Access Requested' 
                    AND Portal_Application__r.Cannot_be_managed_by_portal_admin__c = false];
    }

    /* 
    * @description Return number of notifications for the respective user. It needs to be a string to let the result be 99+ for more than 99
    * @return String
    */
    @AuraEnabled
    public static String getNotificationsCount() {
    
        User loggedUser = [SELECT Id, ContactId , Contact.AccountId, Contact.Account.Top_Parent__c, Contact.User_Portal_Status__c
                           FROM User
                           WHERE Id =: UserInfo.getUserId()];

        //check if the user is a portal user
        if(loggedUser == null || loggedUser.ContactId == null) return null;

        Integer numNotifications = 0;        
        List<Notification__c> notifications = getContactNotifications(loggedUser.ContactId);

        if(!notifications.isEmpty())
            numNotifications += notifications.size();

        //Count also Users and Portal Service Requests to Approve for Admin Users
        if(loggedUser.Contact.User_Portal_Status__c == 'Approved Admin') {

            String topParentId = loggedUser.Contact.Account.Top_Parent__c == null ? loggedUser.Contact.AccountId : loggedUser.Contact.Account.Top_Parent__c;
            
            numNotifications += getContactsToApprove(topParentId).size() + getPortalAppRightsToApprove(topParentId).size();
        }
        
        return numNotifications > 99 ? '99+' : String.valueOf(numNotifications);
    }


    @AuraEnabled
    public static List<NotificationCenter> getNotifications() {
        
        User loggedUser = [SELECT Id, ContactId , Contact.AccountId, Contact.Account.Top_Parent__c, Contact.User_Portal_Status__c
                           FROM User
                           WHERE Id =: UserInfo.getUserId()];

        List<Notification__c> notificationList = getContactNotifications(loggedUser.ContactId);
        List<NotificationCenter> notificationCenterList = new List<NotificationCenter>();

        System.debug('NOT LIST: ' + notificationList);

        for(Notification__c notification : notificationList){            
            NotificationCenter notif = new NotificationCenter(notification.Id, notification.Subject__c, notification.CreatedDate, notification.Number_of_views__c);
            notificationCenterList.add(notif);
        }

        return notificationCenterList;
    }


    public class NotificationCenter {
        public Id id { get; set;}
        public String subject { get; set;}
        public Datetime createdDate { get; set;}
        public Decimal numberOfViews { get; set;}

        public NotificationCenter() {}

        public NotificationCenter(Id id, String subject, Datetime createdDate, Decimal numberOfViews) {
            this.id = id;
            this.subject = subject;
            this.createdDate = CreatedDate;
            this.numberOfViews = numberOfViews;
        }

    }

}