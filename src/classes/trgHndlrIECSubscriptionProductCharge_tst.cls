/**  
  * Description: This class contains unit tests for the (Subscription Product Charge) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

@isTest(SeeAllData=true)
private class trgHndlrIECSubscriptionProductCharge_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionCharge;
	
    static testMethod void TestSubscriptionCharge() {
    	System.debug('Unit Test: Start: TestSubscriptionCharge');
        // create dummy Zuora product
    	oProduct = IECTestUtil.CreateSampleProduct2('Product1');
    	oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
    	insert oProduct;
    	
    	// create dummy Zuora rate plan
    	oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, oProduct);
    	oProductRatePlan.zqu__Deleted__c = false;
    	insert oProductRatePlan;
    	
    	// create dummy Zuora rate plan oProductRatePlanCharge
    	oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 42);
    	oProductRatePlanCharge.zqu__Deleted__c = false;
    	insert oProductRatePlanCharge;
    	
    	// create dummy product category
        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST, true);
        oProductCategory.Active__c = true;
        insert oProductCategory;
        
        // create dummy product info
        oProductInfo = IECTestUtil.CreateSampleProductInfo2('My product', oProductCategory, oProduct);
        insert oProductInfo;
        
        // create dummy rate plan information
        oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, oProductRatePlan, oProductInfo);
        oProductRatePlanInfo.Display_As_Monthly_Fee__c = false;
        oProductRatePlanInfo.Active__c = true;
        oProductRatePlanInfo.Order__c = 1;
        insert oProductRatePlanInfo;
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
			IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
	        
	        // create dummy subscription
	        subscription = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
	        insert subscription;
	        
	        // create dummy subscription charge
	        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
	        insert subscriptionCharge;
	        update subscriptionCharge;
        }
        
        // Make sure that the product linking has occured
        system.assertEquals([SELECT Product_Rate_Plan_Charge__c FROM Zuora__SubscriptionProductCharge__c WHERE Id = :subscriptionCharge.Id].Product_Rate_Plan_Charge__c, oProductRatePlanCharge.Id);
        system.assertEquals([SELECT Product_Rate_Plan_Information__c FROM Zuora__Subscription__c WHERE Id = :subscription.Id].Product_Rate_Plan_Information__c, oProductRatePlanInfo.Id);
    	
    	System.debug('Unit Test: Finish: TestSubscriptionCharge');
    }
}