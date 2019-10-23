//  ================================================================================================
//||
//||
//||        created by: Pedro Fartaria
//||        created Date : Feb 2019
//||        Purpose: Wrapper class to send selectOption between apex and aura/lwc
//||        NOTE: No similar behaviour at development time
//||
//||
//   ================================================================================================



public with sharing class SelectOptionWrapper {
    @AuraEnabled
    public String label {get;set;}
    
    @AuraEnabled
    public String value {get;set;}

    public SelectOptionWrapper(String value, String label) {
        this.value = value;
        this.label = label;
    }
}
