
public without sharing class TreasuryDashboardCtrl {

    public static String POWERBI_ACCESS_TOKEN = 'PowerBIaccessToken';
    public static String POWERBI_EXPIERS_ON = 'PowerBIexpiersOn';
    public static String POWERBI_REFRESH_TOKEN = 'PowerBIrefreshToken';

    public class UserInformation {
        @AuraEnabled
        public User user {get; set;}
        @AuraEnabled
        public Boolean hasTwoFactor {get; set;}
        @AuraEnabled
        public Boolean isStandardUser {get; set;}
        @AuraEnabled
        public Boolean isPremiumUser {get; set;}
        @AuraEnabled
        public Portal_Applications__c tdPremium {get; set;}
    }


    @AuraEnabled
    public static PowerBI_Config__c getPowerBICredentials(String configurationName) {
        return PowerBiCtrl.getPowerBICredentials(configurationName);
    }


    @AuraEnabled
    public static PowerBiCtrl.ReportDetails getReportConfigDetails(String reportName) {
        return PowerBiCtrl.getReportConfigDetails(reportName);
    }


    @AuraEnabled
    public static UserInformation getUserInformation() {

        UserInformation userInfoToReturn = new UserInformation();
        userInfoToReturn.user = null;
        userInfoToReturn.hasTwoFactor = false;
        userInfoToReturn.isStandardUser = false;
        userInfoToReturn.isPremiumUser = false;
        userInfoToReturn.tdPremium = null;

        List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];


        List <Portal_Applications__c> tdServicePremiumList = [SELECT Id, Name, Agency__c, Aplication_Start_Icon__c, Application_icon__c,
                Application_icon_URL__c, Application_URL__c, Case_creation_record_type__c, Confirm_Box__c,
                Confirm_Text__c, Description__c, GSSA__c, Hide_on_Homepage__c,
                ICH_Airline__c, New_Window__c, Not_ICH_Airline__c, Record_type_for_App_Rigth__c,
                Requestable__c, Restricted_App__c, Visible__c, Service_Description__c, TD_Access_Level__c
        FROM Portal_Applications__c
        WHERE Name = 'Treasury Dashboard - Premium'];

        if(! tdServicePremiumList.isEmpty()) {
            userInfoToReturn.tdPremium =  tdServicePremiumList[0];
        }

        if(! users.isEmpty()) {
            //get user
            userInfoToReturn.user = users[0];

            //get two factor
            List<TwoFactorInfo> twoFactors = [SELECT UserId, Type FROM TwoFactorInfo where userID = :users[0].Id];
            if (twoFactors.isEmpty()) {

                //user does not have two factor

            } else {

                userInfoToReturn.hasTwoFactor = true;

            }

            //get is standard user
            List <Portal_Application_Right__c> accessList = [
                    SELECT Id, Portal_Application__r.TD_Access_Level__c,
                            Portal_Application__r.TD_Included_Dashboards__c,
                            Portal_Application__r.TD_Included_Reports__c
                    FROM Portal_Application_Right__c
                    WHERE Contact__c = :users[0] .ContactId
                    AND Portal_Application__r.Name LIKE 'Treasury Dashboard%'
                    AND Right__c = 'Access Granted'
            ];
            //TreasuryDashboard access not granted
            if (accessList.isEmpty()) {

                //no Standard Dashboard access

            } else {//access granted

                userInfoToReturn.isStandardUser = true;

                if (accessList[0].Portal_Application__r.TD_Included_Dashboards__c != null) {
                    List<String> dashboardAccess = accessList[0].Portal_Application__r.TD_Included_Dashboards__c.split(';');
                    for (String thisDashboard : dashboardAccess) {

                        if (thisDashboard == 'ISSP_TD_5') {
                            userInfoToReturn.isStandardUser = false;
                            userInfoToReturn.isPremiumUser = true;
                            break;

                        }
                    }

                }


            }

        }

        return userInfoToReturn;

    }

    /* USE THIS AS GCS PORTAL DOES*/
    /*@AuraEnabled
    public static String premiumAccessRequest(String applicationId, String applicationName, String contactId) {
        return PortalServicesCtrl.newAppsRequestICCS(applicationId, applicationName, contactId);
    }*/


    /*FROM ORIGINAL PAGE*/
    @AuraEnabled
    public static String premiumAccessRequest(String applicationId, String contactId) {
        return requestTreasuryDashboardPremium(applicationId, contactId);
    }


    @RemoteAction
    public static String requestTreasuryDashboardPremium (String applicationId, String contactId){
        insert new Portal_Application_Right__c(Contact__c = contactId,Portal_Application__c = applicationId,Right__c = 'Access Requested');
        return 'ok';
    }

    @AuraEnabled
    public static String getCaseRecordTypeId() {
        String caseRecordTypeId = '';

        ISSP_Record_Type_Mgmt__c rtMgmt =  ISSP_Record_Type_Mgmt__c.getValues('Treasury Dashboard');
        if (rtMgmt != null){
            if (rtMgmt.Record_Type_Name__c != null){
                caseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', rtMgmt.Record_Type_Name__c);
            }
        }

        return caseRecordTypeId;
    }


    @AuraEnabled
    public static PowerBiCtrl.OAuthResult getAccessToken(PowerBI_Config__c conf) {

        Cache.OrgPartition orgPartition = null;
        PowerBiCtrl.OAuthResult result = new PowerBiCtrl.OAuthResult();

        if(conf == null) {
            return null;
        }

        if(Test.isRunningTest()){

            try{
                orgPartition = Cache.Org.getPartition('local.PowerBI');
            }catch(Cache.Org.OrgCacheException e) {
                return PowerBiCtrl.getNewAccessToken(conf);
            }

        } else {
            orgPartition = Cache.Org.getPartition('local.PowerBI');
        }

        if (orgPartition != null) {

            String applicationSufix = conf.Application_Identifier__c;

            if (orgPartition.contains(POWERBI_ACCESS_TOKEN+applicationSufix)) {

                result.access_token = (String) orgPartition.get(POWERBI_ACCESS_TOKEN+applicationSufix);

                if (orgPartition.contains(POWERBI_EXPIERS_ON+applicationSufix)) {

                    Long expiresOn = (Long) orgPartition.get(POWERBI_EXPIERS_ON+applicationSufix);


                    //PowerBI is using timestamp without milliseconds - we need to divide by 1000
                    Long currentTime = (System.now().getTime()) / 1000;

                    if ((expiresOn - 360) < currentTime) {//token will expire in 6 minutes


                        if (orgPartition.contains(POWERBI_REFRESH_TOKEN+applicationSufix)) {
                            //refresh token here
                            String refreshToken = (String)orgPartition.get(POWERBI_REFRESH_TOKEN+applicationSufix);
                            result = PowerBiCtrl.refreshToken(refreshToken, conf);
                            saveAccessTokenInOrgCache(orgPartition, result, conf);
                        } else {
                            //get new token
                            result = PowerBiCtrl.getNewAccessToken(conf);
                            saveAccessTokenInOrgCache(orgPartition, result, conf);
                        }

                    } else {//token OK
                        result.expires_on = (Long) orgPartition.get(POWERBI_EXPIERS_ON+applicationSufix);

                        if (orgPartition.contains(POWERBI_REFRESH_TOKEN+applicationSufix)) {

                            result.refresh_token = (String) orgPartition.get(POWERBI_REFRESH_TOKEN+applicationSufix);
                            System.debug('getting master account access token from cache');

                        } else {
                            //refresh token not found - get new token
                            result = PowerBiCtrl.getNewAccessToken(conf);
                            saveAccessTokenInOrgCache(orgPartition, result, conf);
                        }

                    }

                } else {
                    //expiresOn not found - get new token
                    result = PowerBiCtrl.getNewAccessToken(conf);
                    saveAccessTokenInOrgCache(orgPartition, result, conf);
                }

            } else {
                //access token not found - get new token
                result = PowerBiCtrl.getNewAccessToken(conf);
                saveAccessTokenInOrgCache(orgPartition, result, conf);
            }
        }

        return result;
    }

    @AuraEnabled
    public static PowerBiCtrl.DatasetDetailResult getDataset(String accessToken, String datasetId, PowerBI_Config__c conf) {
        return PowerBiCtrl.getDataset(accessToken, datasetId, conf);
    }

    @AuraEnabled
    public static PowerBiCtrl.ReportDetailResult getReportsDetails(String accessToken, String reportId, PowerBI_Config__c conf) {
        return PowerBiCtrl.getReportsDetails(accessToken, reportId, conf);
    }

    /*@AuraEnabled
    public static PowerBiCtrl.EmbedTokenResult getEmbedToken(String accessToken, String userId, String groupId, String reportId, String datasetId, PowerBI_Config__c conf) {
        return PowerBiCtrl.getEmbedToken(accessToken, userId,  groupId, reportId, datasetId, conf);
    }*/

    @AuraEnabled
    public static PowerBiCtrl.EmbedTokenResult getEmbedToken(String accessToken, String userId, String groupId, String reportId, String datasetId, PowerBI_Config__c conf) {
        System.debug('accessToken: ' + accessToken);
        System.debug('userId: ' + userId);
        System.debug('groupId: ' + groupId);
        System.debug('reportId: ' + reportId);
        System.debug('datasetId: ' + datasetId);
        System.debug('conf: ' + conf);

        if(conf == null) {
            return null;
        }

        PowerBiCtrl.EmbedTokenResult result = new PowerBiCtrl.EmbedTokenResult();
        Cache.SessionPartition sessionPartition = null;

        String cacheKey = reportId.replaceAll('-', '');

        if(Test.isRunningTest()) {

            try{

                sessionPartition = Cache.Session.getPartition('local.PowerBiSession');

            }catch(Cache.Session.SessionCacheException e) {

                return PowerBiCtrl.getEmbedToken(accessToken, userId,  groupId, reportId, datasetId, conf);

            }

        } else {

            sessionPartition = Cache.Session.getPartition('local.PowerBiSession');

        }


        if(sessionPartition != null) {

            if(sessionPartition.contains(cacheKey)) {

                result.token = (String)sessionPartition.get(cacheKey);

                if(sessionPartition.contains(cacheKey+'expireson')) {

                    //expireson present in cache
                    String cacheExpireson = (String)sessionPartition.get(cacheKey + 'expireson');
                    if(String.isNotBlank(cacheExpireson)) {

                        Datetime expiresonDatetime = getExpiresOnDatetime(cacheExpireson);
                        System.debug('expiresonDatetime:: ' + expiresonDatetime);

                        if(expiresonDatetime.addMinutes(-10) < Datetime.now()) {
                            //token expires in less than 10 minutes - get new
                            result = PowerBiCtrl.getEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf);
                            saveEmbedTokenInSessionCache(sessionPartition, result, conf, cacheKey);

                        } else {
                            //token is OK
                            result.expiration = cacheExpireson;

                        }

                    }

                } else {
                    //no expires on in cache
                    result = PowerBiCtrl.getEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf);
                    saveEmbedTokenInSessionCache(sessionPartition, result, conf, cacheKey);
                }

            } else {
                // no embed token in cache
                result = PowerBiCtrl.getEmbedToken(accessToken, userId, groupId, reportId, datasetId, conf);
                saveEmbedTokenInSessionCache(sessionPartition, result, conf, cacheKey);
            }

        }


        return result;
    }

    private static Datetime getExpiresOnDatetime(String expiresOn) {
        String expiresonString = '"' + expiresOn + '"';
        Datetime expiresonDatetime = (DateTime)JSON.deserialize(expiresonString, DateTime.class);
        return expiresonDatetime;
    }

    private static void saveAccessTokenInOrgCache(Cache.OrgPartition orgPartition, PowerBiCtrl.OAuthResult result, PowerBI_Config__c conf) {
        if(result.error != null) {
            TransformationHelper.sendEmailSupport('FATAL: PowerBI Master Account Access token: ' + conf.Name + ' ' + result.error, 'PowerBI Master Account Access token: ' + conf.Name + ' ' +result.error);
            throw new transformationException('PowerBI Master Account Access token: ' + result.error);
        }
        else if(result.access_token != null && result.expires_on != null && result.refresh_token != null) {
            System.debug('saving master account access token to cache');
            String applicationSufix = conf.Application_Identifier__c;
            orgPartition.put(POWERBI_ACCESS_TOKEN + applicationSufix, result.access_token, 3600);
            orgPartition.put(POWERBI_EXPIERS_ON + applicationSufix, result.expires_on, 3600);
            orgPartition.put(POWERBI_REFRESH_TOKEN + applicationSufix, result.refresh_token, 3600);
        }

    }


    private static void saveEmbedTokenInSessionCache(Cache.SessionPartition sessionPartition, PowerBiCtrl.EmbedTokenResult result, PowerBI_Config__c conf, String cacheKey) {
        if(result.error != null) {
            TransformationHelper.sendEmailSupport('FATAL: PowerBI Master Account Embed token: ' + conf.Name + ' ' + result.error, 'PowerBI Master Account Embed token: ' + conf.Name + ' ' +result.error);
            throw new transformationException('PowerBI Master Account Embed token: ' + result.error);
        } else if(result.token != null && result.expiration != null){
            System.debug('saving master account embed token to cache');

            sessionPartition.put(cacheKey, result.token, 3600);
            sessionPartition.put(cacheKey+'expireson', result.expiration, 3600);

        }
    }




}