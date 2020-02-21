/**
 * This class contains unit tests for validating the behavior
 */
@isTest
private class vfIECUpgrade_tst {
	private static Zuora__Subscription__c oSubscription1;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge1;
	private static Zuora__Subscription__c oSubscription2;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge2;
	private static Zuora__CustomerAccount__c customerAccount;
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product_Information__c oProductInfo2;
	private static Product_Information__c oProductInfo3;
	private static Product2 oProduct;
	private static Product2 oProduct2;
	private static Product2 oProduct3;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlan__c oProductRatePlan2;
	private static zqu__ProductRatePlan__c oProductRatePlan3Trial;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge2;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge3;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo2;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo3Trial;
	private static Swap_Configuration__c oUpgradeConfig1;
	private static Swap_Configuration__c oUpgradeConfigTrial;
	private static Terms_and_Conditions__c oTnC;
	private static Terms_and_Conditions__c oTnC_v2;
	private static Terms_and_Conditions__c oTnC2;
	private static Attachment oAttachment;
	private static Attachment oAttachment2;
	private static SAP_Account__c oSAPAccount;
	private static SAP_Account__c oSAPAccount2;

	private static void InitProduct() {

		oProductCategory = IECTestUtil.CreateSampleProductCategory('PCTST', true);
		insert oProductCategory;

		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		oProduct2 = IECTestUtil.CreateSampleProduct2('PTST2');
		oProduct3 = IECTestUtil.CreateSampleProduct2('PTST3');

		insert new List<sObject> {oProduct, oProduct2, oProduct3};

		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		oProductInfo2 = IECTestUtil.CreateSampleProductInfo2('PITST2', oProductCategory, oProduct2);
		oProductInfo2.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT; //ProductInformationAudience_MEMBERAIRLINE
		oProductInfo3 = IECTestUtil.CreateSampleProductInfo2('PITST3', oProductCategory, oProduct3);
		oProductInfo3.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;

		insert new List<sObject> {oProductInfo, oProductInfo2, oProductInfo3};

		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
		oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('PRPTST2', false, oProduct2);
		oProductRatePlan3Trial = IECTestUtil.CreateSampleProductRatePlan2('PRPTST3', true, oProduct3);

		insert new List<sObject> {oProductRatePlan, oProductRatePlan2, oProductRatePlan3Trial};

		oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 42);
		oProductRatePlanCharge.zqu__Deleted__c = false;
		oProductRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan2, 'CHARGETEST', 42);
		oProductRatePlanCharge2.zqu__Deleted__c = false;
		oProductRatePlanCharge3 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan3Trial, 'CHARGETEST', 10);
		oProductRatePlanCharge3.zqu__Deleted__c = false;

		insert new List<sObject> {oProductRatePlanCharge, oProductRatePlanCharge2, oProductRatePlanCharge3};

		insert new List<zqu__ProductRatePlanChargeTier__c> {
			TestDataGenerator.generateZTiers(oProductRatePlanCharge.Id, 1, false)[0]
			, TestDataGenerator.generateZTiers(oProductRatePlanCharge2.Id, 1, false)[0]
			, TestDataGenerator.generateZTiers(oProductRatePlanCharge3.Id, 1, false)[0]
		};

		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
		oProductRatePlanInfo2 = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST2', false, oProductRatePlan2, oProductInfo2);
		oProductRatePlanInfo3Trial = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST3', true, oProductRatePlan3Trial, oProductInfo3);

		insert new List<sObject> {oProductRatePlanInfo, oProductRatePlanInfo2, oProductRatePlanInfo3Trial};

		List<Product2> lstProduct = TestDataGenerator.generateProducts(4, true);
		lstProduct[0].SAP_Material_Number__c = 'TESTPRODCODE';

		lstProduct[1].IEC_Parent_Product__c = lstProduct[0].Id;
		lstProduct[1].IEC_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;

		lstProduct[2].IEC_Parent_Product__c = lstProduct[0].Id;
		lstProduct[2].IEC_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id;

		lstProduct[3].IEC_Parent_Product__c = lstProduct[0].Id;
		lstProduct[3].IEC_Product_Rate_Plan_Information__c = oProductRatePlanInfo3Trial.Id;

		update lstProduct;
	}

	private static void InitSubscription1(IECCustomer currentCustomer){
		oSAPAccount = IECTestUtil.CreateSampleSAPAccount(currentCustomer.RelatedAccount.Id);
		insert oSAPAccount;

		IECAddress__c oBillingAddress = IECTestUtil.CreateSampleIECAddress(currentCustomer.RelatedContact, IECConstants.IECAddress_AddressType_Billing);
		//insert oBillingAddress;  //*** commented by Thai (2016-02-29) because address was inserted in the calling method

		// create first Terms & Conditions
		oTnC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true, 1);
		insert oTnC;

		// create dummy Attachment for the T&C
		oAttachment = IECTestUtil.CreateSampleAttachment(oTnC.Id);
		insert oAttachment;

		// set the effective date of the T&C
		oTnC.Effective_Start_Date__c = Date.today().addDays(-5);
		update oTnC;

		oUpgradeConfig1 = new Swap_Configuration__c (
			Source_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id,
			Target_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id,
			Relationship_Type__c = IECConstants.SwappingType_Upgrade);
		insert oUpgradeConfig1;

		oSubscription1 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.newInstance(2014, 06, 30));
		oSubscription1.Zuora__Status__c = 'Active';
		oSubscription1.Zuora__AutoRenew__c = false;
		insert oSubscription1;

		 // create dummy subscription charge
		oSubscriptionCharge1 = IECTestUtil.createSampleSubscriptionCharge2(oSubscription1.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
		insert oSubscriptionCharge1;
	}

	private static void InitSubscription2(IECCustomer currentCustomer){
		oSAPAccount2 = IECTestUtil.CreateSampleSAPAccount(currentCustomer.RelatedAccount.Id);
		insert oSAPAccount2;

		IECAddress__c oBillingAddress = IECTestUtil.CreateSampleIECAddress(currentCustomer.RelatedContact, IECConstants.IECAddress_AddressType_Billing);
		//insert oBillingAddress;  //*** commented by Thai (2016-02-29) because address was inserted in the calling method

		// create first Terms & Conditions
		oTnC2 = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo2, true, 1);
		insert oTnC2;

		// create dummy Attachment for the T&C
		oAttachment = IECTestUtil.CreateSampleAttachment(oTnC2.Id);
		insert oAttachment;

		// set the effective date of the T&C
		oTnC2.Effective_Start_Date__c = Date.today().addDays(-2);
		update oTnC2;

		oUpgradeConfigTrial = new Swap_Configuration__c (
			Source_Product_Rate_Plan_Information__c = oProductRatePlanInfo3Trial.Id,
			Target_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id,
			Relationship_Type__c = IECConstants.SwappingType_Upgrade);
		insert oUpgradeConfigTrial;

		oSubscription2 = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 02', Date.newInstance(2014, 06, 30));
		oSubscription2.Zuora__Status__c = 'Active';
		oSubscription2.Zuora__AutoRenew__c = false;
		insert oSubscription2;

		// create dummy subscription charge
		oSubscriptionCharge2 = IECTestUtil.createSampleSubscriptionCharge2(oSubscription2.Id, Date.today().addMonths(-6), oProduct3, oProductRatePlan3Trial);
		insert oSubscriptionCharge2;
	}

	@isTest(SeeAllData=true)
	static void testNormalUpgrade() {

		// Initialize Data for test scenario
		InitProduct();

		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
		IECPageController baseCont = new IECPageController();

		System.runAs(usr) {
			baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
		}

		InitSubscription1(baseCont.loggedCustomer);

		Test.startTest();
		System.runAs(usr) {
			PageReference pgRef = Page.IECUpgrade;
			pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(oSubscription1.Id));
			Test.setCurrentPage(pgRef);

			//Instantiate Controller
			vfIECUpgrade pgCont = new vfIECUpgrade();


			// Test #1 - test initial loading of page
			try {
				pgCont.pageLoad();

				// assertions after page load
				system.assert(pgCont.oSubscription != null, 'The subscription object should not be null.');
				system.assertEquals(false, pgCont.upgradeSuccessful, 'The upgrade should not yet be flagged as successful.');
				system.assertEquals(false, pgCont.upgradePreviewSuccessful, 'The upgrade preview should not yet be flagged as successful');
				system.assertEquals('null', pgCont.autoRenewSubscription, 'The auto renew flag should be null (not selected)');
				system.assertEquals(true, pgCont.hasRatePlanUpgradeSource, 'The source rate plan info should be found');
				system.assert(pgCont.oRatePlanInfoSourceUpgrade != null && pgCont.oRatePlanInfoSourceUpgrade.Id == oProductRatePlanInfo.Id, 'The appropriate source Rate Plan Information should be selected');
				system.assertEquals(false, pgCont.hasSubscriptionResult, 'The page shouldn\'t have any subscribe results');
				system.assertEquals(true, pgCont.hasUpgradesAvailable, 'Upgrades should be available');
				system.assertEquals(false, pgCont.hasAcceptedAllTnCs, 'The T&Cs shound not yet be flagged as accepted');
				system.assertEquals(false, pgCont.hasFilledAutoRenewFlag, 'The Auto renew shound not yet be flagged as filled');
				system.assert(pgCont.lstUIRatePlanInfoUpgradeTargets != null && pgCont.lstUIRatePlanInfoUpgradeTargets.size() == 1, 'There should be 1 upgrade path displayed');
			}
			catch(Exception ex) {
				system.assert(false, 'Should be able to load the page. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
			}

			// Test #2 - test the preview of the prices
			try {
				pgCont.previewUpgrades();

				// assertions after price preview
				system.assertEquals(true, pgCont.upgradePreviewSuccessful, 'The upgrade preview should be successful');
				for (vfIECUpgrade.UIUpgradableRatePlan uiRatePlan : pgCont.lstUIRatePlanInfoUpgradeTargets) {
					system.assert(uiRatePlan.lstPreviewInvoiceItems != null && uiRatePlan.lstPreviewInvoiceItems.size() > 0, 'Invoice Items should be gotten from the preview process');
				}
			}
			catch(Exception ex) {
				system.assert(false, 'Should be able to preview the prices of the upgrades. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
			}

			// Test #3 - select the upgrade without setting the ids (ERROR)
			try {
				pgCont.selectUpgrade();
				system.assert(false, 'Select the upgrade without setting the ids should throw an error');
			}
			catch(Exception ex) {
				system.assert(true, 'Select the upgrade without setting the ids should throw an error');
			}

			// Test #4 - select the available upgrade, no new T&C to accept
			try {
				pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).selected = true;
				pgCont.selectedUpgradeRatePlanZuoraID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c;
				pgCont.selectedUpgradeProductInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Related_Product_Information__c;
				pgCont.selectedUpgradeRatePlanInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Id;
				pgCont.selectUpgrade();

				system.assert(pgCont.subTotal != null, 'The subTotal should not be null');
//              system.assert(pgCont.taxes != null, 'The taxes should not be null');
				system.assert(pgCont.taxCharge != null, 'The taxes should not be null');
				system.assert(pgCont.shippingCharge != null, 'The shipping should not be null');
				system.assert(pgCont.total != null, 'The total should not be null');
				system.assertEquals(false, pgCont.needToAcceptTnC, 'Since the T&C havent changed, no need to accept the T&C again');
				system.assert(pgCont.oTnCComponentController != null, 'The T&C component shouldnt be null');
				system.assertEquals(true, pgCont.hasPaymentMethods, 'The customer should have payment methods');
				system.assert(pgCont.defaultPaymentMethodIsICH != null, 'defaultPaymentMethodIsICH should be set');
				system.assert(pgCont.defaultPaymentMethodIsBankTransfer != null, 'defaultPaymentMethodIsBankTransfer should be set');
				system.assert(pgCont.isPaymentAvailableWithCreditCard != null, 'isPaymentAvailableWithCreditCard should be set');
				//system.assert(pgCont.isPaymentAvailableWithICH != null, 'isPaymentAvailableWithICH should be set');
				//system.assert(pgCont.isPaymentAvailableWithBankTransfer != null, 'isPaymentAvailableWithBankTransfer should be set');
			}
			catch(Exception ex) {
				system.assert(false, 'Should be able to select an upgrade. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
			}

			// Test # - change selection
			try {
				pgCont.changeSelection();

				system.assert(pgCont.selectedUpgradeRatePlanZuoraID == '', 'The selectedUpgradeRatePlanZuoraID should not null');
				system.assert(pgCont.selectedUpgradeProductInfoID == '', 'The selectedUpgradeProductInfoID should not null');
				system.assert(pgCont.selectedUpgradeRatePlanInfoID == '', 'The selectedUpgradeRatePlanInfoID should not null');
				system.assert(pgCont.selectedPaymentMethodType == '', 'The selectedPaymentMethodType should be null');
			}
			catch(Exception ex) {
				system.assert(false, 'Should be able to change the selection. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
			}

			// Test # - upgrade without specifying the IDs (ERROR)
			try {
				pgCont.selectedUpgradeRatePlanZuoraID = null;
				pgCont.selectedUpgradeProductInfoID = null;
				pgCont.selectedUpgradeRatePlanInfoID = null;
				pgCont.proceedToUpgrade();
				system.assert(false, 'Performing the upgrade without setting the ids should throw an error');
			}
			catch(Exception ex) {
				system.assert(true, 'Performing the upgrade without setting the ids should throw an error');
			}

			// Test # - perform the real upgrade (not from a trial)
			try {
				pgCont.selectedUpgradeRatePlanZuoraID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c;
				pgCont.selectedUpgradeProductInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Related_Product_Information__c;
				pgCont.selectedUpgradeRatePlanInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Id;

				// set the auto renew flag
				pgCont.autoRenewSubscription = 'true';
				pgCont.selectedPaymentMethodType = 'ICH';

				pgCont.proceedToUpgrade();

				system.assertEquals(true, pgCont.upgradeSuccessful, 'The upgrade should be successful');
				system.assert(pgCont.paymentTransactionNumber != null, 'The paymentTransactionNumber should not be null');

				// Test # - Make sure an email has been triggered to the contact
				List<IEC_Email_Notification__c> lstEmails = [SELECT Email_Sent__c FROM IEC_Email_Notification__c WHERE To_Email__c = :baseCont.loggedCustomer.RelatedContact.Email];

				system.assertNotEquals(lstEmails.size(), 0, 'An email notification must be recorded in the system.');
				system.assertEquals(lstEmails.get(0).Email_Sent__c, true, 'Workflow must kick in and flag the email as sent.');

			}
			catch(Exception ex) {
				system.assert(false, 'Should be able to upgrade. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
			}

			pgCont.displayCallBackfailure();
			pgCont.getExtraParamString();
			pgCont.onClickCancel();

			// Test callback error
			pgRef.getParameters().put('errorCode', IECUtil.EncryptEncodeParameter('Some error code'));
			pgRef.getParameters().put('errorMessage', IECUtil.EncryptEncodeParameter('Some error'));
			Test.setCurrentPage(pgRef);
			pgCont.displayCallBackfailure();

			Test.stopTest();
		}
	}

	@isTest(SeeAllData=true)
	static void testUpgradeWithNewCreditCard() {

		// Initialize Data for test scenario
		InitProduct();

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		IECPageController baseCont = new IECPageController();

		System.runAs(usr) {
			baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
		}

		InitSubscription1(baseCont.loggedCustomer);

		Test.startTest();
		System.runAs(usr) {
			PageReference pgRef = Page.IECUpgrade;
			pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(oSubscription1.Id));
			Test.setCurrentPage(pgRef);

			//Instantiate Controller
			vfIECUpgrade pgCont = new vfIECUpgrade();


			// Test # - perform the upgrade with a new credit card
			try {
				pgCont.pageLoad();
				pgCont.previewUpgrades();
				pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).selected = true;
				pgCont.selectedUpgradeRatePlanZuoraID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c;
				pgCont.selectedUpgradeProductInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Related_Product_Information__c;
				pgCont.selectedUpgradeRatePlanInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Id;
				pgCont.selectUpgrade();

				// set the auto renew flag
				pgCont.autoRenewSubscription = 'true';
				pgCont.selectedPaymentMethodType = 'CREDIT_CARD';
				pgCont.selectedCreditCardPaymentId = '78978s76fg56g4h45sadsdfa';

				pgCont.proceedToUpgrade();

				system.assertEquals(true, pgCont.upgradeSuccessful, 'The upgrade should be successful');
				system.assert(pgCont.paymentTransactionNumber != null, 'The paymentTransactionNumber should not be null');

				// Test # - Make sure an email has been triggered to the contact
				List<IEC_Email_Notification__c> lstEmails = [SELECT Email_Sent__c FROM IEC_Email_Notification__c WHERE To_Email__c = :baseCont.loggedCustomer.RelatedContact.Email];

				system.assertNotEquals(lstEmails.size(), 0, 'An email notification must be recorded in the system.');
				system.assertEquals(lstEmails.get(0).Email_Sent__c, true, 'Workflow must kick in and flag the email as sent.');

			}
			catch(Exception ex) {
				system.assert(false, 'Should be able to upgrade. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
			}

			Test.stopTest();
		}
	}

	@isTest(SeeAllData=true)
	static void testTrialUpgrade() {

		// Initialize Data for test scenario
		InitProduct();

		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
		IECPageController baseCont = new IECPageController();

		System.runAs(usr) {
			baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
		}

		InitSubscription2(baseCont.loggedCustomer);

		Test.startTest();
		System.runAs(usr) {
			PageReference pgRef = Page.IECUpgrade;
			pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_ID, IECUtil.EncryptEncodeParameter(oSubscription2.Id));
			Test.setCurrentPage(pgRef);

			vfIECUpgrade pgCont = new vfIECUpgrade();
			pgCont.pageLoad();

			// basic assertions after page load
			system.assertEquals(true, pgCont.hasRatePlanUpgradeSource, 'The source rate plan info should be found');
			system.assert(pgCont.oRatePlanInfoSourceUpgrade != null && pgCont.oRatePlanInfoSourceUpgrade.Id == oProductRatePlanInfo3Trial.Id, 'The appropriate source Rate Plan Information should be selected');
			system.assertEquals(true, pgCont.hasUpgradesAvailable, 'Upgrades should be available');

			// preview the upgrades prices
			pgCont.previewUpgrades();

			// Test #1 - select the available upgrade, T&C to accept since the source rate plan is a trial
			try {
				pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).selected = true;
				pgCont.selectedUpgradeRatePlanZuoraID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c;
				pgCont.selectedUpgradeProductInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Related_Product_Information__c;
				pgCont.selectedUpgradeRatePlanInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Id;
				pgCont.selectUpgrade();

				system.assertEquals(true, pgCont.upgradePreviewSuccessful, 'The upgrade preview should be successful');
				system.assert(pgCont.subTotal != null, 'The subTotal should not be null');
				//system.assert(pgCont.taxes != null, 'The taxes should not be null');
				system.assert(pgCont.taxCharge != null, 'The taxes should not be null');
				system.assert(pgCont.shippingCharge != null, 'The shipping should not be null');
				system.assert(pgCont.total != null, 'The total should not be null');
				system.assertEquals(true, pgCont.needToAcceptTnC, 'It is mandatory to accept the T&C when upgrading from trial');
			}
			catch(Exception ex) {
				system.assert(false, 'Should be able to upgrade. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
			}

			// Test #2 - try to upgrade from a trial without accepting the T&C (ERROR)
			try {
				pgCont.selectedUpgradeRatePlanInfoID = pgCont.lstUIRatePlanInfoUpgradeTargets.get(0).productRatePlanInfo.Id;

				// set the auto renew flag
				pgCont.autoRenewSubscription = 'false';
				pgCont.selectedPaymentMethodType = 'ICH';

				pgCont.proceedToUpgrade();

				system.assert(false, 'Should throw an error because the T&C were not accepted.');
			}
			catch(Exception ex) {
				system.assert(true, 'Should throw an error because the T&C were not accepted.');
			}

			// Test #3 - accept the T&C and perform the upgrade
			try {
				for (VfIECTermsAndConditionsComponent.UITermsAndConditions uiTnc : pgCont.oTnCComponentController.listTermsAndConditionsToDisplay)
					uiTnc.checked = true;

				pgCont.proceedToUpgrade();
				system.assertEquals(true, pgCont.upgradeSuccessful, 'The upgrade should be successful');
				system.assertEquals(true, pgCont.hasSubscriptionResult, 'Should have subscriptionresult');

				// Test 004: Make sure an email has been triggered to the contact
				List<IEC_Email_Notification__c> lstEmails = [SELECT Email_Sent__c FROM IEC_Email_Notification__c WHERE To_Email__c = :baseCont.loggedCustomer.RelatedContact.Email];

				system.assertNotEquals(lstEmails.size(), 0, 'An email notification must be recorded in the system.');
				system.assertEquals(lstEmails.get(0).Email_Sent__c, true, 'Workflow must kick in and flag the email as sent.');
			}
			catch(Exception ex) {
				system.assert(false, 'Should be able to upgrade. Error:' + ex.getMessage() + ' - ' + ex.getStacktraceString());
			}

			Test.stopTest();
		}
	}


	@isTest
	public static void prepareHPMSetting(){
		HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
		if(hpmsetting == null)
			hpmsetting = new HPM_Setting__c();
		hpmsetting.Name = 'Zuora HPM Setting';
		hpmsetting.HPM_Page_Id__c = 'page_id';
		hpmsetting.HPM_Tenant_Id__c = '100';
		hpmsetting.HPM_Security_Token__c = 'security_token';
		hpmsetting.HPM_App_Url__c = 'www.zuora.com/service/a/27.0';
		upsert hpmsetting;
	}

	@isTest
	public static void removeHPMSetting(){
		HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
		if(hpmsetting != null)
			delete hpmsetting;
	}
}
