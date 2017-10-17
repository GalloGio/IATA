@isTest
private class vfIECEBC_ReportList_Test {
    
    @isTest static void test_method_one() {
         Account myAcct  = new Account (
            name = 'testaccoppclone', 
            site = 'test',
            BillingCity='test',
            BillingCountry='Canada', 
            type='IATA Passenger Sales Agent', 
            Location_Type__c='BR'
        );
        Insert myAcct;
        
        //Create a zuora business account
        Zuora__CustomerAccount__c myBillingAcct = new Zuora__CustomerAccount__c(
            name = myAcct.name,
            Zuora__Account__c = myAcct.Id,
            Zuora__Zuora_Id__c = '12345678901234567890123456789012'
        );
        Insert myBillingAcct;
        
       EBC_Campaign__c camp = new EBC_Campaign__c();
        camp.Name = 'Foo Bar';
        camp.Subject__c = 'Foo Subject';
        camp.From_Name__c = 'Foo From Name';
        camp.Is_Google_Analytics_Tracker_Active__c = true;
        camp.Google_Analytics_Tracking_Code__c = 'UA-XXXXXX';
        //camp.EBC_Master_Filter__c = masterFilter.Id;
        //camp.EBC_Design__c = tpl.Id;
        camp.Scheduled_Date__c = DateTime.now().addMonths(-1);
        //camp.Activity_Type__c = 'Sent';
        camp.Status__c = 'SENT';
        insert camp;
        PageReference pageRef = Page.IECEBC_Reports;
        Test.setCurrentPageReference(pageRef);
        vfIECEBC_ReportList controller = new vfIECEBC_ReportList();
        controller.getCampaigns();
    }   
}