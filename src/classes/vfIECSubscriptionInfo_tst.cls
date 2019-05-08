/**
 * This class contains unit tests for validating the behavior of class vfIECSubscriptionInfo
 */
@isTest
private class vfIECSubscriptionInfo_tst {

    private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Terms_and_Conditions__c oTC;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static Zuora__Subscription__c oSubscription;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge;
	private static IEC_Subscription_History__c oSubscriptionHist;
	private static Account oAccount;
	private static Account oAgencyAccount;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static Contact oContact;
	private static IECCustomer currentCustomer;
	private static Date dtSubscriptionEnddate;
	
	static void setupData() {
		oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_GAD, true);
		insert oProductCategory;
		
		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		insert oProduct;
		
		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;

		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
		insert oProductRatePlan;

		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
		oProductRatePlanInfo.Display_As_Monthly_Fee__c = true;
		oProductRatePlanInfo.Subscription_Usage_Qty__c = null; // make it unlimited
		insert oProductRatePlanInfo;
		
		// create a Terms & Conditions
		oTC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true);
        insert oTC;
        
	}
	
	private static void initSubscription(){

		currentCustomer = IECCustomer.getCurrentIECCustomer();
		oAccount = currentCustomer.RelatedAccount; 
		oContact = currentCustomer.RelatedContact;
		oBillingAccount = currentCustomer.RelatedBillingAccount;
		
		dtSubscriptionEnddate = Date.today().addMonths(6);

		oSubscription = IECTestUtil.createSampleSubscription(oAccount.Id, 'Subs 01', dtSubscriptionEnddate);
		oSubscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
		oSubscription.Zuora__CustomerAccount__c = oBillingAccount.Id;
		insert oSubscription;
		
		// create dummy subscription charge
        oSubscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(oSubscription.Id, dtSubscriptionEnddate.addYears(-1).addDays(1), oProduct, oProductRatePlan);
        insert oSubscriptionCharge;
		
		oSubscriptionHist = IECTestUtil.createSampleSubscriptionHistory(oAccount.Id, oContact.Id, oSubscription.Name, oProductCategory.Id, oProductInfo.Id, oProductRatePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, oTC);
		insert oSubscriptionHist;
	}
	
	@isTest(SeeAllData=true)
	static void testController() {
		try {

			User u = IECTestUtil.createSampleGuestUserAndLogin();
	    	System.runAs(u) {

	    		Test.startTest();
	    		
	    		// setup data
				setupData();
				initSubscription();

				// trigger the Product Access creation
				update oSubscription;
				
				Test.stopTest();
				
				// Initilize subscription component        
		        vfIECSubscriptionInfo controller = new vfIECSubscriptionInfo(); 
		        controller.loggedCustomer = currentCustomer;
		        controller.sApplicationName = IECConstants.ProductCategory_SF_GAD;
		        
		        controller.validateAccess();
		        system.assert(String.isNotblank(controller.sSubscriptionName), 'Sub name should not be null');
		        system.assert(controller.dtSubscriptionEndDate != null, 'dtSubscriptionEndDate should not be null');
		        
		        controller.renewRatePlan();
		        controller.upgrade();
	    	}
	    }
	    catch (Exception ex) {
	    	system.assert(false, 'Test testController should not throw an exception: ' + ex.getMessage() + '\r\n' + ex.getStacktraceString());
	    }
	}	
}