@isTest
private class ANG_FOPOSCARNotificationBatchTest {

		@isTest static void testReminderFOPMassNotificationError() {

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', 
															Region__c = 'Americas', 
															Case_BSP_Country__c= 'Canada'
															);
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Account a1 = new Account(Name='Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', 
			Location_Class__c= AMS_Utils.LC_PASSENGER,
			Status__c= AMS_Utils.ACC_S9_APPROVED,
			RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,
			Is_PCI_compliant__c = null,
			Location_Type__c = AMS_Utils.HO
			);
		agencylist.add(a1);
		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', 
									Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin',
									Preferred_Language__c = 'English', Financial_Assessment_Contact__c = false);	
		insert co1;

		Map<String,Object> fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.clear();
		fieldsOfObject.put('Process__c',AMS_Utils.NGFOP);
		fieldsOfObject.put('RecordTypeId',AMS_Utils.RECTYPE_NEWGENFOP);
		fieldsOfObject.put('ANG_FA_Opt_out__c','Not Applicable');

		AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENFOP, agencylist[0].Id, fieldsOfObject);
		insert oscar;

		Id caseRT = AMS_Utils.getId('Case', 'OSCAR_Communication');

        fieldsOfObject.clear();
        fieldsOfObject.put('Oscar__c',oscar.Id);
        fieldsOfObject.put('BSPCountry__c',agencylist[0].BillingCountry);
        fieldsOfObject.put('CaseArea__c','Accreditation Process');
        fieldsOfObject.put('Origin','Massive FOP Creation');
        fieldsOfObject.put('Reason1__c','FoP Management');
        fieldsOfObject.put('Subject','FoP Management - ');
        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
        //fieldsOfObject.put('ContactId',co1.Id); - force error

        Case newCaseFop =ANG_EntityCreator.createCase(caseRT, agencylist[0].Id, fieldsOfObject);

        insert newCaseFop;

        // set created date so that oscar can be processed for reminder notification
		Test.setCreatedDate(newCaseFop.Id, Datetime.now().addDays(-15));
		update newCaseFop;

		SalesforceSupportEmails__c sEmail = new SalesforceSupportEmails__c(Name = 'test', Support_Email__c = 'testSupportEmail@newgen.istest');
		insert sEmail;

		//insert notification template
		Notification_template__c nt = new Notification_template__c(Language__c = 'English', Identifier__c = ANG_FOPOSCARNotificationBatch.FOP_REMINDER_TEMPLATE_ID, 
								Expire_in_days__c = 30, Subject__c = 'Reminder - Request for PCI DSS Attestation of Compliance / Nil Credit Card Self-Declaration',
								Type__c = 'Information', Message__c = 'Test #CONTACTNAME# #IATACODE# #DEADLINEDATE#');
		insert nt;
		

		Test.startTest();
		//test without contact on case (force error)
		Database.executeBatch(new ANG_FOPOSCARNotificationBatch(),200);

		Test.stopTest();
	}
	
	@isTest static void testReminderFOPMassNotification() {

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', 
															Region__c = 'Americas', 
															Case_BSP_Country__c= 'Canada'
															);
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Account a1 = new Account(Name='Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', 
			Location_Class__c= AMS_Utils.LC_PASSENGER,
			Status__c= AMS_Utils.ACC_S9_APPROVED,
			RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,
			Is_PCI_compliant__c = null,
			Location_Type__c = AMS_Utils.HO
			);
		agencylist.add(a1);
		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste18964654', Lastname='test198654188', Phone = '911111111', MobilePhone = '911111111', 
									Email = 'test@test09237947698764981345.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin',
									Preferred_Language__c = 'English', Financial_Assessment_Contact__c = false);	
		insert co1;

		User  user = new User(
            alias = ISSP_PortalUserStatusChange.createAlias(co1.firstName, co1.lastName), 
            email = co1.email, 
            emailencodingkey = 'UTF-8', 
            firstname = co1.firstName, 
            lastname = co1.lastname, 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            contactId = co1.Id,
            timezonesidkey = 'Asia/Dubai', 
            username = ISSP_Utilities.buildPortalUserName(co1.email),//AEF
            CommunityNickname = 'nick456',
            ProfileId = [select Id from Profile where name = 'ISS Portal Agency Delegated Admin User'].Id,
            IsActive = true
        );

        insert user;

		Map<String,Object> fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.clear();
		fieldsOfObject.put('Process__c',AMS_Utils.NGFOP);
		fieldsOfObject.put('RecordTypeId',AMS_Utils.RECTYPE_NEWGENFOP);
		fieldsOfObject.put('ANG_FA_Opt_out__c','Not Applicable');

		AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENFOP, agencylist[0].Id, fieldsOfObject);
		insert oscar;

		Id caseRT = AMS_Utils.getId('Case', 'OSCAR_Communication');

        fieldsOfObject.clear();
        fieldsOfObject.put('Oscar__c',oscar.Id);
        fieldsOfObject.put('BSPCountry__c',agencylist[0].BillingCountry);
        fieldsOfObject.put('CaseArea__c','Accreditation Process');
        fieldsOfObject.put('Origin','Massive FOP Creation');
        fieldsOfObject.put('Reason1__c','FoP Management');
        fieldsOfObject.put('Subject','FoP Management - ');
        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
        fieldsOfObject.put('ContactId',co1.Id);

        Case newCaseFop =ANG_EntityCreator.createCase(caseRT, agencylist[0].Id, fieldsOfObject);

        insert newCaseFop;

        // set created date so that oscar can be processed for reminder notification
		Test.setCreatedDate(newCaseFop.Id, Datetime.now().addDays(-15));
		update newCaseFop;
		
		//insert notification template
		Notification_template__c nt = new Notification_template__c(Language__c = 'English', Identifier__c = ANG_FOPOSCARNotificationBatch.FOP_REMINDER_TEMPLATE_ID, 
								Expire_in_days__c = 30, Subject__c = 'Reminder - Request for PCI DSS Attestation of Compliance / Nil Credit Card Self-Declaration',
								Type__c = 'Information', Message__c = 'Test #CONTACTNAME# #IATACODE# #DEADLINEDATE#');
		insert nt;

		Test.startTest();

		Database.executeBatch(new ANG_FOPOSCARNotificationBatch(),200);

		Test.stopTest();

		System.assert([SELECT Id FROM Notification__c WHERE Contact__c = :co1.Id].size() == 1, 'No Reminder Notification created');
	}

		@isTest static void testNonComplianceFOPMassNotification() {

		List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', 
															Region__c = 'Americas', 
															Case_BSP_Country__c= 'Canada'
															);
		countrylist.add(isoc1);
		insert countrylist;
		
		List<Account> agencylist = new List<Account>();
		Account a1 = new Account(Name='Test1 Agency',
			IATA_ISO_Country__c = isoc1.id, Sent_to_external_system__c = true, 
			IATACode__c = '12345678', 
			Location_Class__c= AMS_Utils.LC_PASSENGER,
			Status__c= AMS_Utils.ACC_S9_APPROVED,
			RecordTypeId= AMS_Utils.RECTYPE_IATAAGENCY,
			Is_PCI_compliant__c = null,
			Location_Type__c = AMS_Utils.HO
			);
		agencylist.add(a1);
		insert agencylist;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1043651048967017', Lastname='test187536835678', Phone = '911111111', MobilePhone = '911111111', 
									Email = 'test@test48736174619.com', BSP_CASS_Payment_contact__c = true, User_Portal_Status__c = 'Approved Admin',
									Preferred_Language__c = 'English', Financial_Assessment_Contact__c = false);	
		insert co1;

		User  user = new User(
            alias = ISSP_PortalUserStatusChange.createAlias(co1.firstName, co1.lastName), 
            email = co1.email, 
            emailencodingkey = 'UTF-8', 
            firstname = co1.firstName, 
            lastname = co1.lastname, 
            languagelocalekey = 'en_US', 
            localesidkey = 'en_US', 
            contactId = co1.Id,
            timezonesidkey = 'Asia/Dubai', 
            username = ISSP_Utilities.buildPortalUserName(co1.email),//AEF
            CommunityNickname = 'nick123',
           ProfileId = [select Id from Profile where name = 'ISS Portal Agency Delegated Admin User'].Id,
            IsActive = true
        );

        insert user;

		Map<String,Object> fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.clear();
		fieldsOfObject.put('Process__c',AMS_Utils.NGFOP);
		fieldsOfObject.put('RecordTypeId',AMS_Utils.RECTYPE_NEWGENFOP);
		fieldsOfObject.put('ANG_FA_Opt_out__c','Not Applicable');

		AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENFOP, agencylist[0].Id, fieldsOfObject);
		insert oscar;

		Id caseRT = AMS_Utils.getId('Case', 'OSCAR_Communication');

        fieldsOfObject.clear();
        fieldsOfObject.put('Oscar__c',oscar.Id);
        fieldsOfObject.put('BSPCountry__c',agencylist[0].BillingCountry);
        fieldsOfObject.put('CaseArea__c','Accreditation Process');
        fieldsOfObject.put('Origin','Massive FOP Creation');
        fieldsOfObject.put('Reason1__c','FoP Management');
        fieldsOfObject.put('Subject','FoP Management - ');
        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');
        fieldsOfObject.put('ContactId',co1.Id);

        Case newCaseFop =ANG_EntityCreator.createCase(caseRT, agencylist[0].Id, fieldsOfObject);

        insert newCaseFop;

        // set created date so that oscar can be processed for Non Compliance notification
		Test.setCreatedDate(newCaseFop.Id, Datetime.now().addDays(-30));
		update newCaseFop;
		
		//insert notification template
		Notification_template__c nt = new Notification_template__c(Language__c = 'English', Identifier__c = ANG_FOPOSCARNotificationBatch.FOP_NONCOMPLIANCE_TEMPLATE_ID, 
								Expire_in_days__c = 30, subject__c = 'Non compliance - Request for PCI DSS Attestation of Compliance / Nil Credit Card Self-Declaration',
								Type__c = 'Information', Message__c = 'Test #CONTACTNAME# #IATACODE#');
		insert nt;

		Test.startTest();

		Database.executeBatch(new ANG_FOPOSCARNotificationBatch(),200);

		Test.stopTest();

		System.assert([SELECT Id FROM Notification__c WHERE Contact__c = :co1.Id].size() == 1, 'No Non Compliance Notification created');
	}

	@isTest
    public static void testBatchScheduler(){
    	Test.startTest();
    	ANG_FOPOSCARNotificationScheduler sch = new ANG_FOPOSCARNotificationScheduler ();
    	String cronExp = '0 0 7 1/1 * ? *'; 
    	system.schedule('Test ANG_FOPOSCARNotificationScheduler', cronExp, sch);
    	test.StopTest();
    }
	
	
}