public class Service_Notification_List_CTRL {

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
        Pattern allIds = Pattern.compile('[a-zA-Z0-9]{18}|[a-zA-Z0-9]{15}');
        //get all ids in messages
        Set<Id> docVersionIds = new Set<Id>();
        for(Service_Notification__c message : messages){
            if (message.Body__c != null && message.Body__c != '') {
                Matcher MyMatcher = allIds.matcher(message.Body__c);
                while (MyMatcher.find()) {
                    docVersionIds.add((Id)MyMatcher.group());
                }
            }
        }

        Map<Id, ContentVersion> activeContentVersions = new  Map<Id, ContentVersion> ([SELECT Id FROM ContentVersion WHERE Id IN : docVersionIds AND Valid_From__c <= today AND Valid_To__c >= today]);


        for(Service_Notification__c message : messages){
            if (message.Body__c != null && message.Body__c != '') {
                Matcher MyMatcher = MyPattern.matcher(message.Body__c);
                while (MyMatcher.find()) {
                    string[] spl = MyMatcher.group().split('/');
                    if (spl.size() > 0 && spl[spl.size() - 2].startsWith('068')) {
                        string objId = null;
                        for(string s: spl){
                            if(s.startsWith('068')){
                                objId = s;
                                break;
                            }
                        }
                        if (objId.length() > 15) {
                            objId = objId.substring(0, 15);
                        }

                        if(activeContentVersions.keySet().contains((Id)objId)){
                            message.Body__c = message.Body__c.replace(MyMatcher.group(),
                                    'href="' + Site.getBaseUrl() + '/sfc/servlet.shepherd/version/download/' + objId + '" style="color: #1e32fa !important;"');
                        } else {
                            message.Body__c = message.Body__c.replace(MyMatcher.group(),
                                    'href="/#" style="pointer-events: none;" ');
                        }
                    }
                }
            }
        }
        return messages;
    }

}