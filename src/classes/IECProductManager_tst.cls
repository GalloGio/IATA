/**  
  * Description: Test the class IECProductManager_tst
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
@isTest
private class IECProductManager_tst {

    static testMethod void testProductCategories() {
        
        // insert dummy product category
        Product_Category__c myProdCat = IECTestUtil.CreateSampleProductCategory('TESTPRODCAT', true);
        // set product category as inactive
        myProdCat.Active__c = false;
        insert myProdCat;
        
        Test.startTest();
        
        // Test #1 - no active product category
        List<Product_Category__c> listProductCategory = IECProductManager.getAllProductsCategory();
        system.assert(listProductCategory == null || listProductCategory.size() == 0);
        
        // Test #2 - get active product category
        myProdCat.Active__c = true;
        update myProdCat;
        listProductCategory = IECProductManager.getAllProductsCategory();
        system.assert(listProductCategory != null && listProductCategory.size() == 1);
        
        // Test #3 - test product category for inexisting feature
        listProductCategory = IECProductManager.getProductsCategoryByFeature('no me gusta');
        system.assert(listProductCategory == null || listProductCategory.size() == 0);
        
        // Test #4 - test product category for existing feature
        myProdCat.Product_Feature__c = IECConstants.ProductCategoryFeature_DATA;
        update myProdCat;
        listProductCategory = IECProductManager.getProductsCategoryByFeature(IECConstants.ProductCategoryFeature_DATA);
        system.assert(listProductCategory != null && listProductCategory.size() == 1);
        
        // Test #5 - get product category by product category code
        listProductCategory = IECProductManager.getProductsCategoryByProductCategoryCode('TESTPRODCAT');
        system.assert(listProductCategory != null && listProductCategory.size() == 1);
        
        Test.stopTest();
    }
    
    static testMethod void testRatePlansInformation() {
    	
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
        myProdInfo.Product_Audience__c = IECConstants.ProductInformationAudience_MEMBERAIRLINE;
        insert myProdInfo;
        
        // create dummy rate plan information
        Product_Rate_Plan_Information__c ratePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, ratePlan, myProdInfo);
        ratePlanInfo.Display_As_Monthly_Fee__c = false;
        insert ratePlanInfo;
            	
        // Test #1 - anonymous users
        List<Product_Information__c> listProductInformationAnonymous = IECProductManager.getProductInformationsByCategoryForAnonymousUser(IECConstants.ProductCategory_SF_CACPRO);
        system.assert(listProductInformationAnonymous == null || listProductInformationAnonymous.isEmpty());
            	
        // Test #2 - Member Airline
		List<Product_Information__c> listProductInformation = IECProductManager.getProductInformationsByCategoryByClientType(IECConstants.ProductCategory_SF_CACPRO, IECConstants.Account_ClientType_MemberAirline);
        system.assert(listProductInformation != null && listProductInformation.size() > 0);
    		
    	// Test #3 - rate plans
    	List<Product_Rate_Plan_Information__c> listRatePlansInfo = IECProductManager.getProductRatePlansInformationByProductInformation(myProdInfo);
    	system.assert(!listRatePlansInfo.isEmpty(), 'Rate Plans Informations should be returned as per test data');
    	
    		
    	// Test #3
    	Set<String> setRatePlanIds = new Set<String>();
    	setRatePlanIds.add(ratePlan.zqu__ZuoraId__c);
    	List<zqu__ProductRatePlan__c> lstRatePlans = IECProductManager.getZuoraRatePlansFromIDs(setRatePlanIds);
    	system.assert(lstRatePlans != null && lstRatePlans.size() > 0);
    	
    	// Test #3 - get the charges associated to a rate plan
    	List<zqu__ProductRatePlanCharge__c> lstRatePlanCharges = IECProductManager.getZuoraRatePlanChargesByRatePlanID(ratePlan.Id);
    	system.assertEquals(charge.Id, lstRatePlanCharges.get(0).Id);
    }

	@isTest(SeeAllData=true)
	static void testTermsAndConditions() {
		
		Terms_and_Conditions__c oFirstTnC;
		Terms_and_Conditions__c oSecondTnC;
		Attachment oFirstAttach;
		
		// create dummy product category
        Product_Category__c myProdCat = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
        myProdCat.Active__c = true;
        insert myProdCat;
        
        // create dummy Zuora product
    	Product2 prod = IECTestUtil.CreateSampleProduct2('My Product');
    	prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	prod.ProductCategory__c = IECConstants.ProductCategory_SF_CACPRO;
    	insert prod;
        
        // create dummy product info
        Product_Information__c myProdInfo = IECTestUtil.CreateSampleProductInfo2('My product', myProdCat, prod);
        insert myProdInfo;
        
        // create dummy Zuora rate plan
    	zqu__ProductRatePlan__c ratePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, prod);
    	ratePlan.zqu__Deleted__c = false;
    	insert ratePlan;
        
        // create dummy rate plan information
        Product_Rate_Plan_Information__c ratePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, ratePlan, myProdInfo);
        ratePlanInfo.Display_As_Monthly_Fee__c = false;
        insert ratePlanInfo;
        
        Test.startTest();
        
        // Test #1 - create a T&C in the past with no EffectiveDate or attachment
        try {
        	oFirstTnC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', myProdInfo, true);
        	insert oFirstTnC;
        	system.assert(true, 'Should able to create a Terms&Conditions that has no effective date and no attachment');
        }
        catch(Exception ex) {
        	system.assert(false, 'Should able to create a Terms&Conditions that has no effective date and no attachment. Ex: ' + ex.getMessage());
        }
        
        // Test #2 - create a T&C in the past with an EffectiveDate and no attachment (ERROR)
        try {
        	Terms_and_Conditions__c oTnC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', myProdInfo, datetime.now().addDays(-2), true);
        	insert oTnC;
        	system.assert(false, 'Should not be able to create a Terms&Conditions that has an effective date and no attachment');
        }
        catch(Exception ex) {
        	system.assert(true, 'Should not be able to create a Terms&Conditions that has an effective date and no attachment');
        }
        
        // Test #3 - set an effective date on a T&C that has no attachment (ERROR)
        try {
        	oFirstTnC.Effective_Start_Date__c = datetime.now().addDays(1);
        	update oFirstTnC;
        	system.assert(false, 'Should not be able to set an effective date on a T&C that has no attachment');
        }
        catch(Exception ex) {
        	system.assert(true, 'Should not be able to set an effective date on a T&C that has no attachment');
        }
        
        // Test #4 - add an attachment and then update the Effective date
        try {
        	oFirstAttach = IECTestUtil.CreateSampleAttachment(oFirstTnC.Id);
        	insert oFirstAttach;
        	system.assert(true, 'Should be able to create an Attachment for a T&C that hasn\'t got one');
        	
        	system.assert(IECProductManager.isTermsAndConditionsHasAttachment(oFirstTnC.Id), 'The Attachment should be linked to the T&C');
        	system.assert(IECProductManager.hasTnCBeenAcceptedByACustomer(oFirstTnC.Id) == false, 'The T&C should not be accepted yet');
        	
        	oFirstTnC.Effective_Start_Date__c = datetime.now().addSeconds(-1);
        	update oFirstTnC;
        	system.assert(true, 'Should be able to set the Effective date of a T&C when it has an attachment');
        }
        catch(Exception ex) {
        	system.assert(false, 'Should be able to create an Attachment and be able to set the Effective date of a T&C when it has an attachment. Ex: ' + ex.getMessage());
        }
        
        // Test #5 - update a T&C when it hasnt yet been accepted by a customer
        try {
        	oFirstTnC.Name = 'My T&Cs test';
        	update oFirstTnC;
        	system.assert(true, 'Should be able to update a T&C when it hasnt yet been accepted by a customer');
        }
        catch(Exception ex) {
        	system.assert(false, 'Should be able to update a T&C when it hasnt yet been accepted by a customer. Ex: ' + ex.getMessage());
        }
        
        // Test #6 - update the Attachment when it hasnt yet been accepted by a customer
        try {
        	oFirstAttach.Name = 'blabla';
        	update oFirstAttach;
        	system.assert(true, 'Should be able to update an Attachment related to a T&C that hasnt yet been accepted by a customer');
        }
        catch(Exception ex) {
        	system.assert(false, 'Should be able to update an Attachment related to a T&C that hasnt yet been accepted by a customer. Ex: ' + ex.getMessage());
        }
        
        // Test #7 - delete the Attachment when there is an Effective Start Date (ERROR)
        try {
        	delete oFirstAttach;
        	system.assert(false, 'Should not be able to delete the Attachment when there is an Effective Start Date');
        }
        catch(Exception ex) {
        	system.assert(true, 'Should not be able to delete the Attachment when there is an Effective Start Date');
        }
        
        // Test #8 - delete the Effective Start Date and then delete the attachment
        try {
        	oFirstTnC.Effective_Start_Date__c = null;
        	update oFirstTnC;
        	system.assert(true, 'Should be able to delete the Effective Start Date when the T&C hasnt been accepted yet');
        	
        	delete oFirstAttach;
        	system.assert(true, 'Should be able to delete the Attachment when there is no Effective Start Date');
        }
        catch(Exception ex) {
        	system.assert(false, 'Should be able to delete the Effective Start Date and then delete the attachment when the T&C hasnt been accepted yet. Ex: ' + ex.getMessage());
        }
        
        // Test #9 - cannot create more than 1 attachment per T&C
        try {
        	oFirstAttach = IECTestUtil.CreateSampleAttachment(oFirstTnC.Id);
        	insert oFirstAttach;
        	system.assert(true, 'Should be able to create an Attachment for a T&C that hasn\'t got one');
        	
        	Attachment oSecondAttach = IECTestUtil.CreateSampleAttachment(oFirstTnC.Id);
        	insert oSecondAttach;
        	system.assert(false, 'Should not be able to create a second Attachment for a T&C that already has one');
        }
        catch (Exception ex) {
        	system.assert(true, 'Should not be able to create a second Attachment for a T&C that already has one');
        }
        
        // create a Subscription History object to simulate that a customer has accepted the t&C
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
    	System.runAs(usr) {
    		IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
			Account billingAccount = currentCustomer.RelatedAccount; 
        	IEC_Subscription_History__c oSubHist = IECTestUtil.createSampleSubscriptionHistory(currentCustomer, 'S-9876543210', myProdCat.Id, myProdInfo.Id, ratePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, oFirstTnC);
			insert oSubHist;
			
			system.assert(IECProductManager.hasTnCBeenAcceptedByACustomer(oFirstTnC.Id), 'The T&C should be accepted yet');
    	}
        
        
		// NOTE: from now on, the Terms & Conditions object or the Attachment cannot be updated or deleted
		
		
		// Test #10 - update the Terms & Conditions when it already has been accepted (ERROR)
        try {
        	oFirstTnC.Name = 'some name';
        	update oFirstTnC;
        	system.assert(false, 'Should not be able to update the Terms & Conditions when it already has been accepted');
        }
        catch(Exception ex) {
        	system.assert(true, 'Should not be able to update the Terms & Conditions when it already has been accepted');
        }
        
        // Test #11 - delete the Terms & Conditions when it already has been accepted (ERROR)
        try {
        	delete oFirstTnC;
        	system.assert(false, 'Should not be able to delete the Terms & Conditions when it already has been accepted');
        }
        catch(Exception ex) {
        	system.assert(true, 'Should not be able to delete the Terms & Conditions when it already has been accepted');
        }
        
        // Test #12 - update the Attachment of a Terms & Conditions when it already has been accepted (ERROR)
        try {
        	oFirstAttach.Name = 'blabla';
        	update oFirstAttach;
        	system.assert(false, 'Should not be able to update the Attachment of a Terms & Conditions when it already has been accepted');
        }
        catch(Exception ex) {
        	system.assert(true, 'Should not be able to update the Attachment of a Terms & Conditions when it already has been accepted');
        }
        
        // Test #13 - delete the Attachment of a Terms & Conditions when it already has been accepted (ERROR)
        try {
        	delete oFirstAttach;
        	system.assert(false, 'Should not be able to delete the Attachment of a Terms & Conditions when it already has been accepted');
        }
        catch(Exception ex) {
        	system.assert(true, 'Should not be able to delete the Attachment of a Terms & Conditions when it already has been accepted');
        }
		
        Test.stopTest();
	}
}