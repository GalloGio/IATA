@isTest
private class OneIdUtilsTest {
    
    static testMethod void testGetOrgUrl(){

        String orgUrl = URL.getSalesforceBaseUrl().getHost();  
        test.startTest();
        
        String methodUrl = OneIdUtils.getOrgUrl();

        test.stopTest();
        system.assertEquals(methodUrl, orgUrl);
    }
}