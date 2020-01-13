/**
  * Description: This class contains unit tests for the (Recommended Products) component
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */
@isTest(SeeAllData=true)
private class vfIECRecommended_tst {
	static testMethod void TestRecommended() {
		System.debug('Unit Test: Start: TestRecommended');

		// First create a sample product to use it in testing
		Product_Category__c pc1 = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST + '1', true);
		insert pc1;

		Product_Category__c pc2 = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST + '2', true);
		insert pc2;

		Product_Category__c pc3 = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST + '3', true);
		insert pc3;

		//Instantiate Controller
		vfIECRecommended pgCont = new vfIECRecommended();

		//Test 001: Set the product code to something non existing
		pgCont.sProductCode = IECConstants.ProductCategory_SF_TEST + '0';
		system.assertEquals(null, pgCont.oProductCategory, 'No product category should be found.');
		system.assertEquals(false, pgCont.bDisplayComponent, 'Component must be hidden.');
		system.assertEquals(false, pgCont.bDisplayProduct1, 'Product 1 must be hidden.');
		system.assertEquals(false, pgCont.bDisplayProduct2, 'Product 2 must be hidden.');

		//Test 002: Set the product code to something existing, but with no recommended products
		pgCont.sProductCode = IECConstants.ProductCategory_SF_TEST + '1';
		system.assertNotEquals(null, pgCont.oProductCategory, 'Product category must not be null.');
		system.assertEquals(false, pgCont.bDisplayComponent, 'Component must be hidden.');
		system.assertEquals(false, pgCont.bDisplayProduct1, 'Product 1 must be hidden.');
		system.assertEquals(false, pgCont.bDisplayProduct2, 'Product 2 must be hidden.');

		//Test 003: Set the product code to something existing, but with Product1 only recommended
		pc1.Recommended_Product_Category_1__c = pc2.Id;
		pc1.Recommended_Product_Category_2__c = null;
		update pc1;
		pgCont.sProductCode = IECConstants.ProductCategory_SF_TEST + '1';
		system.assertNotEquals(null, pgCont.oProductCategory, 'Product category must not be null.');
		system.assertEquals(true, pgCont.bDisplayComponent, 'Component must not be hidden.');
		system.assertEquals(true, pgCont.bDisplayProduct1, 'Product 1 must not be hidden.');
		system.assertEquals(false, pgCont.bDisplayProduct2, 'Product 2 must be hidden.');

		//Test 004: Set the product code to something existing, but with Product2 only recommended
		pc1.Recommended_Product_Category_1__c = null;
		pc1.Recommended_Product_Category_2__c = pc3.Id;
		update pc1;
		pgCont.sProductCode = IECConstants.ProductCategory_SF_TEST + '1';
		system.assertNotEquals(null, pgCont.oProductCategory, 'Product category must not be null.');
		system.assertEquals(true, pgCont.bDisplayComponent, 'Component must not be hidden.');
		system.assertEquals(false, pgCont.bDisplayProduct1, 'Product 1 must be hidden.');
		system.assertEquals(true, pgCont.bDisplayProduct2, 'Product 2 must not be hidden.');

		//Test 005: Set the product code to something existing, but with 2 products recommended
		pc1.Recommended_Product_Category_1__c = pc2.Id;
		pc1.Recommended_Product_Category_2__c = pc3.Id;
		update pc1;
		pgCont.sProductCode = IECConstants.ProductCategory_SF_TEST + '1';
		system.assertNotEquals(null, pgCont.oProductCategory, 'Product category must not be null.');
		system.assertEquals(true, pgCont.bDisplayComponent, 'Component must not be hidden.');
		system.assertEquals(true, pgCont.bDisplayProduct1, 'Product 1 must not be hidden.');
		system.assertEquals(true, pgCont.bDisplayProduct2, 'Product 2 must not be hidden.');

		//Test 006: Click on first recommendation
		pgCont.iProduct = 1;
		pgCont.onClickProduct();

		//Test 006: Click on second recommendation
		pgCont.iProduct = 2;
		pgCont.onClickProduct();

		System.debug('Unit Test: Finish: TestRecommended');
	}
}
