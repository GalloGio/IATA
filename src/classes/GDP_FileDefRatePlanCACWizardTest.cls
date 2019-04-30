/**
 * This a basic test class for GDP_FileDefRatePlanCACWizard.cls
 *  - GDP_FileDefRatePlanCACWizard.cls
 *  - GDP_FileDefRatePlanCACWizard.page
 * 
 * Original Author: Sonny Leman
 *
 * Change log:
 *   2016-04-25-sl: initial version 
 *
 */
 
@isTest (SeeAllData=false)
private class GDP_FileDefRatePlanCACWizardTest {
	
	// ========================================================================
	// name for the zqu__Product
	private static final String PRODUCT_NAME_01 = 'Test Product 01';
	// name for the zqu__ProductRatePlan
	private static final String PRODUCT_RATE_PLAN_NAME_01 = 'Test Rate Plan 01 With No File Desc';
	private static final String PRODUCT_RATE_PLAN_NAME_02 = 'Test Rate Plan 02 With One File Desc';
    
	// ========================================================================
	// core data  preparation
	// create zqu__ZProduct, zqu__ProductRatePlan__c, zqu__ProductRatePlanCharge__c
	// testUser
	@testSetup private static void testDataPreparation(){
			
		User testUser = IECTestUtil.createSampleGuestUserAndLogin();
		
		Contact oContact = [Select Id, Name, AccountId from Contact where Id = :testUser.ContactId limit 1];
		Account oAccount = [Select Id, Name from Account where Id = :oContact.AccountId limit 1];
		
		Zuora__CustomerAccount__c oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
		insert oBillingAccount;
		
		// --------------------------------------------------------------------
		// create zuora product
		zqu__ZProduct__c oProduct = IECTestUtil.CreateSampleProduct(PRODUCT_NAME_01);
		oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
		oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
		insert oProduct;
		
		// --------------------------------------------------------------------
		// create zuora rate plan
		zqu__ProductRatePlan__c oProductRatePlan1 = IECTestUtil.CreateSampleProductRatePlan(PRODUCT_RATE_PLAN_NAME_01, false, oProduct);
		zqu__ProductRatePlan__c oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan(PRODUCT_RATE_PLAN_NAME_02, false, oProduct);
		zqu__ProductRatePlan__c oProductRatePlan3 = IECTestUtil.CreateSampleProductRatePlan('Rate plan 3', false, oProduct);
		List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c> {oProductRatePlan1, oProductRatePlan2, oProductRatePlan3};
		insert productRatePlanList;
		
		// --------------------------------------------------------------------
		// create dummy Zuora rate plan oProductRatePlanCharge
		zqu__ProductRatePlanCharge__c oProductRatePlanCharge1 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan1, 'CHARGETEST', 42);
		zqu__ProductRatePlanCharge__c oProductRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan2, 'CHARGETEST', 84);
		zqu__ProductRatePlanCharge__c oProductRatePlanCharge3 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan3, 'CHARGETEST', 0);
		List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c> {oProductRatePlanCharge1,oProductRatePlanCharge2,oProductRatePlanCharge3};
		insert productRatePlanChargeList;
		
		// for this test, skip oProductCategory
		// for this test, skip oProductInfo
		// for this test, skip oProductRatePlanInfo 
		
		// GDP_File_Description__c , w/ Product_Type__c : CAC, CACEWS, CACSWS
		List<GDP_File_Description__c> lCacFileDesc = CAC_TestLibrary.generateFileDescCACNonRef();
        System.assertNotEquals(null, lCacFileDesc[0].Id);
        GDP_File_Description_To_Rate_Plan__c  oSelectedGdpFileDescToRatePlan = new GDP_File_Description_To_Rate_Plan__c(
            			GDP_File_Description__c = lCacFileDesc[0].Id
            			, Product_Rate_Plan__c = oProductRatePlan2.Id); // this is PRODUCT_RATE_PLAN_NAME_02
        insert oSelectedGdpFileDescToRatePlan;
	} // end of testDataPreparation
	
	
	
	
	// ========================================================================
	// basic test scenario:
	//  - user opens GDP_FileDefRatePlanCACWizard.page with a given zqu__ProductRatePlan
	//  - the ProductRatePlan initially does not have any GDP_File_Description of CACWeb
	//  - user selects related GDP_File_Description__c and link it with zqu_ProductRatePlan, then save it
	//  - user remove selected GDP_File_Description__c and go back without saving
	static testMethod void test01_Basic() {
		// testDataPreparation() is called as pre test setup
		
		zqu__ProductRatePlan__c oProductRatePlan01 = [select Id, Name from zqu__ProductRatePlan__c
														where Name = : PRODUCT_RATE_PLAN_NAME_01 limit 1];
		
		List<GDP_File_Description_To_Rate_Plan__c> fileDescToRatePlanListBefore = [select Id
						from  GDP_File_Description_To_Rate_Plan__c
						where Product_Rate_Plan__c = : oProductRatePlan01.Id
					];
		
		Integer initialNumOfRecs = fileDescToRatePlanListBefore.size();
		
		//zqu__ProductRatePlan__c oProductRatePlan = new zqu__ProductRatePlan__c();
		ApexPages.StandardController sc = new ApexPages.standardController(oProductRatePlan01);
		
		Test.startTest();
		
		PageReference pageRef = new PageReference('/apex/GDP_FileDefRatePlanCACWizard');
		Test.setCurrentPage(pageRef);
		//pageref.getParameters().put('id', oProductRatePlan1.Id);
		
		GDP_FileDefRatePlanCACWizard con = new GDP_FileDefRatePlanCACWizard(sc);
		System.assertNotEquals(null, con.FileDescriptionItemList, 'FileDescriptionItemList should not be null.');
		System.assertNotEquals(null, con.FileDescriptionSelectedList, 'FileDescriptionItemList should not be null.');
		// System.assertNotEquals(0, con.FileDescriptionItemList, 'FileDescriptionItemList should not be empty.');
		
		// user adds one fileDescription to the selection
		Integer initialSelectedFileDesc = con.FileDescriptionSelectedList.size();
        System.assertNotEquals(0, con.FileDescriptionItemList.size(), 'There should be at least one File Description found.');
		con.toSelect = String.valueOf(con.FileDescriptionItemList.size()-1);
		con.AddToFileDescriptionCart();
		
		// user updates the change
		pageRef = con.DoUpdate();
		System.assertNotEquals(0, con.FileDescriptionSelectedList.size(), 'FileDescriptionSelectedList should not be empty.');
		System.assertEquals(initialSelectedFileDesc+1, con.FileDescriptionSelectedList.size(), 'FileDescriptionSelectedList should be increased by one.');
		
		con.toSelect = '0';
		pageRef = con.RemoveFileDescriptionCart();
		
		// user navigate back to the previous page without saving the changes
		pageRef = con.GoBack();
				
		Test.stopTest();
		
		List<GDP_File_Description_To_Rate_Plan__c> fileDescToRatePlanListAfter = [select Id
						from  GDP_File_Description_To_Rate_Plan__c
						where Product_Rate_Plan__c = : oProductRatePlan01.Id
					];
		
		Integer postNumOfRecs = fileDescToRatePlanListAfter.size();
		System.assertEquals(initialSelectedFileDesc+1, postNumOfRecs, 'FileDescriptionSelectedList should be increased by one.');
	} // end of test01_Basic
	
	// ========================================================================
	// basic test scenario:
	//  - user opens GDP_FileDefRatePlanCACWizard.page with a given zqu__ProductRatePlan
	//  - the ProductRatePlan initially has a GDP_File_Description of CACWeb assigned
	//  - user selects related GDP_File_Description__c and link it with zqu_ProductRatePlan, then save it
	//  - user remove selected GDP_File_Description__c and then save it
	static testMethod void test02_Basic() {
		// testDataPreparation() is called as pre test setup
		
		zqu__ProductRatePlan__c oProductRatePlan02 = [select Id, Name from zqu__ProductRatePlan__c
														where Name = : PRODUCT_RATE_PLAN_NAME_02 limit 1];
		
		List<GDP_File_Description_To_Rate_Plan__c> fileDescToRatePlanListBefore = [select Id
						from  GDP_File_Description_To_Rate_Plan__c
						where Product_Rate_Plan__c = : oProductRatePlan02.Id];
		
		Integer initialNumOfRecs = fileDescToRatePlanListBefore.size();
		System.assertNotEquals(0, initialNumOfRecs);
        
		//zqu__ProductRatePlan__c oProductRatePlan = new zqu__ProductRatePlan__c();
		ApexPages.StandardController sc = new ApexPages.standardController(oProductRatePlan02);
		
		Test.startTest();
		
		PageReference pageRef = page.GDP_FileDefRatePlanCACWizard;
		Test.setCurrentPage(pageRef);
		//pageref.getParameters().put('id', oProductRatePlan1.Id);
		
		GDP_FileDefRatePlanCACWizard con = new GDP_FileDefRatePlanCACWizard(sc);
		System.assertNotEquals(null, con.FileDescriptionItemList, 'FileDescriptionItemList should not be null.');
		System.assertNotEquals(null, con.FileDescriptionSelectedList, 'FileDescriptionItemList should not be null.');
		// System.assertNotEquals(0, con.FileDescriptionItemList, 'FileDescriptionItemList should not be empty.');
		
		
		// user add one fileDescription to the selection
		Integer initialSelectedFileDesc = con.FileDescriptionSelectedList.size();
		con.toSelect = '0';
		con.AddToFileDescriptionCart();
		
		// user remove the selection
		con.toSelect = '0';
		pageRef = con.RemoveFileDescriptionCart();
		
		// user commit the change
		pageRef = con.DoUpdate();
		System.assertEquals(initialSelectedFileDesc, con.FileDescriptionSelectedList.size(), 'FileDescriptionSelectedList should stay as before.');
				
		Test.stopTest();
		
		List<GDP_File_Description_To_Rate_Plan__c> fileDescToRatePlanListAfter = [select Id
						from  GDP_File_Description_To_Rate_Plan__c
						where Product_Rate_Plan__c = : oProductRatePlan02.Id ];
		
		Integer postNumOfRecs = fileDescToRatePlanListAfter.size();
		System.assertEquals(initialSelectedFileDesc, postNumOfRecs, 'FileDescriptionSelectedList should be the same as before.');
	} // end of test02_Basic
	
}