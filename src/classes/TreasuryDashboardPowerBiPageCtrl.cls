global with sharing class TreasuryDashboardPowerBiPageCtrl {

    public String embedUrl{get;set;}
    public String accessToken{get;set;}
    public String objectId{get;set;}
    public String tokenType{get;set;}
    public String groupId{get;set;}
    public String datasetId{get;set;}
    public String expiration{get; set;}


    public TreasuryDashboardPowerBiPageCtrl() {
        this.embedUrl = Apexpages.currentPage().getParameters().get('embedUrl');
        this.accessToken = Apexpages.currentPage().getParameters().get('accessToken');
        this.objectId = Apexpages.currentPage().getParameters().get('objectId');
        this.tokenType = Apexpages.currentPage().getParameters().get('tokenType');
        this.groupId = Apexpages.currentPage().getParameters().get('groupId');
        this.datasetId = Apexpages.currentPage().getParameters().get('datasetId');
        this.expiration = Apexpages.currentPage().getParameters().get('expiration');
    }


    @RemoteAction
    global static String  refreshEmbedToken(String reportId, String groupId, String datasetId) {
        String toReturn = '';

        PowerBI_Config__c conf = PowerBiCtrl.getPowerBICredentials('TreasuryDashboard');

        PowerBiCtrl.OAuthResult result = TreasuryDashboardCtrl.getAccessToken(conf);
        String accessToken = result.access_token;

        if(String.isNotBlank(accessToken)) {
            String userId = UserInfo.getUserId();
            PowerBiCtrl.EmbedTokenResult resultEmbed = TreasuryDashboardCtrl.getEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf);
            toReturn = resultEmbed.token+'expiration='+resultEmbed.expiration;

            return toReturn;
        }

        return toReturn;
    }


    public PageReference redirect() {
        return null;
    }

}