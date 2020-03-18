/**
 * Test class for the visualforce controller VfIECTermsAndConditionsComponent
 */
@isTest
private class VfIECTermsAndConditionsComponent_tst {

	static testMethod void testController() {

		VfIECTermsAndConditionsComponent controller = new VfIECTermsAndConditionsComponent();

		// insert dummy product category
		Product_Category__c myProdCat = IECTestUtil.CreateSampleProductCategory('TESTPRODCAT', true);
		insert myProdCat;

		// create dummy Zuora product
		Product2 prod = IECTestUtil.CreateSampleProduct2('My Product');
		prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
		prod.ProductCategory__c = IECConstants.ProductCategory_SF_CACPRO;
		insert prod;

		// create dummy product info
		Product_Information__c myProdInfo = IECTestUtil.CreateSampleProductInfo2('My product', myProdCat, prod);
		insert myProdInfo;

		// create a Terms & Conditions
		Terms_and_Conditions__c oTC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', myProdInfo, true);
		insert oTC;

		// create dummy Attachment for the T&C
		Attachment oAttachment = IECTestUtil.CreateSampleAttachment(oTC.Id);
		insert oAttachment;

		// set the effective date of the T&C
		oTC.Effective_Start_Date__c = Date.today().addDays(-5);
		update oTC;

		controller.listProductInformationIDs = new String[] {myProdInfo.Id};

		List<Terms_and_Conditions__c> listTC = controller.listTermsAndConditions;
		system.assert(controller.hasTermsAndConditions, 'The vf component should be able to retreive a Terms And Conditions');

		system.assert(controller.hasAcceptedAllTCs == false, 'T&C are not supposed to be accepted.');

		// accept all T&C
		for (VfIECTermsAndConditionsComponent.UITermsAndConditions uiTnC : controller.listTermsAndConditionsToDisplay)
			uiTnC.checked = true;

		system.assertEquals(true, controller.hasAcceptedAllTCs, 'T&C are supposed to be all accepted.');

		// reset acceptance
		controller.reset();
		system.assertEquals(false, controller.hasAcceptedAllTCs, 'T&C acceptance is supposed to be reseted.');
	}
}
