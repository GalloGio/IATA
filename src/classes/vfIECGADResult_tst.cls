/**
 * This class contains unit tests for validating the behavior of class vfIECGADResult
 */
@isTest
public with sharing class vfIECGADResult_tst {

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
	
	private static GDP_Reference_Table__c oRefAgencyStatus;
	private static GDP_Reference_Table__c oRefAgencyStatusTerminated;
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
	
	static void setupData() {
		oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_GAD, true);
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
		oProductRatePlanInfo.Subscription_Usage_Qty__c = null; // make it unlimited
		insert oProductRatePlanInfo;
		
		// create a Terms & Conditions
		oTC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true);
        insert oTC;
        
        oRefAgencyStatus = IECTestUtil.createSampleGDPReferenceTableEntry('4', 'Valid');
        insert oRefAgencyStatus;
        
        oRefAgencyStatusTerminated = IECTestUtil.createSampleGDPReferenceTableEntry('0', 'Terminated');
        insert oRefAgencyStatusTerminated;
        
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
        
        oGDPAccount3 = IECTestUtil.createSampleGDPAccount(AGENCY3_NAME, AGENCY3_CODE, oRefAgencyStatusTerminated, oRefIncorporationType, oRefLocationType);
        insert oGDPAccount3;
        
        oAccreditation1 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount1, 'GDP');
        oAccreditation1.Status__c = oRefAgencyStatus.Id;
    	insert oAccreditation1;

        oAccreditation2 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount2, 'GDP');
    	oAccreditation2.Status__c = oRefAgencyStatus.Id;
    	insert oAccreditation2;

        oAccreditation3 = IECTestUtil.CreateSampleAccreditation(null, oGDPAccount3, 'GDP');
    	oAccreditation3.Status__c = oRefAgencyStatusTerminated.Id;
    	insert oAccreditation3;
    	
    	oGDPAccount1.Related_Accreditation_Class__c = oAccreditation1.Id;
    	oGDPAccount2.Related_Accreditation_Class__c = oAccreditation2.Id;
    	oGDPAccount3.Related_Accreditation_Class__c = oAccreditation3.Id;
    	update new List<GDP_Products_Account_View__c> {oGDPAccount1, oGDPAccount2, oGDPAccount3};
	}
	
	private static void initSubscription(){

		IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
		oAccount = currentCustomer.RelatedAccount; 
		oContact = currentCustomer.RelatedContact;
		oBillingAccount = currentCustomer.RelatedBillingAccount;
		
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
	static void testDisplayAgencyList() {
		try {
			TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
			User u = IECTestUtil.createSampleGuestUserAndLogin();
	    	System.runAs(u) {

	    		Test.startTest();
	    		
	    		// setup data
				setupData();
				initSubscription();

				// trigger the Product Access creation
				update oSubscription;
				
                SchdlGDPProductsAccountSnapshotCleanup bat = new SchdlGDPProductsAccountSnapshotCleanup();
                bat.execute(null);
				Test.stopTest();
	    		
	    		// Set current page
	    		PageReference pgRef = Page.IECGADResult;
                pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter('GAD'));
	    		Test.setCurrentPage(pgRef);
	    		
	    		// instantiate Controller
		    	vfIECGADResult pgCont = new vfIECGADResult(); // test default constructor
		    	pgCont = new vfIECGADResult(2); // since we'll have 3 agencies, use 2 per page so we can have 2 pages
	    		
	    		// Test #1 - don't provide an IEC Application Filter ID
	    		pgCont.pageLoad();
	    		system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_InvalidPageParameter));
	    		system.assertEquals(true, pgCont.ctrSubsInfo.hasPageAccess, 'The customer should have access to GAD');
	    		
	    		// Test #2 - provide an invalid IEC Application Filter ID
	    		pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, IECUtil.EncryptEncodeParameter('WeThrewGasolineOnTheFire'));
	    		pgCont.pageLoad();
	    		system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_InvalidPageParameter));
	    		
	    		// Test #3 - provide a valid IEC Application Filter ID with no filter
	    		IEC_Application_Filter__c oAppFilters = new IEC_Application_Filter__c();
	    		oAppFilters.Related_Contact__c = oContact.Id;
	    		insert oAppFilters;
	    		
	    		pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, IECUtil.EncryptEncodeParameter(oAppFilters.Id));
	    		pgCont.pageLoad();
	    		
	    		system.assertEquals(oAppFilters.Id, pgCont.sIECApplicationFiltersID, 'The app filter Id should be loaded correctly');
	    		system.assertEquals(oAppFilters.Id, pgCont.oApplicationFilters.Id, 'The app filter should be loaded correctly');
	    		system.assertEquals(2, pgCont.lstAgencies == null ? 0 : pgCont.lstAgencies.size(), '2 agencies should be found');
	    		system.assertEquals(2, pgCont.iTotalResult, 'The total result should be appropriated');
	    		for (GDP_Products_Account_View__c agency : pgCont.lstAgencies)
	    			system.assert(agency.Id == oGDPAccount1.ID || agency.Id == oGDPAccount2.ID, 'agency1 and agency2 should be found (agency3 is terminated)');

	    		// un-terminate agency3
		    	oAccreditation3.Status__c = oRefAgencyStatus.Id;
		    	update oAccreditation3;
                bat = new SchdlGDPProductsAccountSnapshotCleanup();
                List<GDP_Products_Account_View__c> gpav = Database.query(SchdlGDPProductsAccountSnapshotCleanup.query);
                bat.execute(null, gpav);

	    		pgCont = new vfIECGADResult(2); // since we'll have 3 agencies, use 2 per page so we can have 2 pages
	    		pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, IECUtil.EncryptEncodeParameter(oAppFilters.Id));
	    		pgCont.pageLoad();
	    		system.assert(pgCont.lstAgencies != null && pgCont.lstAgencies.size() == 3, 'All 3 agencies should be found');
	    		system.assert(pgCont.sTextRepresentationOfFilters=='', 'The text search criteria should be empty');
	    		
	    		// Test #4 - browse tru the pages
	    		system.assertEquals(0, pgCont.iCurrentPageIndex, 'Page index should be 0');
	    		system.assertEquals(2, pgCont.iTotalPage, 'Total nbr of page should be 2');
	    		system.assertEquals(false, pgCont.bPreviousPageIsEnabled, 'We are at the first page so previous page link should be disabled');
	    		system.assertEquals(true, pgCont.bNextPageIsEnabled, 'We are at the first page of 2 so next page link should be enabled');
	    		system.assertEquals(false, pgCont.bShowStateProvinceColumn, 'State/Province column shoud not be displayed');
	    		system.assertEquals(false, pgCont.bShowCityColumn, 'City column shoud not be displayed');
	    		system.assertEquals(false, pgCont.bShowZipPostalCodeColumn, 'Zip/Postal Code column shoud not be displayed');
	    		system.assertEquals(false, pgCont.bShowLegalName, 'By default, Trading Name should be displayed');
	    		pgCont.nextPage();
	    		system.assertEquals(1, pgCont.iCurrentPageIndex, 'Page index should be 1');
	    		system.assertEquals(true, pgCont.bPreviousPageIsEnabled, 'We are at the second page so previous page link should be enabled');
	    		system.assertEquals(false, pgCont.bNextPageIsEnabled, 'We are at the second page of 2 so next page link should be disabled');
	    		pgCont.previousPage();
	    		system.assertEquals(0, pgCont.iCurrentPageIndex, 'Page index should be 0');
	    		system.assertEquals(false, pgCont.bPreviousPageIsEnabled, 'We are at the first page so previous page link should be disabled');
	    		
	    		// Test #5 - browse tru the agencies from the detail view
	    		pgCont.selectAgency();
	    		pgCont.previousAgency();
	    		pgCont.nextAgency();
	    		pgCont.sSelectedAgencyId = oGDPAccount2.Id;
	    		pgCont.selectAgency();
	    		system.assertEquals(oGDPAccount2.Id, pgCont.sAgencyIDToViewDetail, 'The appropriate agency id should be selected');
	    		system.assertEquals(1, pgCont.iCurrentAgencyIndex, 'Index of Agency should be 1');
	    		system.assertEquals(true, pgCont.bPreviousAgencyIsEnabled, 'bPreviousAgencyIsEnabled should be true');
	    		system.assertEquals(true, pgCont.bNextAgencyIsEnabled, 'bNextAgencyIsEnabled should be true');
	    		pgCont.previousAgency();
	    		system.assertEquals(0, pgCont.iCurrentAgencyIndex, 'Index of Agency should be 0');
	    		system.assertEquals(false, pgCont.bPreviousAgencyIsEnabled, 'bPreviousAgencyIsEnabled should not be true');
	    		system.assertEquals(true, pgCont.bNextAgencyIsEnabled, 'bNextAgencyIsEnabled should be true');
	    		pgCont.nextAgency();
	    		pgCont.nextAgency();
	    		system.assertEquals(2, pgCont.iCurrentAgencyIndex, 'Index of Agency should be 2');
	    		system.assertEquals(true, pgCont.bPreviousAgencyIsEnabled, 'bPreviousAgencyIsEnabled should be true');
	    		system.assertEquals(false, pgCont.bNextAgencyIsEnabled, 'bNextAgencyIsEnabled should not be true');
	    		
	    		pgCont.backToResultList();
	    		system.assertEquals(null, pgCont.sAgencyIDToViewDetail, 'sAgencyIDToViewDetail should be null');
	    		system.assertEquals(0, pgCont.iCurrentAgencyIndex, 'iCurrentAgencyIndex should be reset to 0');
	    		
	    		pgCont.backToSearchPage();
	    	}
		}
		catch(Exception ex) {
			system.assert(false, 'Test testDisplayAgencyDetails should not throw an exception: ' + ex.getMessage() + '\r\n' + ex.getStacktraceString());
		}
	}
	
	@isTest(SeeAllData=true)
	static void testDisplayAgencyList_Misc() {
    	// Set current page
		PageReference pgRef = Page.IECGADResult;
		Test.setCurrentPage(pgRef);
		
		vfIECGADResult pgCont = new vfIECGADResult(); // test default constructor
		pgCont.pageLoad();
		String sTest = pgCont.sProductCode;
	}
}