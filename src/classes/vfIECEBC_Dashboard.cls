/*
 *  Controller for IECEBC_Dashboard, a.k.a eBroadcast Dashboard
 *  - Main objects: Zuora__Subscription, Zuora__CustomerAccount__c, Product_Rate_Plan_Information 
 *  - Original writer: Mathieu Beausoleil
 * 
 * Note that we intentionally try to avoid using IECPageController.loggedCustomer for the following reasons: 
 *  - Any test class requiring IECCustomer creation currently requires seeAllData true. 
 *  - IECCustomer constructor has conditional value for test run, which creates its own ZuoraAccount and BillingAccount.
 *  - In creating that ZuoraAccount (regular Account), IECTestUtil calls Zuora.zObject and Zuora.zSchema which requires Zuora WSDL
 *  
 *
 *  Change log:
 *   20160521: Mathieu Beausoleil
 *   20160530-sl: GDP-75/GDP-667: display the Account Summary section with EBC account status
 *
*/

public with sharing class vfIECEBC_Dashboard {
	class Controller_Exception extends Exception{}
	
	
	private User thisUser; // current login user
	
	public List<EBC_Campaign__c> campaigns {
		get {
			if (campaigns == null) 
			{	
			
				campaigns = [select Id, Is_Step5_Writable__c, Is_Step4_Valid__c, Name, Status__c, Scheduled_Date__c, Owner.Name 
								from EBC_Campaign__c 
								where Account__c = :thisUser.Contact.AccountId 
								order by LastModifiedDate desc limit 3];
			}
			return campaigns;
		}
		private set;
	} // campaigns
	
	public Integer getCampaignsCount() {
		return [Select count() From EBC_Campaign__c];
	} // getCampaignsCount
	
	// ========================================================================
	// the following properties are to be displayed in Account Summary section
	public String billingPlanName { get; private set;} // Zuora__Subscription__c.Product_Rate_Plan_Information__r.Name
	public String billingPlanRate { get; private set;} // Zuora__Subscription__c.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c
	public String emailBalanceOnAccount { get; private set;} // Zuora__Subscription__c.Zuora__CustomerAccount__r.eBroadcast_Available_Email_Balance__c
	
	public String availableAddOns { get; private set;} 
	
	
	// ========================================================================
	// constructor
	public vfIECEBC_Dashboard() {
		thisUser = [select Id, ContactId, Contact.AccountId 
			from User 
			where id =: Userinfo.getUserid() limit 1];
			
		getEBCSubscriptionInformation();
	} // end of vfIECEBC_Dashboard constructor
	
	
	// ========================================================================
	// get information related to EBC Subscription
	// billingPlanName, emailBalanceOnAccount, billingPlanName
	private void getEBCSubscriptionInformation()
	{
		// get subscription with Product Category = IECConstants.ProductCategory_SF_EBROADCAST
		// we do not care whether the Zuora Subscription__c.Zuora__Status__c = 'Active' or or not 
		List<Zuora__Subscription__c> subsList = [select Id, Name
				, Product_Rate_Plan_Information__r.Name
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c
				, Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c
				// , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c
				, Zuora__CustomerAccount__r.eBroadcast_Available_Email_Balance__c
				, Zuora__CustomerAccount__r.Contact__c
			from Zuora__Subscription__c
			where (Zuora__CustomerAccount__r.Contact__c = : thisUser.ContactId) 
				and ( (Zuora__SubscriptionEndDate__c >=  today) 
					or (Zuora__SubscriptionEndDate__c = null) )
				and (Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = : IECConstants.ProductCategory_SF_EBROADCAST)
				order by Zuora__SubscriptionStartDate__c desc
			];
		
		billingPlanName = 'BAD DATA: No Correct EBC Subscription found for this ContactId:' + thisUser.ContactId;
		if (subslist.size() > 0) 
		{
			billingPlanRate = '$' + subsList[0].Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c;
			// emailBalanceOnAccount = subsList[0].Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c;
			emailBalanceOnAccount = String.valueOf(subsList[0].Zuora__CustomerAccount__r.eBroadcast_Available_Email_Balance__c);
			billingPlanName = subsList[0].Product_Rate_Plan_Information__r.Name;
		}
	} // end of getEBCSubscriptionInformation
	
	
} // vfIECEBC_Dashboard