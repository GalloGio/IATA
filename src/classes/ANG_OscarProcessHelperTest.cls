@isTest
private class ANG_OscarProcessHelperTest {
	
	@testSetup static void setup(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
		Id caseRT = AMS_Utils.getId('Case', 'OSCAR_Communication');
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewGenAgency',Short_Name__c='NewGenAgency', Location_Class__c = 'P', Location_Type__c = 'HE', Remittance_frequency__c = 'Monthly', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');

		insert a1;
        
        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		ID oscarNewHeRt = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NG New HE').getRecordTypeId();

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NEWHESTANDARD, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = oscarNewHeRt);

		insert oscar;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		ID rtNew = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.getRecordTypeInfosByName().get('Travel Agent - Head Entity Standard no Cash').getRecordTypeId();

		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

		theAccreditation.Account_Name__c='NEWGEN-559 HE5';
		theAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theAccreditation.Branch_Office_Country__c= ctry.Id;
		theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
		theAccreditation.Branch_Office_City__c='sdfsdfdf';
		theAccreditation.IATA_ISO_State__c= stt.Id;
		theAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
		theAccreditation.Branch_Office_Phone__c='123123123';
		theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
		theAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
		theAccreditation.Abbreviated_Address__c='sdfsdf';
		theAccreditation.Remittance_frequency__c='Monthly';
		theAccreditation.Solicitation_Flag__c=false;
		theAccreditation.Location_Class__c='P';
		theAccreditation.Location_Type__c='HE';
		theAccreditation.SAAM_Case__c=oscarCase.Id;
		theAccreditation.Account_Name__c = a1.Id;

		insert theAccreditation;

		ID personRT = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();

		AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = theAccreditation.Id, 
			First_name__c='Bugs', Last_name__c='Bunny', Agency_owner__c = true, Email__c='bugsandbunny@imagsd.com' , PhoneNational__c = '123123123',
			Phone__c='123123123', Contact__c = co1.Id, Financial_interest__c = 100, RecordTypeId=personRT);

		insert acontact;

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.AMS_Online_Accreditation__c = theAccreditation.Id;
		oscar.Is_PCI_compliant__c = 'Yes';
        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		update oscar;
		
	}

	@isTest static void testIATACodeGenerationOKNoDueDiligenceCase() {

		System.debug('Starting testIATACodeGenerationOKNoDueDiligenceCase');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationOKNoDueDiligenceCase Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKNoDueDiligenceCase Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}
	
	@isTest static void testIATACodeGenerationOKWithDueDiligenceCase() {

		System.debug('Starting testIATACodeGenerationOKWithDueDiligenceCase');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationOKWithDueDiligenceCase Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKWithDueDiligenceCase Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0]);
		System.assertEquals('0',result[2]); // due diligence was created

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}
	
	@isTest static void testIATACodeGenerationOKTwice() {

		System.debug('Starting testIATACodeGenerationOKTwice');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		System.debug('Finished the first IATA Code Generation.');

		system.debug('testIATACodeGenerationOKTwice Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKTwice Result message is:'+result[1]);

		System.assertEquals('0',result[0]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		system.debug('testIATACodeGenerationOKTwice Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKTwice Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

	@isTest static void testIATACodeGenerationOKAlreadyIATACodeGenerated() {
		
		System.debug('Starting testIATACodeGenerationOKAlreadyIATACodeGenerated');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		oscar.Flag_IATACode__c = true;
		update oscar;

		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Test.startTest();

		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		system.debug('testIATACodeGenerationOKAlreadyIATACodeGenerated Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKAlreadyIATACodeGenerated Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

	@isTest static void testIATACodeGenerationOKAlreadyDataCopied() {
		
		System.debug('Starting testIATACodeGenerationOKAlreadyDataCopied');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		oscar.Flag_Data_to_Account__c = true;
		update oscar;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		system.debug('testIATACodeGenerationOKAlreadyDataCopied Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKAlreadyDataCopied Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}


	@isTest static void testIATACodeGenerationOKAlreadyChangeCodeNew() {
		
		System.debug('Starting testIATACodeGenerationOKAlreadyChangeCodeNew');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Test.startTest();

		ANG_OscarProcessHelper.isIATACodeGenerationRunning = true;

        Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Account__c = oscar.Account__c, OSCAR__c = oscar.Id, Change_Code__c = 'NEW',  Sent_to_external_system__c = false);

        insert aacc;
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		system.debug('testIATACodeGenerationOKAlreadyChangeCodeNew Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKAlreadyChangeCodeNew Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

	@isTest static void testIATACodeGenerationOKWithDueDiligenceCaseInProgress() {

		System.debug('Starting testIATACodeGenerationOKWithDueDiligenceCaseInProgress');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Account acct = new Account(id = oscar.Account__c);
		acct.Due_Diligence_Status__c = AMS_Utils.IN_PROGRESS;
		update acct;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationOKWithDueDiligenceCaseInProgress Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKWithDueDiligenceCaseInProgress Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

 	@isTest static void testIATACodeGenerationOKWithNOSTEP6PASSED() {
		
		System.debug('Starting testIATACodeGenerationOKWithNOSTEP6PASSED');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		oscar.STEP6__c = AMS_Utils.IN_PROGRESS;
		update oscar;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationOKWithNOSTEP6PASSED Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKWithNOSTEP6PASSED Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('-1',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.debug('Oscar is:'+oscar);

		System.assertEquals(false,oscar.Flag_IATACode__c);
		System.assertNotEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(false,oscar.Flag_Data_to_Account__c);
		System.assertEquals(false,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}


	@isTest static void testIATACodeGenerationBadDataMigration() {
		
		System.debug('Starting testIATACodeGenerationBadDataMigration');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
				
		
		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(id = oscar.AMS_Online_Accreditation__c);
		theAccreditation.Branch_Office_Email__c='sdf+dfgdg@~df3434.comsdsd';
		update theAccreditation;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationBadDataMigration Result code is:'+result[0]);
		system.debug('testIATACodeGenerationBadDataMigration Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('-1',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.debug('Oscar is:'+oscar);

		System.assertEquals(false,oscar.Flag_IATACode__c);
		System.assertEquals(false,oscar.Flag_Data_to_Account__c);
		System.assertEquals(false,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}
}