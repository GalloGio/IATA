public with sharing class SIDRARepaymentInstalmentsController {
    public static final RecordType RT_REPAYMENT_INSTALMENT =
        [SELECT Id FROM RecordType WHERE sObjectType='Case_Detail__c' AND DeveloperName='Repayment_Instalment'];
    public static final Integer REPAYMENT_INSTALMENTS_QUANTITY = 6;

    public Case cs {get; set;}
    public list<Case_Detail__c> lstRepaymentInstalments {get; set;}
    public Boolean isEditMode {get; set;}
    public String strAddNewLabel {get{
            return lstRepaymentInstalments.isEmpty() ? 'Create Repayment Instalments' : 'Add New Payment Instalment';
        } set;}
    public Double totalAmount {get{
            Double total = 0;
            for (Case_Detail__c rpc : lstRepaymentInstalments){
                if (rpc.Amount_Expected__c != null) {
                    total += rpc.Amount_Expected__c;
                }
            }
            
            return total;
        } set;}
    public Double netBalance {get{
            Double received = 0;
            for (Case_Detail__c rpc : lstRepaymentInstalments){
                if (rpc.Amount_Received__c != null) {
                    received += rpc.Amount_Received__c;
                }
            }
            
            return totalAmount - received;
        } set;}
    public Integer rpiIndexToDelete {get; set;}
    
    public SIDRARepaymentInstalmentsController (final ApexPages.StandardController controller) {
        if (controller.getRecord().Id != null ) {
            this.cs = [SELECT Id, Currency__c FROM Case WHERE Id = :controller.getRecord().Id];
            this.lstRepaymentInstalments = getListInstalments(this.cs.Id);
            this.isEditMode = ApexPages.currentPage().getParameters().get('isEditMode') == 'true';
            
        } else {
            lstRepaymentInstalments = new list<Case_Detail__c>();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Case ID'));
        }
    }
    
    /**
        Get the repayment instalments related to this case
    **/
    private static list<Case_Detail__c> getListInstalments(Id caseId) {
        return [
            SELECT Id, Currency__c, Amount_Expected__c, Payment_Status__c, Due_Date__c, Amount_Received__c, Date_received__c, CreatedDate 
            FROM Case_Detail__c 
            WHERE Case__c = :caseId
            AND RecordTypeId = :RT_REPAYMENT_INSTALMENT.Id
            ORDER BY CreatedDate ASC, Id ASC];
    }
    
    /**
        Go to edit mode
    **/
    public void Edit () {
        this.isEditMode = true;
    }
    
    /**
        Goes back to not edit mode
    **/
    public PageReference Cancel () {
        this.lstRepaymentInstalments = getListInstalments(this.cs.Id);
        this.isEditMode = false;
        return null;
    }
    
    /**
        Save current repayment records, updating the status field
        returns to page in edit mode
    **/
    public PageReference Save () {
        if (netBalance <= 0) {
            for (Case_Detail__c ri : lstRepaymentInstalments) {
                if (ri.Payment_Status__c == 'Pending') {
                    ri.Payment_Status__c = 'Received';
                }
            }
        }
        
        try {
            upsert lstRepaymentInstalments;
            this.isEditMode = false;
            
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
        }
        return null;
    }
    
    /**
        Removes selected repayment record from the list
        If the record has an id then delete from the database as well
    **/
    public void DeleteRpi () {
        try {
            Case_Detail__c instalmentToDelete = this.lstRepaymentInstalments.remove(this.rpiIndexToDelete);
            if (instalmentToDelete.Id != null) {
                delete instalmentToDelete;
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR! Invalid Repayment Instalment index. The operation could not be completed, no record has been deleted.'));
        }
    }
    
    /**
        Add repaymnet records to current case, first time 6 records,
        and one more each subsequent time
    **/
    public void AddNewPaymentInstalment () {
        try {
            this.lstRepaymentInstalments = getListInstalments(this.cs.Id);
            
            //if there are no instalment by default we create 6, but if thery 
            //were already created then add 1 more
            Integer quantityToCreate = lstRepaymentInstalments.isEmpty()? REPAYMENT_INSTALMENTS_QUANTITY: 1;
            for (Integer i = 1; i <= quantityToCreate; i++) {
                Case_Detail__c rpi = new Case_Detail__c(
                    Case__c = cs.Id,
                    RecordTypeId = RT_REPAYMENT_INSTALMENT.Id,
                    Amount_Expected__c = 0,
                    Due_Date__c = Date.today().addMonths(i+1)
                );
                this.lstRepaymentInstalments.add(rpi);
            }
            this.isEditMode = true;
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

    public Boolean getIsUpdateable() {
        return Schema.sObjectType.Case_Detail__c.isUpdateable();
    }
    
    public Boolean getIsDeletable() {
        return Schema.sObjectType.Case_Detail__c.isDeletable();
    }
    
    public Boolean getIsCreateable() {
        return Schema.sObjectType.Case_Detail__c.isCreateable();
    }
}