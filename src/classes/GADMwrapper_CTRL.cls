public without sharing class GADMwrapper_CTRL {

    /*@AuraEnabled
    public static boolean isAccessGranted(Id userId) {
        if(String.isNotBlank(userId)) {
            return Contact_Roles_Helper.isAccessGranted('GADM User', 'GADM');
        }
        return false;
    }*/


    @AuraEnabled
    public static Map<String, String> getUserRoles(Id userId) {
        if(String.isNotBlank(userId)) {
            Contact con = Contact_Roles_Helper.getContactFromUser(userId);
            Map<String, String> rolesMap = Contact_Roles_Helper.getAllAvailableRoles(con.Id, 'GADM');
            return rolesMap;
        }else{
            return new Map<String, String>();
        }
    }


    @AuraEnabled
    public static Map<String, String> getAccountDetails(Id userId) {
        if(String.isNotBlank(userId)) {
            Contact con = Contact_Roles_Helper.getContactFromUser(userId);
            if(String.isNotBlank(con.Id)) {
                return Contact_Roles_Helper.getContactAccountDetails(con.Id);
            }else{
                return new Map<String, String>();
            }
        }else{
            return new Map<String, String>();
        }
    }




}