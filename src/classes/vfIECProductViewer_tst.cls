/**
  * Description: This class contains unit tests for the (Product Viewer) webpage
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */
@isTest(SeeAllData=true)
private class vfIECProductViewer_tst {
	static testMethod void TestProductViewer() {
		System.debug('Unit Test: Start: TestProductViewer');

		// create dummy Zuora product
		Product2 prod = IECTestUtil.CreateSampleProduct2('Product1');
		prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
		prod.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
		insert prod;

		// First create a sample product to use it in testing
		Product_Category__c pc = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST, true);
		insert pc;

		Product_Information__c pi = IECTestUtil.CreateSampleProductInfo2('My product', pc, prod);
		pi.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert pi;

		//Set current page to Encryption Utility
		PageReference pgRef = Page.IECProductViewer;
		Test.setCurrentPage(pgRef);
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_TEST));

		//Instantiate Controller
		vfIECProductViewer pgCont = new vfIECProductViewer();
		pgCont.pageLoad();

		// Test the product retrieval process
		system.assertEquals(IECConstants.ProductCategory_SF_TEST, pgCont.sParamProductCode);
		system.assertEquals(pc.Display_Name__c, pgCont.sDisplayName);
		system.assertEquals(true, pgCont.bFeature1Show);

		System.debug('Unit Test: Finish: TestProductViewer');
	}

	static testMethod void TestProductViewer_Errors() {
		System.debug('Unit Test: Start: TestProductViewer_Errors');

		//Set current page to Encryption Utility
		PageReference pgRef = Page.IECProductViewer;
		Test.setCurrentPage(pgRef);

		//Instantiate Controller
		vfIECProductViewer pgCont = new vfIECProductViewer();
		pgCont.pageLoad();

		// Test the page generated an error for missing product code
		system.assert(ApexPages.getMessages().size() > 0);

		// Now add a product code that doesn't exist
		pgRef.getParameters().put('ProductCode', IECUtil.EncryptEncodeParameter('TEST'));

		pgCont.pageLoad();
		// Test the page generated an error for invalid product code
		system.assert(ApexPages.getMessages().size() > 0);

		System.debug('Unit Test: Finish: TestProductViewer_Errors');
	}
}
