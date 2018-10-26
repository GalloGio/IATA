/**  
  * Description: 
  * 	This class contains batchable class for EBC_Account_Notification object for Renewal Offering Email
  *	
  * Initial Author: Sonny Leman
  * Version: 1.0
  * History: 
  *   2016-08-26-sl: initial version
  *
  * Note:
  *  - Email notification will only be sent to those satisfying the following conditions
  *    * Zuora__Subscription__r.Zuora__Status__c = Active
  *    * Zuora__Subscription__r.Zuora__TermEndDate__c = Today - EBC_Setup__c.Renewal_Window__c
  *    * zqu__ProductRatePlan__c in  availableEbcRatePlanIdSet (Prepaid product rate plan, as defined in EBC_Setup)
  * 
  *  - Email will be set to the email and contact name in EBC_Preference (there should only be one eBroadcast_Preference)
  * 
  */
 
global class BtchEBCCreateNotificationForRenewal implements Database.Batchable<sObject>, Database.Stateful {
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
	private static final Integer HISTORY_CUT_OFF_MONTHS = 3; // record age that will be deleted, even if the BillingAccount.Id is not in current notification
	
	// field/label constants for EBC_Account_Notification fields
	private static final String EBC_ACCOUNT_STATUS_ACTIVE = 'Active';
	//private static final String EBC_ACCOUNT_STATUS_INACTIVE = 'Inactive';
	
	private static final String EBC_ACCOUNT_NOTIFICATION_TYPE_RENEWAL = 'Renewal Offer'; // EBC_Account_Notification__c.Notification_Type__c value
	private static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO = 'Pay-As-You-Go';	
	private static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID = 'Pre-Paid';	
	
	
	// ========================================================================
	// constructor
	global BtchEBCCreateNotificationForRenewal() {
		logs = new List<IEC_Error_Log__c>();
		bErrorFound = false;
		
		manageAccountUrl = IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/' + MANAGE_ACCOUNT_PAGE;
		createCampaignUrl = IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/' +  CREATE_CAMPAIGN_PAGE;
		ebcDashboardUrl =  IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/' +  EBC_DASHBOARD_PAGE + IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_EBROADCAST);
	}
	
	// ========================================================================
	global Database.querylocator start(Database.BatchableContext BC){
		//showQuery(query);
		return Database.getQueryLocator(query);
	} // end of queryLocator
	
	
	// ========================================================================
	// batch execution method
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		System.debug( 'BtchEBCCreateNotificationForRenewal: execute(), scope length:' + scope.size());
		
		Map<Id, Zuora__SubscriptionProductCharge__c> subProdChargeIdToObjectMap = new Map<Id, Zuora__SubscriptionProductCharge__c>();
		Map<Id, Zuora__CustomerAccount__c> billingAccountIdToObjectMap = new Map<Id, Zuora__CustomerAccount__c>();
		for(sObject rec : scope) {
			Zuora__SubscriptionProductCharge__c spcRec = (Zuora__SubscriptionProductCharge__c) rec;
			subProdChargeIdToObjectMap.put(spcRec.Id, spcRec);
			
			Zuora__CustomerAccount__c baRec = spcRec.Zuora__Subscription__r.Zuora__CustomerAccount__r; // Id, Name
			billingAccountIdToObjectMap.put(baRec.Id, baRec);
		}
				
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
	// use callBatchEBCCreateNotification to do standard call to this batch class.
	// this will simplify debugging and scheduling this job
	//
	public static void callBatchEBCCreateNotification()	{
	
		BtchEBCCreateNotificationForRenewal btchProc = new BtchEBCCreateNotificationForRenewal();
		
		// get related subscription and those details
		btchProc.query =
			'SELECT Id, Name'
			+ ', Zuora__Subscription__r.Name '
			+ ', Zuora__Subscription__r.Zuora__Status__c '
			+ ', Zuora__Subscription__r.Zuora__CustomerAccount__c '
			+ ', Zuora__Subscription__r.Zuora__CustomerAccount__r.Id '
			+ ', Zuora__Subscription__r.Zuora__CustomerAccount__r.Name '
			+ ', Zuora__Subscription__r.Zuora__CustomerAccount__r.Contact__c '
			+ ', Zuora__Subscription__r.Zuora__CustomerAccount__r.eBroadcast_Email_Balance__c '
			+ ', Zuora__Subscription__r.Zuora__NextRenewalDate__c '
			+ ', Zuora__Subscription__r.Zuora__TermEndDate__c '
			+ ', Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Name '
			+ ', Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_SubscriptionType__c '
			+ ' from Zuora__SubscriptionProductCharge__c '
			+ ' where Product_Rate_Plan_Charge__r.zqu__Deleted__c = false '
			+ '   and Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c in ' + availableEbcRatePlanIdSetString 
			+ '   and Zuora__Subscription__r.Zuora__Status__c = \'Active\' '
			+ '   and Zuora__Subscription__r.Zuora__NextRenewalDate__c = ' + subscriptionRenewalTargetDateString
			;
		
        //System.debug( 'to exec batch ' + btchProc.query);
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
		Map<Id, EBC_Account_Notification__c> billingAccountIdToEbcAccountNotificationMap = new Map<Id,EBC_Account_Notification__c>();
		Map<Id, EBC_Preference__c> ebcPreferenceIdToObjectMap = new Map<Id, EBC_Preference__c>([ select Id, Name 
							, Billing_Account__c
							, PrimaryContact_Email__c
							, PrimaryContact_Name__c
							from EBC_Preference__c
							where Billing_Account__c in : billingAccountIdToObjectMap.keySet()
						]);
		
		for (EBC_Preference__c ebcPref : ebcPreferenceIdToObjectMap.values()) 
		{
			Zuora__CustomerAccount__c billingAcct = billingAccountIdToObjectMap.get(ebcPref.Billing_Account__c);

			EBC_Account_Notification__c accNotification = new EBC_Account_Notification__c( Billing_Account__c = billingAcct.Id
																						, Name = billingAcct.Name
																						, Email_Balance__c = billingAcct.eBroadcast_Email_Balance__c
																						, Notification_Type__c = EBC_ACCOUNT_NOTIFICATION_TYPE_RENEWAL
																						, Notification_Date__c = Date.today()
																						, EBC_Account_Status__c = EBC_ACCOUNT_STATUS_ACTIVE // (selected billingAcct.eBroadcast_Product_Access__c should  be true)
																						, Create_New_Campaign_URL__c = createCampaignUrl
																						, Manage_My_Account_URL__c = manageAccountUrl
																						, EBC_Dashboard_URL__c = ebcDashboardUrl
																						);
			
			accNotification.Primary_Contact_Name__c = ebcPref.PrimaryContact_Name__c;
			accNotification.Email__c = ebcPref.PrimaryContact_Email__c;
			
			billingAccountIdToEbcAccountNotificationMap.put(billingAcct.Id, accNotification);
			
			if (billingAcct.Contact__c != null) {
				contactIdToAccountNotificationMap.put(billingAcct.Contact__c, accNotification);
			}

		} // end for Zuora__CustomerAccount__c
		
		
		// complete the information based on SubscriptionProductCharge/ProductRatePlan or Subscription
		// in the hypothetical case of multiple subscription found, pick the one with the latter Zuora__TermEndDate__c
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
				accNotification.Subscription_End_Date__c = subProdCharge.Zuora__Subscription__r.Zuora__TermEndDate__c;
				accNotification.Next_Renewal_Date__c = subProdCharge.Zuora__Subscription__r.Zuora__NextRenewalDate__c;
			} // end if accNotification
		} //  end for Zuora__SubscriptionProductCharge__c
		
		// collect the user name relevant BillingAccounts
		Map<Id,User> userIdToObjectMap = new Map<Id,User> ([select Id, ContactId, Email
				from User
				where IsPortalEnabled = true
					and contactId in : contactIdToAccountNotificationMap.keySet()]);
		for (User usr : userIdToObjectMap.values())	{
			EBC_Account_Notification__c acctNot = contactIdToAccountNotificationMap.get(usr.ContactId);
			acctNot.UserName__c = usr.Email;
		}
		
		// insert new EBC Account Notification records
		try {
			insert billingAccountIdToEbcAccountNotificationMap.values();
		} catch (Exception ex) {
			System.debug( 'BtchEBCCreateAccountNotificationOnStatus.prepareEBCAccountNotification(), error on inserting ' + subProdChargeIdToObjectMap.values());
			System.debug( 'Exception: ' + ex );
			
			logs.add(IECErrorLogger.logBatchError('Error on inserting.', ex.getMessage(), null
					, 'BtchEBCCreateAccountNotificationOnStatus', ex.getStackTraceString()));
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
				where Notification_Type__c = : EBC_ACCOUNT_NOTIFICATION_TYPE_RENEWAL
					and (Billing_Account__c in : billingAccountIdSet
						or CreatedDate < : veryOldDate)
				order by CreatedDate desc 
				limit : BATCH_DELETE_SIZE
				];
		try {
			delete oldNotificationList;
		} catch (Exception ex) {
			System.debug( 'BtchEBCCreateAccountNotificationOnStatus.prepareEBCAccountNotification(), error on deleting old recs' + oldNotificationList);
			System.debug( 'Exception: ' + ex );
			logs.add(IECErrorLogger.logBatchError('Error on deleting.', ex.getMessage(), null
					, 'BtchEBCCreateAccountNotificationOnStatus', ex.getStackTraceString()));
		}
	} // end of deleteEBCAccountNotification
	
	
	// ========================================================================
	// return the Renewal Date in string format for the batch query
	@TestVisible
	private static String subscriptionRenewalTargetDateString
	{
		get{
			if (subscriptionRenewalTargetDateString == null)
			{
				Date endDate = (IECEBC_Utility.ebcSetup.Renewal_Window__c == null) ? null 
						: Date.today().addDays( (Integer) IECEBC_Utility.ebcSetup.Renewal_Window__c);
				subscriptionRenewalTargetDateString = (endDate==null) ? ' null ' : String.valueOf(endDate);
			}
			return subscriptionRenewalTargetDateString;
		}
		
		private set;
	} // end of subscriptionRenewalTargetDateString
	
	
	// ========================================================================
	// availableRatePlanSet is the collection of Id for EBC Product Rate Plans, member or non members
	// this is independent of the users or billing accounts
	// in String, so it will be ( 'firstId', 'secondId' )
	@TestVisible
	private static String availableEbcRatePlanIdSetString{
		get{
			if (availableEbcRatePlanIdSetString == null) {
				Set<Id> ebcRatePlanSetId = new Set<Id>();
				ebcRatePlanSetId.addAll(IECEBC_Utility.ebcMemberProductRatePlanIdList);
				ebcRatePlanSetId.addAll(IECEBC_Utility.ebcNonMemberProductRatePlanIdList);
                
				String idSetString =''; 
				for (Id theId : ebcRatePlanSetId)
				{
					idSetString += '\'' + theId + '\',';
				}
				availableEbcRatePlanIdSetString = '(' + idSetString.removeEnd(',') + ')';
                
                if (Test.isRunningTest() && ebcRatePlanSetId.size()==0) availableEbcRatePlanIdSetString = '(null)'; // this is only to ease SchdlEBCCreateNotificationForRenewal_tst with no data
			}
			return availableEbcRatePlanIdSetString;
		}
		private set;
	} // end of availableEbcRatePlanIdSetstring getter/setter
	
	// ========================================================================
	// debugging tool to show if the query return some records
	private static void showQuery( String query)
	{
		System.debug( '\n=======================================================\n') ;
		System.debug( '\nBtchEBCCreateNotificationForRenewal query at ' + DateTime.now() + ':\n' + query) ;
		List<Zuora__SubscriptionProductCharge__c> subProdChargeList = Database.query(query + ' LIMIT 5');
		System.debug( '\nZuora__SubscriptionProductCharge query num of recs:' + subProdChargeList.size());
		System.debug( 'Zuora__SubscriptionProductCharge query result:' + subProdChargeList);
	} // showQuery
	
} // end of BtchEBCCreateNotificationForRenewal class