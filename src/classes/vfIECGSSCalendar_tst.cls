/**  
  * Description: This class contains unit tests for the (GSS - Submission Calendar) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  *  - 20160217-sl: add dTodayPrivate to store dToday internally and allowing default value, change the test values for Semi-Monthly case (BiMon).
  *
  */
@isTest(SeeAllData=true)
public class vfIECGSSCalendar_tst {
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Zuora__Subscription__c subscriptionWeek;
	private static Zuora__Subscription__c subscriptionBiMon;
	private static Zuora__Subscription__c subscriptionMon;
	private static Zuora__SubscriptionProductCharge__c subscriptionChargeWeek;
	private static Zuora__SubscriptionProductCharge__c subscriptionChargeBiMon;
	private static Zuora__SubscriptionProductCharge__c subscriptionChargeMon;
	private static GSS_Subscription_Detail__c gssWeek;
	private static GSS_Subscription_Detail__c gssBiMon;
	private static GSS_Subscription_Detail__c gssMon;
	
	private static IECCustomer currentCustomer;
	private static Date dTodayPrivate; // use this to store dToday internally
	public static Date dToday {
		get{
			if (dTodayPrivate == null) {
				dTodayPrivate = Date.today();
			}
			return dTodayPrivate;
		}
		set{
			dTodayPrivate = value;
		}
	}
	
	static void Init(integer iOption) {
		System.debug('Unit Test: Start: Init');
		oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_GSS, true);
		insert oProductCategory;
		
		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		insert oProduct;
		
		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;
		
		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', false, oProduct);
		insert oProductRatePlan;
		
		oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
		insert oProductRatePlanCharge;
		
		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
		insert oProductRatePlanInfo;
		
		currentCustomer = IECCustomer.getCurrentIECCustomer();
		
		if (iOption == 1) { // Weekly
			// create dummy subscription - Week
			subscriptionWeek = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs-Week', Date.today().addMonths(6));
			subscriptionWeek.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
			insert subscriptionWeek;
			
			// create dummy subscription charge
			subscriptionChargeWeek = IECTestUtil.createSampleSubscriptionCharge2(subscriptionWeek.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
			insert subscriptionChargeWeek;
			
			GDP_File_Description__c fileWeek = IECTestUtil.CreateSampleGDPFileDescription('D', 'Weekly', IECConstants.ProductCategory_SF_GSS);
			insert fileWeek;
			
			gssWeek = new GSS_Subscription_Detail__c (Name = 'Subs-Week', GDP_File_Description__c = fileWeek.Id);
			insert gssWeek;
		}
		else if (iOption == 2) { // Semi-Monthly
			// create dummy subscription - BiMonthly
			subscriptionBiMon = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs-BiMon', Date.today().addMonths(6));
			subscriptionBiMon.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
			insert subscriptionBiMon;
			
			// create dummy subscription charge
			subscriptionChargeBiMon = IECTestUtil.createSampleSubscriptionCharge2(subscriptionBiMon.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
			insert subscriptionChargeBiMon;
			
			GDP_File_Description__c fileBiMon = IECTestUtil.CreateSampleGDPFileDescription('P', 'Semi-Monthly', IECConstants.ProductCategory_SF_GSS);
			insert fileBiMon;
			
			gssBiMon = new GSS_Subscription_Detail__c (Name = 'Subs-BiMon', GDP_File_Description__c = fileBiMon.Id);
			insert gssBiMon;
		}
		else if (iOption == 3) { // Monthly
			// create dummy subscription - Monthly
			subscriptionMon = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs-Mon', Date.today().addMonths(6));
			subscriptionMon.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
			insert subscriptionMon;
			
			// create dummy subscription charge
			subscriptionChargeMon = IECTestUtil.createSampleSubscriptionCharge2(subscriptionMon.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
			insert subscriptionChargeMon;
			
			GDP_File_Description__c fileMon = IECTestUtil.CreateSampleGDPFileDescription('T', 'Monthly', IECConstants.ProductCategory_SF_GSS);
			insert fileMon;
			
			gssMon = new GSS_Subscription_Detail__c (Name = 'Subs-Mon', GDP_File_Description__c = fileMon.Id);
			insert gssMon;
		}
		
		System.debug('Unit Test: Finish: Init');
	}
	
	static testMethod void TestGSSCalendarWeek() {
		System.debug('Unit Test: Start: TestGSSCalendarWeek');
		
		//Set current page to GSSCalendar
		PageReference pgRef = Page.IECFDCalendar;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs-Week'));
		Test.setCurrentPage(pgRef);
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			
			Test.startTest();
				
			// setup data
			Init(1);
			
			// trigger the Product Access creation
			update subscriptionWeek;
				
			Test.stopTest();
			
			//Instantiate Controller
			vfIECGSSCalendar pgCont = new vfIECGSSCalendar();
			pgCont.pageLoad();
			
			//Test 001: Set calendar settings while today is before submission date
			
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 24); // Tuesday
			gssWeek.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 11, 25); // Wednesday
			update gssWeek;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sWeeklyOption = 'Monday';
			pgCont.sBiMonthlyOption1 = '8';
			pgCont.sBiMonthlyOption2 = '20';
			pgCont.sMonthlyOption = '9';
			
			// Test the getters function of variables
			system.assertEquals('Monday', pgCont.sWeeklyOption);
			system.assertEquals('8', pgCont.sBiMonthlyOption1);
			system.assertEquals('20', pgCont.sBiMonthlyOption2);
			system.assertEquals('9', pgCont.sMonthlyOption);
			
			pgCont.onClickSave();
			
			//Query GSS Settings
			List<GSS_Subscription_Detail__c> lstGSSSetting =
				[SELECT Calendar_Weekly_Option__c
					, Calendar_Semi_Monthly_First_Option__c
					, Calendar_Semi_Monthly_Second_Option__c
					, Calendar_Monthly_Option__c
					, Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-Week'];
			
			system.assert(!lstGSSSetting.isEmpty(), 'GSS Subscription Detail record must exist');
			system.assertEquals('Monday', lstGSSSetting.get(0).Calendar_Weekly_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_Semi_Monthly_First_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_Semi_Monthly_Second_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_Monthly_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(Date.newInstance(2015, 11, 25), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission is not changed');
			system.assertEquals(Date.newInstance(2015, 11, 30), lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date should be Monday next week');
			
			//Test 002: Set calendar settings while today is after submission day takes place
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 26); // Thursday
			gssWeek.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 11, 25); // Wednesday
			gssWeek.Calendar_New_Submission_Effective_Date__c = null;
			update gssWeek;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sWeeklyOption = 'Monday';
			pgCont.onClickSave();
			
			//Query GSS Settings
			lstGSSSetting =
				[SELECT Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-Week'];
			
			system.assertEquals(Date.newInstance(2015, 11, 30), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission must be changed to next week monday');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date should be empty');
		}
		System.debug('Unit Test: Finish: TestGSSCalendarWeek');
	}
	
	// test for Semi-Monthly case
	static testMethod void TestGSSCalendarBiMon() {
		System.debug('Unit Test: Start: TestGSSCalendarBiMon');
		
		//Set current page to GSSCalendar
		PageReference pgRef = Page.IECFDCalendar;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs-BiMon'));
		Test.setCurrentPage(pgRef);
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			
			Test.startTest();
			
			// setup data
			Init(2);
			
			// trigger the Product Access creation
			update subscriptionBiMon;
			
			Test.stopTest();
			
			//Instantiate Controller
			vfIECGSSCalendar pgCont = new vfIECGSSCalendar();
			pgCont.pageLoad();
			
			//Test 001: Set calendar settings while today is between the two submission windows
			
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 11);
			gssBiMon.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 11, 21);
			update gssBiMon;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sWeeklyOption = 'Monday';
			pgCont.sBiMonthlyOption1 = '8';
			pgCont.sBiMonthlyOption2 = '20';
			pgCont.sMonthlyOption = '9';
			
			// Test the getters function of variables
			system.assertEquals('Monday', pgCont.sWeeklyOption);
			system.assertEquals('8', pgCont.sBiMonthlyOption1);
			system.assertEquals('20', pgCont.sBiMonthlyOption2);
			system.assertEquals('9', pgCont.sMonthlyOption);
			
			pgCont.onClickSave();
			
			//Query GSS Settings
			List<GSS_Subscription_Detail__c> lstGSSSetting =
				[SELECT Calendar_Weekly_Option__c
					, Calendar_Semi_Monthly_First_Option__c
					, Calendar_Semi_Monthly_Second_Option__c
					, Calendar_Monthly_Option__c
					, Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-BiMon'];
			
			system.assert(!lstGSSSetting.isEmpty(), 'GSS Subscription Detail record must exist');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_Weekly_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('8', lstGSSSetting.get(0).Calendar_Semi_Monthly_First_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('20', lstGSSSetting.get(0).Calendar_Semi_Monthly_Second_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_Monthly_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(Date.newInstance(2015, 11, 20), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission is changed to the second half of the month with new date of Nov 20');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date must be empty');
			
			//Test 002: Set calendar settings while today is in the first half of the month and BEFORE submission takes place in first half of month
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 3);
			gssBiMon.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 11, 7);
			gssBiMon.Calendar_New_Submission_Effective_Date__c = null;
			update gssBiMon;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sBiMonthlyOption1 = '8';
			pgCont.sBiMonthlyOption2 = '20';
			pgCont.onClickSave();
			
			//Query GSS Settings
			lstGSSSetting =
				[SELECT Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-BiMon'];
			
			system.assertEquals(Date.newInstance(2015, 11, 7), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission must remain on Nov 7');
			system.assertEquals(Date.newInstance(2015, 11, 20), lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date should be Nov 20');
			
			//Test 003: Set calendar settings while today is in the first half of the month and AFTER submission takes place in first half of month
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 8);
			gssBiMon.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 11, 7);
			gssBiMon.Calendar_New_Submission_Effective_Date__c = null;
			update gssBiMon;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sBiMonthlyOption1 = '8';
			pgCont.sBiMonthlyOption2 = '20';
			pgCont.onClickSave();
			
			//Query GSS Settings
			lstGSSSetting =
				[SELECT Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-BiMon'];
			
			system.assertEquals(Date.newInstance(2015, 11, 20), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission must change to Nov 20');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date should be empty');
			
			//Test 004: Set calendar settings while today is in the second half of the month and BEFORE submission takes place in second half of month
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 16);
			gssBiMon.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 11, 18);
			gssBiMon.Calendar_New_Submission_Effective_Date__c = null;
			update gssBiMon;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sBiMonthlyOption1 = '8';
			pgCont.sBiMonthlyOption2 = '20';
			pgCont.onClickSave();
			
			//Query GSS Settings
			lstGSSSetting =
				[SELECT Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-BiMon'];
			
			system.assertEquals(Date.newInstance(2015, 11, 18), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission must remain on Nov 18');
			system.assertEquals(Date.newInstance(2015, 12, 8), lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date should be Dec 8');
			
			//Test 005: Set calendar settings while today is in the second half of the month and AFTER submission takes place in second half of month
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 19);
			//gssBiMon.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 11, 18);
			gssBiMon.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 12, 1); // with the new initialization, Calendar_Next_Submission_Date will not be past in the controller.
			gssBiMon.Calendar_New_Submission_Effective_Date__c = null;
			update gssBiMon;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sBiMonthlyOption1 = '8';
			pgCont.sBiMonthlyOption2 = '20';
			pgCont.onClickSave();
			
			//Query GSS Settings
			lstGSSSetting =
				[SELECT Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-BiMon'];
			
			system.assertEquals(Date.newInstance(2015, 12, 8), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission must change to Dec 8');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date should be empty');
		}
		System.debug('Unit Test: Finish: TestGSSCalendarBiMon');
	}
	
	static testMethod void TestGSSCalendarMon() {
		System.debug('Unit Test: Start: TestGSSCalendarMon');
		
		//Set current page to GSSCalendar
		PageReference pgRef = Page.IECFDCalendar;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs-Mon'));
		Test.setCurrentPage(pgRef);
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			
			Test.startTest();
				
			// setup data
			Init(3);
			
			// trigger the Product Access creation
			update subscriptionMon;
			
			Test.stopTest();
			
			//Instantiate Controller
			vfIECGSSCalendar pgCont = new vfIECGSSCalendar();
			pgCont.pageLoad();
			
			//Test 001: Set calendar settings while today is same month as submission date
			
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 5);
			gssMon.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 11, 7);
			update gssMon;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sWeeklyOption = 'Monday';
			pgCont.sBiMonthlyOption1 = '8';
			pgCont.sBiMonthlyOption2 = '20';
			pgCont.sMonthlyOption = '9';
			
			// Test the getters function of variables
			system.assertEquals('Monday', pgCont.sWeeklyOption);
			system.assertEquals('8', pgCont.sBiMonthlyOption1);
			system.assertEquals('20', pgCont.sBiMonthlyOption2);
			system.assertEquals('9', pgCont.sMonthlyOption);
			
			pgCont.onClickSave();
			
			//Query GSS Settings
			List<GSS_Subscription_Detail__c> lstGSSSetting =
				[SELECT Calendar_Weekly_Option__c
					, Calendar_Semi_Monthly_First_Option__c
					, Calendar_Semi_Monthly_Second_Option__c
					, Calendar_Monthly_Option__c
					, Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-Mon'];
			
			system.assert(!lstGSSSetting.isEmpty(), 'GSS Subscription Detail record must exist');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_Weekly_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_Semi_Monthly_First_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_Semi_Monthly_Second_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals('9', lstGSSSetting.get(0).Calendar_Monthly_Option__c, 'Submission Calendar setting must be updated in the GSS Subscription Detail table');
			system.assertEquals(Date.newInstance(2015, 11, 7), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission is not changed');
			system.assertEquals(Date.newInstance(2015, 12, 9), lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date should be Dec 9');
			
			//Test 002: Set calendar settings while today is after submission day takes place
			// Initialize previous submission dates
			dToday = Date.newInstance(2015, 11, 26);
			gssMon.Calendar_Next_Submission_Date__c = Date.newInstance(2015, 12, 7);
			gssMon.Calendar_New_Submission_Effective_Date__c = null;
			update gssMon;
			pgCont.ctrSubsInfo.loadFileSubscriptionDetails();
			
			pgCont.sMonthlyOption = '9';
			pgCont.onClickSave();
			
			//Query GSS Settings
			lstGSSSetting =
				[SELECT Calendar_Next_Submission_Date__c
					, Calendar_New_Submission_Effective_Date__c
				FROM GSS_Subscription_Detail__c WHERE Name = 'Subs-Mon'];
			
			system.assertEquals(Date.newInstance(2015, 12, 9), lstGSSSetting.get(0).Calendar_Next_Submission_Date__c, 'Existing submission must be changed to Dec 9');
			system.assertEquals(null, lstGSSSetting.get(0).Calendar_New_Submission_Effective_Date__c, 'New submission date should be empty');
		}
		System.debug('Unit Test: Finish: TestGSSCalendarMon');
	}

	static testMethod void TestGSSCalendar_ErrorsNoLogin() {
		System.debug('Unit Test: Start: TestGSSCalendar_ErrorsNoLogin');
		
		//Set current page to GSSCalendar
		PageReference pgRef = Page.IECFDCalendar;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs 01'));
		Test.setCurrentPage(pgRef);
		
		//Instantiate Controller
		vfIECGSSCalendar pgCont = new vfIECGSSCalendar();
		
		// Test 001: Accessing page as guest user
		pgCont.pageLoad();
		
		System.debug('Unit Test: Finish: TestGSSCalendar_ErrorsNoLogin');
	}
	
	static testMethod void TestGSSCalendar_ErrorsWeek() {
		System.debug('Unit Test: Start: TestGSSCalendar_ErrorsWeek');
		
		//Set current page to GSSCalendar
		PageReference pgRef = Page.IECFDCalendar;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs-Week'));
		Test.setCurrentPage(pgRef);
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			
			Test.startTest();
				
			// setup data
			Init(1);
			
			// trigger the Product Access creation
			update subscriptionWeek;
				
			Test.stopTest();
			
			//Instantiate Controller
			vfIECGSSCalendar pgCont = new vfIECGSSCalendar();
			pgCont.pageLoad();
			
			//Test 001: Saving while no selection is made
			pgCont.sWeeklyOption = null;
			pgCont.sBiMonthlyOption1 = null;
			pgCont.sBiMonthlyOption2 = null;
			pgCont.sMonthlyOption = null;
			
			pgCont.onClickSave();
			
			// Misc Coverage
			pgCont.onClickEdit();
			pgCont.onClickCancel();
			
			String sTest = pgCont.sApplicationTitleUpperCase;
			pgCont.sProductCode = IECConstants.ProductCategory_SF_MDP;
			sTest = pgCont.sApplicationTitleUpperCase;
			pgCont.sProductCode = '';
			sTest = pgCont.sApplicationTitleUpperCase;
			
			Integer iTest = pgCont.getDayNumberFromWeekDay('Friday');
			iTest = pgCont.getDayNumberFromWeekDay('Saturday');
			iTest = pgCont.getDayNumberFromWeekDay('Sunday');
			iTest = pgCont.getDayNumberFromWeekDay('Test');
		}
		System.debug('Unit Test: Finish: TestGSSCalendar_ErrorsWeek');
	}

	static testMethod void TestGSSCalendar_ErrorsBiMon() {
		System.debug('Unit Test: Start: TestGSSCalendar_ErrorsBiMon');
		
		//Set current page to GSSCalendar
		PageReference pgRef = Page.IECFDCalendar;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs-BiMon'));
		Test.setCurrentPage(pgRef);
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			
			Test.startTest();
			
			// setup data
			Init(2);
			
			// trigger the Product Access creation
			update subscriptionBiMon;
			
			Test.stopTest();
			
			//Instantiate Controller
			vfIECGSSCalendar pgCont = new vfIECGSSCalendar();
			pgCont.pageLoad();
			
			//Test 001: Saving while no selection is made
			pgCont.sWeeklyOption = null;
			pgCont.sBiMonthlyOption1 = null;
			pgCont.sBiMonthlyOption2 = null;
			pgCont.sMonthlyOption = null;
			
			pgCont.onClickSave();
		}
		System.debug('Unit Test: Finish: TestGSSCalendar_ErrorsBiMon');
	}

	static testMethod void TestGSSCalendar_ErrorsMon() {
		System.debug('Unit Test: Start: TestGSSCalendar_ErrorsMon');
		
		//Set current page to GSSCalendar
		PageReference pgRef = Page.IECFDCalendar;
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
		pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs-Mon'));
		Test.setCurrentPage(pgRef);
		
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			
			Test.startTest();
				
			// setup data
			Init(3);
			
			// trigger the Product Access creation
			update subscriptionMon;
				
			Test.stopTest();
			
			//Instantiate Controller
			vfIECGSSCalendar pgCont = new vfIECGSSCalendar();
			pgCont.pageLoad();
			
			//Test 001: Saving while no selection is made
			pgCont.sWeeklyOption = null;
			pgCont.sBiMonthlyOption1 = null;
			pgCont.sBiMonthlyOption2 = null;
			pgCont.sMonthlyOption = null;
			
			pgCont.onClickSave();
		}
		System.debug('Unit Test: Finish: TestGSSCalendar_ErrorsMon');
	}
}