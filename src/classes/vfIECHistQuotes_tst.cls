/**
 * This class contains unit tests for validating the behavior of
 */
@isTest
private class vfIECHistQuotes_tst {

	private static Account oAccount;
	private static Contact oContact;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static User usr;

	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Opportunity oOpportunity1;
	private static Opportunity oOpportunity2;
	private static zqu__Quote__c oQuote1;
	private static zqu__Quote__c oQuote2;

	/**
	 * Setup user/account test data
	 */
	static void setupUser() {

		usr = IECTestUtil.createSampleGuestUserAndLogin();

		oContact = [Select Id, Name, AccountId from Contact where Id = :usr.ContactId limit 1];

		oAccount = [Select Id, Name from Account where Id = :oContact.AccountId limit 1];

		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount);
		insert oBillingAccount;
	}

	/**
	 * Setup quote test data
	 */
	static void setupData() {

		// create product/rateplan

		oProductCategory = IECTestUtil.CreateSampleProductCategory('PCTST', true);
		insert oProductCategory;

		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		insert oProduct;

		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;

		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
		insert oProductRatePlan;

		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
		oProductRatePlanInfo.Display_As_Monthly_Fee__c = true;
		insert oProductRatePlanInfo;

		// create opportunity/quotes
		oOpportunity1 = IECTestUtil.createSampleOpportunity(oAccount, 'OPP1', 420.42);
		insert oOpportunity1;

		oOpportunity2 = IECTestUtil.createSampleOpportunity(oAccount, 'OPP2', 321.21);
		insert oOpportunity2;

		oQuote1 = IECTestUtil.createSampleQuote(oOpportunity1, oContact, 'No comments', false);
		insert oQuote1;

		oQuote2 = IECTestUtil.createSampleQuote(oOpportunity2, oContact, '-sudo Make me a sandwich', true);
		insert oQuote2;
	}

	@isTest(SeeAllData=true)
	static void testEmptyPage() {

		setupUser();

		System.runAs(usr) {

			PageReference pgRef = Page.IECHistQuotes;
			Test.setCurrentPage(pgRef);

			// instantiate Controller
			vfIECHistQuotes pageController = new vfIECHistQuotes();

			try {
				pageController.pageLoad();
				system.assert(pageController.lstQuotes == null || pageController.lstQuotes.size() == 0, 'No quotes should be found yet');
				system.assertEquals(null, pageController.oSelectedQuote, 'oSelectedQuote should be null');
				system.assertEquals(null, pageController.sSelectedQuoteId, 'sSelectedQuoteId should be null');
				system.assertEquals(null, pageController.oRatePlanInfo, 'oRatePlanInfo should be null');
			}
			catch(Exception ex) {
				system.assert(false, 'Should not throw an error: ' + ex.getMessage());
			}
		}
	}


	@isTest(SeeAllData=true)
	static void testPage() {



		zqu__Quote_Template__c zqt = new zqu__Quote_Template__c(Name = 'sqt',zqu__Template_Id__c = 'asdsad');
		insert zqt;

	   IEC_Settings__c iecs = IEC_Settings__c.getOrgDefaults();
	  // throw new transformationException(' iecs ' +iecs);
	  // iecs.id = IEC_Settings__c.getInstance().id;
	   iecs.Quote_Template_ID_New_Subscription__c=zqt.id;// [Customer_Permission_Set_Id__c, PaymentMethod_Bank_Transfer_Zuora_ID__c, PaymentMethod_Other_Zuora_ID__c, Quote_Template_Zuora_ID_New_Subscription__c, SchdlIECCompileUsage_Class_ID__c, CAC_Web_Service_API_Gateway__c, CAC_Web_Service_Usage_Url__c, SchdlCACWSUsageUpdate_Class_ID__c);
	   //
		update iecs;

		setupUser();
		setupData();

		System.runAs(usr) {

			PageReference pgRef = Page.IECHistQuotes;
			Test.setCurrentPage(pgRef);

			//Instantiate Controller
			vfIECHistQuotes pageController = new vfIECHistQuotes();

			// Test #1 - pageload with 2 quotes
			try {
				pageController.pageLoad();
				system.assert(pageController.lstQuotes != null && pageController.lstQuotes.size() == 2, '2 quotes should be found');
				system.assertEquals(null, pageController.oSelectedQuote, 'oSelectedQuote should be null');
				system.assertEquals(null, pageController.sSelectedQuoteId, 'sSelectedQuoteId should be null');
				system.assertEquals(null, pageController.oRatePlanInfo, 'oRatePlanInfo should be null');

				system.assert(String.isNotBlank(pageController.sUserSessionId), 'sUserSessionId should not be blank');
				system.assert(String.isNotBlank(pageController.sQuoteTemplateZuoraId), 'sQuoteTemplateZuoraId should not be blank');
				system.assert(String.isNotBlank(pageController.sZuoraGenerateQuotePDFURL), 'sZuoraGenerateQuotePDFURL should not be blank');
				system.assert(String.isNotBlank(pageController.sServerURL), 'sServerURL should not be blank');
			}
			catch(Exception ex) {
				system.assert(false, 'Should not throw an error: ' + ex.getMessage());
			}

			// Test #2 - select a quote without providing the quoteid
			pageController.selectQuote();

			// Test #3 - select a quote providing an invalid quoteid
			pageController.sSelectedQuoteId = 'notavalidquoteid';
			pageController.selectQuote();

			// Test #3 - select a quote
			try {
				pageController.sSelectedQuoteId = pageController.lstQuotes.get(1).Id;
				pageController.selectQuote();

				system.assert(pageController.oSelectedQuote != null, 'oSelectedQuote should not be null');
				system.assertEquals(pageController.lstQuotes.get(1).Id, pageController.oSelectedQuote.Id, 'oSelectedQuote.Id and sSelectedQuoteId should match');
			}
			catch(Exception ex) {
				system.assert(false, 'Should not throw an error: ' + ex.getMessage());
			}

			// variable get coverage
		  //  String temp = pageController.sZuoraSessionID;
		}
	}
}
