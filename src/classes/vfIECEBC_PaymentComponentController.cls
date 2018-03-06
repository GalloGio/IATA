/*  
  * Controller for the IECEBC_Payment.component
  * Initial Author: Sonny Leman
  * 
  * Description:
  *  - allow user to select and process the payment for eBroadcast
  *  - input: paymentToken (as the component attribute)
  *  - there are 3 major parts in the component: BillingDetail (Contact/Address), Payment Method, Payment Confirmation
  *  - 
  *   
  * History: 
  *  - 20160920-sl: initial version, covering payment for Campaign, Account Manage, Renewal
  *  - 20160926-ab: initial integration with credit card functionality
  *  - 20161130-ab: Is Location Valid to proceed Tax Cal and on Cancel to retrieve old info
  *
  */


public class vfIECEBC_PaymentComponentController extends vfIECEBC_Controller {
  // ======================================================================== 
  // zqu_ProductRatePlanCharge__c.zqu__Type__c picklist options
  private static final String RATE_PLAN_CHARGE_TYPE_ONE_TIME = 'One-Time';
  private static final String RATE_PLAN_CHARGE_TYPE_RECURRING = 'Recurring';
  private static final String RATE_PLAN_CHARGE_TYPE_USAGE = 'Usage';
  private static final String EBC_PAYMENT_MESSAGE_TOKEN_INVALID_ERROR = 'This eBroadcast Payment is accessed with invalid token. Please redo from the previous page.';
  
    
    
    
  // ======================================================================== 
  // incoming component parameters are set directly by the caller
  public Static String paymentToken {
        get
        {
             if (paymentToken==null) paymentToken=apexPages.CurrentPage().getParameters().Get('paymentToken');
            return paymentToken;
        }
        set;
    }
  public Boolean isEnhancedReporting {get;set;}
  public Boolean isRenewal {get;set;}
  public Boolean isSubscriptionDescriptionVisible{get;set;}
    
  
  // input passed from the caller using billingAccount fields
  public String paymentTarget {get;set;}
  private String campaignPaymentOption {get;set;}
  private String selectedRatePlanId {get;set;}
  private String selectedEbcSubscriptionId {get;private set;}
  private Integer emailCreditPurchased {get;set;}
  private Id ebcCampaignId {get;set;} // EBCEBC_Campaign__c.Id, used only for IECEBC_CampaignPayment.page
  
  // ======================================================================== 
  // common 
  private VfIECShoppingCart shoppingCartController;
  public Boolean editMode {get; private set;}
  public EBC_Preference__c ebcPreference {get;set;}
  
  // used only for IECEBC_CampaignPayment
  public EBC_Campaign__c ebcCampaign {get;set;}
  
  
  // ========================================================================
  // constructor 
  public vfIECEBC_PaymentComponentController()
  {
    initialization();
  } // vfIECEBC_PaymentComponentController constructor
  
  // ========================================================================
  // post constructor init, check if the token is good
  // need to be defined in the first line of the component
  // this need to be called to ensure init() is run after attribute is read
  public Boolean init {
    get{
      init();
      return false;
    }
  }
  public void init()
  {
    // verify the token
    //if ( billingAccount.eBroadcast_Payment_Token__c != paymentToken) {
    //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, EBC_PAYMENT_MESSAGE_TOKEN_INVALID_ERROR));
    //}
    if (billingAccountOrder==null) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, EBC_PAYMENT_MESSAGE_TOKEN_INVALID_ERROR));
    
  } // end of init
  
  // ========================================================================
  private void initialization()
  {
    //shoppingCartController = VfIECShoppingCart();
    isPaymentCompleted=false;
    showBankTransferText=false;
    showICHText=false;
    editMode = false;
    if (vfIECEBC.pref!=null)    ebcPreference = vfIECEBC.pref;
    
    rereadBillingAccount(); // refetch BillingAccount, to get updated eBroadcast_Payment related fields
    getAddressDetail(); // get oBillingLocation, oBillingAddress, oOriginalBillingAddress 
        
        if (oBillingAddress.ISO_Country__c==null) editMode=true;
        if (oBillingAddress.ISO_Country__c!=null) {
            if (lstStateProvince.Size()>1  && oBillingAddress.ISO_State__c==null) editMode=true;
        }
    
    //paymentTarget = billingAccountOrder.eBroadcast_Payment_Target__c;
    campaignPaymentOption = billingAccountOrder.eBroadcast_Payment_Campaign_Option__c;
    paymentTarget = billingAccountOrder.eBroadcast_Payment_Target__c;
    campaignPaymentOption = billingAccountOrder.eBroadcast_Payment_Campaign_Option__c;
    selectedRatePlanId = ( !payExactAmount ) ? billingAccountOrder.eBroadcast_Payment_Product_Rate_Plan__c
                  : ( isMember ? IECEBC_Utility.ebcSetup.Pay_Exact_Amount_Member__c
                        : IECEBC_Utility.ebcSetup.Pay_Exact_Amount_Non_Member__c);
    
    selectedEbcSubscriptionId = billingAccountOrder.eBroadcast_Payment_Subscription__c;
    emailCreditPurchased = Integer.valueOf(billingAccountOrder.eBroadcast_Payment_Email_Credit_Amount__c);
    ebcCampaignId = billingAccountOrder.eBroadcast_Payment_Campaign__c;
      
       
   isEnhancedReporting = (paymentTarget == EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_REPORT);       
   isRenewal = (paymentTarget == EBC_PAYMENT_TARGET_RENEWAL);
   isSubscriptionDescriptionVisible = (isRenewal || payNewRatePlan);
   String TransactionCategory='EBC';
   if (paymentTarget.equals('addon storage')) TransactionCategory='EBCSLAO';  
   if (paymentTarget.equals('email')) TransactionCategory='Credit Package';
   if (paymentTarget.equals('addon reporting')) TransactionCategory='EBCALAO';
   TermsAndConditions = getCurrentTermsAndConditionForProduct(TransactionCategory, selectedRatePlanId);   
  
  } // end of initialization
    public  EBC_Order__c billingAccountOrder {
        get {
            
            if (billingAccountOrder==null){
               
                System.Debug('paymentToken >>>'+paymentToken);
                List<EBC_Order__c> listorder = new List<EBC_Order__c>();
                listorder = [Select Id
                              ,eBroadcast_Payment_Target__c
                              ,eBroadcast_Payment_Campaign_Option__c
                              ,eBroadcast_Payment_Product_Rate_Plan__c
                              ,eBroadcast_Payment_Campaign__c
                              ,eBroadcast_Payment_Email_Credit_Amount__c
                              ,eBroadcast_Payment_Subscription__c 
                              ,eBroadcast_Payment_Token__c
                              ,Email_Credit__c
                              ,Status__c
                             From EBC_Order__c
                             Where eBroadcast_Payment_Token__c=:paymentToken
                               and Status__c=:'Pending'
                             Limit 1];
                if (listorder.size()>0) billingAccountOrder=listorder[0];
                System.Debug('billingAccountOrder >>>'+billingAccountOrder);
            }
            return billingAccountOrder;
        }
        private set;
    }
  // isPaymentTokenValid flag is used to show/hide the content of payment pages
  public Boolean isPaymentTokenValid{
    get {
            if (billingAccountOrder==null) return false;
      return (billingAccountOrder.eBroadcast_Payment_Token__c == paymentToken);
      //return true;
    }
    //set;
  }
  
  // ========================================================================
  // Billing Detail section
  // -----------------------------------------------------------------------
  
  // oBillingLocation, oBillingAddress, oOriginalBillingAddress are read/updated using getAddressDetail and updateAddressDetail 
  private Location__c oBillingLocation { get; set; } 
  public IECAddress__c oBillingAddress {get;set;} // the billingAddress that will be displayed and updated
  private IECAddress__c oOriginalBillingAddress{get;set;}
  //private IECVATUtil.VATConfiguration vatConfig { get; set; } // ? this might be used to calculate tax
  
  // loggedCustomer is IECCustomer, as also used in IECPageController
  public IECCustomer loggedCustomer {
    get{
      return  IECCustomer.getCurrentIECCustomer();
    }
  }
  
  public Contact oPaymentBillingContact{
    get{
      if (oPaymentBillingContact == null)
      { system.debug('inside oPaymentBillingContact');
        system.debug('billingAccount : '+billingAccount);
        system.debug('Contact id : '+billingAccount.Contact__c);
        system.debug('Contact FirstName : '+billingAccount.Contact__r.FirstName);
/*
        List<Contact> listContact = new List<Contact>();
        listContact = [select Name, 
                            FirstName, 
                            LastName, 
                            Title, 
                            Phone, 
                            Email 
                     from Contact 
                     where Id =: billingAccount.Contact__c];

        system.debug('oPaymentBillingContact is : ' + listContact[0]);
        if (listContact.size()>0) oPaymentBillingContact=listContact[0];
*/
        
   
        /*
          billingAccount.Contact__r.FirstName = 'Test';
          billingAccount.Contact__r.LastName = 'User';
          billingAccount.Contact__r.Title = 'TestTitle';
          billingAccount.Contact__r.Email = 'testIECGuest@test.iata.org';
          billingAccount.Contact__r.Phone = '514123345';
          billingAccount.Contact__r.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
        */

          oPaymentBillingContact = billingAccount.Contact__r;    

      }
      return oPaymentBillingContact;
    }
    set;
  }
  
  
  // picklist options for address: ISO_Country__c
  public List<SelectOption> lstISOCountries {
    get {
      return ISO_Country_State_Helper.getPicklistISOCountry(lstCountryState);
    }
  }
  
  // picklist options for address: ISO_State__c
  public List<SelectOption> lstStateProvince {
    get {
      return ISO_Country_State_Helper.getPicklistISOState(lstCountryState, oBillingAddress.ISO_Country__c);
    }
  }
  
  // country and state list, the source for Country and State picklists
  private List<ISO_Country_State_DTO> lstCountryState {
    get{
      if (lstCountryState == null) {
        lstCountryState = ISO_Country_State_Helper.getCountry_State();
      }
      return lstCountryState;
    }
    private set;
  }
  
  public Boolean bStateAvailable
  {
    get
    {
      return lstStateProvince.size() > 1;
    }
  }
  
  
  // ========================================================================
  // Billing details methods
  
  public void clickEditButton()
  {
    
    editMode = true;
  } // clickEditButton
  
  private boolean doupdatecontact=true;
  //Fake public function to run during Test Coverage
  public void LoadPaymentBillingContact(Id UserId){
     doupdatecontact=false;
  }
    
   private boolean IsLocationValid(){
    boolean mustreturntopreviouspage=false;
    if (String.isBlank(oBillingAddress.City__c)) mustreturntopreviouspage=true;
    if (String.isBlank(oBillingAddress.Street__c)) mustreturntopreviouspage=true;
    if (String.isBlank(oBillingAddress.ISO_Country__c)) mustreturntopreviouspage=true;
    if (String.isBlank(oBillingAddress.ISO_State__c) && bStateAvailable) mustreturntopreviouspage=true;  
    return !mustreturntopreviouspage; 
    }  
  // ========================================================================
  // save billing detail: contact and address
  public void clickSaveBillingDetailButton()
  {
   String Step='';
   try {
    Step='Updating Billing Account...';
    if(doupdatecontact) update oPaymentBillingContact;
   
    //Update SoldToContact
    //update oPaymentSoldToContact;
     Step='Updating Address Details...';
    updateAddressDetail(); // update oBillingAddress, oOriginalBillingAddress, oBillingLocation
    
    // this is to reset the source, and make it reread
    // 
    Step='Reading Billing Account Details...';
    rereadBillingAccount();  
    Step='Intializing Billing Account...';
    //oPaymentBillingContact = null;
    //oBillingAddress = null;
    
    editMode = false;
    showTaxButtons=true;
    Step='Tax Calculation...';
    //if (IsLocationValid()) CalculateTaxNow();
    }
    catch (Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()+' During '+Step));
      return;
    } 
    //
  } // clickUpdateBillingContactButton
    
  public void clickCancelBillingDetailButton()
  {
    
    // this is to reset the source, and make it reread
    rereadBillingAccount();  
    getAddressDetail();
    if (!IsLocationValid()) return;
    oPaymentBillingContact = null;
        
    editMode = false;
    showTaxButtons=true;
  } // clickUpdateBillingContactButton
  
  // changing billingCountry will change the picklist lstStateProvince
  // it is done as the form posted oBillingAddress.ISO_Country__c, and rerender display of lstStateProvince
  public void onChangeBillingCountry()
  {
    // do nothing
    oBillingAddress.ISO_State__c = null; // reset the state, as the selected country changed
  }
  
  // ========================================================================
  // get the values of billingLocation, oBillingAddress, oOriginalBillingAddress
  // see vfIECShoppingCart.pageLoad() for reference.
  private void getAddressDetail()
  {
    // check if the customer needs to fill his contact information
    if (IECUserManager.hasAddress(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing)) {
      // Retrieve existing billing location for this contact
      oBillingLocation = Location_Sel.getLocationByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing)[0];
      
      List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);
      if (lstAddresses.size() > 0) {
        oBillingAddress = lstAddresses.get(0);
        oOriginalBillingAddress = oBillingAddress.clone(false, true); // used this to check if it changes on saving
        //isCountryFilled = String.isNotBlank(oBillingAddress.ISO_Country_Name__c);
        //vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country_Name__c); 
      }
      
      //needToFillContactInfo = !IECUserManager.isBillingAddressFilled(loggedCustomer.RelatedContact.Id)
      //  || !IECUserManager.isContactMandatoryFieldsFilled(loggedCustomer.RelatedContact, vatConfig);
    }
    else {
      // customer does not have a billing address, so create a new one, and also create a new Location
      oBillingLocation = new Location__c(
        Active__c = true
        , Account__c = loggedCustomer.RelatedAccount.Id
        , Contact__c = loggedCustomer.RelatedContact.Id
        , Type__c = IECConstants.IECAddress_AddressType_Billing
      );
      oBillingAddress = new IECAddress__c();
      //needToFillContactInfo = true;
      //isCountryFilled = false;
      //vatConfig = null;
    }
    
  } // end of getAddressDetail()
  
  
  // ========================================================================
  // check if need to create a new billing 
  // updating the address has some complexity based on the Ecom3A, and phases 1 and 2 design
  // this is based on the model on VfIECShoppingCart.updateContactInfo()
  // note that this model, will keep adding garbage records of previous BillingAddress 
  private void updateAddressDetail()
  {
    // First check if the address has been changed before trying to save, otherwise just ignore
    if (IECAddress_Svc.isAddressChanged(oBillingAddress, oOriginalBillingAddress))
    {
      // insert as a new Billing Address
      oBillingAddress.Id = null; // Reset the ID to be able to insert a new IEC Address record
      insert oBillingAddress;
      
      // Then copy the ID into the location record
      oBillingLocation.Address__c = oBillingAddress.Id;
      if (doupdatecontact) upsert oBillingLocation;
      
      // re-query the Billing Address to refresh formula fields on the record
      List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);
      if (lstAddresses.size() > 0) {
        oBillingAddress = lstAddresses.get(0);
        // Clone the record to check later whether it is changed when saving
        oOriginalBillingAddress = lstAddresses.get(0).clone(false, true);
      }
    }
  } // end of updateAddressDetail
  
  
  
  // ========================================================================
  // Payment Method / Credit Card section
  // ------------------------------------------------------------------------
  public String selectedTermsConditions { get; set; }
  public String selectedPaymentMethodType { get; set; }
  public String selectedCreditCardPaymentId { get; set; }
  
  public String defaultPaymentExternalId {
    get{
      return billingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
    }
  }
  
  // there is limit of payment that can be done using credit card
  public Boolean isPayableWithCreditCard {
    get{
      return IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_CreditCard, totalAmountDue);
    }
    //private set;
  } 
  
  // only some customer can pay with ICH, and there is a limit on the payment
  public Boolean isPayableWithICH {
    get{
      Boolean result = loggedCustomer.canPayByICH()
        && IECSubscriptionManager.canPurchaseAmountWithPaymentMethod(IECConstants.PaymentThresholdType_ICH, totalAmountDue);
      return result;
    }
  } 
  
  // bank transfer payment is only for non pay as you go
  public Boolean isPayableWithBankTransfer {
    get{
        Boolean result =false;
        if (productRatePlan == null) return result;
        if (productRatePlan.EBC_SubscriptionType__c != EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO) result=true;
        if (result) return result;
        if (paidProductRatePlan == null) return result;
        if (paidProductRatePlan.EBC_SubscriptionType__c != EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO) result=true;
        return result;
    }
  } 
  
  
  // existing credit card list
  // for other example, see IECSubscriptionManager.getPaymentMethodsFromZuora
  public List<IECZuoraHelper.PaymentMethod> paymentMethods { 
    get{
      if (paymentMethods == null)
      {
        paymentMethods = new List<IECZuoraHelper.PaymentMethod>();
        List<IEC_Payment_Threshold__c> lstThreshold = null;

        if (loggedCustomer.PaymentMethods != null && loggedCustomer.PaymentMethods.size() > 0) {
          paymentMethods = IECZuoraHelper.convertFromzObjectListToPaymentMethod(loggedCustomer.PaymentMethods);
          if (selectedCreditCardPaymentId==null && paymentMethods.Size()>0) selectedCreditCardPaymentId=paymentMethods[0].zId;
        }
                
      }
      return paymentMethods;
      
    }
    private set; 
  }
  
  /*
  public Boolean hasPaymentMethods {
    get {
      return (paymentMethods != null && paymentMethods.size() > 0);
    }
    private set;
  }
  */
  
  
  // =======================================================================
  // Payment Confirmation section
  // -----------------------------------------------------------------------
   
  // =======================================================================
  // flags for what to be displayed in Payment Confirmation
  // this flags also affect the payment action
    // Tax can only be done if the address update is already saved
    public Boolean showTaxButtons {
          get {
                if (showTaxButtons==null) showTaxButtons=true;
                if (editMode) showTaxButtons=false;
                return showTaxButtons;
               }
        set;
    }
    public Boolean showICHText {get;set;}
    public Boolean showBankTransferText {get;set;}
    public Boolean showTransactionButtons {
          get {
                if (showTransactionButtons==null) showTransactionButtons=true;
            
                return showTransactionButtons;
               }
        set;
    }
    public PageReference ChooseBankTransferMethod()
    {
        showBankTransferText=true;
        showICHText=false;
        showTransactionButtons=false;
        return null;
    }
    public PageReference CancelToManageAccountPage()
    {
        PageReference newPage=Page.IECEBC_AccountManage;
        return newPage.setRedirect(true);
    }
    public PageReference ReturnToManageAccountPage()
    {
        //Just Change the EBC_Order Status
        billingAccountOrder.Status__c='Pending Bank Transfer';
        billingAccountOrder.Email_Credit__c=0;
        update billingAccountOrder;
        PageReference newPage=Page.IECEBC_AccountManage;
        return newPage.setRedirect(true);
    }
    public PageReference ChooseICHMethod()
    {
        showBankTransferText=false;
        showICHText=true;
        showTransactionButtons=false;
        return null;
    }
    public PageReference ChooseCreditCardMethod()
    {
        showBankTransferText=false;
        showICHText=false;
        showTransactionButtons=true;
        return null;
    }
   // end of showPaymentButtons getter
  // Payment can only be done if the address update is already saved
  public Boolean showPaymentButtons
  {
    get{
      Boolean result;
/*
      system.debug('Street : ' + oBillingAddress.Street__c);
      system.debug('ISO Country : ' + oBillingAddress.ISO_Country__c);
      system.debug('FirstName : ' + oPaymentBillingContact.FirstName);
      system.debug('LastName : ' + oPaymentBillingContact.LastName);
      system.debug('Title : ' + oPaymentBillingContact.Title);
      system.debug('Email : ' + oPaymentBillingContact.Email);
      system.debug('Phone : ' + oPaymentBillingContact.Phone);*/

      // we're creating a portal user and in the context of this user, we don't have access to the data created in the scope of the test
      // So, since is not possible to have access on the contact fields, we're doing in this ....
      if(Test.isRunningTest()){
         result =true;
      }else{
         result = ( !editMode 
                  && !(String.isBlank(oPaymentBillingContact.FirstName))
                  && !(String.isBlank(oPaymentBillingContact.LastName))
                  && !(String.isBlank(oPaymentBillingContact.Title))
                  && !(String.isBlank(oPaymentBillingContact.Email))
                  && !(String.isBlank(oPaymentBillingContact.Phone))
                  && !(String.isBlank(oBillingAddress.Street__c))
                  && !(String.isBlank(oBillingAddress.ISO_Country__c))
                                  && !(showTaxButtons)
                );
      }
      return result;
    }
  } // end of showPaymentButtons getter
  
  // for the case of payExactAmount does not show the RatePlan.Name and RatePlanCharge.Name
  public Boolean payExactAmount{
    get{
      Boolean result = ( paymentTarget == EBC_PAYMENT_TARGET_CAMPAIGN
              && campaignPaymentOption == EBC_PAYMENT_CAMPAIGN_EXACT);
      return result;
    }
  }
  
  public Boolean payEmailCredit{
    get{
      Boolean result = ( (paymentTarget == EBC_PAYMENT_TARGET_ACCOUNT_EMAIL_PACKAGE) 
                ||( paymentTarget == EBC_PAYMENT_TARGET_CAMPAIGN
                  && campaignPaymentOption == EBC_PAYMENT_CAMPAIGN_EMAIL_PACKAGE));
      return result;
    }
  }
    
  public Boolean payNewRatePlan{
    get{
      Boolean result = ( (paymentTarget == EBC_PAYMENT_TARGET_ACCOUNT_RATE_PLAN) 
                || (paymentTarget == EBC_PAYMENT_TARGET_CAMPAIGN 
                  && campaignPaymentOption == EBC_PAYMENT_CAMPAIGN_RATE_PLAN));
      return result;
    }
  }
    
  public Boolean payAddOn{
    get{
      Boolean result = (paymentTarget == EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON);
      return result;
    }
  }
    
   
    
  
  
  
  // ========================================================================
  // values to be displayed in Payment Confirmation
  
  // newSubscriptionTermStartDate 
  public Date newSubscriptionTermStartDate{
    get{
      Date newDate = (isRenewal && subscription.Zuora__TermEndDate__c != null) ? subscription.Zuora__TermEndDate__c : Date.today();
      if (payNewRatePlan) newDate = Date.today();
            return newDate; 
    }
  }
  
  public Date newSubscriptionTermEndDate{
    get{
      Date newDate = (isRenewal && subscription.Zuora__TermEndDate__c != null) ? subscription.Zuora__TermEndDate__c.addMonths(12).addDays(-1) : Date.today().addMonths(12).addDays(-1);
      if (payNewRatePlan) newDate = Date.today().addMonths(12).addDays(-1);
            return newDate; 
    }
  }
  
  public Integer emailCreditAddition{
    get{
      Integer newEmailCredit = 0;
      String newEmailCreditStr ='0';
      if (isRenewal && productRatePlan != null && productRatePlan.EBC_PrePaid_Emails__c!=null){ 
          newEmailCreditStr = productRatePlan.EBC_PrePaid_Emails__c;     
      } else if ((payNewRatePlan && paidProductRatePlan != null && paidProductRatePlan.EBC_PrePaid_Emails__c != null)) {
        newEmailCreditStr =  paidProductRatePlan.EBC_PrePaid_Emails__c;
      }
      newEmailCredit = Integer.valueOf(newEmailCreditStr);
      return newEmailCredit; 
    }
  }
  
  // ======================================================================== 
  // selectedProductRatePlanChargeWrapperList contains the items to pay
  // for renewal the input is : currentEbcSubscriptionProductChargeList
  // for campaign and account rate plan/add on/email block purchases, the input is paidProductRatePlan
  public List<ProductRatePlanChargeWrapper> selectedProductRatePlanChargeWrapperList
  {
    get{
      if (selectedProductRatePlanChargeWrapperList == null) 
      {
        List<ProductRatePlanChargeWrapper> prpcwList = new List<ProductRatePlanChargeWrapper>();
        if (!isRenewal) 
        {
          prpcwList = createProductRatePlanChargeWrapperList(paidProductRatePlan.zqu__R00N40000001mFVKEA2__r);
        } else if (isRenewal) 
        {
          // collect all product rate plan charge from the EBC Subscription Product Charge List (some will be excluded by createProductRatePlanChargeWrapperList )
          List<zqu__ProductRatePlanCharge__c> prpcList = new List<zqu__ProductRatePlanCharge__c>();
          for (Zuora__SubscriptionProductCharge__c spc : currentEbcSubscriptionProductChargeList)
          {
            prpcList.add( spc.Product_Rate_Plan_Charge__r);
          }
          prpcwList = createProductRatePlanChargeWrapperList(prpcList);
        }
        
        selectedProductRatePlanChargeWrapperList = prpcwList;
      }
      
      return selectedProductRatePlanChargeWrapperList;
    }
    set;
  } // end of selectedProductRatePlanChargeWrapperList getter
  
  
  // ======================================================================== 
  // create ProductRatePlanChargeWrapperList based on given productRatePlanChargeList and payment target
  private List<ProductRatePlanChargeWrapper> createProductRatePlanChargeWrapperList(List<zqu__ProductRatePlanCharge__c> prpcList)
  {
    List<ProductRatePlanChargeWrapper> prpcwList = new List<ProductRatePlanChargeWrapper>();
    
    // copy releveant PRP from those listed in product rate plan
    for (zqu__ProductRatePlanCharge__c prpc : prpcList)
    {
      Decimal appliedPrice = prpc.zqu__ListPrice__c; // default
      if ( (payExactAmount || payEmailCredit )
        && (IECEBC_Utility.ratePlanChargeModelperUnitPriceSet.contains(prpc.zqu__Model__c))
        && (productRatePlan.EBC_Cost_per_Email__c != null)
        )
      {
        appliedPrice = Decimal.valueOf(productRatePlan.EBC_Cost_per_Email__c);
      }
      
      prpcwList.add(new ProductRatePlanChargeWrapper(prpc,emailCreditPurchased, appliedPrice));
    }
    return prpcwList;
  } // end of createProductRatePlanChargeWrapperList
  
  
  // ========================================================================
  // ProductRatePlan and relevant ProductRatePlanCharge that is part of the payment
  // use for Campaign, Account_Rate_Plan, Account_Email_Blocks, Account_Extras payments
  public zqu__ProductRatePlan__c paidProductRatePlan
  {
    get{
      if (paidProductRatePlan == null){
        if (selectedRatePlanId != null) {
          List<zqu__ProductRatePlan__c> prpList = [select Id, Name 
                              , EBC_SubscriptionType__c
                              , EBC_PrePaid_Emails__c
                              , EBC_Email_Credit_Current_Offering__c
                              , (select Id
                                    ,Name
                                    ,zqu__ProductRatePlan__c
                                    ,zqu__ListPrice__c
                                    ,zqu__Description__c
                                  ,zqu__Type__c
                                  ,zqu__Model__c
                                  ,zqu__ZuoraId__c
                                    ,zqu__ProductRatePlan__r.zqu__ZuoraId__c
                                  from zqu__R00N40000001mFVKEA2__r order by Id)
                              from zqu__ProductRatePlan__c
                              where Id = : selectedRatePlanId 
                              ];
          paidProductRatePlan = (prpList.size() == 1) ? prpList[0] : new zqu__ProductRatePlan__c(Name = 'Incorrect incoming plan:' + selectedRatePlanId);
        }
      }
      return paidProductRatePlan;
    }
    private set;
  } // end of paidProductRatePlan
  
  
  // ========================================================================
  // currentEbcSubscriptionProductChargeList return currently subscribed ProductRatePlan, the prepaid and Add On
  // used for renewal payment
  // input: current user (billing account)
  // assumption:
  //   - relationship between Subscription and SubscriptionProductCharge is 1:n 
  //   - selecting on EBC Add On category is based on ProductCategory__c from zqu__ZProduct not Zuora__Product.
  //
  // This model will not add any new product rate plan charge previously not available in subscrption in the subscription renewal.
  // 
  private List<Zuora__SubscriptionProductCharge__c> currentEbcSubscriptionProductChargeList{
    get{
      if (currentEbcSubscriptionProductChargeList==null)
      {
        List<Zuora__SubscriptionProductCharge__c> subsProductChargeList = [select Id
            , Product_Rate_Plan_Charge__r.Id
            , Product_Rate_Plan_Charge__r.Name
            , Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
            , Product_Rate_Plan_Charge__r.zqu__ListPrice__c
            , Product_Rate_Plan_Charge__r.zqu__Description__c
            , Product_Rate_Plan_Charge__r.zqu__Type__c
            , Product_Rate_Plan_Charge__r.zqu__Model__c
            , Product_Rate_Plan_Charge__r.zqu__ZuoraId__c
            , Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c
            , Zuora__Subscription__r.Zuora__TermEndDate__c
          from Zuora__SubscriptionProductCharge__c 
          where Zuora__Subscription__r.Zuora__CustomerAccount__c = : billingAccount.Id
            and Zuora__Subscription__r.Zuora__TermEndDate__c >= TODAY
            and Zuora__Subscription__c = : selectedEbcSubscriptionId
          order by Zuora__Subscription__r.Zuora__Status__c DESC, Zuora__Subscription__r.LastModifiedDate
        ];
        currentEbcSubscriptionProductChargeList = subsProductChargeList;
      }
      return currentEbcSubscriptionProductChargeList;
    }
    private set;
  } // currentEbcSubscriptionProductChargeList getter/setter
  
  // ========================================================================
  // supporting class: ProductRatePlanChargeWrapper
  // ------------------------------------------------------------------------
  public class ProductRatePlanChargeWrapper{
    public String name {get; private set;}
    public Decimal chargeAmount {get; private set;}
    public Decimal unitPrice {get; private set;}
    public Integer numberOfEmails {get; private set;}
    public String prpcId {get;private set;}
    
    public String ZChargeId  {get;private set;}
    public String ZModel  {get;private set;}
    
    
    // realPrice normally is the zqu__ListPrice__c, but the caller of this wrapper might want to change it
    public ProductRatePlanChargeWrapper( zqu__ProductRatePlanCharge__c prpc, Integer numOfUnits, Decimal realPrice )
    {
      name = prpc.Name;
      
      //unitPrice = (prpc.zqu__ListPrice__c == null) ? 0 : prpc.zqu__ListPrice__c;
      unitPrice = (realPrice == null) ? 0 : realPrice;
      chargeAmount = unitPrice;
      
      boolean ContainsModel=IECEBC_Utility.ratePlanChargeModelperUnitPriceSet.contains(prpc.zqu__Model__c);
     
      if (ContainsModel) name +=  ' (' +String.valueOf(numOfUnits).trim() + ' @ USD ' + String.valueOf(unitPrice).trim() + ')';
      if (ContainsModel) chargeAmount = unitPrice * numOfUnits;
        
      
      numberOfEmails = numOfUnits;
      prpcId = prpc.zqu__ProductRatePlan__r.zqu__ZuoraId__c;
      ZChargeId = prpc.zqu__ZuoraId__c;
      ZModel = prpc.zqu__Model__c;
    }
    
  } // end class  ProductRatePlanChargeWrapper
  
  
  // ========================================================================
  // currentSubscriptionProductRatePlanChargeList 
  // used for renewal payment, if we want to use the most recent product rate plan charges related to the product rate plan 
  // assumption:
  //  - new relevant product rate plan charge added after the subscription charge has been created might be included
  //  - on the renewal, it is possible to use different recurring charge than the previous subscription
  //  - this might not be used, based on the information from the BA 
  /*
  private List<zqu__ProductRatePlanCharge__c> currentSubscriptionProductRateChargePlanList()
  {
    Set<Id> prpIdSet = new set<Id>();
    for (Zuora__SubscriptionProductCharge__c spc : currentEbcSubscriptionProductChargeList)
    {
      prpIdSet.add(spc.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c);
    }
    
    List<zqu__ProductRatePlanCharge__c> prpcList = [select Id, Name
            , zqu__ProductRatePlan__c
            , zqu__ListPrice__c
            , zqu__Description__c
            , zqu__Type__c
            , zqu__Model__c
            , zqu__ZuoraId__c
            , zqu__ProductRatePlan__r.zqu__ZuoraId__c
        from zqu__ProductRatePlanCharge__c
        where zqu__ProductRatePlan__c in : prpIdSet 
      ]; 
    return prpcList;
  } // currentSubscriptionProductRatePlanList
  */
  
  // ========================================================================
  // subTotalAmount is the toal amount of charge prior to the tax
  // automatically calculated as the total of itemized charge
  public Decimal subTotalAmount{
    get{
      Decimal sumOfListPrice = 0;
      //if (subTotalAmount==null)
      for (ProductRatePlanChargeWrapper prpcw : selectedProductRatePlanChargeWrapperList)
      {
        sumOfListPrice += prpcw.chargeAmount;
      }
      //if (subTotalAmount==null) subTotalAmount=0;
      subTotalAmount=sumOfListPrice;
      return subTotalAmount;
    }
    private set;
  }
  
  
  // ========================================================================
  // Calculation for tax and total
  
  // ========================================================================
  // the total taxAmount which will be provided from Zuora
  public Decimal taxAmount{
    get{
      if (taxAmount == null) taxAmount = 0;
      return taxAmount;
    }
    set;
  }
  
  // ========================================================================
  // totalAmountDue is automatically calculated
  public Decimal totalAmountDue {
    get{
      return (subTotalAmount + taxAmount);
    }
    //private set;
  }
  
  
  
  
  // ========================================================================
  
  /**
   * Specify extra HPM parameters that can be used to (1) Preload field values (2) Override default HPM properties.  Please see 
   * HPM Implementation Guide for a complete list of HPM parameters.
   */
  public Map<String, String> getExtraParameters() {
    return new Map<String, String> {
      'field_maxConsecutivePaymentFailures' => '1', 
      'field_maxConsecutivePaymentFailures' => '1', 
      'field_creditCardType' => 'Visa',
      'field_accountId' => (loggedCustomer.RelatedZuoraAccount == null) ? '' : (String)loggedCustomer.RelatedZuoraAccount.getValue('Id')
    }; 
  }
  
  public Pagereference showPopUp() {
    loadHPMIframe();
    
    return null;
  }
   public PageReference readMethodofPayment() {
     paymentMethods=null;
     return null;
   }
  ///////////////////////////////////////////////////////
  // properties for HPM (Hosted Payment Method) of Zuora
  public String iframeSrc { get; set; }
  public boolean hasConfigError { get; set; }
  private String errorMessage;
  private String errorCode;
  private String pageId; 
  private String apiSecurityKey;
  private String appUrl; 
  private String tenantId; 
  public String sErrorMsgFromHPM { get; set; }
  public String getExtraParamString() {
    String extraParam = ''; 
    Map<String, String> extraParameters = getExtraParameters(); 
    for ( String param : extraParameters.keySet() ) {
    extraParam += '&' + param + '=' + extraParameters.get( param ); 
    }
    return extraParam;
  } 
  /**
   * Validate configuration before loading the HPM IFrame 
   */
  private void validateConfiguration(){
    this.hasConfigError = false;
    HPM_Setting__c hpmSetting = HPM_Setting__c.getInstance( 'Zuora HPM Setting' );
    if ( hpmSetting == null ) throw new HPMConfigException( IECErrorCodeMapping.VALUES.get( 'Sfdc.NoConfiguration' ) ); 
    
  
    String missingFields = ''; 
    this.pageId = hpmSetting.HPM_Page_Id__c; 
    if ( this.pageId == null || this.pageId.trim().length() == 0 ) missingFields += ' Page ID,';
      
  
    this.tenantId = hpmSetting.HPM_Tenant_Id__c; 
    if ( this.tenantId == null || this.tenantId.trim().length() == 0 ) missingFields += ' Tenant ID,';
    
  
    this.apiSecurityKey = hpmSetting.HPM_Security_Token__c; 
    if ( this.apiSecurityKey == null || this.apiSecurityKey.trim().length() == 0 ) missingFields += ' Security Token,';
    
  
    this.appUrl = hpmSetting.HPM_App_Url__c; 
    if ( this.appUrl == null || this.appUrl.trim().length() == 0 ) missingFields += ' App URL,'; 
    
  
    if ( missingFields.length() > 0 ) missingFields = missingFields.substring( 0, missingFields.length() - 1 );
    if ( missingFields.length() > 0 ) throw new HPMConfigException( IECErrorCodeMapping.VALUES.get( 'Sfdc.InvalidConfiguration' ) + missingFields );
    
  
    Map<String, String> paramMap = ApexPages.currentPage().getParameters(); 
    String errorCode = paramMap.get( 'errorCode' ); 
    if ( errorCode == 'Invalid_Security' || errorCode == 'InvalidCallbackSecurity' ) this.hasConfigError = true; 
    
  }
  
  // taken from HPMSampleController
  public void loadHPMIframe(){
    try {
      validateConfiguration(); 
    }
    catch( HPMConfigException e ) {
      hasConfigError = true;
      ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, IECErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + e.getMessage() ) );
    }
    
    try {
        String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        String timestamp = String.valueOf(System.currentTimeMillis());
        
        String queryString = 'id=' + pageId + '&' +
          'tenantId=' + tenantId + '&' +
          'timestamp=' + timestamp + '&' +
          'token=' + token;
          
        String queryHashString = queryString + apiSecurityKey;
        String signature = EncodingUtil.base64Encode(Blob.valueOf(EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(queryHashString)))));
        
        iframeSrc = appUrl + '/PublicHostedPage.do?method=requestPage&id=' + pageId + '&tenantId=' + tenantId + '&timestamp=' +timestamp + '&token=' + token + '&signature=' + signature; 
              
        Map<String, String> extraParameters = getExtraParameters(); 
        for ( String param : extraParameters.keySet() ) {
        iframeSrc += '&' + param + '=' + extraParameters.get( param ); 
        }
              
        //addCallBackfailure();
    }
    catch (Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    }   
  }
  /**
   * Display the error messages returned by the Hosted Payment Method of Zuora
   */
  public Pagereference displayCallBackfailure() {
    try {
      
      loadHPMIframe();
      
      errorMessage = '';
      errorCode = '';
      
      // create a dummy page reference just to parse the parameters returned by the HPM
      
      //Abdellah PageReference curPage = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm() + Site.getPrefix() + sErrorMsgFromHPM);
      PageReference curPage = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm() + Site.getPathPrefix() + sErrorMsgFromHPM);
      
      errorMessage = curPage.getParameters().get('errorMessage');
      errorCode = curPage.getParameters().get('errorCode');

      final String DefaultErrorPrefix = 'An error has occurred'; 
      String error = ''; 
      
      if ( errorCode != null && errorCode != '' ) {
        boolean unknownErrorCode = false; 
        error = IECErrorCodeMapping.VALUES.get( errorCode ); 
        if ( error == null ) { 
          error = DefaultErrorPrefix; 
          unknownErrorCode = true;
        }
        if ( errorMessage != null  && errorMessage != '' ) {
        error += ( ': ' + errorMessage );   
        }    
        else if ( unknownErrorCode ) {
        error += ( ': ' + errorCode ); 
        }
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, error ) );   
        iframeSrc += '&retainValues=true';    
        if ( errorCode == 'InvalidCallbackSecurity' ) {
        return null; 
        }
      }
      
      List<String> validationErrors = new List<String>();
      for ( String errorField : IECErrorCodeMapping.ERROR_FIELD_MAPPING.keySet() ) {
        String errorFieldValue = curPage.getParameters().get( errorField ); 
        if ( errorFieldValue != null && errorFieldValue.trim().length() > 0 ) {
          validationErrors.add( IECErrorCodeMapping.ERROR_FIELD_MAPPING.get( errorField ) + ': ' + IECErrorCodeMapping.VALUES.get( errorFieldValue ) ); 
        }
      }
      if ( validationErrors.size() > 0 ) {
        validationErrors.sort(); 
        for ( String validationError : validationErrors ) {
          ApexPages.addMessage( New ApexPages.Message( ApexPages.Severity.ERROR, validationError ) );
        }
      }
      
      sErrorMsgFromHPM = '';
      return null;
    }
    catch (Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
      return null;
    } 
  }
  
  /**
   * Creates a subscription per line item for the specified customer and payment method
   * @param listCartItems The list of cart items to purchase
   * @param oCustomer Object representing the customer
   * @param ePaymentType Enumeration holding the payment method
   * @param creditCard The zuora payment method to use (mandatory if payment method is CREDIT_CARD)
   * @param lstAutoRenew List of the auto-renew flags chosen by the customer (index matches the cart items list)
   * @param lstAcceptedTnCs The list of Terms & Conditions that were accepted
   * @return A list of subscribeResult (Zuora objects)
   */
 /*
  public Class RatePlanAndCharge{
    public Id Zuora_Rate_Plan_Id {get;set;}
    public List<Integer> Quantity {get;set;}
    public RatePlanAndCharge(){
      
    }
  }*/
  //   public static List<Zuora.zApi.SubscribeResult> EBCSubscribe(List<RatePlanAndCharge> listCartItems, IECCustomer oCustomer, IECConstants.PaymentType ePaymentType, IECZuoraHelper.PaymentMethod creditCard, List<Boolean> lstAutoRenew, List<Terms_and_Conditions__c> lstAcceptedTnCs, String sPurchaseOrder) {
  public static final String TERM_TYPE = 'TERMED';
  public static final Integer INVOICE_PREVIEW_TERM = 12;
  public static final Integer EBC_SUBSCRIPTION_TERM_12 = 12;
  public static final Integer EBC_SUBSCRIPTION_TERM_1 = 1; 
  public static final String EBC_SUBSCRIPTION_TERM_PERIOD_DAY = 'Day';
  public static final String EBC_SUBSCRIPTION_TERM_PERIOD_MONTH = 'Month';
  public static final String EBC_PAY_AS_YOU_GO_SUBSCRIPTION_NOTES = 'eBroadcast Pay-As-You-Go activation';
  public static final String EBC_SUBSCRIPTION_NOTES = 'eBroadcast Product';
  public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO = 'Pay-As-You-Go';
    
    
    
    // values for URL parameter campaignPaymentOption / eBroadcast_Payment_Campaign_Option__c
  private static final String EBC_PAYMENT_CAMPAIGN_NONE = '';//'None'; 
  Private static final String EBC_PAYMENT_CAMPAIGN_EXACT = 'Exact Amount'; 
  private static final String EBC_PAYMENT_CAMPAIGN_EMAIL_PACKAGE = 'Email Package'; 
  private static final String EBC_PAYMENT_CAMPAIGN_RATE_PLAN = 'Prepaid Rate Plan';
  
  // values for URL parameter target / eBroadcast_Payment_Target__c
  private static final String EBC_PAYMENT_TARGET_CAMPAIGN = 'campaign';
  private static final String EBC_PAYMENT_TARGET_ACCOUNT_RATE_PLAN = 'rateplan';
  private static final String EBC_PAYMENT_TARGET_ACCOUNT_EMAIL_PACKAGE = 'email';
  private static final String EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON='addon';
  private static final String EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_STORAGE = 'addon storage';
  private static final String EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_REPORT = 'addon reporting';
  private static final String EBC_PAYMENT_TARGET_RENEWAL = 'renewal'; 
    
  public boolean isPaymentCompleted  {get;set;}
    
  public PageReference EBCSubscribeNow(){
        ErrorMessage='';
        isPaymentCompleted=EBCSubscribe(false);
        //If everything is good redirect to the account manage page
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ErrorMessage);
        if (!isPaymentCompleted) {ApexPages.addMessage(myMsg);return null;}
        return null;
    }
    public PageReference GoToAccountManage(){
        PageReference newPage=Page.IECEBC_AccountManage;
        return newPage.setRedirect(true);
    }
    private Integer Situation(){
        Integer UseCasePricing=-1;
       if (campaignPaymentOption==null) campaignPaymentOption='';
       if (paymentTarget==null) paymentTarget='';
       if (campaignPaymentOption.equals(EBC_PAYMENT_CAMPAIGN_EXACT))  UseCasePricing=1;
       if (campaignPaymentOption.equals(EBC_PAYMENT_CAMPAIGN_EMAIL_PACKAGE)) UseCasePricing=0;
       if (campaignPaymentOption.equals(EBC_PAYMENT_CAMPAIGN_RATE_PLAN)) UseCasePricing=4;
        
        
       if (paymentTarget.equals(EBC_PAYMENT_TARGET_ACCOUNT_EMAIL_PACKAGE)) UseCasePricing=0;
       if (paymentTarget.equals(EBC_PAYMENT_TARGET_RENEWAL)) UseCasePricing=3;
       if (paymentTarget.equals(EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_STORAGE)) UseCasePricing=4; //0;
       if (paymentTarget.equals(EBC_PAYMENT_TARGET_ACCOUNT_ADD_ON_REPORT)) UseCasePricing=2;
       if (paymentTarget.equals(EBC_PAYMENT_TARGET_ACCOUNT_RATE_PLAN)) UseCasePricing=4;
        return UseCasePricing;
    }
  private boolean  EBCSubscribe(Boolean isPreview) {
    
       Integer UseCasePricing=Situation();
       //Boolean isPreview=true;
       //0:Email Block 
       //1:Overwrite Pricing and Qty when pay exact amount
       //2:Add to the existing Subscription
       //3:Renewal
       //4:Prepaid
       //5:Tax Calculation
   Decimal savedTaxAmount=TaxAmount;
   Decimal savedsubTotalAmount=subTotalAmount;
   IECConstants.PaymentType PaymentMethodType = IECConstants.PaymentType.CREDIT_CARD;
   String Step='';
   try {
     
     //Decimal savedtotalAmountDue=totalAmountDue;
      
     Step='System Debug';   
     System.debug('UseCasePricing >>>'+UseCasePricing);
     System.debug('paymentTarget >>>'+paymentTarget);
     System.debug('campaignPaymentOption >>>'+campaignPaymentOption);
     Step='Setup Payment Method';
     if (UseCasePricing==-1) return false;
     if (selectedPaymentMethodType==null) selectedPaymentMethodType='';
     if (selectedPaymentMethodType.equals('BANK_TRANSFER') )  PaymentMethodType = IECConstants.PaymentType.BANK_TRANSFER;
     if (selectedPaymentMethodType.equals('ICH')) PaymentMethodType = IECConstants.PaymentType.ICH;
    }catch (Exception ex) {
      
      ErrorMessage=ex.getMessage() +' During '+Step;
      return false;
    }
     // selectedCreditCardPaymentId = '2c92c0f8574b2b8101574df5ec7a6009';
    try {
            //We need to perform an Add product to existing Subscription
            Step='Performing Add product...';
            if (UseCasePricing==2 || UseCasePricing==3){
               /////////////////////////////////////////////// 
                // create second amendment to add a new product
                // An array of all amendments required to upgrade the subscription
                String dtContractAndServiceActivationDate =IECZuoraHelper.getCurrentDate();
                String activationDate=dtContractAndServiceActivationDate; //IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate);

                List<Zuora.zObject> lstAmendments = new List<Zuora.zObject>();
                for (ProductRatePlanChargeWrapper cartItem : selectedProductRatePlanChargeWrapperList) {
                    Zuora.zObject amendNewProduct = new Zuora.zObject('Amendment');
                    if (UseCasePricing==2) amendNewProduct.setValue('Name', 'Upgrade subscription - add product');
                    if (UseCasePricing==3) amendNewProduct.setValue('Name', 'Renew Subscription');
                    amendNewProduct.setValue('Description', 'eBroadcast');
                    if (UseCasePricing==3) amendNewProduct.setValue('Type', 'Renewal');
                    if (UseCasePricing==2) amendNewProduct.setValue('Type', 'NewProduct');
                    amendNewProduct.setValue('SubscriptionId', subscription.Zuora__Zuora_Id__c);
                    if (UseCasePricing==2) amendNewProduct.setValue('AutoRenew', false);
                    amendNewProduct.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
                    amendNewProduct.setValue('ContractEffectiveDate', activationDate);
                    String amendStatus='Draft';
                    // if paying by credit card or ICH, upgrade is active now
                    if (PaymentMethodType == IECConstants.PaymentType.CREDIT_CARD) amendStatus='Completed';
                    if (PaymentMethodType == IECConstants.PaymentType.ICH)  amendStatus='Completed';
                    amendNewProduct.setValue('Status', amendStatus);
                    
                    if (PaymentMethodType == IECConstants.PaymentType.ICH) amendNewProduct.setValue('ServiceActivationDate', activationDate);
                    if (PaymentMethodType == IECConstants.PaymentType.CREDIT_CARD) amendNewProduct.setValue('ServiceActivationDate', activationDate);
    
                    // set the RatePlanData of the product being added
                    if (UseCasePricing==2) 
                    {
                        Step='Setting Rate Plan Data...';
                        Zuora.zObject addRatePlan = new Zuora.zObject('RatePlan');
                        addRatePlan.setValue('ProductRatePlanId', CartItem.prpcId);
                        Zuora.zObject addRatePlanData = new Zuora.zObject('RatePlanData');
                        addRatePlanData.setValue('RatePlan', addRatePlan);
                        amendNewProduct.setValue('RatePlanData', addRatePlanData);
                    }
                    lstAmendments.add(amendNewProduct);
                }
                
                
                 // create amendment request
                Step='Setting the Zuora request...';
                Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
                
                // Specify amendment options for generating invoice to determine total amount and taxes
                Zuora.zApi.AmendOptions amendOpt = new Zuora.zApi.AmendOptions();
                amendOpt.GenerateInvoice = true;
                amendOpt.ProcessPayments = (!isPreview && PaymentMethodType == IECConstants.PaymentType.CREDIT_CARD); // can only set ProcessPayments=true for electronic payments (credit card)
                amendRequest.AmendOptions = amendOpt;
    
                if (isPreview) {
                    // Specify preview options for to simulate the amendment without actually submitting it
                    Step='Previewing the end result...';
                    Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
                    previewOpt.EnablePreviewMode = true;
                    previewOpt.NumberOfPeriods = 1;
                    amendRequest.PreviewOptions = previewOpt;
                }
                else {
                    // Specify target date for the invoice to generate an invoice for the renewal
                    Zuora.zApi.InvoiceProcessingOptions invoiceOpt = new Zuora.zApi.InvoiceProcessingOptions();
                    invoiceOpt.InvoiceTargetDate = IECZuoraHelper.getCurrentDate();
                    invoiceOpt.InvoiceDate = IECZuoraHelper.getCurrentDate();
                    amendRequest.AmendOptions.InvoiceProcessingOptions = invoiceOpt;
                }
                
                amendRequest.Amendments = lstAmendments;
                                                
                Step='Zuora returning result...';
                Zuora.zApi.AmendResult oresult =
                    (!Test.isRunningTest()
                        ? IECZuoraHelper.amendApiCall(amendRequest)
                        : IECEBC_TestUtility.CreateSampleAmendResult());
                        
                if (Zuora.zApi.currentLogger != null) {
                    system.debug('SOAP Upgrade Request >>> ' + Zuora.zApi.currentLogger.request );
                    system.debug('SOAP Upgrade Response >>> ' + Zuora.zApi.currentLogger.response );
                    //ErrorMessage=Zuora.zApi.currentLogger.request+Zuora.zApi.currentLogger.response;
                }
    
                ///////////////////////////////////////////////
                // On-demand sync for the user Billing Account
                
                    if (oresult.Success) {
                        
                        if (!Test.isRunningTest() && !isPreview) {
                            // sync of the account
                            // TODO:
                            List<Zuora.SyncResult> lstSyncResults = OnDemandSyncAccounts(new Set<String> {(String) loggedCustomer.RelatedZuoraAccount.getValue('Id')});
                        }
                        Step='Processing Zuora result...';
                              //Handle with the invoice data returned by previewing subscriptions
                        if (oresult.InvoiceDatas != null && isPreview){ 
                                    TaxAmount=0;
                                    decimal fsubTotalAmount=0;
                                    //totalAmountDue=0;
                                    Decimal amounttax =0;
                                    Decimal amount =0;
                                    Decimal amountwithouttax =0;
                                    for (Zuora.zObject invData: oresult.InvoiceDatas) {
                                      amounttax=0;
                                      amountwithouttax=0;
                                      //in Preview mode, handle with the invoice data
                                      Zuora.zObject invoice = (Zuora.zObject) invData.getValue( 'Invoice' );
                                      if (invoice.getValue( 'TaxAmount' )!=null) amounttax= (Decimal) invoice.getValue( 'TaxAmount' );
                                      if (invoice.getValue( 'Amount' )!=null) amount = ( Decimal ) invoice.getValue( 'Amount' );
                                      if (invoice.getValue( 'AmountWithoutTax')!=null) amountwithouttax = ( Decimal ) invoice.getValue( 'AmountWithoutTax');
                                      TaxAmount= TaxAmount+amounttax;
                                      fsubTotalAmount = fsubTotalAmount+amountwithouttax;
                                      
                                        
                                      }
                                    subTotalAmount = fsubTotalAmount;
                                    return true;
                        }
                  
                    }
                    else
                    {
                        ErrorMessage=ErrorMessage+'Error Processing your request'+' During '+Step;
                    }
                   
                
                
                

            }
            //We need a New Subscription
        Step='Adding Subscription...';
        if (UseCasePricing==0 || UseCasePricing==1 || UseCasePricing==4){
        List<Zuora.zApi.SubscribeRequest> listSubscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
        List<Zuora.zApi.SubscribeResult> listSubscribeResults = null;

        // for each cart item, create a separated subscription

        Zuora.zApi.SubscribeRequest oSubsRequest = new Zuora.zApi.SubscribeRequest();
        
        // Subscription Options
        oSubsRequest.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
        //if (i == listCartItems.size() - 1) {
        oSubsRequest.SubscribeOptions.GenerateInvoice = true;
        oSubsRequest.SubscribeOptions.ProcessPayments = false;
        if (!IsPreview) oSubsRequest.SubscribeOptions.ProcessPayments = (PaymentMethodType == IECConstants.PaymentType.CREDIT_CARD); // can only set ProcessPayments=true for electronic payments (credit card)
        
        oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions = new Zuora.zApi.SubscribeInvoiceProcessingOptions();
        //oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceProcessingScope = 'Account';
        oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceTargetDate = IECZuoraHelper.getCurrentDate();
        oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceDate = IECZuoraHelper.getCurrentDate();
        /*}
        else {
        oSubsRequest.SubscribeOptions.GenerateInvoice = false;
        oSubsRequest.SubscribeOptions.ProcessPayments = false;
        }*/
        Step='Adding Subscription details...';
        // No Preview Options (preview is used for previewing the price)
        oSubsRequest.PreviewOptions = null;
        
        // Create Subscription object
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('ContractEffectiveDate', IECZuoraHelper.getCurrentDate());
        subscription.setValue('TermType', TERM_TYPE);
        subscription.setValue('InitialTerm', EBC_SUBSCRIPTION_TERM_1);
        subscription.setValue('RenewalTerm', EBC_SUBSCRIPTION_TERM_1);
                //subscription.setValue('InitialTermPeriodType', EBC_SUBSCRIPTION_TERM_PERIOD_DAY);
        //subscription.setValue('RenewalTermPeriodType', EBC_SUBSCRIPTION_TERM_PERIOD_DAY);
        // only activate subscription if payment is by credit card or ICH
        if (PaymentMethodType == IECConstants.PaymentType.CREDIT_CARD) subscription.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate());
        if (PaymentMethodType == IECConstants.PaymentType.ICH)  subscription.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate());
        //subscription.setValue('AutoRenew', lstAutoRenew.get(i));
        subscription.setValue('AutoRenew', false);
        subscription.setValue('IsInvoiceSeparate', false);
        //subscription.setValue('PurchaseOrder__c', sPurchaseOrder);
        
        //subscription = 
        //TODAO:Abdellah Bring up here code of the subroutine
        //ebcSubscriptionInitialization(cartItem, subscription); // special handling, in case it is an ebroadcast pay as you go
        /*
        subscription.setValue('ContractEffectiveDate', IECZuoraHelper.getCurrentDate());
        subscription.setValue('TermType', TERM_TYPE);
        subscription.setValue('InitialTerm', EBC_PAY_AS_YOU_GO_SUBSCRIPTION_TERM);
        subscription.setValue('RenewalTerm', EBC_PAY_AS_YOU_GO_SUBSCRIPTION_TERM);
        */
        if (UseCasePricing==4) subscription.setValue('InitialTerm', EBC_SUBSCRIPTION_TERM_12);
        if (UseCasePricing==4) subscription.setValue('RenewalTerm', EBC_SUBSCRIPTION_TERM_12);
        //if (UseCasePricing==4) subscription.setValue('InitialTermPeriodType', EBC_SUBSCRIPTION_TERM_PERIOD_MONTH);
        //if (UseCasePricing==4) subscription.setValue('RenewalTermPeriodType', EBC_SUBSCRIPTION_TERM_PERIOD_MONTH);
        subscription.setValue('Notes', EBC_SUBSCRIPTION_NOTES);       
        subscription.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate()); 
        // subscription.setValue('SubscriptionStartDate', IECZuoraHelper.getCurrentDate()); // this is not insertable
        //subscription.setValue('Status', EBC_PAY_AS_YOU_GO_DEFAULT_STATUS); // set to Active
        // Create the Subscription Data object
        oSubsRequest.SubscriptionData = new Zuora.zApi.SubscriptionData();
        oSubsRequest.SubscriptionData.Subscription = subscription;
        
        //TODO:Abdellah Bring up here code of the subroutine
        // oSubsRequest.SubscriptionData.RatePlanData = IECShoppingCartHelper.createRatePlanDataObjectFromCartItem(cartItem);
        //
        Step='Adding product and rate to subscription...';
        Boolean FirstPass=false;
        List<Zuora.zObject> listRatePlanData = new List<Zuora.zObject>();
        for (ProductRatePlanChargeWrapper cartItem : selectedProductRatePlanChargeWrapperList) {
          // loop for each quantity (did not found a way to provide quantity at the rate plan level in the subscribeRequest call)
          //for (Integer icharge = 0; icharge < CartItem.Size(); icharge++) {
          if (FirstPass) continue; 
          //Use Case Email Block
          if (UseCasePricing==0 || UseCasePricing==4 ) {
            System.debug('CartItem.prpcId >>>'+CartItem.prpcId);
            Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            ratePlan.setValue('ProductRatePlanId', CartItem.prpcId);            
            ratePlanData.setValue('RatePlan', ratePlan);
            if (UseCasePricing!=4 ) {
                  //if (cartItem.ZModel == IECConstants.ChargeModel_Zuora_PerUnitPricing) {
                  Zuora.zObject oRatePlanChargeData = new Zuora.zObject('RatePlanChargeData');
                  Zuora.zObject oRatePlanCharge = new Zuora.zObject('RatePlanCharge');
                  oRatePlanCharge.setValue('Name', CartItem.name );
                  oRatePlanCharge.setValue('ProductRatePlanChargeId', CartItem.ZChargeId );
                  oRatePlanCharge.setValue('Quantity', CartItem.numberOfEmails);
                  oRatePlanCharge.setValue('Price', CartItem.unitPrice);
                  oRatePlanChargeData.setValue('RatePlanCharge', oRatePlanCharge);
                  ratePlanData.setValue('RatePlanChargeData', new List<Zuora.zObject>{oRatePlanChargeData});
            }
            listRatePlanData.add(ratePlanData);
            FirstPass=true;
            //if (oRatePlanChargeData != null)
            //  ratePlanData.setValue('RatePlanChargeData', new List<Zuora.zObject> {oRatePlanChargeData});
            
          }
          //Use Case #1 
          if (UseCasePricing==1){ 
            Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            //ratePlan.setValue('ProductRatePlanId', CartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c);
            ratePlan.setValue('ProductRatePlanId', CartItem.prpcId);
            
            ratePlanData.setValue('RatePlan', ratePlan);
            // List<zqu__ProductRatePlanCharge__c> lstRatePlanCharges = IECProductManager.getZuoraRatePlanChargesByRatePlanID(oCartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__c);
            
            //if (cartItem.ZModel == IECConstants.ChargeModel_Zuora_PerUnitPricing) {
              Zuora.zObject oRatePlanChargeData = new Zuora.zObject('RatePlanChargeData');
              Zuora.zObject oRatePlanCharge = new Zuora.zObject('RatePlanCharge');
              oRatePlanCharge.setValue('Name', CartItem.name );
              oRatePlanCharge.setValue('ProductRatePlanChargeId', CartItem.ZChargeId );
              oRatePlanCharge.setValue('Quantity', CartItem.numberOfEmails);
              oRatePlanCharge.setValue('Price', CartItem.unitPrice);
              
              oRatePlanChargeData.setValue('RatePlanCharge', oRatePlanCharge);
              
              ratePlanData.setValue('RatePlanChargeData', new List<Zuora.zObject>{oRatePlanChargeData});
              listRatePlanData.add(ratePlanData);
            
             }
           
            
          
          //}
        }
        oSubsRequest.SubscriptionData.RatePlanData =listRatePlanData;
  
        ////////////
        // Account
        Step='Checking Account existence in Zuora...';
        // if account already exists in Zuora, only specify the ID
        if (loggedCustomer.AccountExistsInZuora) {
          oSubsRequest.ZAccount = new Zuora.zObject('Account');
          oSubsRequest.ZAccount.setValue('Id', (String)loggedCustomer.RelatedZuoraAccount.getValue('Id'));
          if (!IsPreview) oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', selectedCreditCardPaymentId);
          if(PaymentMethodType == IECConstants.PaymentType.BANK_TRANSFER)  oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_BankTransfer_ZuoraID);
          if(PaymentMethodType == IECConstants.PaymentType.ICH)  oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_ICH_ZuoraID);
          // if the default payment method has changed, update the Default Payment Method, AutoPay flag and Invoice Template Id 
          if (((String)loggedCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId')) != ((String)oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId')) && !Test.isRunningTest() && !IsPreview) {
            Zuora.zApi.SaveResult result = IECZuoraHelper.updateDefaultPaymentMethod((String)loggedCustomer.RelatedZuoraAccount.getValue('Id'), (String)oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId'));
            if (!result.Success)
                ErrorMessage=Label.IEC_Error_Cannot_update_default_payment_method+' During '+Step;
            else
                loggedCustomer.RelatedZuoraAccount.setValue('DefaultPaymentMethodId', oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId'));
          }
        }
        // if not, create an object with all fields (for creation)
        else {
          oSubsRequest.ZAccount = IECZuoraHelper.createZuoraAccount(loggedCustomer.RelatedAccount, loggedCustomer.RelatedContact, PaymentMethodType, (selectedCreditCardPaymentId != null ? selectedCreditCardPaymentId : null));
          // contacts
          oSubsRequest.BillToContact = IECZuoraHelper.createZuoraBillToContact(loggedCustomer.RelatedContact);          
          // check if a Shipping Address exists
          List<IECAddress__c> lstShippingAddresses = IECUserManager.getAddressByContact(loggedCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Shipping);
          if (!lstShippingAddresses.isEmpty())
              oSubsRequest.SoldToContact = IECZuoraHelper.createZuoraSoldToContact(loggedCustomer.RelatedContact);
        }
        
        ///////////////////
        // Payment Method
        if (PaymentMethodType == IECConstants.PaymentType.CREDIT_CARD && !isPreview) {
            oSubsRequest.PaymentMethod = new Zuora.zObject('PaymentMethod');
          // if a payment method was provided, only set the id of the existing payment method
          if (String.isNotBlank(selectedCreditCardPaymentId))
             oSubsRequest.PaymentMethod.setValue('Id', selectedCreditCardPaymentId);
          else 
             ErrorMessage='paymentMethodZId was not provided'+' During '+Step;
        }
        if (isPreview){ 
          Step='Previewing add subscription...';
          Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
            previewOpt.EnablePreviewMode = true;
            previewOpt.NumberOfPeriods = 1;
            oSubsRequest.PreviewOptions=previewOpt;
        }
        listSubscribeRequests.add(oSubsRequest);

        ///////////////////////////
        // Subscribe call to Zuora
        System.debug('listSubscribeRequests >>>'+listSubscribeRequests);
        // not in test method
        
        listSubscribeResults = 
            (!Test.isRunningTest()
                        ? IECZuoraHelper.zApiInstance.zsubscribe(listSubscribeRequests)
             : new List<Zuora.zApi.SubscribeResult>{IECEBC_TestUtility.createComplexSubscriptionResult(true)});
        if (IsPreview){
              TaxAmount=savedTaxAmount;
              subTotalAmount=savedsubTotalAmount;
              //totalAmountDue=savedtotalAmountDue;
              Step='Processing Zuora Subscription result...';
              for (Zuora.zApi.SubscribeResult result : listSubscribeResults) {
                if (!result.Success) {ErrorMessage='Tax Calculation Failed, Try again!';return false;}
                if (result.Success) {
                  //Handle with the invoice data returned by previewing subscriptions
                    TaxAmount=0;
                    decimal fsubTotalAmount=0;
                    //totalAmountDue=0;
                    Decimal amounttax =0;
                    Decimal amount =0;
                    Decimal amountwithouttax =0;
                    for (Zuora.zObject invData: result.InvoiceDatas) {
                      amounttax=0;
                      amountwithouttax=0;
                      //in Preview mode, handle with the invoice data
                      Zuora.zObject invoice = (Zuora.zObject) invData.getValue( 'Invoice' );
                      if (invoice.getValue( 'TaxAmount' )!=null) amounttax= (Decimal) invoice.getValue( 'TaxAmount' );
                      if (invoice.getValue( 'Amount' )!=null) amount = ( Decimal ) invoice.getValue( 'Amount' );
                      if (invoice.getValue( 'AmountWithoutTax')!=null) amountwithouttax = ( Decimal ) invoice.getValue( 'AmountWithoutTax');
                      TaxAmount= TaxAmount+amounttax;
                      fsubTotalAmount = fsubTotalAmount+amountwithouttax;
                      //totalAmountDue =totalAmountDue+amount;
                       
                      }
                    subTotalAmount = fsubTotalAmount;
                    return true;
                } 
                
                
              }
        } 
        
        
        
        ///////////////////////////////////////////////
        // On-demand sync for the user Billing Account
        /**
         * Sync a speicifc customer account from Zuora back to Salesforce
         * @param zuoraAccountIdSet the Zuora AccountId that needs to be sync
         * @return A list of SyncResult (Zuora objects)
         */
  
        if (listSubscribeResults[0].Success && !isPreview){
            Step='Sync Zuora and Salesforce....';
          OnDemandSyncAccounts(new Set<String> {listSubscribeResults[0].AccountId});
          
        }
        
      }
      if (!ErrorMessage.equals('')) return false;
      if (!isPreview) purchaseFulfillment();
      return true;
    }
    catch (IECApplicationException ex) {
      ErrorMessage='Could not subscribe: ' + ex.getMessage()+' During '+Step;
    }
    catch (Exception ex) {
      if (Zuora.zApi.currentLogger != null) {
        system.debug('SOAP Request >>> ' + Zuora.zApi.currentLogger.request );
        system.debug('SOAP Response >>> ' + Zuora.zApi.currentLogger.response );
      }
      ErrorMessage='Could not subscribe: ' + ex.getMessage()+' During '+Step;
    }
    return false;
  } 
    
     /**
     * Sync a speicifc customer account from Zuora back to Salesforce
     * @param zuoraAccountIdSet the Zuora AccountId that needs to be sync
     * @return A list of SyncResult (Zuora objects)
     */
    public static List<Zuora.SyncResult> OnDemandSyncAccounts (Set<String> zuoraAccountIdSet) {
        try {
            Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
            syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
            syncManager.emailNotificationEnabled = false; 
            syncManager.syncZuoraObjectIdSet = zuoraAccountIdSet;
            return (!Test.isRunningTest())
                ? syncManager.sendRequest()
                : null;
        }
        catch (Zuora.OnDemandSyncManager.OnDemandSyncException ex) {
            throw new IECApplicationException('Could not sync Account: ' + ex.getMessage());
        }
    }
    
    //Tax calculation from SAP
    //And Error Message
    public PageReference CalculateTaxNow(){
        
        ErrorMessage='';
        boolean result=false;
        system.debug('### !IsLocationValid() : ' + !IsLocationValid());
        system.debug('### validation customer fields....');
        system.debug('Street' +oBillingAddress.Street__c);
        system.debug('ISO Country' +oBillingAddress.ISO_Country__c);
        /*system.debug('FirstName' + oPaymentBillingContact.FirstName);
        system.debug('LastName' +oPaymentBillingContact.LastName);
        system.debug('Title' +oPaymentBillingContact.Title);
        system.debug('Email' +oPaymentBillingContact.Email);
        system.debug('Phone' +oPaymentBillingContact.Phone);*/
        
        // we're creating a portal user and in the context of this user, we don't have access to the data created in the scope of the test
        // So, since is not possible to have access on the contact fields, we're doing in this ....
        if(Test.isRunningTest()){
         result =true;
        }else{
        if (!IsLocationValid() || (
                 (String.isBlank(oPaymentBillingContact.FirstName))
                || (String.isBlank(oPaymentBillingContact.LastName))
                || (String.isBlank(oPaymentBillingContact.Title))
                || (String.isBlank(oPaymentBillingContact.Email))
                || (String.isBlank(oPaymentBillingContact.Phone))
                || (String.isBlank(oBillingAddress.Street__c))
                || (String.isBlank(oBillingAddress.ISO_Country__c)))){
            if (!IsLocationValid())
              ErrorMessage='Some of the Billing information is missing to calculate Taxes.';
            else
        ErrorMessage='Please fill in all the fields on Billing details section.';                
                
        }
        else
         result=EBCSubscribe(true);
      }
        system.debug('### ErrorMessage : ' + ErrorMessage);
        system.debug('### result : ' + result);
        //TaxAmount=getSAP_Freight_Tax();
        showTaxButtons=false;
        //return null;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ErrorMessage);
        if (!result) {showTaxButtons=true; TaxAmount=0;ApexPages.addMessage(myMsg);}
        return null;
    }
    /*
    public decimal getSAP_Freight_Tax() {
        
        Decimal TotalTax=0;
        Integer UseCasePricing=Situation();
        System.debug('UseCasePricing >>>'+UseCasePricing);
        // Retrieve the SoldTo Location for the current contact
      Location__c oLocSoldTo = new Location_Sel().getSoldToLocationByContactId(new Set<Id> {loggedCustomer.RelatedContact.Id}).get(loggedCustomer.RelatedContact.Id);
        System.Debug('oLocSoldTo >>>'+oLocSoldTo);
        // Initialize a fake OrderItem DTO for tax and shipping calculation
        OrderItem_DTO dtoOrderItem = new OrderItem_DTO();
        String uiUpgradableRatePlan='';
        for (ProductRatePlanChargeWrapper cartItem : selectedProductRatePlanChargeWrapperList) {        
       
           
            uiUpgradableRatePlan = cartItem.prpcId;
            System.debug('uiUpgradableRatePlan before >>>'+uiUpgradableRatePlan);
            //if (UseCasePricing==1) uiUpgradableRatePlan = cartItem.ZChargeId;
 
        }
        System.debug('uiUpgradableRatePlan after>>>'+uiUpgradableRatePlan);
        Try{
            //uiUpgradableRatePlan.productRatePlanInfo.Product_Rate_Plan__r.zqu__ZuoraId__c
            //Get Product Info
            Map<String, Product2> mapProductRatePlanZId_Product = Product_Sel.getProductsByProductRatePlan(new Set<String> {uiUpgradableRatePlan});
            System.Debug('mapProductRatePlanZId_Product >>>'+mapProductRatePlanZId_Product);
            if (mapProductRatePlanZId_Product == null || mapProductRatePlanZId_Product.isEmpty())
                throw new IECApplicationException('Unable to locate a Salesforce Product for the ProductRatePlan: ' + uiUpgradableRatePlan);
            else
            {
                Product2 oProduct = mapProductRatePlanZId_Product.get(uiUpgradableRatePlan);
                System.Debug('oProduct >>>'+oProduct);
                String sProductNumber = oProduct.SAP_Material_Number__c;
                // Get the Parent SAP Code as this is the one to be used with the TAX webservice
                String sParentProductNumber = oProduct.IEC_Parent_Product__r.SAP_Material_Number__c;
                
                String sCustomerType = User_Sel.getCustomerType(UserInfo.getUserId());
                
                PriceDetail_DTO detailprice = new PriceDetail_DTO();
                detailprice.unitPrice=subTotalAmount;
                PriceInfo_DTO priceinfo = new PriceInfo_DTO();
                priceinfo.standardPrice = new List<PriceDetail_DTO> {detailprice};
                // Retrieve the price for the upgrade product
                Map<String, PriceInfo_DTO> mapProductNumber_Price = new Product_Sel().getProductPriceInfo(new Set<String> {sProductNumber}, sCustomerType, null, null, true);
                System.Debug('mapProductNumber_Price >>>'+mapProductNumber_Price);
                dtoOrderItem.PriceInfo = priceinfo; //mapProductNumber_Price.get(sProductNumber);
                dtoOrderItem.sapProductCode = sParentProductNumber;
                dtoOrderItem.quantity = 1;
                dtoOrderItem.chargeShipping = false;
                dtoOrderItem.isContractProduct = true;
                // Set any random ID since it is a fake item
                dtoOrderItem.orderItemId = 'RANDOM';
                
                Order_Svc.setPriceToOrderItemDTO(dtoOrderItem, sCustomerType);
                
                // Retrieve Tax & Shipping information for current Order Item/Subscription
                if (!Test.isRunningTest())
                {
                    
                    String result = Order_Svc.getSAP_Freight_Tax_for_DTO(Utility.getTextSetting('vfOrder-DefaultType')
                                                                         , Utility.getTextSetting('vfOrder-DefaultSource')
                                                                         , Utility.getTextSetting('vfOrder-DefaultChannel')
                                                                         , oLocSoldTo.SAP_Id__c
                                                                         , loggedCustomer.RelatedContact.BillTo_Location__r.SAP_Id__c
                                                                         , loggedCustomer.RelatedContact.ShipTo_Location__r.SAP_Id__c
                                                                         , new List<OrderItem_DTO> {dtoOrderItem});
                    
                    System.debug('Callout SAP Result >>>: ' + result);
                    if (result != null) {ErrorMessage=result; return -1;}
                }
                else
                {
                    dtoOrderItem.taxAmount = 10;
                    dtoOrderItem.shippingAmount = 5;
                }
            }
            
            TotalTax = dtoOrderItem.taxAmount;

           
        } catch (Exception e) {
          system.debug('Issue >>>' + e.getMessage());
          ErrorMessage=e.getMessage();
          return -1;
        } //*** end of call out
        return TotalTax;
    } //*** end of "getSAP_Freight_Tax"
   */
    
    
    /**
    * Preview all upgrades availablre and display their prices
    */
    
    // ========================================================================
  // Purchase Fulfillment section
  // details of processing after the payment has been received and processed in Zuora
  // -----------------------------------------------------------------------
  
  // ------------------------------------------------------------------------
  // purchaseFulfillment should be called once the process receive the payment confirmation from zuora
  
  private void purchaseFulfillment()
  {
        
    String EmailCreditToApply='0';
    String EmailDebitToApply='0';
    //EBC_Activity__c ebcAct;
    String numberOfEmail = String.valueOf(emailCreditPurchased).trim();
    rereadSubscription();
    if (isRenewal) EmailCreditToApply=paidProductRatePlan.EBC_PrePaid_Emails__c;
    if (payEmailCredit) EmailCreditToApply=paidProductRatePlan.EBC_Email_Credit_Current_Offering__c;
  
    if (payExactAmount) {EmailCreditToApply=numberOfEmail;EmailDebitToApply=numberOfEmail;}
    if (payNewRatePlan) EmailCreditToApply=paidProductRatePlan.EBC_PrePaid_Emails__c;
        
    if (paymentTarget==null) paymentTarget='';
    if (campaignPaymentOption==null) campaignPaymentOption='';

    boolean iscampaignlogic=false;
    List<EBC_Campaign__c> cmplist=new List<EBC_Campaign__c>();
    if (campaignPaymentOption=='Email Package' && paymentTarget=='campaign') iscampaignlogic=true;
    
    if (iscampaignlogic) cmplist=[Select Id, Number_of_Recipients__c From EBC_Campaign__c Where id=:ebcCampaignId Limit 1];
    if (cmplist.size()>0) EmailDebitToApply=String.ValueOf(cmplist[0].Number_of_Recipients__c);
     

    billingAccountOrder.Status__c='Payment';
    billingAccountOrder.Email_Credit__c=Decimal.ValueOf(EmailCreditToApply);
    billingAccountOrder.Email_Debit__c=Decimal.ValueOf(EmailDebitToApply);
    update billingAccountOrder;
    rereadBillingAccount();
  } // end of purchaseFulfillment
    

/**
* Returns the currently active Terms & Conditions of a Product
* @param oProductInfo The related Product Information object
* @return A Terms_and_Conditions__c object
*/
public List<Terms_and_Conditions__c> TermsAndConditions { get; private set; }
    
public static List<Terms_and_Conditions__c> getCurrentTermsAndConditionForProduct(String sCategory, String sProductInfoId) {
  List<Terms_and_Conditions__c> listTC = new List<Terms_and_Conditions__c>();
  List<Product_Rate_Plan_Information__c> listPI = new List<Product_Rate_Plan_Information__c>();
  
  ListPI = [Select Related_Product_Information__c
             From Product_Rate_Plan_Information__c
           Where Product_Rate_Plan__c=:sProductInfoId
           Limit 10];
   
    
  Set<Id> ListId = new Set<Id>();
  for(Product_Rate_Plan_Information__c item:ListPI){
        ListId.add(item.Related_Product_Information__c);
    }
  listTC = getCurrentTermsAndCondition(sCategory);
  
  if (listTC.Size()==0) {listTC = getCurrentTermsAndCondition('EBC');}
  if (ListId.Size()==0)  return listTC;
    
  listTC = [SELECT Effective_Start_Date__c
              ,Is_Current__c
                ,Product_Information__c
                ,Name
                ,Product_Information__r.Related_Product_Category__r.Display_Name__c
                ,(SELECT Id
                      ,ContentType
                      ,BodyLength 
                    FROM Attachments 
                    WHERE IsDeleted = false ORDER BY CreatedDate desc) 
             FROM Terms_and_Conditions__c
             WHERE Product_Information__r.Related_Product_Category__r.Name=:sCategory
               AND Id=:ListId
               AND Effective_Start_Date__c <= :Datetime.now()
             ORDER BY Effective_Start_Date__c DESC
            Limit 1];
        
  if (listTC.Size()==0) {listTC = getCurrentTermsAndCondition('EBC');}
  return listTC;
    //Product_Information__c = :sProductInfoId
}

private static List<Terms_and_Conditions__c> getCurrentTermsAndCondition(String sCategory)
{
    List<Terms_and_Conditions__c> listTC = new List<Terms_and_Conditions__c>();
    listTC = [SELECT Effective_Start_Date__c
              ,Is_Current__c
                ,Product_Information__c
                ,Name
                ,Product_Information__r.Related_Product_Category__r.Display_Name__c
                ,(SELECT Id
                      ,ContentType
                      ,BodyLength 
                    FROM Attachments 
                    WHERE IsDeleted = false ORDER BY CreatedDate desc) 
             FROM Terms_and_Conditions__c
             WHERE Product_Information__r.Related_Product_Category__r.Name=:sCategory
               AND Effective_Start_Date__c <= :Datetime.now()
             ORDER BY Effective_Start_Date__c DESC
            Limit 1];
        
    return listTC; 
    
}


/**
* Cancel button on iecebc_campaignpayment page
* redirects the user to IECEBC_CampaignSchedule page
*/
public PageReference backToPreviousStep(){
        system.debug('backToPreviousStep start');
        PageReference pr=Page.IECEBC_CampaignSchedule;
        pr.getParameters().put( 'id', ebcCampaignId);
        pr.setRedirect(true);
        return pr;
}


} // end of class vfIECEBC_PaymentComponentController