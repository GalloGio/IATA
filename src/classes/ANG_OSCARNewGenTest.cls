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

	@isTest static void changeOfEntityLocationNewHEStandardTest(){

   		AMS_OSCAR_TestDataFactory.createNewGenTestData(AMS_Utils.NEWHESTANDARD);

		AMS_OSCAR__c oscar = 
			[SELECT 
				Id, 
				AMS_Online_Accreditation__c,
				Oscar_Communication_Case_Id__c
			 FROM 
			 	AMS_OSCAR__c 
			 LIMIT 1
			];

        Attachment attc = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = oscar.Oscar_Communication_Case_Id__c,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );

        insert attc;

        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= oscar.AMS_Online_Accreditation__c,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );

        insert owner;

		oscar.ANG_Change_Entity_Location__c = true;
		oscar.Change_of_Entity_Location_within_EU__c = true;
		oscar.STEP6__c = AMS_Utils.PASSED;

		try {
			update oscar;
		}
		catch(Exception e){
			System.assert(e.getMessage().contains(ANG_OscarProcessHelper.NEW_HE_CHANGE_ENTITY_LOCATION_ERROR_MSG));
		}

		oscar.ANG_Change_Entity_Location__c = false;
		oscar.STEP6__c = AMS_Utils.PASSED;
		update oscar;

    }

}