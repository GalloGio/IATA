public with sharing class CW_AccountDetailCertificationList {
    @AuraEnabled (cacheable=true)
    public static Map<Boolean, List<ICG_Certification__c>> getCertificationList(String accountName){
        Set<String> certificationsNameList = new Set<String>();
        List<ICG_Account_Role_Detail_Certification__c> AccRoleCertificationlist = 
            [SELECT Id, Name,Certification__r.Name__c,Certification__r.Id, Certification__r.Image__c 
                FROM ICG_Account_Role_Detail_Certification__c 
                    WHERE ICG_Account_Role_Detail__r.Name =: accountName]; 

        for(ICG_Account_Role_Detail_Certification__c accRoleCert: AccRoleCertificationlist){
            certificationsNameList.add(accRoleCert.Certification__r.Name__c);
        }
        List<ICG_Certification__c> allCertifictations = [SELECT Id,Name__c,Certification_Type__c,Expiration_Period__c,is_visible__C,Image__c, Order__c
                        FROM ICG_Certification__c WHERE is_visible__C=TRUE];

        if(!certificationsNameList.isEmpty()){
            List<ICG_Certification__c> accountCertifictations = [SELECT Id,Name__c,Certification_Type__c,Expiration_Period__c,is_visible__C,Image__c, Order__c
                        FROM ICG_Certification__c WHERE Name__c IN: certificationsNameList
                            AND is_visible__C=TRUE];
            
            Map<Boolean, List<ICG_Certification__c>> returnMap = new Map<Boolean, List<ICG_Certification__c>>();

            for(ICG_Certification__c cert: allCertifictations){

                boolean exists = false;

                for(ICG_Certification__c accCert: accountCertifictations){
                    if(String.isNotBlank(cert.Name__c)){
                        if(cert.Name__c.equals(accCert.Name__c)){
                            exists = true;
                        }
                    }
                }

                if(returnMap.get(exists) != null){
                    List<ICG_Certification__c> certList = returnMap.get(exists);
                    certList.add(cert);
                    returnMap.put(exists,certList);
                }
                else{
                    List<ICG_Certification__c> certList = new List<ICG_Certification__c>();
                    certList.add(cert);
                    returnMap.put(exists,certList);
                }
            }

            return returnMap;
            
        }else {
            Map<Boolean, List<ICG_Certification__c>> returnMap = new Map<Boolean, List<ICG_Certification__c>>();

            returnMap.put(false, allCertifictations);

            return returnMap;
        }
    }

}