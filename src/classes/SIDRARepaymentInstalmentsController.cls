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
    public Id rpiIdToDelete {get; set;}
    
    public SIDRARepaymentInstalmentsController (final ApexPages.StandardController controller) {
        if (controller.getRecord().Id != null ) {
            cs = [SELECT Id, Currency__c FROM Case WHERE Id = :controller.getRecord().Id];
            
            // Get the repayment instalments related to this case
            lstRepaymentInstalments = [SELECT Id, Currency__c, Amount_Expected__c, Payment_Status__c, Due_Date__c, Amount_Received__c, Date_received__c, CreatedDate 
                                        FROM Case_Detail__c 
                                        WHERE Case__c = :cs.Id
                                        AND RecordTypeId = :RT_REPAYMENT_INSTALMENT.Id
                                        ORDER BY CreatedDate ASC, Id ASC];
            
            isEditMode = ApexPages.currentPage().getParameters().get('isEditMode') == 'true' ? true : false;
        } else {
            lstRepaymentInstalments = new list<Case_Detail__c>();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Case ID'));
        }
    }
    
    
    public void Edit () {
        isEditMode = true;
    }
    
    public PageReference Cancel () {
        PageReference curPage = ApexPages.currentPage();
        curPage.getParameters().put('isEditMode','false');
        curPage.setRedirect(true);
        return curPage;
    }
        
    public PageReference Save () {
        if (netBalance <= 0) {
            for (Case_Detail__c ri : lstRepaymentInstalments) {
                if (ri.Payment_Status__c == 'Pending') {
                    ri.Payment_Status__c = 'Received';
                }
            }
        }
        
        try {
            update lstRepaymentInstalments;
            
            PageReference curPage = ApexPages.currentPage();
            curPage.getParameters().put('isEditMode','false');
            curPage.setRedirect(true);
            return curPage;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
            return null;
        }
        
    }
    
    public void DeleteRpi () {
        if ( rpiIdToDelete == null ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR! Invalid Repayment Instalment ID. The operation could not be completed, no record has been deleted.'));
        }
        for (Integer i=0;i<lstRepaymentInstalments.size();i++) {
            Case_Detail__c rpi = lstRepaymentInstalments.get(i);
            if (rpi.Id == this.rpiIdToDelete) {
                lstRepaymentInstalments.remove(i);
                delete rpi;
                return;
            }
        }
    }
    
    public PageReference AddNewPaymentInstalment () {
        try {
            list<Case_Detail__c> lstRPIToInsert = new list<Case_Detail__c>();
            
            if (lstRepaymentInstalments.isEmpty()) {
                for (Integer i = 0; i < REPAYMENT_INSTALMENTS_QUANTITY; i++) {
                    Case_Detail__c rpi = new Case_Detail__c(
                        Case__c = cs.Id,
                        RecordTypeId = RT_REPAYMENT_INSTALMENT.Id,
                        Amount_Expected__c = 0,
                        Due_Date__c = Date.today().addMonths(i+1)
                    );
                    lstRPIToInsert.add(rpi);
                }
            } else {
                Case_Detail__c rpi = new Case_Detail__c(
                    Case__c = cs.Id,
                    RecordTypeId = RT_REPAYMENT_INSTALMENT.Id,
                    Amount_Expected__c = 0,
                    Due_Date__c = Date.today().addMonths(1)
                );
                lstRPIToInsert.add(rpi);
            }
            
            insert lstRPIToInsert;
            
            PageReference curPage = ApexPages.currentPage();
            curPage.getParameters().put('isEditMode','true');
            curPage.setRedirect(true);
            return curPage;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
}