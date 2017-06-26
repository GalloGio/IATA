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
        System.debug('resIECEBC_RecipientsCount.webservice static Integer getCount(String masterFilterId) >>>');
        boolean elastic_switch = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
        String cntQuery = IECEBC_Utility.getSOQLFromMasterFilter(null, masterFilterId,elastic_switch);
        if (elastic_switch) {IECEBCNew_eBroadcast_Counter req = new IECEBCNew_eBroadcast_Counter(); return req.execute(cntQuery,false);} 
        //only query salesforce and return counter when elastic switch is false
        return Integer.valueOf(Database.Query(cntQuery)[0].get('expr0'));
    }
    
    public Integer getCount() {
        System.debug('resIECEBC_RecipientsCount.public Integer getCount() >>>');
        String masterFilterId = ApexPages.currentPage().getParameters().get('id');
        boolean elastic_switch = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
        String cntQuery = IECEBC_Utility.getSOQLFromMasterFilter(null, masterFilterId,elastic_switch);
        if (elastic_switch) {IECEBCNew_eBroadcast_Counter req = new IECEBCNew_eBroadcast_Counter(); return req.execute(cntQuery,false);} 
        //only query salesforce and return counter when elastic switch is false 
        return Integer.valueOf(Database.Query(cntQuery)[0].get('expr0'));
    }
}