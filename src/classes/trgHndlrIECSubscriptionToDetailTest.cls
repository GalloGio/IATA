/**
 * This test class mainly test trgHndlrIECSubscriptionToDetail class
 * In addition, this test class also cover the trgHndlrIECGssSubscriptionDetail class
 *   and trgIECGssSubscriptionDetail_BI_BU trigger
 *
 * Author: Sonny Leman
 * Change log:
 *   2015-12-23: created
 *
 */
@isTest
private class trgHndlrIECSubscriptionToDetailTest {

	private static Account oAccount;
	private static Contact oContact;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static User usr;
	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product2 oProduct;
	private static zqu__ProductRatePlan__c oProductRatePlan1;
	private static zqu__ProductRatePlan__c oProductRatePlan2;
	private static zqu__ProductRatePlan__c oProductRatePlan3;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge1;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge2;
	private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge3;
	/*
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo1;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo2;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo3;
	*/
	private static Zuora__Subscription__c subscription;
	private static Zuora__SubscriptionProductCharge__c subscriptionCharge;

	private static final double QTY = 42.0; // subscription quantity

	private static GDP_File_Description__c fileDescriptionReference;
	private static GDP_File_Description__c fileDescription1;
	private static GDP_File_Description__c fileDescription2;
	private static GDP_File_Description__c fileDescription3;
	private static GDP_File_Description__c fileDescription4;


	// ========================================================================
	// core data  preparation
	private static void dataPreparation() {
		usr = IECTestUtil.createSampleGuestUserAndLogin();

		oContact = [Select Id, Name, AccountId from Contact where Id = :usr.ContactId limit 1];

		oAccount = [Select Id, Name from Account where Id = :oContact.AccountId limit 1];

		oBillingAccount = IECTestUtil.createSampleBillingAccount(oAccount, oContact);
		insert oBillingAccount;

		// --------------------------------------------------------------------
		// create zuora product
		oProduct = IECTestUtil.CreateSampleProduct2('Product1');
		oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
		oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
		insert oProduct;

		// --------------------------------------------------------------------
		// create zuora rate plan
		oProductRatePlan1 = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, oProduct);
		oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 2', false, oProduct);
		oProductRatePlan3 = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 3', false, oProduct);
		List<zqu__ProductRatePlan__c> productRatePlanList = new List<zqu__ProductRatePlan__c> {oProductRatePlan1, oProductRatePlan2, oProductRatePlan3};
		insert productRatePlanList;

		// --------------------------------------------------------------------
		// create dummy Zuora rate plan oProductRatePlanCharge
		oProductRatePlanCharge1 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan1, 'CHARGETEST', 42);
		oProductRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan2, 'CHARGETEST', 84);
		oProductRatePlanCharge3 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan3, 'CHARGETEST', 0);
		List<zqu__ProductRatePlanCharge__c> productRatePlanChargeList = new List<zqu__ProductRatePlanCharge__c> {oProductRatePlanCharge1,oProductRatePlanCharge2,oProductRatePlanCharge3};
		insert productRatePlanChargeList;

	} // end of dataPreparation




	// ========================================================================
	static List<GDP_File_Description__c> generateFileDescriptionRecords()
	{
		//Create the reference File Description
		fileDescriptionReference = new GDP_File_Description__c(
			File_Format__c='TXT',
			Frequency__c='Monthly',
			Reference__c=null,
			Class__c='',
			Magnitude__c='Master',
			Field_Label__c='',
			Description__c='Test Reference File description',
			File_Naming_Convention__c='Name'
			);
		insert fileDescriptionReference;

		//Create a file specification with file field desctiption (for GetFileSpecification)
		fileDescription1 = new GDP_File_Description__c(
			File_Format__c='TXT',
			Frequency__c='Monthly',
			Field_Label__c='',
			Reference__c = fileDescriptionReference.id,
			Class__c='',
			Magnitude__c='Master',
			Description__c='File Description Child Master',
			File_Naming_Convention__c='Name'
			);

		fileDescription2 = new GDP_File_Description__c(
			File_Format__c='TXT',
			Frequency__c='Semi-Monthly',
			Field_Label__c='',
			Reference__c=fileDescriptionReference.id,
			Class__c='',
			Magnitude__c='Delta',
			Description__c='File Description Child Delta',
			File_Naming_Convention__c='Name'
			);

		fileDescription3 = new GDP_File_Description__c(
			File_Format__c='XLSX',
			Frequency__c='Weekly',
			Field_Label__c='',
			Reference__c=fileDescriptionReference.id,
			Class__c='',
			Magnitude__c='Master',
			Description__c='File Description Child Delta',
			File_Naming_Convention__c='Name'
			);

		fileDescription4 = new GDP_File_Description__c(
			File_Format__c='XLSX',
			Frequency__c='Daily',
			Field_Label__c='',
			Reference__c= fileDescriptionReference.id,
			Class__c='',
			Magnitude__c='Delta',
			Description__c='File Description Child Delta',
			File_Naming_Convention__c='Name'
			);

		List<GDP_File_Description__c> fileDescriptionList = new List<GDP_File_Description__c> {fileDescription1, fileDescription2
																, fileDescription3, fileDescription4};
		insert fileDescriptionList;

		return fileDescriptionList;

	} // end of generateFileDescriptionRecords


	// ========================================================================
	private static void matchProductRatePlanWithFileDescription()
	{
		GDP_File_Description_To_Rate_Plan__c fileDescRatePlanMatching;
		List<GDP_File_Description_To_Rate_Plan__c> fileDescRatePlanMatchingList = new List<GDP_File_Description_To_Rate_Plan__c>();
		fileDescRatePlanMatching = new GDP_File_Description_To_Rate_Plan__c(Product_Rate_Plan__c=oProductRatePlan1.Id, GDP_File_Description__c=fileDescription1.id);
		fileDescRatePlanMatchingList.add( fileDescRatePlanMatching );
		fileDescRatePlanMatching = new GDP_File_Description_To_Rate_Plan__c(Product_Rate_Plan__c=oProductRatePlan1.Id, GDP_File_Description__c=fileDescription2.id);
		fileDescRatePlanMatchingList.add( fileDescRatePlanMatching );
		fileDescRatePlanMatching = new GDP_File_Description_To_Rate_Plan__c(Product_Rate_Plan__c=oProductRatePlan1.Id, GDP_File_Description__c=fileDescription3.id);
		fileDescRatePlanMatchingList.add( fileDescRatePlanMatching );
		fileDescRatePlanMatching = new GDP_File_Description_To_Rate_Plan__c(Product_Rate_Plan__c=oProductRatePlan1.Id, GDP_File_Description__c=fileDescription4.id);
		fileDescRatePlanMatchingList.add( fileDescRatePlanMatching );
		fileDescRatePlanMatching = new GDP_File_Description_To_Rate_Plan__c(Product_Rate_Plan__c=oProductRatePlan2.Id, GDP_File_Description__c=fileDescription1.id);
		fileDescRatePlanMatchingList.add( fileDescRatePlanMatching );
		fileDescRatePlanMatching = new GDP_File_Description_To_Rate_Plan__c(Product_Rate_Plan__c=oProductRatePlan3.Id, GDP_File_Description__c=fileDescription3.id);
		fileDescRatePlanMatchingList.add( fileDescRatePlanMatching );
		insert fileDescRatePlanMatchingList;
	} // matchProductRatePlanWithFileDescription


	// ========================================================================
	// Core test: on creation of Zuora__SubscriptionProductCharge__c, the GSS_Subscription_Detail will be created
	static testMethod void testSubscriptionDetailGeneration_1()
	{

		dataPreparation();
		generateFileDescriptionRecords();
		matchProductRatePlanWithFileDescription();

		System.test.startTest();

		// --------------------------------------------------------------------
		// basic test execution: creating Zuora__Subscription and Zuora__SubscriptionProductCharge__c
		System.runAs(usr) {

			// create Zuora__Subscription
			String SUBSCRIPTION_NAME_1 = 'Subs 01';
			subscription = IECTestUtil.createSampleSubscription(oAccount.Id, SUBSCRIPTION_NAME_1, Date.today().addMonths(6));
			subscription.Zuora__CustomerAccount__c = oBillingAccount.Id;
			insert subscription;

			// create Zuora__SubscriptionProductCharge__c
			subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan1);
			subscriptionCharge.Product_Rate_Plan_Charge__c = oProductRatePlanCharge1.Id;
			insert subscriptionCharge;
		}
		System.test.stopTest();

		// --------------------------------------------------------------------
		// validation
		// Zuora__SubscriptionProductCharge__c : =oProductRatePlan1 subscription.Id
		// ProductRatePlanCharge and

		List<GSS_Subscription_Detail__c> subDetailList = [select Id, Name
				, Zuora_Subscription__c, GDP_File_Description__c
				from GSS_Subscription_Detail__c
				where Zuora_Subscription__c = : subscription.Id
				];
		System.assertNotEquals(0, subDetailList.size(), 'GSS_Subscription_Detail should have been automatically created.');

		System.assertEquals(subscription.Name, subDetailList[0].Name, 'GSS_Subscription_Detail should have correct name:' + subscription.Name);
		System.assertNotEquals(null, subDetailList[0].GDP_File_Description__c, 'GSS_Subscription_Detail should have correct file description');


		// ensure that the GSS_Subscription_Detail is created

	} // end of testSubscriptionDetailGeneration_1


	// ========================================================================
	// Optional test: on update of Zuora__Subscription__c, the GSS_Subscription_Detail will be recreated, if necessary
	// also test with multiple Zuora__SubscriptionProductCharge__c insertion
	static testMethod	void testSubscriptionDetailGeneration_2()
	{
		dataPreparation();
		generateFileDescriptionRecords();
		matchProductRatePlanWithFileDescription();

		System.test.startTest();

		// --------------------------------------------------------------------
		// basic test execution: creating Zuora__Subscription and Zuora__SubscriptionProductCharge__c
		System.runAs(usr) {

			// create Zuora__Subscription
			String SUBSCRIPTION_NAME_1 = 'Subs 01';
			String SUBSCRIPTION_NAME_2 = 'Subs 02';
			subscription = IECTestUtil.createSampleSubscription(oAccount.Id, SUBSCRIPTION_NAME_1, Date.today().addMonths(6));
			subscription.Zuora__CustomerAccount__c = oBillingAccount.Id;

			Zuora__Subscription__c subscription2 = IECTestUtil.createSampleSubscription(oAccount.Id, SUBSCRIPTION_NAME_2, Date.today().addMonths(8));
			List<Zuora__Subscription__c> subscriptionList = new List<Zuora__Subscription__c>{ subscription, subscription2 };

			insert subscriptionList;

			// create Zuora__SubscriptionProductCharge__c
			subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan1);
			subscriptionCharge.Product_Rate_Plan_Charge__c = oProductRatePlanCharge1.Id;

			Zuora__SubscriptionProductCharge__c subscriptionCharge2 = IECTestUtil.createSampleSubscriptionCharge2(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan2);
			subscriptionCharge2.Product_Rate_Plan_Charge__c = oProductRatePlanCharge2.Id;
			List<Zuora__SubscriptionProductCharge__c> subscriptionProductChargeList = new List<Zuora__SubscriptionProductCharge__c>{subscriptionCharge,subscriptionCharge2 };
			insert subscriptionProductChargeList;

			List<GSS_Subscription_Detail__c> originalSubDetailList = [select Id, Name
				, Zuora_Subscription__c, GDP_File_Description__c
				from GSS_Subscription_Detail__c
				where Zuora_Subscription__c = : subscription.Id
				];

			delete originalSubDetailList[0];
			//update subscription;  // this one fails
		} // end of runAs
		System.test.stopTest();

		// --------------------------------------------------------------------
		// validation
		// Zuora__SubscriptionProductCharge__c : =oProductRatePlan1 subscription.Id
		// ProductRatePlanCharge and

		List<GSS_Subscription_Detail__c> subDetailList = [select Id, Name
				, Zuora_Subscription__c, GDP_File_Description__c
				from GSS_Subscription_Detail__c
				where Zuora_Subscription__c = : subscription.Id
				];
		System.assertNotEquals(0, subDetailList.size(), 'GSS_Subscription_Detail should have been automatically created.');

		System.assertEquals(subscription.Name, subDetailList[0].Name, 'GSS_Subscription_Detail should have correct name:' + subscription.Name);
		System.assertNotEquals(null, subDetailList[0].GDP_File_Description__c, 'GSS_Subscription_Detail should have correct file description');

		// ensure that the GSS_Subscription_Detail is created
	} // end of testSubscriptionDetailGeneration_2

	// ========================================================================
	// Test on GSS_Subscription_Detail insert
	// Related to trgIECGssSubscriptionDetail_BI_BU trigger and trgHndlrIECGssSubscriptionDetail.cls
	// mainly test the calculation of Calendar_Next_Submission_Date__c
	static testMethod void testSubscriptionDetailTrigger_3()
	{
		// todayInTest is used because other part of the code might use special condition for testing and code.
		// in which the current value of Date.today() is simulated in running the test method.
		// if we are not using vfIECGSSCalendar_tst.dToday() in other part, we can set it as Date.today()
		Date todayInTest = vfIECGSSCalendar_tst.dToday; // this is used to allow simulating Date.today() in other part,

		dataPreparation();
		List<GDP_File_Description__c> nonReferenceFileDescriptionList = generateFileDescriptionRecords();
		matchProductRatePlanWithFileDescription();

		System.test.startTest();

		// --------------------------------------------------------------------
		// basic test execution: creating Zuora__Subscription and Zuora__SubscriptionProductCharge__c
		System.runAs(usr) {

			// create Zuora__Subscription
			String SUBSCRIPTION_NAME_1 = 'Subs 01';
			subscription = IECTestUtil.createSampleSubscription(oAccount.Id, SUBSCRIPTION_NAME_1, Date.today().addMonths(6));
			subscription.Zuora__CustomerAccount__c = oBillingAccount.Id;
			insert subscription;

			/*
			// create Zuora__SubscriptionProductCharge__c is not done for this test,
			// as we do not want the system to automatically create GSS_Subscription_Detail, unlike in the previous test methods
			subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan1);
			subscriptionCharge.Product_Rate_Plan_Charge__c = oProductRatePlanCharge1.Id;
			insert subscriptionCharge;
			*/

			// create GSS_Subscription_Detail__c
			List<GSS_Subscription_Detail__c> newSubDetailList = new List<GSS_Subscription_Detail__c>();
			for ( GDP_File_Description__c fileDesc : nonReferenceFileDescriptionList)
			{
				System.assertNotEquals( null, fileDesc.Id, 'File Description Id cannot be null.');
				GSS_Subscription_Detail__c newSubscription = newGssSubscriptionDetail(subscription.Id, fileDesc.Id);
				newSubscription.Calendar_Monthly_Option__c = '2';
				newSubscription.Calendar_Weekly_Option__c = '2';
				newSubscription.Calendar_Semi_Monthly_First_Option__c = '2';
				newSubscription.Calendar_Semi_Monthly_Second_Option__c = '20';

				newSubDetailList.add(newSubscription);
			}
			insert newSubDetailList;
		}
		System.test.stopTest();

		// --------------------------------------------------------------------
		// ensure that the GSS_Subscription_Detail.Calendar_Next_Submission_Date__c is set
		List<GSS_Subscription_Detail__c> subDetailList = [select Id, Name
				, Zuora_Subscription__c, GDP_File_Description__c
				, Calendar_Monthly_Option__c, Calendar_Weekly_Option__c
				, Calendar_Semi_Monthly_First_Option__c, Calendar_Semi_Monthly_Second_Option__c
				, GDP_File_Description__r.Frequency__c
				, Calendar_Next_Submission_Date__c
				from GSS_Subscription_Detail__c
				where Zuora_Subscription__c = : subscription.Id
				];

		System.assertNotEquals(0, subDetailList.size(), 'GSS_Subscription_Detail should have been automatically created.');
		for ( GSS_Subscription_Detail__c subDet : subDetailList)
		{

			System.debug('Subscription Detail: ' + subDet
					+ 'File description: ' + subDet.GDP_File_Description__c + ', frequency: ' + subDet.GDP_File_Description__r.Frequency__c
					);
			if (( subDet.GDP_File_Description__r.Frequency__c  != null)
				&& (subDet.GDP_File_Description__r.Frequency__c != 'Daily' ))
			{ // Daily does not use calendar_Next_Submission_Date
				System.assertNotEquals(null, subDet.Calendar_Next_Submission_Date__c, 'Calendar_Next_Submission_Date should not be null: ' + subDet + ' frequency:' + subDet.GDP_File_Description__r.Frequency__c);
				//System.assert(todayInTest < subDet.Calendar_Next_Submission_Date__c, 'Calendar_Next_Submission_Date should be in the future from dToday ' + todayInTest + ' :'+ subDet);  //*** (Thai) commented for quickfix
			}
		}

		// additional test, call the method directly, this is to verify that the method is correct, in addition to testing on the trigger.
		for ( GSS_Subscription_Detail__c subDet : subDetailList)
		{
			subDet.Calendar_Monthly_Option__c = '3';
			subDet.Calendar_Weekly_Option__c = '3';
			subDet.Calendar_Semi_Monthly_First_Option__c = '3';
			subDet.Calendar_Semi_Monthly_Second_Option__c = '21';

			Date newDate = trgHndlrIECGssSubscriptionDetail.calculateCalendarNextSubmissionDate(subDet, subDet.GDP_File_Description__r.Frequency__c, todayInTest.addMonths(1)) ;
			System.debug ('subscription Detail 2: ' + subDet + '\n freq:' + subDet.GDP_File_Description__r.Frequency__c  );

			if ( subDet.GDP_File_Description__r.Frequency__c  != null && subDet.GDP_File_Description__r.Frequency__c != 'Daily' )
				System.assert(todayInTest < newDate, 'Calculated Calendar_Next_Submission_Date should be in the future: ' + subDet );
		}
	} // end of testSubscriptionDetailTrigger_3


	// ========================================================================
	// supporting method
	private static GSS_Subscription_Detail__c newGssSubscriptionDetail(Id zuoraSubscriptionId, Id fileDescriptionId)
	{
		GSS_Subscription_Detail__c subDetail = new GSS_Subscription_Detail__c(Name = fileDescriptionId
				, GDP_File_Description__c = fileDescriptionId
				, Zuora_Subscription__c = zuoraSubscriptionId);
		return subDetail;
	}

} // end of trgHdlrIECSubscriptionTest
