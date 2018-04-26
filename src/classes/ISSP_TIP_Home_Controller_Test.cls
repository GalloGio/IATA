@isTest
private class ISSP_TIP_Home_Controller_Test{
    
    static User user = new User();
    static Case newCase = new Case();
    static Partner_products__c prod = new Partner_products__c();
    static ISSP_TIP_Home_Controller controller;

    private static void setupTest(){
  
        //create isocountry
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;


      

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.id;
        parent.category__c = TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER;
        insert parent;
        

        //create case
        newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
        newcase.Reason1__c = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT;
        newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS;
        newcase.Status = 'Open';
        newcase.Subject = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER+' - ' + parent.name;
        newCase.Description = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER;
        newcase.Region__c = parent.IATA_ISO_Country__r.region__c;
        newcase.Origin = 'Portal';
        newcase.BSPCountry__c = parent.IATA_ISO_Country__r.Name;
        newcase.Country_concerned_by_the_query__c = parent.IATA_ISO_Country__r.Name;    
        
        
        prod.Name = 'test prod'; 
        prod.PP_Payment_Product_Code__c = 'aa'; 
        prod.PP_Form_of_payment__c = 'CC';
        prod.Provider__c = parent.id; 
        prod.PP_Category__c = 'CONSUMER'; 
        prod.PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE'; 
        prod.PP_Pay_in_model__c = 'PREPAID';
        prod.PP_Accepted_transactions__c = 'PAYMENT'; 
        prod.PP_VAN_type__c = 'SINGLE_USE_VAN'; 
        prod.PP_Chargeback_airlines__c = 'N'; 
        prod.PP_Effective_from_Date__c = Date.newInstance(2019, 2, 2); 
        prod.RecordTypeid = TIP_Utils.PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID; 
        insert prod;

        TIP_BIN_Range__c br = new TIP_BIN_Range__c (TIP_Payment_Provider_Product__c = prod.id, TIP_Status__c = 'DRAFT',
                TIP_Range_Start__c = '111' , TIP_Range_End__c = '222');
            
        insert br;

         TIP_BIN_Range__c br1 = new TIP_BIN_Range__c (TIP_Payment_Provider_Product__c = prod.id, TIP_Status__c = 'DRAFT',
                TIP_Range_Start__c = '333' , TIP_Range_End__c = '999'); 
        insert br1;

        system.debug('##Account: ' + parent);
        //insert contact
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

       user = ISSP_ObjectFactory.createPortalUser(con);
       con.OwnerId = user.Id;
       update con;
       
       System.debug('##newUser Id: ' + user.Id);
       con.OwnerId = user.Id;
       update con;
       
        system.debug('##HERE: ' + [select id, CaseArea__c, reason1__c, AccountId,RecordTypeid,Status from case]);
        System.runAs(user){
            insert newCase;
            controller = new ISSP_TIP_Home_Controller();
            system.debug('##HERE: ' + [select id,TIP_Status__c  from TIP_BIN_Range__c]);
        }
    }

    @isTest
    static void testGetCases(){

        setupTest();


        List<Case> cases = controller.getCases();
        System.assertEquals(1, cases.size());

        List<ISSP_TIP_Home_Controller.productWrapper> products = controller.products; 
        System.assertEquals(1, products.size());
        
    }

    @isTest
    static void testDraftProduct(){
        setupTest();
        controller.acceptedTransactionVal = new String[]{'Payment'} ;
        controller.paymentGuaranteeVal = new String[]{'COMMERCIAL_DISPUTE'};
        System.runAs(user){
            controller.NewEditProduct();
            controller.saveDraft();
        }
    }

    @isTest
    static void testEditProduct(){

        setupTest();

        //System.runAs(user){
            List<selectOption> t = controller.acceptedTransactionsOptList;
            List<selectOption> tt = controller.paymentGuaranteeOptList;

            System.currentPageReference().getParameters().put('prodId', prod.id);
            controller.NewEditProduct();
            controller.saveDraft();
            controller.cancelNewEditProd();

        //}
    } 

    @isTest
    static void testbinRanges(){
        
        setupTest();

        controller.binRangeList = new list<ISSP_TIP_Home_Controller.BinRangeRec>();

        //new bin range
        controller.newEditBinRange();
        controller.selectedBinRange.binRange.TIP_Range_Start__c = '111';
        controller.selectedBinRange.binRange.TIP_Range_End__c = '222';
        controller.addUpdateBinRange();
        
        system.assertEquals(1, controller.binRangeList.size());

        //Edit
        System.currentPageReference().getParameters().put('binRangeRecPos', '0');
        controller.newEditBinRange();
        
        controller.newpp = [Select id,name,PP_Settlement_terms__c,PP_Issuer_name__c,is_PCI_DSS_required__c,PP_Chargeback_airlines__c,PP_Pay_in_model__c,PP_Category__c,PP_Banking_license__c,PP_Payment_network__c,PP_GDS_Integration__c,PP_VAN_type__c,PP_Interchange_fee__c,PP_Payment_guarantee__c,PP_Network_Fee__c,PP_Accepted_transactions__c,PP_Chargeback_airlines_duration__c,Provider__c,PP_status__c,PP_Payment_Product_Network_type__c,  
                                                    (select id,TIP_Range_Start__c,TIP_Range_End__c,TIP_Status__c from BIN_Ranges__r) 
                                                from Partner_products__c limit 1];
        controller.changePaymentNetwork();

        //controller.paymentNetworkMap;

        controller.cancelNewEditProd();

        System.currentPageReference().getParameters().put('binRangeRecPos', '0');
        controller.deleteBinRange();
        system.assertEquals(0, controller.binRangeList.size());
    }
}