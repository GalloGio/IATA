public with sharing class CW_LandingSearchBarController {

    @AuraEnabled(cacheable=true)
    public static String getLocationsList(){
        Map<String,Integer> locationResultsMap = new Map<String,Integer>();
        
        List<ICG_Account_Role_Detail__c> accountRoleDetails = [Select City__c, Country__c, Nearest_Airport__c from ICG_Account_Role_Detail__c ];
        Schema.DescribeFieldResult countryField = ICG_Account_Role_Detail__c.Country__c.getDescribe();
        Schema.sObjectField countryFieldDescription = countryField.getSObjectField();
        List<PicklistEntry> entries = countryFieldDescription.getDescribe().getPicklistValues();
        for (PicklistEntry entry : entries){
            locationResultsMap.put(entry.getValue(), 0);
        }
        for (ICG_Account_Role_Detail__c accd : accountRoleDetails){
            if (locationResultsMap.get(accd.City__c) == null){
                locationResultsMap.put(accd.City__c, 1);
            }else {
                locationResultsMap.put(accd.City__c, locationResultsMap.get(accd.City__c)+1);
            }

            if (locationResultsMap.get(accd.Country__c) == null){
                locationResultsMap.put(accd.Country__c, 1);
            }else {
                locationResultsMap.put(accd.Country__c, locationResultsMap.get(accd.Country__c)+1);
            }

            if (locationResultsMap.get(accd.Nearest_Airport__c) == null){
                locationResultsMap.put(accd.Nearest_Airport__c, 1);
            }else {
                locationResultsMap.put(accd.Nearest_Airport__c, locationResultsMap.get(accd.Nearest_Airport__c)+1);
            }
        }
        return JSON.serialize(locationResultsMap);
        // return JSON.serialize(orderIntegerValuesMap(locationResultsMap));
    }

    @AuraEnabled (cacheable=true)
    public static String getCertificationsList(){
        Map<String,Integer> certificationsResultsMap = new Map<String,Integer>();
        
        List<ICG_Certification__c> certDetails = [Select name, (select id from ICG_Account_Role_Detail_Certifications__r) from ICG_Certification__c ]; //Check if cert is expired to avoid it
        for (ICG_Certification__c cert : certDetails){
                certificationsResultsMap.put(cert.name, cert.ICG_Account_Role_Detail_Certifications__r.size());
        }
        
        return JSON.serialize(orderIntegerValuesMap(certificationsResultsMap));
    }

    @AuraEnabled (cacheable = true)
    public static String getCompanyNamesList(){
        Map<String,Integer> companyNamesResultsMap = new Map<String,Integer>();
        
        List<ICG_Account_Role_Detail__c> accountDetails = [Select id, Account_Role__r.Account__r.name from ICG_Account_Role_Detail__c ]; //add where type in (list of available type to show) 
        for (ICG_Account_Role_Detail__c accd : accountDetails){
            if (companyNamesResultsMap.get(accd.Account_Role__r.Account__r.name) == null){
                companyNamesResultsMap.put(accd.Account_Role__r.Account__r.name, 1);
            }else {
                companyNamesResultsMap.put(accd.Account_Role__r.Account__r.name, companyNamesResultsMap.get(accd.Account_Role__r.Account__r.name)+1);
            }
        }

        return JSON.serialize(orderIntegerValuesMap(companyNamesResultsMap));
    }

    public static Map<String,Integer> orderIntegerValuesMap (Map<String,Integer> mapToOrder){
        Map<String,Integer> orderedMap = new Map<String,Integer>();
        if(mapToOrder != null){
            List<String> keys = new List<String>();
            List<integer> numbers = new List<integer>();

            keys.addAll(mapToOrder.keySet());
            for(String str : keys)
            {
                numbers.add(mapToOrder.get(str));
            }
            numbers.sort();

            for(Integer num : numbers)
            {
                for(String key : keys)
                {
                    Integer j=mapToOrder.get(key);
                    if(j==num && !orderedMap.containsKey(key))
                    {
                        orderedMap.put(key,num);
                    }
                }
            }
        }

        return orderedMap;
    }
}