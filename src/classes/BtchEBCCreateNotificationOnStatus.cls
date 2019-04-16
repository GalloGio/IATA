/**  
  * Description: This class contains batchable class for EBC_Account_Notification
  * Initial Author: Sonny Leman
  * Version: 1.0
  * History: 
  *   2016-08-26-sl: initial version
  *
  * Note:
  *   - Email notification will only be sent to those with Zuora__CustomerAccount__c.eBroadcast_Product_Access__c = true
  *	 and eBroadcast_Preferences__r.Monthly_Account_Status__c = true. 
  *   - Email will be set to the email and contact name in eBroadcast_Preferences (there should only be one eBroadcast_Preference)
  *   - In case there is more than one matching Zuora__Subscription, pick the one the the latest Zuora__Subscription__r.Zuora__TermEndDate__c
  *   - For subscription end date, use Zuora__Subscription__r.Zuora__TermEndDate__c
  * 
  */
  
global class BtchEBCCreateNotificationOnStatus implements Database.Batchable<sObject>, Database.Stateful {
	global List<IEC_Error_Log__c> logs;
	
	public String query; // this is the query to pass to this batch job
	private Boolean bErrorFound;
	private String errorMessage;
	
	private String manageAccountUrl;  // complete url for IECEBC_AccountManage.page
	private String createCampaignUrl; // complete url for IECEBC_Campaign.page
	private String ebcDashboardUrl; // complete url for IECEC_Dashboard with its parameter
	
	// configuration constants
	private static final String MANAGE_ACCOUNT_PAGE = 'IECEBC_AccountManage'; // the page for the manage account
	private static final String CREATE_CAMPAIGN_PAGE = 'IECEBC_Campaign'; // the page for creating a new campaign
	private static final String EBC_DASHBOARD_PAGE = 'IECEBC_Dashboard?ProductCode='; // the page for creating a new campaign
	
	private static final Integer BATCH_INSERT_SIZE = 200; // batch size for creating new record
	private static final Integer BATCH_DELETE_SIZE = 600; // batch size for deleting record, should be no less than BATCH_INSERT_SIZE
	private static final Integer HISTORY_CUT_OFF_MONTHS = 2; // record age that will be deleted, even if the BillingAccount.Id is not in current notification
	
	// field/label constants for EBC_Account_Notification fields
	private static final String EBC_ACCOUNT_STATUS_ACTIVE = 'Active';
	
	private static final String EBC_ACCOUNT_NOTIFICATION_TYPE_STATUS = 'Account Status'; // EBC_Account_Notification__c.Notification_Type__c value
	private static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO = 'Pay-As-You-Go';	
	private static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID = 'Pre-Paid';	
	
	
	// ========================================================================
	// constructor
	global BtchEBCCreateNotificationOnStatus() {
		logs = new List<IEC_Error_Log__c>();
		bErrorFound = false;
		
		manageAccountUrl = IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/' + MANAGE_ACCOUNT_PAGE;
		createCampaignUrl = IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/' +  CREATE_CAMPAIGN_PAGE;
		ebcDashboardUrl =  IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/' +  EBC_DASHBOARD_PAGE + IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_EBROADCAST);
	}
	
	// ========================================================================
	global Database.querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	} // end of queryLocator
	
	
	// ========================================================================
	// batch execution method
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		Map<Id, Zuora__CustomerAccount__c> billingAccountIdToObjectMap = new Map<Id, Zuora__CustomerAccount__c>();
		
		for(sObject rec : scope) {
			Zuora__CustomerAccount__c baRec = (Zuora__CustomerAccount__c) rec;
			billingAccountIdToObjectMap.put(baRec.Id, baRec);
		}
		
		// get related subscription and those details
		Map<Id, Zuora__SubscriptionProductCharge__c> subProdChargeIdToObjectMap = new Map<Id, Zuora__SubscriptionProductCharge__c>([select Id, Name
						, Zuora__Subscription__r.Name
						, Zuora__Subscription__r.Zuora__Status__c
						, Zuora__Subscription__r.Zuora__CustomerAccount__c
						, Zuora__Subscription__r.Zuora__NextRenewalDate__c
						, Zuora__Subscription__r.Zuora__TermEndDate__c 
						, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Name
						, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_SubscriptionType__c						
					from Zuora__SubscriptionProductCharge__c
					where Zuora__Subscription__r.Zuora__CustomerAccount__c in : billingAccountIdToObjectMap.keyset()
						and Product_Rate_Plan_Charge__r.zqu__Deleted__c = false
						and Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c in : availableEbcRatePlanIdSet
						and Zuora__Subscription__r.Zuora__Status__c = 'Active'
						and Zuora__Subscription__r.Zuora__TermEndDate__c >= TODAY
					]);
		
		prepareEBCAccountNotification(billingAccountIdToObjectMap, subProdChargeIdToObjectMap );
		
		// Insert error logs if applicable
		if (!logs.isEmpty()) {
			bErrorFound = true;
			insert logs;
			logs.clear();
		}
	} // end of execute
	
	
	// ========================================================================
	// when this batch is finish, call next job on the line
	global void finish(Database.BatchableContext BC) {	
		// Insert error logs if applicable
		if (!logs.isEmpty()) {
			bErrorFound = true;
			insert logs;
		}
		
	} // end of finish
	
	
	// ========================================================================
	// use callBatchEBCCreateAccountNotificationOnStatus to do standard call to this batch class.
	// this will simplify debugging and scheduling this job
	//
	public static void callBatchEBCCreateNotification(){
		
		BtchEBCCreateNotificationOnStatus btchProc = new BtchEBCCreateNotificationOnStatus();
		
		btchProc.query =
			'SELECT Id, Name'
			+ ', eBroadcast_Email_Balance__c'
			+ ', eBroadcast_Product_Access__c'
			+ ', Contact__c'
			+ ', (select Id, Monthly_Account_Status__c, PrimaryContact_Email__c, PrimaryContact_Name__c from eBroadcast_Preferences__r order by Id) ' // for email recipient
			+ '	FROM Zuora__CustomerAccount__c '
			+ '	WHERE eBroadcast_Product_Access__c = true '
			+ ' ORDER BY Name, Id';

		Database.executeBatch(btchProc, BATCH_INSERT_SIZE);
	} // callBatchEBCCreateNotification
	
	
	// ========================================================================
	// for the given BillingAccount, delete related old notification, and create new ones
	// Some EBC Account Notification record might not have related subscription product charge
	// (e.g. for those who has Pay-As-You-Go ?)
	private void prepareEBCAccountNotification(Map<Id, Zuora__CustomerAccount__c> billingAccountIdToObjectMap
											, Map<Id, Zuora__SubscriptionProductCharge__c> subProdChargeIdToObjectMap )
	{
		deleteEBCAccountNotification(billingAccountIdToObjectMap.keySet());
		
		// set notification for each billing account, if EBC Preference Monthly Account Status is checked	
		Map<Id, EBC_Account_Notification__c> contactIdToAccountNotificationMap = new Map<Id,EBC_Account_Notification__c>();
		Map<Id,EBC_Account_Notification__c> billingAccountIdToEbcAccountNotificationMap = new Map<Id,EBC_Account_Notification__c>();
		for (Zuora__CustomerAccount__c billingAcct : billingAccountIdToObjectMap.values()) 
		{
			if (billingAcct.eBroadcast_Preferences__r.size() > 0) {
				EBC_Account_Notification__c accNotification = new EBC_Account_Notification__c( Billing_Account__c = billingAcct.Id
							, Name = billingAcct.Name
							, Email_Balance__c = billingAcct.eBroadcast_Email_Balance__c
							, EBC_Subscription_Type__c = EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO // default to pay as you go 
							, EBC_Rate_Plan_Name__c = EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO // default to prepaid, to be updated by related Zuora__SubscriptionProductCharge__c
							, Notification_Type__c = EBC_ACCOUNT_NOTIFICATION_TYPE_STATUS
							, Notification_Date__c = Date.today()
							, EBC_Account_Status__c = EBC_ACCOUNT_STATUS_ACTIVE // (selected billingAcct.eBroadcast_Product_Access__c should  be true)
							, Create_New_Campaign_URL__c = createCampaignUrl
							, Manage_My_Account_URL__c = manageAccountUrl
							, EBC_Dashboard_URL__c = ebcDashboardUrl
						);
				
				EBC_Preference__c ebcPref = billingAcct.eBroadcast_Preferences__r[0];
				accNotification.Primary_Contact_Name__c = ebcPref.PrimaryContact_Name__c;
				accNotification.Email__c = ebcPref.PrimaryContact_Email__c;
				
				// only those who is willing to receive email notification will get the notification
				if (ebcPref.Monthly_Account_Status__c) {
					billingAccountIdToEbcAccountNotificationMap.put(billingAcct.Id, accNotification);
					if (billingAcct.Contact__c != null) {
						contactIdToAccountNotificationMap.put(billingAcct.Contact__c, accNotification);
					}
				} // end if ebcPref.Monthly_Account_Status
			} // end of if billingAcct.eBroadcast_Preferences__r
		} // end for Zuora__CustomerAccount__c
		
		// complete the information based on SubscriptionProductCharge/ProductRatePlan or Subscription
		for ( Zuora__SubscriptionProductCharge__c subProdCharge : subProdChargeIdToObjectMap.values())
		{
			EBC_Account_Notification__c accNotification = billingAccountIdToEbcAccountNotificationMap.get(subProdCharge.Zuora__Subscription__r.Zuora__CustomerAccount__c);
			if ((accNotification != null) 
				&& (accNotification.Subscription_End_Date__c == null || accNotification.Subscription_End_Date__c < subProdCharge.Zuora__Subscription__r.Zuora__TermEndDate__c))
			{   // we select the subscription with last end date, 
				// and it is safe to assume it is an EBC Subscription, i.e (subProdCharge.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductCategory__c == 'eBroadcast')
				// this is for the EBC Subscription
				accNotification.EBC_Subscription_Type__c = subProdCharge.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_SubscriptionType__c;
				accNotification.EBC_Rate_Plan_Name__c = subProdCharge.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Name;
					
				// Subscription_End_Date is only for Prepaid
				if (accNotification.EBC_Subscription_Type__c == EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID) {
					accNotification.Subscription_End_Date__c = subProdCharge.Zuora__Subscription__r.Zuora__TermEndDate__c;
				}
				accNotification.Next_Renewal_Date__c = subProdCharge.Zuora__Subscription__r.Zuora__NextRenewalDate__c;
			} // end if accNotification
		} //  end for Zuora__SubscriptionProductCharge__c
		
		
		// collect the campaign statistics for relevant BillingAccounts
		List<AggregateResult> campaignAggrList = [select Related_Billing_Account__c 
				, sum(Total_Count__c) numOfEmailSent
				, count(Id) numOfCampaigns
				, calendar_year(Activity_Date_Time__c) year, calendar_month(Activity_Date_Time__c) month
			from EBC_Activity__c
			where Related_Billing_Account__c in : billingAccountIdToEbcAccountNotificationMap.keySet()
				and Activity_Date_Time__c = LAST_MONTH
				and EBC_Campaign__r.Status__c = 'SENT'
			group by Related_Billing_Account__c
					, calendar_year(Activity_Date_Time__c)
					, calendar_month(Activity_Date_Time__c)
			order by calendar_year(Activity_Date_Time__c), calendar_month(Activity_Date_Time__c)
					, Related_Billing_Account__c
			];

		for (AggregateResult campaignAggr : campaignAggrList)
		{
			String billingAccountId = (String) campaignAggr.get('Related_Billing_Account__c');
			if (billingAccountId != null) {
				EBC_Account_Notification__c accNotification = billingAccountIdToEbcAccountNotificationMap.get(billingAccountId);
				
				Decimal numOfEmailSentDEC = (Decimal)campaignAggr.get('numOfEmailSent');
				accNotification.Number_of_Email_Recipients_Last_Month__c = (Integer) numOfEmailSentDEC;
				
				Integer numOfCampaigns =  (Integer) campaignAggr.get('numOfCampaigns');
				accNotification.Number_of_Campaigns_Last_Month__c = numOfcampaigns;
			} // end if
		} // end of for campaignAggr
		
		// collect the user name relevant BillingAccounts
		Map<Id,User> userIdToObjectMap = new Map<Id,User> ([select Id, ContactId, Email
				from User
				where IsPortalEnabled = true
					and contactId in : contactIdToAccountNotificationMap.keySet()]);
		for (User usr : userIdToObjectMap.values())
		{
			EBC_Account_Notification__c acctNot = contactIdToAccountNotificationMap.get(usr.ContactId);
			acctNot.UserName__c = usr.Email;
		}
		
		// insert new EBC Account Notification records
		try {
			insert billingAccountIdToEbcAccountNotificationMap.values();
		} catch (Exception ex) {
			System.debug( 'BtchEBCCreateNotificationOnStatus.prepareEBCAccountNotification(), error on inserting ' + subProdChargeIdToObjectMap.values());
			System.debug( 'Exception: ' + ex );
			
			logs.add(IECErrorLogger.logBatchError('Error on inserting.', ex.getMessage(), null
					, 'BtchEBCCreateNotificationOnStatus', ex.getStackTraceString()));
		}
	} // prepareEBCAccountNotification
	
	
	// ========================================================================
	// for the given BillingAccount, delete related old notification of this Type
	private void deleteEBCAccountNotification( Set<Id> billingAccountIdSet )
	{
		// clean old EBC_Account_Notification records
		// also delete some other's old records (which might not have billing account included in the list)
		Date veryOldDate = Date.today().addMonths(- HISTORY_CUT_OFF_MONTHS);
		List<EBC_Account_Notification__c> oldNotificationList = [select Id 
				from EBC_Account_Notification__c 
				where Notification_Type__c = : EBC_ACCOUNT_NOTIFICATION_TYPE_STATUS
					and (Billing_Account__c in : billingAccountIdSet
						or CreatedDate < : veryOldDate)
				order by CreatedDate desc 
				limit : BATCH_DELETE_SIZE
				];
		try {
			delete oldNotificationList;
		} catch (Exception ex) {
			System.debug( 'BtchEBCCreateNotificationOnStatus.prepareEBCAccountNotification(), error on deleting old recs' + oldNotificationList);
			System.debug( 'Exception: ' + ex );
			logs.add(IECErrorLogger.logBatchError('Error on deleting.', ex.getMessage(), null
					, 'BtchEBCCreateNotificationOnStatus', ex.getStackTraceString()));
		}
	} // end of deleteEBCAccountNotification
	
	
	// ========================================================================
	// availableRatePlanSet is the collection of Id for EBC Product Rate Plans, member or non members
	// this is independent of the users or billing accounts
	private Set<Id> availableEbcRatePlanIdSet{
		get{
			if (availableEbcRatePlanIdSet == null) {
				Set<Id> ebcRatePlanSet = new Set<Id>();
				ebcRatePlanSet.addAll(IECEBC_Utility.ebcMemberProductRatePlanIdList);
				ebcRatePlanSet.addAll(IECEBC_Utility.ebcNonMemberProductRatePlanIdList);
				availableEbcRatePlanIdSet = ebcRatePlanSet;
			}
			return availableEbcRatePlanIdSet;
		}
		private set;
	} // end of availableEbcRatePlanIdSet getter/setter
	
	/*
	// ========================================================================
	// debugging tool to show if the query return some records
	private static void showQuery( String query)
	{
		System.debug( '\n\BtchEBCCreateNotificationOnStatus query at ' + DateTime.now() + ':\n' + query) ;
		List<Zuora__CustomerAccount__c> customerAccountList = Database.query(query + ' LIMIT 5');
		System.debug( '\n\BillingAcct query num of recs:' + customerAccountList.size());
		System.debug( 'BillingAcct query result:' + customerAccountList);
	} // showQuery
	*/	 
} // end of BtchEBCCreateNotificationOnStatus class

