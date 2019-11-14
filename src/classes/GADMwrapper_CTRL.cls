public without sharing class GADMwrapper_CTRL {


    @AuraEnabled
    public static String getUserRoles(Id userId) {
        String status = '';
        if(String.isNotBlank(userId)) {
            status = Contact_Roles_Helper.getGadmUserRoleStatus(userId);
        }

        return status;
        
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