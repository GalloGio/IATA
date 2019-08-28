/**
 * Created by bkaya01 on 28/08/2019.
 */

public with sharing class PortalResetPasswordController {

    public class resultWrapper{
        @AuraEnabled
        public boolean success{get;set;}
        @AuraEnabled
        public String message{get;set;}
    }

    @AuraEnabled
    public static string getUserId(String urlExtension){
        string userId = '';
        PageReference pageRef = new PageReference(urlExtension);
        String parameters     = pageRef.getParameters().get('c');

        parameters             =  Encodingutil.urlDecode(PortalPasswordHandler.DecryptString(parameters),'UTF-8') ;
        List<String> paramList =  parameters.split(PortalPasswordHandler.SEPARATOR,-1);

        STring userName = paramList[0].replace(PortalPasswordHandler.plusReplacer, '+');
        String password = paramList[1];
        string UID      = paramList[2];

        string ids = '';
        if (!String.isEmpty(userName)) {
            List<User> user = [Select Id, Username, UID__c from user where username = :userName OR email = :userName];
            if (!user.isEmpty()) {
                if (user[0].UID__c == UID) {
                    userId = user[0].Id;
                }
            }
        }
        return userId;
    }

    @AuraEnabled
    public static resultWrapper setNewPassword(String userId, String password){
        resultWrapper result = new resultWrapper();
        result.success       = true;

        try{
            system.setPassword(userId, password);

            User user = [Select id, uid__c from user where id =: userId limit 1];
            user.uid__c = '';
            update user;
        }
        catch(Exception ex){
            result.success = false;
            result.message = ex.getMessage();
        }

        return result;
    }
}