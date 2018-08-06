/**
 * Description: This class contains unit tests for the Subscription trigger
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
 */
@isTest(SeeAllData=true)
private class trgHndlrIECSubscription_tst {

	private static Account oAccount;
	private static Contact oContact;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static User usr;
    private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlan__c oProductRatePlan2;
	private static zqu__ProductRatePlan__c oProductRatePlan3;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge2;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge3;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo2;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo3;
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionCharge;
	
	private static final double QTY = 42.0;
	
	private static void setup() {
		usr = IECTestUtil.createSampleGuestUserAndLogin();
		
		oContact = [Select Id, Name, AccountId from Contact where Id = :usr.ContactId limit 1];

		oAccount = [Select Id, Name from Account where Id = :oContact.AccountId limit 1];
		
		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
		insert oBillingAccount;

		// create dummy Zuora product
    	oProduct = IECTestUtil.CreateSampleProduct2('Product1');

    	oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;

    	insert oProduct;

    	// create dummy Zuora rate plan
    	oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, oProduct);
    	oProductRatePlan.zqu__Deleted__c = false;
    	insert oProductRatePlan;
    	
    	oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 2', false, oProduct);
    	oProductRatePlan2.zqu__Deleted__c = false;
    	insert oProductRatePlan2;
    	
    	oProductRatePlan3 = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 3', false, oProduct);
    	oProductRatePlan3.zqu__Deleted__c = false;
    	insert oProductRatePlan3;

    	// create dummy Zuora rate plan oProductRatePlanCharge
    	oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 42);
    	oProductRatePlanCharge.zqu__Deleted__c = false;
    	insert oProductRatePlanCharge;

    	oProductRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan2, 'CHARGETEST', 84);
    	oProductRatePlanCharge2.zqu__Deleted__c = false;
    	insert oProductRatePlanCharge2;
    	
    	oProductRatePlanCharge3 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan3, 'CHARGETEST', 0);
    	oProductRatePlanCharge3.zqu__Deleted__c = false;
    	insert oProductRatePlanCharge3;
    	
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
        oProductRatePlanInfo.Subscription_Usage_Qty__c = QTY;
        insert oProductRatePlanInfo;
        
        oProductRatePlanInfo2 = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 2', false, oProductRatePlan2, oProductInfo);
        oProductRatePlanInfo2.Display_As_Monthly_Fee__c = false;
        oProductRatePlanInfo2.Active__c = true;
        oProductRatePlanInfo2.Order__c = 2;
        oProductRatePlanInfo2.Subscription_Usage_Qty__c = QTY * 2;
        insert oProductRatePlanInfo2;
        
        oProductRatePlanInfo3 = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 3', false, oProductRatePlan3, oProductInfo);
        oProductRatePlanInfo3.Display_As_Monthly_Fee__c = false;
        oProductRatePlanInfo3.Active__c = true;
        oProductRatePlanInfo3.Order__c = 3;
        oProductRatePlanInfo3.Subscription_Usage_Qty__c = 0;
        insert oProductRatePlanInfo3;

	}
	
    static testMethod void TestSubscription() {

		setup();

        System.runAs(usr) {
        	
	        // create dummy subscription
	        subscription = IECTestUtil.createSampleSubscription(oAccount.Id, 'Subs 01', Date.today().addMonths(6));
	        subscription.Zuora__CustomerAccount__c = oBillingAccount.Id;

	        insert subscription;

	        // create dummy subscription charge
	        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);

	        insert subscriptionCharge;

	        // Test #1 - check if the Product Access has been created
	        List<IEC_Product_Access__c> lstProductAccess = [Select Id, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, 
	        Active__c, Related_Contact__c, Subscription_Number__c, Related_Rate_Plan_Info__c from IEC_Product_Access__c 
	        where Zuora_Subscription_Id__c =: subscription.Zuora__Zuora_Id__c];
	        system.assert(lstProductAccess.size() > 0, 'A Product Access should be found');
	        
	        IEC_Product_Access__c oProductAccess = lstProductAccess.get(0);
	        system.assertEquals(oProductRatePlanInfo.Id, lstProductAccess.get(0).Related_Rate_Plan_Info__c, 'Product Access must have the proper Rateplan assigned');
	        system.assertEquals(QTY, oProductAccess.Usage_Qty_Start__c, 'The start quantity should be set according to the predefined value');
	        system.assertEquals(QTY, oProductAccess.Usage_Qty_Left__c, 'The left quantity should be set according to the predefined value');
	        
	        // Test #2 - run trigger a second time, make sure that another Product Access object has not been created
	        update subscription;
	        lstProductAccess = [Select Id, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, Active__c, Related_Contact__c, Subscription_Number__c from IEC_Product_Access__c where Zuora_Subscription_Id__c =: subscription.Zuora__Zuora_Id__c];
	        system.assert(lstProductAccess.size() == 1, 'One Product Access should be found');
	        
	        // Test #3 - Update RatePlanInfo on the subscription to a limited rate plan
	        subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id;
	        subscription.Zuora__External_Id__c = IECUtil.NewGuid().substring(0, 32);
	        update subscription;
	        lstProductAccess = [Select Id, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, Active__c, Related_Contact__c, Subscription_Number__c, Related_Rate_Plan_Info__c from IEC_Product_Access__c where Zuora_Subscription_Id__c =: subscription.Zuora__Zuora_Id__c];
	        system.assertEquals(1, lstProductAccess.size(), 'One Product Access should be found');
	        system.assertEquals(oProductRatePlanInfo2.Id, lstProductAccess.get(0).Related_Rate_Plan_Info__c, 'Product Access must update the rateplan');
	        system.assertEquals(QTY * 2, lstProductAccess.get(0).Usage_Qty_Start__c, 'Product Access must update the rateplan');
	        
	        // Test #4 - Update RatePlanInfo on the subscription to an unlimited rate plan
	        subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo3.Id;
	        update subscription;
	        lstProductAccess = [Select Id, Usage_Qty_Start__c, Usage_Qty_Left__c, Usage_Unlimited__c, Active__c, Related_Contact__c, Subscription_Number__c, Related_Rate_Plan_Info__c from IEC_Product_Access__c where Zuora_Subscription_Id__c =: subscription.Zuora__Zuora_Id__c];
	        system.assertEquals(1, lstProductAccess.size(), 'One Product Access should be found');
	        system.assertEquals(oProductRatePlanInfo3.Id, lstProductAccess.get(0).Related_Rate_Plan_Info__c, 'Product Access must update the rateplan');
	        system.assertEquals(true, lstProductAccess.get(0).Usage_Unlimited__c, 'Product Access must update the rateplan');
        }
    }
}