public without sharing class PortalHeaderCtrl {

    public static List<String> getQueryFields() {
		return new List<String>{
			'Id', 
            'Subject__c', 
            'CreatedDate', 
            'Number_of_views__c', 
            'Message__c'
		};
	}

    /* 
    * @description Return list of notifications for a specific contact. It needs to pass contact Id to get the respective notifications
    * @params String contactId
    * @return List<Notification__c>
    */
    public static List<Notification__c> getAllContactNotifications(User loggedUser, Boolean isAdmin) {
        String whereClause = '';
		if (isAdmin){
            String topParentId = loggedUser.Contact.Account.Top_Parent__c == null ? loggedUser.Contact.AccountId : loggedUser.Contact.Account.Top_Parent__c;
			whereClause += '(Contact__r.Account.Top_Parent__c =:topParentId OR Contact__r.AccountId =:topParentId)';
		}
		else {
			whereClause += 'Contact__c =:loggedUser.contactId';
		}
        whereClause += ' AND Archive__c = false ORDER BY Critical_notification__c DESC, CreatedDate DESC';

        String notificationQuery = String.format('SELECT {0} FROM Notification__c WHERE {1}', 
			new List<String>{String.join(getQueryFields(), ', '), whereClause}
		);

        System.debug('QUERY: ' + notificationQuery);

        List<Notification__c> notList = (List<Notification__c>) Database.query(notificationQuery);
        return notList;

    }
    
    /* 
    * @description Return list of portal users to approve. It needs to pass top parent Id to get the respective pending contacts to be approved
    * @params String topParentId
    * @return List<Contact>
    */
    public static List<Contact> getContactsToApprove(String topParentId) {

        return [SELECT Id, Name, User_Portal_Status__c, Owner.CreatedDate 
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

        return [SELECT Id, Portal_Application__c, Portal_Application__r.Name, Contact__r.Name, CreatedDate 
                FROM Portal_Application_Right__c 
                WHERE (Contact__r.AccountId =: topParentId OR Contact__r.Account.Top_Parent__c =: topParentId)
                    AND Right__c = 'Access Requested' 
                    AND Portal_Application__r.Cannot_be_managed_by_portal_admin__c = false];
    }

    /* 
    * @description Return list of notifications based on the user.
    * @return List<NotificationItem>
    */
    @AuraEnabled
    public static List<NotificationItem> getNotifications() {
        
        User loggedUser = [SELECT Id, Contact.AccountId, Contact.Account.Top_Parent__c 
                           FROM User
                           WHERE Id =: UserInfo.getUserId()];

        // Get Notifications
        List<Notification__c> notificationList = getAllContactNotifications(loggedUser, CSP_Utils.isAdmin());
        List<NotificationItem> notificationItemList = new List<NotificationItem>();

        List<Contact> userPortalAccessRequestList = new List<Contact>();
        List<Portal_Application_Right__c> userPortalServiceAccessRequestList = new List<Portal_Application_Right__c>();
        if ( CSP_Utils.isAdmin() ) {
            String topParentId = loggedUser.Contact.Account.Top_Parent__c == null ? loggedUser.Contact.AccountId : loggedUser.Contact.Account.Top_Parent__c;
            userPortalAccessRequestList = getContactsToApprove(topParentId);
            userPortalServiceAccessRequestList = getPortalAppRightsToApprove(topParentId);
            
            for (Contact contact : userPortalAccessRequestList){
                // USER ACCESS (CONTACT)
                NotificationItem notif = new NotificationItem(contact.Id, contact.Name + ' ' + System.Label.UserRequestPortalAccess, contact.Owner.CreatedDate, false, 'Task', contact.Name + ' as requested Access to the Portal.', false, 'Portal Access');
                notificationItemList.add(notif);
            }
            
            for (Portal_Application_Right__c application : userPortalServiceAccessRequestList){
                // PORTAL SERVICE
                NotificationItem notif = new NotificationItem(application.Portal_Application__c, application.Contact__r.Name + ' ' + System.Label.UserRequestServiceAccess + ' ' + application.Portal_Application__r.Name + ' service', application.CreatedDate, false, 'Task', application.Contact__r.Name + ' as request access to ' + application.Portal_Application__r.Name, false, 'Portal Service');
                notificationItemList.add(notif);
                }

        }

        for(Notification__c notification : notificationList){
            NotificationItem notif = new NotificationItem(notification.Id, notification.Subject__c, notification.CreatedDate, notification.Number_of_views__c > 0, 'Announcement', notification.Message__c, true, 'Notification');
            notificationItemList.add(notif);
        }

        return notificationItemList;
    }

     /* 
    * @description Increase the number of views of 1 notification.
    * @return true to confirm the action.
    */
    @AuraEnabled
    public static String increaseNotificationView(Id id) {
        Notification__c notification = [SELECT id, Number_of_views__c FROM Notification__c WHERE id =:id];
        if ( notification.Number_of_views__c != null ){
            notification.Number_of_views__c++;
        } else {
            notification.Number_of_views__c = 1;
        }

        update notification;
        return 'true';
    }


    @AuraEnabled
    public static String goToManageService(){
        return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.CSP, 's/manage-service');
    }

    /* 
    * @description: Inner class to build all the Notification types.
    */
    public class NotificationItem {
        @AuraEnabled
        public Id id { get; set;}
        @AuraEnabled
        public String subject { get; set;}
        @AuraEnabled
        public Datetime createdDate { get; set;}
        @AuraEnabled
        public Boolean viewed { get; set;}
        @AuraEnabled
        public String typeNotification { get; set;} // ANNOUNCEMENT OR TASK
        @AuraEnabled
        public String message { get; set;}
        @AuraEnabled
        public Boolean isNotification { get; set;} // TRUE FALSE
        @AuraEnabled
        public String type { get; set;} // Notification / Access to Portal / Access to Service
        @AuraEnabled
        public String styles { get; set;}

        public NotificationItem(Id id, String subject, Datetime createdDate, Boolean viewed, String typeNotification, String message, Boolean isNotification, String type) {
            this.id = id;
            this.subject = subject;
            this.createdDate = CreatedDate;
            this.viewed = viewed;
            this.typeNotification = typeNotification;
            this.message = message;
            this.isNotification = isNotification;
            this.type = type;
            this.styles = (viewed != true ? 'background-color: #f7f8fa;' : 'background-color: white;');
        }

    }

}