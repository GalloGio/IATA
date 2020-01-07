/**
 * Controller associated with the Dashboard
 * Change Log:
 *  - 20160826-sl: add renew links (with showRenewNow/renewalPageUrl)
 *
 **/

public with sharing class vfIECEBC_Dashboard extends vfIECEBC_Controller {
	public Integer campaignsCount {
		get {
			if (campaignsCount == null)
			{

				campaignsCount = [select count()
								from EBC_Campaign__c
								where Billing_Account__c = :billingAccount.Id];
			}
			return campaignsCount;
		}
		private set;
	} // campaigns

	// ========================================================================
	// constructor
	public vfIECEBC_Dashboard() { }
	public vfIECEBC_Dashboard(ApexPages.StandardController controller) { }


	// ========================================================================
	// showRenewNow link is used to turn on/off Renew Subscription link
	public Boolean showRenewNow{
		get{
			return vfIECEBC.isSubscriptionRenewable;
		}
	} // end of showRenewNow getter


	// ========================================================================
	// renewalPageUrl link contains the URL for the URL
	public String renewalPageUrl{
		get{
			return IECEBC_Utility.renewalPageUrl;
		}
	} // end of renewalPageUrl getter
} // vfIECEBC_Dashboard
