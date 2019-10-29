public without sharing class PortalForgotPasswordController {

    public class configInfo{
        @AuraEnabled
        public String selfRegistrationUrl{get;set;}
        @AuraEnabled
        public String loginUrl{get;set;}
        @AuraEnabled
        public boolean isSelfRegistrationEnabled{get;set;}
        @AuraEnabled
        public String troubleShootingUrl{get;set;}
    }

    @AuraEnabled
    public static configInfo getInitialConfig(){
        configInfo config = new configInfo();
        Auth.AuthConfiguration authConfig = getAuthConfig();

        //get login and self registration url
        config.selfRegistrationUrl = authConfig.getSelfRegistrationUrl();
        config.loginUrl = Network.getLoginURL(Network.getNetworkId());
        config.isSelfRegistrationEnabled = authConfig.getSelfRegistrationEnabled();
        config.troubleShootingUrl = Label.CSP_PortalPath + 'faq-article?language=en_US&q=troubleshooting';

        ISSP_CS__c cs = ISSP_CS__c.getInstance('TroubleShootingArticleId');
        if(cs != null){
            config.troubleShootingUrl = config.troubleShootingUrl + '&id1=' + cs.value__c;
        }

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
        if(result.success == true){
            String link                  = PortalPasswordHandler.generateUrl(result.user, result.password, 'resetPassword');
            Map<String, String> emailMap = PortalPasswordHandler.forgotPasswordEmailMap(result.user, link);
            result.success               = PortalPasswordHandler.sendEmail(result.user.id, 'CSP_Forgot_Password_Email_VF', emailMap);
        }

        return result;
    }

}