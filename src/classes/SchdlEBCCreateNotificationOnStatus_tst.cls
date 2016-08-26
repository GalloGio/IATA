/**
 * Test class for SchdlEBCCreateNotificationOnStatus
 *
 * This is part of the eBroadcast feature
 * 
 * History: 
 *  - 20160823-sl: initial version
 * 
 *
 */
@isTest
private class SchdlEBCCreateNotificationOnStatus_tst {
	
	// ========================================================================
	// basic test: calling scheduled job, no data provided
	@isTest (SeeAllData=false)
	static void test01_BasicTestOnScheduleJob() {
		Test.startTest();
		
		// Set up scheduled job
		datetime nextScheduleTime = system.now().addMinutes(1);
		string minute = string.valueof(nextScheduleTime.minute());
		string second = string.valueof(nextScheduleTime.second ());
		string cronvalue = second + ' ' + minute + ' * * * ?' ;
		string jobName = 'SchdlEBCCreateNotificationOnStatus TEST ' + nextScheduleTime.format('hh:mm');
		system.schedule(jobName, cronvalue , new SchdlEBCCreateNotificationOnStatus());
		
		Test.stopTest();
		
		System.debug('Unit Test: Finish: SchdlEBCCreateNotificationOnStatus');
	} // test01_BasicTestOnScheduleJob
	
	
	// ========================================================================
	// basic test: calling batch job, no data provided
	@isTest (SeeAllData=false)
	static void test02_BasicTestOnBatchJob() {
		//prepareTestData();
		//createEbcData();
		//createUsers();
		
		/*
		System.assertNotEquals( 0, lUser.size(), 'number of newly created users should be > 0');
		System.assertEquals( lUser.size(), lContact.size(), 'number of newly created users and contacts should be the same');
		System.assertEquals( lContact.size(), lEbcPreference.size(), 'number of newly created contacts and EBC Preference should be the same');
		System.assertEquals( lContact.size(), lBillingAccount.size(), 'number of newly created contacts and Billing Accounts should be the same');
		System.assertNotEquals(null, IECEBC_Utility.ebcSetup.Id);
		*/
		
		Test.startTest();
		
		BtchEBCCreateNotificationOnStatus.callBatchEBCCreateNotification();
		
		Test.stopTest();
		
		System.debug('Unit Test: Finish: BtchEBCCreateAccountNotificationOnStatus');
	} // test02_BasicTestOnBatchJob
	
	
	// ========================================================================
	// basic test: calling batch job, with access to existing live data 
	@isTest (SeeAllData=true)	
	static void test03_BasicTestOnBatchJobExistingData() {
		System.assertNotEquals(null, IECEBC_Utility.ebcSetup.Id);
		
		Test.startTest();
		
		BtchEBCCreateNotificationOnStatus.callBatchEBCCreateNotification();
		
		Test.stopTest();
		
		System.debug('Unit Test: Finish: test03_BasicTestOnBatchJobExistingData');
	} // test03_BasicTestOnBatchJobExistingData
	
	
	
	
	// ========================================================================
	// test data
	// the following will only be used if we want to create out test data
	
	private static Product_Category__c oEbcProductCategory;
	private static zqu__ZProduct__c oEbcProductMember;
	private static zqu__ZProduct__c oEbcProductNonMember;
	private static zqu__ZProduct__c oEbcProductAddOnStorage;
	private static zqu__ZProduct__c oEbcProductAddOnReporting;
	private static zqu__ZProduct__c oEbcProductEmailBlock;
	private static List<Product_Information__c> lEbcProductInfo;
	
	private static List<zqu__ProductRatePlan__c> lEbcProductRatePlanMember;
	private static List<zqu__ProductRatePlan__c> lEbcProductRatePlanNonMember;
	private static zqu__ProductRatePlan__c oEbcProductRatePlanAddOnStorage;
	private static zqu__ProductRatePlan__c oEbcProductRatePlanAddOnReporting;
	private static List<zqu__ProductRatePlan__c> lEbcProductRatePlanEmailBlock;
	
	private static List<zqu__ProductRatePlanCharge__c> lEbcProductRatePlanCharge;
	private static EBC_Setup__c oEbcSetup;
	
	// ================================================================================
	//@testSetup
	private static void prepareTestData()
	{
		createEbcData();
		
		//createUsers();
		// create Users, Billing Account, EBC Preferences 
		// create ebc subscriptions, subscription charge, product rate plan charge
		
		// cases: 
		// no ebc preferences, no subscription (become pay as you go), prepaid subscription valid, prepaid subscription expired (become pay as you go)
		
		
		// validation: check on the newly created records
	} // prepareTestData
	
	// ========================================================================
	// create all EBC system/public configuration records
	// EBC_Setup, Product, Product Rate Plan, Product Rate Plan Charge 
	private static void createEbcData()
	{
		oEbcProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_EBROADCAST, true);
		insert oEbcProductCategory;
		
		// create ZProducts
		oEbcProductMember = IECTestUtil.CreateSampleProduct('eBroadcast for Non-Members');
		//oEbcProductMember.ProductAudience__c = 'Member Airline';
		//oEbcProductMember.zqu__Category__c = 'Base Products';
		oEbcProductMember.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductMember.zqu__Description__c = 'eBroadcast for IATA Member Airlines';
		
		oEbcProductNonMember = IECTestUtil.CreateSampleProduct('eBroadcast for Non-Members');
		//oEbcProductNonMember.ProductAudience__c = 'Non-Member Single';
		//oEbcProductNonMember.zqu__Category__c = 'Base Products';
		oEbcProductNonMember.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductNonMember.zqu__Description__c = 'eBroadcast for IATA Member Airlines';
		
		oEbcProductAddOnStorage = IECTestUtil.CreateSampleProduct('Additional Storage');
		//oEbcProductAddOnStorage.ProductAudience__c = null;
		//oEbcProductAddOnStorage.zqu__Category__c = 'Add On Services';
		oEbcProductAddOnStorage.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductAddOnStorage.zqu__Description__c = 'eBroadcast add on';
		
		oEbcProductAddOnReporting = IECTestUtil.CreateSampleProduct('Enhanced Reporting');
		//oEbcProductAddOnReporting.ProductAudience__c = null;
		//oEbcProductAddOnReporting.zqu__Category__c = 'Add On Services';
		oEbcProductAddOnReporting.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductAddOnReporting.zqu__Description__c = 'eBroadcast add on';
		
		oEbcProductEmailBlock = IECTestUtil.CreateSampleProduct('Email Block');
		//oEbcProductEmailBlock.ProductAudience__c = null;
		//oEbcProductEmailBlock.zqu__Category__c = 'Email Blocks';
		oEbcProductEmailBlock.ProductCategory__c = IECConstants.ProductCategory_SF_EBROADCAST; // option undefined yet
		oEbcProductEmailBlock.zqu__Description__c = 'eBroadcast Email Blocks';
		
		List<zqu__ZProduct__c> lEbcProduct = new List<zqu__ZProduct__c>{oEbcProductMember, oEbcProductNonMember
			, oEbcProductAddOnStorage, oEbcProductAddOnReporting, oEbcProductEmailBlock};
		insert lEbcProduct;
		
		//
		lEbcProductInfo = new List<Product_Information__c>();
		for (zqu__ZProduct__c prd : lEbcProduct) 
		{
			Product_Information__c oProdInfo = IECTestUtil.CreateSampleProductInfo( prd.Name, oEbcProductCategory, prd);
			oProdInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
			lEbcProductInfo.add(oProdInfo);
		}
		insert lEbcProductInfo;
		
		// create EBC Rate Plans
		lEbcProductRatePlanMember= new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlanMember.add(IECTestUtil.CreateSampleProductRatePlan('Starter Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(IECTestUtil.CreateSampleProductRatePlan('Professional Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(IECTestUtil.CreateSampleProductRatePlan('Enterprise Edition M', false, oEbcProductMember));
		lEbcProductRatePlanMember.add(IECTestUtil.CreateSampleProductRatePlan('Premium Edition M', false, oEbcProductMember));
		
		lEbcProductRatePlanNonMember = new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlanNonMember.add(IECTestUtil.CreateSampleProductRatePlan('Starter Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(IECTestUtil.CreateSampleProductRatePlan('Professional Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(IECTestUtil.CreateSampleProductRatePlan('Enterprise Edition N', false, oEbcProductNonMember));
		lEbcProductRatePlanNonMember.add(IECTestUtil.CreateSampleProductRatePlan('Premium Edition N', false, oEbcProductNonMember));
		
		oEbcProductRatePlanAddOnStorage = IECTestUtil.CreateSampleProductRatePlan('Extra Storage', false, oEbcProductAddOnStorage);
		oEbcProductRatePlanAddOnReporting = IECTestUtil.CreateSampleProductRatePlan('Extra Storage', false, oEbcProductAddOnReporting);
		
		lEbcProductRatePlanEmailBlock = new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlanEmailBlock.add(IECTestUtil.CreateSampleProductRatePlan('Email Block 1', false, oEbcProductEmailBlock));
		lEbcProductRatePlanEmailBlock.add(IECTestUtil.CreateSampleProductRatePlan('Email Block 2', false, oEbcProductEmailBlock));
		lEbcProductRatePlanEmailBlock.add(IECTestUtil.CreateSampleProductRatePlan('Email Block 3', false, oEbcProductEmailBlock));
		
		List<zqu__ProductRatePlan__c> lEbcProductRatePlan = new List<zqu__ProductRatePlan__c>();
		lEbcProductRatePlan.addAll(lEbcProductRatePlanMember);
		lEbcProductRatePlan.addAll(lEbcProductRatePlanNonMember);
		lEbcProductRatePlan.add(oEbcProductRatePlanAddOnStorage);
		lEbcProductRatePlan.add(oEbcProductRatePlanAddOnReporting);
		lEbcProductRatePlan.addAll(lEbcProductRatePlanEmailBlock);
		
		insert lEbcProductRatePlan;
		
		// Product Rate Plan Charges
		lEbcProductRatePlanCharge = new List<zqu__ProductRatePlanCharge__c>();
		for (zqu__ProductRatePlan__c oPrp : lEbcProductRatePlan)
		{
			zqu__ProductRatePlanCharge__c oPrpCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oPrp, 'CHARGETEST', 1);
			lEbcProductRatePlanCharge.add(oPrpCharge);
		}
		insert lEbcProductRatePlanCharge;
		
		
		// create EBC Set up
		oEbcSetup = new EBC_Setup__c( Name='Default for Test'
					, Member_Prepaid_Product_Rate_Plan_01__c = lEbcProductRatePlanMember[0].Id
					, Member_Prepaid_Product_Rate_Plan_02__c = lEbcProductRatePlanMember[1].Id
					, Member_Prepaid_Product_Rate_Plan_03__c = lEbcProductRatePlanMember[2].Id
					, Member_Prepaid_Product_Rate_Plan_04__c = lEbcProductRatePlanMember[3].Id
					, Non_Member_Prepaid_Product_Rate_Plan_01__c = lEbcProductRatePlanNonMember[0].Id
					, Non_Member_Prepaid_Product_Rate_Plan_02__c = lEbcProductRatePlanNonMember[1].Id
					, Non_Member_Prepaid_Product_Rate_Plan_03__c = lEbcProductRatePlanNonMember[2].Id
					, Non_Member_Prepaid_Product_Rate_Plan_04__c = lEbcProductRatePlanNonMember[3].Id
					
					, Enhanced_Reporting_Product_Rate_Plan__c = oEbcProductRatePlanAddOnReporting.Id
					, Storage_Product_Rate_Plan__c = oEbcProductRatePlanAddOnStorage.Id
					
					, Member_Email_Block_Product__c = oEbcProductEmailBlock.Id
					//, Non_Member_Email_Block_Product__c
					, Maximum_File_Size_Upload__c = 1
					
					, Default_Storage_Capacity__c = 76
					, Default_Cost_per_E_mail__c  = 0.53
					//, E_Commerce_Base_Url__c = 'https://3b-customer-portal-iata.cs87.force.com/iec'
				);
		insert oEbcSetup;
		
	} // end of createEbcData
	
	
	private static List<User> lUser;
	private static List<Contact> lContact;
	private static List<Account> lAccount;
	private static List<Zuora__CustomerAccount__c> lBillingAccount;
	private static List<EBC_Preference__c> lEbcPreference;
	
	// ========================================================================
	// create users, subscriptions, subscription charge etc
	private static void createUsers()
	{
		// create Users, Billing Account, EBC Preferences 
		lUser = new List<User>();
		lContact = new List<Contact>();
		lAccount = new List<Account>();
		lBillingAccount = new List<Zuora__CustomerAccount__c>();
		
		// create users 
		
		List<User> lNewUser = new List<User>();
		lNewUser.add(IECTestUtil.createSampleGuestUserAndLogin());
		lNewUser.add(IECTestUtil.createSampleGuestUserAndLogin());
		lNewUser.add(IECTestUtil.createSampleGuestUserAndLogin());
		lNewUser.add(IECTestUtil.createSampleGuestUserAndLogin());
		//insert lnewUser;
		
		System.assertNotEquals(null, lNewUser[0].Id, 'User.Id should not be null for user:'+ lNewUser[0]);
		
		Set<Id> sUserId = new Set<Id>();
		for (User usr: lNewUser) 
		{
			sUserId.add(usr.Id);
		}
		
		lUser = [select Id, Name
				, ContactId
				, Contact.Id
				, Contact.Name
				//, Contact.FirstName
				, Contact.Email
				, Contact.AccountId
				, Contact.Account.Id
				, Contact.Account.Name
				from User
				where Id in : sUserId];
		
		Contact oContact; // temp contact
		Account oAccount; // temp Account
		Zuora__CustomerAccount__c oBillingAccount;
		lEbcPreference = new list<EBC_Preference__c>();
		for (User usr : lUser)
		{
			// get related Contact and Account recs
			if (usr.ContactId != null) {
				//oContact = new Contact( Id=usr.ContactId, Name = usr.Contact.Name, AccountId=usr.Contact.AccountId );
				oContact = usr.Contact;
				lContact.add( oContact);
				
				if (usr.Contact.AccountId != null)
				{
					//oAccount = new Account(Id = u.Contact.AccountId, Name=usr.Contact.Account.Name);
					oAccount = usr.Contact.Account;
					lAccount.add(oAccount);
					
					oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
					oBillingAccount.eBroadcast_Product_Access__c = true; 
					oBillingAccount.Zuora__Status__c = 'Active';
					lBillingAccount.add(oBillingAccount);
					
					lEbcPreference.add( new EBC_Preference__c(Name = usr.Contact.Name
								, PrimaryContact_Email__c = usr.Contact.Email
								, Notify_On_Send__c = true
								//, Default_From_Name__c = usr.Contact.Name
							));
				}
			}
		} // end for
		insert lBillingAccount;
		
		// complete the EBC_Preference list
		for (Integer i=0;i<lEbcPreference.size();i++) 
		{
			lEbcPreference[i].Billing_Account__c = lBillingAccount[i].Id;
		}
		insert lEbcPreference;
	} // create Users

	// ================================================================================
	// create ebc subscriptions, subscription charge
	private static void createSubscriptionData()
	{
		
	} // end of createSubscriptionData
} // SchdlEBCCreateNotificationOnStatus_tst