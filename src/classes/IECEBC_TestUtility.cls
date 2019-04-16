/**  
  * Description: 
  * 	This class contains utilities for building test class related to EBC/eBroadcast
  *     This class should only be used by test classes. 
  *     The @isTest annotation in this class might be commented out to increase total average of test coverage
  *	
  * Initial Author: 
  *   - Sonny Leman (common data setups)
  *   - Mathieu Beausoleil (other methods)
  *
  * Version: 1.0
  * History: 
  *   2016-09-11 -sl: initial version prior to move the content of vfIECEBC_TestSuite, no extra insert on createTestUser
  *   2016-09-30 -sl: update EBC_Setup, create related Product Rate Plan Information and Product Info as part of the set up
  *
  * Public Methods:
  *  - createTestUser()
  *  - createEbcSetupAndRelatedData(): EBC Rate Plan creations
  *  - createEbcSubscription(,,)
  *  - Email will be set to the email and contact name in EBC_Preference (there should only be one eBroadcast_Preference)
  * 
  * 
  * 
  */

//@isTest 
public with sharing class IECEBC_TestUtility {
	
	// Test User related records, created by createTestUser
	public static User oUser {get;private set;} // community user
	public static Contact oContact {get;private set;}
	public static Account oAccount {get;private set;}
	public static Location__c oLocation {get;private set;}
	public static IECAddress__c oAddress {get;private set;}
	public static IATA_ISO_Country__c isoCountry {get;private set;} 
	public static Zuora__CustomerAccount__c oBillingAccount {get;private set;}
	public static EBC_Preference__c oEbcPreference {get;private set;}
	
	// ========================================================================
	// zqu_ProductRatePlanCharge__c.zqu__Type__c picklist options
	private static final String RATE_PLAN_CHARGE_TYPE_ONE_TIME = 'One-Time';
	private static final String RATE_PLAN_CHARGE_TYPE_RECURRING = 'Recurring';
	
	// ========================================================================
	// EBC Configuration Records
	// EBC_Setup, EBC Specific Categories, EBC Related Product, 
	// Product Rate Plan, Product Rate Plan Information, Product Rate Plan Charge
	//  
	
	public static Product_Category__c oEbcProductCategory;
	public static zqu__ZProduct__c oEbcProductMember;
	public static zqu__ZProduct__c oEbcProductNonMember;
	public static zqu__ZProduct__c oEbcProductAddOnStorage;
	public static zqu__ZProduct__c oEbcProductAddOnReporting;
	public static zqu__ZProduct__c oEbcProductEmailBlock;
	public static zqu__ZProduct__c oEbcProductPayExactAmount;
	public static List<Product_Information__c> lEbcProductInfo;
	public static Map<Id,Product_Information__c> mProductIdToProductInfoObj; // map from ZProduct.Id to Product_Information
	
	public static zqu__ProductRatePlan__c oEbcPayAsYouGoProductRatePlanMember {get;private set;}	// pay as you go EBC
	public static zqu__ProductRatePlan__c oEbcPayAsYouGoProductRatePlanNonMember {get;private set;} // pay as you go EBC
	
	public static List<zqu__ProductRatePlan__c> lEbcProductRatePlanMember {get;private set;} 	// prepaid EBC
	public static List<zqu__ProductRatePlan__c> lEbcProductRatePlanNonMember {get;private set;} // prepaid EBC
	public static zqu__ProductRatePlan__c oEbcProductRatePlanAddOnStorage {get;private set;} 
	public static zqu__ProductRatePlan__c oEbcProductRatePlanAddOnReporting {get;private set;}
	public static List<Product_Rate_Plan_Information__c> lProductRatePlanInformation {get; private set;} 
	public static Map<Id,Product_Rate_Plan_Information__c> mProductRatePlanIdToProductRatePlanInformationObj {get; private set;}
	
	public static List<zqu__ProductRatePlan__c> lEbcProductRatePlanEmailBlock {get;private set;}
	public static zqu__ProductRatePlan__c oEbcProductRatePlanPaysExactAmount {get;private set;}
	public static List<zqu__ProductRatePlanCharge__c> lEbcProductRatePlanCharge {get;private set;}
	
	public static EBC_Setup__c oEbcSetup {get;private set;}
	
	private static Set<Id> sProductIdWithRecurringFlatCharge {get; private set;}
	private static Set<Id> sProductIdWithOneTimeFlatCharge {get; private set;}
	private static Set<Id> sProductIdWithOneTimePerUnitCharge {get; private set;}
	
	// ================================================================================
	// last created/inserted ebc subscription and subscription charge, created by createEbcSubscription
	private static Zuora__Subscription__c oSubscription;
	private static Zuora__SubscriptionProductCharge__c oSubscriptionProductCharge;
	
	// ================================================================================
	// static constants
	private static String TEST_IATA_CODE = '1234567';
	public static final String EBC_RENEWAL_WINDOW = '60';
	
    private static String generateZuoraID() {
        String newId = IECUtil.NewGuid();
        return newId.substring(0, 32);
    }
			
	// ========================================================================
	// create one community user, along with its related records
	// Output: oUser, oContact, oAccount, oBillingAccount, oEbcPreference
	public static void createTestUser()
	{
		createTestUser(false);
	}
	
	public static void createTestUser(Boolean isMember)
	{
		// create users 
		
		oUser = createSampleGuestUserAndLogin();
		//insert oUser; // i am not sure why this was required before, it should not need additional insert here
		
		System.assertNotEquals(null, oUser.Username, 'User.Username should not be null for user:'+ oUser);
		System.assertNotEquals(null, oUser.ContactId, 'User.ContactId should not be null for user:'+ oUser);
		//System.assertNotEquals(null, oUser.Id, 'User.Id should not be null for user:'+ oUser); // this often returns null at this point
		
		// get updated oUser record
		
		 List<User> lUser = [select Id, Name
				, ContactId
				, Contact.Id
				, Contact.Name
				, Contact.FirstName
				, Contact.LastName
				, Contact.Email
				, Contact.Title
				, Contact.AccountId
				, Contact.Account.Id
				, Contact.Account.Name
				, Contact.IATA_Code__c
				from User
				where Id = : oUser.Username];
		
		List<Contact> lContact = [select Id, Name, FirstName, LastName, Email, Title, Phone
									, IATA_Code__c
									, AccountId
									, Account.Id
									, Account.Name 
								from Contact 
								where Id = : oUser.ContactId];
		oContact = lContact[0];
		oAccount = oContact.Account;
		
		if (isMember && oContact.IATA_Code__c == null) {
			//oContact.IATA_Code__c = TEST_IATA_CODE;
			//insert oContact;
		} else if (!isMember && oContact.IATA_Code__c != null) {
			//oContact.IATA_Code__c = null;
			//insert oContact;
		}
		
		
		List<Zuora__CustomerAccount__c> lBillingAccount = [select Id, Name, Contact__c
						  from Zuora__CustomerAccount__c
						  where Contact__c = : oContact.Id];
		
		System.assertNotEquals( 0, lBillingAccount.size(), 'No Billing account found for oContact!');
		oBillingAccount = lBillingAccount[0];
		
		oBillingAccount.eBroadcast_Product_Access__c = true; 
		oBillingAccount.Zuora__Status__c = 'Active';
		update oBillingAccount;
		
		oEbcPreference = new EBC_Preference__c(Name = oContact.FirstName
								, PrimaryContact_Email__c = oContact.Email
								, Notify_On_Send__c = true
								, Default_From_Name__c = oContact.FirstName
								, PrimaryContact_Name__c = oContact.FirstName
								, Billing_Account__c = oBillingAccount.Id
							);
		insert oEbcPreference;
	
	} // end of createTestUser
	
	
	
	// ========================================================================
	// create all EBC Setup, and all related records
	// Product, Product Rate Plan, Product Rate Plan Charge 
	// Main Output oEbcSetup
	// Other ouputs:  
	//   oEbcProductCategory, oEbcProductMember, oEbcProductNonMember,
	//   oEbcProductAddOnStorage, oEbcProductAddOnReporting, oEbcProductEmailBlock
	//   lEbcProductInfo
	public static void createEbcSetupAndRelatedData()
	{
		// create all EBC related Product_Category, zqu__ZProduct, Product_Information
		createEbcRelatedProducts();
		
		// create all EBC Related Rate Plans and ProducRatePlanCharges
		createEbcRelatedRatePlansAndCharges(); 
		
		// create EBC Set up
		oEbcSetup = new EBC_Setup__c( Name='Default for Test'
					, Default_Storage_Capacity__c = 20
					, Default_Cost_per_E_mail__c  = 0.53
					, Extra_Storage_Capacity__c = 25
					, Maximum_File_Size_Upload__c = 1
					
					, Product_Category__c = oEbcProductCategory.Id
					, Member_Pay_As_You_Go_Plan__c = oEbcPayAsYouGoProductRatePlanMember.Id
					, Member_Prepaid_Product_Rate_Plan_01__c = lEbcProductRatePlanMember[0].Id
					, Member_Prepaid_Product_Rate_Plan_02__c = lEbcProductRatePlanMember[1].Id
					, Member_Prepaid_Product_Rate_Plan_03__c = lEbcProductRatePlanMember[2].Id
					, Member_Prepaid_Product_Rate_Plan_04__c = lEbcProductRatePlanMember[3].Id
					, Non_Member_Pay_As_You_Go_Plan__c = oEbcPayAsYouGoProductRatePlanMember.Id 
					, Non_Member_Prepaid_Product_Rate_Plan_01__c = lEbcProductRatePlanNonMember[0].Id
					, Non_Member_Prepaid_Product_Rate_Plan_02__c = lEbcProductRatePlanNonMember[1].Id
					, Non_Member_Prepaid_Product_Rate_Plan_03__c = lEbcProductRatePlanNonMember[2].Id
					, Non_Member_Prepaid_Product_Rate_Plan_04__c = lEbcProductRatePlanNonMember[3].Id
					, E_Member_Prepaid_Product_Rate_Plan_01__c =lEbcProductRatePlanMember[0].Id
                    , E_Member_Prepaid_Product_Rate_Plan_02__c =lEbcProductRatePlanMember[1].Id
                    , E_Member_Prepaid_Product_Rate_Plan_03__c =lEbcProductRatePlanMember[2].Id
                    , E_Member_Prepaid_Product_Rate_Plan_04__c =lEbcProductRatePlanMember[3].Id                                                   
                    , E_N_Member_Prepaid_Product_Rate_Plan_01__c= lEbcProductRatePlanNonMember[0].Id
                    , E_N_Member_Prepaid_Product_Rate_Plan_02__c= lEbcProductRatePlanNonMember[1].Id
                    , E_N_Member_Prepaid_Product_Rate_Plan_03__c= lEbcProductRatePlanNonMember[2].Id
                    , E_N_Member_Prepaid_Product_Rate_Plan_04__c= lEbcProductRatePlanNonMember[3].Id
					, Pay_Exact_Amount_Member__c = oEbcProductRatePlanPaysExactAmount.Id
					, Pay_Exact_Amount_Non_Member__c = oEbcProductRatePlanPaysExactAmount.Id
					
					, Member_Email_Block_Product__c = oEbcProductEmailBlock.Id
					, Non_Member_Email_Block_Product__c = oEbcProductEmailBlock.Id
					
					, Storage_Product_Rate_Plan__c = oEbcProductRatePlanAddOnStorage.Id
					, Enhanced_Reporting_Product_Rate_Plan__c = oEbcProductRatePlanAddOnReporting.Id
					
				);
		insert oEbcSetup;
		
	} // end of createEbcData
	
	
	// ========================================================================
	// create all EBC Category, Products, and Product_Information
	// output oEbcProductCategory, oEbcProduct*, lEbcProductInfo
	private static void createEbcRelatedProducts()
	{
		oEbcProductCategory = CreateSampleProductCategory(IECConstants.ProductCategory_SF_EBROADCAST, true);
		
		oEbcProductCategory.Renewal_Window__c = EBC_RENEWAL_WINDOW;
		insert oEbcProductCategory;
		
		// create ZProducts
		oEbcProductMember = CreateSampleProduct('eBroadcast for Non-Members');
		//oEbcProductMember.ProductAudience__c = 'Member Airline';
		//oEbcProductMember.zqu__Category__c = 'Base Products';
		oEbcProductMember.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductMember.zqu__Description__c = 'eBroadcast for IATA Member Airlines';
		
		oEbcProductNonMember = CreateSampleProduct('eBroadcast for Non-Members');
		//oEbcProductNonMember.ProductAudience__c = 'Non-Member Single';
		//oEbcProductNonMember.zqu__Category__c = 'Base Products';
		oEbcProductNonMember.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductNonMember.zqu__Description__c = 'eBroadcast for IATA Member Airlines';
		
		oEbcProductAddOnStorage = CreateSampleProduct('Additional Storage');
		//oEbcProductAddOnStorage.ProductAudience__c = null;
		//oEbcProductAddOnStorage.zqu__Category__c = 'Add On Services';
		oEbcProductAddOnStorage.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductAddOnStorage.zqu__Description__c = 'eBroadcast add on';
		
		oEbcProductAddOnReporting = CreateSampleProduct('Enhanced Reporting');
		//oEbcProductAddOnReporting.ProductAudience__c = null;
		//oEbcProductAddOnReporting.zqu__Category__c = 'Add On Services';
		oEbcProductAddOnReporting.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductAddOnReporting.zqu__Description__c = 'eBroadcast add on';
		
		oEbcProductEmailBlock = CreateSampleProduct('Email Block');
		//oEbcProductEmailBlock.ProductAudience__c = null;
		//oEbcProductEmailBlock.zqu__Category__c = 'Email Blocks';
		oEbcProductEmailBlock.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductEmailBlock.zqu__Description__c = 'eBroadcast Email Blocks';
		
		oEbcProductPayExactAmount = CreateSampleProduct('EBC Pay Exact Amount');
		oEbcProductPayExactAmount.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST;
		oEbcProductPayExactAmount.zqu__Description__c ='eBroadcast Pay Exact Amount';
		
		List<zqu__ZProduct__c> lEbcProduct = new List<zqu__ZProduct__c>{oEbcProductMember, oEbcProductNonMember
			, oEbcProductAddOnStorage, oEbcProductAddOnReporting, oEbcProductEmailBlock
			, oEbcProductPayExactAmount };
		insert lEbcProduct;
		
		//
		lEbcProductInfo = new List<Product_Information__c>();
		mProductIdToProductInfoObj = new Map<Id,Product_Information__c>();
		for (zqu__ZProduct__c prd : lEbcProduct) 
		{
			Product_Information__c oProdInfo = CreateSampleProductInfo( prd.Name, oEbcProductCategory, prd);
			oProdInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
			lEbcProductInfo.add(oProdInfo);
			mProductIdToProductInfoObj.put( prd.Id, oProdInfo);
		}
		insert lEbcProductInfo;
		
	} // createEbcRelatedCategoryProducts
	
	
	// ========================================================================
	// create all EBC Product Rate Plans, Product Rate Plan Information, and Product Rate Plan Charges
	// input oEbcProductMember, oEbcProductNonMember, oEbcProductAddOnStorage, oEbcProductAddOnReporting, oEbcProductEmailBlock
	// output:  
	private static void createEbcRelatedRatePlansAndCharges()
	{
		lEbcProductRatePlanMember= new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlanMember.add(CreateSampleProductRatePlan('Starter Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(CreateSampleProductRatePlan('Professional Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(CreateSampleProductRatePlan('Enterprise Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(CreateSampleProductRatePlan('Premium Edition M', false, oEbcProductMember));
		
		for (zqu__ProductRatePlan__c prp : lEbcProductRatePlanMember) {
			prp.EBC_SubscriptionType__c = vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID;
		}

		lEbcProductRatePlanNonMember = new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlanNonMember.add(CreateSampleProductRatePlan('Starter Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(CreateSampleProductRatePlan('Professional Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(CreateSampleProductRatePlan('Enterprise Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(CreateSampleProductRatePlan('Premium Edition N', false, oEbcProductNonMember));
		for (zqu__ProductRatePlan__c prp : lEbcProductRatePlanNonMember) {
			prp.EBC_SubscriptionType__c = vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID;
		}
		
		oEbcPayAsYouGoProductRatePlanMember = CreateSampleProductRatePlan(vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO, false, oEbcProductMember);
		oEbcPayAsYouGoProductRatePlanMember.EBC_SubscriptionType__c = vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO;
		oEbcPayAsYouGoProductRatePlanNonMember = CreateSampleProductRatePlan(vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO, false, oEbcProductNonMember);
		oEbcPayAsYouGoProductRatePlanNonMember.EBC_SubscriptionType__c = vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO;
		
		oEbcProductRatePlanAddOnStorage = CreateSampleProductRatePlan('Extra Storage', false, oEbcProductAddOnStorage);
		oEbcProductRatePlanAddOnReporting = CreateSampleProductRatePlan('Extra Storage', false, oEbcProductAddOnReporting);
		
		lEbcProductRatePlanEmailBlock = new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlanEmailBlock.add(CreateSampleProductRatePlan('Email Block 1', false, oEbcProductEmailBlock));
		lEbcProductRatePlanEmailBlock.add(CreateSampleProductRatePlan('Email Block 2', false, oEbcProductEmailBlock));
		lEbcProductRatePlanEmailBlock.add(CreateSampleProductRatePlan('Email Block 3', false, oEbcProductEmailBlock));
		
		oEbcProductRatePlanPaysExactAmount = CreateSampleProductRatePlan('Exact Amount', false, oEbcProductPayExactAmount);
		
		
		// insert all of product rate plans
		List<zqu__ProductRatePlan__c> lEbcProductRatePlan = new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlan.addAll(lEbcProductRatePlanMember);
		lEbcProductRatePlan.addAll(lEbcProductRatePlanNonMember);
		lEbcProductRatePlan.add(oEbcPayAsYouGoProductRatePlanMember);
		lEbcProductRatePlan.add(oEbcPayAsYouGoProductRatePlanNonMember);
		lEbcProductRatePlan.add(oEbcProductRatePlanAddOnStorage);
		lEbcProductRatePlan.add(oEbcProductRatePlanAddOnReporting);
		lEbcProductRatePlan.addAll(lEbcProductRatePlanEmailBlock);
		lEbcProductRatePlan.add(oEbcProductRatePlanPaysExactAmount);
		
		insert lEbcProductRatePlan;
		
		// product rate plan charges are set based on products 
		sProductIdWithRecurringFlatCharge = new Set<Id> {oEbcProductMember.Id, oEbcProductNonMember.Id, oEbcProductAddOnStorage.Id};
		sProductIdWithOneTimeFlatCharge = new Set<Id> {oEbcProductAddOnStorage.Id, oEbcProductAddOnReporting.Id};
		sProductIdWithOneTimePerUnitCharge = new Set<Id> {oEbcProductEmailBlock.Id, oEbcProductPayExactAmount.Id};
		
		// Product Rate Plan Charges
		lEbcProductRatePlanCharge = new List<zqu__ProductRatePlanCharge__c>();
		
		// Product Rate Plan Information
		lProductRatePlanInformation = new List<Product_Rate_Plan_Information__c>();
		mProductRatePlanIdToProductRatePlanInformationObj = new Map<Id,Product_Rate_Plan_Information__c>();
		
		for (zqu__ProductRatePlan__c oPrp : lEbcProductRatePlan)
		{
			Product_Rate_Plan_Information__c oPrpi = CreateSampleProductRatePlanInfo( oPrp.Name, false
												, oPrp, mProductIdToProductInfoObj.get( oPrp.zqu__ZProduct__c) );
			lProductRatePlanInformation.add(oPrpi);
			mProductRatePlanIdToProductRatePlanInformationObj.put( oPrp.Id, oPrpi);
			
			// create product rate plan charge as needed.
			if ( sProductIdWithRecurringFlatCharge.contains( oPrp.zqu__ZProduct__c)) {
				zqu__ProductRatePlanCharge__c oPrpCharge;
				oPrpCharge = CreateSampleProductRatePlanCharge(oPrp, 'Charge Recurring Flat-' + oPrp.Name, 1);
				oPrpCharge.zqu__Type__c = RATE_PLAN_CHARGE_TYPE_RECURRING;
				oPrpCharge.zqu__Model__c = IECConstants.ChargeModel_Zuora_FlatFeePricing;
				lEbcProductRatePlanCharge.add(oPrpCharge);
			}
			if ( sProductIdWithOneTimeFlatCharge.contains( oPrp.zqu__ZProduct__c)) {
				zqu__ProductRatePlanCharge__c oPrpCharge;
				oPrpCharge = CreateSampleProductRatePlanCharge(oPrp, 'Charge One Time Flat-' + oPrp.Name, 1);
				oPrpCharge.zqu__Type__c = RATE_PLAN_CHARGE_TYPE_ONE_TIME;
				oPrpCharge.zqu__Model__c = IECConstants.ChargeModel_Zuora_FlatFeePricing;
				lEbcProductRatePlanCharge.add(oPrpCharge);
			}
			if ( sProductIdWithOneTimePerUnitCharge.contains( oPrp.zqu__ZProduct__c)) {
				zqu__ProductRatePlanCharge__c oPrpCharge;
				oPrpCharge = CreateSampleProductRatePlanCharge(oPrp, 'Charge One Time Per Unit-' + oPrp.Name, 1);
				oPrpCharge.zqu__Type__c = RATE_PLAN_CHARGE_TYPE_ONE_TIME;
				oPrpCharge.zqu__Model__c = IECConstants.ChargeModel_Zuora_PerUnitPricing;
				lEbcProductRatePlanCharge.add(oPrpCharge);
			}
		}
		insert lEbcProductRatePlanCharge;
		insert lProductRatePlanInformation;
	} // end of createEbcRelatedRatePlansAndCharges
	
	
	
	// ================================================================================
	// create Subscription and related SubscriptionProductCharge
	// for the test user (oUser, oAccount, oBillingAccount)
	// input ProductRatePlan, ZProduct, EndSubscriptionDate
	// output oSubscription, oSubscriptionProductCharge
	// return value: oSubscription
	public static Zuora__Subscription__c createEbcSubscription(zqu__ProductRatePlan__c poProductRatePlan, zqu__ZProduct__c poProduct, Date pdEndSubscriptionDate)
	{
		// create dummy subscription
		oSubscription = createSampleSubscription(oAccount.Id, oBillingAccount.Id, 'Subs 01', pdEndSubscriptionDate);
		oSubscription.Zuora__Status__c = 'Active';
		insert oSubscription;
		
		// create dummy subscription charge
		oSubscriptionProductCharge = createSampleSubscriptionCharge(oSubscription.Id, pdEndSubscriptionDate.addMonths(-12)
																				, poProduct, poProductRatePlan
																			   );
		insert oSubscriptionProductCharge;

		return oSubscription;
	} // end of createEbcSubscription

	
    public static Product_Rate_Plan_Information__c CreateSampleProductRatePlanInfo(String sName, Boolean triable, zqu__ProductRatePlan__c oProductRatePlan, Product_Information__c oProductInfo) {
        Product_Rate_Plan_Information__c prpi = new Product_Rate_Plan_Information__c();
            prpi.Name = sName;
            prpi.Related_Product_Information__c = oProductInfo.Id;
            prpi.Product_Rate_Plan__c = oProductRatePlan.Id;
            prpi.Active__c = true;
            prpi.Monthly_Price__c = 10.00;
            prpi.Display_As_Monthly_Fee__c = !triable;
            //prpi.User_Interface_Display__c = 'Yes';
            prpi.Order__c = 1;
            prpi.Short_Description__c = 'Sample Product Rate Plan Information';
            prpi.Long_Description__c = 'long desc';
            
            return prpi;
    }
    public static Zuora__Subscription__c createSampleSubscription(id idAccount, String sName, Date sEndDate) {
        return createSampleSubscription(idAccount, null, sName, sEndDate);
    }

    public static Zuora__Subscription__c createSampleSubscription(id idAccount, id idBillingAccount, String sName, Date sEndDate) {
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        String zuoraId =  IECUtil.NewGuid();
        subscription.Zuora__External_Id__c = 
            subscription.Zuora__Zuora_Id__c = zuoraId.substring(0, 32);
        subscription.Zuora__RenewalTerm__c = '12 Months';
        subscription.Zuora__Version__c = 1;
    
        if (sName != null)
            subscription.Name = sName;
    
        if (idAccount != null)
            subscription.Zuora__Account__c = idAccount;
        
        if (idBillingAccount != null)
            subscription.Zuora__CustomerAccount__c = idBillingAccount;

        if (sEndDate != null) { 
            subscription.Zuora__SubscriptionEndDate__c = sEndDate;
            subscription.Zuora__SubscriptionStartDate__c = sEndDate.addYears(-1).addDays(1); // Calculates start date 1 year before endDate
            subscription.Zuora__TermStartDate__c = subscription.Zuora__SubscriptionStartDate__c;
            subscription.Zuora__TermEndDate__c = subscription.Zuora__SubscriptionEndDate__c;
        }
        
        return subscription;
    }
    
    public static Zuora__SubscriptionProductCharge__c createSampleSubscriptionCharge(Id subscriptionId, Date sEffectiveDate, zqu__ZProduct__c oProduct, zqu__ProductRatePlan__c oProductRatePlan) {
        string sZID = IECUtil.NewGuid().substring(0, 32);
        return new Zuora__SubscriptionProductCharge__c(
            Zuora__External_Id__c = sZID
            , Zuora__Zuora_Id__c = sZID
            , Name = 'CHARGETEST'
            , Zuora__Subscription__c = subscriptionId
            , Zuora__BillingPeriod__c = 'Annual'
            , Zuora__EffectiveStartDate__c = sEffectiveDate
            , Zuora__TotalContractValue__c = 25
            , Zuora__MonthlyRecurringRevenue__c = 2
            , Zuora__Price__c = 25
            , Zuora__Quantity__c = 1
            , Zuora__ExtendedAmount__c = 25
            , Zuora__BillingPeriodStartDay__c = '19th of the month'
            , Zuora__Model__c = IECConstants.ChargeModel_Zuora_FlatFeePricing
            , Zuora__Type__c = 'Recurring'
            , Zuora__RatePlanName__c = oProductRatePlan.Name
            , Zuora__RatePlanDescription__c = oProductRatePlan.zqu__Description__c
            , Zuora__RatePlanEffectiveEndDate__c = oProductRatePlan.zqu__EffectiveEndDate__c
            , Zuora__ProductName__c = oProduct.Name
            , Zuora__ProductSKU__c = oProduct.zqu__SKU__c
            , Zuora__ProductEffectiveEndDate__c = oProduct.zqu__EffectiveEndDate__c
        );
    }
    
    public static zqu__ProductRatePlanCharge__c CreateSampleProductRatePlanCharge(zqu__ProductRatePlan__c oRelatedRatePlan, String sName, double dPrice) {
        zqu__ProductRatePlanCharge__c ratePlanCharge = new zqu__ProductRatePlanCharge__c();
            ratePlanCharge.Name = sName;
            ratePlanCharge.zqu__ProductRatePlan__c = oRelatedRatePlan.Id;
            ratePlanCharge.zqu__Deleted__c = false;
            ratePlanCharge.zqu__ZuoraId__c = generateZuoraID();
            ratePlanCharge.zqu__ListPrice__c = dPrice;
            ratePlanCharge.zqu__Model__c = 'Flat Fee Pricing';
            
            return ratePlanCharge;
    }
    
	public static Zuora.zApi.SubscribeResult createComplexSubscriptionResult(Boolean success) {
        Zuora.zApi.SubscribeResult res = new Zuora.zApi.SubscribeResult();
        if (success) {
            res.Success = true;
            res.AccountNumber = 'A-0987654321';
            res.SubscriptionNumber = 'S-0987654321';
            res.InvoiceNumber = 'I-0987654321';
            List<Zuora.zObject> lstInvoiceDatas = new List<Zuora.zObject>();
            Zuora.zObject oInvoiceData = new Zuora.zObject('InvoiceData');
            
            Zuora.zObject oInvoice = new Zuora.zObject('Invoice');
            oInvoice.setValue('AmountWithoutTax', 25.0);
            oInvoice.setValue('TaxAmount', 0.2);
            oInvoice.setValue('Amount', 25.2);
            
            oInvoiceData.setValue('Invoice', oInvoice);
            lstInvoiceDatas.add(oInvoiceData);
            res.InvoiceDatas = lstInvoiceDatas;
        }
        else {
            res.Success = false;
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Code', 'OMG');
            error.setValue('Message', 'Error generated for unit testing');
            res.errors = new List<Zuora.zObject> {error};
        }
        return res;
    }
    
    public static Zuora.zApi.AmendResult CreateSampleAmendResult() {
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
        result.Success = true;
        result.PaymentTransactionNumber = '1234567890';
        List<Zuora.zObject> lstInvoiceDatas = new List<Zuora.zObject>();
        Zuora.zObject oInvoiceData = new Zuora.zObject('InvoiceData');
        
        Zuora.zObject oInvoice = new Zuora.zObject('Invoice');
        oInvoice.setValue('AmountWithoutTax', 25.0);
        oInvoice.setValue('TaxAmount', 0.2);
        oInvoice.setValue('Amount', 25.2);
        
        Zuora.zObject oInvoiceItem = new Zuora.zObject('InvoiceItem');
        oInvoiceItem.setValue('ChargeDate', Datetime.now());
        oInvoiceItem.setValue('ChargeName', 'Test subscription charge');
        oInvoiceItem.setValue('ServiceStartDate', Datetime.now());
        oInvoiceItem.setValue('ServiceEndDate', Datetime.now().addYears(1).addDays(-1));
        oInvoiceItem.setValue('UnitPrice', 42.0);
        oInvoiceItem.setValue('ChargeAmount', 42.0);
        
        oInvoiceData.setValue('Invoice', oInvoice);
        oInvoiceData.setValue('InvoiceItem', new List<Zuora.zObject>{ oInvoiceItem });
        lstInvoiceDatas.add(oInvoiceData);
        result.InvoiceDatas = lstInvoiceDatas;
        return result;
    }
    
    public static Product_Category__c CreateSampleProductCategory(string sProductCode, boolean bPricedProduct) {
        Product_Category__c pc = new Product_Category__c ();
            pc.Name = sProductCode;
            pc.Button_Type__c = bPricedProduct ? IECConstants.ProductCategory_ButtonType_BuyNow : IECConstants.ProductCategory_ButtonType_GetAQuote;
            pc.Renewal_Window__c = '600';
            pc.Auto_Renewal_Window__c = '60';
            pc.Display_Name__c = 'Sample Product Display Name';
            pc.Short_Description__c = 'Sample Product Short Description';
            pc.Long_Description__c = 'Sample Product Long Description';
            pc.Application_URL__c = 'http://www.iata.org';
            pc.Feature_1_Image__c
                = pc.Feature_2_Image__c
                = pc.Feature_3_Image__c
                = pc.Feature_4_Image__c
                = pc.Feature_5_Image__c
                = pc.Feature_6_Image__c = 'http://www.deque.com/images/Deque_feature_icon_chckbx.png';
            pc.Feature_1_Description__c
                = pc.Feature_2_Description__c
                = pc.Feature_3_Description__c
                = pc.Feature_4_Description__c
                = pc.Feature_5_Description__c
                = pc.Feature_6_Description__c = 'Sample Product Feature Description'; 
            pc.Section_2_Name__c
                = pc.Section_3_Name__c
                = pc.Section_5_Name__c = 'Sample Product Sections';
            pc.Section_1_Show__c
                = pc.Section_2_Show__c
                = pc.Section_3_Show__c
                = pc.Section_4_Show__c
                = pc.Section_5_Show__c
                = pc.Section_6_Show__c = true;
            pc.Active__c = true;
        return pc;
    }
    
    public static zqu__ProductRatePlan__c CreateSampleProductRatePlan(String sName, Boolean triable, zqu__ZProduct__c oProduct) {
        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c();
            prp.Name = sName;
            prp.zqu__ZProduct__c = oProduct.Id;
            prp.zqu__ZuoraId__c = 'PRP' + (Math.random()*1000000000);
            prp.zqu__EffectiveStartDate__c = Date.today().addDays(-15);
            prp.zqu__EffectiveEndDate__c = Date.today().addDays(15);
            prp.IsTriable__c = triable?'Yes':'No';
        	prp.EBC_Cost_Per_Email__c = '0.001';
            
            return prp;
    }
    
    public static zqu__ZProduct__c CreateSampleProduct(String sName) {
        return new zqu__ZProduct__c(
            Name = sName
            , zqu__ZuoraId__c = 'P-' + (Math.random()*1000000000)
            , zqu__EffectiveStartDate__c = Date.today().addDays(-15)
            , zqu__EffectiveEndDate__c = Date.today().addDays(15)
            , zqu__SKU__c = 'SKU' + (Math.random()*1000000000)
        );
    }
    public static Product_Information__c CreateSampleProductInfo(String sName, Product_Category__c oProductCategory, zqu__ZProduct__c oProduct) {
        return CreateSampleProductInfo(sName, oProductCategory, oProduct, IECConstants.ProductInformationAudience_DEFAULT);
    }
    
    public static Product_Information__c CreateSampleProductInfo(String sName, Product_Category__c oProductCategory, zqu__ZProduct__c oProduct, String productAudience) {
        Product_Information__c pi = new Product_Information__c();
            pi.Name = sName;
            pi.Related_Product_Category__c = oProductCategory.Id;
            pi.Related_Product__c = oProduct.Id;
            pi.Product_Audience__c = productAudience;

            return pi;
    }
    
     public static User createSampleGuestUserAndLogin() {
        return createSampleGuestUserAndLogin(IECConstants.Account_ClientType_ThirdParty);
    }
    
    public static User createSampleGuestUserAndLogin(String ClientType) {
        // insert account
        oAccount = createSampleAccount(ClientType);
        insert oAccount;

        isoCountry = new IATA_ISO_Country__c();
        isoCountry.ISO_Code__c='CT';
		isoCountry.Name='canadatest';
		isoCountry.Region__c = 'North-America';
		isoCountry.ISO_Code_Numeric__c = 560;
		insert isoCountry;
 
        // create Bill To contact info
        oContact = new Contact();
        oContact.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Contact', 'Standard_Contact');
        oContact.AccountId = oAccount.Id;
        oContact.FirstName = 'Test';
        oContact.LastName = 'User';
        oContact.Title = 'TestTitle';
        oContact.Email = 'testIECGuest@test.iata.org';
        oContact.Phone = '514123345';
        oContact.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
        insert oContact;
        system.debug('oContact->contact id : ' + oContact.id);

        oBillingAccount = new Zuora__CustomerAccount__c(
            Zuora__Account__c = oAccount.Id
            , Contact__c = oContact.Id
            , Name = oAccount.Name
            , CRMContactID__c = oContact.Id
            , Zuora__DefaultPaymentMethod__c = 'CreditCard'
            , Zuora__BillToCity__c = 'Toronto'
            , Zuora__BillToCountry__c = 'Canada'
            , Zuora__BillToState__c = 'Ontario'
            , Zuora__BillToAddress1__c = '123 Test St'
            , Zuora__BillToPostalCode__c = 'A9A9A9'
        );

        //oBillingAccount = createSampleBillingAccount(oAccount, oContact);
        insert oBillingAccount; 
        system.debug('oBillingAccount->contact id : ' + oBillingAccount.Contact__c);

        oAddress = new IECAddress__c();
		oAddress.Address_Type__c = IECConstants.IECAddress_AddressType_Billing;
		oAddress.Contact__c = oContact.Id;
	    oAddress.Street__c = '12 main street';
	    oAddress.City__c = 'Montreal';
	    oAddress.Country__c = 'Canada';
	    oAddress.State__c = 'QC';
	    oAddress.ZipCode__c = 'h1q2w3';
	    oAddress.ISO_Country__c = isoCountry.Id;
	    insert oAddress; 

	    oLocation = Location_Svc.createLocation(oAccount.Id,oAddress.Id,oContact.Id, oContact.Email,  oContact.Phone,  null, 'Bill To');
	    //location  = Location_Svc.createLocation(accountHQ1.Id, lstAddress[0].Id, lstContact[0].Id, lstContact[0].Email, lstContact[0].Phone, null, 'Bill To');
	    //insert oLocation;

        User u = new User(
            Username = ISSP_Utilities.buildPortalUserName('testIECGuest@test.iata.org')
            , Email = 'testIECGuest@test.iata.org'
            , emailencodingkey = 'UTF-8'
            , Alias = IECUserManager.createAliasFromName(oContact.LastName)
            , FirstName = oContact.FirstName
            , LastName = oContact.LastName
            , LocaleSidKey = 'en_US'
            , CommunityNickname = 'testIECGuest@iata.org'
            , ProfileId = IECUserManager.getProfileIdForIECUser()
            , LanguageLocaleKey = 'en_US'
            , timezonesidkey = 'America/New_York'
            , ContactId = oContact.Id
            , IsActive = true
            , ReceivesAdminInfoEmails = false
            , ReceivesInfoEmails = false
        );
        insert u;
        //trgPortalUserAfterInserUpdate = true;
        String userId = Site.createPortalUser(u, oAccount.Id, 'testpassword');
      
        system.debug('oContact->contact id before : ' + oContact);
        IECUserManager.login(u.Username, 'testpassword', null);
           system.debug('oContact->contact id after : ' + oContact);



        return u;
    }
    
    public static Zuora__CustomerAccount__c createSampleBillingAccount(Account oRelatedAccount) {
        return createSampleBillingAccount(oRelatedAccount, null); 
    }
    
    public static Zuora__CustomerAccount__c createSampleBillingAccount(Account oRelatedAccount, Contact oRelatedContact) {
        return new Zuora__CustomerAccount__c(
            Zuora__Account__c = oRelatedAccount.Id
            , Contact__c = (oRelatedContact == null ? null : oRelatedContact.Id)
            , Name = oRelatedAccount.Name
            , CRMContactID__c = (oRelatedContact == null) ? null : String.valueOf(oRelatedContact.Id)
            , Zuora__DefaultPaymentMethod__c = 'CreditCard'
            , Zuora__BillToCity__c = 'Toronto'
            , Zuora__BillToCountry__c = 'Canada'
            , Zuora__BillToState__c = 'Ontario'
            , Zuora__BillToAddress1__c = '123 Test St'
            , Zuora__BillToPostalCode__c = 'A9A9A9'
        );
    }
    public static Account createSampleAccount() {
        return createSampleAccount(IECConstants.Account_ClientType_ThirdParty);
    }
    
    public static Account createSampleAccount(String ClientType) {
        oAccount = new Account();
        oAccount.RecordTypeId = IECUserManager.getAccountRecordTypeForIEC(ClientType);
        oAccount.BillingStreet = '123 main street';
        oAccount.BillingPostalCode = 'H0H 0H0';
        oAccount.BillingCountry = 'Canada';
        oAccount.BillingCity = 'Montreal';
        oAccount.Customer_Type__c = ClientType;
        oAccount.Name = 'Company';


        //IATA_ISO_Country__c isoCountry = CreateSampleIATAISOCountry();
        //insert isoCountry;
        //newAccount.IATA_ISO_Country__c = isoCountry.Id;


        oAccount.OwnerId = IECUserManager.getIECAccountOwnerId();
        
        if (ClientType == IECConstants.Account_ClientType_MemberAirline) {
            oAccount.Membership_status__c = IECConstants.Account_MembershipStatus_IATAMember;
            oAccount.ICH_Member__c = true;
        }

        return oAccount;
    }
    
    
   
} // IECEBC_TestUtility class