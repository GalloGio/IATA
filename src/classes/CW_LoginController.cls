public without sharing class CW_LoginController {
    public String portalUrl {get;set;}
    public String serviceId {get;set;}
    public CW_LoginController() {
        portalUrl = ISSP_CS__c.getValues('HostCSP').Value__c;
        if(portalUrl != null) portalUrl = portalUrl.removeEnd('/');
        serviceId = getOneSourceServiceId();
    }

    @AuraEnabled (cacheable=true)
    public static String getOneSourceServiceId(){
        String srvcId;
        List<Portal_Applications__c> oneSourceApp = [Select Id from Portal_Applications__c where Name = 'One Source' limit 1];
        if(!oneSourceApp.isEmpty()) srvcId = oneSourceApp[0].Id;
        return srvcId;
    }
}