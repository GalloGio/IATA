/**
 * Created by bkaya01 on 28/08/2019.
 */

public without sharing class PortalResetPasswordController {

    public class resultWrapper{
        @AuraEnabled
        public boolean success{get;set;}
        @AuraEnabled
        public String message{get;set;}
    }

    @AuraEnabled
    public static User getUser(String urlExtension){
        User user;

        PageReference pageRef = new PageReference(urlExtension);
        String parameters     = pageRef.getParameters().get('c');

        parameters             =  Encodingutil.urlDecode(PortalPasswordHandler.DecryptString(parameters),'UTF-8') ;
        List<String> paramList =  parameters.split(PortalPasswordHandler.SEPARATOR,-1);

        STring userName = paramList[0].replace(PortalPasswordHandler.plusReplacer, '+');
        String password = paramList[1];
        string UID      = paramList[2];

        if (!String.isEmpty(userName)) {
            List<User> userList = [Select Id, Username, UID__c from user where username = :userName OR email = :userName];
            if (!userList.isEmpty()) {
                if (userList[0].UID__c == UID) {
                    userList[0].UID__c = '';
                    user = userList[0];
                }
            }
        }
        return user;
    }

    @AuraEnabled
    public static resultWrapper setNewPassword(User user, String password){
        resultWrapper result = new resultWrapper();
        result.success       = true;

        try{
            system.setPassword(user.id, password);
            update user;
        }
        catch(Exception ex){
            result.success = false;
            result.message = ex.getMessage();
        }

        return result;
    }
}