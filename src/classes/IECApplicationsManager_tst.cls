/**
 * This class contains unit tests for validating the behavior of class IECApplicationsManager
 * Change log:
 *  20160415-sl: bug fix, split testCustomerSearch into 4 test methods and move shared data preparation out
 *  20160603-sl: add test method for testing isEbcAccessGrantedFoContact
 *  20160803-sl: merge code from Ebroadcast old repository to new repository (20160728 version)
 * 
 */
@isTest
private class IECApplicationsManager_tst {
    private static User oCommunityUser; 
    private static Product_Category__c oProductCategory;
    private static Product_Information__c oProductInfo;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    private static Terms_and_Conditions__c oTC;
    private static zqu__ZProduct__c oProduct;
    private static zqu__ProductRatePlan__c oProductRatePlan;
    private static Zuora__Subscription__c oSubscription;
    private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge;
    private static IEC_Subscription_History__c oSubscriptionHist;
    private static Account oAccount;
    private static Account oAgencyAccount;
    private static Zuora__CustomerAccount__c oBillingAccount;
    private static Contact oContact;
    private static Date dtSubscriptionEnddate;
    private static ID_Card__c oIDCard;
    
    private static GDP_Reference_Table__c oRefAgencyStatus;
    private static GDP_Reference_Table__c oRefIncorporationType;
    private static GDP_Reference_Table__c oRefLocationType;
    private static GDP_Products_Account_View__c oGDPAccount1;
    private static GDP_Products_Account_View__c oGDPAccount2;
    private static GDP_Products_Account_View__c oGDPAccount3;
    private static Accreditation__c oAccreditation1;
    private static Accreditation__c oAccreditation2;
    private static Accreditation__c oAccreditation3;
    
    private static final Integer SUB_USAGE_QTY = 42;
    private static final String AGENCY1_CODE = '55555';
    private static final String AGENCY2_CODE = '66666';
    private static final String AGENCY3_CODE = '77777';
    private static final String AGENT_VER_NUMBER = '5578000523';
    private static final String AGENCY_CHECK_DIGIT = '9';
    private static final String AGENCY1_NAME = 'Chillwave Agency';
    private static final String AGENCY2_NAME = 'Chilly Cheese Agency';
    private static final String AGENCY3_NAME = 'Kashmir Coats';
    private static final String AREA_OF_ACTIVITY = 'My Area of Activity';
    
    
    // ========================================================================
    // setupData will create and insert Product, Agency, and required records
    // and they will be stored as class variable
    //   oProduct, oProductInfo, oProductRatePlan, oTC, oRefAgencyStatus, oRefIncorporationType, oRefLocationType
    //   oAgencyAccount, oGDPAccount1, oGDPAccount2, oGDPAccount3, oIDCard
    //   oAccreditation1, oAccreditation2, oAccreditation3
    //
    // In addition the following record is inserted: agencyPassengerClass
    //
    // no input or other variable is used.
    static void setupData() {
        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
        insert oProductCategory;
        
        oProduct = IECTestUtil.CreateSampleProduct('PTST');
        insert oProduct;
        
        oProductInfo = IECTestUtil.CreateSampleProductInfo('PITST', oProductCategory, oProduct);
        oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
        insert oProductInfo;
        
        oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan('PRPTST', false, oProduct);
        insert oProductRatePlan;
        
        oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
        oProductRatePlanInfo.Display_As_Monthly_Fee__c = true;
        oProductRatePlanInfo.Subscription_Usage_Qty__c = SUB_USAGE_QTY;
        insert oProductRatePlanInfo;
        
        // create a Terms & Conditions
        oTC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true);
        insert oTC;
        
        oRefAgencyStatus = IECTestUtil.createSampleGDPReferenceTableEntry('4', 'Valid');
        insert oRefAgencyStatus;
        
        oRefIncorporationType = IECTestUtil.createSampleGDPReferenceTableEntry('i', 'Incorporated');
        insert oRefIncorporationType;
        
        oRefLocationType = IECTestUtil.createSampleGDPReferenceTableEntry('HO', 'Head Office');
        insert oRefLocationType;
        
        Id rtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        oAgencyAccount = IECTestUtil.createSampleAccount();
        oAgencyAccount.Name = AGENCY1_NAME;
        oAgencyAccount.IATACode__c = AGENCY1_CODE;
        oAgencyAccount.Status__c = 'Approved';
        oAgencyAccount.RecordTypeId = rtypeId;
        insert oAgencyAccount;
        
        // create GDP_Products_Account_View records 
        oGDPAccount1 = IECTestUtil.createSampleGDPAccount(AGENCY1_NAME, AGENCY1_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
        oGDPAccount1.Check_Digit__c = AGENCY_CHECK_DIGIT;
        
        oGDPAccount2 = IECTestUtil.createSampleGDPAccount(AGENCY2_NAME, AGENCY2_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
        oGDPAccount3 = IECTestUtil.createSampleGDPAccount(AGENCY3_NAME, AGENCY3_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
        
        List<GDP_Products_Account_View__c> lstGDPAccounts = new List<GDP_Products_Account_View__c> { oGDPAccount1, oGDPAccount2, oGDPAccount3 };
        insert lstGDPAccounts;
        
        // create ID_Card records
        oIDCard = IECTestUtil.createSampleIDCard('John', 'Doe', AGENT_VER_NUMBER, AGENCY1_NAME, AGENCY1_CODE, 'Valid ID Card');
        oIDCard.Valid_To_Date__c = Date.today().addYears(1);
        oIDCard.Valid_From_Date__c = Date.today();
        insert oIDCard;
        
        //add accreditation class  for the Accreditation record
        GDP_Reference_Table__c oAgencyPassengerClass =  IECTestUtil.createSampleGDPReferenceTableEntry('P', 'Passenger');
        oAgencyPassengerClass.Code__c = 'P';
        oAgencyPassengerClass.Name = 'Passenger';
        oAgencyPassengerClass.System__c = 'Global';
        oAgencyPassengerClass.Table__c = 'ORGCLASS';
        insert oAgencyPassengerClass;
        
        // insert accreditation records
        oAccreditation1 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount1, 'GDP');
        oAccreditation1.Status__c = oRefAgencyStatus.Id;
        oAccreditation1.Class__c = oAgencyPassengerClass.Id;
        
        oAccreditation2 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount2, 'GDP');
        oAccreditation2.Status__c = oRefAgencyStatus.Id;
        
        oAccreditation3 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount3, 'GDP');
        oAccreditation3.Status__c = oRefAgencyStatus.Id;
        
        List<Accreditation__c> lstAccreditations = new List<Accreditation__c>{oAccreditation1, oAccreditation2, oAccreditation3};
        insert  lstAccreditations;
        
        // GDP_Products_Account_View should have lookup to Accrediation too
        oGDPAccount1.Related_Accreditation_Class__c = oAccreditation1.Id;
        oGDPAccount2.Related_Accreditation_Class__c = oAccreditation2.Id;
        oGDPAccount3.Related_Accreditation_Class__c = oAccreditation3.Id;
        update new List<GDP_Products_Account_View__c> {oGDPAccount1, oGDPAccount2, oGDPAccount3};
    } // end of setupData
    
    // ========================================================================
    // initSubscription will create and insert Subscription and required records
    // and they will be stored as class variable
    // oAccount, oContact, oBillingAccount, oSubscription, oSubscriptionCharge, oSubscriptionHist
    // In addition: local oProductAccess is created and inserted.
    // no input or other variable is used.
    private static void initSubscription(){
        
        oAccount = IECTestUtil.createSampleAccount();
        insert oAccount;
        
        oContact = IECTestUtil.createSampleContact(oAccount);
        insert oContact;
        
        oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
        oBillingAccount.Contact__c = oContact.Id;
        insert oBillingAccount;
        
        dtSubscriptionEnddate = Date.today().addMonths(6);
        
        oSubscription = IECTestUtil.createSampleSubscription(oAccount.Id, 'Subs 01', dtSubscriptionEnddate);
        oSubscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
        oSubscription.Zuora__CustomerAccount__c = oBillingAccount.Id;
        insert oSubscription;
        
        // create dummy subscription charge
        oSubscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(oSubscription.Id, dtSubscriptionEnddate.addYears(-1).addDays(1), oProduct, oProductRatePlan);
        insert oSubscriptionCharge;
        
        oSubscriptionHist = IECTestUtil.createSampleSubscriptionHistory(oAccount.Id, oContact.Id, oSubscription.Name, oProductCategory.Id, oProductInfo.Id, oProductRatePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, oTC);
        insert oSubscriptionHist;
        
        // insert Product Access for oContact for oSubscription and its Product Rate Plan
        IEC_Product_Access__c oProductAccess = new IEC_Product_Access__c(
                Related_Contact__c = oContact.Id
                , Zuora_Subscription_Id__c = oSubscription.Zuora__Zuora_Id__c
                , Subscription_Number__c = oSubscription.Name
                , Related_Rate_Plan_Info__c = oSubscription.Product_Rate_Plan_Information__c 
                , Usage_Qty_Start__c = 100
                , Usage_Qty_Left__c = 100
                , Usage_Qty_consumed__c = 0
                , Usage_Unlimited__c = false
                , Invoice_Number__c = 'INV-0001'
                , Active__c = true
                , Effective_Start_Date__c = Date.today()
                , Effective_End_Date__c = Date.today().addYears(1)
            );
        insert oProductAccess;
        
    } // initSubscription
    
    // ====================================================================
    // initialization for test customer search functionality
    // output: oContact, oCommunityUser: test community user
    // used by testCustomerSearch1,2,3
    private static void initDataForCustomerSearch()
    {
        setUpData();
        
        System.assertNotEquals(null, oRefAgencyStatus, 'oRefAgencyStatus should have been created by setupData');
        System.assertNotEquals(null, oRefIncorporationType, 'oRefIncorporationType should have been created by setupData');
        System.assertNotEquals(null, oRefLocationType, 'oRefLocationType should have been created by setupData');
        System.assertNotEquals(null, oGDPAccount1, 'oGDPAccount1 should have been created by setupData');
        System.assertNotEquals(null, oAccreditation1, 'oAccreditation1 should have been created by setupData');
        System.assertNotEquals(null, oIDCard, 'oIDCard should have been created by setupData');
        
        // create oAccount, oContact, oBillingAccount, oSubscription: 
        // required data: oProductRatePlanInfo
        initSubscription();
        
        oCommunityUser = IECTestUtil.createSampleUser(oContact);
    } // initDataForCustomerSearch
    

    // ====================================================================
    // creates a registry in tha custom setting CAC_and_GAD_Settings__c
    // output: CAC_and_GAD_Settings__c
    // used by testAnonymousSearch
    private static void createCACandGADEntry(){
        Boolean exists = false;

        //fetch the existing entries for this custom setting
        for(CAC_and_GAD_Settings__c cs : CAC_and_GAD_Settings__c.getAll().values()){
            //check if already exists one named Excluded Values
            if(cs.Name.equals('Excluded Values')){
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
    
    // ====================================================================
    // test customer search functionality: part 1
    // test the product access consumption
    @isTest(SeeAllData=true)
    static void testCustomerSearch1_Count() {
        initDataForCustomerSearch();

        createCACandGADEntry();
        
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
        List<IEC_Product_Access__c> lstProductAccess = null;
        List<GDP_Products_Account_View__c> lstSearchResult = null;
        ID_Card__c oSearchedIDCard = null;
        Integer iUsageAccess;
        
        Integer initialCount = 0;
        test.startTest();
        System.runAs(oCommunityUser) {
            lstProductAccess = IECApplicationsManager.getListProductAccessByContactByProductCategory(oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
            if (lstProductAccess != null && lstProductAccess.size()>0) {
                initialCount = Integer.valueOf(lstProductAccess.get(0).Usage_Qty_consumed__c);
            }
            
            // Test #2 - search for unknown agency
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByIATACode('4444444', null, null, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            System.debug ('Test 1: lstSearchResult:' + lstSearchResult);
            system.assert(lstSearchResult == null || lstSearchResult.size() == 0, 'No Agency should be found');
            
        }
        test.stopTest();  
        // note that the calculation is done by a future method
        // usage should be consumed (even if no results)
        lstProductAccess = IECApplicationsManager.getListProductAccessByContactByProductCategory(oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
        Integer lastCount = Integer.valueOf(lstProductAccess.get(0).Usage_Qty_consumed__c);
        system.assert(lastCount == initialCount+1, 'Test 2: Product Access should reflect 1 search consumption, initialCount:' + initialCount + ', lastCount:' + lastCount);
    } // testCustomerSearch1_Count
    
    // ====================================================================
    // test customer search functionality: part 2.1
    // customerSearchAgencyByIATACode
    // customerSearchAgentByVER
    @isTest(SeeAllData=true)
    static void testCustomerSearch2() {
        initDataForCustomerSearch();

        createCACandGADEntry();
        
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
        List<IEC_Product_Access__c> lstProductAccess = null;
        List<GDP_Products_Account_View__c> lstSearchResult = null;
        ID_Card__c oSearchedIDCard = null;
        Integer iUsageAccess;
        
        test.startTest();
        System.runAs(oCommunityUser) {
            
            // Test #2 - search for unknown agency
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByIATACode('4444444', null, null, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            System.debug ('Test 2: lstSearchResult:' + lstSearchResult);
            system.assert(lstSearchResult == null || lstSearchResult.size() == 0, 'No Agency should be found');
            
            // usage should be consumed (even if no results)
            lstProductAccess = IECApplicationsManager.getListProductAccessByContactByProductCategory(oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
            
            //futuremethod
            //system.assert(lstProductAccess != null && lstProductAccess.get(0).Usage_Qty_consumed__c == 1, 'Product Access should reflect 1 search consumption');
            
            // Test #3 - search for a known agency
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByIATACode(AGENCY1_CODE, null, null, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            system.assert(lstSearchResult != null, 'Test 3: The Agency List should not be null');
            system.assert(lstSearchResult.size() == 1, 'Test 3: Exactly One Agency should be found instead of ' + lstSearchResult.size() + ' lstSearchResult:' + lstSearchResult);
            
            // usage should be consumed
            lstProductAccess = IECApplicationsManager.getListProductAccessByContactByProductCategory(oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
            
            //system.assert(lstProductAccess != null && lstProductAccess.get(0).Usage_Qty_consumed__c == 2, 'Product Access should reflect 2 search consumption');
            
            // make sure the search was tracked in the global counter
            /* List<IEC_Usage_Tracker_Live__c> lstTracker = 
                [SELECT Counter__c, Search_Status__c, Search_Target__c, Related_Application_Type__c, RelatedContact__c 
                 FROM IEC_Usage_Tracker_Live__c
                 WHERE RelatedContact__c = :oContact.Id
                    AND Search_Status__c = :IECConstants.IECUsageTrackerSearchStatus_Success
                    AND Search_Target__c = :IECConstants.IECUsageTrackerSearchTarget_Agency
                    AND Related_Application_Type__c = :IECConstants.ProductCategory_SF_CACPRO];*/
           // system.assert(lstTracker != null && lstTracker.size() > 0, 'There should be at least 1 IEC_Usage_Tracker_Live__c created');
            
            // Test #4 - search for invalid ID Card
            oSearchedIDCard = IECApplicationsManager.customerSearchAgentByVER('3213211', IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            system.assert(oSearchedIDCard == null, 'The ID Card should not be found for unknown VER number');
            
            // Test #5 - search for valid ID Card
            oSearchedIDCard = IECApplicationsManager.customerSearchAgentByVER(AGENT_VER_NUMBER, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
         //   system.assert(oSearchedIDCard != null, 'The ID Card should be found');
            
            // Test #6 - search for a known agency with a check code
         /*   lstSearchResult = IECApplicationsManager.customerSearchAgencyByIATACode(AGENCY1_CODE, null, AGENCY_CHECK_DIGIT, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            system.assert(lstSearchResult != null, 'Test 6: The Agency List should not be null');
            system.assert(lstSearchResult.size() == 1, 'Test 6: Exactly One Agency should be found instead of ' + lstSearchResult.size() + ':' + lstSearchResult);
            system.assert(lstSearchResult != null && lstSearchResult.size() == 1, 'The Agency should be found');
            */
        }
        test.stopTest();  
    } // testCustomerSearch2
      
    
   
    @isTest(SeeAllData=true)
    static void testCustomerSearch3Pre() {  

        initDataForCustomerSearch();

        createCACandGADEntry();
        //account 3 - start
        List<GDP_Products_Account_View__c> lstSearchResult = null;
        IATA_ISO_Country__c oISOCountry = IECTestUtil.CreateSampleIATAISOCountry();
        insert oISOCountry;
        GDP_Geo_Detail__c oGEODetail = IECTestUtil.CreateSampleGDPGeoDetail(oISOCountry);
        insert oGEODetail;
        /*oGDPAccount3 = IECTestUtil.createSampleGDPAccount(AGENCY1_NAME, AGENCY1_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
        oGDPAccount3.Check_Digit__c = AGENCY_CHECK_DIGIT;

        insert oGDPAccount3;
        */

        /*oAccreditation3 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount3, 'GDP');
        oAccreditation3.Status__c = oRefAgencyStatus.Id;
        insert oAccreditation3;
        oGDPAccount3.Related_Accreditation_Class__c = oAccreditation3.Id;
        update oGDPAccount3;
        */
        //account 3 - end

        GDP_Address__c oGDPAddress3 = IECTestUtil.CreateSampleGDPAddress(oGDPAccount3, oISOCountry, null, oGEODetail);
        oGDPAddress3.Address_Postal_Code__c = 'H0H 0H0';
        oGDPAddress3.Address_Type__c = 'Location';
        oGDPAddress3.Address_City__c = 'BOYA';
        insert oGDPAddress3;


        oGDPAccount3.Related_GDP_Address__c = oGDPAddress3.Id;
        update oGDPAccount3;
        SchdlGDPProductsAccountSnapshotCleanup bat = new SchdlGDPProductsAccountSnapshotCleanup();
        
		/*
		List<GDP_Products_Account_View__c> gpav = Database.query(SchdlGDPProductsAccountSnapshotCleanup.query);
        bat.execute(null, gpav);

        IEC_Application_Filter__c oFilter = new IEC_Application_Filter__c();
        oFilter.Zip_Code__c = '0H 0';
        oFilter.City__c = oGDPAddress3.Address_City__c;
        oFilter.Sub_Continent__c = oGEODetail.Sub_Continent__c;
        oFilter.Country__c = oGDPAddress3.Address_ISO_Country_Code__c;


        System.runAs(oCommunityUser) {

            lstSearchResult = IECApplicationsManager.customerSearchAgencyByAdvancedFilters(oFilter, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());

            system.assert(lstSearchResult != null && lstSearchResult.size() == 1 && oGDPAccount3.Id == lstSearchResult.get(0).Id, 'The Agency #3 should be found based on the zip/postal code');
            // 
            // Test #11 - search by agency trade name (starts with) and city (exact match)
            oFilter = new IEC_Application_Filter__c(); // reset filter
            oFilter.Agency_Name__c = 'Chillwave Agency';
            oFilter.Agency_Name_Search_Condition__c = IECConstants.GADAgencyNameSearchBy.TradingName.name();
            oFilter.Agency_Name_Search_Type__c = IECConstants.GADSearchType.StartsWith.name();
            oFilter.City__c = oGDPAddress3.Address_City__c;
            oFilter.City_Search_Type__c = IECConstants.GADSearchType.ExactMatch.name();

            lstSearchResult = IECApplicationsManager.customerSearchAgencyByAdvancedFilters(oFilter, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            //system.assert(lstSearchResult != null && lstSearchResult.size() == 1 && oGDPAccount1.Id == lstSearchResult.get(0).Id, 'The Agency #2 should be found based on agency name and city');
        }
		*/
    }

    

    // test customer search functionality: part 4
    // test search by address
    //@isTest(SeeAllData=true)
    static void testCustomerSearch4_Address() {  
        initDataForCustomerSearch();
        System.assertNotEquals( null, oGDPAccount3.Id, 'oGDPAddress3 should have been inserted');
        // oGDPAccount3 was created by initDataForCustomerSearch, now just update it with new address
        
        List<GDP_Products_Account_View__c> lstSearchResult = null;
        
        // prepare the Address related records
        IATA_ISO_Country__c oISOCountry = IECTestUtil.CreateSampleIATAISOCountry();
        insert oISOCountry;
        GDP_Geo_Detail__c oGEODetail = IECTestUtil.CreateSampleGDPGeoDetail(oISOCountry);
        insert oGEODetail;
        
        GDP_Address__c oGDPAddress3 = IECTestUtil.CreateSampleGDPAddress(oGDPAccount3, oISOCountry, null, oGEODetail);
        oGDPAddress3.Address_Postal_Code__c = 'H0H 0H0';
        oGDPAddress3.Address_Type__c = 'Location';
        oGDPAddress3.Address_City__c = 'BOYA';
        insert oGDPAddress3;
        
        // add Address to the existing oGDPAccount3 in database
        GDP_Products_Account_View__c oGDPAccount3New = new GDP_Products_Account_View__c( Id = oGDPAccount3.Id
                , Related_GDP_Address__c = oGDPAddress3.Id);
        update oGDPAccount3New;
        
        // Test #10
        // create search filter
        IEC_Application_Filter__c oFilter = new IEC_Application_Filter__c();
        oFilter.Zip_Code__c = '0H 0';
        oFilter.City__c = oGDPAddress3.Address_City__c;
        oFilter.Sub_Continent__c = oGEODetail.Sub_Continent__c;
        oFilter.Country__c = oGDPAddress3.Address_ISO_Country_Code__c;
        
        test.startTest();
        System.runAs(oCommunityUser) {
            // note that IECCustomer.getCurrentIECCustomer() requires the method to be called by Community User
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByAdvancedFilters(oFilter, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
        }
        system.assert(lstSearchResult != null && lstSearchResult.size() == 1 && oGDPAccount3.Id == lstSearchResult.get(0).Id, 'The Agency #3 should be found based on the zip/postal code');
         
        // Test #11 - search by agency trade name (starts with) and city (exact match)
        oFilter = new IEC_Application_Filter__c(); // reset filter
        oFilter.Agency_Name__c = oGDPAccount3.Name.substring(5); //  AGENCY3_NAME should be longer than this
        oFilter.Agency_Name_Search_Condition__c = IECConstants.GADAgencyNameSearchBy.TradingName.name();
        oFilter.Agency_Name_Search_Type__c = IECConstants.GADSearchType.StartsWith.name();
        oFilter.City__c = oGDPAddress3.Address_City__c;
        oFilter.City_Search_Type__c = IECConstants.GADSearchType.ExactMatch.name();
        
        System.runAs(oCommunityUser) {
            // note that IECCustomer.getCurrentIECCustomer() requires the method to be called by Community User
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByAdvancedFilters(oFilter, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
        }
        
        test.stopTest();
        
        System.debug( 'Test search by City:' + oFilter.City__c 
                     + ', Search Type: ' + oFilter.City_Search_Type__c
                     + ', lstSearchResult:' + lstSearchResult);
        System.assert(lstSearchResult != null && lstSearchResult.size() > 0, 'The Agency #3 should be found.');
        System.assert(lstSearchResult != null && lstSearchResult.size() == 1 
                      && oGDPAccount3New.Id == lstSearchResult.get(0).Id
                      , 'The Agency #3 should be found based on agency name and city');
    } // end of testCustomerSearch4_Address
     
    // test testLiveUsageTracking
     @isTest(SeeAllData=true)
    static void testLiveUsageTracking() {
        setupData();
        
        //User usr = IECTestUtil.createSampleGuestUserAndLogin();
        //System.runAs(usr) {
            
            Test.startTest();
            
            initSubscription();
            
            // trigger the Product Access creation (why only on Subscription trigger After Update ?)
            update oSubscription;
            
            Test.stopTest();
            
            // Test #1 - missing mandatory parameters
            try {
                IECApplicationsManager.trackLiveUsage(null, null, null, null, null);
                system.assert(false, 'Should throw exception because of missing parameters');
            }
            catch(Exception ex) {
                system.assert(true, 'Should throw exception because of missing parameters');
            }
            
            // Test #2 - create anonymous usage tracking for CAC Free
            Id idUsageTracker = IECApplicationsManager.trackLiveUsage(IECConstants.ProductCategory_SF_CACFREE, IECConstants.IECUsageTrackerSearchStatus_Success, IECConstants.IECUsageTrackerSearchTarget_Agent, null, null);
            IEC_Usage_Tracker_Live__c oUsageTracker = [SELECT Counter__c, RelatedContact__c, Search_Status__c, Search_Target__c, Related_Subscription_History__c, Related_Application_Type__c, Date__c 
                                                        FROM IEC_Usage_Tracker_Live__c
                                                        WHERE Id =: idUsageTracker limit 1];
            system.assert(oUsageTracker != null, 'The Usage Tracking record should be found');
            system.assertEquals(IECConstants.ProductCategory_SF_CACFREE, oUsageTracker.Related_Application_Type__c, 'The Product Category should be CAC Free');
            system.assertEquals(IECConstants.IECUsageTrackerSearchStatus_Success, oUsageTracker.Search_Status__c, 'The Search Status should be Valid');
            system.assertEquals(IECConstants.IECUsageTrackerSearchTarget_Agent, oUsageTracker.Search_Target__c, 'The Search Target should be Agent');
            system.assertEquals(Date.today(), oUsageTracker.Date__c.date(), 'The Date should be set to today');
            system.assertEquals(1, oUsageTracker.Counter__c, 'The Counter should be set to 1');
            system.assertEquals(null, oUsageTracker.RelatedContact__c, 'The Related Contact should be set to null');
            system.assertEquals(null, oUsageTracker.Related_Subscription_History__c, 'The Related Subscription History should be set to null');
            
            // Test #3 - create non-anonymous usage tracking for CAC Pro
            idUsageTracker = IECApplicationsManager.trackLiveUsage(IECConstants.ProductCategory_SF_CACPRO, IECConstants.IECUsageTrackerSearchStatus_Fail, IECConstants.IECUsageTrackerSearchTarget_Agent, oContact, oSubscriptionHist);
            oUsageTracker = [SELECT Counter__c, RelatedContact__c, Search_Status__c, Search_Target__c, Related_Subscription_History__c, Related_Application_Type__c, Date__c 
                                FROM IEC_Usage_Tracker_Live__c
                                WHERE Id =: idUsageTracker limit 1];
            system.assert(oUsageTracker != null, 'The Usage Tracking record should be found');
            system.assertEquals(IECConstants.ProductCategory_SF_CACPRO, oUsageTracker.Related_Application_Type__c, 'The Product Category should be CAC Pro');
            system.assertEquals(IECConstants.IECUsageTrackerSearchStatus_Fail, oUsageTracker.Search_Status__c, 'The Search Status should be Fail');
            system.assertEquals(oContact.Id, oUsageTracker.RelatedContact__c, 'The Related Contact should be assigned');
            system.assertEquals(oSubscriptionHist.Id, oUsageTracker.Related_Subscription_History__c, 'The Related Subscription History should be assigned');
            
            // Other tests
            // Test #4 - test subscription end date and number of days left
            Date enddate = IECApplicationsManager.getLastEnddateOfProductAccess(oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
            //system.assertEquals(dtSubscriptionEnddate, enddate, 'The appropriate End date should be returned');
            Integer iDaysLeft = IECApplicationsManager.getDaysLeftForAccessByProductCategory(oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
            system.assertEquals(Date.today().daysBetween(enddate), iDaysLeft, 'Days between error');
            system.assertEquals(0, IECApplicationsManager.getDaysLeftForAccessByProductCategory(oContact.Id, IECConstants.ProductCategory_SF_GAD), 'Should have 0 days left for a product not purchased');
        //}
    } // end of testLiveUsageTracking
    
    // ====================================================================
    // testAnonymousSearch
    @isTest(SeeAllData=true)
    static void testAnonymousSearch() {
        
        List<GDP_Products_Account_View__c> lstSearchResult = null;
        List<IEC_Usage_Tracker_Live__c> lstUsageLive = null;
        ID_Card__c oSearchedIDCard = null;

        //Creates a regist in CAC_and_GAD_Settings__c to be used in the test
        createCACandGADEntry();
        
        setupData();
        
        // Test #1 - search for unknown agency
        lstSearchResult = IECApplicationsManager.anonymousSearchAgencyByIATACode('4444444', null, null, IECConstants.ProductCategory_SF_CACFREE);
        system.assert(lstSearchResult == null || lstSearchResult.size() == 0, 'No Agency should be found');
        
        lstUsageLive = [SELECT Counter__c, RelatedContact__c, Search_Status__c, Search_Target__c, Related_Subscription_History__c, Related_Application_Type__c, Date__c 
                        FROM IEC_Usage_Tracker_Live__c
                        WHERE RelatedContact__c = null
                            AND Related_Subscription_History__c = null
                            AND Related_Application_Type__c = :IECConstants.ProductCategory_SF_CACFREE
                            AND Search_Target__c = :IECConstants.IECUsageTrackerSearchTarget_Agency
                            AND Date__c >= :Datetime.now().addSeconds(-5)
                        ORDER by CreatedDate desc];
        system.assert(lstUsageLive != null && lstUsageLive.size() > 0, 'The Usage Tracking record should be found');

        // Test #2 - search for an existing checkCode
        lstSearchResult = IECApplicationsManager.anonymousSearchAgencyByIATACode('4444444', '0', null, IECConstants.ProductCategory_SF_CACFREE);
        system.assert(lstSearchResult == null || lstSearchResult.size() == 0, 'No Agency should be found');

        // Test #3 - search for an existing checkCode and CASSCode
        lstSearchResult = IECApplicationsManager.anonymousSearchAgencyByIATACode('4444444', '0', '0', IECConstants.ProductCategory_SF_CACFREE);
        system.assert(lstSearchResult == null || lstSearchResult.size() == 0, 'No Agency should be found');


        //system.assertEquals(IECConstants.IECUsageTrackerSearchStatus_Fail, lstUsageLive.get(0).Search_Status__c, 'The Search Status should be Fail');
        //system.assertEquals(1, lstUsageLive.get(0).Counter__c, 'The Counter should be set to 1');
        
        // Test #2 - search for known agency
        //lstSearchResult = IECApplicationsManager.anonymousSearchAgencyByIATACode(AGENCY1_CODE, null, null, IECConstants.ProductCategory_SF_CACFREE);
        //system.assert(lstSearchResult != null && lstSearchResult.size() == 1, 'The Agency should be found');
        
        // Test #4 - search for invalid ID Card
        oSearchedIDCard = IECApplicationsManager.anonymousSearchAgentByVER('3213215', IECConstants.ProductCategory_SF_CACFREE);
        system.assert(oSearchedIDCard == null, 'The ID Card should not be found for unknown VER number');
        
        // Test #4 - search for valid ID Card
        //oSearchedIDCard = IECApplicationsManager.anonymousSearchAgentByVER(AGENT_VER_NUMBER, IECConstants.ProductCategory_SF_CACFREE);
        //system.assert(oSearchedIDCard != null, 'The ID Card should be found');
    } // end of testAnonymousSearch
    
    // ====================================================================
    // testOtherStuff
    @isTest(SeeAllData=true)
    static void testOtherStuff() {
        
        // Test #1 - test string representation of filter
        
        IEC_Application_Filter__c oFilter = new IEC_Application_Filter__c();
        oFilter.Agency_Name__c = 'some name';
        oFilter.Agency_Name_Search_Condition__c = 'Legal Name';
        oFilter.Agency_Name_Search_Type__c = 'Contains';
        oFilter.Agency_Program__c = 'afds';
        oFilter.Area_of_Activity__c = 'afds';
        oFilter.City__c = 'afds';
        oFilter.City_Search_Type__c = 'Contains';
        oFilter.Country__c = 'Canada';
        oFilter.Hierarchy__c = 'afds';
        oFilter.Agency_Program__c = 'afds';
        oFilter.IATA_Code__c = 'afds';
        oFilter.State__c = 'afds';
        oFilter.Sub_Continent__c = 'afds';
        oFilter.Zip_Code__c = 'h2w3e4';
        insert oFilter;
        
        IECApplicationsManager.getStringRepresentationOfApplicationFilter(oFilter.Id);
        
        // Test #2 - test agency program code by area of activity
        
        IEC_Agency_Type__c oAgencyType1 = new IEC_Agency_Type__c();
        oAgencyType1.Area_of_Activity__c = AREA_OF_ACTIVITY;
        oAgencyType1.Agency_Program__c = 'Domestic';
        oAgencyType1.Agency_Program_Code__c = 'D';
        insert oAgencyType1;
        
        IEC_Agency_Type__c oAgencyType2 = new IEC_Agency_Type__c();
        oAgencyType2.Area_of_Activity__c = AREA_OF_ACTIVITY;
        oAgencyType2.Agency_Program__c = 'External Registrars';
        oAgencyType2.Agency_Program_Code__c = 'E';
        insert oAgencyType2;
        
        List<String> lstProgramCodes = IECApplicationsManager.getAgencyProgramCodesByAreaOfActivity(AREA_OF_ACTIVITY);
        system.assert(lstProgramCodes != null && lstProgramCodes.size() == 2, '2 agency program code should be found');
        
        // Test #3 - test empty filters
        oFilter = new IEC_Application_Filter__c();
        system.assertEquals(true, IECApplicationsManager.isApplicationFilterEmpty(oFilter), 'The filter should be considered empty');
    } // end of testOtherStuff
    
    // ====================================================================
    // testOtherStuff part 2
    // just some extra calls just to increase the coverage
    @isTest(SeeAllData=true)
    static void testOtherStuff2() {
        initDataForCustomerSearch();
        
        Test.startTest();
        GDP_Products_Account_View__c oGDPAccount1Search = IECApplicationsManager.getAgencyByID(oGDPAccount1.Id);
        System.assertEquals( oGDPAccount1.Id, oGDPAccount1Search.Id, 'GDPAccount1 should have been found');
        
        IECApplicationsManager.createProductAccessOnNewSubscription( oContact.Id, oSubscription, 'INVOICE 333'); 
        
        Integer contactAccessProductCategoryStatusCode = IECApplicationsManager.ContactHasAccessToProductCategory( oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
        Integer contactAccessSubscriptionStatusCode =  IECApplicationsManager.ContactHasAccessToSubscriptionName( oContact.Id, oSubscription.Name);   

        List<IEC_Product_Access__c> lstProdAccessBySubs = IECApplicationsManager.getListProductAccessByContactBySubscriptionNumber(oContact.Id, oSubscription.Name);
        System.assertNotEquals(0, lstProdAccessBySubs.size(), 'ProductAccess By Subscription should be found.');
            
        List<IEC_Product_Access__c> lstProdAccessByProductCategory = IECApplicationsManager.getProductAccessByContact(oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
        System.assertNotEquals(0, lstProdAccessByProductCategory.size(), 'ProductAccess By Product Category should be found.');
        
        IECApplicationsManager.adjustProductAccessOnSubscription( oContact.Id, oSubscription, 'INVOICE 333', lstProdAccessBySubs[0]); 

        List<IEC_Application_Filter__c> lstFilters = IECApplicationsManager.LoadFilterByContact( oContact.id, true) ;// test for bSystemGenerated
        
        System.runAs(oCommunityUser) {
            Date dEndSubscriptionDate = IECApplicationsManager.getEnddateOfSubscriptionName(oSubscription.Name);
            Integer iDayLeftForAccess = IECApplicationsManager.getDaysLeftForAccessBySubscriptionName(oSubscription.Name);
        }

        /*
        IECEBC_TestUtility.createEbcSetupAndRelatedData();
        IECEBC_TestUtility.createTestUser();
        Zuora__Subscription__c ebcSubscription = IECEBC_TestUtility.createEbcSubscription(IECEBC_TestUtility.lEbcProductRatePlanMember[1], IECEBC_TestUtility.oEbcProductMember, dtSubscriptionEnddate);
        ebcSubscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
        IECApplicationsManager.adjustProductAccessOnSubscription( oContact.Id, ebcSubscription, 'INVOICE 333', null);
        */

        Test.stopTest();
        
    } // end of testOtherStuff2
    
    // ====================================================================
    // test isEbcAccessGrantedForContact()
    // this method only check based on the value of related Zuora__CustomerAccount__c.eBroadcast_Product_Access__c 
    @isTest(SeeAllData=false)
    static void testIsEbcAccessGrantedForContact() {
        // simplified data preparation
        Account oTestAccount = IECTestUtil.createSampleAccount();
        insert oTestAccount;
        System.assertNotEquals( null, oTestAccount.Id, 'AccountId is null');
        
        Contact oTestContact = IECTestUtil.createSampleContact(oTestAccount);
        insert oTestContact;
        System.assertNotEquals( null, oTestContact.Id, 'ContactId is null');
        
        Zuora__CustomerAccount__c oTestBillingAccount = IECTestUtil.createSampleBillingAccount(oTestAccount, oTestContact);
        oTestBillingAccount.Contact__c = oTestContact.Id;
        oTestBillingAccount.Zuora__Status__c = 'Active';
        oTestBillingAccount.eBroadcast_Product_Access__c = false;
        insert oTestBillingAccount;
        System.assertNotEquals( null, oTestBillingAccount.Id, 'CustomerAccountId is null');
        
        Boolean bPermissionGranted;
        
        // initial case: no access to EBC
        bPermissionGranted = IECApplicationsManager.isEbcAccessGrantedForContact(oTestContact.Id);
        System.assertEquals( false, bPermissionGranted, 'Permission to access EBC should not be granted based on BillingAccount setting');
        
        // test second case: no access to EBC
        Zuora__CustomerAccount__c oTestBillingAccountUpdate = new Zuora__CustomerAccount__c( Id = oTestBillingAccount.Id
            , eBroadcast_Product_Access__c = true);
        update oTestBillingAccountUpdate;

        
        Boolean resetPreviouslyStoredBillingAcct = true;
        bPermissionGranted = IECApplicationsManager.isEbcAccessGrantedForContact(oTestContact.Id, resetPreviouslyStoredBillingAcct); // 
        System.assertEquals( true, bPermissionGranted, 'Permission to access EBC should be granted based on BillingAccount setting');
		
        
    } // testIsEbcAccessGrantedForContact
} // end of IECApplicationsManager_tst