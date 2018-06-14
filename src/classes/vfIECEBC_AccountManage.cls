/**  
  * Controller for the IECEBC_AccountManage page (eBroadcast Account Details Overview) 
  * Initial Author: Sonny Leman
  * 
  * Description:
  *  - For a given Billing Account (Zuora__CustomerAccount)/User display the current EBroadcast information
  *  - Plan, cost, account balance
  *  - Personalized upgrade suggestion
  *  - Account activity summary and table
  *  
  * History: 
  *  - 20160721-sl: initial version
  *  - 20160810-sl: graph is added
  *  - 20160826-sl: add Renew Link
  *  - 20161010-ab: activity UAT-162
  *  - 20161128-ab: activity UAT-208
  */


public with sharing class vfIECEBC_AccountManage extends vfIECEBC_Abstract_List
// vfIECEBC_Controller is the base of vfIECEBC_Abstract_List
{
	
	// ========================================================================
	// constant definition 
	private static final String EBC_SUBSCRIPTION_PAY_AS_YOU_GO = 'Pay-as-You-Go';
	private static final List<String> activityTypeSelectionList = new List<String> { 'Adjustment', 'Credit', 'Send' };
	
	
	// ======================================================================== 
	// constructor
	public vfIECEBC_AccountManage()
	{
		// settings related to activityList
		itemsPerPage = 10; // number of items per page
		sortBy = 'Activity_Date_Time__c ASC, LastModifiedDate ASC'; // set order direction
		
		prepareGraphDataYearAfterYear();
		prepareGraphDataYearToDate();
	} // end of vfIECEBC_AccountManage constructor
	
	
	// ======================================================================== 
	// showSubscriptionEnd flag is used to turn on/off the end of subscription info 
	public Boolean showSubscriptionEnd{
		get{
			return (productRatePlan.EBC_SubscriptionType__c != EBC_SUBSCRIPTION_PAY_AS_YOU_GO);
		}
	}
	
	
	// ======================================================================== 
	// showSuggestionMessage flag is used to turn on/off upgrade suggestion message 
	public Boolean showSuggestionMessage{
		get{
			return (productRatePlanIdUpgradeSet != null && productRatePlanIdUpgradeSet.size() > 0);
		}
	}
	
	// ======================================================================== 
	// showRenewNow link is used to turn on/off Renew Now link 
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
	
	
	// ======================================================================== 
	// subscriptionId is used for debugging on VfP
	public String subscriptionId{
		get{
			return vfIECEBC.subscription.Id + ' - ' + vfIECEBC.subscription.Name;
		}
	} // end of showRenewNow getter
	
	
	// ========================================================================
	// totalCampaigns is the number of campaign records for this billing account
	public Integer totalCampaigns
	{
		get{
			if (totalCampaigns == null)
			{
				List<AggregateResult> aggrList = [select Count(Id) totalCount 
						from EBC_Campaign__c
						where Billing_Account__c = :billingAccount.Id
					];
				Object iTot =  (aggrList == null || aggrList.size() == 0) ? 0 : aggrList[0].get('totalCount');
				totalCampaigns =  (iTot == null ) ? 0 : Integer.valueOf(iTot);
			}
			return totalCampaigns;
		}
		private set;
	} // end of total campaigns
	
	// ========================================================================
	private List<EBC_Campaign__c> ebcCampaignList {
		get {
			if (ebcCampaignList == null)
			{
				ebcCampaignList = [select Id, Name 
					from EBC_Campaign__c
					where Billing_Account__c = :billingAccount.Id
					order by CreatedDate desc
					];
			}
			return ebcCampaignList;
		}
		private set;
	}
	
	
	// ========================================================================
	// totalSends is the total number of Send purchased and executed
	// this is based on the campaign order, prior to the adjustment due to opt-outs etc.
	public Integer totalSends
	{
		get{
			if (totalSends == null)
			{
				List<AggregateResult> aggrList = [select sum(Total_Count__c) sumTotalCount 
					from EBC_Activity__c
					where Related_Billing_Account__c = :billingAccount.Id
						and Activity_Type__c = 'Send'
					];
				Object iTot =  (aggrList == null || aggrList.size() == 0) ? 0 : aggrList[0].get('sumTotalCount');
				totalSends =  (iTot == null ) ? 0 : - Integer.valueOf(iTot);
			}
			return totalSends;
		}
		private set;
	} // end of totalSends
	
	// ========================================================================
	// totalCredits is the currnet total number of Adjustment email occurs
	// this excludes the initial balance given on new subscription
	public Integer totalAdjustments
	{
		get{
			if (totalAdjustments == null)
			{
				List<AggregateResult> aggrList = [select sum(Total_Count__c) sumTotalCount
					from EBC_Activity__c
					where Related_Billing_Account__c = :billingAccount.Id
						and Activity_Type__c = 'Adjustment'
					];
				
				Object iTot =  (aggrList == null || aggrList.size() == 0) ? 0 : aggrList[0].get('sumTotalCount');
				totalAdjustments =  (iTot == null ) ? 0 : Integer.valueOf(iTot);
			}
			return totalAdjustments;
		}
		private set;
	} // end of totalAdjustments
	
	
	// ========================================================================
	// Account EBC Activity List related methods below utilizes vfIECEBC_Abstract_List
	// to manage the query and pagination
	//
	// ========================================================================
	// getQuery return the EBC Activity List 
	// this overrides the virtual method
	// filtered by Activity Type
	public String getQuery(Boolean isCountOnly) {
		List<String> fields = new List<String>();
		if (isCountOnly) {
			fields.add('count()');
		} else {
			fields.add('Id');
			fields.add('Name');
			fields.add('Activity_Type__c');
			fields.add('Total_Count__c');
			fields.add('Activity_Date_Time__c');
			fields.add('EBC_Campaign__r.Name');
			fields.add('EBC_Campaign__r.Campaign_ID__c');
			fields.add('CreatedDate');
			fields.add('LastModifiedDate'); 
		}
		resetPaging();
		String query = 'Select ' + String.join(fields, ',') 
			+ ' FROM EBC_Activity__c '
			+ ' Where  Related_Billing_Account__c = \'' + billingAccount.Id + '\' '
			+ selectedActivityTypeClause;
        sortBy='Createddate desc';
		//System.debug( 'getQuery: ' + query);
		currentQuery = query;
		return query;
	} // getQuery
	
	// ========================================================================
	public List<EBC_Activity__c> activityList {
		get{
			return (List<EBC_Activity__c>)items; 
		}
	} // activityList getter
	
	public EBC_Activity__c getSelectedActivity() {
		
		return (EBC_Activity__c)selectedItem; 
	}
	
	public String currentQuery{get;set;} // only for debugging
	// ========================================================================
	// selectedActivityTypeClause will used as part of the getQuery
	// it adds the filtering based on selected activity types 
	public String selectedActivityTypeClause {
		get{
			String activitySetString = ''; // include '' as the default search
			String activityNotSetString = '';
            String activityNotZeroCredit=' and (Total_Count__c>0 or Total_Count__c<0)';
			boolean ArraySelected=false;
			boolean ArrayNotSelected=false;
			for (ActivityTypeWrapper atw : activityTypeWrapperList)
			{
				if (atw.activityType=='') continue;
				
				if (atw.selected) {
					ArraySelected=true;
					activitySetString += ((activitySetString == '') ? '' : ', ') + '\'' + atw.activityType + '\'';
				}else{
					ArrayNotSelected=true;
					activityNotSetString += ((activityNotSetString == '') ? '' : ', ') + '\'' + atw.activityType + '\'';
				
				}
			}
			
			
			if (ArraySelected) activitySetString = ' and  Activity_Type__c in (' + activitySetString + ')';
			if (ArrayNotSelected) activityNotSetString = ' and  Activity_Type__c Not in (' + activityNotSetString + ')';
			
			//System.debug( 'selectedActivityTypeClause getter returns: [' + activitySetString +']');
			return activitySetString+activityNotSetString+activityNotZeroCredit;
		}
		private set;
	} // end selectedActivityTypeClause getter setter
	
	
	
	// ========================================================================
	// activityTypeWrapperList is used for selecting activity types
	public List<ActivityTypeWrapper> activityTypeWrapperList {
		get{
			if (activityTypeWrapperList == null)
			{
				List<ActivityTypeWrapper> actWrapList = new List<ActivityTypeWrapper>();
				for (String actType : activityTypeSelectionList)
				{
					ActivityTypeWrapper atw = new ActivityTypeWrapper(actType);
					atw.index = actWrapList.size();
					actWrapList.add(atw);
				}
				activityTypeWrapperList = actWrapList;
			}
			return activityTypeWrapperList;
		}
		set;
	} // end of activityTypeWrapperList getter/setter
	
	
	// ========================================================================
	// refreshTable will be done by reseting the query, generate the updated query
	// (based on modification in activityTypeWrapperList)
	public void refreshTable()
	{
		//System.debug( 'vfIECEBC_ManageAccount.refreshTable starts');
		resetQuery(); // redefine the query with new filter
		getQuery(false);
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'refresh table'));
	} // end refreshTable
	
	
	// ========================================================================
	// graph related code 
	// ------------------------------------------------------------------------
	
	// ========================================================================
	// graph related properties that will be used by Vfp
	// data values 
	public List<Decimal> adjustmentYayData {get; private set;}
	public List<Decimal> creditYayData {get; private set;}
	public List<Decimal> sendYayData {get; private set;}
	
	public List<Decimal> adjustmentYtdData {get; private set;}
	public List<Decimal> creditYtdData {get; private set;}
	public List<Decimal> sendYtdData {get; private set;}
	
	// the axis labels: months
	public List<String> monthYayList {
		get {
			if (monthYayList == null) {
				monthYayList = getMonthListSince(beginningOfObservationYay);
			}
			return monthYayList;
		}
		private set;
	}
	
	public List<String> monthYtdList {
		get {
			if (monthYtdList == null) {
				monthYtdList = getMonthListSince(beginningOfObservationYtd);
			}
			return monthYtdList;
		} 
		private set;
	}
	
	
	// ========================================================================
	// initializer for preparing all the graph related properties above
	
	// ========================================================================
	// prepareGraphDataYearToDate initializes adjustmentYayData, creditYayData, sendYayData
	// the list size can vary from 1 to 12 (same year)
	private void prepareGraphDataYearToDate()
	{
		List<AggregateResult> aggrList = [select Activity_Type__c
			, sum(Total_Count__c) sumTotalCount
			, calendar_year(Activity_Date_Time__c) year, calendar_month(Activity_Date_Time__c) month
			from EBC_Activity__c
			where Related_Billing_Account__c = :billingAccount.Id 
				and Activity_Date_Time__c = THIS_YEAR
			group by Related_Billing_Account__c
					, calendar_year(Activity_Date_Time__c)
					, calendar_month(Activity_Date_Time__c)
					, Activity_Type__c
			order by calendar_year(Activity_Date_Time__c)
					, calendar_month(Activity_Date_Time__c)
					, Activity_Type__c
			];
		
		adjustmentYtdData = new List<Decimal>();
		creditYtdData = new List<Decimal>();
		sendYtdData = new List<Decimal>();
		for (Integer i=0;i< Date.today().month();i++)
		{
			adjustmentYtdData.add( 0);
			creditYtdData.add( 0);
			sendYtdData.add( 0);
		}
		Map<String, List<Decimal>> typeToListMap = new Map<String, List<Decimal>> { 'Adjustment' => adjustmentYtdData
			, 'Credit' => creditYtdData
			, 'Send' => sendYtdData };
		List<Decimal> targetList;
		
		for (AggregateResult aggr : aggrList)
		{
			targetList = typeToListMap.get( (String) aggr.get('Activity_Type__c'));
			Integer idx = (Integer) aggr.get('month')-1;
			targetList[idx] = Math.abs((Decimal) aggr.get('sumTotalCount'));
		}
	} // prepareGraphDataYearToDate
	
	
	// ========================================================================
	// prepareGraphDataYearToDate prepares adjustmentYayData, creditYayData, sendYayData
	// the list size is fixed to 13 (last 12 months)
	private void prepareGraphDataYearAfterYear()
	{
		List<AggregateResult> aggrList = [select Activity_Type__c
			, sum(Total_Count__c) sumTotalCount
			, calendar_year(Activity_Date_Time__c) year, calendar_month(Activity_Date_Time__c) month
			from EBC_Activity__c
			where Related_Billing_Account__c = :billingAccount.Id 
				and Activity_Date_Time__c >= : beginningOfObservationYay
			group by Related_Billing_Account__c
					, calendar_year(Activity_Date_Time__c)
					, calendar_month(Activity_Date_Time__c)
					, Activity_Type__c
			order by calendar_year(Activity_Date_Time__c), calendar_month(Activity_Date_Time__c)
					, Activity_Type__c
			];
		
		adjustmentYayData = new List<Decimal>{ 0,0,0,0,0,0, 0,0,0,0,0,0,0 };
		creditYayData = new List<Decimal>{0,0,0,0,0,0, 0,0,0,0,0,0,0 };
		sendYayData = new List<Decimal>{ 0,0,0,0,0,0, 0,0,0,0,0,0,0 };
		Map<String, List<Decimal>> typeToListMap = new Map<String, List<Decimal>> { 'Adjustment' => adjustmentYayData
			, 'Credit' => creditYayData
			, 'Send' => sendYayData };
		List<Decimal> targetList;
		
		Integer monthNumber;
		Integer yearNumber;
		Integer idx;
		for (AggregateResult aggr : aggrList)
		{
			targetList = typeToListMap.get( (String) aggr.get('Activity_Type__c'));
			monthNumber = (Integer) aggr.get('month');
			yearNumber = (Integer) aggr.get('year');
			idx = shiftIndex(yearNumber, monthNumber, beginningOfObservationYay);
			targetList[idx] = Math.abs((Decimal) aggr.get('sumTotalCount'));
		}
	} // prepareGraphDataYearAfterYear
	
	
	
	// ========================================================================
	// beginningOfObservation Year To Date, first day of the year
	private Datetime beginningOfObservationYtd
	{
		get {
			return datetime.newInstance( Date.today().Year(), 1, 1);
		}
	}
	
	// ========================================================================
	// beginningOfObservation Year After Year, first day of the month 12 months ago
	private Datetime beginningOfObservationYay
	{
		get {
			return datetime.newInstance( Date.today().Year(), Date.today().Month(), 1).addMonths(-12);
		}
	}
	
	// ========================================================================
	// shiftIndex return the list index for data of year and month,
	// given that the observation starts in startingDateTime
	private Integer shiftIndex( Integer year, Integer month, Datetime startingDateTime)
	{
		Integer base = (year - startingDateTime.year()) * 12 - startingDateTime.month() ;
		return base + month;
	}
	
	// ========================================================================
	// return a list of months since beginning until now
	private List<String> getMonthListSince(DateTime beginning)
	{
		Datetime observationTime = beginning;
		List<String> monthList = new List<String>();
		while (observationTime <= DateTime.now()) 
		{
			String newMonth = '\'' + observationTime.format('MMM') + ' ' + String.valueOf(Math.mod(observationTime.year(),100)) +  '\'';
			monthList.add(newMonth);
			observationTime = observationTime.addMonths(1);
		}
		return monthList;
	} // end of getMonthListSince
	
	
	// ========================================================================
	// wrapper class 
	public class ActivityTypeWrapper {
		public Integer index {get;set;}
		public Boolean selected {get;set;}
		public String activityType {get; private set;}
		public ActivityTypeWrapper(String actType) 
		{
			selected = true; 
			activityType = actType;
		}
		
	} // end of ActivityTypeWrapper class definition 
	
} // end of vfIECEBC_AccountManage