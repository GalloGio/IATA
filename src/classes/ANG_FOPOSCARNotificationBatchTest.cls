@isTest
private class ANG_FOPOSCARNotificationBatchTest {

	@testSetup 
	static void setup() {
		Test.startTest();

		insert new List<Notification_template__c>{
			new Notification_template__c(Language__c = 'English', 
				Identifier__c = ANG_FOPOSCARNotificationBatch.ANNUAL_REV_REMINDER,
				Expire_in_days__c = 30, 
				Subject__c = 'Annual Revalidation Reminder',
				Type__c = 'Information', 
				Message__c = 'Annual Revalidation Reminder'),
			
			new Notification_template__c(Language__c = 'English', 
				Identifier__c = ANG_FOPOSCARNotificationBatch.ANNUAL_REV_DEADLINE_REMINDER,
				Expire_in_days__c = 30, 
				Subject__c = 'Annual Revalidation Deadline Reminder',
				Type__c = 'Information', 
				Message__c = 'Annual Revalidation Deadline Reminder'),

			new Notification_template__c(Language__c = 'English',
				Identifier__c = ANG_FOPOSCARNotificationBatch.FOP_REMINDER_TEMPLATE_ID,
				Expire_in_days__c = 30,
				Subject__c = 'Reminder - Request for PCI DSS Attestation of Compliance / Nil Credit Card Self-Declaration',
				Type__c = 'Information',
				Message__c = 'Test #CONTACTNAME# #IATACODE# #DEADLINEDATE#'),

			new Notification_template__c(Language__c = 'English', 
				Identifier__c = ANG_FOPOSCARNotificationBatch.FOP_NONCOMPLIANCE_TEMPLATE_ID,
				Expire_in_days__c = 30, 
				Subject__c = 'Non compliance - Request for PCI DSS Attestation of Compliance / Nil Credit Card Self-Declaration',
				Type__c = 'Information', 
				Message__c = 'Test #CONTACTNAME# #IATACODE#')
		};

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'Portugal', 
			ISO_Code__c = 'PT',
			Region__c = 'Europe',
			Case_BSP_Country__c = 'Portugal',
			ANG_Enable_NewGen__c = true);

		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS',
			Region__c = 'Americas',
			Case_BSP_Country__c= 'Canada');
		
		insert new List<IATA_ISO_Country__c>{
			country,
			isoc1
		};

		Account a1 = new Account(Name = 'Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, 
			Sent_to_external_system__c = true,
			IATACode__c = '12345678',
			Location_Class__c= AMS_Utils.LC_PASSENGER,
			Status__c= AMS_Utils.ACC_S9_APPROVED,
			RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,
			Is_PCI_compliant__c = null,
			Location_Type__c = AMS_Utils.HO);

		Account account = new Account(BillingCity = 'test',
			Name = 'test',
			sector__c = Ams_Utils.SECTOR_PASSENGER,
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATACode__c = '12345677',
			status__c = Ams_Utils.ACC_S9_APPROVED,
			IATA_ISO_Country__c = country.Id,
			Location_Class__c = 'P',
			Reason__c = 'Annual Revalidation - Name');

		insert new List<Account>{
			a1,
			account
		};

		Contact contact = new Contact(LastName = 'Contact',
			AccountId = account.Id,
			Email = 'testannualrevreminder@test.com');

		Contact co1 = new Contact(AccountId = a1.id, 
			Lastname = 'test1', 
			Email = 'test@test.com', 
			BSP_CASS_Payment_contact__c = true);

		insert new List<Contact>{
			contact, co1
		};

		User user = ISSP_ObjectFactory.createPortalUser(contact);
		contact.OwnerId = user.Id;

		User user1 = ISSP_ObjectFactory.createPortalUser(co1);
		co1.OwnerId = user1.Id;

		update new List<Contact>{
			contact,
			co1
		};

		AMS_OSCAR__c oscar = New AMS_OSCAR__c(Account__c = account.id, 
			Process__c = 'ANG.ANNUAL.REVALIDATION', 
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_ANNUAL_REVALIDATION'));

		AMS_OSCAR__c oscar1 = New AMS_OSCAR__c(Account__c = a1.id, 
			Process__c = AMS_Utils.NGFOP, 
			RecordTypeId = AMS_Utils.RECTYPE_NEWGENFOP,
			ANG_FA_Opt_out__c = 'Not Applicable');
		
		insert new List<AMS_OSCAR__c>{
			oscar,
			oscar1
		};

		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		String annualRevGroup;
		String massFopGroup;

		for (Group groupQueue: [SELECT Id, Name 
								FROM Group 
								WHERE Name IN ('NewGen PCI - Americas', 'Annual Revalidation') 
									AND Type = 'Queue']) {
			if (groupQueue.Name == 'NewGen PCI - Americas') {
				massFopGroup = groupQueue.Id;
			} else {
				annualRevGroup = groupQueue.Id;
			}
		}

		Case testcase = new Case (Account_Concerned__c = account.Id,
			AccountId = account.Id,
			OSCAR__c  = oscar.Id,
			ContactId = contact.Id,
			Reason1__c = 'Annual revalidation',
			Region__c = 'Europe',
			RecordTypeId = caseRT,
			Subject = 'Annual Revalidation',
			Type = 'Case',
			Type_of_customer__c = 'IATA Travel Agent',
			CaseArea__c = 'Annual Revalidation');

		Case newCaseFop = new Case (Account_Concerned__c = a1.Id,
			AccountId = a1.Id,
			OSCAR__c  = oscar1.Id,
			ContactId = co1.Id,
			Reason1__c = 'FoP Management',
			Region__c = 'Europe',
			RecordTypeId = caseRT,
			Subject = 'FoP Management - ',
			Type = 'Case',
			Type_of_customer__c = 'IATA Travel Agent',
			Origin = 'Massive FOP Creation',
			CaseArea__c = 'Accreditation Process',
			BSPCountry__c = 'BSPCountry__c');

		insert new List<Case>{
			testcase,
			newCaseFop
		};

		testcase.OwnerId = annualRevGroup;
		newCaseFop.OwnerId = massFopGroup;

		update new List<Case>{
			testcase,
			newCaseFop
		};

		insert new SalesforceSupportEmails__c(Name = 'test', 
			Support_Email__c = 'testSupportEmail@newgen.istest', Support_User_Id__c = UserInfo.getUserId());

		insert new AMS_ChangeCodes__c(Name = 'ARV',
			Bulletin_Memo_Text__c = 'AGENT IS SERVED ADMINISTRATIVE NON-COMPLIANCE DUE TO ANNUAL REVALIDATION NON COMPLIANCE, AGENT IS GIVEN 30 DAYS TO VALIDATE THE AGENCY DETAILS',
			Change_Code__c = 'ARV',
			Published_in_bulletin__c = true,
			Integration_RecId__c = 'C');

		Test.stopTest();
	}
	@isTest 
	static void testReminderFOPMassNotificationError() {
		Case fopCase = [SELECT Id
			FROM Case
			WHERE Origin = 'Massive FOP Creation'];

		fopCase.ContactId = null;

		Test.setCreatedDate(fopCase.Id, Datetime.now().addDays(-15));
		update fopCase;

		Test.startTest();

		Database.executeBatch(new ANG_FOPOSCARNotificationBatch(), 200);

		Test.stopTest();
	}

	@isTest 
	static void testReminderFOPMassNotification() {
		Case fopCase = [SELECT Id
			FROM Case
			WHERE Origin = 'Massive FOP Creation'];

		Contact co1 = [SELECT Id
			FROM Contact
			WHERE LastName = 'test1'];

		Test.setCreatedDate(fopCase.Id, Datetime.now().addDays(-15));
		update fopCase;

		Test.startTest();

		Database.executeBatch(new ANG_FOPOSCARNotificationBatch(),200);

		Test.stopTest();

		List<Notification__c> notificationCreated = [SELECT Id 
			FROM Notification__c 
			WHERE Contact__c = :co1.Id];

		System.assert(notificationCreated.size() == 1, 'No Reminder Notification created');
	}

	@isTest 
	static void testNonComplianceFOPMassNotification() {
		Case fopCase = [SELECT Id
			FROM Case
			WHERE Origin = 'Massive FOP Creation'];

		Contact co1 = [SELECT Id
			FROM Contact
			WHERE LastName = 'test1'];

		Test.setCreatedDate(fopCase.Id, Datetime.now().addDays(-30));
		update fopCase;

		Test.startTest();

		Database.executeBatch(new ANG_FOPOSCARNotificationBatch(), 200);

		Test.stopTest();

		List<Notification__c> notificationCreated = [SELECT Id 
			FROM Notification__c 
			WHERE Contact__c = :co1.Id];

		System.assert(notificationCreated.size() == 1, 'No Non Compliance Notification created');
	}

	@isTest
	public static void testBatchScheduler(){
		Test.startTest();
		ANG_FOPOSCARNotificationScheduler sch = new ANG_FOPOSCARNotificationScheduler ();
		String cronExp = '0 0 7 1/1 * ? *';
		system.schedule('Test ANG_FOPOSCARNotificationScheduler', cronExp, sch);
		Test.stopTest();
	}

	@isTest 
	static void testReminderAnnualRevalidation() {
		Case annRevCase = [SELECT Id
			FROM Case
			WHERE Reason1__c = 'Annual revalidation'];

		Contact con = [SELECT Id
			FROM Contact
			WHERE LastName = 'Contact'];

		Test.setCreatedDate(annRevCase.Id, Datetime.now().addDays(-15));
		update annRevCase;

		Test.startTest();

		Database.executeBatch(new ANG_FOPOSCARNotificationBatch(), 200);

		Test.stopTest();

		List<Notification__c> notificationCreated = [SELECT Id 
			FROM Notification__c 
			WHERE Contact__c = :con.Id];

		System.assert(notificationCreated.size() == 1, 'No Annual Revalidation Notification created');
	}

	@isTest 
	static void testDeadlineReminderAnnualRevalidation() {
		AMS_OSCAR__c oscar = [SELECT Id
			FROM AMS_OSCAR__c
			WHERE Process__c = 'ANG.ANNUAL.REVALIDATION'];

		oscar.STEP43__c = AMS_Utils.PASSED;
		oscar.ANG_Administrative_non_compliance_date__c = Date.today()-20;

		update oscar;

		Contact con = [SELECT Id
			FROM Contact
			WHERE LastName = 'Contact'];

		Test.startTest();

		ANG_FOPOSCARNotificationBatch batch = new ANG_FOPOSCARNotificationBatch();
		batch.simulateRunOnDate(Date.today().addDays(1));
		Database.executeBatch(batch, 200);

		Test.stopTest();

		List<Notification__c> notificationCreated = [SELECT Id 
			FROM Notification__c 
			WHERE Contact__c = :con.Id];

		System.assert(notificationCreated.size() == 1, 'No Annual Revalidation Notification created');
	}

}
