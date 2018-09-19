@isTest
private class AMS_MigrationToolHelperTest {

	@testSetup static void setup() {

		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account';
		account1.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
		account1.IATACode__c = '4242424';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		insert account1;

		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = account1.Id;
		contact1.Email = 'some@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = account1.Id;
		saamCase.Subject = 'Test SAAM case';
		saamCase.Description = 'Test SAAM case';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = AMS_Utils.RECTYPE_SAAM;
		saamCase.Reason1__c = 'New HO';
		insert saamCase;

		List<Case> casesList = [SELECT id, Status, Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];

		if (!casesList.isEmpty()) {

			Case thecase = casesList.get(0);

			thecase.Financial_Assessment_received__c = Date.Today();
			thecase.Bank_Guarantee_amount__c = '666';
			thecase.Bank_Guarantee_deadline__c = Date.Today();
			thecase.Bank_Guarantee_received__c = Date.Today();
			thecase.Bank_Guarantee_requested__c = Date.Today();
			thecase.Change_effective_as_of__c = Date.Today();
			thecase.Criteria_remarks__c = 'Stuff3';
			thecase.Documentation_remarks__c = 'Stuff2';
			thecase.Dossier_reception_date__c = Date.Today();
			thecase.Fees_refund_requested__c = Date.Today();
			thecase.Finalization_checklist__c = 'BG Updated in CAIMS (C&NA)';
			thecase.Financial_Assessment_deadline__c = Date.Today();
			thecase.Financial_Assessment_requested__c = Date.Today();
			thecase.Financial_Review_Result__c = 'Satisfactory';
			thecase.Financial_Assessment_compliant__c = 'Satisfactory';
			thecase.Invoice_number__c = '12312323';
			thecase.Local_Inspection_compliant__c = 'No';
			thecase.Local_Inspection_deadline__c = Date.Today();
			thecase.Local_Inspection_received__c = Date.Today();
			thecase.Local_Inspection_requested__c = Date.Today();
			thecase.Process_Start_Date__c = Date.Today();
			thecase.Proof_of_payment_received__c = Date.Today();
			thecase.PSAA_EACP_Agreement_received__c = Date.Today();
			thecase.PSAA_signed_copy_sent__c = Date.Today();
			thecase.SAAM_Deadline_Date__c = Date.Today();
			thecase.AIMS_updated__c = Date.Today();
			thecase.Finalized_in_AIMS__c = Date.Today();

			update thecase;

		}


	}

	@isTest
	static void test_verifyCaseMigration() {

		Test.startTest();

		AMS_MigrationToolHelper.decode('V');

		List<Case> casesList = [SELECT id, Account.ANG_IsNewGenAgency__c, Account.Location_Class__c, Account.Category__c, Account.Location_Type__c ,Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c ,Financial_Assessment_received__c,Bank_Guarantee_amount__c,Bank_Guarantee_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_requested__c,Change_effective_as_of__c,Criteria_remarks__c,Documentation_remarks__c,Dossier_reception_date__c,Fees_refund_requested__c,Finalization_checklist__c,Financial_Assessment_deadline__c,Financial_Assessment_requested__c,Financial_Review_Result__c,Invoice_number__c,Local_Inspection_compliant__c,Local_Inspection_deadline__c,Local_Inspection_received__c,Local_Inspection_requested__c,Process_Start_Date__c,Proof_of_payment_received__c,PSAA_EACP_Agreement_received__c,PSAA_signed_copy_sent__c,SAAM_Deadline_Date__c,AIMS_updated__c,Finalized_in_AIMS__c from case];

		if (casesList.isEmpty())
			System.assertEquals(true, false);

		Case c = casesList.get(0);

		AMS_MigrationToolHelper.CaseContainer cc = new AMS_MigrationToolHelper.CaseContainer(c, false);

		Boolean testvarhasError = cc.hasError;

		cc = AMS_MigrationToolHelper.migratecases(cc, null);

		if (cc.errorMessage != null)
			System.assertEquals(null, cc.errorMessage);

		List<AMS_OSCAR__c> oscars = [SELECT Id, Status__c, Name, First_Step_Completed__c, Assessment_Performed_Date__c, Bank_Guarantee_deadline__c, Bank_Guarantee_amount__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_Reception_Date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Billing_Document_Number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, Welcome_Pack_Sent__c, Sanity_check_deadline__c, Update_AIMS_Rejection_Date__c, Update_AIMS_Rejection__c, Update_AIMS_Approval_Date__c, Update_AIMS_Approval__c from AMS_OSCAR__c];

		if (oscars.isEmpty())
			System.assertEquals(true, false);

		AMS_OSCAR__c oscar = oscars.get(0);

		System.assertEquals(c.Financial_Assessment_received__c, oscar.Assessment_Performed_Date__c);
		System.assertEquals(c.Bank_Guarantee_deadline__c, oscar.Bank_Guarantee_deadline__c);
		System.assertEquals(c.Bank_Guarantee_received__c, oscar.Bank_Guarantee_received__c);
		System.assertEquals(c.Bank_Guarantee_requested__c, oscar.Bank_Guarantee_requested__c);
		System.assertEquals(c.Change_effective_as_of__c, oscar.Change_effective_as_of__c);
		System.assertEquals(c.Criteria_remarks__c, oscar.Criteria_remarks__c);
		System.assertEquals(c.Documentation_remarks__c, oscar.Documentation_remarks__c);
		System.assertEquals(c.Dossier_reception_date__c, oscar.Dossier_Reception_Date__c);
		System.assertEquals(c.Fees_refund_requested__c, oscar.Fees_refund_requested__c);
		System.assertEquals(c.Finalization_checklist__c, oscar.Finalization_checklist__c);
		System.assertEquals(c.Financial_Assessment_deadline__c, oscar.Financial_Assessment_deadline__c);
		System.assertEquals(c.Financial_Assessment_requested__c, oscar.Financial_Assessment_requested__c);
		System.assertEquals(c.Invoice_number__c, oscar.Billing_Document_Number__c);
		System.assertEquals(c.Local_Inspection_deadline__c, oscar.Local_Inspection_deadline__c);
		System.assertEquals(c.Local_Inspection_received__c, oscar.Local_Inspection_received__c);
		System.assertEquals(c.Local_Inspection_requested__c, oscar.Local_Inspection_requested__c);
		System.assertEquals(c.Process_Start_Date__c, oscar.Process_Start_Date__c);
		System.assertEquals(c.Proof_of_payment_received__c, oscar.Proof_of_payment_received__c);
		System.assertEquals(c.PSAA_EACP_Agreement_received__c, oscar.PSAA_EACP_Agreement_received__c);
		System.assertEquals(c.PSAA_signed_copy_sent__c, oscar.Welcome_Pack_Sent__c);
		System.assertEquals(c.SAAM_Deadline_Date__c, oscar.Sanity_check_deadline__c);
		System.assertEquals(c.AIMS_updated__c, oscar.Update_AIMS_Rejection_Date__c);
		System.assertEquals(c.Finalized_in_AIMS__c, oscar.Update_AIMS_Approval_Date__c);

		System.assertEquals(true , oscar.Assessment_Performed_Date__c != null );
		System.assertEquals(true , oscar.Bank_Guarantee_amount__c != null );
		System.assertEquals(true , oscar.Bank_Guarantee_deadline__c != null );
		System.assertEquals(true , oscar.Bank_Guarantee_received__c != null );
		System.assertEquals(true , oscar.Bank_Guarantee_requested__c != null );
		System.assertEquals(true , oscar.Change_effective_as_of__c != null );
		System.assertEquals(true , oscar.Criteria_remarks__c != null );
		System.assertEquals(true , oscar.Documentation_remarks__c != null );
		System.assertEquals(true , oscar.Dossier_Reception_Date__c != null );
		System.assertEquals(true , oscar.Fees_refund_requested__c != null );
		System.assertEquals(true , oscar.Finalization_checklist__c != null );
		System.assertEquals(true , oscar.Financial_Assessment_deadline__c != null );
		System.assertEquals(true , oscar.Financial_Assessment_requested__c != null );
		System.assertEquals(true , oscar.Billing_Document_Number__c != null );
		System.assertEquals(true , oscar.Local_Inspection_compliant__c != null );
		System.assertEquals(true , oscar.Local_Inspection_deadline__c != null );
		System.assertEquals(true , oscar.Local_Inspection_received__c != null );
		System.assertEquals(true , oscar.Local_Inspection_requested__c != null );
		System.assertEquals(true , oscar.Process_Start_Date__c != null );
		System.assertEquals(true , oscar.Proof_of_payment_received__c != null );
		System.assertEquals(true , oscar.PSAA_EACP_Agreement_received__c != null );
		System.assertEquals(true , oscar.Welcome_Pack_Sent__c != null );
		System.assertEquals(true , oscar.Sanity_check_deadline__c != null );
		System.assertEquals(true , oscar.Update_AIMS_Rejection_Date__c != null );
		System.assertEquals(true , oscar.Update_AIMS_Approval_Date__c != null );


		Test.stopTest();
	}

	@isTest
	static void test_verifyCaseMigration3() {

		Test.startTest();

		AMS_MigrationToolHelper.decode('V');

		List<Case> casesList = [SELECT id, Account.Location_Class__c, Account.Category__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];

		if (casesList.isEmpty())
			System.assertEquals(true, false);

		Case c = casesList.get(0);

		c.reason1__c = 'New SA / CHV – New Code';

		update c;

		casesList = [SELECT id, Account.Location_Class__c, Account.Category__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];

		AMS_MigrationToolHelper.CaseContainer cc = new AMS_MigrationToolHelper.CaseContainer(c, false);

		cc = AMS_MigrationToolHelper.migratecases(cc, null);



		Test.stopTest();
	}

	@isTest
	static void test_verifyCaseMigration2() {

		Test.startTest();

		List<Case> casesList = [SELECT id, Account.Location_Class__c, Account.Category__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];

		if (casesList.isEmpty())
			System.assertEquals(true, false);

		Case c = casesList.get(0);

		AMS_MigrationToolHelper.CaseContainer cc = new AMS_MigrationToolHelper.CaseContainer(c, true);

		cc = AMS_MigrationToolHelper.migratecases(cc, null);

		AMS_MigrationToolHelper.performValidations(c, 'New HO');

		AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();

		accreditationObj.SAAM_Case__c = c.Id;

		insert accreditationObj;

		accreditationObj = [select Id, SAAM_Case__c from AMS_Pax_Accreditation_Form__c LIMIT 1].get(0);

		AMS_Account_Role__c role = new AMS_Account_Role__c();
		role.Legacy_External_ID__c = '123213';
		role.Owner_Name__c = 'TEST';
		role.Legacy_System__c = 'AIMS';

		insert role;

		role = [SELECT Id , Legacy_External_ID__c, Owner_Name__c, Legacy_System__c, Owner_Account__c, Contact__c, Contact_Email__c, Percentage__c, Person__c, Contact_Phone__c from AMS_Account_Role__c LIMIT 1].get(0);

		AMS_MigrationToolHelper.createAccreditationContact(accreditationObj, role, 'NEW.HO.1.0');

		AMS_MigrationToolHelper.alignOwners(accreditationObj, c);

		Test.stopTest();
	}


    static testMethod void test_verifyCaseMigration4() {
		  
		Test.startTest();

		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account';
        account1.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
		account1.IATACode__c = '4242424';
		account1.Type = 'IATA Passenger Sales Agent';
		account1.BillingCity = 'Montreal';
		account1.BillingCountry = 'Canada';
		account1.BillingStreet = 'some street';
		account1.Location_Type__c = 'HO';
		insert account1;

		// create test contact
		Contact contact1 = new Contact();
		contact1.FirstName = 'Dummy';
		contact1.LastName = 'Contact';
		contact1.Type_of_Contact__c = 'IFAP Contact';
		contact1.AccountId = account1.Id;
		contact1.Email = 'some2@email.org';
		contact1.Financial_Assessment_Contact__c = true;
		insert contact1;

		Case thecase = new Case();
		thecase.ContactId = contact1.Id;
		thecase.AccountId = account1.Id;
		thecase.Subject = 'Test SAAM case';
		thecase.Description = 'Test SAAM case';
		thecase.Status = 'Open';
		thecase.RecordTypeId = AMS_Utils.RECTYPE_SAAM;
		thecase.Reason1__c = 'CLO - Closure';
		insert thecase;


		thecase.Financial_Assessment_received__c = Date.Today();
		thecase.Bank_Guarantee_amount__c = '666';
		thecase.Bank_Guarantee_deadline__c = Date.Today();
		thecase.Bank_Guarantee_received__c = Date.Today();
		thecase.Bank_Guarantee_requested__c = Date.Today();
		thecase.Change_effective_as_of__c = Date.Today();
		thecase.Criteria_remarks__c = 'Stuff3';
		thecase.Documentation_remarks__c = 'Stuff2';
		thecase.Dossier_reception_date__c = Date.Today();
		thecase.Fees_refund_requested__c = Date.Today();
		thecase.Finalization_checklist__c = 'BG Updated in CAIMS (C&NA)';
		thecase.Financial_Assessment_deadline__c = Date.Today();
		thecase.Financial_Assessment_requested__c = Date.Today();
		thecase.Financial_Review_Result__c = 'Satisfactory';
		thecase.Financial_Assessment_compliant__c = 'Satisfactory';
		thecase.Invoice_number__c = '12312323';
		thecase.Local_Inspection_compliant__c = 'No';
		thecase.Local_Inspection_deadline__c = Date.Today();
		thecase.Local_Inspection_received__c = Date.Today();
		thecase.Local_Inspection_requested__c = Date.Today();
		thecase.Process_Start_Date__c = Date.Today();
		thecase.Proof_of_payment_received__c = Date.Today();
		thecase.PSAA_EACP_Agreement_received__c = Date.Today();
		thecase.PSAA_signed_copy_sent__c = Date.Today();
		thecase.SAAM_Deadline_Date__c = Date.Today();
		thecase.AIMS_updated__c = Date.Today();
		thecase.Finalized_in_AIMS__c = Date.Today();

		update thecase;
	
		AMS_MigrationToolHelper.CaseContainer cc = new AMS_MigrationToolHelper.CaseContainer(thecase,false);

		cc = AMS_MigrationToolHelper.migratecases(cc,null);
		
        AMS_MigrationToolHelper.fetchAccreditation(thecase.Id);
            
		Test.stopTest();
		  
	}

        static testMethod void alignOwnersTest() {

		Test.startTest();

		// create test account1
		Account account2 = new Account();
		account2.Name = 'Test account Contact';
		account2.IATACode__c = '424242434';
		account2.Type = 'IATA Passenger Sales Agent';
		account2.BillingCity = 'Montreal';
		account2.BillingCountry = 'Canada';
		account2.BillingStreet = 'some street';
		account2.Location_Type__c = 'HO';

		// create test account1
		Account account3 = new Account();
		account3.Name = 'Test account Contact2';
		account3.IATACode__c = '4242424123';
		account3.Type = 'IATA Passenger Sales Agent';
		account3.BillingCity = 'Montreal';
		account3.BillingCountry = 'Canada';
		account3.BillingStreet = 'some street';
		account3.Location_Type__c = 'HO';

		insert new List<Account> {account2, account3};

		Contact contact1 = new Contact(FirstName = 'user1' , LastName = 'lastnameuser1', email = 'user1test@tmail.com', account = account2);
		Contact contact2 = new Contact(FirstName = 'user2' , LastName = 'lastnameuser2', email = 'user2test@tmail.com', account = account2);

		Contact contact3 = new Contact(FirstName = 'user3' , LastName = 'lastnameuser3', email = 'user3test@tmail.com', account = account2);

		Contact contact4 = new Contact(FirstName = 'user4' , LastName = 'lastnameuser4', email = 'user4test@tmail.com', account = account2);

		Contact contact5 = new Contact(FirstName = 'user4' , LastName = 'lastnameuser4', email = 'testuser23@gtst.com', account = account2);

		Contact contact6 = new Contact(FirstName = 'user6' , LastName = 'lastnameuser4', email = 'testuser236@gtst.com', account = account2);

		insert new List<Contact> {contact1, contact2, contact3, contact4, contact5, contact6};

		AMS_Person__c person1 = new AMS_Person__c(Name = 'Person3' , Contact__c = contact4.Id);
		AMS_Person__c person2 = new AMS_Person__c(Name = 'Person4');

		insert new List<AMS_Person__c> {person1, person2};

		AMS_Account_Role__c role1 = new AMS_Account_Role__c(Account__c = account2.Id , Contact__c = contact1.Id);
		AMS_Account_Role__c role2 = new AMS_Account_Role__c(Account__c = account2.Id , Person__c = person1.Id);
		AMS_Account_Role__c role3 = new AMS_Account_Role__c(Account__c = account2.Id , Legacy_System__c = 'AIMS2' , Legacy_External_ID__c = 'ASD123123');
		AMS_Account_Role__c role4 = new AMS_Account_Role__c(Account__c = account2.Id , Contact__c = contact2.Id);
		AMS_Account_Role__c role5 = new AMS_Account_Role__c(Account__c = account2.Id , Contact__c = contact3.Id);
		AMS_Account_Role__c role6 = new AMS_Account_Role__c(Account__c = account2.Id, Owner_Account__c = account3.Id);

		insert new List<AMS_Account_Role__c> {role1, role2, role3, role4, role5, role6};

		Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = account2.Id;
		saamCase.Subject = 'Test SAAM case2';
		saamCase.Description = 'Test SAAM case2';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = SAAMcaseRecordTypeId;
		saamCase.Reason1__c = 'New HO';
		insert saamCase;

		AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();

		accreditationObj.SAAM_Case__c = saamCase.Id;

		insert accreditationObj;

		AMS_Accreditation_Contact__c aContact1 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Agency_owner__c = true, Financial_interest__c = 25);
		AMS_Accreditation_Contact__c aContact2 = new AMS_Accreditation_Contact__c(First_name__c = 'user4' , Last_name__c = 'lastnameuser4' ,  Email__c = 'user4test@tmail.com' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Agency_owner__c = true, Financial_interest__c = 25);
		AMS_Accreditation_Contact__c aContact3 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , Agency_owner__c = true, AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Financial_interest__c = 25);
		AMS_Accreditation_Contact__c aContact4 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , Contact__c = contact2.Id, Agency_owner__c = true, AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Financial_interest__c = 25);
		AMS_Accreditation_Contact__c aContact5 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Legacy_External_Id__c = 'ASD123123', Email__c = 'testuser236@gtst.com', Agency_owner__c = true);
		AMS_Accreditation_Contact__c aContact6 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Person_AMS__c = person1.id, Contact__c = contact4.id, Agency_owner__c = true);
		AMS_Accreditation_Contact__c aContact7 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Company__c = account3.Id , Email__c = 'testuser23@gtst.com', Agency_owner__c = true);
		AMS_Accreditation_Contact__c aContact8 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Person_AMS__c = person2.Id, Agency_owner__c = true);

		insert new List<AMS_Accreditation_Contact__c> {aContact1, aContact2, aContact3, aContact4, aContact5, aContact6, aContact7, aContact8};

		AMS_MigrationToolHelper.alignOwners(accreditationObj, saamCase);

		AMS_MigrationToolHelper.decode('A');
		AMS_MigrationToolHelper.decode('C');
		AMS_MigrationToolHelper.decode('E');
		AMS_MigrationToolHelper.decode('J');
		AMS_MigrationToolHelper.decode('L');
		AMS_MigrationToolHelper.decode('O');
		AMS_MigrationToolHelper.decode('P');
		AMS_MigrationToolHelper.decode('R');
		AMS_MigrationToolHelper.decode('S');
		AMS_MigrationToolHelper.decode('T');
		AMS_MigrationToolHelper.decode('V');
		AMS_MigrationToolHelper.decode('X');

		Test.stopTest();
	}

	@isTest
	static void performValidations() {

		Test.startTest();

		List<Case> casesList = [SELECT id, Account.ParentId, Account.Location_Class__c, Account.Category__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];

		if (casesList.isEmpty())
			System.assertEquals(true, false);

		Case c = casesList.get(0);

		// create test account1
		Account account3 = new Account();
		account3.Name = 'Test account Contact2';
		account3.IATACode__c = '4242424123';
		account3.Type = 'IATA Passenger Sales Agent';
		account3.BillingCity = 'Montreal';
		account3.BillingCountry = 'Canada';
		account3.BillingStreet = 'some street';
		account3.Location_Type__c = 'BR';
		account3.Category__c = 'TIDS Agent';
		insert account3;

		c.AccountId = account3.Id;

		update c;

		casesList = [SELECT id, Account.ParentId, Account.Category__c, Account.Location_Class__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];
		c = casesList.get(0);

		AMS_MigrationToolHelper.performValidations(c, 'MAJOR.CHANGES');

		account3.Category__c = 'GSSA Cargo';
		update account3;

		casesList = [SELECT id, Account.ParentId, Account.Category__c, Account.Location_Class__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];
		c = casesList.get(0);

		AMS_MigrationToolHelper.performValidations(c, 'New HO');

		account3.Category__c = 'MSO Member Sales Office';
		update account3;

		casesList = [SELECT id, Account.ParentId, Account.Category__c, Account.Location_Class__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];
		c = casesList.get(0);

		AMS_MigrationToolHelper.performValidations(c, 'New HO');

		account3.Category__c = 'TIDS Agent';
		update account3;

		casesList = [SELECT id, Account.ParentId, Account.Category__c, Account.Location_Class__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];
		c = casesList.get(0);

		AMS_MigrationToolHelper.performValidations(c, 'New HO');

		account3.Category__c = 'Handling Agent';
		update account3;

		casesList = [SELECT id, Account.ParentId, Account.Category__c, Account.Location_Class__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];
		c = casesList.get(0);

		AMS_MigrationToolHelper.performValidations(c, 'New HO');

		account3.Category__c = 'GSA General Sales Agent';
		update account3;

		casesList = [SELECT id, Account.ParentId, Account.Category__c, Account.Location_Class__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];
		c = casesList.get(0);

		AMS_MigrationToolHelper.performValidations(c, 'New HO');

		account3.Location_Type__c = 'BR';
		update account3;

		casesList = [SELECT id, Account.ParentId, Account.Category__c, Account.Location_Class__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c , Financial_Assessment_received__c, Bank_Guarantee_amount__c, Bank_Guarantee_deadline__c, Bank_Guarantee_received__c, Bank_Guarantee_requested__c, Change_effective_as_of__c, Criteria_remarks__c, Documentation_remarks__c, Dossier_reception_date__c, Fees_refund_requested__c, Finalization_checklist__c, Financial_Assessment_deadline__c, Financial_Assessment_requested__c, Financial_Review_Result__c, Invoice_number__c, Local_Inspection_compliant__c, Local_Inspection_deadline__c, Local_Inspection_received__c, Local_Inspection_requested__c, Process_Start_Date__c, Proof_of_payment_received__c, PSAA_EACP_Agreement_received__c, PSAA_signed_copy_sent__c, SAAM_Deadline_Date__c, AIMS_updated__c, Finalized_in_AIMS__c from case];
		c = casesList.get(0);

		AMS_MigrationToolHelper.performValidations(c, 'New HO');

		Test.stopTest();

	}

	@isTest
	static void alignOwnersTest2() {

		Test.startTest();

		// create test account1
		Account account2 = new Account();
		account2.Name = 'Test account Contact';
		account2.IATACode__c = '424242434';
		account2.Type = 'IATA Passenger Sales Agent';
		account2.BillingCity = 'Montreal';
		account2.BillingCountry = 'Canada';
		account2.BillingStreet = 'some street';
		account2.Location_Type__c = 'HO';

		// create test account1
		Account account3 = new Account();
		account3.Name = 'Test account Contact2';
		account3.IATACode__c = '4242424123';
		account3.Type = 'IATA Passenger Sales Agent';
		account3.BillingCity = 'Montreal';
		account3.BillingCountry = 'Canada';
		account3.BillingStreet = 'some street';
		account3.Location_Type__c = 'HO';

		insert new List<Account> {account2, account3};

		Contact contact1 = new Contact(FirstName = 'user1' , LastName = 'lastnameuser1', email = 'user1test@tmail.com', account = account2);
		Contact contact2 = new Contact(FirstName = 'user2' , LastName = 'lastnameuser2', email = 'user2test@tmail.com', account = account2);

		Contact contact3 = new Contact(FirstName = 'user3' , LastName = 'lastnameuser3', email = 'user3test@tmail.com', account = account2);

		Contact contact4 = new Contact(FirstName = 'user4' , LastName = 'lastnameuser4', email = 'user4test@tmail.com', account = account2);

		Contact contact5 = new Contact(FirstName = 'user4' , LastName = 'lastnameuser4', email = 'testuser23@gtst.com', account = account2);

		Contact contact6 = new Contact(FirstName = 'user6' , LastName = 'lastnameuser4', email = 'testuser236@gtst.com', account = account2);

		insert new List<Contact> {contact1, contact2, contact3, contact4, contact5, contact6};

		AMS_Person__c person1 = new AMS_Person__c(Name = 'Person3' , Contact__c = contact4.Id);
		AMS_Person__c person2 = new AMS_Person__c(Name = 'Person4');

		insert new List<AMS_Person__c> {person1, person2};

		AMS_Account_Role__c role1 = new AMS_Account_Role__c(Account__c = account2.Id , Contact__c = contact1.Id);
		AMS_Account_Role__c role2 = new AMS_Account_Role__c(Account__c = account2.Id , Person__c = person1.Id);
		AMS_Account_Role__c role3 = new AMS_Account_Role__c(Account__c = account2.Id , Legacy_System__c = 'AIMS2' , Legacy_External_ID__c = 'ASD123123');
		AMS_Account_Role__c role4 = new AMS_Account_Role__c(Account__c = account2.Id , Contact__c = contact2.Id);
		AMS_Account_Role__c role5 = new AMS_Account_Role__c(Account__c = account2.Id , Contact__c = contact3.Id);
		AMS_Account_Role__c role6 = new AMS_Account_Role__c(Account__c = account2.Id, Owner_Account__c = account3.Id);
		AMS_Account_Role__c role7 = new AMS_Account_Role__c(Account__c = account2.Id, Owner_Account__c = account3.Id, Owner_Name__c = 'user9 lastnameuser9');

		insert new List<AMS_Account_Role__c> {role1, role2, role3, role4, role5, role6, role7};

		Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

		Case saamCase = new Case();
		saamCase.ContactId = contact1.Id;
		saamCase.AccountId = account2.Id;
		saamCase.Subject = 'Test SAAM case2';
		saamCase.Description = 'Test SAAM case2';
		saamCase.Status = 'Open';
		saamCase.RecordTypeId = SAAMcaseRecordTypeId;
		saamCase.Reason1__c = 'New HO';
		insert saamCase;



		AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();

		accreditationObj.SAAM_Case__c = saamCase.Id;

		insert accreditationObj;

		AMS_Accreditation_Contact__c aContact1 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Agency_owner__c = true, Financial_interest__c = 25);
		AMS_Accreditation_Contact__c aContact2 = new AMS_Accreditation_Contact__c(First_name__c = 'user4' , Last_name__c = 'lastnameuser4' ,  Email__c = 'user4test@tmail.com' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Agency_owner__c = true, Financial_interest__c = 25);
		AMS_Accreditation_Contact__c aContact3 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , Agency_owner__c = true, AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Financial_interest__c = 25);
		AMS_Accreditation_Contact__c aContact4 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , Contact__c = contact2.Id, Agency_owner__c = true, AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Financial_interest__c = 25);
		AMS_Accreditation_Contact__c aContact5 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Legacy_External_Id__c = 'ASD123123', Email__c = 'testuser236@gtst.com', Agency_owner__c = true);
		AMS_Accreditation_Contact__c aContact6 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Person_AMS__c = person1.id, Contact__c = contact4.id, Agency_owner__c = true);
		AMS_Accreditation_Contact__c aContact7 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Company__c = account3.Id , Email__c = 'testuser23@gtst.com', Agency_owner__c = true);
		AMS_Accreditation_Contact__c aContact8 = new AMS_Accreditation_Contact__c(Last_name__c = '-' , AMS_Pax_Accreditation_Form__c = accreditationObj.Id, Person_AMS__c = person2.Id, Agency_owner__c = true);

		insert new List<AMS_Accreditation_Contact__c> {aContact1, aContact2, aContact3, aContact4, aContact5, aContact6, aContact7, aContact8};

		AMS_Account_Role__c role8 = new AMS_Account_Role__c(
		    Legacy_System__c = 'AIMS2' ,
		    Legacy_External_ID__c = 'ASD123124',
		    Account__c = saamCase.AccountId
		);

		AMS_Account_Role__c role9 = new AMS_Account_Role__c(
		    Legacy_System__c = 'AIMS2' ,
		    Legacy_External_ID__c = 'ASD123125',
		    Owner_Name__c = 'user9 lastnameuser9',
		    Account__c = saamCase.AccountId
		);

		Contact xc1 = new Contact(FirstName = 'user7', LastName = 'lastnameuser7', Email = 'testuser2367@gtst.com', AccountId = saamCase.AccountId);
		Contact xc2 = new Contact(FirstName = 'user8', LastName = 'lastnameuser8', Email = 'testuser2368@gtst.com', AccountId = saamCase.AccountId);
		Contact xc3 = new Contact(FirstName = 'user9', LastName = 'lastnameuser9', Email = 'testuser2369@gtst.com', AccountId = saamCase.AccountId);
		Contact xc4 = new Contact(FirstName = 'userA', LastName = 'lastnameuserA', Email = 'testuser236A@gtst.com', AccountId = saamCase.AccountId);

		AMS_Accreditation_Contact__c accreditationContact1 = new AMS_Accreditation_Contact__c(Legacy_External_Id__c = 'ASD123124', AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_Name__c = 'user7', Last_Name__c = 'lastnameuser7', Email__c = 'testuser2367@gtst.com', Person_AMS__c = role2.Person__c, Company__c = role6.Owner_Account__c, Agency_owner__c = true);
		AMS_Accreditation_Contact__c accreditationContact2 = new AMS_Accreditation_Contact__c(Legacy_External_Id__c = 'ASD123124', AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_Name__c = 'user8', Last_Name__c = 'lastnameuser8', Email__c = 'testuser2368@gtst.com', Company__c = role6.Owner_Account__c, Agency_owner__c = true);
		AMS_Accreditation_Contact__c accreditationContact3 = new AMS_Accreditation_Contact__c(Legacy_External_Id__c = 'ASD123124', AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_Name__c = 'user9', Last_Name__c = 'lastnameuser9', Email__c = 'testuser2369@gtst.com', Agency_owner__c = true);
		AMS_Accreditation_Contact__c accreditationContact4 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_Name__c = 'user7', Last_Name__c = 'lastnameuser7', Email__c = 'testuser2367@gtst.com', Agency_owner__c = true);
		AMS_Accreditation_Contact__c accreditationContact5 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_Name__c = 'user8', Last_Name__c = 'lastnameuser8', Email__c = 'testuser2368@gtst.com', Agency_owner__c = true);
		AMS_Accreditation_Contact__c accreditationContact6 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_Name__c = 'user9', Last_Name__c = 'lastnameuser9', Email__c = 'testuser2369@gtst.com', Agency_owner__c = true);
		AMS_Accreditation_Contact__c accreditationContact7 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accreditationObj.Id, First_Name__c = 'userA', Last_Name__c = 'lastnameuserA', Email__c = 'testuser236A@gtst.com', Agency_owner__c = false);

		insert new List<Contact> { xc1, xc2, xc3, xc4 };

		accreditationContact5.Name = role8.Owner_Name__c;
		accreditationContact6.Name = role9.Owner_Name__c;

		insert new List<AMS_Account_Role__c> { role8, role9 };

		insert new List<AMS_Accreditation_Contact__c> { accreditationContact1, accreditationContact2, accreditationContact3, accreditationContact4, accreditationContact5, accreditationContact6, accreditationContact7 };

		AMS_MigrationToolHelper.alignOwners(accreditationObj, saamCase);

		AMS_MigrationToolHelper.decode('A');
		AMS_MigrationToolHelper.decode('C');
		AMS_MigrationToolHelper.decode('E');
		AMS_MigrationToolHelper.decode('J');
		AMS_MigrationToolHelper.decode('L');
		AMS_MigrationToolHelper.decode('O');
		AMS_MigrationToolHelper.decode('P');
		AMS_MigrationToolHelper.decode('R');
		AMS_MigrationToolHelper.decode('S');
		AMS_MigrationToolHelper.decode('T');
		AMS_MigrationToolHelper.decode('V');
		AMS_MigrationToolHelper.decode('X');



		Test.stopTest();
    }
	static testMethod void TestCompliant() {

		Test.startTest();

        AMS_MigrationToolHelper a = new AMS_MigrationToolHelper();
        a.isTestCompliant();
		Map<String,String> b = AMS_MigrationToolHelper.newgenCaseReason;
		Map<String, Id> c = AMS_MigrationToolHelper.oscarNewgenRTMap;
		Map<String, String> d = AMS_MigrationToolHelper.processTypeMapNewgen;

		Test.stopTest();
	}
}
