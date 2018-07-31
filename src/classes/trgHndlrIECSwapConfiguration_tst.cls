/**  
  * Description: This class contains unit tests for the (Swap Configuration) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

@isTest(SeeAllData=true)
private class trgHndlrIECSwapConfiguration_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product_Information__c oProductInfo2;
	private static Product2 oProduct;
	private static Product2 oProduct2;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlan__c oProductRatePlan2;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge2;	
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
		
		oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
    	insert oProductRatePlanCharge;
    	
    	oProductRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan2, 'CHARGETEST', 1);
    	insert oProductRatePlanCharge2;
		
		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
		insert oProductRatePlanInfo;
		
		oProductRatePlanInfo2 = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST2', false, oProductRatePlan2, oProductInfo2);
		insert oProductRatePlanInfo2;
	}
	
    static testMethod void TestSwapConfiguration() {
    	System.debug('Unit Test: Start: TestSwapConfiguration');

    	Init();
    	
		// 001: The Swap Config is created with no errors
        oSwapConfig = new Swap_Configuration__c (
        	Source_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id, 
			Target_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id,
			Relationship_Type__c = IECConstants.SwappingType_Swap);
		insert oSwapConfig;
		update oSwapConfig;
		
        system.assertNotEquals(oSwapConfig.Id, null, 'Swap Config must have been created with no errors.');
				
		// 002: Try to reinsert it and it will fail
		try {
	        oSwapConfig2 = new Swap_Configuration__c (
	        	Source_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id, 
				Target_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id,
				Relationship_Type__c = IECConstants.SwappingType_Swap);
			insert oSwapConfig2;
		}
		catch (Exception e) {
			system.assert(e.getMessage().contains(Label.IEC_Error_OnlyOneSwapConfiguration), 'Swap Config must raise an exception.');
		}
		
    	System.debug('Unit Test: Finish: TestSwapConfiguration');
    }
}