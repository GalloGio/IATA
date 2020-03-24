/**
	* Description: Test the class IECQuoteManager
	* Author: Alexandre McGraw
	* Version: 1.0
	* History:
	*/
@isTest(SeeAllData=true)
private class IECQuoteManager_tst {

	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;

	private static Account oAccount;
	private static Contact oContact;
	private static Zuora__CustomerAccount__c oBillingAccount;

	static{
		setupData(true);
	}

	private static void setupData(Boolean triable){

		// create product/rateplan

		oProductCategory = IECTestUtil.CreateSampleProductCategory('PCTST', true);
		insert oProductCategory;

		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		insert oProduct;

		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;

		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', triable, oProduct);
		insert oProductRatePlan;

		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', triable, oProductRatePlan, oProductInfo);
		oProductRatePlanInfo.Display_As_Monthly_Fee__c = !triable;
		insert oProductRatePlanInfo;

		// create user
		oAccount = IECTestUtil.createSampleAccount();
		insert oAccount;

		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount);
		insert oBillingAccount;
	}

	static testmethod void testQuoteManager() {

		Boolean bAutoRenew = false;
		Decimal dQuoteAmount = 123.45;
		String sComments = 'some comments...';
		zqu__Quote__c oQuote = null;

		setupData(false);

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
			System.runAs(usr) {

				Test.startTest();

				// Test #1 - submit quote with invalid arguments
				try {
					oQuote = IECQuoteManager.submitQuote(IECCustomer.getCurrentIECCustomer(), null, bAutoRenew, null, null, null, null);
					system.assert(false, 'submitQuote() with invalid arguments should throw an error');
				}
				catch(Exception ex) {

					system.assert(true, 'submitQuote() with invalid arguments should throw an error' );
				}


				zqu__Quote_Template__c zqt = new zqu__Quote_Template__c(Name = 'sqt',zqu__Template_Id__c = 'asdsad');
				insert zqt;

			 IEC_Settings__c iecs = IEC_Settings__c.getOrgDefaults();
			// throw new transformationException(' iecs ' +iecs);
			// iecs.id = IEC_Settings__c.getInstance().id;
			 iecs.Quote_Template_ID_New_Subscription__c=zqt.id;// [Customer_Permission_Set_Id__c, PaymentMethod_Bank_Transfer_Zuora_ID__c, PaymentMethod_Other_Zuora_ID__c, Quote_Template_Zuora_ID_New_Subscription__c, SchdlIECCompileUsage_Class_ID__c, CAC_Web_Service_API_Gateway__c, CAC_Web_Service_Usage_Url__c, SchdlCACWSUsageUpdate_Class_ID__c);
			 //
				update iecs;
				// Test #2 - submitquote and opportunity creation
				try {
					oQuote = IECQuoteManager.submitQuote(IECCustomer.getCurrentIECCustomer(), oProductRatePlanInfo, bAutoRenew, dQuoteAmount, sComments, null, null);
				}
				catch(Exception ex) {
				 /// throw new transformationException(ex.getStacktraceString() + ex.getMessage());
					system.assert(false, 'Should not throw an error: ' + ex.getMessage());
				}

				Test.stopTest();

				// Test #3 - retreive list of quotes by contact id
				List<zqu__Quote__c> lstQuotes = IECQuoteManager.getQuotesByContactId(IECCustomer.getCurrentIECCustomer().RelatedContact.Id);
				system.assert(lstQuotes.size() == 1, 'One quote should be found by the contact id');

			}

		// Test #4 - reselect Quote and check fields
		oQuote = IECQuoteManager.getQuoteById(oQuote.Id);

		system.assert(oQuote != null, 'A quote object should be created.');
		system.assertEquals(bAutoRenew, oQuote.zqu__AutoRenew__c, 'The flag autorenew should be set accordingly');
		system.assertEquals(sComments, oQuote.zqu__Terms__c, 'The Quote comments should be set accordingly');
		system.assert(oQuote.IEC_Opportunity_Id__c != null, 'The Quote should have an opportunity');

		// Test #5 - retreive Opportunity associated to the Quote
		Opportunity oOpp = [SELECT AccountId, Amount, CloseDate, Name, StageName, Type
							FROM Opportunity
							WHERE Id = :oQuote.IEC_Opportunity_Id__c
							limit 1];

		system.assert(oOpp != null, 'The opportunity should be found');

		system.assertEquals(dQuoteAmount, oOpp.Amount, 'The Opportunity amount should be set accordingly');
		system.assertEquals(IECConstants.Opportunity_StageName_NeedsAssessment, oOpp.StageName, 'A quote object should be created.');
	}
}
