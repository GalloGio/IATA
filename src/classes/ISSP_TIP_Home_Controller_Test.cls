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

        AMS_Settlement_System__c as1 = new AMS_Settlement_System__c(name = 'test1', BSP_Billing__c = 'tq');
        insert as1;
      

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID;
        parent.IATACode__c = '1000';
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
        prod.PP_Payment_network__c = 'AX';
        prod.PP_Payment_Product_Code__c = 'aa'; 
        prod.PP_Form_of_payment__c = 'CC';
        prod.Provider__c = parent.id; 
        prod.PP_Category__c = 'CONSUMER'; 
        prod.PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE'; 
        prod.PP_Pay_in_model__c = 'PREPAID';
        prod.PP_Accepted_transactions__c = 'PAYMENT'; 
        prod.PP_VAN_type__c = 'SINGLE_USE_VAN'; 
        prod.PP_Chargeback_airlines__c = 'N'; 
        prod.is_PCI_DSS_required__c = 'YES';
        prod.PP_Chargeback_airlines_duration__c = 1;
        prod.PP_Effective_from_Date__c = Date.newInstance(2019, 2, 2); 
        prod.RecordTypeid = TIP_Utils.PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID; 
        insert prod;
/*
        TIP_BIN_Range__c br = new TIP_BIN_Range__c (TIP_Payment_Provider_Product__c = prod.id, TIP_Status__c = 'DRAFT',
                TIP_Range_Start__c = '111' , TIP_Range_End__c = '222');
            
        insert br;

         TIP_BIN_Range__c br1 = new TIP_BIN_Range__c (TIP_Payment_Provider_Product__c = prod.id, TIP_Status__c = 'DRAFT',
                TIP_Range_Start__c = '333' , TIP_Range_End__c = '999'); 
        insert br1;*/

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
        Portal_Applications__c pa = new Portal_Applications__c(name = TIP_Utils.PORTAL_SERVICE_NAME_TIP);
        insert pa;

        Portal_Application_Right__c appRight = new Portal_Application_Right__c (
            Right__c = 'Access Granted', Contact__c = user.ContactId, Portal_Application__c = pa.id);
        insert appRight;

        System.runAs(user){
            insert newCase;
            PageReference pageRef = Page.ISSP_TIP_Home;
            Test.setCurrentPage(pageRef);
            controller = new ISSP_TIP_Home_Controller();
            //system.debug('##HERE: ' + [select id,TIP_Status__c  from TIP_BIN_Range__c]);
        }
    }

    @isTest
    static void testGetCases(){

        setupTest();


        List<Case> cases = controller.getCases();
        System.assertEquals(1, cases.size());

        List<ISSP_TIP_Home_Controller.productWrapper> products = controller.products; 
        System.assertEquals(1, products.size());
        controller.initActions();
        
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
            controller.saveAccountEnrolmentAsDraft();
            controller.cancelNewEditProd();

        //}
    } 

    @isTest
    static void testbinRanges(){
        
        setupTest();
        controller.NewEditProduct();

        ID prodid = [Select id from Partner_products__c limit 1].id;
        TIP_BIN_Range__c br = new TIP_BIN_Range__c (TIP_Payment_Provider_Product__c = prodid, TIP_Status__c = 'DRAFT',
                TIP_Range_Start__c = '111' , TIP_Range_End__c = '222');
            
        insert br;

         TIP_BIN_Range__c br1 = new TIP_BIN_Range__c (TIP_Payment_Provider_Product__c = prodid, TIP_Status__c = 'DRAFT',
                TIP_Range_Start__c = '333' , TIP_Range_End__c = '999'); 
        insert br1;

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

        controller.changePaymentNetwork();

        //controller.paymentNetworkMap;

        controller.cancelNewEditProd();

        System.currentPageReference().getParameters().put('binRangeRecPos', '0');
        controller.deleteBinRange();
        system.assertEquals(0, controller.binRangeList.size());
    }

    @isTest
    static void testCreateNewContact(){
        setupTest();
        System.runAs(user){
            controller.getISOCountry();
            controller.setContactToEdit();
            controller.newContact.lastName='testLastName';
            controller.newContact.Email = 'Test@test11.com';            
            controller.createContact();

            system.assertEquals(1,[select id from contact].size());//fail to create due duplicate email

            controller.newContact.Email = 'test@test1233.com';            
            controller.createContact();//create email
            system.assertEquals(2,[select id from contact].size());

            //controller.saveAccountEnrolmentAsDraft();
        }
    }

    //------------------------------test for enrolment methods-------------------
    @isTest
    static void testEditContact(){
        setupTest();
        System.runAs(user){
            Apexpages.currentPage().getParameters().put('contactIDToEdit',[select id from contact limit 1].id);
            controller.startEnrolmentAccount();
            controller.setContactToEdit();
            controller.newContact.lastName='testLastName';
            controller.newContact.Email = 'test@test333.com';            
            controller.createContact();//create email
            system.assertEquals(1,[select id from contact].size());
            
            //controller.saveAccountEnrolmentAsDraft();
        }
    }

   

    @isTest
    static void testsaveAccountEnrolmentAsDraft(){
        setupTest();
        System.runAs(user){
            
            controller.saveAccountEnrolmentAsDraft();
            system.assertEquals(2,[select id from case].size());
            
            //controller.saveAccountEnrolmentAsDraft();
        }
    }

    @isTest
    static void testsubmitAccountEnrolmentToIATA(){
        setupTest();
        System.runAs(user){
            controller.startEnrolmentAccount();
            //legal name missing
            controller.account.Name='';
            controller.submitAccountEnrolmentToIATA();
            controller.account.Name='acc1';

            //Office Phone missing
            controller.account.PhoneNational__c=null;
            controller.submitAccountEnrolmentToIATA();
            controller.account.PhoneNational__c='123123123';

            //Office email missing
            controller.account.Email__c=null;
            controller.submitAccountEnrolmentToIATA();
            controller.account.Email__c='asdas@asd.pt';

            //BillingCity missing
            controller.account.BillingStreet=null;
            controller.submitAccountEnrolmentToIATA();
            controller.account.BillingStreet='street test';

            //Location of Headquarter missing
            controller.account.BillingCity=null;
            controller.submitAccountEnrolmentToIATA();
            controller.account.BillingCity='city test';

            //Location of Headquarter missing
            controller.account.TIP_HQ_Location__c=null;
            controller.submitAccountEnrolmentToIATA();
            controller.account.TIP_HQ_Location__c=[select id from IATA_ISO_Country__c limit 1].id;

            //Primary contact missing
            controller.contactList.get(0).Primary_Contact__c=false;
            controller.submitAccountEnrolmentToIATA();

            Apexpages.currentPage().getParameters().put('contactIDToEdit',controller.contactList.get(0).id);
            controller.updateRadioButtonStatus();
            
            controller.contactList.get(0).Primary_Contact__c=true;
            Test.startTest();
            controller.submitAccountEnrolmentToIATA();
            Test.stopTest();
            //controller.saveAccountEnrolmentAsDraft();
        }
    }
    @isTest
    static void testsecurityCheck(){
        setupTest();
        System.runAs(user){
            PageReference pageRef = Page.ISSP_TIP_Home;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('caseId', newCase.id);
            //controller.updateCase();
            controller.saveAccountEnrolmentAsDraft();
            controller.securityCheckForEnrolmentPage();
        }
    }

    @isTest
    static void testCountryConfigs(){
        
        setupTest();
        controller.NewEditProduct();
        //controller.provProdConfList = new list<ISSP_TIP_Home_controller.ProvProdConfigRec>();

        //new prod config
        controller.newEditCountryConfig();
        controller.selectedProvProdConf.action='N';
        controller.selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c = '1';
        controller.selectedProvProdConf.prodConfig.Network_Fee__c = '3';
        controller.selectProvConfigCountriesList = new list<string>();
        system.debug('##list: ' + controller.bspCountrList);
        controller.selectProvConfigCountriesList.add(controller.bspCountrList.get(0).getValue());
        //controller.selectedBinRange.binRange.TIP_Range_Start__c = '111';
        //controller.selectedBinRange.binRange.TIP_Range_End__c = '222';
        controller.addUpdateCountryConfig();
        
        system.assertEquals(1, controller.provProdConfList.size());

        //Edit
        System.currentPageReference().getParameters().put('countryConfigPos', '0');
        controller.newEditCountryConfig();
        
       /* controller.newpp = [Select id,name,PP_Settlement_terms__c,PP_Issuer_name__c,is_PCI_DSS_required__c,PP_Chargeback_airlines__c,PP_Pay_in_model__c,PP_Category__c,PP_Banking_license__c,PP_Payment_network__c,PP_GDS_Integration__c,PP_VAN_type__c,PP_Interchange_fee__c,PP_Payment_guarantee__c,PP_Network_Fee__c,PP_Accepted_transactions__c,PP_Chargeback_airlines_duration__c,Provider__c,PP_status__c,PP_Payment_Product_Network_type__c,  
                                                    (select id,TIP_Range_Start__c,TIP_Range_End__c,TIP_Status__c from BIN_Ranges__r) 
                                                from Partner_products__c limit 1];

*/
        //controller.cancelNewEditProd();

        System.currentPageReference().getParameters().put('countryConfigPos', '0');
        controller.deleteCountryConfig();
        system.assertEquals(0, controller.provProdConfList.size());


        /**/


        controller.NewEditProduct();
        //controller.provProdConfList = new list<ISSP_TIP_Home_controller.ProvProdConfigRec>();

        //new prod config
        System.currentPageReference().getParameters().remove('countryConfigPos');
        controller.newEditCountryConfig();
        controller.selectedProvProdConf.action='N';
        controller.selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c = '1';
        controller.selectedProvProdConf.prodConfig.Network_Fee__c = '3';
        controller.selectProvConfigCountriesList = new list<string>();
        controller.selectProvConfigCountriesList.add(controller.bspCountrList.get(0).getValue());
        //controller.selectedBinRange.binRange.TIP_Range_Start__c = '111';
        //controller.selectedBinRange.binRange.TIP_Range_End__c = '222';
        controller.addUpdateCountryConfig();
        controller.provProdConfList.get(0).isSelected = true;
        system.assertEquals(1, controller.provProdConfList.size());
        controller.deleteMassCountryConfig();
        system.assertEquals(0, controller.provProdConfList.size());
    }

    @isTest
    static void testsubmitProduct(){

        setupTest();
        TIP_Payment_Network_Config__c paymentNetworkConfig = new TIP_Payment_Network_Config__c(Name = 'Amex Config', Maximum_Length__c = 15,
            Payment_Network__c = 'AX');
        insert paymentNetworkConfig;


        ID prodid = [Select id from Partner_products__c limit 1].id;
        System.currentPageReference().getParameters().put('prodId',prodid);
        controller.NewEditProduct();

    
        controller.acceptedTransactionVal = new String[]{'Payment'} ;
        controller.paymentGuaranteeVal = new String[]{'COMMERCIAL_DISPUTE'};
        controller.submitProduct();

    
        
        system.assertEquals(1, Apexpages.getMessages().size());

        controller.newpp.PP_Settlement_terms__c = '2';
        controller.submitProduct();


        //new bin range
        controller.newEditBinRange();
        controller.selectedBinRange.binRange.TIP_Range_Start__c = '111';
        controller.selectedBinRange.binRange.TIP_Range_End__c = '222';
        controller.addUpdateBinRange();

        controller.submitProduct();

        System.currentPageReference().getParameters().put('binRangeRecPos', '0');
        controller.newEditBinRange();
        controller.selectedBinRange.binRange.TIP_Range_Start__c = '111111111111111';
        controller.selectedBinRange.binRange.TIP_Range_End__c = '222222222222222';
        controller.addUpdateBinRange();
        system.debug('##bin ranges: ' + controller.binRangeList);
        controller.submitProduct();

        controller.newEditCountryConfig();
        controller.selectedProvProdConf.action='N';
        controller.selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c = '1';
        controller.selectedProvProdConf.prodConfig.Network_Fee__c = '3';
        controller.selectProvConfigCountriesList = new list<string>();
        system.debug('##list: ' + controller.bspCountrList);
        controller.selectProvConfigCountriesList.add(controller.bspCountrList.get(0).getValue());
        //controller.selectedBinRange.binRange.TIP_Range_Start__c = '111';
        //controller.selectedBinRange.binRange.TIP_Range_End__c = '222';
        controller.addUpdateCountryConfig();
        system.assertEquals(1, controller.provProdConfList.size());
        
        controller.submitProduct();
    }

    @isTest
    static void testAcceptTermsAndConditions(){
        setupTest();

        controller.rejectTerms();
        Portal_Application_Right__c ar = [SELECT Terms_Acceptance__c FROM Portal_Application_Right__c LIMIT 1];
        System.assertEquals(ar.Terms_Acceptance__c, false);

        controller.acceptTerms();
        system.assertEquals(1, Apexpages.getMessages().size());

        controller.acceptedTaC = true;
        controller.acceptTerms();
        ar = [SELECT Terms_Acceptance__c FROM Portal_Application_Right__c LIMIT 1];
        System.assertEquals(ar.Terms_Acceptance__c, true);
        
    }
}
