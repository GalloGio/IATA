/*
	* Controller for the IECEBC misc payment pages , Renew page
	* Initial Author: Sonny Leman
	*
	* Description:
	*  -
	*  -
	*  -
	*
	* History:
	*  - 20160915-sl: initial dev version
	*/


public without sharing class vfIECEBC_Payment extends vfIECEBC_Controller
{
	// ========================================================================
	// incoming Url parameter and will be passed to the IECEBC_Payment.component
	public String paymentToken {get;set;}

	// used only for IECEBC_CampaignPayment
	public Id ebcCampaignId {get;set;} // EBCEBC_Campaign__c.Id
	public EBC_Campaign__c ebcCampaign {get;set;}


	// ========================================================================
	// these 2 getters might be deleted later, moved to component
	public Contact paymentBillingContact{
		get{
			if (paymentBillingContact == null)
			{
				paymentBillingContact = billingAccount.Contact__r;
			}
			return paymentBillingContact;
		}
		set;
	}

	public Zuora__CustomerAccount__c paymentBillingAccount {
		get {
					 /*
			if (paymentBillingAccount == null)
			{
				paymentBillingAccount = new Zuora__CustomerAccount__C (Name = billingAccount.Name
															, Zuora__BillToAddress1__c = billingAccount.Zuora__BillToAddress1__c
															, Zuora__BillToAddress2__c = billingAccount.Zuora__BillToAddress2__c
															, Zuora__BillToState__c = billingAccount.Zuora__BillToState__c
															, Zuora__BillToPostalCode__c = billingAccount.Zuora__BillToPostalCode__c
															, Zuora__BillToCountry__c = billingAccount.Zuora__BillToCountry__c );
			}*/
			return paymentBillingAccount;
		}
		set;
	}


	// ========================================================================
	// constructor for page based on EBC_Campaign standard controller
	public vfIECEBC_Payment(ApexPages.StandardController controller)
	{
		initialization();
	}

	// ========================================================================
	// constructor for other pages
	public vfIECEBC_Payment()
	{
		initialization();

	} // vfIECEBC_Payment constructor


	// ========================================================================
	private void initialization()
	{
		//shoppingCartController = VfIECShoppingCart();
		PageReference thisPage = ApexPages.currentPage();
		paymentToken = thisPage.getParameters().get( EBC_PAYMENT_PARAM_PAYMENT_TOKEN);

		// this might only apply to call from CampaignConfirm
		String campId = thisPage.getparameters().get('id');
		//ebcCampaignId = campId;

	} // end of initialization

} // end of vfIECEBC_Payment class
