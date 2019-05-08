@isTest
private class VfIECRatePlansComponent_tst {

    static testMethod void testVfIECRatePlansComponent() {
        
        // create dummy Zuora product
    	Product2 prod = IECTestUtil.CreateSampleProduct2('Product1');
    	prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	prod.ProductCategory__c = IECConstants.ProductCategory_SF_CACPRO;
    	insert prod;
    	
    	// create dummy Zuora rate plan
    	zqu__ProductRatePlan__c ratePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, prod);
    	ratePlan.zqu__Deleted__c = false;
    	insert ratePlan;
    	
    	// create dummy Zuora rate plan charge
    	zqu__ProductRatePlanCharge__c charge = IECTestUtil.CreateSampleProductRatePlanCharge(ratePlan, 'Charge 1', 42);
    	charge.zqu__Deleted__c = false;
    	insert charge;
    	
    	// create dummy product category
        Product_Category__c myProdCat = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
        myProdCat.Active__c = true;
        insert myProdCat;
        
        // create dummy product info
        Product_Information__c myProdInfo = IECTestUtil.CreateSampleProductInfo2('My product', myProdCat, prod);
        myProdInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
        insert myProdInfo;
        
        // create dummy rate plan information
        Product_Rate_Plan_Information__c ratePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, ratePlan, myProdInfo);
        ratePlanInfo.Display_As_Monthly_Fee__c = false;
        ratePlanInfo.Active__c = true;
        insert ratePlanInfo;
        
        Test.startTest();
        
        VfIECRatePlansComponent component = new VfIECRatePlansComponent();
        component.bDisplayPrice = true;
        
        // Test #1 - missing product category code
        List<Product_Rate_Plan_Information__c> listRatePlans = component.lstRatePlansInformation;
        system.assert(listRatePlans == null || listRatePlans.isEmpty(), 'No Rate plans should be found since we didnt provide a Product Category Code');
        
        // set an unexisting product category code
        component.sProductCategoryCode = IECConstants.ProductCategory_SF_GAD;
        
        // Test #2 - test find rate plans - no result
        system.assert(component.lstRatePlansInformation == null || component.lstRatePlansInformation.isEmpty(), 'Rate Plans should not be found');
        
        // set the product category code
        component.sProductCategoryCode = IECConstants.ProductCategory_SF_CACPRO;
        
        // Test #3 - test find rate plans
        system.assert(component.lstRatePlansInformation != null && !component.lstRatePlansInformation.isEmpty(), 'Rate Plans should be found');
        
        Integer i = component.iNbrRatePlans;
        
        // Test #4 - add item to cart
        component.selectedRatePlanInformationId = ratePlanInfo.Id;
        Pagereference pref = component.addToCart();
        
        // Test #5 - trial
        component.selectedRatePlanInformationId = ratePlanInfo.Id;
        pref = component.tryMe();

        Test.stopTest();
    }
}