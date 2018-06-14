public with sharing class clsCheckOutOfOfficeAndAutoReply {

    // Check if the sender address of the case is contained in the list of excluded sender addresses for a given application
    public static boolean IsFromAddressExcluded(Case aCase, String applicationName){
        
        List <ExcludedEmailFromAddress__c> eList = [SELECT Name From ExcludedEmailFromAddress__c e WHERE e.ApplicationName__c ='ANY' OR e.ApplicationName__c = :applicationName];
        
        for (ExcludedEmailFromAddress__c excludedAddress : eList){
            if (aCase.SuppliedEmail != null && aCase.SuppliedEmail.toUpperCase().contains(excludedAddress.Name.toUpperCase())){
                return true;
            }
        }
        return false;
    }
    
    // Check if the subject of the case is contained in the list of excluded subjects for a given application
    public static boolean IsSubjectExcluded(Case aCase, String applicationName){
        
        List <ExcludedCaseSubject__c> eList = [SELECT e.Name From ExcludedCaseSubject__c e WHERE e.Application_Name__c ='ANY' OR e.Application_Name__c   = :applicationName];
        
        //if(aCase != null && eList.size() > 0){
            for (ExcludedCaseSubject__c excludedSubject : eList){
                //if(excludedSubject != null){
                    if (aCase.Subject.toUpperCase().contains(excludedSubject.Name.toUpperCase())){
                    return true;
                    }   
               // }
                
            }
        //}
        
        return false;
    }
}