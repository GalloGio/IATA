/*  
  * Controller for the IECEBC_CampaignConfirm page
  * Initial Author: Sonny Leman
  * 
  * Description:
  *  - Input page parameter id: EBC_Campaign__c.Id 
  *  - This use vfIECEBC_AccountRatePlan and vfIECEBC_EmailBlocks for selecting email block or rate plan
  *  - 
  *   
  * History: 
  *  - 20160817-sl: initial working version
  *  - 20160915-sl: payment page url 
  */


public class vfIECEBC_CampaignConfirm extends vfIECEBC_Controller
{
    public Id ebcCampaignId {get;set;} // EBCEBC_Campaign__c.Id
    public EBC_Campaign__c ebcCampaign {get;set;}
    
    public vfIECEBC_AccountEmailBlocks acctEmailBlock {get;set;}
    public vfIECEBC_AccountRatePlan acctRatePlan {get;set;}
    
    // selected payment method, set by clickPayWithExactAmount, payWithEmailPackage, payWithRatePlan
    public Boolean payWithExactAmount {get;private set;} 
    public Boolean payWithEmailPackage {get;private set;} 
    public Boolean payWithRatePlan {get;private set;}
    
    // ========================================================================
    // constructor for page based on EBC_Campaign standard controller
    public vfIECEBC_CampaignConfirm(ApexPages.StandardController controller)
    {
        initialization();
    }
    
    // constructor for page using this class as the controller
    public vfIECEBC_CampaignConfirm()
    {
        initialization();
    }
    
    // ========================================================================
    // initialization initializes ebcCampaignId, ebcCampaign
    // other flags
    private void initialization()
    {
        String id = ApexPages.currentPage().getParameters().get('id');
        ebcCampaignId = id;
        updateNewPurchasedRatePlanChargeList(null);
        
        if (id == null) {
            //ebcCampaign = new EBC_Campaign__c( Name = 'Invalid Campaign', Number_of_Recipients__c = 0);
        } else {
            List<EBC_Campaign__c> campaignList = [select Id, Name
                        //, Audience__c
                        //Billing_Account__c
                        , Campaign_ID__c
                        //, ConnectionReceivedId
                        //, ConnectionSentId
                        //, CreatedById
                        //, CreatedDate
                        //, CurrencyIsoCode
                        //, EBC_Design__c
                        , EBC_Master_Filter__c
                        //, EBC_Selected_Template__c
                        //, Exact_Target_Campaign_Id__c
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
                        , Maximum_Allowed_Step__c
                        , Number_of_Recipients__c
                        , Is_Payment_Step__c
                        , Is_Step6_Valid__c
                        , Is_Step5_Valid__c
                        , Is_Step7_Valid__c
                        //, OwnerId
                        //, Scheduled_Date_Valid_Until__c
                        //, Scheduled_Date__c
                        , Status__c
                        //, Subject__c
                        //, Test_Email_Last_Send_Time_Stamp__c
                        //, Test_Email_Total_Sent_On_Stamp_Period__c
                        //, Test_Email_Total_Sent_Today__c 
                from EBC_Campaign__c
                where Id = :ebcCampaignId
                limit 1] ;
            ebcCampaign = ( campaignList.size() == 0)  ? null :campaignList[0];
            
            payWithEmailPackage = false;
            payWithExactAmount = true;
            payWithRatePlan = false;
        }
        
        acctEmailBlock = new vfIECEBC_AccountEmailBlocks();
        acctRatePlan = new vfIECEBC_AccountRatePlan();
        acctEmailBlock.minimumEmailBlockPurchaseSize = Integer.valueOf(ebcCampaign.Number_of_Recipients__c) - Integer.valueOf(billingAccount.eBroadcast_Email_Balance__c);
    } // end of initialization
    
    
    
    // ========================================================================
    // action function related methods
    public void clickPayWithEmailPackage(){
        payWithEmailPackage = true;
        payWithExactAmount = false;
        payWithRatePlan = false;
    }
    
    public void clickPayWithExactAmount(){
        payWithExactAmount = true;
        payWithEmailPackage = false;
        payWithRatePlan = false;
    }
    
    public void clickPayWithRatePlan(){
        payWithRatePlan = true;
        payWithExactAmount = false;
        payWithEmailPackage = false;
    }
    
    
    
    // ========================================================================
    // getters for the displayed values on the left
    public String newBalanceLabel{ 
        get{
            String balanceLabel = (Integer.valueOf(ebcCampaign.Number_of_Recipients__c) <= Integer.valueOf(billingAccount.eBroadcast_Email_Balance__c))
                                ? 'New Balance' : 'Balance Owing';
            return balanceLabel;
        }
    }
    
    // number of the email balance after this email is executed, based on current available balance,
    // excluding the new to bepurchased email block package
    public Integer newEmailBalance {
        get{
            return (Integer.valueOf(billingAccount.eBroadcast_Email_Balance__c) - Integer.valueOf(ebcCampaign.Number_of_Recipients__c));
        }
    }
    
    // New Email Balance / Balance Owing line should show positive number
    public Integer absoluteNewEmailBalance {
        get{
            return (Math.abs(newEmailBalance));
        }
    }
    
    
    // ========================================================================
    // Payment Confirmation Item flags
    // message only: select or no payment
    public Boolean showPaymentItemMessage{
        get{
            return ( !payWithExactAmount && acctEmailBlock.selectedProductRatePlan == null && acctRatePlan.selectedProductRatePlan == null);
        }
    }
    // pay with email block or exactamount
    public Boolean showPaymentItemEmailCredit{
        get{
            return (payWithExactAmount || (payWithEmailPackage && acctEmailBlock.selectedProductRatePlan != null ));
        }
    }
    // payment with rateplan selected
    public Boolean showPaymentItemRatePlan{
        get{
            return (payWithRatePlan && acctRatePlan.selectedProductRatePlan != null);
        }
    }
    
    // ======================================================================================== 
    // payment confirmation displayed values    
    public Integer emailCreditPurchased{
        get{
            Integer emails =  0;
            if (payWithExactAmount) {
                emails = Math.max(0,acctEmailBlock.minimumEmailBlockPurchaseSize);
            } else if ( payWithEmailPackage ) {
                emails = acctEmailBlock.selectedProductRatePlanWrapper.currentEmailCredits;
            } else if (payWithRatePlan && acctRatePlan.selectedProductRatePlan != null) {
                Integer prepaidEmail = (acctRatePlan.selectedProductRatePlan.EBC_Prepaid_Emails__c==null) ? 0 : Integer.valueOf(acctRatePlan.selectedProductRatePlan.EBC_Prepaid_Emails__c);
                emails = Math.max(0, -(prepaidEmail + newEmailBalance));
            }
            return emails;
        }
    } // end of emailCreditPurchased getter
        
    public Decimal emailUnitCost{
        get{
            Decimal x = ( payWithEmailPackage && acctEmailBlock.selectedProductRatePlan != null ) 
                            ? acctEmailBlock.selectedProductRatePlan.EBC_Currency_Cost_Per_Email__c 
                            : ( (payWithRatePlan && acctRatePlan.selectedProductRatePlanWrapper != null ) 
                                ? acctRatePlan.selectedProductRatePlanWrapper.productRatePlan.EBC_Currency_Cost_Per_Email__c
                                : productRatePlan.EBC_Currency_Cost_Per_Email__c );
            return x;
        }
    } // emailUnitCost getter
    
    
    public String paymentItemDescription {
        get {
            String str = '';
            if ( newEmailBalance>=0 && acctEmailBlock.selectedProductRatePlanWrapper==null && acctRatePlan.selectedProductRatePlan == null)
            {
                str ='No need to purchase more email';
            } else if (payWithEmailPackage && acctEmailBlock.selectedProductRatePlanWrapper == null) {
                str = 'Please make selection';
            } else if (payWithRatePlan && acctRatePlan.selectedProductRatePlanWrapper == null) {
                str = 'Please select a rate plan';
            }
            return str;
        }
    } // paymentItemDescription getter, used for no selection
    
    
    public Decimal paymentItemAmount {
        get {
            Decimal amt = 0;
            if (payWithExactAmount) {
                amt = emailCreditPurchased * productRatePlan.EBC_Currency_Cost_Per_Email__c;
            } else if (payWithEmailPackage && acctEmailBlock.selectedProductRatePlanWrapper != null) {
                amt = acctEmailBlock.selectedProductRatePlanWrapper.amount;
            } else if (payWithRatePlan && acctRatePlan.selectedProductRatePlanWrapper != null) {
                amt = acctRatePlan.selectedProductRatePlanWrapper.amount;
            } 
            return amt;
        }
    } // paymentItemAmount getter
    
    
    // note totalPurchaseAmount is based on vfIECEBC_Controller.totalNewPurchaseAmount
    // or the pay selected amount
    public Decimal totalPurchaseAmount {
        get{
            Decimal total = 0;
            if (payWithExactAmount) {
                total = productRatePlan.EBC_Currency_Cost_Per_Email__c * emailCreditPurchased;
            } else if (payWithEmailPackage) {
                total = acctEmailBlock.totalNewPurchaseAmount;
            } else if (payWithRatePlan){
                total = acctRatePlan.totalNewPurchaseAmount;
            }
            return total;
        }
    } // totalPurchaseAmount getter
    
    
    // ========================================================================
    // the url along with the parameter for the payment
    // please note that the detail on the product rate plan charge will be recalculated and reselected
    // this ensure the data integrity and simplify the caller
    public PageReference goToPaymentPage()
    {   String id = ApexPages.currentPage().getParameters().get('id');
        ebcCampaignId = id;
        system.debug('goToPaymentPage ebcCampaignId :: ' + ebcCampaignId);

        String campaignPaymentOption = payWithExactAmount ? EBC_PAYMENT_CAMPAIGN_EXACT 
                                    : ( payWithEmailPackage ? EBC_PAYMENT_CAMPAIGN_EMAIL_PACKAGE  
                                        : ( payWithRatePlan ? EBC_PAYMENT_CAMPAIGN_RATE_PLAN : null )
                                    );
        Id paidProductRatePlanId = (payWithExactAmount) ? productRatePlan.Id
                                    : (payWithEmailPackage ? acctEmailBlock.selectedProductRatePlanWrapper.productRatePlan.Id
                                        : (payWithRatePlan ? acctRatePlan.selectedProductRatePlanWrapper.productRatePlan.Id : null));
            
        
        PageReference paymentPage = goToPaymentPageBase( Page.IECEBC_CampaignPayment, EBC_PAYMENT_TARGET_CAMPAIGN, campaignPaymentOption
                            , null // subscription.Id
                            , paidProductRatePlanId // productRatePlanId
                            , ebcCampaignId // campaignId
                            , emailCreditPurchased // emailCreditAmount
                            );
        system.debug('paymentPage :: ' + paymentPage);
        return paymentPage;
    }
    
    public class NotEnoughCredits_Exception extends Exception{}
    
    public PageReference debitCredits() {
        rereadBillingAccount();
        
        if (newEmailBalance < 0) throw new NotEnoughCredits_Exception('Not Enough Credits');
        EBC_Activity__c a = new EBC_Activity__c();
        a.Activity_Date_Time__c = Datetime.now();
        a.Activity_Type__c = 'Send';
        a.EBC_Campaign__c = ebcCampaign.Id;
        a.New_Balance__c = newEmailBalance;
        a.Related_Billing_Account__c = billingAccount.Id;
        a.Total_Count__c = -1 * Integer.valueOf(ebcCampaign.Number_of_Recipients__c);
        a.Name = 'Campaign Send';
        
        insert a;
        
        submitForApproval();
        
        PageReference pr = new PageReference('/IECEBC_Dashboard');
        pr.setRedirect(true);
        return pr;
    }
    
    
    private void submitForApproval() {
        EBC_Campaign__c c = new EBC_Campaign__c();
        c.Id = ebcCampaign.Id;
        c.Notification_Email__c = vfIECEBC.pref.PrimaryContact_Email__c;
        update c;
        
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        //req1.setComments('Submitting request for approval.');
        req1.setObjectId(ebcCampaign.Id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId());
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('EBC_Campaign_Approval');
        if (Test.isRunningTest()) {
            req1.setSkipEntryCriteria(true);
        }
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        // Verify the result
        System.assert(result.isSuccess());
    }
    
    
}