/**  
  * Description: This class contains unit tests for the (GSS - Submission Calendar) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  *  - 20160104-sl: change the GDP_File_Description__c.Frequency option from Bi-Monthly to Semi-Monthly, note that some local variables still say BiMon 
  */
@isTest(SeeAllData=true)
public class vfIECGSSHist_tst {
    private static Product_Category__c oProductCategory;
    private static Product_Information__c oProductInfo;
    private static Product2 oProduct;
    private static zqu__ProductRatePlan__c oProductRatePlan;
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    private static Zuora__Subscription__c subscriptionDay;
    private static Zuora__Subscription__c subscriptionWeek;
    private static Zuora__Subscription__c subscriptionBiMon;
    private static Zuora__Subscription__c subscriptionMon;
    private static Zuora__SubscriptionProductCharge__c subscriptionChargeDay;
    private static Zuora__SubscriptionProductCharge__c subscriptionChargeWeek;
    private static Zuora__SubscriptionProductCharge__c subscriptionChargeBiMon;
    private static Zuora__SubscriptionProductCharge__c subscriptionChargeMon;
    private static GSS_Subscription_Detail__c gssDay;
    private static GSS_Subscription_Detail__c gssWeek;
    private static GSS_Subscription_Detail__c gssBiMon;
    private static GSS_Subscription_Detail__c gssMon;
    
    private static IECCustomer currentCustomer;
    
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
            
            if (iOption == 0) { // Daily
            	// create dummy subscription - Day
	            subscriptionDay = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs-Day', Date.today().addMonths(6));
	            subscriptionDay.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
	            insert subscriptionDay;
	            
	            // create dummy subscription charge
	            subscriptionChargeDay = IECTestUtil.createSampleSubscriptionCharge2(subscriptionDay.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
	            insert subscriptionChargeDay;
	            
	            GDP_File_Description__c fileDay = IECTestUtil.CreateSampleGDPFileDescription('D', 'Daily', IECConstants.ProductCategory_SF_GSS);
	            insert fileDay;
	            
	            gssDay = new GSS_Subscription_Detail__c (Name = 'Subs-Day', GDP_File_Description__c = fileDay.id);
	            insert gssDay;
	            
	            GDP_File_Delivery__c gdpFileDelDay = new GDP_File_Delivery__c (GSS_Subscription_Detail__c = gssDay.Id, File_Specification__c = fileDay.Id, Delivery_Date__c = Date.newInstance(2015, 11, 4), Status__c = 'Completed');
	            insert gdpFileDelDay;
            }
            else if (iOption == 1) { // Weekly
            	// create dummy subscription - Week
	            subscriptionWeek = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs-Week', Date.today().addMonths(6));
	            subscriptionWeek.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
	            insert subscriptionWeek;
	            
	            // create dummy subscription charge
	            subscriptionChargeWeek = IECTestUtil.createSampleSubscriptionCharge2(subscriptionWeek.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
	            insert subscriptionChargeWeek;
	            
	            GDP_File_Description__c fileWeek = IECTestUtil.CreateSampleGDPFileDescription('D', 'Weekly', IECConstants.ProductCategory_SF_GSS);
	            insert fileWeek;
	            
	            gssWeek = new GSS_Subscription_Detail__c (Name = 'Subs-Week', GDP_File_Description__c = fileWeek.id);
	            insert gssWeek;
	            
	            GDP_File_Delivery__c gdpFileDelWeek = new GDP_File_Delivery__c (GSS_Subscription_Detail__c = gssWeek.Id, File_Specification__c = fileWeek.Id, Delivery_Date__c = Date.newInstance(2015, 11, 4), Status__c = 'Failed');
	            insert gdpFileDelWeek;
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
				
	            gssBiMon = new GSS_Subscription_Detail__c (Name = 'Subs-BiMon', GDP_File_Description__c = fileBiMon.id);
	            insert gssBiMon;
            
	            GDP_File_Delivery__c gdpFileDelBiMon1 = new GDP_File_Delivery__c (GSS_Subscription_Detail__c = gssBiMon.Id, File_Specification__c = fileBiMon.Id, Delivery_Date__c = Date.newInstance(2015, 11, 4), Status__c = 'Completed');
	            insert gdpFileDelBiMon1;
	            
	            GDP_File_Delivery__c gdpFileDelBiMon2 = new GDP_File_Delivery__c (GSS_Subscription_Detail__c = gssBiMon.Id, File_Specification__c = fileBiMon.Id, Delivery_Date__c = Date.newInstance(2015, 11, 24), Status__c = 'Completed');
	            insert gdpFileDelBiMon2;
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
	            
	            gssMon = new GSS_Subscription_Detail__c (Name = 'Subs-Mon', GDP_File_Description__c = fileMon.id);
	            insert gssMon;
	            
	            GDP_File_Delivery__c gdpFileDelMon = new GDP_File_Delivery__c (GSS_Subscription_Detail__c = gssMon.Id, File_Specification__c = fileMon.Id, Delivery_Date__c = Date.newInstance(2015, 11, 4), Status__c = 'In Progress');
	            insert gdpFileDelMon;
            }
        
        System.debug('Unit Test: Finish: Init');
    }

    static testMethod void TestGSSHistDay() {
        System.debug('Unit Test: Start: TestGSSHistDay');

        //Set current page to GSSHist
        PageReference pgRef = Page.IECFDHist;
        pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
        pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs-Day'));
        Test.setCurrentPage(pgRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            
            Test.startTest();
                
            // setup data
            Init(0);

            // trigger the Product Access creation
            update subscriptionDay;
                
            Test.stopTest();

            //Instantiate Controller
            vfIECGSSHist pgCont = new vfIECGSSHist();
            pgCont.pageLoad();
            
            //Test 001: Make sure there is data to be displayed
            System.assertEquals(1, pgCont.lstSubmissionRecords.size(), 'One submission record must be found');
            System.assertEquals(null, pgCont.submissionObj, 'Selected submission must be null');
            
            //Test 002: Select the submission record
            pgCont.iSelectedSubmissionID = 0;
            pgCont.selectSubmission();
            
            System.assertNotEquals(null, pgCont.submissionObj);
            System.assertEquals(1, pgCont.submissionObj.FileCount);
            System.assertEquals('Daily', pgCont.submissionObj.Frequency);
            System.assertEquals(Date.newInstance(2015, 11, 3), pgCont.submissionObj.ReportingFrom);
            System.assertEquals(null, pgCont.submissionObj.ReportingTo);
            System.assertEquals('Completed', pgCont.submissionObj.Status);
        }
        System.debug('Unit Test: Finish: TestGSSHistDay');
    }

    static testMethod void TestGSSHistWeek() {
        System.debug('Unit Test: Start: TestGSSHistWeek');

        //Set current page to GSSHist
        PageReference pgRef = Page.IECFDHist;
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
            vfIECGSSHist pgCont = new vfIECGSSHist();
            pgCont.pageLoad();
            
            //Test 001: Make sure there is data to be displayed
            System.assertEquals(1, pgCont.lstSubmissionRecords.size(), 'One submission record must be found');
            System.assertEquals(null, pgCont.submissionObj, 'Selected submission must be null');
            
            //Test 002: Select the submission record
            pgCont.iSelectedSubmissionID = 0;
            pgCont.selectSubmission();
            
            System.assertNotEquals(null, pgCont.submissionObj);
            System.assertEquals(1, pgCont.submissionObj.FileCount);
            System.assertEquals('Weekly', pgCont.submissionObj.Frequency);
            System.assertEquals(Date.newInstance(2015, 10, 26), pgCont.submissionObj.ReportingFrom);
            System.assertEquals(Date.newInstance(2015, 11, 1), pgCont.submissionObj.ReportingTo);
            System.assertEquals('Failed', pgCont.submissionObj.Status);
        }
        System.debug('Unit Test: Finish: TestGSSHistWeek');
    }

    static testMethod void TestGSSHistBiMon() {
        System.debug('Unit Test: Start: TestGSSHistBiMon');

        //Set current page to GSSHist
        PageReference pgRef = Page.IECFDHist;
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
            vfIECGSSHist pgCont = new vfIECGSSHist();
            pgCont.pageLoad();
            
            //Test 001: Make sure there is data to be displayed
            System.assertEquals(2, pgCont.lstSubmissionRecords.size(), 'One submission record must be found');
            System.assertEquals(null, pgCont.submissionObj, 'Selected submission must be null');
            
            //Test 002: Select the 1st submission record
            pgCont.iSelectedSubmissionID = 0;
            pgCont.selectSubmission();
            
            System.assertNotEquals(null, pgCont.submissionObj);
            System.assertEquals(1, pgCont.submissionObj.FileCount);
            System.assertEquals('Semi-Monthly', pgCont.submissionObj.Frequency);
            System.assertEquals(Date.newInstance(2015, 11, 1), pgCont.submissionObj.ReportingFrom);
            System.assertEquals(Date.newInstance(2015, 11, 15), pgCont.submissionObj.ReportingTo);
            System.assertEquals('Completed', pgCont.submissionObj.Status);
            
            //Test 002: Select the 2nd submission record
            pgCont.iSelectedSubmissionID = 1;
            pgCont.selectSubmission();
            
            System.assertNotEquals(null, pgCont.submissionObj);
            System.assertEquals(1, pgCont.submissionObj.FileCount);
            System.assertEquals('Semi-Monthly', pgCont.submissionObj.Frequency);
            System.assertEquals(Date.newInstance(2015, 10, 16), pgCont.submissionObj.ReportingFrom);
            System.assertEquals(Date.newInstance(2015, 10, 31), pgCont.submissionObj.ReportingTo);
            System.assertEquals('Completed', pgCont.submissionObj.Status);
        }
        System.debug('Unit Test: Finish: TestGSSHistBiMon');
    }

    static testMethod void TestGSSHistMon() {
        System.debug('Unit Test: Start: TestGSSHistMon');

        //Set current page to GSSHist
        PageReference pgRef = Page.IECFDHist;
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
            vfIECGSSHist pgCont = new vfIECGSSHist();
            pgCont.pageLoad();
            
            //Test 001: Make sure there is data to be displayed
            System.assertEquals(1, pgCont.lstSubmissionRecords.size(), 'One submission record must be found');
            System.assertEquals(null, pgCont.submissionObj, 'Selected submission must be null');
            
            //Test 002: Select the submission record
            pgCont.iSelectedSubmissionID = 0;
            pgCont.selectSubmission();
            
            System.assertNotEquals(null, pgCont.submissionObj);
            System.assertEquals(1, pgCont.submissionObj.FileCount);
            System.assertEquals('Monthly', pgCont.submissionObj.Frequency);
            System.assertEquals(Date.newInstance(2015, 10, 1), pgCont.submissionObj.ReportingFrom);
            System.assertEquals(Date.newInstance(2015, 10, 31), pgCont.submissionObj.ReportingTo);
            System.assertEquals('In Progress', pgCont.submissionObj.Status);
        }
        System.debug('Unit Test: Finish: TestGSSHistMon');
    }

    static testMethod void TestGSSHist_ErrorsNoLogin() {
        System.debug('Unit Test: Start: TestGSSHist_ErrorsNoLogin');

        //Set current page to GSSHist
        PageReference pgRef = Page.IECFDHist;
        pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_GSS));
        pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs 01'));
        Test.setCurrentPage(pgRef);
        
        //Instantiate Controller
        vfIECGSSHist pgCont = new vfIECGSSHist();

        // Test 001: Accessing page as guest user
        pgCont.pageLoad();
        
        // Misc Coverage
        String sTest = pgCont.sApplicationTitleUpperCase;
        pgCont.sProductCode = IECConstants.ProductCategory_SF_MDP;
        sTest = pgCont.sApplicationTitleUpperCase;
        pgCont.sProductCode = '';
        sTest = pgCont.sApplicationTitleUpperCase;
        
        vfIECGSSHist.SubmissionRecord sr = new vfIECGSSHist.SubmissionRecord(1, Date.today());
        Date dtTest = sr.ReportingFrom;
        dtTest = sr.ReportingTo;

        System.debug('Unit Test: Finish: TestGSSHist_ErrorsNoLogin');
    }
}