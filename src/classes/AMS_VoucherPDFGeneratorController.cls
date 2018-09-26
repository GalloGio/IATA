public with sharing class AMS_VoucherPDFGeneratorController {

    public List<AMS_Voucher__c> vouchersToPrintList{get;set;}

    public Integer runExec {get;set;}

    public String runId {get;set;}

    public AMS_VoucherPDFGeneratorController() {
        
        getParametersFromBatch();

        vouchersToPrintList = new List<AMS_Voucher__c>();
        
        fetchVouchersInfo();
    }

    public void getParametersFromBatch(){

        runId  = (String)JSON.deserialize(ApexPages.currentPage().getParameters().get('runId'), String.class);
        
        runExec = (Integer)JSON.deserialize(ApexPages.currentPage().getParameters().get('runExec'), Integer.class);

        System.debug('AMS_VoucherPDFGeneratorController Fetching process vars: runId is '+runId + ' and runExec is ' + runExec);

    }

    public void fetchVouchersInfo(){
        
            System.debug('AMS_VoucherPDFGeneratorController CPU time is ' + Limits.getCpuTime() + '(1)');
        
            this.vouchersToPrintList =  [SELECT id, Name, Voucher_Information__r.Year__c, SequenceNumber__c,Voucher_Information__r.Account__r.IATACode__c, Voucher_Information__r.Account__r.Name ,Voucher_Information__r.Account__r.BillingStreet, Voucher_Information__r.Account__r.BillingCity, Voucher_Information__r.Account__r.BillingPostalCode, Voucher_Information__r.Account__r.BillingState, Voucher_Information__r.Account__r.BillingCountry  FROM AMS_Voucher__c WHERE AMS_Voucher_Process_Run__c = :runId and runExecution__c = :runExec order by name];
            
            System.debug('AMS_VoucherPDFGeneratorController CPU time is ' + Limits.getCpuTime() + '(2)');
        
            System.debug('AMS_VoucherPDFGeneratorController The size to print is ' + vouchersToPrintList);
    }


}