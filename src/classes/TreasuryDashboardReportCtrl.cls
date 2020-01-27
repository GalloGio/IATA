public without sharing class TreasuryDashboardReportCtrl {

    public static String SERVICE_PRINCIPAL_ACCESS_TOKEN = 'PrincipalAccessToken';
    public static String SERVICE_PRINCIPAL_EXPIERS_ON = 'PrincipalExpiresOn';



    @AuraEnabled
    public static PowerBI_Config__c getPowerBICredentials(String configurationName) {
        return PowerBiCtrl.getPowerBICredentials(configurationName);
    }


    @AuraEnabled
    public static PowerBiCtrl.ReportDetails getReportConfigDetails(String reportName) {
        return PowerBiCtrl.getReportConfigDetails(reportName);
    }



    @AuraEnabled
    public static PowerBiCtrl.ServicePrincipalAccessTokenResult getServicePrincipalAccessToken(PowerBI_Config__c conf) {

        if(conf == null) {
            return null;
        }

        PowerBiCtrl.ServicePrincipalAccessTokenResult result = new PowerBiCtrl.ServicePrincipalAccessTokenResult();
        Cache.OrgPartition orgPartition = null;

        if(Test.isRunningTest()){

            try{
                orgPartition = Cache.Org.getPartition('local.PowerBI');
            }catch(Cache.Org.OrgCacheException e) {
                return PowerBiCtrl.getServicePrincipalAccessToken(conf);
            }

        } else {
            orgPartition = Cache.Org.getPartition('local.PowerBI');
        }

        if(orgPartition != null) {

            String applicationSufix = conf.Application_Identifier__c;

            if (orgPartition.contains(SERVICE_PRINCIPAL_ACCESS_TOKEN+applicationSufix)) {

                result.access_token = (String)orgPartition.get(SERVICE_PRINCIPAL_ACCESS_TOKEN+applicationSufix);

                if (orgPartition.contains(SERVICE_PRINCIPAL_EXPIERS_ON+applicationSufix)) {

                    Long expiresOn = (Long)orgPartition.get(SERVICE_PRINCIPAL_EXPIERS_ON+applicationSufix);

                    //PowerBI is using timestamp without milliseconds - we need to divide by 1000
                    Long currentTime = (System.now().getTime()) / 1000;

                    if((expiresOn - 1200) < currentTime) {//token will expire in 20 minutes

                        result = PowerBiCtrl.getServicePrincipalAccessToken(conf);
                        saveAccessTokenInOrgCache(orgPartition, result, conf);

                    } else {//token is OK

                        result.expires_on = expiresOn;
                    }

                } else {
                    //expiresOn not found - get new token
                    result = PowerBiCtrl.getServicePrincipalAccessToken(conf);
                    saveAccessTokenInOrgCache(orgPartition, result, conf);
                }


            } else {
                //access token not found - get new token
                result = PowerBiCtrl.getServicePrincipalAccessToken(conf);
                saveAccessTokenInOrgCache(orgPartition, result, conf);
            }
        }


        return result;

    }

    @AuraEnabled
    public static PowerBiCtrl.ServicePrincipalEmbedTokenResult getServicePrincipalEmbedToken(String accessToken, String userId, String groupId, String reportId, PowerBI_Config__c conf) {

        if(conf == null) {
            return null;
        }

        PowerBiCtrl.ServicePrincipalEmbedTokenResult result = new PowerBiCtrl.ServicePrincipalEmbedTokenResult();
        Cache.SessionPartition sessionPartition = null;

        String reportIdReplaced = reportId.replaceAll('-', '');
        String cacheKey = conf.Application_Identifier__c + reportIdReplaced;

        if(Test.isRunningTest()) {

            try{

                sessionPartition = Cache.Session.getPartition('local.PowerBiSession');

            }catch(Cache.Session.SessionCacheException e) {

                return PowerBiCtrl.getServicePrincipalEmbedToken(accessToken, userId, groupId, reportId, conf);

            }

        }else{

            sessionPartition = Cache.Session.getPartition('local.PowerBiSession');

        }

        if(sessionPartition != null) {

            if(sessionPartition.contains(cacheKey)) {
                //embedToken for reportId is in cache

                result.token = (String)sessionPartition.get(cacheKey);

                if(sessionPartition.contains(cacheKey + 'expireson')) {

                    //expireson present in cache
                    String cacheExpireson = (String)sessionPartition.get(cacheKey + 'expireson');
                    if(String.isNotBlank(cacheExpireson)) {

                        Datetime expiresonDatetime = getExpiresOnDatetime(cacheExpireson);

                        if(expiresonDatetime.addMinutes(-20) < Datetime.now()) {
                            //token expires in less than 10 minutes - get new
                            result = PowerBiCtrl.getServicePrincipalEmbedToken(accessToken, userId, groupId, reportId, conf);
                            saveEmbedTokenInSessionCache(sessionPartition, result, cacheKey);

                        }else{
                            //token is ok now
                            result.expiration = cacheExpireson;
                        }
                    }


                }else{

                    //expireson missing in cache for reportId - get new
                    result = PowerBiCtrl.getServicePrincipalEmbedToken(accessToken, userId, groupId, reportId, conf);
                    saveEmbedTokenInSessionCache(sessionPartition, result, cacheKey);

                }

            }else{
                //no embedToken for reportId in cache - get new
                result = PowerBiCtrl.getServicePrincipalEmbedToken(accessToken, userId, groupId, reportId, conf);
                saveEmbedTokenInSessionCache(sessionPartition, result, cacheKey);

            }

        }

        return result;

    }


    private static void saveAccessTokenInOrgCache(Cache.OrgPartition orgPartition, PowerBiCtrl.ServicePrincipalAccessTokenResult result, PowerBI_Config__c conf) {
        if(result.error != null) {
            TransformationHelper.sendEmailSupport('FATAL: PowerBI Service Principal Access token: ' + conf.Name + ' ' + result.error, 'PowerBI Service Principal Access token: ' + conf.Name + ' ' +result.error);
            throw new transformationException('PowerBI Service Principal Access token: ' + result.error);
        }
        else if(result.access_token != null && result.expires_on != null) {
            String applicationSufix = conf.Application_Identifier__c;
            orgPartition.put(SERVICE_PRINCIPAL_ACCESS_TOKEN + applicationSufix, result.access_token, 3600);
            orgPartition.put(SERVICE_PRINCIPAL_EXPIERS_ON + applicationSufix, result.expires_on, 3600);
        }

    }


    private static Datetime getExpiresOnDatetime(String expiresOn) {
        String expiresonString = '"' + expiresOn + '"';
        Datetime expiresonDatetime = (DateTime)JSON.deserialize(expiresonString, DateTime.class);
        return expiresonDatetime;
    }


    private static void saveEmbedTokenInSessionCache(Cache.SessionPartition sessionPartition, PowerBiCtrl.ServicePrincipalEmbedTokenResult result, String cacheKey) {
        if(result.error != null) {
            TransformationHelper.sendEmailSupport('FATAL: PowerBI Service Principal Embed token error: ' + result.error.message, 'PowerBI Service Principal Embed token error: ' + result.error.message);
            throw new transformationException('PowerBI Service Principal Embed token: ' + result.error.message);
        }
        else if(result.token != null && result.expiration != null) {

            sessionPartition.put(cacheKey, result.token, 3600);
            sessionPartition.put(cacheKey+'expireson', result.expiration, 3600);
        }
    }

}