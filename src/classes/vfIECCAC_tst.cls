/**  
  * Description: This class contains unit tests for the (CheckACode ) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class vfIECCAC_tst {
    private static Product_Category__c oProductCategory;
    private static Product_Information__c oProductInfo;
    private static zqu__ZProduct__c oProduct;
    private static zqu__ProductRatePlan__c oProductRatePlan;
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    private static Zuora__Subscription__c subscription;
    private static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    private static IEC_Subscription_History__c oSubscriptionHist;
    private static Terms_and_Conditions__c oTC;
    
    private static Zuora__CustomerAccount__c oBillingAccount;
    private static Account oAccount;
    private static Contact oContact;

    private static GDP_Products_Account_View__c gdpAccActive;
    private static GDP_Products_Account_View__c gdpAccActiveCASS;
    private static GDP_Products_Account_View__c gdpAccActiveCASS2;
    private static GDP_Products_Account_View__c gdpAccTerminated;
    private static GDP_Reference_Table__c oRefAgencyStatus;
    private static GDP_Reference_Table__c oRefAgencyStatusTerminated;
    private static GDP_Reference_Table__c oRefIncorporationType;
    private static GDP_Reference_Table__c oRefLocationType;
    
    private static Accreditation__c oAccreditation1;
    private static Accreditation__c oAccreditation2;
    //private static IATA_ISO_Country__c iataCountry;
    
    private static IECCustomer currentCustomer;
    
    private static String AGENCY1_NAME = 'Test Agency1';
    private static String AGENCY2_NAME = 'Test Agency2';
    private static String AGENCY3_NAME = 'Test Agency3';
    private static String AGENCY4_NAME = 'Test Agency4';
    
    private static String AGENCY1_CODE = '00123456';
    private static String AGENCY1_CHECK = '6';
    private static String AGENCY1_IATA = '0012345';
    
    private static String AGENCY2_CODE = '64973158';
    private static String AGENCY2_CHECK = '8';
    private static String AGENCY2_IATA = '6497315';

    private static String AGENCY3_CODE = '12345679018';
    private static String AGENCY3_CHECK = '8';
    private static String AGENCY3_IATA = '1234567';
    private static String AGENCY3_IATA8 = '12345678';
    private static String AGENCY3_CASS = '901';
    
    private static String AGENCY4_CODE = '12345679028';
    private static String AGENCY4_CHECK = '8';
    private static String AGENCY4_IATA = '1234567';
    private static String AGENCY4_IATA8 = '12345678';
    private static String AGENCY4_CASS = '902';
    
    static void Init() {
        try {
            System.debug('Unit Test: Start: Init');
    
            oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
            insert oProductCategory;
            
            oProduct = IECTestUtil.CreateSampleProduct('PTST');
            insert oProduct;
            
            oProductInfo = IECTestUtil.CreateSampleProductInfo('PITST', oProductCategory, oProduct);
            oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
            insert oProductInfo;
            
            oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan('PRPTST', false, oProduct);
            insert oProductRatePlan;
            
            oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
            insert oProductRatePlanCharge;
            
            oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
            insert oProductRatePlanInfo;
            
            // create a Terms & Conditions
            oTC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true);
            insert oTC;
            
            currentCustomer = IECCustomer.getCurrentIECCustomer();
            
            // create dummy subscription
            subscription = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
            subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
            insert subscription;
            
            // create dummy subscription charge
            subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
            insert subscriptionCharge;
            
            oSubscriptionHist = IECTestUtil.createSampleSubscriptionHistory(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedContact.Id, subscription.Name, oProductCategory.Id, oProductInfo.Id, oProductRatePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, oTC);
            insert oSubscriptionHist;
    
            // Create a dummy country
            //iataCountry = IECTestUtil.CreateSampleIATAISOCountry();
            //insert iataCountry; 
            
            oRefAgencyStatus = IECTestUtil.createSampleGDPReferenceTableEntry('4', 'Valid');
            insert oRefAgencyStatus;
            
            oRefAgencyStatusTerminated = IECTestUtil.createSampleGDPReferenceTableEntry('0', 'Terminated');
            insert oRefAgencyStatusTerminated;
            
            oRefIncorporationType = IECTestUtil.createSampleGDPReferenceTableEntry('i', 'Incorporated');
            insert oRefIncorporationType;
            
            oRefLocationType = IECTestUtil.createSampleGDPReferenceTableEntry('HO', 'Head Office');
            insert oRefLocationType;
            
            // First create a sample GDP Accounts
            gdpAccActive = IECTestUtil.CreateSampleGDPAccount(AGENCY1_NAME, AGENCY1_CODE, AGENCY1_IATA, AGENCY1_CHECK, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
            insert gdpAccActive;
            gdpAccTerminated = IECTestUtil.CreateSampleGDPAccount(AGENCY2_NAME, AGENCY2_CODE, AGENCY2_IATA, AGENCY2_CHECK, oRefAgencyStatusTerminated, oRefIncorporationType, oRefLocationType);
            insert gdpAccTerminated;
            
            gdpAccActiveCASS = IECTestUtil.CreateSampleGDPAccount(AGENCY3_NAME, AGENCY3_CODE, AGENCY3_IATA, AGENCY3_CHECK, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
            gdpAccActiveCASS.CASS_Number__c = AGENCY3_CASS;
            insert gdpAccActiveCASS;
            gdpAccActiveCASS2 = IECTestUtil.CreateSampleGDPAccount(AGENCY4_NAME, AGENCY4_CODE, AGENCY4_IATA, AGENCY4_CHECK, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
            gdpAccActiveCASS2.CASS_Number__c = AGENCY4_CASS;
            insert gdpAccActiveCASS2;
            
            oAccreditation1 = IECTestUtil.CreateSampleAccreditation(null, gdpAccActiveCASS, 'GDP');
            oAccreditation1.Status__c = oRefAgencyStatus.Id;
            insert oAccreditation1;

            oAccreditation2 = IECTestUtil.CreateSampleAccreditation(null, gdpAccActiveCASS2, 'GDP');
            oAccreditation2.Status__c = oRefAgencyStatus.Id;
            insert oAccreditation2;
            
            gdpAccActiveCASS.Related_Accreditation_Class__c = oAccreditation1.Id;
            update gdpAccActiveCASS;
            
            gdpAccActiveCASS2.Related_Accreditation_Class__c = oAccreditation2.Id;
            update gdpAccActiveCASS2;

            createCACandGADEntry();

        }
        catch (Exception ex) {
            System.debug('SALV - Init - Exception :' + ex.getMessage());
        }

        System.debug('Unit Test: Finish: Init');
    }
    
    // ====================================================================
    // creates a registry in tha custom setting CAC_and_GAD_Settings__c
    // output: CAC_and_GAD_Settings__c
    // used by testAnonymousSearch
    private static void createCACandGADEntry(){
        Boolean exists = false;

        //fetch the existing entries for this custom setting
        for(CAC_and_GAD_Settings__c cs : CAC_and_GAD_Settings__c.getAll().values()){
            //check if already exists one named Excluded Values
            if(!cs.Name.equals('Excluded Values')){
                exists = true;
            }

        }

        //If does not exist an Excluded Values custom setting creates it
        if(!exists){
            CAC_and_GAD_Settings__c CacGadSettings = new CAC_and_GAD_Settings__c();
            CacGadSettings.Name = 'Excluded Values';
            CacGadSettings.Excluded_CAC_Location_Classes__c = 'A;I;L;Q;R;U;Y;Z';
            CacGadSettings.Excluded_GAD_Location_Classes__c = 'A;I;L;Q;R;U;Y;Z;C;X';

            insert CacGadSettings;
        }

    }

    static testMethod void TestCAC() {
        System.debug('Unit Test: Start: TestCAC');

        //Set current page to CAC
        PageReference pgRef = Page.IECCAC;
        Test.setCurrentPage(pgRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            
            Test.startTest();
                
            // setup data
            Init();

            // trigger the Product Access creation
            update subscription;
                
            Test.stopTest();

            //Instantiate Controller
            vfIECCAC pgCont = new vfIECCAC();
            pgCont.pageLoad();
            
            String productCode = pgCont.sProductCode;
            
            
            system.debug('ALEX - pgCont.ctrSubsInfo.hasPageAccess: ' + pgCont.ctrSubsInfo.hasPageAccess);
            
            //Test 001: Set Validation Code to An Active Agency - Use 7 Digits
            pgCont.sValidationCode = AGENCY1_CODE;//'0012345';
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(true, pgCont.bShowAgency, 'Agency result must be displayed');
            system.assertEquals(gdpAccActive.Id, pgCont.oAgency.Id, 'Agency must be retrieved and match existing Active GDP Account');
    
            //Test 002: Set Validation Code to An Active Agency - Use 8 Digits
            pgCont.sValidationCode = '00123456';
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(pgCont.bShowAgency, true, 'Agency result must be displayed');
            system.assertEquals(pgCont.oAgency.Id, gdpAccActive.Id, 'Agency must be retrieved and match existing Active GDP Account');

            
            //Test CASS code request for 7 digits
            pgCont.sValidationCode = AGENCY3_IATA;
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(true, pgCont.baskCASSCode, 'Multiple agencies with same IATA codes. Requires CASS code to differentiate');
    

            //Test CASS code search for 7 digits
            pgCont.sValidationCode = AGENCY3_IATA;
            pgCont.sCASSCode = AGENCY3_CASS;
            pgCont.validateCode();
            system.assertEquals(pgCont.bShowAgency, true, 'Agency result must be displayed');
            system.assertEquals(pgCont.oAgency.Id, gdpAccActiveCASS.Id, 'Agency must be retrieved and match existing Active GDP Account');

            //Test CASS code request for 8 digits
            pgCont.sValidationCode = AGENCY3_IATA8;
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(pgCont.baskCASSCode, true, 'Multiple agencies with same IATA codes. Requires CASS code to differentiate');

            //Test CASS code search for 8 digits
            pgCont.sValidationCode = AGENCY3_IATA8;
            pgCont.sCASSCode = AGENCY3_CASS;
            pgCont.validateCode();
            
           system.assertEquals(pgCont.bIsValid, true, 'Agency result must be displayed');
           system.assertEquals(pgCont.oAgency.Id, gdpAccActiveCASS.Id, 'Agency must be retrieved and match existing Active GDP Account');

            //Test code search for 11 digits
           pgCont.sValidationCode = AGENCY4_CODE;
           pgCont.sCASSCode = '';
           pgCont.validateCode();
           system.assertEquals(pgCont.bIsValid, true, 'Agency result with 11 digits code');
           // SALVATORE 22 12 2014 DUE TO HOTFIX DURING XMAS BREAK PLEASE CONTAT ME IF NEEDED  
           system.assertEquals(pgCont.oAgency.Id, gdpAccActiveCASS2.Id, 'Agency must be retrieved and match existing Active GDP Account');
           
        }
        System.debug('Unit Test: Finish: TestCAC');
    }

    static testMethod void TestCAC_Errors() {
        System.debug('Unit Test: Start: TestCAC_Errors');

        //Set current page to CAC
        PageReference pgRef = Page.IECCAC;
        Test.setCurrentPage(pgRef);
        
        //Instantiate Controller
        vfIECCAC pgCont = new vfIECCAC();

        // Test 001: Accessing page as guest user
        pgCont.pageLoad();

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            
            Test.startTest();
                
            // setup data
            Init();

            // trigger the Product Access creation
            update subscription;
                
            Test.stopTest();

            //Instantiate Controller
            pgCont = new vfIECCAC();
            pgCont.pageLoad();

            /*
            //Instantiate Controller
            IECPageController baseCont = new IECPageController();
            baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
            pgCont = new vfIECCAC();

            // Test 002: Accessing page with no subscription for CAC
            pgCont.pageLoad();
            //system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_No_Application_Access));
            
            // Initialize Data for test scenario
            Init();
            */

            //Test 003: Set Validation Code to an alphanumeric code
            pgCont.sValidationCode = '6ab98713';
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(pgCont.bshowInvalidCode, true, 'The code is invalid');
            
                    
            //Test 004: Set Validation Code to an invalid code length (5 digits)
            pgCont.sValidationCode = '68713';
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(pgCont.bshowInvalidCode, true, 'The code is invalid');
                    
            //Test 005: Set Validation Code to a non-existing Agency
            pgCont.sValidationCode = '65498713';
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(pgCont.bIsValid, false, 'There is no result');
           
    
            //Test 006: Set Validation Code to a terminated Agency
            pgCont.sValidationCode = '64973158';
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(pgCont.bIsValid, false, 'There is no result');
            
            //Test 007: Set Validation Code to a non-existing Agent
            pgCont.sValidationCode = '6549871301';
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(pgCont.bIsValid, false, 'There is no result');

            //Test 008: Set Validation Code to a non-existing Agent
            pgCont.sValidationCode = '1234567890';
            pgCont.sCASSCode = '';
            pgCont.validateCode();
            system.assertEquals(pgCont.bIsValid, false, 'There is no result');
        }

        System.debug('Unit Test: Finish: TestCAC_Errors');
    }
}