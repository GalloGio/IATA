/**  
  * Description: This class contains unit tests for the (Product Rate Plan Information) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

@isTest(SeeAllData=true)
private class trgIECProductRatePlanInformation_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product_Information__c oProductInfo2;
	private static Product2 oProduct;
	private static Product2 oProduct2;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlan__c oProductRatePlan2;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo2;
	private static Swap_Configuration__c oSwapConfig;
	private static Swap_Configuration__c oSwapConfig2;
	
	private static void Init() {
        oProductCategory = IECTestUtil.CreateSampleProductCategory('PCTST', true);
		insert oProductCategory;
		
		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		insert oProduct;
		
		oProduct2 = IECTestUtil.CreateSampleProduct2('PTST2');
		insert oProduct2;
		
		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;
		
		oProductInfo2 = IECTestUtil.CreateSampleProductInfo2('PITST2', oProductCategory, oProduct2);
		oProductInfo2.Product_Audience__c = IECConstants.ProductInformationAudience_MEMBERAIRLINE;
		insert oProductInfo2;
		
		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
		insert oProductRatePlan;
		
		oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('PRPTST2', false, oProduct2);
    	insert oProductRatePlan2;
		
		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
		insert oProductRatePlanInfo;
		
		oProductRatePlanInfo2 = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST2', false, oProductRatePlan2, oProductInfo2);
		oProductRatePlanInfo2.Subscription_Usage_Qty__c = 0;
		insert oProductRatePlanInfo2;
		
        oSwapConfig = new Swap_Configuration__c (
        	Source_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id, 
			Target_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id,
			Relationship_Type__c = IECConstants.SwappingType_Upgrade);
		insert oSwapConfig;
	}
	
    static testMethod void TestProductRatePlanInfo() {
    	System.debug('Unit Test: Start: TestProductRatePlanInfo');

    	Init();
    	
		// 001: Try to modify the unlimited plan to a limited plan
		try {
			oProductRatePlanInfo2.Subscription_Usage_Qty__c = 500;
			update oProductRatePlanInfo2;
		}
		catch (Exception e) {
			system.assert(e.getMessage().contains(Label.IEC_Error_CannotSwitchToLimited), 'Update rate plan must raise an exception.');
		}
		
    	System.debug('Unit Test: Finish: TestProductRatePlanInfo');
    }
}