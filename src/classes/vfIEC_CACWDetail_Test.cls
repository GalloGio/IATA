/**
 * This is a test class for vfIEC_CACWDetail.cls
 *  - vfIEC_CACWDetailDetail.cls
 *  - vfIEC_CACWDetail.page
 * 
 * Note on seeAllData=true (we know it is a bad practice):
 *  - IEC_CACW uses vfIECSubscriptionInfo, vfIECSubscriptionInfo uses IECCustomer in validateAccess().
 *  - IECCustomer constructor has conditional value for test run, which creates its own ZuoraAccount and BillingAccount.
 *  - In creating that ZuoraAccount (regular Account), IECTestUtil calls Zuora.zObject and Zuora.zSchema which requires Zuora WSDL
 *  - Unless someone fixes IECCustomer constructor, anytime test class involving IECCustomer requires seeAllData true.
 * 
 * Original Author: Sonny Leman
 *
 * Change log:
 *   2016-04-25-sl: initial version 
 *
 */
 
@isTest(seeAllData=true)
private class vfIEC_CACWDetail_Test {
  static private User testUser; 
  
  static private final String ZSUBSCRIPTION_NAME_01 = 'Subs Test 01';
  static private final Integer ZSUBSCRIPTION_01_DAYS_LEFT = 100;
  static private final Integer SUBSCRIPTION_PRODUCT_CHARGE_01_DAYS_LEFT = 105;
  static private final Integer PRODUCT_ACCESS_DAYS_LEFT = 110;
  
  static private final String PRODUCT_CATEGORY_DISPLAY_NAME_01 = 'Product Category Display 01';
  static private final String PRODUCT_RATE_PLAN_NAME_01 = 'TEST Product Rate Plan Name 1';
  static private final String PRODUCT_NAME_01 = 'TEST PROD 101';
  static private final String PRODUCT_RATE_PLAN_INFO_NAME_01 = 'PCRPTST';
  
  // ========================================================================
  // basic test
  static testMethod void testIEC_CACWDetail01_Basic() {
    testUser = IECTestUtil.createSampleGuestUserAndLogin();
    testDataPreparation(); // testUser will be used in testDataPreparation
    
    System.debug('Unit Test: Start: testIEC_CACWDetail01_Basic');
    
    //Set current page to GSSDetail File
    PageReference pgRef = Page.IEC_CACWDetail;
    pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(ZSUBSCRIPTION_NAME_01));
    pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_CACWEB));
    Test.setCurrentPage(pgRef);
    
    Test.startTest();
    
    // simulate a community user access this web page
    System.runAs(testUser) 
    {
      vfIEC_CACW iecCacWebBaseCon = new vfIEC_CACW();
      vfIEC_CACWDetail cacCon = new vfIEC_CACWDetail(iecCacWebBaseCon);
      
      // ----------------------------------------------------------------------------
      // test from the parent properties, just for validation
      // note that the base class vfIEC_CACW is private property of vfIEC_CACWDetail.
      System.debug( 'ctrSubsInfo.sSelectedSubscriptionName:' + iecCacWebBaseCon.ctrSubsInfo.sSelectedSubscriptionName);
      System.assertEquals(ZSUBSCRIPTION_NAME_01, iecCacWebBaseCon.ctrSubsInfo.sSelectedSubscriptionName, 'Subscription Name should be passed preperly.');
      
      System.debug('sProductCode: ' + iecCacWebBaseCon.sProductCode);
      System.debug('ctrSubsInfo.sSelectedSubscriptionName:' + iecCacWebBaseCon.ctrSubsInfo.sSelectedSubscriptionName);
      
      System.assert(iecCacWebBaseCon.ctrSubsInfo.validateAccess(), 'testUser should have access validated.');
      
      System.assertEquals(ZSUBSCRIPTION_NAME_01, iecCacWebBaseCon.subscriptionObj.Name, 'Subscription Name should match.');
      
      // iecCacWeb.subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
      System.assertNotEquals(null, iecCacWebBaseCon.subscriptionObj.Product_Rate_Plan_Information__c, 'Subscription.Product_Rate_Plan_Information__c is null.' );
      
      // ---------------------------------------------------------------------------
      // test IEC_CACWDetail getter methods:
      
      // oSubscription.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
      String sProductName = cacCon.sProductName;
      System.assertEquals( PRODUCT_CATEGORY_DISPLAY_NAME_01, sProductName, 'Product Name should match the definition.');
      
      // oSubscription.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
      String sOptionName = cacCon.sOptionName;
      System.assertEquals( PRODUCT_RATE_PLAN_NAME_01, sOptionName, 'sOption should match Product Rate Plan Name definition.');
      
      Integer iSubscriptionDaysLeft = cacCon.iSubscriptionDaysLeft;
    //  System.assertEquals( ZSUBSCRIPTION_01_DAYS_LEFT, iSubscriptionDaysLeft, 'Number of Subscription Days Left should match the one in Subscription.');
    }
    Test.stopTest();
  } // end of testIEC_CACWDetail01_Basic
  
  
  // ========================================================================
  // extra test for no subscription data found
  static testMethod void testIEC_CACWDetail02_Extra() {
    testUser = IECTestUtil.createSampleGuestUserAndLogin();
    // testDataPreparation(); // do not call
    
    System.debug('Unit Test: Start: testIEC_CACWDetail01_Basic');
    
    //Set current page to GSSDetail File
    PageReference pgRef = Page.IEC_CACWDetail;
    //pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(testUser.ContactId_01));
    pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_CACWEB));
    Test.setCurrentPage(pgRef);
    
    Test.startTest();
    
    // simulate a community user access this web page
    System.runAs(testUser) 
    {
      vfIEC_CACW iecCacWebBaseCon = new vfIEC_CACW();
      vfIEC_CACWDetail cacCon = new vfIEC_CACWDetail(iecCacWebBaseCon);
      
      // ----------------------------------------------------------------------------
      // test from the parent properties, just for validation
      // note that the base class vfIEC_CACW is private property of vfIEC_CACWDetail.
      System.debug( 'ctrSubsInfo.sSelectedSubscriptionName:' + iecCacWebBaseCon.ctrSubsInfo.sSelectedSubscriptionName);
      System.assertEquals(null, iecCacWebBaseCon.subscriptionObj, 'Subscription should be null');
      
      // ---------------------------------------------------------------------------
      // test IEC_CACWDetail getter methods:
      Integer iSubscriptionDaysLeft = cacCon.iSubscriptionDaysLeft;
    }
    Test.stopTest();
  } // end of testIEC_CACWDetail02_Extra
  
  
  // ========================================================================
  // test data  preparation creates/inserted the following
  //   - Product_Category__c, zqu__ZProduct, Product_Information__c,
  //   - zqu__ProductRatePlan__c, zqu__ProductRatePlanCharge__c, Product_Rate_Plan_Information__c
  //   - IECCustomer
  //   - Zuora__Subscription__c, Zuora__SubscriptionProductCharge__c, IEC_Product_Access__c
  //   - GDP_File_Description__c, CAC_Subscription_Detail__c
  static void testDataPreparation() 
  {
    Date dEndOfSubscriptionDate = Date.today().addDays(ZSUBSCRIPTION_01_DAYS_LEFT);
    Date dEndOfSubscriptionProductChargeDate = Date.today().addDays(SUBSCRIPTION_PRODUCT_CHARGE_01_DAYS_LEFT);
    Date dEndOfProductAccessDate = Date.today().addDays(PRODUCT_ACCESS_DAYS_LEFT);
    
    Product_Category__c  oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACWEB, true);
    oProductCategory.Display_Name__c = PRODUCT_CATEGORY_DISPLAY_NAME_01;
    insert oProductCategory;
    
    Product2 oProduct = IECTestUtil.CreateSampleProduct2('PTST');
    insert oProduct;
    
    Product_Information__c oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
    oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
    insert oProductInfo;
    
    zqu__ProductRatePlan__c oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2(PRODUCT_RATE_PLAN_NAME_01, false, oProduct);
    insert oProductRatePlan;
    
    zqu__ProductRatePlanCharge__c oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
    insert oProductRatePlanCharge;
    
    Product_Rate_Plan_Information__c oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
    insert oProductRatePlanInfo;
    
    IECCustomer currentCustomer;
    System.runAs(testUser)
    {
      currentCustomer = IECCustomer.getCurrentIECCustomer(); // this is the part that requires seeAllData = true
    }
    
    // create test subscription
    Zuora__Subscription__c oSubscription = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, ZSUBSCRIPTION_NAME_01, dEndOfSubscriptionDate);
    oSubscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
    insert oSubscription;
    
    // create test subscription charge
    Zuora__SubscriptionProductCharge__c subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(oSubscription.Id, dEndOfSubscriptionProductChargeDate, oProduct, oProductRatePlan);
    
    Contact oContact = [Select Id, Name, AccountId from Contact where Id = :testUser.ContactId limit 1];
    //Account oAccount = [Select Id, Name from Account where Id = :oContact.AccountId limit 1];
    
    // insert Product Access for oContact for oSubscription and its Product Rate Plan
    IEC_Product_Access__c oProductAccess = new IEC_Product_Access__c(
        Related_Contact__c = testUser.ContactId
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
        , Effective_End_Date__c = dEndOfProductAccessDate
      );
    insert oProductAccess;
    
    // create GDP_File_Description__c , w/ Product_Type__c : CAC, CACEWS, CACSWS
    List<GDP_File_Description__c> lCacFileDesc = CAC_TestLibrary.generateFileDescCACNonRef();
    System.assertNotEquals(null, lCacFileDesc[0].Id);
    
    
    // Create test CAC Subscription Detail
    CAC_Subscription_Detail__c oCacSubscriptionDetail = 
       new CAC_Subscription_Detail__c(Name = oSubscription.Name
                     , Subscription__c = oSubscription.Id
                     , Service_Specification__c = lCacFileDesc[0].Id
                    , Service_Activation_Date__c = Date.today()
                    , Max_API_Call_Per_Month__c = 10000
                    , Status__c='Active'
                    //, Service_Token__c=
                    );
    upsert oCacSubscriptionDetail;
    
    System.debug('End of testDataPreparation');
  } // testDataPreparation
  
}