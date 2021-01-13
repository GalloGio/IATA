@isTest(SeeAllData = true)
private class vfIECGSSFileRecipientDetail_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionCharge;

	private static IECCustomer currentCustomer;
	private static User usr;  // test user
	private static Contact oContact; // related test Contact of the test user
	private static Account oAccount; // related test Account
	private static Zuora__CustomerAccount__c oBillingAccount;
	
	private static final String TEST_SUBSCRIPTION_NAME = 'Subs 01';
	
	// ========================================================================
	// initialize related data: Contact, Account, GDP_File_Description, Subscription
	// 
	static void Init() {
		System.debug('Unit Test: Start: Init');
		
		// create the customer: user, contact, account, billing account
		usr = IECTestUtil.createSampleGuestUserAndLogin();
		oContact = [Select Id, Name, Email, AccountId from Contact where Id = :usr.ContactId limit 1];
		System.debug ('\n oContact:' + oContact);
		oAccount = [Select Id, Name from Account where Id = :oContact.AccountId limit 1];
		System.debug ('\n oAccount:' + oAccount);	
        
		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
		insert oBillingAccount;
		System.debug ('\n oBillingAccount:' + oBillingAccount);	
        
		// create the product and related record
		
		oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_GSS, true);
		insert oProductCategory;
		
		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		insert oProduct;
		
		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;
		
		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
		insert oProductRatePlan;
		System.debug( 'oProductRatePlan inserted: '+ oProductRatePlan);
		
		oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
		insert oProductRatePlanCharge;
		System.debug( 'oProductRatePlanCharge inserted: '+ oProductRatePlanCharge);
		
		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
		insert oProductRatePlanInfo;
		System.debug( 'oProductRatePlanInfo inserted: '+ oProductRatePlanInfo);
		
		// create File Description, link it to ProductRatePlan
		GDP_File_Description__c fileDesc = IECTestUtil.CreateSampleGDPFileDescription('T', 'Monthly', IECConstants.ProductCategory_SF_GSS);
		System.debug( 'fileDesc to insert: '+ fileDesc);
		insert fileDesc;
		
		GDP_File_Description_To_Rate_Plan__c fileDescRatePlan = new GDP_File_Description_To_Rate_Plan__c( 
								GDP_File_Description__c = fileDesc.Id
								, Product_Rate_Plan__c = oProductRatePlan.Id);
		insert fileDescRatePlan;
		
		
		// create test subscription	
		subscription = IECTestUtil.createSampleSubscription(oAccount.Id
								, oBillingAccount.Id, TEST_SUBSCRIPTION_NAME
								, Date.today().addMonths(6));
		
		subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
		
		insert subscription;
		System.debug( 'Subscription '+ subscription.Id + '  as inserted: ' +  subscription );
		
		// create dummy subscription charge
		subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
		insert subscriptionCharge;
		
		List<GSS_Subscription_Detail__c> subDetailList = [select Id, Name, GDP_File_Description__c
															, Zuora_Subscription__c
															, FileRecipientEmail__c
															, FileRecipientFirstName__c, FileRecipientLastName__c
				from GSS_Subscription_Detail__c 
				where GDP_File_Description__c = :fileDesc.Id
					and Zuora_Subscription__c = :subscription.Id
				];
		System.debug( '\n\n Normally Subscription_Detail should be automatically created, current subDetailList:' + subDetailList);
		if (subDetailList.size() ==0)
		{
			System.debug( 'GSS_Subscription_Detail was not created automatically, so we need to add it');
			GSS_Subscription_Detail__c gss = new GSS_Subscription_Detail__c(Name = TEST_SUBSCRIPTION_NAME, GDP_File_Description__c = fileDesc.id ,
													FileRecipientEmail__c='test@test.test', 
													FileRecipientFirstName__c='Test', 
													FileRecipientLastName__c = 'User') ;
			insert gss;
		}
		
		System.debug('Unit Test: Finish: Init');
	} // end of Init
	
	
	// ========================================================================
	// basic test
	static testMethod void TestGSSFileRecipientDetailName() {
		// setup data
		Init();
		
		System.debug('Unit Test: Start: TestGSSFileRecipientDetailName');
		
		//Set current page to GSSFileRecipientDetailName
		PageReference pgRef = Page.IECFDFileRecipientDetail;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(TEST_SUBSCRIPTION_NAME));
		Test.setCurrentPage(pgRef);
		
		
		//User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.debug( '\n\nxSubscription when TestGSSFileRecipientDetailName began: ' +  subscription);
		
		System.runAs(usr) {
			Test.startTest();
			System.debug( 'startTest, as user:' + usr);
			System.assertNotEquals( null, subscription, 'where is the subscription here'+ subscription.Id );
			
			// trigger the Product Access creation
			Zuora__Subscription__c subscriptionToUpdate = new Zuora__Subscription__c( Id = subscription.Id);
			update subscriptionToUpdate;
			
			//Instantiate Controller
			vfIECGSSFileRecipientDetail pgCont = new vfIECGSSFileRecipientDetail();
			
			// check the parameter passing:
			System.debug( 'pgCont.CtrSubsInfo.sApplicationName: ' + pgCont.CtrSubsInfo.sApplicationName);
			System.assertEquals( subscription.Name, pgCont.ctrSubsInfo.sSelectedSubscriptionName);
			System.assertEquals( IECConstants.ProductCategory_SF_GSS, pgCont.CtrSubsInfo.sApplicationName);
			
			//Boolean accessValid = pgCont.ctrSubsInfo.validateAccess(); // this need IECCustomer loggedCustomer to be set in the init
			//System.debug( 'access to SubscriptionInfo valid:'+ accessValid);
			
			pgCont.pageLoad();
			System.debug( 'After pageLoad, ctrSubsInfo: ' + pgCont.ctrSubsInfo);
			
			//Test 001: Set file recipient on the subscription
			// Prefix:Date, Suffix: Custom
			pgCont.sFileRecipientFirstName = 'Test';
			pgCont.sFileRecipientLastName = 'User';
			pgCont.sFileRecipientEmail = 'test@test.test';

            pgCont.sFileRecipientJobTitle = 'Director';
            pgCont.sFileRecipientSalutation = 'Mr.';
            pgCont.sFileRecipientPhone = '555-555-5555';	
            
			// Test the getters function of variables
			system.assertEquals('Test', pgCont.sFileRecipientFirstName);
			system.assertEquals('User', pgCont.sFileRecipientLastName);
			system.assertEquals('test@test.test', pgCont.sFileRecipientEmail);

			system.assertEquals('Director', pgCont.sFileRecipientJobTitle);
			system.assertEquals('Mr.', pgCont.sFileRecipientSalutation);
			system.assertEquals('555-555-5555', pgCont.sFileRecipientPhone);
            
			// this is the missing part in controller: subscriptionObj is not set by ctrSubsInfo  
			System.debug( 'Before clicking save button, subscriptionObj=' + pgCont.subscriptionObj);
			
			pgCont.onClickSave();
			System.debug( 'After clicking save button');
			
			Test.stopTest();
			
			//Query GSS Settings
			List <GSS_Subscription_Detail__c> lstGSSSetting =
				[SELECT Id
                 	, Name
                 	, GDP_File_Description__c
                 	, Zuora_Subscription__c
					, FileRecipientEmail__c
					, FileRecipientFirstName__c
                 	, FileRecipientLastName__c
                 
                 	, FileRecipientJobTitle__c
                 	, FileRecipientSalutation__c
                 	, FileRecipientPhone__c
				FROM GSS_Subscription_Detail__c
				WHERE Name = : subscription.Name];
			
			system.assert(!lstGSSSetting.isEmpty(), 'GSS Subscription Detail record must exist');
			//GSS_Subscription_Detail should have the recipient details updated: '
            System.debug( 'lstGSSSetting: ' + lstGSSSetting);
						
            
			
			// assert that the values are correctly saved
			system.assertEquals('test@test.test', lstGSSSetting.get(0).FileRecipientEmail__c, 	'File Recipient setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('Test', lstGSSSetting.get(0).FileRecipientFirstName__c, 		'File Recipient setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('User', lstGSSSetting.get(0).FileRecipientLastName__c, 			'File Recipient setting must be updated in the GSS Subscription Detail table');
			
			system.assertEquals('Director', lstGSSSetting.get(0).FileRecipientJobTitle__c, 		'File Recipient setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('Mr.', lstGSSSetting.get(0).FileRecipientSalutation__c, 		'File Recipient setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('555-555-5555', lstGSSSetting.get(0).FileRecipientPhone__c, 	'File Recipient setting must be updated in the GSS Subscription Detail table');
			
			// Misc Coverage
			pgCont.onClickEdit();
			pgCont.onClickCancel();
		} // end runAs
		System.debug('Unit Test: Finish: TestGSSFileRecipientDetailName');
	} // end of TestGSSFileRecipientDetailName
	
	
	// ========================================================================
	// test for other cases
	static testMethod void TestGSSFileRecipientDetailName_Errors() {
		System.debug('Unit Test: Start: TestGSSFileRecipientDetailName_Errors');
		Init();
		
		//Set current page to GSSFileRecipientDetailName
		PageReference pgRef = Page.IECFDFileRecipientDetail;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs 01'));
		Test.setCurrentPage(pgRef);
		
		//Instantiate Controller
		vfIECGSSFileRecipientDetail pgCont = new vfIECGSSFileRecipientDetail();
		
		// Test 001: Accessing page as community user
		pgCont.pageLoad();
		
		Test.startTest();
		System.runAs(usr) {
			// trigger the Product Access creation
			update subscription;
			
			//Instantiate Controller
			pgCont = new vfIECGSSFileRecipientDetail();
			pgCont.pageLoad();
			
			//Test 002: Set Validations on clicking save with invalid data
			pgCont.sFileRecipientLastName = '';
			pgCont.sFileRecipientEmail = '';
			pgCont.onClickSave();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Last Name'));
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Email'));
			
			// Misc Coverage
			String sTest = pgCont.sApplicationTitleUpperCase;
			pgCont.sProductCode = IECConstants.ProductCategory_SF_MDP;
			sTest = pgCont.sApplicationTitleUpperCase;
			pgCont.sProductCode = '';
			sTest = pgCont.sApplicationTitleUpperCase;
			sTest = pgCont.sFileRecipientiiNet;
			Zuora__Subscription__c oTest = pgCont.subscriptionObj;
		}
		Test.stopTest();
		
		System.debug('Unit Test: Finish: TestGSSFileRecipientDetailName_Errors');
	} // end of TestGSSFileRecipientDetailName_Errors
	
	
	
}