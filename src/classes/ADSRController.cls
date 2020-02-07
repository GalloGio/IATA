public without sharing class ADSRController {
    
    @AuraEnabled(cacheable=true)
    public static List<PicklistWrapper> getRegions(){
        List<PicklistWrapper> result = new List<PicklistWrapper>();
    
        for(Schema.PicklistEntry region : Utility.getPicklistEntries('IATA_ISO_Country__c', 'Region__c')){
            PicklistWrapper item = new PicklistWrapper();
            item.value = region.getValue();
            item.label = region.getLabel();
            result.add(item);
        }

        return result;
    }

    @AuraEnabled
    public static List<PicklistWrapper> getMarkets(String region){
        List<PicklistWrapper> result = new List<PicklistWrapper>();
        
        if(String.isBlank(region)){
            return result;
        }

        for(IATA_ISO_Country__c market : [SELECT Id, Name FROM IATA_ISO_Country__c WHERE Region__c = :region ORDER BY Name ASC]){
            PicklistWrapper item = new PicklistWrapper();
            item.value = market.Id;
            item.label = market.Name;
            result.add(item);
        }

        return result;
    }

    @AuraEnabled
    public static List<Object> getAgents(){
        return new List<Object>();
    }

    @AuraEnabled
    public static ADSRService.SummaryReport getReport(){
        ADSRService service = new ADSRService('airlineCode', 'region', 'markets', 'operation', null);

        ADSRService.SummaryReport report = service.getSummaryReport();

        return report;
    }

    public class PicklistWrapper {
        @AuraEnabled public String value;
        @AuraEnabled public String label;

        public PicklistWrapper(){

        }
    }

}