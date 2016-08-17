public class vfIECEBC_CampaignConfirm extends vfIECEBC_AccountEmailBlocks
{
	
    public Id ebcCampaignId {get;set;} // EBCEBC_Campaign__c.Id
    public EBC_Campaign__c ebcCampaign {get;set;}
    
	// constructor
	public vfIECEBC_CampaignConfirm(ApexPages.StandardController controller)
	{
        initID();
    }
    
	// constructor
	
	public vfIECEBC_CampaignConfirm()
    {
        initID();
    }
	private void initId()
	{
		String id = ApexPages.currentPage().getParameters().get('id');
        ebcCampaignId = id;
        updateNewPurchasedRatePlanChargeList(null);
        
        if (id != null) {
            List<EBC_Campaign__c> campaignList = [select Id, Name
						, Account__c
						, Audience__c
						, Billing_Account__c
						, Campaign_ID__c
						//, ConnectionReceivedId
						//, ConnectionSentId
						//, CreatedById
						//, CreatedDate
						//, CurrencyIsoCode
						, EBC_Design__c
						//, EBC_Master_Filter__c
						//, EBC_Selected_Template__c
						, Exact_Target_Campaign_Id__c
						//, From_Name__c
						//, Google_Analytics_Tracking_Code__c
						//, Is_Google_Analytics_Tracker_Active__c
						//, Is_Step1_Valid__c
						//, Is_Step1_Writable__c
						//, Is_Step2_Valid__c
						//, Is_Step2_Writable__c
						//, Is_Step3_Valid__c
						//, Is_Step3_Writable__c
						//, Is_Step4_Valid__c
						//, Is_Step4_Writable__c
						//, Is_Step5_Valid__c
						//, Is_Step5_Writable__c
						//, Is_Step6_Valid__c
						//, LastActivityDate
						//, LastModifiedById
						//, LastModifiedDate
						//, LastReferencedDate
						//, LastViewedDate
						//, Maximum_Allowed_Step__c
						, Number_of_Recipients__c
						//, OwnerId
						, Scheduled_Date_Valid_Until__c
						, Scheduled_Date__c
						, Status__c
						//, Subject__c
						//, Test_Email_Last_Send_Time_Stamp__c
						//, Test_Email_Total_Sent_On_Stamp_Period__c
						//, Test_Email_Total_Sent_Today__c 
				from EBC_Campaign__c 
				where Id = :ebcCampaignId
				limit 1] ;
			ebcCampaign = ( campaignList.size() == 0)  ? null :campaignList[0];
            minimumEmailBlockPurchaseSize = Integer.valueOf(ebcCampaign.Number_of_Recipients__c) - Integer.valueOf(billingAccount.eBroadcast_Email_Balance__c);
            payWithEmailPackage = false;
            payWithExactAmount = false;
        }
        
        
    }
	
    public String newBalanceLabel{ 
        get{
            String balanceLabel = (Integer.valueOf(ebcCampaign.Number_of_Recipients__c) > Integer.valueOf(billingAccount.eBroadcast_Email_Balance__c))
                           ? 'New Balance' : 'Balance Owing';
            return balanceLabel;
        }
    }
    
    // number of the email balance after this email is executed, based on current available balance,
    // excluding the new to bepurchased email block package
    public Integer newEmailBalance {
        get{
            return ( Integer.valueOf(billingAccount.eBroadcast_Email_Balance__c) - Integer.valueOf(ebcCampaign.Number_of_Recipients__c));
        }
        private set;
    }
    
    // note totalPurchaseAmount is based on vfIECEBC_Controller.totalNewPurchaseAmount
    // or the pay selected amount
    public Decimal totalPurchaseAmount {
        get{
            Decimal total = (payWithExactAmount) ?  
                			productRatePlan.EBC_Currency_Cost_Per_Email__c * minimumEmailBlockPurchaseSize
                			: totalNewPurchaseAmount;
            //System.debug( 'vfIECEBC_CampaignConfirm.totalNewPurchaseAmount'+ totalNewPurchaseAmount);
            return total;
        }
        
        
    } // totalPurchaseAmount 

    
    public Boolean payWithEmailPackage{
        get;
        set;
    } 
    
    public Boolean payWithExactAmount{
        get;
        set;
    } 
    
    public String paymentItemDescription {
        get {
            String str = (payWithEmailPackage) 
                		? ( (selectedProductRatePlanWrapper == null && minimumEmailBlockPurchaseSize > 0) 
                         		? 'Please make a selection'
                         		: selectedProductRatePlanWrapper.name )
                		: ( ( minimumEmailBlockPurchaseSize > 0) ? 
                			'Exact purchase of ' + String.valueOf( minimumEmailBlockPurchaseSize ) + '  * ' + String.valueOf(productRatePlan.EBC_Currency_Cost_Per_Email__c)
                			: 'No need to purchase more email');
            return str;
        }
    }
    
    public Boolean showPaymentItem1{
        get{
            return (payWithEmailPackage && selectedProductRatePlan == null);
        }
    }
    public Boolean showPaymentItem2{
        get{
            return (payWithEmailPackage && selectedProductRatePlan == null);
        }
    }
    public Boolean showPaymentItem3{
        get{
            return (selectedProductRatePlan != null || !payWithEmailPackage);
        }
    }
    public Boolean showPaymentItem4{
        get{
            return true;
        }
    }
    
    public Integer emailCreditPurchased{
        get{
            Integer x =  ( payWithEmailPackage ) ? selectedProductRatePlanWrapper.currentEmailCredits : minimumEmailBlockPurchaseSize;
            return x;
        }
    }
        
    public Decimal emailUnitCost{
        get{
            Decimal x = ( payWithEmailPackage ) ? selectedProductRatePlan.EBC_Currency_Cost_Per_Email__c : productRatePlan.EBC_Currency_Cost_Per_Email__c ;
            return x;
        }
    }
        
    
    
    public Decimal paymentItemAmount {
        get {
            Decimal amt = (payWithEmailPackage) 
                		? ( (selectedProductRatePlanWrapper == null && minimumEmailBlockPurchaseSize > 0) 
                         		? 0
                         		: selectedProductRatePlanWrapper.amount )
                		: ( ( minimumEmailBlockPurchaseSize > 0) ? 
                			 minimumEmailBlockPurchaseSize * productRatePlan.EBC_Currency_Cost_Per_Email__c
                			: 0 );
            return amt;
        }
    }
    
    public void clickPayWithEmailPackage(){
        payWithEmailPackage = true;
        payWithExactAmount = false;
    }
    
    public void clickPayWithExactAmount(){
        payWithExactAmount = true;
        payWithEmailPackage = false;
    }
}