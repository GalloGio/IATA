public without sharing class Service_Notification_List_CTRL {

    @AuraEnabled
    public static List<Service_Notification__c> getMessages() {

        Contact con = Contact_Roles_Helper.getContactFromUser(UserInfo.getUserId());
        Map<String, String> rolesMap = Contact_Roles_Helper.getAllAvailableRoles(con.Id, 'GADM');

        Set<String> grantedRoles = new Set<String>();
        for(String role : rolesMap.keySet()) {
            if(rolesMap.get(role) == 'Granted'){
                grantedRoles.add(role);
            }
        }

        List<Service_Notification_Role__c> notificationRoles = [SELECT Id, Service_Notification__c FROM Service_Notification_Role__c WHERE Contact_Roles__r.Name = :grantedRoles];

        Set<Id> notificationIds = new Set<Id>();
        for(Service_Notification_Role__c role : notificationRoles) {
            notificationIds.add(role.Service_Notification__c);
        }

        Date today = System.today();
        List<Service_Notification__c> messages = [SELECT Header__c, Body__c FROM Service_Notification__c WHERE (Valid_From__c <= :today AND Valid_To__c >= :today) AND Id =:notificationIds];

        if(messages.isEmpty()) {
            return new List<Service_Notification__c>();
        }

        return messages;

    }

}