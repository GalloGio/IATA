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

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'); 
        
        oAgencyAccount = IECTestUtil.createSampleAccount();
        oAgencyAccount.Name = AGENCY1_NAME;
        oAgencyAccount.IATACode__c = AGENCY1_CODE;
        oAgencyAccount.Status__c = 'Approved';
        oAgencyAccount.RecordTypeId = rtId;
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