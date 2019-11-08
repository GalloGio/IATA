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

    public class getUserWrapper{
        @AuraEnabled
        public User user{get;set;}
        @AuraEnabled
        public Boolean isExpired{get;set;}
        @AuraEnabled
        public String password{get;set;}
    }

    @AuraEnabled
    public static getUserWrapper getUser(String urlExtension){
        getUserWrapper result = new getUserWrapper();
        result.isExpired = false;

        PageReference pageRef = new PageReference(urlExtension);
        String parameters     = pageRef.getParameters().get('c');

        parameters             =  Encodingutil.urlDecode(PortalPasswordHandler.DecryptString(parameters),'UTF-8') ;
        List<String> paramList =  parameters.split(PortalPasswordHandler.SEPARATOR,-1);

        STring userName = paramList[0].replace(PortalPasswordHandler.plusReplacer, '+');
        String password = paramList[1];
        string UID      = paramList[2];
        Datetime dt     = datetime.valueOf(paramList[3]);

        if(system.now() > dt.addHours(8)) result.isExpired = true;

        if (!String.isEmpty(userName)) {
            List<User> userList = [Select Id, Username, UID__c, contactId, contact.Preferred_Language__c from user where username = :userName OR email = :userName];
            if (!userList.isEmpty()) {
                if (userList[0].UID__c == UID) {
                    if(result.isExpired != true) userList[0].UID__c = '';
                    result.user     = userList[0];
                    result.password = password;
                }
            }
        }
        return result;
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
        }

        return result;
    }

    @AuraEnabled
    public static boolean resendEmail(String userInfo, String password){
        User user = (User)JSON.deserialize(userInfo, user.class);
        String link                  = PortalPasswordHandler.generateUrl(user, password, 'resetPassword');
        Map<String, String> emailMap = PortalPasswordHandler.forgotPasswordEmailMap(user, link);

        boolean success = PortalPasswordHandler.sendEmail(user.id, 'CSP_Forgot_Password_Email_VF', emailMap);
        return success;
    }
}