public with sharing class SIDRARepaymentInstalmentsController {
    public Case cs {get; set;}
    public list<Repayment_Instalment__c> lstRepaymentInstalments {get; set;}
    public Boolean isEditMode {get; set;}
    public String strAddNewLabel {get{            
            return lstRepaymentInstalments.isEmpty() ? 'Create Repayment Instalments' : 'Add New Payment Instalment';
        } set;}
    public Double totalAmount {get{
            Double total = 0;
            for (Repayment_Instalment__c rpc : lstRepaymentInstalments){
                if (rpc.Instalment_Amount__c != null) {
                    total += rpc.Instalment_Amount__c;
                }
            }
            
            return total;
        } set;}
    public Double netBalance {get{
            Double received = 0;
            for (Repayment_Instalment__c rpc : lstRepaymentInstalments){
                if (rpc.Amount_Received_R_S__c != null) {
                    received += rpc.Amount_Received_R_S__c;
                }
            }
            
            return totalAmount - received;
        } set;}
    public Id rpiIdToDelete {get; set;}
    
    public SIDRARepaymentInstalmentsController (final ApexPages.StandardController controller) {
        if (controller.getRecord().Id != null ) {
            cs = [SELECT Id, Currency__c FROM Case WHERE Id = :controller.getRecord().Id];
            
            // Get the repayment instalments related to this case
            lstRepaymentInstalments = [SELECT Id, Currency__c, Instalment_Amount__c, Payment_Status__c, Due_Date__c, Amount_Received_R_S__c, Reception_Date__c, CreatedDate 
                                        FROM Repayment_Instalment__c 
                                        WHERE Case__c = :cs.Id
                                        ORDER BY CreatedDate ASC, Id ASC];
            
            isEditMode = ApexPages.currentPage().getParameters().get('isEditMode') == 'true' ? true : false;            
        } else {
            lstRepaymentInstalments = new list<Repayment_Instalment__c>();
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
    		for (Repayment_Instalment__c ri : lstRepaymentInstalments) {
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
        if ( rpiIdToDelete != null ) {
            Integer i = 0;
            while (i < lstRepaymentInstalments.size()) {
                if(lstRepaymentInstalments.get(i).Id == rpiIdToDelete) {
                    Repayment_Instalment__c rpi = lstRepaymentInstalments.get(i);
                    lstRepaymentInstalments.remove(i);
                    delete rpi;
                } else {
                    i++;
                }
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR! Invalid Repayment Instalment ID. The operation could not be completed, no record has been deleted.'));
        }
        
    }
    
    public PageReference AddNewPaymentInstalment () {
        try {
        	list<Repayment_Instalment__c> lstRPIToInsert = new list<Repayment_Instalment__c>();
        	
        	if (lstRepaymentInstalments.isEmpty()) {
        		for (Integer i = 1; i < 7; i++) {
        			Repayment_Instalment__c rpi = new Repayment_Instalment__c(Case__c = cs.Id, Instalment_Amount__c = 0, Due_Date__c = Date.today().addMonths(i));
        			lstRPIToInsert.add(rpi);
        		}
        	} else {
            	Repayment_Instalment__c rpi = new Repayment_Instalment__c(Case__c = cs.Id, Instalment_Amount__c = 0, Due_Date__c = Date.today().addMonths(1));
            	lstRPIToInsert.add(rpi);
        	}
        	
            insert lstRPIToInsert;
            
            PageReference curPage = ApexPages.currentPage();
            curPage.getParameters().put('isEditMode','true');
            curPage.setRedirect(true);
            return curPage;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
}