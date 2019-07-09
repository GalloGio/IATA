public without sharing class Service_Notification_List_CTRL {

    @AuraEnabled
    public static List<Service_Notification__c> getMessages() {

        Contact con = Contact_Roles_Helper.getContactFromUser(UserInfo.getUserId());
        if(con.Id == null) {
            return new List<Service_Notification__c>();
        }

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

        return convertLinksToExternal(messages);

    }

    private static List<Service_Notification__c> convertLinksToExternal(List<Service_Notification__c> messages){
        Pattern MyPattern = Pattern.compile('href="([^"]*)"');
        for(Service_Notification__c message : messages){
            if (message.Body__c != null && message.Body__c != '') {
                Matcher MyMatcher = MyPattern.matcher(message.Body__c);
                while (MyMatcher.find()) {

                    string[] spl = MyMatcher.group().split('/');
                    if (spl.size() > 0 && spl[spl.size() - 1].startsWith('068')) {
                        string objId = spl[spl.size() - 1];
                        if (objId.length() > 15) {
                            objId = objId.substring(0, 15);
                        }
                        message.Body__c = message.Body__c.replace(MyMatcher.group(),
                                'href="' + Site.getBaseUrl() + '/sfc/servlet.shepherd/version/download/' + objId + '"');
                    }
                }
            }
        }
        return messages;
    }

}