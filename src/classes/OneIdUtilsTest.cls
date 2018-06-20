@isTest(SeeAllData=false)
private class OneIdUtilsTest {
   
    
    static testMethod void testGetOrgUrl(){

        String orgUrl = URL.getSalesforceBaseUrl().getHost();
        
        //TODO: Set portal context
        String comunityUrl=Site.getBaseUrl();
       
        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'IdentityPortal';
        setting.Value__c = orgUrl;
        insert setting;
        
        OneId_Global_Settings__c setting2 = new OneId_Global_Settings__c();
        setting2.Community_Name__c = 'oneidentity';
        insert setting2;

        ISSP_CS__c cs = new ISSP_CS__c();
        cs.Name='Host';
        cs.Value__c='csp1idsre-customer-portal-iata.cs88.force.com';
        insert cs;        
        
        test.startTest();
        
        String UrlName = OneIdUtils.getCommunityUrlName();                

        String methodUrl = OneIdUtils.getOrgUrl();     

        String Siteurl=OneIdUtils.GetSiteCompleteUrl();
        //String SiteurlSt = OneIdUtils.GetSiteCompleteUrl(OneIdUtils.GET_POR_URL_FROM_SITE);
        
        String SiteurlCs = OneIdUtils.GetSiteCompleteUrl();
        String SiteurlOrgCusTy = OneIdUtils.GetSiteCompleteUrl();
        
        test.stopTest();
        system.assertEquals(methodUrl, orgUrl);
        //TODO:uncoment (after set portal context above)
        // system.assertEquals(SiteurlSt, comunityUrl);
        system.assertEquals(Siteurl, SiteurlOrgCusTy);
        system.assertEquals(SiteurlCs, SiteurlOrgCusTy);
        //System.assertEquals('https://oneidconde-customer-portal-iata.cs83.force.com/oneidentity', OneIdLightningLoginFormController.getSiteCompleteUrl());
       
    }
}