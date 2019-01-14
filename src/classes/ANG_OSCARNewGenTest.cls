@isTest
private class ANG_OSCARNewGenTest {
       
	@isTest static void testNewHEStandardManagerApproval() {
		
		AMS_OSCAR_TestDataFactory.createNewGenTestData(AMS_Utils.NEWHESTANDARD);

		AMS_OSCAR__c oscar = [SELECT Id, RPM_Approval__c, Oscar_Communication_Case_Id__c, STEP12__c FROM AMS_OSCAR__c limit 1];

		oscar.STEP12__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		oscar.STEP34__c = AMS_Utils.PASSED;
		oscar.STEP35__c = AMS_Utils.PASSED;

		update oscar;

		//confirm that email sent is on the case
		List<EmailMessage> approvalEmail = [SELECT Id, ParentId FROM EmailMessage WHERE ParentId =: oscar.Oscar_Communication_Case_Id__c];

		System.assertEquals(approvalEmail.size(), 1);

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');
		List<Agency_Authorization__c> formsofpayment = [SELECT Id, ANG_FormOfPayment_ID__c FROM Agency_Authorization__c WHERE RecordTypeId =: FormOfPaymentRT];

		String check = '';
		for(Agency_Authorization__c fp: formsofpayment)
			check += fp.ANG_FormOfPayment_ID__c;

		System.assert(check.contains('CC'));
		System.assert(check.contains('CA'));
		System.assert(check.contains('EP'));

		//check that agency authorizations are created on the account
		System.assertEquals(formsofpayment.size(), 3);

	}

	@isTest static void testNewAEManagerApprovalAgencyAuthorizationsCopied() {
		
		AMS_OSCAR_TestDataFactory.createNewGenTestData(AMS_Utils.NEWAE);

		Account ae = [Select Id, IATA_ISO_Country__c, RecordTypeId From Account WHERE Name = 'NewGenAgency'];

		Account he = new Account(IATA_ISO_Country__c = ae.IATA_ISO_Country__c, RecordTypeId = ae.RecordTypeId, IATACode__c='1234560',Name='NewGenAgencyHE',Short_Name__c='NewGenAgencyHE');
		insert he;

		ID formOfPayment = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');
		Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = he.Id, RecordTypeId = formOfPayment, Status__c = 'Active', ANG_FormOfPayment_ID__c = 'CC');
		insert aa;

		ae.ParentId = he.Id;
		update ae;

		AMS_OSCAR__c oscar = [SELECT Id, RPM_Approval__c, Oscar_Communication_Case_Id__c, STEP12__c FROM AMS_OSCAR__c WHERE Account__c =: ae.Id];

		//check that AE has no agency authorizations
		List<Agency_Authorization__c> aaList = [SELECT Id FROM Agency_Authorization__c WHERE Account__c =: ae.Id];

		System.assertEquals(0, aaList.size());

		oscar.STEP12__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;

		update oscar;

		//check that AE has one agency authorization
		aaList = [SELECT Id, RecordTypeId FROM Agency_Authorization__c WHERE Account__c =: ae.Id];

		System.assertEquals(1, aaList.size());
		System.assertEquals(formOfPayment, aaList.get(0).RecordTypeId);

	}


	@isTest static void testNewAEManagerApprovalAgencyAuthorizationsNotCopied() {
		
		AMS_OSCAR_TestDataFactory.createNewGenTestData(AMS_Utils.NEWAE);

		Account ae = [Select Id, IATA_ISO_Country__c, RecordTypeId From Account WHERE Name = 'NewGenAgency'];

		Account he = new Account(IATA_ISO_Country__c = ae.IATA_ISO_Country__c, RecordTypeId = ae.RecordTypeId, IATACode__c='1234560',Name='NewGenAgencyHE',Short_Name__c='NewGenAgencyHE');
		insert he;

		ID formOfPayment = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		ae.ParentId = he.Id;
		update ae;

		AMS_OSCAR__c oscar = [SELECT Id, RPM_Approval__c, Oscar_Communication_Case_Id__c, STEP12__c FROM AMS_OSCAR__c WHERE Account__c =: ae.Id];

		//check that AE has no agency authorizations
		List<Agency_Authorization__c> aaList = [SELECT Id FROM Agency_Authorization__c WHERE Account__c =: ae.Id];

		System.assertEquals(0, aaList.size());

		oscar.STEP12__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;

		update oscar;

		//check that AE has one agency authorization
		aaList = [SELECT Id, ANG_FormOfPayment_ID__c FROM Agency_Authorization__c WHERE Account__c =: ae.Id];

		System.assertEquals(1, aaList.size());
		System.assertEquals('CC', aaList.get(0).ANG_FormOfPayment_ID__c);

	}
}