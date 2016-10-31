public with sharing class AMS_VoucherPDFGeneratorController {

    public List<AMS_Voucher__c> vouchersToPrintList{get;set;}

    public AMS_VoucherPDFGeneratorController() {
        
        List<String> idsToPrint = getParametersFromBatch();

        vouchersToPrintList = new List<AMS_Voucher__c>();
        
        fetchVouchersInfo(idsToPrint);
    }

    public List<String> getParametersFromBatch(){


        Integer listSize = (Integer)JSON.deserialize(ApexPages.currentPage().getParameters().get('sizeList'), Integer.class);
        
        System.debug('List size is:'+listSize);
        String ids = '';

        for(Integer i=0 ; i < listSize; i++){

            ids += (String)JSON.deserialize(ApexPages.currentPage().getParameters().get('list' + i), String.class);
        }

        System.debug('List of ids is:' + ids);
        return ids.split(';');

    }

    public void fetchVouchersInfo(List<String> idsToPrint){
		if(idsToPrint != null)
	        this.vouchersToPrintList =  [SELECT id, Name, Voucher_Information__r.Year__c, SequenceNumber__c,Voucher_Information__r.Account__r.IATACode__c, Voucher_Information__r.Account__r.Name ,Voucher_Information__r.Account__r.BillingStreet, Voucher_Information__r.Account__r.BillingCity, Voucher_Information__r.Account__r.BillingPostalCode, Voucher_Information__r.Account__r.BillingState, Voucher_Information__r.Account__r.BillingCountry  FROM AMS_Voucher__c WHERE Id in :idsToPrint];
    }


}