public with sharing class CaseValidationDueDiligenceForAP {

    public static final Id RT_INTERNAL_CASE_ID = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('InternalCasesEuropeSCE').getRecordTypeId();
    public String message {get;set;}
    public Boolean doRefresh {get;set;}
    private Case cse;

    /**
        controller
        Populates the message variable with an error if the Due Diligence validation fails
    **/
    public CaseValidationDueDiligenceForAP(ApexPages.StandardController stdController) {
        this.cse = [
            SELECT Id, CaseArea__c, Reason1__c, Classification__c, Type, Case_Remarks__c, RecordtypeId,
                Account.Date_of_last_clearance__c, Account.Clearance_level__c,
                (SELECT Id FROM Cases
                WHERE RecordTypeId = :RT_INTERNAL_CASE_ID
                AND CaseArea__c = 'Corporate Compliance')
            FROM Case
            WHERE Id = :stdController.getId()];
        
        this.doRefresh = false;
        try {
            CaseDueDiligence.validate(this.cse, this.cse.Account);
        } catch(Exception e) {
            //Ignore message if there is an internal case with Case area = Corporate Compliance
            if (this.cse.Cases.isEmpty()) {
                this.message = e.getMessage();
            }
        }
    }

    /**
        Update the case remarks field if there is an error message to show
        Also tells the page if a refresh is required to show this change
    **/
    public void updateCase() {
        if (!String.isBlank(this.message) && this.cse.Case_Remarks__c != this.message) {
            this.cse.Case_Remarks__c = this.message;
            update this.cse;
            this.doRefresh = true;
        }
    }
}