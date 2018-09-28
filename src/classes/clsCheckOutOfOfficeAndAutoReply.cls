public with sharing class clsCheckOutOfOfficeAndAutoReply {

    // Check if the sender address of the case is contained in the list of excluded sender addresses for a given application
    public static Set<ID> IsFromAddressExcluded(List<Case> aCases, String applicationName){
        
        Set<ID> setCaseIDAddressExcluded = new Set<ID>();
        List <ExcludedEmailFromAddress__c> eList = [SELECT Name From ExcludedEmailFromAddress__c e WHERE e.ApplicationName__c ='ANY' OR e.ApplicationName__c = :applicationName];
        
        for(Case aCase :aCases){
            for (ExcludedEmailFromAddress__c excludedAddress : eList){
                if (aCase.SuppliedEmail != null && aCase.SuppliedEmail.toUpperCase().contains(excludedAddress.Name.toUpperCase())){
                    setCaseIDAddressExcluded.add(aCase.ID);
                }
            }
        }
        return setCaseIDAddressExcluded;
    }
    
    // Check if the subject of the case is contained in the list of excluded subjects for a given application
    public static Set<ID> IsSubjectExcluded(List<Case> aCases, String applicationName){
        
        Set<ID> setCaseIDSujectExcluded = new Set<ID>();
        List <ExcludedCaseSubject__c> eList = [SELECT e.Name From ExcludedCaseSubject__c e WHERE e.Application_Name__c ='ANY' OR e.Application_Name__c   = :applicationName];
        
        for(Case aCase :aCases){
            for (ExcludedCaseSubject__c excludedSubject : eList){
                if (aCase.Subject.toUpperCase().contains(excludedSubject.Name.toUpperCase())){
                    setCaseIDSujectExcluded.add(aCase.ID);
                }   
            }
        }
                    
        return setCaseIDSujectExcluded;
    }
}