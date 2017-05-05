public class vfIECEBC_TestPaymentSuite {
    public static Account IECTestUtil_Account;
    public static Contact IECTestUtil_Contact;
    public static User IECTestUtil_User;
    public static Id IECTestUtil_UserId;
    public static Zuora__CustomerAccount__c IECTestUtil_BillingAccount;
    
    public static Product_Category__c oProductCategory;
    public static Product_Information__c oProductInfo;
    public static zqu__ZProduct__c oProduct;
    public static zqu__ProductRatePlan__c oProductRatePlan;
    public static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    public static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    public static Zuora__Subscription__c subscription;
    public static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    public static Zuora__CustomerAccount__c oBillingAccount {get;set;}
    private Static boolean isOk=false;
    //    get { return IECTestUtil_BillingAccount; }
    //}
    public static EBC_Preference__c oPref;
    
    public static IECCustomer currentCustomer;

    
    public static boolean initPostRunAs(Integer Scenario) {
        IECEBC_TestUtility.createEbcSetupAndRelatedData();
        oProductCategory = IECEBC_TestUtility.oEbcProductCategory;
        
        oProduct = IECEBC_TestUtility.oEbcProductNonMember;
        
        oProductInfo = IECEBC_TestUtility.mProductIdToProductInfoObj.get(oProduct.Id);
        
        if (Scenario==10) oProductRatePlan = IECEBC_TestUtility.oEbcPayAsYouGoProductRatePlanMember;
        if (Scenario!=10) oProductRatePlan = IECEBC_TestUtility.lEbcProductRatePlanMember[0];
        			
        oProductRatePlanCharge = IECEBC_TestUtility.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
        insert oProductRatePlanCharge;
        //zqu__ProductRatePlanCharge__c.zqu__ProductRatePlan__c
        
        oProductRatePlanInfo = IECEBC_TestUtility.CreateSampleProductRatePlanInfo('Starter Edition', false, oProductRatePlan, oProductInfo);
        insert oProductRatePlanInfo; 
        
        currentCustomer = IECCustomer.getCurrentIECCustomer(); 
        
        // create dummy subscription
        subscription = IECEBC_TestUtility.createSampleSubscription(IECEBC_TestUtility.oBillingAccount.Zuora__Account__c, IECEBC_TestUtility.oBillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
        subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
        subscription.Zuora__TermEndDate__c =null;
		subscription.Zuora__SubscriptionStartDate__c =Date.today().addMonths(-6);
		subscription.Zuora__Status__c = 'Active';
        insert subscription;
        
        // create dummy subscription charge
        subscriptionCharge = IECEBC_TestUtility.createSampleSubscriptionCharge(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        subscriptionCharge.Product_Rate_Plan_Charge__c = oProductRatePlanCharge.Id;
        //zqu__ProductRatePlanCharge__c
        insert subscriptionCharge;
        
        //oPref = new EBC_Preference__c(Billing_Account__c = IECEBC_TestUtility.oBillingAccount.Id, PrimaryContact_Email__c = 'hello@world.com', Default_From_Name__c = 'w00t', PrimaryContact_Name__c = 'w00t');
        User vusr = vfIECEBC.usr;
        
        if (IECEBC_TestUtility.oUser.Id!=vusr.Id) return false;
        
        //insert oPref;
        User usr = [Select ContactId, Contact.AccountId from User where id = :IECEBC_TestUtility.oUser.Id];
        //if (IECEBC_TestUtility.oUser.Id!=Userinfo.getUserid()) return false;
	
        Zuora__CustomerAccount__c billingAccount;
		
				billingAccount = [Select Id, Name
									, eBroadcast_Trusted_Sender__c
                                    , eBroadcast_Email_Balance__c
                                    , Zuora__Account__c  
									, eBroadcast_Add_On_Access__c
									, eBroadcast_Add_On_Advanced_Reporting__c
									, eBroadcast_Storage__c
									, Zuora__DefaultPaymentMethod__c // text, e.g. Credit Card
									, Zuora__Default_Payment_Method__c // lookup
									, Zuora__Default_Payment_Method__r.Zuora__External_Id__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardExpirationMonth__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardExpirationYear__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardHolderName__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardMaskNumber__c
									, Zuora__Default_Payment_Method__r.Zuora__CreditCardType__c
									, Zuora__Default_Payment_Method__r.Zuora__Type__c
									, ICHCode__c 
									, ClientType__c
									, Contact__c
									, Contact__r.Id
									, Contact__r.IATA_Code__c
									, Contact__r.Name
									, Contact__r.FirstName
									, Contact__r.LastName
									, Contact__r.Title
									, Contact__r.Phone
									, Contact__r.Email
									
									from Zuora__CustomerAccount__c 
									where Contact__c = :usr.ContactId LIMIT 1];
	    
        Contact oPaymentBillingContact = billingAccount.Contact__r;
        //if (oPaymentBillingContact==null) return false;
        
        Set<Id> ebcProductRatePlanIdSet = new Set<Id>();
			ebcProductRatePlanIdSet.addAll(IECEBC_Utility.ebcNonMemberProductRatePlanIdList);
			ebcProductRatePlanIdSet.addAll(IECEBC_Utility.ebcMemberProductRatePlanIdList);
            ebcProductRatePlanIdSet.addAll(IECEBC_Utility.ebcECommerceProductRatePlanIdList);
            ebcProductRatePlanIdSet.addAll(IECEBC_Utility.ebcPayAsYouGoProductRatePlanIdSet);
            //if (!ebcProductRatePlanIdSet.contains(oProductRatePlan.id)) return false;
			
			List<Zuora__SubscriptionProductCharge__c> spcList = [select Id
				, Zuora__Product__c, Zuora__Product__r.Name
				, Zuora__Price__c
				, Zuora__ProductDescription__c 
				, Zuora__ProductName__c
				, Product_Rate_Plan_Charge__c
				, Product_Rate_Plan_Charge__r.Name
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Id
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Name
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__Description__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_SubscriptionType__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_Cost_Per_Email__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_Currency_Cost_Per_Email__c
				, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.EBC_PrePaid_Emails__c
				, Zuora__EffectiveEndDate__c
				
				, Zuora__Subscription__c
				, Zuora__Subscription__r.Id
				, Zuora__Subscription__r.Name
				, Zuora__Subscription__r.Zuora__AutoRenew__c
				, Zuora__Subscription__r.Zuora__NextRenewalDate__c
				, Zuora__Subscription__r.Zuora__Status__c
				, Zuora__Subscription__r.Zuora__SubscriptionEndDate__c
				, Zuora__Subscription__r.Zuora__TermEndDate__c
				, Zuora__Subscription__r.Zuora__Zuora_Id__c 
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Id
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__Description__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Cost_Per_Email__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_Currency_Cost_Per_Email__c
				, Zuora__Subscription__r.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_PrePaid_Emails__c
				
				from Zuora__SubscriptionProductCharge__c 
				//where Zuora__Subscription__c = : subscription.Id
				//	and Product_Rate_Plan_Charge__c = : productRatePlan.Id];
					
				 Where ( Zuora__Subscription__r.Zuora__CustomerAccount__c = :IECEBC_TestUtility.obillingAccount.Id) 
					 AND (
						 (Zuora__Subscription__r.Zuora__TermEndDate__c >=  TODAY) 
						 OR (Zuora__Subscription__r.Zuora__TermEndDate__c = NULL)
						 
						 //OR (Product_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c = : EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO)
					 )
					 AND (Zuora__Subscription__r.Zuora__SubscriptionStartDate__c <=  TODAY) 
					 AND (Zuora__Subscription__r.Zuora__Status__c = 'Active')
					 //AND (Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = :IECConstants.ProductCategory_SF_EBROADCAST)
					 
					AND Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.Id=:oProductRatePlan.id
                                                                 //in :  ebcProductRatePlanIdSet
				 ORDER BY Zuora__Subscription__r.Zuora__Status__c ASC
					 , Zuora__Subscription__r.Zuora__TermEndDate__c DESC NULLS FIRST
					 , Zuora__Subscription__r.Zuora__TermStartDate__c DESC
				 ];
                if (spcList.size() > 0) {
					Zuora__SubscriptionProductCharge__c  ebcSubscriptionProductCharge = spcList[0];
                    System.debug('ebcSubscriptionProductCharge>>>'+ebcSubscriptionProductCharge);
				    System.debug('ebcSubscriptionProductCharge>>>'+ebcSubscriptionProductCharge.Product_Rate_Plan_Charge__r);
				    System.debug('ebcSubscriptionProductCharge>>>'+ebcSubscriptionProductCharge.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r);
				
				}else
                {
                    
                    System.debug('Account Billing >>>'+IECEBC_TestUtility.obillingAccount.Id);
                    //return false;
                }
				
                                                                                   
			return true;
        
        
        
    }
    
    private static String PaymentToken='mntuIDiPdV9OtU0ydP/ixJRl0NRNC7H60dQ2d9sBr2tsJUOpJhD8z6t6IxlGFnbz57g6XcF9G2lgsVpY1NHep28i8r83CG3sOFlBvjNVlpH93G4bXSsh8VrkCuidiHIF';
    private static EBC_Order__c CreateOrder(){
       EBC_Order__c order = new EBC_Order__c();
       order.Billing_Account__c=IECEBC_TestUtility.oBillingAccount.Id;
       order.eBroadcast_Payment_Campaign__c=null;
       order.eBroadcast_Payment_Campaign_Option__c='Exact Amount';
      
       order.eBroadcast_Payment_Email_Credit_Amount__c=0;
       order.eBroadcast_Payment_Product_Rate_Plan__c=null;
       order.eBroadcast_Payment_Subscription__c=null;
       order.eBroadcast_Payment_Target__c='rateplan';
       order.eBroadcast_Payment_Token__c=PaymentToken;
       order.Email_Credit__c=0;
       order.Email_Debit__c=0;
       order.Status__c='Pending';
       return order;
        
        
    }

    //Storage RatePlan to test Exact Payment Subscription with storage Credit
    public static void createEBCOrderForStorageProduct(){
       EBC_Order__c order=CreateOrder();
       order.eBroadcast_Payment_Campaign_Option__c='Exact Amount';
       order.eBroadcast_Payment_Target__c='addon storage';
       order.eBroadcast_Payment_Product_Rate_Plan__c=IECEBC_TestUtility.oEbcProductRatePlanAddOnStorage.Id;
       insert order;

    }
    //Storage Extended report to test Amdended Payment Subscription
    public static void createEBCOrderForExtendedReportProduct(){
       EBC_Order__c order=vfIECEBC_TestPaymentSuite.CreateOrder();
       order.eBroadcast_Payment_Campaign_Option__c='Email Package';
       order.eBroadcast_Payment_Target__c='addon reporting';
       order.eBroadcast_Payment_Product_Rate_Plan__c=IECEBC_TestUtility.oEbcProductRatePlanAddOnReporting.id;

       insert order;

    }
    //Storage Email Block report to test Payment New Subscription with Credit
    public static void createEBCOrderForEmailBlockProduct(){
       EBC_Order__c order=vfIECEBC_TestPaymentSuite.CreateOrder();
       order.eBroadcast_Payment_Campaign_Option__c='Prepaid Rate Plan';
       order.eBroadcast_Payment_Target__c='email';
       order.eBroadcast_Payment_Email_Credit_Amount__c=500;
       order.Email_Credit__c=500;
       order.eBroadcast_Payment_Product_Rate_Plan__c=IECEBC_TestUtility.lEbcProductRatePlanEmailBlock[0].Id;
       insert order;

    }
    //Renew the subscription
    public static void createEBCOrderForRenewal(){
       EBC_Order__c order=vfIECEBC_TestPaymentSuite.CreateOrder();
       order.eBroadcast_Payment_Campaign_Option__c='Prepaid Rate Plan';
       order.eBroadcast_Payment_Target__c='renewal';
       order.eBroadcast_Payment_Email_Credit_Amount__c=500;
       order.eBroadcast_Payment_Subscription__c=subscription.id;
       order.Email_Credit__c=500;
       order.eBroadcast_Payment_Product_Rate_Plan__c=null; //IECEBC_TestUtility.lEbcProductRatePlanEmailBlock[0].Id;
       insert order;

    }
    //Renew the subscription
    public static void createEBCOrderForCampaign(){
        
       EBC_Order__c order=vfIECEBC_TestPaymentSuite.CreateOrder();
       order.eBroadcast_Payment_Campaign__c=DummyCampaign().Id;
       order.eBroadcast_Payment_Campaign_Option__c='Exact Amount';
       order.eBroadcast_Payment_Target__c='campaign';
       order.eBroadcast_Payment_Email_Credit_Amount__c=500;
       order.eBroadcast_Payment_Subscription__c=null;
       order.Email_Credit__c=500;
       order.eBroadcast_Payment_Product_Rate_Plan__c=IECEBC_TestUtility.lEbcProductRatePlanEmailBlock[0].Id;
       insert order;

    }
    private static EBC_Campaign__c DummyCampaign(){
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = 'Agency', Filter_Description__c = 'Preferred Language', Data_Type__c = 'Text', Filter_Field__c = 'Preferred_Language__c');
        insert af;
        EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Agency', OwnerId = IECEBC_TestUtility.oUser.Id);
        insert masterFilter;
        EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id, EBC_Application_Filter__c = af.Id, Field_Operator__c = '=', Field_Value__c = 'X0');
        insert cf;
        EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true, OwnerId = IECEBC_TestUtility.oUser.Id);
        insert tpl;
        EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar', Number_of_Recipients__c = 7, Subject__c = 'Foo Subject', From_Name__c = 'Foo From Name', Is_Google_Analytics_Tracker_Active__c = true, Google_Analytics_Tracking_Code__c = 'UA-XXXXXX', Billing_Account__c = IECEBC_TestUtility.oBillingAccount.Id, EBC_Master_Filter__c = masterFilter.Id, EBC_Design__c = tpl.Id, OwnerId = IECEBC_TestUtility.oUser.Id);
        insert camp;
        return camp;
    }
    public static void CreatePayment()
    {
        IECEBC_TestUtility.createTestUser(false);
        //System.
        //initPostRunAs();
        System.runAs(IECEBC_TestUtility.oUser) {
            Test.startTest();
            PageReference pageRef = Page.IECEBC_Payment;
            
            Test.setCurrentPage(pageRef); 
            vfIECEBC_Payment pmt = new vfIECEBC_Payment(); 
            
            Id pmtid=pmt.ebcCampaignId;
            EBC_Campaign__c cmp=pmt.ebcCampaign;
            Contact cnt=pmt.paymentBillingContact;
            Zuora__CustomerAccount__c actb = pmt.paymentBillingAccount;
        }

    }
    public static void CreateOrderPayment(Integer Scenario){

        
        IECEBC_TestUtility.createTestUser(false);
        //System.
        //initPostRunAs();
        System.runAs(IECEBC_TestUtility.oUser) {
            Test.startTest();
            PageReference pageRef = Page.IECEBC_Payment;
            Test.setCurrentPage(pageRef); 
            if (!initPostRunAs(Scenario)) return;
            //if (!isOK) return;
            Id sub =vfIECEBC.billingAccount.Id;
            if (IECEBC_TestUtility.oBillingAccount.Id!=sub) return;
 
            if (Scenario==1) createEBCOrderForStorageProduct();
            if (Scenario==2) createEBCOrderForExtendedReportProduct();
            if (Scenario==3) createEBCOrderForEmailBlockProduct();
            if (Scenario==4) createEBCOrderForRenewal();
            if (Scenario==5) createEBCOrderForCampaign();
            
            if (Scenario==10) createEBCOrderForStorageProduct();
            pageRef.getParameters().put('PaymentToken',PaymentToken);
            
            
            vfIECEBC_PaymentComponentController ctrl = new vfIECEBC_PaymentComponentController();
            
            ctrl.selectedPaymentMethodType='CREDIT_CARD';
            ctrl.selectedCreditCardPaymentId='asdasdasdasdasdasdasd';
            ctrl.selectedTermsConditions='';
            string df=ctrl.defaultPaymentExternalId;
            boolean isf=ctrl.isPayableWithCreditCard;
            isf=ctrl.isPayableWithICH;
            isf=ctrl.isPayableWithBankTransfer;
            isf=ctrl.showTaxButtons;
            ctrl.showTaxButtons=true;
            ctrl.showICHText=true;
            ctrl.showBankTransferText=true;
            isf=ctrl.showTransactionButtons;
            ctrl.showTransactionButtons=true;
            ctrl.ChooseBankTransferMethod();            
            ctrl.ChooseICHMethod();
            ctrl.ChooseCreditCardMethod();
            isf=ctrl.showPaymentButtons;
            ctrl.showPopUp();
            ctrl.displayCallBackfailure();
            //ctrl.validateConfiguration();
            ctrl.getExtraParamString();
            ctrl.sErrorMsgFromHPM='';
            ctrl.hasConfigError=false;
            ctrl.iframeSrc='';
            
            Map<String, String> mapv = ctrl.getExtraParameters();
            ctrl.EBCSubscribeNow();
            ctrl.CalculateTaxNow();
            
            List<IECZuoraHelper.PaymentMethod> paymentv=ctrl.paymentMethods;
            Date datev = ctrl.newSubscriptionTermEndDate;
            datev=ctrl.newSubscriptionTermStartDate;
            Integer intv=ctrl.emailCreditAddition;
            isf=ctrl.isSubscriptionDescriptionVisible;
            isf=ctrl.payAddOn;
            isf=ctrl.payNewRatePlan;
            ctrl.clickEditButton();
            isf=ctrl.bStateAvailable;
            isf=ctrl.isPaymentTokenValid;
            
            //List<ISO_Country_State_DTO> countryv=ctrl.lstCountryState();
            List<SelectOption> provincev=ctrl.lstStateProvince;
            List<SelectOption> isocountryv=ctrl.lstISOCountries;
            
            ctrl.LoadPaymentBillingContact(null);
            //Contact contactv=ctrl.oPaymentBillingContact;
            
            ctrl.clickSaveBillingDetailButton();
            ctrl.clickCancelBillingDetailButton();
            //Leave the Payment Page
            ctrl.readMethodofPayment();
            ctrl.GoToAccountManage();
            ctrl.CancelToManageAccountPage();
            ctrl.ReturnToManageAccountPage();
            ctrl.onChangeBillingCountry();
            isf=ctrl.init;
            ctrl.init();
            // System.assertEquals(4, dashboardCon.campaignsCount);
  
            }

    }
   
}