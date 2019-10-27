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
    public static List<Notification__c> getAllContactNotifications(User loggedUser) {
        String whereClause = '';
        
        whereClause += 'Contact__c = \'' + loggedUser.contactId + '\'';

        whereClause += ' AND Archive__c = false ORDER BY Critical_notification__c DESC, CreatedDate DESC';

        String notificationQuery = String.format('SELECT {0} FROM Notification__c WHERE {1}', 
			new List<String>{String.join(getQueryFields(), ', '), whereClause}
		);

        List<Notification__c> notList = (List<Notification__c>) Database.query(notificationQuery);
        return notList;

    }
    
    /* 
    * @description Return list of portal users to approve. It needs to pass top parent Id to get the respective pending contacts to be approved
    * @params String topParentId
    * @return List<Contact>
    */
    public static List<User> getContactsToApprove(String topParentId) {

        return [SELECT Contactid, Contact.Name, Contact.User_Portal_Status__c, CreatedDate 
                FROM User 
                WHERE (Account.Top_Parent__c =: topParentId OR AccountId =: topParentId) 
                    AND Contact.User_Portal_Status__c = 'Pending Approval'];
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
    * @description Return list of customer invoices.
    * @params String topParentId
    * @return List<Customer_Invoice__c>
    */
    public static List<Customer_Invoice__c> getCustomerInvoices(String topParentId) {
        List<String> statusList = new List<String>();
        for(Customer_Invoices_Visible_Status__mdt visibleStatus : [SELECT MasterLabel FROM Customer_Invoices_Visible_Status__mdt]) {
            statusList.add(visibleStatus.MasterLabel);
        }
        
        return [SELECT Id, Invoice_Number__c, CreatedDate, CreatedById
                FROM Customer_Invoice__c 
                WHERE (AccountId__c =: topParentId OR AccountId__r.Top_Parent__c =: topParentId)
                      AND Invoice_Status__c IN :statusList];
    }

    /* 
    * @description Return list of notifications based on the user.
    * @return List<NotificationItem>
    */
    @AuraEnabled
    public static List<NotificationItem> getNotifications() {

        User loggedUser = CSP_Utils.getLoggedUser();
        Boolean isAdmin = loggedUser.Contact.User_Portal_Status__c == 'Approved Admin';

        // Get Notifications
        List<Notification__c> notificationList = getAllContactNotifications(loggedUser);
        List<NotificationItem> notificationItemList = new List<NotificationItem>();

        List<User> userPortalAccessRequestList = new List<User>();
        List<Portal_Application_Right__c> userPortalServiceAccessRequestList = new List<Portal_Application_Right__c>();
        List<Customer_Invoice__c> customerInvoicesList = new List<Customer_Invoice__c>(); //ACAMBAS - WMO-628

        if ( isAdmin ) {
            String topParentId = loggedUser.Contact.Account.Top_Parent__c == null ? loggedUser.Contact.AccountId : loggedUser.Contact.Account.Top_Parent__c;

            userPortalAccessRequestList = getContactsToApprove(topParentId);
            userPortalServiceAccessRequestList = getPortalAppRightsToApprove(topParentId);
            customerInvoicesList = getCustomerInvoices(topParentId); //ACAMBAS - WMO-628 
            
            for (User contact : userPortalAccessRequestList){
                // USER ACCESS (CONTACT)

                // Contactid, Contact.Name, Contact.User_Portal_Status__c, CreatedDate 
                NotificationItem notif = new NotificationItem(contact.Contactid, String.format(System.Label.UserRequestPortalAccess, new String[]{contact.Contact.Name}), contact.CreatedDate, false, System.label.CSP_Task, String.format(System.Label.UserRequestPortalAccess, new String[]{contact.Contact.Name}), false, 'Portal Access', contact.Contact.Name);
                notificationItemList.add(notif);
            }
            
            for (Portal_Application_Right__c application : userPortalServiceAccessRequestList){
                // PORTAL SERVICE
                NotificationItem notif = new NotificationItem(application.Portal_Application__c, 
                                                                String.format(System.Label.UserRequestServiceAccess, new String[]{application.Contact__r.Name, application.Portal_Application__r.Name}), 
                                                                application.CreatedDate, 
                                                                false, 
                                                                System.label.CSP_Task, 
                                                                String.format(System.Label.UserRequestServiceAccess, new String[]{application.Contact__r.Name, application.Portal_Application__r.Name}), 
                                                                false, 
                                                                'Portal Service', 
                                                                application.Contact__r.Name);
                notificationItemList.add(notif);
            }

            
            if(showIATAInvoices()) {  //ACAMBAS - WMO-696
                //ACAMBAS - WMO-628: Begin
                for (Customer_Invoice__c invoice : customerInvoicesList){
                    // CUSTOMER INVOICES
                    NotificationItem notif = new NotificationItem(invoice.Id, 
                                                                    'You have a new outstanding invoice from IATA: ' + invoice.Invoice_Number__c, 
                                                                    invoice.CreatedDate, 
                                                                    false, 
                                                                    System.label.CSP_Task, 
                                                                    'You have a new outstanding invoice from IATA: ' + invoice.Invoice_Number__c, 
                                                                    false, 
                                                                    'Customer Invoice', 
                                                                    '');
                    notificationItemList.add(notif);
                }
                //ACAMBAS - WMO-628: End
            }
        }

        for(Notification__c notification : notificationList){
            NotificationItem notif = new NotificationItem(notification.Id, notification.Subject__c, notification.CreatedDate, notification.Number_of_views__c > 0, System.label.CSP_Announcement, notification.Message__c, true, 'Notification', '');
            notificationItemList.add(notif);
        }

        return notificationItemList;
    }

    //WMO-696 - ACAMBAS: Begin
     /* 
    * @description If the account is Agency and the ISO country is not defined in the custom metadata XXX the IATA Invoices menu entry should be displayed
    * @return true if the IATA Invoices menu entry is to be displayed.
    */
    @AuraEnabled
    public static Boolean showIATAInvoices() {
        User loggedUser = CSP_Utils.getLoggedUser();
        Boolean isAgency = loggedUser.Contact.Account.RecordType.DeveloperName == 'IATA_Agency';
        String isoCountry = loggedUser.Contact.Account.IATA_ISO_Country__r.ISO_Code__c;

        List<String> hiddenCountryList = new List<String>();
        for(Customer_Invoices_Hidden_Country__mdt hiddenCountry : [SELECT DeveloperName FROM Customer_Invoices_Hidden_Country__mdt]) {
            hiddenCountryList.add(hiddenCountry.DeveloperName);
        }

        if(isAgency && hiddenCountryList.contains(isoCountry)) {
            return false;
        }
        else {
            return true;
        }
    }
    //WMO-696 - ACAMBAS: End

     /* 
    * @description Increase the number of views of 1 notification.
    * @return true to confirm the action.
    */
    @AuraEnabled
    public static void increaseNotificationView(Id id) {
        Notification__c notification = [SELECT id, Number_of_views__c FROM Notification__c WHERE id =:id];
        if ( notification.Number_of_views__c != null ){
            notification.Number_of_views__c++;
        } else {
            notification.Number_of_views__c = 1;
        }

        update notification;
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
        @AuraEnabled
        public String contactName { get; set;}

        public NotificationItem(Id id, String subject, Datetime createdDate, Boolean viewed, String typeNotification, String message, Boolean isNotification, String type, String contactName) {
            this.id = id;
            this.subject = subject;
            this.createdDate = CreatedDate;
            this.viewed = viewed;
            this.typeNotification = typeNotification;
            this.message = message;
            this.isNotification = isNotification;
            this.type = type;
            this.styles = (viewed != true ? 'unreadNotification' : 'readNotification');
            this.contactName = contactName;
        }

    }

    @AuraEnabled
    public static String goToOldChangePassword(){
        return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.ISSP, 'ISSP_ChangePassword');
    }

    @AuraEnabled
    public static String redirectChangePassword(){
        User loggedUser = [SELECT UID__c, LastPasswordChangeDate FROM USER WHERE Id =: UserInfo.getUserId()];

        integer passwordDays = integer.ValueOF(ISSP_CS__c.getValues('PasswordResetPeriod').value__c);

        if (loggedUser.UID__c != '' && loggedUser.UID__c != null){
            String pr = 'ISSP_ChangePassword';
            return pr;
        }
        else if (loggedUser.LastPasswordChangeDate != null){
            if (loggedUser.LastPasswordChangeDate.addDays(passwordDays) < system.now()){
                 String pr = 'ISSP_ChangePassword';
                return pr;
            }
        }            
        return null;
    }

}
