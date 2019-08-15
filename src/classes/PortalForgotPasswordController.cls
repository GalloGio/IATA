public without sharing class PortalForgotPasswordController {

    public class configInfo{
        @AuraEnabled
        public String selfRegistrationUrl{get;set;}
        @AuraEnabled
        public String loginUrl{get;set;}
    }

    @AuraEnabled
    public static configInfo getInitialConfig(){
        configInfo config = new configInfo();
        Auth.AuthConfiguration authConfig = getAuthConfig();

        //get login and self registration url
        config.selfRegistrationUrl = authConfig.getSelfRegistrationUrl();
        config.loginUrl = Network.getLoginURL(Network.getNetworkId());
        return config;
    }

    @TestVisible
    public static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    public static PortalPasswordHandler.resultWrapper handleResetPassword(String email){
        PortalPasswordHandler.resultWrapper result = PortalPasswordHandler.handleResetPassword(email);
        return result;
    }

}