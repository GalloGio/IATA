@isTest
private class AMS_MigrationToolHelperTest {
	
	@testSetup static void setup(){

		RecordType SAAMcaseRecordType = [Select r.Id, r.Name from RecordType r where r.Name = 'SAAM' limit 1];

		// create test account1
		Account account1 = new Account();
		account1.Name = 'Test account';
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
		saamCase.RecordTypeId = SAAMcaseRecordType.Id;
		saamCase.Reason1__c = 'New HO';
		insert saamCase;


		List<Case> casesList = [SELECT id, Status, Financial_Assessment_received__c,Bank_Guarantee_amount__c,Bank_Guarantee_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_requested__c,Change_effective_as_of__c,Criteria_remarks__c,Documentation_remarks__c,Dossier_reception_date__c,Fees_refund_requested__c,Finalization_checklist__c,Financial_Assessment_deadline__c,Financial_Assessment_requested__c,Financial_Review_Result__c,Invoice_number__c,Local_Inspection_compliant__c,Local_Inspection_deadline__c,Local_Inspection_received__c,Local_Inspection_requested__c,Process_Start_Date__c,Proof_of_payment_received__c,PSAA_EACP_Agreement_received__c,PSAA_signed_copy_sent__c,SAAM_Deadline_Date__c,AIMS_updated__c,Finalized_in_AIMS__c from case];

		if(!casesList.isEmpty()) {

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
	
	static testMethod void test_verifyCaseMigration() {

		Test.startTest();

		AMS_MigrationToolHelper.decode('V');

		List<Case> casesList = [SELECT id, Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c ,Financial_Assessment_received__c,Bank_Guarantee_amount__c,Bank_Guarantee_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_requested__c,Change_effective_as_of__c,Criteria_remarks__c,Documentation_remarks__c,Dossier_reception_date__c,Fees_refund_requested__c,Finalization_checklist__c,Financial_Assessment_deadline__c,Financial_Assessment_requested__c,Financial_Review_Result__c,Invoice_number__c,Local_Inspection_compliant__c,Local_Inspection_deadline__c,Local_Inspection_received__c,Local_Inspection_requested__c,Process_Start_Date__c,Proof_of_payment_received__c,PSAA_EACP_Agreement_received__c,PSAA_signed_copy_sent__c,SAAM_Deadline_Date__c,AIMS_updated__c,Finalized_in_AIMS__c from case];

		if(casesList.isEmpty())
			System.assertEquals(true,false);

		Case c = casesList.get(0);

		AMS_MigrationToolHelper.CaseContainer cc = new AMS_MigrationToolHelper.CaseContainer(c,false);

		cc = AMS_MigrationToolHelper.migratecases(cc);

		if(cc.errorMessage != null)
			System.assertEquals(null,cc.errorMessage);

		List<AMS_OSCAR__c> oscars = [SELECT Id,Status__c, Name, First_Step_Completed__c, Assessment_Performed_Date__c,Bank_Guarantee_deadline__c,Bank_Guarantee_amount__c,Bank_Guarantee_received__c,Bank_Guarantee_requested__c,Change_effective_as_of__c,Criteria_remarks__c,Documentation_remarks__c,Dossier_Reception_Date__c,Fees_refund_requested__c,Finalization_checklist__c,Financial_Assessment_deadline__c,Financial_Assessment_requested__c,Financial_Review_Result__c,Billing_Document_Number__c,Local_Inspection_compliant__c,Local_Inspection_deadline__c,Local_Inspection_received__c,Local_Inspection_requested__c,Process_Start_Date__c,Proof_of_payment_received__c,PSAA_EACP_Agreement_received__c,Welcome_Pack_Sent__c,Sanity_check_deadline__c,Update_AIMS_Rejection_Date__c,Update_AIMS_Rejection__c,Update_AIMS_Approval_Date__c,Update_AIMS_Approval__c from AMS_OSCAR__c];

		if(oscars.isEmpty())
			System.assertEquals(true,false);

		AMS_OSCAR__c oscar = oscars.get(0);

		System.assertEquals(c.Financial_Assessment_received__c,oscar.Assessment_Performed_Date__c);
		System.assertEquals(c.Bank_Guarantee_deadline__c,oscar.Bank_Guarantee_deadline__c);
		System.assertEquals(c.Bank_Guarantee_received__c,oscar.Bank_Guarantee_received__c);
		System.assertEquals(c.Bank_Guarantee_requested__c,oscar.Bank_Guarantee_requested__c);
		System.assertEquals(c.Change_effective_as_of__c,oscar.Change_effective_as_of__c);
		System.assertEquals(c.Criteria_remarks__c,oscar.Criteria_remarks__c);
		System.assertEquals(c.Documentation_remarks__c,oscar.Documentation_remarks__c);
		System.assertEquals(c.Dossier_reception_date__c,oscar.Dossier_Reception_Date__c);
		System.assertEquals(c.Fees_refund_requested__c,oscar.Fees_refund_requested__c);
		System.assertEquals(c.Finalization_checklist__c,oscar.Finalization_checklist__c);
		System.assertEquals(c.Financial_Assessment_deadline__c,oscar.Financial_Assessment_deadline__c);
		System.assertEquals(c.Financial_Assessment_requested__c,oscar.Financial_Assessment_requested__c);
		System.assertEquals(c.Invoice_number__c,oscar.Billing_Document_Number__c);
		System.assertEquals(c.Local_Inspection_deadline__c,oscar.Local_Inspection_deadline__c);
		System.assertEquals(c.Local_Inspection_received__c,oscar.Local_Inspection_received__c);
		System.assertEquals(c.Local_Inspection_requested__c,oscar.Local_Inspection_requested__c);
		System.assertEquals(c.Process_Start_Date__c,oscar.Process_Start_Date__c);
		System.assertEquals(c.Proof_of_payment_received__c,oscar.Proof_of_payment_received__c);
		System.assertEquals(c.PSAA_EACP_Agreement_received__c,oscar.PSAA_EACP_Agreement_received__c);
		System.assertEquals(c.PSAA_signed_copy_sent__c,oscar.Welcome_Pack_Sent__c);
		System.assertEquals(c.SAAM_Deadline_Date__c,oscar.Sanity_check_deadline__c);
		System.assertEquals(c.AIMS_updated__c,oscar.Update_AIMS_Rejection_Date__c);
		System.assertEquals(c.Finalized_in_AIMS__c,oscar.Update_AIMS_Approval_Date__c);

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


    static testMethod void test_verifyCaseMigration2() {

		Test.startTest();

		List<Case> casesList = [SELECT id, Account.Category__c, Account.Location_Type__c , Financial_Assessment_compliant__c, Status, RecordType__c, Reason1__c, AccountId, BSPCountry__c ,Financial_Assessment_received__c,Bank_Guarantee_amount__c,Bank_Guarantee_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_requested__c,Change_effective_as_of__c,Criteria_remarks__c,Documentation_remarks__c,Dossier_reception_date__c,Fees_refund_requested__c,Finalization_checklist__c,Financial_Assessment_deadline__c,Financial_Assessment_requested__c,Financial_Review_Result__c,Invoice_number__c,Local_Inspection_compliant__c,Local_Inspection_deadline__c,Local_Inspection_received__c,Local_Inspection_requested__c,Process_Start_Date__c,Proof_of_payment_received__c,PSAA_EACP_Agreement_received__c,PSAA_signed_copy_sent__c,SAAM_Deadline_Date__c,AIMS_updated__c,Finalized_in_AIMS__c from case];

		if(casesList.isEmpty())
			System.assertEquals(true,false);

		Case c = casesList.get(0);

		AMS_MigrationToolHelper.CaseContainer cc = new AMS_MigrationToolHelper.CaseContainer(c,true);

		cc = AMS_MigrationToolHelper.migratecases(cc);

		AMS_MigrationToolHelper.performValidations(c,'New HO');

		AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();
		
		accreditationObj.SAAM_Case__c = c.Id;

		insert accreditationObj;

		accreditationObj = [select Id, SAAM_Case__c from AMS_Pax_Accreditation_Form__c LIMIT 1].get(0);

		AMS_Account_Role__c role = new AMS_Account_Role__c();
		role.Legacy_External_ID__c = '123213';
		role.Owner_Name__c = 'TEST';
		role.Legacy_System__c = 'AIMS';

		insert role;

		role = [SELECT Id , Legacy_External_ID__c,Owner_Name__c, Legacy_System__c, Owner_Account__c, Contact__c, Contact_Email__c, Percentage__c, Person__c, Contact_Phone__c from AMS_Account_Role__c LIMIT 1].get(0);

		AMS_MigrationToolHelper.createAccreditationContact(accreditationObj, role, 'NEW.HO.1.0');

		AMS_MigrationToolHelper.alignOwners(accreditationObj, c);

		Test.stopTest();
    }
}