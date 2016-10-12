@RestResource(urlMapping='/RecipientsCount/*')
global without sharing class restIECEBC_RecipientsCount {
    @HttpGet
    global static Integer doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String masterFilterId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        return getCount(masterFilterId);
    }
    
    @ReadOnly
    webservice static Integer getCount(String masterFilterId) {
        String cntQuery = IECEBC_Utility.getSOQLFromMasterFilter(null, masterFilterId);
        
        return Integer.valueOf(Database.Query(cntQuery)[0].get('expr0'));
    }
    
    public Integer getCount() {
        String masterFilterId = ApexPages.currentPage().getParameters().get('id');
        
        String cntQuery = IECEBC_Utility.getSOQLFromMasterFilter(null, masterFilterId);
        
        return Integer.valueOf(Database.Query(cntQuery)[0].get('expr0'));
    }
}