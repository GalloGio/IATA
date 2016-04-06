/**
 * This class contains unit tests for validating the behavior of class IECApplicationsManager
 */
@isTest
private class IECApplicationsManager_tst {

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
    private static final String AGENCY1_CODE = '5555555';
    private static final String AGENCY2_CODE = '6666666';
    private static final String AGENCY3_CODE = '7777777';
    private static final String AGENT_VER_NUMBER = '5578000523';
    private static final String AGENCY_CHECK_DIGIT = '9';
    private static final String AGENCY1_NAME = 'Chillwave Agency';
    private static final String AGENCY2_NAME = 'Chilly Cheese Agency';
    private static final String AGENCY3_NAME = 'Kashmir Coats';
    private static final String AREA_OF_ACTIVITY = 'My Area of Activity';
    
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

        List<RecordType> rtypes = [Select Name, Id 
                                    From RecordType
                                    where sObjectType='Account'
                                        and Name = 'Agency'
                                        and isActive = true];
        
        oAgencyAccount = IECTestUtil.createSampleAccount();
        oAgencyAccount.Name = AGENCY1_NAME;
        oAgencyAccount.IATACode__c = AGENCY1_CODE;
        oAgencyAccount.Status__c = 'Approved';
        oAgencyAccount.RecordTypeId = rtypes.get(0).Id;
        insert oAgencyAccount;
        
        oGDPAccount1 = IECTestUtil.createSampleGDPAccount(AGENCY1_NAME, AGENCY1_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
        oGDPAccount1.Check_Digit__c = AGENCY_CHECK_DIGIT;
        insert oGDPAccount1;
        
        oGDPAccount2 = IECTestUtil.createSampleGDPAccount(AGENCY2_NAME, AGENCY2_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
        insert oGDPAccount2;
        
        oGDPAccount3 = IECTestUtil.createSampleGDPAccount(AGENCY3_NAME, AGENCY3_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
        insert oGDPAccount3;
        
        oIDCard = IECTestUtil.createSampleIDCard('John', 'Doe', AGENT_VER_NUMBER, AGENCY1_NAME, AGENCY1_CODE, 'Printed/Delivered');
        oIDCard.Valid_To_Date__c = Date.today().addYears(1);
        oIDCard.Valid_From_Date__c = Date.today();
        insert oIDCard;
        
        oAccreditation1 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount1, 'GDP');
        oAccreditation1.Status__c = oRefAgencyStatus.Id;
        insert oAccreditation1;
        
        oAccreditation2 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount2, 'GDP');
        oAccreditation2.Status__c = oRefAgencyStatus.Id;
        insert oAccreditation2;

        oAccreditation3 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount3, 'GDP');
        oAccreditation3.Status__c = oRefAgencyStatus.Id;
        insert oAccreditation3;
        
        oGDPAccount1.Related_Accreditation_Class__c = oAccreditation1.Id;
        oGDPAccount2.Related_Accreditation_Class__c = oAccreditation2.Id;
        oGDPAccount3.Related_Accreditation_Class__c = oAccreditation3.Id;
        update new List<GDP_Products_Account_View__c> {oGDPAccount1, oGDPAccount2, oGDPAccount3};
    }
    
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
    }






 @isTest(SeeAllData=true)
    static void testCustomerSearch2Pre() {
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
        List<IEC_Product_Access__c> lstProductAccess = null;
        List<GDP_Products_Account_View__c> lstSearchResult = null;
        ID_Card__c oSearchedIDCard = null;
        Integer iUsageAccess;
        

test.startTest();
        List<RecordType> rtypes = [Select Name, Id 
                                    From RecordType
                                    where sObjectType='Account'
                                        and Name = 'Agency'
                                        and isActive = true];
        
      /*  oAgencyAccount = IECTestUtil.createSampleAccount();
        oAgencyAccount.Name = AGENCY1_NAME;
        oAgencyAccount.IATACode__c = AGENCY1_CODE;
        oAgencyAccount.Status__c = 'Approved';
        oAgencyAccount.RecordTypeId = rtypes.get(0).Id;
        insert oAgencyAccount;*/

        oRefAgencyStatus = IECTestUtil.createSampleGDPReferenceTableEntry('4', 'Valid');
        insert oRefAgencyStatus;

        oRefIncorporationType = IECTestUtil.createSampleGDPReferenceTableEntry('i', 'Incorporated');
        insert oRefIncorporationType;


        oRefLocationType = IECTestUtil.createSampleGDPReferenceTableEntry('HO', 'Head Office');
        insert oRefLocationType;

        oGDPAccount1 = IECTestUtil.createSampleGDPAccount(AGENCY1_NAME, AGENCY1_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
        oGDPAccount1.Check_Digit__c = AGENCY_CHECK_DIGIT;
        insert oGDPAccount1;




        oAccreditation1 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount1, 'GDP');
        oAccreditation1.Status__c = oRefAgencyStatus.Id;
        insert oAccreditation1;
        oGDPAccount1.Related_Accreditation_Class__c = oAccreditation1.Id;
        update oGDPAccount1;

      oIDCard = IECTestUtil.createSampleIDCard('John', 'Doe', AGENT_VER_NUMBER, AGENCY1_NAME, AGENCY1_CODE, 'Printed/Delivered');
        oIDCard.Valid_To_Date__c = Date.today().addYears(1);
        oIDCard.Valid_From_Date__c = Date.today();
        insert oIDCard;
        oAccount = IECTestUtil.createSampleAccount();
        insert oAccount;
        
        oContact = IECTestUtil.createSampleContact(oAccount);
        insert oContact;
        User u = IECTestUtil.createSampleUser(oContact);
        test.stopTest();  

        System.runAs(u) {
        
            // Test #2 - search for unknown agency
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByIATACode('4444444', null, null, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            system.assert(lstSearchResult == null || lstSearchResult.size() == 0, 'No Agency should be found');
            
            // usage should be consumed (even if no results)
            lstProductAccess = IECApplicationsManager.getListProductAccessByContactByProductCategory(oContact.Id, IECConstants.ProductCategory_SF_CACPRO);
            
            //futuremethod
            //system.assert(lstProductAccess != null && lstProductAccess.get(0).Usage_Qty_consumed__c == 1, 'Product Access should reflect 1 search consumption');
            
            // Test #3 - search for a known agency
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByIATACode(AGENCY1_CODE, null, null, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            system.assert(lstSearchResult != null && lstSearchResult.size() == 1, 'The Agency should be found');
            
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
            system.assert(oSearchedIDCard != null, 'The ID Card should be found');
            // Test #6 - search for a known agency with a check code
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByIATACode(AGENCY1_CODE, null, AGENCY_CHECK_DIGIT, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            system.assert(lstSearchResult != null && lstSearchResult.size() == 1, 'The Agency should be found');
            
            ///////////////////////
            // GAD Advanced search
            // Test #7 - search for unknown sub-continent
            // create some filter for unkown sub-continent
            IATA_ISO_Country__c oISOCountry = IECTestUtil.CreateSampleIATAISOCountry();
            insert oISOCountry;
            GDP_Geo_Detail__c oGEODetail = IECTestUtil.CreateSampleGDPGeoDetail(oISOCountry);
            insert oGEODetail;
            GDP_Address__c oGDPAddress1 = IECTestUtil.CreateSampleGDPAddress(oGDPAccount1, oISOCountry, null, oGEODetail);
            oGDPAddress1.Address_City__c = 'BOYA';
            insert oGDPAddress1;
            oGDPAccount1.Related_GDP_Address__c = oGDPAddress1.Id;
            update oGDPAccount1;
            SchdlGDPProductsAccountSnapshotCleanup bat = new SchdlGDPProductsAccountSnapshotCleanup();
            List<GDP_Products_Account_View__c> gpav = Database.query(SchdlGDPProductsAccountSnapshotCleanup.query);
            bat.execute(null, gpav);



            IEC_Application_Filter__c oFilter = new IEC_Application_Filter__c();
            oFilter.Sub_Continent__c = 'Some sub-continent';
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByAdvancedFilters(oFilter, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            system.assert(lstSearchResult == null || lstSearchResult.size() == 0, 'No agency should be found');
            // Test #8 - search for known sub-continent
            
            
      //      throw new transformationException('oFilter.sub-continent ' + oGEODetail.Sub_Continent__c);




//list<GDP_Products_Account_View__c> GDPs = (list<GDP_Products_Account_View__c>)database.query(sQueryFields);

//throw new  transformationException('GDP_Products_Account_View__cs   ' +GDPs);

            oFilter.Sub_Continent__c = oGEODetail.Sub_Continent__c;
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByAdvancedFilters(oFilter,
                                                IECConstants.ProductCategory_SF_CACPRO,
                                                 IECCustomer.getCurrentIECCustomer());
            system.assert(lstSearchResult != null
                             && lstSearchResult.size() == 1 && 
                             oGDPAccount1.Id == lstSearchResult.get(0).Id,
                              'The Agency #1 should be found based on sub-continent');

            // Test #9 - search by multiple filters with 2 agencies having the same city, country and sub-continent

            //account 2 - start
                oGDPAccount2 = IECTestUtil.createSampleGDPAccount(AGENCY1_NAME, AGENCY1_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
                oGDPAccount1.Check_Digit__c = AGENCY_CHECK_DIGIT;
                insert oGDPAccount2;

                oAccreditation2 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount2, 'GDP');
                oAccreditation2.Status__c = oRefAgencyStatus.Id;
                insert oAccreditation2;
                oGDPAccount2.Related_Accreditation_Class__c = oAccreditation2.Id;
                update oGDPAccount2;

            //account 2 - end

            //GDP_Geo_Detail__c 2 - start
                    
                GDP_Geo_Detail__c oGEODetail2 = IECTestUtil.CreateSampleGDPGeoDetail(oISOCountry);
                insert oGEODetail2;
                GDP_Address__c oGDPAddress2 = IECTestUtil.CreateSampleGDPAddress(oGDPAccount2, oISOCountry, null, oGEODetail2);
                oGDPAddress2.Address_City__c = 'BOYA_2';
                insert oGDPAddress2;
                oGDPAccount2.Related_GDP_Address__c = oGDPAddress2.Id;
                update oGDPAccount2;
            	bat = new SchdlGDPProductsAccountSnapshotCleanup();
            	gpav = Database.query(SchdlGDPProductsAccountSnapshotCleanup.query);
            	bat.execute(null, gpav);

            //GDP_Geo_Detail__c 2 - end 

            for (GDP_Products_Account_View__c g : [SELECT City__c, Sub_Continent__c, Country_ISO_Code__c FROM GDP_Products_Account_View__c WHERE ID IN (:oGDPAccount1.Id)]){
                System.debug('SSS: City__c: ' + g.City__c + ', Sub_Continent__c: ' + g.Sub_Continent__c + ', Country_ISO_Code__c: ' + g.Country_ISO_Code__c);
            }
            
            oFilter = new IEC_Application_Filter__c(); // reset filter
            oFilter.City__c = oGDPAddress1.Address_City__c;
            oFilter.Sub_Continent__c = oGEODetail.Sub_Continent__c;
            oFilter.Country__c = oGDPAddress1.Address_ISO_Country_Code__c;
            lstSearchResult = IECApplicationsManager.customerSearchAgencyByAdvancedFilters(oFilter, IECConstants.ProductCategory_SF_CACPRO, IECCustomer.getCurrentIECCustomer());
            system.assert(lstSearchResult != null && lstSearchResult.size() == 2, '2 agencies should be found based on sub-continent and city');
            
            for (GDP_Products_Account_View__c oAgency : lstSearchResult)
                system.assert(oAgency.Id == oGDPAccount1.Id || oAgency.Id == oGDPAccount2.Id, 'Agency #1 and #2 should be found');

            // Test #10 - search by zip/postal code with search type contains
          }
      }
      

   static void testCustomerSearch3Pre() {  
            //account 3 - start
            List<GDP_Products_Account_View__c> lstSearchResult = null;
                 IATA_ISO_Country__c oISOCountry = IECTestUtil.CreateSampleIATAISOCountry();
                insert oISOCountry;
                GDP_Geo_Detail__c oGEODetail = IECTestUtil.CreateSampleGDPGeoDetail(oISOCountry);
                insert oGEODetail;
                oGDPAccount3 = IECTestUtil.createSampleGDPAccount(AGENCY1_NAME, AGENCY1_CODE, oRefAgencyStatus, oRefIncorporationType, oRefLocationType);
                oGDPAccount3.Check_Digit__c = AGENCY_CHECK_DIGIT;

                insert oGDPAccount3;

                oAccreditation3 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount3, 'GDP');
                oAccreditation3.Status__c = oRefAgencyStatus.Id;
                insert oAccreditation3;
                oGDPAccount3.Related_Accreditation_Class__c = oAccreditation3.Id;
                update oGDPAccount3;
            //account 3 - end

            GDP_Address__c oGDPAddress3 = IECTestUtil.CreateSampleGDPAddress(oGDPAccount3, oISOCountry, null, oGEODetail);
            oGDPAddress3.Address_Postal_Code__c = 'H0H 0H0';
            oGDPAddress3.Address_Type__c = 'Location';
            oGDPAddress3.Address_City__c = 'BOYA';
            insert oGDPAddress3;

            oGDPAccount3.Related_GDP_Address__c = oGDPAddress3.Id;
            update oGDPAccount3;
            SchdlGDPProductsAccountSnapshotCleanup bat = new SchdlGDPProductsAccountSnapshotCleanup();
            List<GDP_Products_Account_View__c> gpav = Database.query(SchdlGDPProductsAccountSnapshotCleanup.query);
            bat.execute(null, gpav);

            IEC_Application_Filter__c oFilter = new IEC_Application_Filter__c();
            oFilter.Zip_Code__c = '0H 0';
            oFilter.City__c = oGDPAddress3.Address_City__c;
            oFilter.Sub_Continent__c = oGEODetail.Sub_Continent__c;
            oFilter.Country__c = oGDPAddress3.Address_ISO_Country_Code__c;


            

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
            system.assert(lstSearchResult != null && lstSearchResult.size() == 1 && oGDPAccount1.Id == lstSearchResult.get(0).Id, 'The Agency #2 should be found based on agency name and city');
        }
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

    }
    
    @isTest(SeeAllData=true)
    static void testAnonymousSearch() {
        
        List<GDP_Products_Account_View__c> lstSearchResult = null;
        List<IEC_Usage_Tracker_Live__c> lstUsageLive = null;
        ID_Card__c oSearchedIDCard = null;
        
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
        system.assertEquals(IECConstants.IECUsageTrackerSearchStatus_Fail, lstUsageLive.get(0).Search_Status__c, 'The Search Status should be Fail');
        system.assertEquals(1, lstUsageLive.get(0).Counter__c, 'The Counter should be set to 1');
        
        // Test #2 - search for known agency
        lstSearchResult = IECApplicationsManager.anonymousSearchAgencyByIATACode(AGENCY1_CODE, null, null, IECConstants.ProductCategory_SF_CACFREE);
        system.assert(lstSearchResult != null && lstSearchResult.size() == 1, 'The Agency should be found');
        
        // Test #3 - search for invalid ID Card
        oSearchedIDCard = IECApplicationsManager.anonymousSearchAgentByVER('3213215', IECConstants.ProductCategory_SF_CACFREE);
        system.assert(oSearchedIDCard == null, 'The ID Card should not be found for unknown VER number');
        
        // Test #4 - search for valid ID Card
        oSearchedIDCard = IECApplicationsManager.anonymousSearchAgentByVER(AGENT_VER_NUMBER, IECConstants.ProductCategory_SF_CACFREE);
        system.assert(oSearchedIDCard != null, 'The ID Card should be found');
    }

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
    }

}
