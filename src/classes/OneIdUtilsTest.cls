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

        ISSP_CS__c setting3 = new ISSP_CS__c();
        setting3.Name = 'Host';
        setting3.Value__c = orgUrl;
        insert setting3;
        
        OneId_Global_Settings__c setting2 = new OneId_Global_Settings__c();
        setting2.Community_Name__c = 'oneidentity';
        insert setting2;
        
        
        test.startTest();
        
        String UrlName = OneIdUtils.getCommunityUrlName();                

        String methodUrl = OneIdUtils.getOrgUrl();      
        String communityRedirection = OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY, methodUrl);      
        String Siteurl=OneIdUtils.GetSiteCompleteUrl();
        String SiteurlSt = OneIdUtils.GetSiteCompleteUrl(OneIdUtils.Mode.IDENTITY);
        //String communityRedirection = OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY, methodUrl);  
        
        //String SiteurlCs = OneIdUtils.GetSiteCompleteUrl(OneIdUtils.GET_POR_URL_FROM_ISSP_CS);
        //String SiteurlOrgCusTy = OneIdUtils.GetSiteCompleteUrl(OneIdUtils.GET_POR_URL_FROM_ORG_AND_CUM_NAME_CS);
        
        test.stopTest();
        system.assertEquals(methodUrl, orgUrl);
        //TODO:uncoment (after set portal context above)
        // system.assertEquals(SiteurlSt, comunityUrl);
        //system.assertEquals(Siteurl, SiteurlOrgCusTy);
        //system.assertEquals(SiteurlCs, SiteurlOrgCusTy);
        //System.assertEquals('https://oneidconde-customer-portal-iata.cs83.force.com/oneidentity', OneIdLightningLoginFormController.getSiteCompleteUrl());
       
    }
}