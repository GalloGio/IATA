/**
 * Controller associated with the IECEBC_SubsriptionRenewal
 * Change Log:
 *  - 20160920-sl: initial version
 *
 **/


public with sharing class vfIECEBC_SubscriptionRenewal extends vfIECEBC_Controller {

	public vfIECEBC_SubscriptionRenewal()
	{

	}

	// ========================================================================
	// link to the payment page (renewal)
	// the information is passed on the billingAccount record
	// use paymentToken as Url Parameter to ensure the communication integrity between pages.
	// the detail on the product rate plan charge will be recalculated and reselected
	// this ensure the data integrity and simplify the caller
	// for IECEBC_Dashboard, this is a renewal.
	public PageReference goToRenewalPaymentPage()
	{
		PageReference paymentPage = goToPaymentPageBase( Page.IECEBC_Payment, EBC_PAYMENT_TARGET_RENEWAL, EBC_PAYMENT_CAMPAIGN_NONE
							, subscription.Id
							, productRatePlan.Id // EBC productRatePlanId
							, null // campaignId
							, 0 // emailCreditAmount
							);
		return paymentPage;
	} // end of goToPaymentPage



}
