global with sharing class TreasuryDashboardPowerBiReportPageCtrl {

    public String embedUrl{get;set;}
    public String accessToken{get;set;}
    public String objectId{get;set;}
    public String tokenType{get;set;}
    public String groupId{get;set;}
    public String expiration{get; set;}


    public TreasuryDashboardPowerBiReportPageCtrl() {
        this.embedUrl = Apexpages.currentPage().getParameters().get('embedUrl');
        this.accessToken = Apexpages.currentPage().getParameters().get('accessToken');
        this.objectId = Apexpages.currentPage().getParameters().get('objectId');
        this.tokenType = Apexpages.currentPage().getParameters().get('tokenType');
        this.groupId = Apexpages.currentPage().getParameters().get('groupId');
        this.expiration = Apexpages.currentPage().getParameters().get('expiration');
    }

    @RemoteAction
    global static String  refreshEmbedToken(String reportId, String groupId) {
        String toReturn = '';

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboardReport');

        PowerBiCtrl.ServicePrincipalAccessTokenResult result = TreasuryDashboardReportCtrl.getServicePrincipalAccessToken(conf);
        String accessToken = result.access_token;

        if(String.isNotBlank(accessToken)) {
            String userId = UserInfo.getUserId();
            PowerBiCtrl.ServicePrincipalEmbedTokenResult resultEmbed = TreasuryDashboardReportCtrl.getServicePrincipalEmbedToken(accessToken, userId, groupId, reportId, conf);
            toReturn = resultEmbed.token+'expiration='+resultEmbed.expiration;

            return toReturn;
        }

        return toReturn;
    }

    public PageReference redirect() {
        return null;
    }

}