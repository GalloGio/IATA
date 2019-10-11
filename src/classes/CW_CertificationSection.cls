public with sharing class CW_CertificationSection {
    @AuraEnabled (cacheable=true)
    public static List<ICG_Certification__c> getCertifications(String certificationType, String certificationName){

        if(String.isNotBlank(certificationType) && String.isNotBlank(certificationName)){
            return [SELECT Id, Description__c, link__c,Name__c,Certification_Type__c,Expiration_Period__c,is_visible__c,Image__c
                        FROM ICG_Certification__c WHERE is_visible__C = TRUE 
                            AND Name__c =: certificationName AND Certification_Type__c =: certificationType];
        }
        else if(String.isNotBlank(certificationType)){
            return [SELECT Id, Description__c, link__c,Name__c,Certification_Type__c,Expiration_Period__c,is_visible__c,Image__c
                        FROM ICG_Certification__c WHERE is_visible__C = TRUE
                            AND Certification_Type__c =: certificationType];
        }
        else if(String.isNotBlank(certificationName)){
            return [SELECT Id, Description__c, link__c,Name__c,Certification_Type__c,Expiration_Period__c,is_visible__c,Image__c
                        FROM ICG_Certification__c WHERE is_visible__C = TRUE
                            AND Name__c =: certificationName];
        }
        else {
            return [SELECT Id, Description__c, link__c,Name__c,Certification_Type__c,Expiration_Period__c,is_visible__c,Image__c
                        FROM ICG_Certification__c WHERE is_visible__C = TRUE];
        }
    }

    @AuraEnabled (cacheable = true)
    public static List<ICG_Account_Role_Detail_Certification__c> getLatestAccountCertifications(){
        return [Select Id, Certification__r.Image__c, Certification__r.Name__c, ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__r.City__c from ICG_Account_Role_Detail_Certification__c order by CreatedDate DESC Limit 5];
    }
}