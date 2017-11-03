/**
    Helper class 
**/
public without sharing class E2CPFieldAccess {

    private Case cse;

    public E2CPFieldAccess(Id caseId) {
        try {
            this.cse = [
                SELECT Id, E2CP__AdditionalBCC__c, E2CP__AdditionalCC__c, E2CP__AdditionalTo__c
                FROM Case
                WHERE Id = :caseId];
        } catch(Exception e) {
            System.debug('ERROR in E2CPFieldAccess caseId ' + caseId + ': ' + e.getMessage());
        }
    }

    public String getAdditionalCC() {
        if (this.cse==null) return '';
        String value = this.cse.E2CP__AdditionalCC__c;
        return value==null? '': value;
    }
    
    public void setAdditionalCC(String value) {
        if (this.cse==null) return;
        this.cse.E2CP__AdditionalCC__c = value;
        update this.cse;
    }
}