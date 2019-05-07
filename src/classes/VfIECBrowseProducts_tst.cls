/**
 * This class contains the test method for the class VfIECBrowseProducts
 * Author: Alexandre McGraw
 * Version: 1.0
 * History: 
 */
@isTest(SeeAllData=true)
private class VfIECBrowseProducts_tst {
	private static Product_Category__c myProdCat;
	private static void Init() {
    	// create dummy Zuora product
    	Product2 prod = IECTestUtil.CreateSampleProduct2('Product1');
    	prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	prod.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
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
        myProdCat = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST, true);
        myProdCat.Active__c = true;
        myProdCat.Product_Feature__c = IECConstants.ProductCategoryFeature_DATA;
        insert myProdCat;
        
        // create dummy product info
        Product_Information__c myProdInfo = IECTestUtil.CreateSampleProductInfo2('My product', myProdCat, prod);
        myProdInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
        insert myProdInfo;
        
        // create dummy rate plan information
        Product_Rate_Plan_Information__c ratePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, ratePlan, myProdInfo);
        ratePlanInfo.Display_As_Monthly_Fee__c = false;
        insert ratePlanInfo;
	}

    static testMethod void testpgCont() {
    	Init();
    	
        Test.startTest();
        VfIECBrowseProducts pgCont = new VfIECBrowseProducts();
        //system.assert(!pgCont.lstDataProductCategories.isEmpty(), 'There should be one Data product category');
        
        pgCont.pageLoad();
        
        pgCont.browseToProductCategory();
        pgCont.selectedProductCategoryCode = myProdCat.Name;
        pgCont.browseToProductCategory();

		pgCont.selectedProductCategoryCode = null;
        pgCont.browseToProductCategoryPricing();
        pgCont.selectedProductCategoryCode = myProdCat.Name;
        pgCont.browseToProductCategoryPricing();
        Test.stopTest();
    }
    
    static testMethod void testpgContLoggedIn() {
    	Init();
    	
        Test.startTest();
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
        	VfIECBrowseProducts pgCont = new VfIECBrowseProducts();
    	}
		Test.stopTest();
    }
}