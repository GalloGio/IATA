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
        itemsPerPage = 5; // number of items per page
        sortBy = 'Activity_Date_Time__c ASC, LastModifiedDate ASC'; // set order direction
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
        System.debug( 'getQuery: ' + query);
        currentQuery = query;
        return query;
    } // getQuery
    
    // ========================================================================
    public List<EBC_Activity__c> activityList {
        get{
            system.debug ('vfIECEBC_ManageAccount getActivityList:' + items.size() );
        
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
            System.debug( 'selectedActivityTypeClause getter starts');
            String activitySetString = ''; // include '' as the default search
            String activityNotSetString = '';
            boolean ArraySelected=false;
            boolean ArrayNotSelected=false;
            for (ActivityTypeWrapper atw : activityTypeWrapperList)
            {
                if (atw.activityType=='') continue;
                System.debug( 'atw:' + atw);
                if (atw.selected) {
                    ArraySelected=true;
                    activitySetString += ((activitySetString == '') ? '' : ', ') + '\'' + atw.activityType + '\'';
                }else{
                    ArrayNotSelected=true;
                    activityNotSetString += ((activityNotSetString == '') ? '' : ', ') + '\'' + atw.activityType + '\'';
                
                }
            }
            
            //if (activitySetString != '') {
            if (ArraySelected) activitySetString = ' and  Activity_Type__c in (' + activitySetString + ')';
            if (ArrayNotSelected) activityNotSetString = ' and  Activity_Type__c Not in (' + activityNotSetString + ')';
            //}
            System.debug( 'selectedActivityTypeClause getter returns: [' + activitySetString +']');
            return activitySetString+activityNotSetString;
        }
        private set;
    } // end selectedActivityTypeClause getter setter
    
    
    
    // ========================================================================
    // activityTypeWrapperList is used for selecting activity types
    public List<ActivityTypeWrapper> activityTypeWrapperList {
        get{
            System.debug( 'activityTypeWrapperList getter starts' + activityTypeWrapperList);
            if (activityTypeWrapperList == null)
            {
                System.debug( 'activityTypeWrapperList initialization' );
                List<ActivityTypeWrapper> actWrapList = new List<ActivityTypeWrapper>();
                for (String actType : activityTypeSelectionList)
                {
                    ActivityTypeWrapper atw = new ActivityTypeWrapper(actType);
                    atw.index = actWrapList.size();
                    actWrapList.add(atw);
                }
                activityTypeWrapperList = actWrapList;
            }
            System.debug( 'activityTypeWrapperList size:' + activityTypeWrapperList.size());
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
        //System.debug( 'xxxx with actClause:' + selectedActivityTypeClause);
        resetQuery(); // redefine the query with new filter
        getQuery(false);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'refresh table'));
        System.debug( 'vfIECEBC_ManageAccount.refreshTable ends, activityList:' + activityList.size() + activityList);
    }
    
    
    
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