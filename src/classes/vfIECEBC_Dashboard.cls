/**
 * Controller associated with the Dashboard 
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
	
} // vfIECEBC_Dashboard