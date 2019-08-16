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
    public static LoginResult login(String username, String password) {
        LoginResult result = new LoginResult();
        result.userIsFrozen = false;
        string startUrl = '/csportal/s/';
        User oneUser;
        String pageLink='';
        //Clear spaces
        username = (null != username) ? username.trim() : username;

        try{
            System.debug('Controller.login.Begin');
            list<User> userList = DAL_ISSP.getUserListByNameOrEmail(username);
            system.debug('userList: ' + userList);
            system.debug('username: ' + username);
            system.debug('startUrl: ' + startUrl);

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

            system.debug('user idX: ' + oneUser.Id);
            system.debug('contact id: ' + oneUser.ContactId);
            system.debug('Portal_User_Frozen_Checkbox__c: ' + oneUser.Portal_User_Frozen_Checkbox__c);


            if (oneUser.Portal_User_Frozen_Checkbox__c){
                result.isSuccess = false;
                result.userIsFrozen = true;
                reactivateUser(oneUser);
                return result;
            }


            username=null != oneUser ? oneUser.Username : username;
            system.debug('pageLink: ' + pageLink);
            system.debug('Used Username: '+username);




            OneIdUtils.Mode mode=null;
            mode=OneIdUtils.Mode.CSP;

            //login in siteCompleteUrl
            //System.PageReference pageRef = Site.login(username, password, OneIdUtils.getCommunityRedirection(mode,startUrl));
            //System.PageReference pageRef = Site.login(username, password, 'corejune-customer-portal-iata.cs101.force.com/csportal/s/');

            System.PageReference pageRef = Site.login(username, password, startUrl);

            system.debug('page reference return from login: '+pageRef);
            result.isSuccess = true;
            result.sessionUrl = pageRef.getUrl();

            //aura.redirect(Site.login(username, password, '/csportal/s/test'));

            //todo: commented because LastPasswordChangeDate field does not exist
            /*
            List<User> userListConfirmTempPassword = [SELECT Id, ToU_Accepted__c, UID__c, LastPasswordChangeDate , Email, ContactId
            //X2FA_Session__c, TD_User__c
            FROM User WHERE username =:username limit 1];

            system.debug('userListConfirmTempPassword '+ userListConfirmTempPassword[0]);
            */

            //todo:replace this part for customer portal logic
            /*
            if (userListConfirmTempPassword[0].UID__c != '' && userListConfirmTempPassword[0].UID__c != null){
                pageRef = Site.login(username, password, OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/OneId_ChangePassword'+serviceNameParam));
            }
            */

            //Check user permissions for FAQs, reassign if needed
            //todo: FAQ does not exist
            /*
            try{
                PortalFAQsSharingCtrl.validateUserFAQsPermissions(oneUser.Id);
            }catch(Exception e){
                System.debug('Unable to validate FAQs permissions assignments. \n'+e);
            }
            */
            //redirect to startUrl or some other page returned from the login
            //for different login cases scenarios
            //todo:does not work on lwc
            //aura.redirect(pageRef);

            //return null in case of login success
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
        PortalPasswordHandler.handleResetPassword(usr.email);
    }

}