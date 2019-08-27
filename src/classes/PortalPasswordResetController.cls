/**
 * Created by bkaya01 on 22/08/2019.
 */

public without sharing class PortalPasswordResetController {

    public class LoginResult{
        @AuraEnabled
        public boolean isSuccess{get;set;}
        @AuraEnabled
        public string errorMessage{get;set;}
    }

    @AuraEnabled
    public static LoginResult redirectToResetPasswordPage(String urlExtension){
        LoginResult result    = new LoginResult();
        PageReference pageRef = new PageReference(urlExtension);
        String parameters     = pageRef.getParameters().get('c');

        parameters =  Encodingutil.urlDecode(PortalPasswordHandler.DecryptString(parameters),'UTF-8') ;

        List<String> paramList =  parameters.split(PortalPasswordHandler.SEPARATOR,-1);

        String userName = paramList[0].replace(PortalPasswordHandler.plusReplacer, '+');
        String password = paramList[1];
        string UID      = paramList[2];

        string ids = '';
        string startUrl = Label.CSP_PortalPath;
        if (!String.isEmpty(userName)) {
            List<User> user = [Select Id, Username, UID__c from user where username = :userName OR email = :userName];

            if (user <> null && user.size() > 0) {
                if (user[0].UID__c == UID) {
                    ids = user[0].id;

                    if (!test.isRunningTest()) {
                        //redirect create password
                            try{
                                aura.redirect(Site.login(userName, password, Label.CSP_PortalPath + 'resetPassword'));
                            }
                            catch (Exception ex) {
                                //return serror message string in case of any errors
                                system.debug('ERROR ON LOGIN: '+ex.getMessage());
                                result.isSuccess = false;
                                result.errorMessage = Label.OneId_LoginFail;
                            }
                        }
                    }
                }
                else {
                    //redirect to login page
                    aura.redirect(new PageReference(Network.getLoginURL(Network.getNetworkId())));
                }
        }

        return result;
    }

}