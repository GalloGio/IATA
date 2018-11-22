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
	public static Product2 oEbcProductMember;
	public static Product2 oEbcProductNonMember;
	public static Product2 oEbcProductAddOnStorage;
	public static Product2 oEbcProductAddOnReporting;
	public static Product2 oEbcProductEmailBlock;
	public static Product2 oEbcProductPayExactAmount;
	public static List<Product_Information__c> lEbcProductInfo;
	public static Map<Id,Product_Information__c> mProductIdToProductInfoObj; // map from Product.Id to Product_Information
	
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
		//System.assertNotEquals( 0, lUser.size(), 'oUser record is not ready in the storage yet: ' + oUser);
		//System.assertNotEquals( null, lUser[0].ContactId, 'ContactId should not be null');
		//oUser = lUser[0];
		
		//oContact = oUser.Contact; // related Contact record of the community user
		//oAccount = oUser.Contact.Account; // temp Account
		
		
		
		
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
		// create all EBC related Product_Category, Product, Product_Information
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
					
					, New_Member_Email_Block_Product__c = oEbcProductEmailBlock.Id
					, New_Non_Member_Email_Block_Product__c = oEbcProductEmailBlock.Id
					
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
		oEbcProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_EBROADCAST, true);
		
		oEbcProductCategory.Renewal_Window__c = EBC_RENEWAL_WINDOW;
		insert oEbcProductCategory;
		
		// create Products
		oEbcProductMember = IECTEstUtil.createSampleProduct2('eBroadcast for Non-Members');
		oEbcProductMember.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductMember.Description = 'eBroadcast for IATA Member Airlines';
		
		oEbcProductNonMember = IECTEstUtil.createSampleProduct2('eBroadcast for Non-Members');
		oEbcProductNonMember.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductNonMember.Description = 'eBroadcast for IATA Member Airlines';
		
		oEbcProductAddOnStorage = IECTEstUtil.createSampleProduct2('Additional Storage');
		oEbcProductAddOnStorage.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductAddOnStorage.Description = 'eBroadcast add on';
		
		oEbcProductAddOnReporting = IECTEstUtil.createSampleProduct2('Enhanced Reporting');
		oEbcProductAddOnReporting.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductAddOnReporting.Description = 'eBroadcast add on';
		
		oEbcProductEmailBlock = IECTEstUtil.createSampleProduct2('Email Block');
		oEbcProductEmailBlock.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductEmailBlock.Description = 'eBroadcast Email Blocks';
		
		oEbcProductPayExactAmount = IECTEstUtil.createSampleProduct2('EBC Pay Exact Amount');
		oEbcProductPayExactAmount.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST;
		oEbcProductPayExactAmount.Description ='eBroadcast Pay Exact Amount';
		
		List<Product2> lEbcProduct = new List<Product2>{oEbcProductMember, oEbcProductNonMember
			, oEbcProductAddOnStorage, oEbcProductAddOnReporting, oEbcProductEmailBlock
			, oEbcProductPayExactAmount };
		insert lEbcProduct;
		
		//
		lEbcProductInfo = new List<Product_Information__c>();
		mProductIdToProductInfoObj = new Map<Id,Product_Information__c>();
		for (Product2 prd : lEbcProduct) 
		{
			Product_Information__c oProdInfo = IECTestUtil.createSampleProductInfo2( prd.Name, oEbcProductCategory, prd);
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
		lEbcProductRatePlanMember.add(createEbcSampleProductRatePlan('Starter Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(createEbcSampleProductRatePlan('Professional Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(createEbcSampleProductRatePlan('Enterprise Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(createEbcSampleProductRatePlan('Premium Edition M', false, oEbcProductMember));
		
		for (zqu__ProductRatePlan__c prp : lEbcProductRatePlanMember) {
			prp.EBC_SubscriptionType__c = vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID;
		}

		lEbcProductRatePlanNonMember = new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlanNonMember.add(createEbcSampleProductRatePlan('Starter Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(createEbcSampleProductRatePlan('Professional Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(createEbcSampleProductRatePlan('Enterprise Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(createEbcSampleProductRatePlan('Premium Edition N', false, oEbcProductNonMember));
		for (zqu__ProductRatePlan__c prp : lEbcProductRatePlanNonMember) {
			prp.EBC_SubscriptionType__c = vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PRE_PAID;
		}
		
		oEbcPayAsYouGoProductRatePlanMember = createEbcSampleProductRatePlan(vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO, false, oEbcProductMember);
		oEbcPayAsYouGoProductRatePlanMember.EBC_SubscriptionType__c = vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO;
		oEbcPayAsYouGoProductRatePlanNonMember = createEbcSampleProductRatePlan(vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO, false, oEbcProductNonMember);
		oEbcPayAsYouGoProductRatePlanNonMember.EBC_SubscriptionType__c = vfIECEBC.EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO;
		
		oEbcProductRatePlanAddOnStorage = createEbcSampleProductRatePlan('Extra Storage', false, oEbcProductAddOnStorage);
		oEbcProductRatePlanAddOnReporting = createEbcSampleProductRatePlan('Extra Storage', false, oEbcProductAddOnReporting);
		
		lEbcProductRatePlanEmailBlock = new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlanEmailBlock.add(createEbcSampleProductRatePlan('Email Block 2', false, oEbcProductEmailBlock));
		lEbcProductRatePlanEmailBlock.add(createEbcSampleProductRatePlan('Email Block 3', false, oEbcProductEmailBlock));
		lEbcProductRatePlanEmailBlock.add(createEbcSampleProductRatePlan('Email Block 1', false, oEbcProductEmailBlock));
		
		oEbcProductRatePlanPaysExactAmount = createEbcSampleProductRatePlan('Exact Amount', false, oEbcProductPayExactAmount);
		
		
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
			Product_Rate_Plan_Information__c oPrpi = IECTestUtil.createSampleProductRatePlanInfo( oPrp.Name, false
												, oPrp, mProductIdToProductInfoObj.get( oPrp.zqu__Product__c) );
			lProductRatePlanInformation.add(oPrpi);
			mProductRatePlanIdToProductRatePlanInformationObj.put( oPrp.Id, oPrpi);
			
			// create product rate plan charge as needed.
			if ( sProductIdWithRecurringFlatCharge.contains( oPrp.zqu__Product__c)) {
				zqu__ProductRatePlanCharge__c oPrpCharge;
				oPrpCharge = IECTestUtil.createSampleProductRatePlanCharge(oPrp, 'Charge Recurring Flat-' + oPrp.Name, 1);
				oPrpCharge.zqu__Type__c = RATE_PLAN_CHARGE_TYPE_RECURRING;
				oPrpCharge.zqu__Model__c = IECConstants.ChargeModel_Zuora_FlatFeePricing;
				lEbcProductRatePlanCharge.add(oPrpCharge);
			}
			if ( sProductIdWithOneTimeFlatCharge.contains( oPrp.zqu__Product__c)) {
				zqu__ProductRatePlanCharge__c oPrpCharge;
				oPrpCharge = IECTestUtil.createSampleProductRatePlanCharge(oPrp, 'Charge One Time Flat-' + oPrp.Name, 1);
				oPrpCharge.zqu__Type__c = RATE_PLAN_CHARGE_TYPE_ONE_TIME;
				oPrpCharge.zqu__Model__c = IECConstants.ChargeModel_Zuora_FlatFeePricing;
				lEbcProductRatePlanCharge.add(oPrpCharge);
			}
			if ( sProductIdWithOneTimePerUnitCharge.contains( oPrp.zqu__Product__c)) {
				zqu__ProductRatePlanCharge__c oPrpCharge;
				oPrpCharge = IECTestUtil.createSampleProductRatePlanCharge(oPrp, 'Charge One Time Per Unit-' + oPrp.Name, 1);
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
	// input ProductRatePlan, Product, EndSubscriptionDate
	// output oSubscription, oSubscriptionProductCharge
	// return value: oSubscription
	public static Zuora__Subscription__c createEbcSubscription(zqu__ProductRatePlan__c poProductRatePlan, Product2 poProduct, Date pdEndSubscriptionDate)
	{
		// create dummy subscription
		oSubscription = IECTestUtil.createSampleSubscription(oAccount.Id, oBillingAccount.Id, 'Subs 01', pdEndSubscriptionDate);
		oSubscription.Zuora__Status__c = 'Active';
		insert oSubscription;
		
		// create dummy subscription charge
		oSubscriptionProductCharge = IECTestUtil.createSampleSubscriptionCharge2(oSubscription.Id, pdEndSubscriptionDate.addMonths(-12)
																				, poProduct, poProductRatePlan
																			   );
		insert oSubscriptionProductCharge;

		return oSubscription;
	} // end of createEbcSubscription
    
        
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
    
    public static zqu__ProductRatePlan__c createEbcSampleProductRatePlan(String sName, Boolean triable, Product2 oProduct) {
        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c();
            prp.Name = sName;
            prp.zqu__Product__c = oProduct.Id;
            prp.zqu__ZuoraId__c = 'PRP' + (Math.random()*1000000000);
            prp.zqu__EffectiveStartDate__c = Date.today().addDays(-15);
            prp.zqu__EffectiveEndDate__c = Date.today().addDays(15);
            prp.IsTriable__c = triable?'Yes':'No';
        	prp.EBC_Cost_Per_Email__c = '0.001';
            
            return prp;
    }
    
    
     public static User createSampleGuestUserAndLogin() {
        return createSampleGuestUserAndLogin(IECConstants.Account_ClientType_ThirdParty);
    }
    
    public static User createSampleGuestUserAndLogin(String ClientType) {
        // insert account
        oAccount = IECTestUtil.createSampleAccount(ClientType);
        insert oAccount;

        isoCountry = new IATA_ISO_Country__c();
        isoCountry.ISO_Code__c='CT';
		isoCountry.Name='canadatest';
		isoCountry.Region__c = 'North-America';
		isoCountry.ISO_Code_Numeric__c = 560;
		insert isoCountry;
 
        // create Bill To contact info
        oContact = new Contact();
        oContact.RecordTypeId = IECUserManager.getContactRecordTypeForIEC();
        oContact.AccountId = oAccount.Id;
        oContact.OwnerId = IECUserManager.getIECContactOwnerId();
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
    
   
} // IECEBC_TestUtility class