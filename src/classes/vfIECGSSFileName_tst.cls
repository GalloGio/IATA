/**
  * Description: This class contains unit tests for the (GSS - File Name) webpage
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */
@isTest(SeeAllData=true)
private class vfIECGSSFileName_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionCharge;

	private static IECCustomer currentCustomer;

	static void Init() {
			System.debug('Unit Test: Start: Init');
			oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_GSS, true);
			insert oProductCategory;

			oProduct = IECTestUtil.CreateSampleProduct2('PTST');
			insert oProduct;

			oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
			oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
			insert oProductInfo;

			oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
			insert oProductRatePlan;

			oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
			insert oProductRatePlanCharge;

			oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
			insert oProductRatePlanInfo;

			currentCustomer = IECCustomer.getCurrentIECCustomer();

			// create dummy subscription
			subscription = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
			subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
			insert subscription;

			// create dummy subscription charge
			subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
			insert subscriptionCharge;

			GDP_File_Description__c fileDesc = IECTestUtil.CreateSampleGDPFileDescription('T', 'Monthly', IECConstants.ProductCategory_SF_GSS);
			insert fileDesc;

			GSS_Subscription_Detail__c gss = new GSS_Subscription_Detail__c (Name = 'Subs 01', GDP_File_Description__c = fileDesc.id);
			insert gss;

		System.debug('Unit Test: Finish: Init');
	}

	static testMethod void TestGSSFileName() {
		System.debug('Unit Test: Start: TestGSSFileName');


		//Set current page to GSSFileName
		PageReference pgRef = Page.IECFDFileName;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs 01'));
		Test.setCurrentPage(pgRef);

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {

			Test.startTest();

			// setup data
			Init();

			// trigger the Product Access creation
			update subscription;

			Test.stopTest();

			//Instantiate Controller
			vfIECGSSFileName pgCont = new vfIECGSSFileName();
			pgCont.pageLoad();

			//Test 001: Set file name prefix/suffix on the subscription
			// Prefix:Date, Suffix: Custom
			pgCont.sApplyOption = 'Zip file only';
			pgCont.sNamePrefixOption = 'Date';
			pgCont.sNameSuffixOption = 'Custom';
			pgCont.sNamePrefix = '';
			pgCont.sNameSuffix = 'TST';

			// Test the getters function of variables
			system.assertEquals('Zip file only', pgCont.sApplyOption);
			system.assertEquals('Date', pgCont.sNamePrefixOption);
			system.assertEquals('Custom', pgCont.sNameSuffixOption);
			system.assertEquals('', pgCont.sNamePrefix);
			system.assertEquals('TST', pgCont.sNameSuffix);

			pgCont.onClickSave();

			//Query GSS Settings
			List<GSS_Subscription_Detail__c> lstGSSSetting =
				[SELECT File_Name_Applies_on__c
					, File_Name_Custom_Prefix__c
					, File_Name_Custom_Suffix__c
					, File_Name_Prefix_Option__c
					, File_Name_Suffix_Option__c
				FROM GSS_Subscription_Detail__c WHERE Name = :subscription.Name];

			system.assert(!lstGSSSetting.isEmpty(), 'GSS Subscription Detail record must exist');
			system.assertEquals('Zip file only', lstGSSSetting.get(0).File_Name_Applies_on__c, 'File Naming setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('Date', lstGSSSetting.get(0).File_Name_Prefix_Option__c, 'File Naming setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('Custom', lstGSSSetting.get(0).File_Name_Suffix_Option__c, 'File Naming setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(null, lstGSSSetting.get(0).File_Name_Custom_Prefix__c, 'File Naming setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('TST', lstGSSSetting.get(0).File_Name_Custom_Suffix__c, 'File Naming setting must be updated in the GSS Subscription Detail table');

			//Test 001: Set file name prefix/suffix on the subscription
			// Prefix:Date, Suffix: Custom
			pgCont.sApplyOption = 'Zip file only';
			pgCont.sNamePrefixOption = 'Custom';
			pgCont.sNameSuffixOption = 'Date';
			pgCont.sNamePrefix = 'TST';
			pgCont.sNameSuffix = '';

			// Test the getters function of variables
			system.assertEquals('Zip file only', pgCont.sApplyOption);
			system.assertEquals('Custom', pgCont.sNamePrefixOption);
			system.assertEquals('Date', pgCont.sNameSuffixOption);
			system.assertEquals('TST', pgCont.sNamePrefix);
			system.assertEquals('', pgCont.sNameSuffix);

			pgCont.onClickSave();

			//Query GSS Settings
			lstGSSSetting =
				[SELECT File_Name_Applies_on__c
					, File_Name_Custom_Prefix__c
					, File_Name_Custom_Suffix__c
					, File_Name_Prefix_Option__c
					, File_Name_Suffix_Option__c
				FROM GSS_Subscription_Detail__c WHERE Name = :subscription.Name];

			system.assert(!lstGSSSetting.isEmpty(), 'GSS Subscription Detail record must exist');
			system.assertEquals('Zip file only', lstGSSSetting.get(0).File_Name_Applies_on__c, 'File Naming setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('Custom', lstGSSSetting.get(0).File_Name_Prefix_Option__c, 'File Naming setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('Date', lstGSSSetting.get(0).File_Name_Suffix_Option__c, 'File Naming setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('TST', lstGSSSetting.get(0).File_Name_Custom_Prefix__c, 'File Naming setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(null, lstGSSSetting.get(0).File_Name_Custom_Suffix__c, 'File Naming setting must be updated in the GSS Subscription Detail table');

			// Misc Coverage
			pgCont.onClickEdit();
			pgCont.onClickCancel();
		}
		System.debug('Unit Test: Finish: TestGSSFileName');
	}

	static testMethod void TestGSSFileName_Errors() {
		System.debug('Unit Test: Start: TestGSSFileName_Errors');

		//Set current page to GSSFileName
		PageReference pgRef = Page.IECFDFileName;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs 01'));
		Test.setCurrentPage(pgRef);

		//Instantiate Controller
		vfIECGSSFileName pgCont = new vfIECGSSFileName();

		// Test 001: Accessing page as guest user
		pgCont.pageLoad();

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {

			Test.startTest();

			// setup data
			Init();

			// trigger the Product Access creation
			update subscription;

			Test.stopTest();

			//Instantiate Controller
			pgCont = new vfIECGSSFileName();
			pgCont.pageLoad();

			//Test 002: Set Validations on clicking save with invalid data
			pgCont.sApplyOption = '';
			pgCont.sNamePrefixOption = 'Custom';
			pgCont.sNamePrefix = '';
			pgCont.sNameSuffixOption = 'Custom';
			pgCont.sNameSuffix = '';
			pgCont.onClickSave();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Name Applies On'));
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Custom Prefix'));
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_Required_field + ' Custom Suffix'));

			//Test 003: Set Validations on clicking save with invalid prefix/suffix
			pgCont.sApplyOption = 'Zip file only';
			pgCont.sNamePrefixOption = 'Custom';
			pgCont.sNamePrefix = '1,23$#';
			pgCont.sNameSuffixOption = 'Custom';
			pgCont.sNameSuffix = '1,23$#';
			pgCont.onClickSave();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_InvalidFileNameFormat.replace('{0}', 'Custom Prefix')));
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_InvalidFileNameFormat.replace('{0}', 'Custom Suffix')));

			// Misc Coverage
			String sTest = pgCont.sDate;
			sTest = pgCont.sApplicationTitleUpperCase;
			pgCont.sProductCode = IECConstants.ProductCategory_SF_MDP;
			sTest = pgCont.sApplicationTitleUpperCase;
			pgCont.sProductCode = '';
			sTest = pgCont.sApplicationTitleUpperCase;
		}

		System.debug('Unit Test: Finish: TestGSSFileName_Errors');
	}
}
