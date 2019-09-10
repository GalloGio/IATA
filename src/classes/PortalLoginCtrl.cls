/**
 * Created by ukaya01 on 02/07/2019.
 */

public with sharing class PortalLoginCtrl {

    public class LoginConfig{
        @AuraEnabled
        public Boolean isUsernamePasswordEnabled{get;set;}
        @AuraEnabled
        public Boolean isSelfRegistrationEnabled{get;set;}
        @AuraEnabled
        public String selfRegistrationUrl{get;set;}
        @AuraEnabled
        public String forgotPasswordUrl{get;set;}
    }

    public class LoginResult{
        @AuraEnabled
        public boolean isSuccess{get;set;}
        @AuraEnabled
        public string errorMessage{get;set;}
        @AuraEnabled
        public string sessionUrl{get;set;}
        @AuraEnabled
        public boolean userIsFrozen{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static LoginConfig getInitialConfig(){
        LoginConfig config = new LoginConfig();
        Auth.AuthConfiguration authConfig = getAuthConfig();
        config.isUsernamePasswordEnabled = authConfig.getUsernamePasswordEnabled();
        config.isSelfRegistrationEnabled = authConfig.getSelfRegistrationEnabled();
        config.selfRegistrationUrl = authConfig.getSelfRegistrationUrl();
        config.forgotPasswordUrl = authConfig.getForgotPasswordUrl();
        system.debug('config: ' + config);
        return config;
    }

    @AuraEnabled
    public static LoginResult login(String username, String password, string landingPage) {
        LoginResult result = new LoginResult();
        result.userIsFrozen = false;
        string startUrl = '';

        system.debug('landingPage: ' + landingPage);

        if(landingPage != null && landingPage != ''){
            landingPage = EncodingUtil.urlDecode(landingPage, 'UTF-8');
            system.debug('landingPage: ' + landingPage);
            if(landingPage.contains(Label.CSP_PortalPath)){
                startUrl = landingPage;
            }else{
                startUrl = Label.CSP_PortalPath + landingPage;
            }
        }else{
            startUrl = Label.CSP_PortalPath;
        }

        system.debug('startUrl: ' + startUrl);

        User oneUser;
        username = (null != username) ? username.trim() : username;

        try{

            list<User> userList = DAL_ISSP.getUserListByNameOrEmail(username);

            //Errors validation
            if (username == '' || password == ''){
                result.isSuccess = false;
                result.errorMessage = Label.OneId_Password_ErrorBlank;
                return result;
            }

            if(ISSP_Utilities.isNotEmpty(userList)) {
                oneUser = userList[0];
                PermissionSetAssignment [] psa = [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =:oneUser.id AND PermissionSetId IN
                (SELECT Id FROM PermissionSet WHERE Name = 'Identity_Portal_User')];

                if(psa.size()==0){
                    LightningRegistrationProcess.assignIdentityPermissionSet(oneUser.Id);
                }

                //Assign GDPR Permission set when user logs in. No matter the service
                LightningRegistrationProcess.assignGDPRPermissionSet(oneUser.Id);
            }
            //to developer Testing user frozen reactivate user reset password and send password email  - uncoment line below
            //oneUser.Portal_User_Frozen_Checkbox__c=true;

            if (oneUser.Portal_User_Frozen_Checkbox__c){
                result.isSuccess = false;
                result.userIsFrozen = true;
                reactivateUser(oneUser);
                return result;
            }


            username=null != oneUser ? oneUser.Username : username;

            OneIdUtils.Mode mode=null;
            mode=OneIdUtils.Mode.CSP;

            System.PageReference pageRef = Site.login(username, password, startUrl);

            system.debug('page reference return from login: '+pageRef);
            result.isSuccess = true;
            result.sessionUrl = pageRef.getUrl();

            //todo:replace this part for customer portal logic
            /*
            if (userListConfirmTempPassword[0].UID__c != '' && userListConfirmTempPassword[0].UID__c != null){
                pageRef = Site.login(username, password, OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/OneId_ChangePassword'+serviceNameParam));
            }
            */

            return result;
        }
        catch (Exception ex) {
            //return serror message string in case of any errors
            system.debug('ERROR ON LOGIN: '+ex.getMessage());
            result.isSuccess = false;
            result.errorMessage = Label.OneId_LoginFail;
            result.sessionUrl = '';
            return result;
        }
    }

    @TestVisible
    public static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    public static void reactivateUser(User usr){
        PortalPasswordHandler.resultWrapper result = PortalPasswordHandler.handleResetPassword(usr.email);
        if(result.success == true){
            String link                  = PortalPasswordHandler.generateUrl(result.user, result.password, 'resetPassword');
            Map<String, String> emailMap = PortalPasswordHandler.forgotPasswordEmailMap(result.user, link);
            result.success               = PortalPasswordHandler.sendEmail(result.user.id, 'CSP_Forgot_Password_Email', emailMap);
        }
    }

}