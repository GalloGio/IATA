@isTest
private class AMS_OSCAR_Case_Detail_ControllerTest {

	@testSetup static void setup(){
		//AMS_OSCAR_TestDataFactory.createOSCARtestData();
		AMS_OSCAR_TestDataFactory.createOSCARtestDataAccHier();
		AMS_OSCAR__c oscar = [SELECT Id, Account__c FROM AMS_OSCAR__c limit 1];
		Case c = [SELECT Id FROM Case WHERE Oscar__c = :oscar.Id];

		AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(
			SAAM_Case__c = c.id,
			CASS_Number__c = '123',
			Location_Class__c = 'C',
			IATA_ISO_State__c = [SELECT Id FROM IATA_ISO_State__c LIMIT 1][0].Id,
			Branch_Office_Country__c = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1][0].Id
		);
		insert accre;

		oscar.Process__c = AMS_Utils.AGENCYCHANGES;
		oscar.AMS_Online_Accreditation__c = accre.Id;
		update oscar;

		ANG_AgencyChangesConfig__c confs = new ANG_AgencyChangesConfig__c(
			Name ='Combination07',
			TC_VMFR__c = true,
			TCA_Sanity_check__c = 'CAD',
			TCA_Application_withdrawal__c = 'CWD',
			Valid_Accreditation_Models__c = 'ALL'
		);

		insert confs;

	}

	@isTest static void test_OSCARCaseDetail() {
		Case c = [SELECT Id FROM Case WHERE Oscar__c IN (SELECT Id FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '') LIMIT 1];

		PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
		pg.getParameters().put('id', c.Id);
		Test.setCurrentPage(pg);

		Test.startTest();

			AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();
			controller.cancel();
			controller.save();

			System.assert(controller.saveAction, 'Error saving');
			System.assert(!controller.hasEditableFields, 'Found editable fields');
			System.assert(controller.getExistOscarInspections(), 'No inspections found');
			System.assert(!controller.getRfPicklistValues().isEmpty());

			Id idCorrRT = controller.corrRT;
			Boolean bIsVATnumberSpecialCase = controller.isVATnumberSpecialCase;
			Boolean bIsBranchAbroadSelected = controller.isBranchAbroadSelected;
			bIsVATnumberSpecialCase = controller.isVATnumberSpecialCase;
			bIsBranchAbroadSelected = controller.isBranchAbroadSelected;

		Test.stopTest();
	}

	@isTest static void test_OSCARCaseDetail2(){
		Test.startTest();

		Case c = [SELECT Id FROM Case WHERE Oscar__c IN (SELECT Id FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '') LIMIT 1];

		Id aRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name= 'Testland',
			Region__c = 'Americas',
			Iso_code__c = 'TL',
			ISO_Code_Numeric__c=99,
			BSP__c = 'Yes',
			ANG_Enable_NewGen__c = true,
			OSCAR_enabled__c = true
		);

		insert country;

		Account a = new Account(
			Name='TesteAccount',
			Location_Class__c = 'P',
			Location_Type__c = 'HE',
			Reason_for_creation__c = 'Headquarter is missing',
			RecordTypeId = aRTId,
			IATA_ISO_Country__c = country.id
		);

		insert a;


			AMS_Pax_Accreditation_Form__c accredForm = [SELECT Id, Branch_Office_Country__c FROM AMS_Pax_Accreditation_Form__c][0];

			accredForm.Branch_Office_Country__c = country.Id;
			accredForm.Location_Class__c = 'P';
			accredForm.CASS_Number__c = '';

			update accredForm;

			AMS_Oscar__c oscar = [SELECT Id, Process__c, Account__c, ANG_Type_Of_Change__c FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != ''];

			oscar.Account__c = a.Id;
			oscar.Process__c = AMS_Utils.NEWHELITE;

			update oscar;

			Id settlementRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');

			AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
				Name = 'test settlement',
				RecordTypeId = settlementRTId
			);

			insert settlement;

			country.AMS_Settlement_System__c = settlement.Id;
			update country;

			AMS_Operation__c opCode = new AMS_Operation__c(
				Name = 'test operation',
				Settlement__c = settlement.id,
				Allow_multiple_remittances__c = false,
				Country__c = country.id
			);

			insert opCode;

			List<ANG_BSP_Attributes__c> bSPAttributes = new List<ANG_BSP_Attributes__c>();

			ANG_BSP_Attributes__c bSPAttributes1 = new ANG_BSP_Attributes__c(
				Class_Type__c  = 'P',
				Remittance_Frequency__c = 'D',
				Operation__c = opCode.Id,
				BSP__c = settlement.Id
			);
			bSPAttributes.add(bSPAttributes1);

				ANG_BSP_Attributes__c bSPAttributes2 = new ANG_BSP_Attributes__c(
				Class_Type__c  = 'P',
				Remittance_Frequency__c = 'V',
				Operation__c = opCode.Id,
				BSP__c = settlement.Id
			);
			bSPAttributes.add(bSPAttributes2);

			insert bSPAttributes;

			AMS_Agency_Operations__c agencyOp = new AMS_Agency_Operations__c(
				Account__c = a.id,
				Operation__c = opCode.Id
			);

			insert agencyOp;


			PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
			pg.getParameters().put('id', c.Id);
			Test.setCurrentPage(pg);

			AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();

			controller.accreditationObj.Remittance_Frequency__c = controller.getRfPicklistValues()[0].getValue();

			controller.save();

			opCode.Allow_multiple_remittances__c = true;
			update opcode;

			controller = new AMS_OSCAR_Case_Detail_Controller();

			controller.oscarobj.RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES;
			controller.oscarobj.Process__c = AMS_Utils.NGCHANGES;
			controller.oscarobj.ANG_Type_Of_Change__c = 'VMFR';

			System.assert(!controller.getRfPicklistValues().isEmpty());

			System.assert(controller.remittanceFrequencyToShow == '');

			controller.accreditationObj.Remittance_Frequency__c = 'V';

			System.assert(controller.remittanceFrequencyToShow.contains('Weekly'));

			controller.accreditationObj.Remittance_Frequency__c = 'V;D';

			System.assert(controller.remittanceFrequencyToShow.contains('Daily'));
			System.assert(controller.isNewAE == false);
			System.assert(controller.displayErrorMsg == false);

		Test.stopTest();
	}

	@isTest
	public static void test_OSCARCaseRemmitancePerState()
	{
		Test.startTest();

		Case c = [SELECT Id FROM Case WHERE Oscar__c IN (SELECT Id FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '') LIMIT 1];

		Id aRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name= 'Testland',
			Region__c = 'Americas',
			Iso_code__c = 'TL',
			ISO_Code_Numeric__c=99,
			BSP__c = 'Yes',
			ANG_Enable_NewGen__c = true,
			OSCAR_enabled__c = true
		);

		insert country;

		Account a = new Account(
			Name='TesteAccount',
			Location_Class__c = 'P',
			Location_Type__c = 'HE',
			Reason_for_creation__c = 'Headquarter is missing',
			RecordTypeId = aRTId,
			IATA_ISO_Country__c = country.id
		);

		insert a;

		AMS_Pax_Accreditation_Form__c accredForm = [SELECT Id, Branch_Office_Country__c FROM AMS_Pax_Accreditation_Form__c][0];

		accredForm.Branch_Office_Country__c = country.Id;
		accredForm.Location_Class__c = 'P';
		accredForm.CASS_Number__c = '';
		accredForm.Remittance_frequency__c = 'W';

		update accredForm;

		AMS_Oscar__c oscar = [SELECT Id, Process__c, Account__c, ANG_Type_Of_Change__c FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != ''];

		oscar.Account__c = a.Id;
		oscar.Process__c = AMS_Utils.NGCHANGES;
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION;
		oscar.RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES;

		update oscar;

		Id settlementRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
			Name = 'test settlement',
			RecordTypeId = settlementRTId,
			Remittance_Frequency_per_State__c = true
		);

		insert settlement;

		country.AMS_Settlement_System__c = settlement.Id;
		update country;

		AMS_Operation__c opCode = new AMS_Operation__c(
			Name = 'test operation',
			Settlement__c = settlement.id,
			Allow_multiple_remittances__c = false,
			Country__c = country.id
		);

		insert opCode;

		List<ANG_BSP_Attributes__c> bSPAttributes = new List<ANG_BSP_Attributes__c>();

		ANG_BSP_Attributes__c bSPAttributes1 = new ANG_BSP_Attributes__c(
			Class_Type__c  = 'P',
			Remittance_Frequency__c = 'D',
			Operation__c = opCode.Id,
			BSP__c = settlement.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_BSP_Attributes__c', 'Remittance_Frequency')
		);
		bSPAttributes.add(bSPAttributes1);

		ANG_BSP_Attributes__c bSPAttributes2 = new ANG_BSP_Attributes__c(
			Class_Type__c  = 'P',
			Remittance_Frequency__c = 'V',
			Operation__c = opCode.Id,
			BSP__c = settlement.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_BSP_Attributes__c', 'Remittance_Frequency')
		);
		bSPAttributes.add(bSPAttributes2);

		insert bSPAttributes;

		AMS_Agency_Operations__c agencyOp = new AMS_Agency_Operations__c(
			Account__c = a.id,
			Operation__c = opCode.Id
		);

		insert agencyOp;


		PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
		pg.getParameters().put('id', c.Id);
		Test.setCurrentPage(pg);

		AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();

		controller.accreditationObj.Remittance_Frequency__c = controller.getRfPicklistValues()[0].getValue();

		controller.save();

		opCode.Allow_multiple_remittances__c = true;
		update opcode;

		controller = new AMS_OSCAR_Case_Detail_Controller();

		controller.oscarobj.RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES;
		controller.oscarobj.Process__c = AMS_Utils.NGCHANGES;
		controller.oscarobj.ANG_Type_Of_Change__c = 'VMFR';

		System.assert(!controller.getRfPicklistValues().isEmpty());

		System.assertEquals('4 times per month', controller.remittanceFrequencyToShow);

		controller.accreditationObj.Remittance_Frequency__c = 'V';

		System.assert(controller.remittanceFrequencyToShow.contains('Weekly'));

		controller.accreditationObj.Remittance_Frequency__c = 'V;D';

		System.assert(controller.remittanceFrequencyToShow.contains('Daily'));
		System.assert(controller.isNewAE == false);
		System.assert(controller.displayErrorMsg == false);

		System.assertEquals(false, controller.isNewMulticountryAE);
		System.assertEquals(false, controller.isAEAccount);
		//System.assertEquals(false, controller.isDuplicatedDGR);
		//System.assertEquals(null, controller.duplicatedDGR_msg);
		System.assertEquals(1, controller.getItemsForPreferredRHC().size());
		System.assertEquals(3, controller.getAvailableAccModel().size());
		System.assertEquals(2, controller.populateRightOptions(new List<String> { 'W', 'D' }).size());
		System.assertEquals(1, controller.getRfPicklistValues().size());
		System.assertEquals(false, controller.isOSCARCorrection);
		System.assertEquals(false, controller.isStandardAgency);
		System.assertEquals(false, controller.isSplitMcHierarchy);

		controller.rfPerState = true;
		controller.getRfPicklistValues();

		controller.rightOptionsRF = new List<SelectOption> { new SelectOption('op1', 'op1') };
		controller.save();

		controller.rightOptionsRF.add(new SelectOption('op2', 'op2'));
		controller.rightOptionsRF.add(new SelectOption('op3', 'op3'));
		controller.save();
		
		controller.rfPerState = null;
		controller.accreditationObj = null;
		System.assertEquals(false, controller.rfPerState);

		Test.stopTest();
	}

	@isTest static void test_OSCARCaseDetail3(){

		AMS_OSCAR__c oscar = [SELECT Id, AMS_Online_Accreditation__c FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '' LIMIT 1];

		Id aRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name= 'Testland',
			Region__c = 'Americas',
			Iso_code__c = 'TL',
			ISO_Code_Numeric__c=99,
			BSP__c = 'Yes',
			ANG_Enable_NewGen__c = true,
			OSCAR_enabled__c = true
		);

		insert country;
		Test.startTest();

		Account a = new Account(
			Name='TesteAccount',
			Location_Class__c = 'P',
			Location_Type__c = 'HE',
			Reason_for_creation__c = 'Headquarter is missing',
			RecordTypeId = aRTId,
			IATA_ISO_Country__c = country.id
		);

		insert a;

		AMS_Pax_Accreditation_Form__c accredForm = [SELECT Id, Branch_Office_Country__c FROM AMS_Pax_Accreditation_Form__c WHERE Id = :oscar.AMS_Online_Accreditation__c];

		accredForm.Branch_Office_Country__c = country.Id;
		accredForm.Location_Class__c = 'P';
		accredForm.CASS_Number__c = '';

		update accredForm;

		Id settlementRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(
			Name = 'test settlement',
			RecordTypeId = settlementRTId
		);

		insert settlement;

		country.AMS_Settlement_System__c = settlement.Id;
		update country;

		AMS_Operation__c opCode = new AMS_Operation__c(
			Name = 'test operation',
			Settlement__c = settlement.id,
			Allow_multiple_remittances__c = true,
			Country__c = country.id
		);

		insert opCode;

		ANG_BSP_Attributes__c bSPAttributes = new ANG_BSP_Attributes__c(
			Class_Type__c  = 'P',
			Remittance_Frequency__c = 'V',
			Operation__c = opCode.Id,
			BSP__c = settlement.Id
		);

		insert bSPAttributes;

		AMS_Agency_Operations__c agencyOp = new AMS_Agency_Operations__c(
			Account__c = a.id,
			Operation__c = opCode.Id
		);

		insert agencyOp;


		PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
		pg.getParameters().put('id', oscar.Id);
		Test.setCurrentPage(pg);

		AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();

		controller.getRfPicklistValuesAMS();

		Test.stopTest();
	}

	@isTest static void chinaConversionHideStagingAreaTest(){

		Case c = [SELECT Id, OSCAR__c
			 	FROM Case
			 	WHERE Oscar__c IN
						(SELECT Id
			 		 FROM AMS_OSCAR__c
			 		 WHERE AMS_Online_Accreditation__c != ''
			 		)
			 LIMIT 1];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();

		oscar.id = c.OSCAR__c;
		oscar.Process__c = AMS_Utils.NGCHINACONVERSION;

		Test.startTest();
			update oscar;

			PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
			pg.getParameters().put('id', c.Id);
			Test.setCurrentPage(pg);

			AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();

			System.assert(!controller.isChangeOfLocation, 'Should not be a change of location');
			System.assert(!controller.showStagingArea, 'The staging area for China Conversions should be hidden');
		Test.stopTest();
	}

	@isTest static void chinaConversionShowOscarOnGoingWarningTest(){

		Case c =
			[SELECT
				Id,
				OSCAR__c,
				AccountId
			 FROM
			 	Case
			 WHERE
			 	Oscar__c IN
			 		(SELECT
			 			Id
			 		 FROM
			 		 	AMS_OSCAR__c
			 		 WHERE
			 		 	AMS_Online_Accreditation__c != ''
			 		)
			 LIMIT 1];

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();

		oscar.id = c.OSCAR__c;
		oscar.Process__c = AMS_Utils.NGCHINACONVERSION;

		update oscar;

		Account account =
			[SELECT
				Id,
				RecordType.DeveloperName
			 FROM
			 	Account
			 WHERE
			 	 Id != :c.AccountId
			 AND RecordType.DeveloperName = 'Standard_Account'
			][0];

		AMS_OSCAR__c pendingOscar = new AMS_OSCAR__c();
		pendingOscar.Account__c = account.Id;
		pendingOscar.Process__c = AMS_Utils.AGENCYCHANGES;
		insert pendingOscar;

		Test.startTest();

		Case oscarCase = new Case(
			Oscar__c = pendingOscar.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'),
			AccountId = account.Id
		);
		insert oscarCase;

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(
			Hierarchy_Name__c='Test Hierarchy'
		 	);

		insert hierarchy;

		AMS_Agencies_relationhip__c agenciesRel = new AMS_Agencies_relationhip__c(
			Relationship_details__c='Test',
			Hierarchy__c = hierarchy.id,
			Child_Account__c = account.id,
			Parent_Account__c = c.AccountId
		 	);

		insert agenciesRel;

		PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
		pg.getParameters().put('id', c.Id);
		Test.setCurrentPage(pg);

		AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();

		system.assert(!controller.showStagingArea, 'The staging area for China Conversions should be hidden');

		ApexPages.Message[] pageMessages = ApexPages.getMessages();

		system.debug(pageMessages);

		System.assertNotEquals(0, pageMessages.size());

		Boolean messageFound = false;

		for(ApexPages.Message message : pageMessages) {

			system.debug('MESSAGE DETAIL: ' + message.getDetail());

			if(message.getDetail().contains(Label.ANG_OnGoing_OSCAR_Warning)){
				messageFound = true;
			}

		}

		System.assertEquals(messageFound, true, 'The warning message \'' + Label.ANG_OnGoing_OSCAR_Warning + '\' should be shown');

		Test.stopTest();

	}

	@isTest
	public static void test_ProcessViewerReactiveRisckEvent()
	{

		Test.startTest();
		Case testCase = [SELECT Id FROM Case WHERE Oscar__c IN (SELECT Id FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '') LIMIT 1];

		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name= 'Testland',
			Region__c = 'Americas',
			Iso_code__c = 'TL',
			ISO_Code_Numeric__c=99,
			BSP__c = 'Yes',
			ANG_Enable_NewGen__c = true,
			OSCAR_enabled__c = true
		);

		insert country;

		Account accountToUpdateRiskEventCashAndCashless = new Account(
				Name ='account To Update Risk Event Cash to Cashless',
				Type = 'IATA Passenger Sales Agent',
				Sector__c='Travel Agent',
				Location_Type__c = AMS_Utils.HE,
				Location_Class__c = 'P',
				ANG_FA_Opt_out__c = false,
				IATACode__c='12345600',
				IATA_ISO_Country__c = country.Id,
				BillingCountry='Iso Country Name Test',
				ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
				Status__c = AMS_Utils.ACC_S9_APPROVED,
				ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
				Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
				RecordTypeId = accRT
			);
		insert accountToUpdateRiskEventCashAndCashless;


		AMS_Oscar__c oscar = [SELECT Id, Process__c, Account__c, ANG_Type_Of_Change__c FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '' LIMIT 1];
		
		testCase.Oscar__c = oscar.id;
		upsert testCase;
		
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
		insert isoc;

		AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id, Account_Name__c = accountToUpdateRiskEventCashAndCashless.Name, ANG_Accreditation_Model_to_Change__c = AMS_Utils.ACCREDITATIONMODEL_CASH);
		insert onlineAccreditation;
		
		oscar.RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES;
		oscar.Account__c = accountToUpdateRiskEventCashAndCashless.Id;
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE;
		oscar.AMS_Online_Accreditation__c = onlineAccreditation.id;
		upsert oscar;

		AMS_Pax_Accreditation_Form__c onlineAccreditation2 = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id, Account_Name__c = accountToUpdateRiskEventCashAndCashless.Name, ANG_Accreditation_Model_to_Change__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS);
		insert onlineAccreditation2;

		AMS_OSCAR__c oscar2 = new AMS_OSCAR__c(AMS_Online_Accreditation__c = onlineAccreditation2.id, RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES, Account__c = accountToUpdateRiskEventCashAndCashless.Id, ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE);
		insert oscar2;		

		Agency_Applied_Change_code__c ch1 = new Agency_Applied_Change_code__c(OSCAR__c = oscar2.id, Account__c = accountToUpdateRiskEventCashAndCashless.Id, Change_Code__c = 'CHA');
		insert ch1;

		ANG_Agency_Risk_Calculation__c rule = new ANG_Agency_Risk_Calculation__c(
			ANG_Order__c = 1,
			ANG_Occurrence_Num__c = 1,
			ANG_Adjusted__c = ANG_Risk_Helper.ADJ_NO,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
			RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES);
		insert rule;
		
		ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(
				Name = 'Risk Event Test',
				ANG_Description__c = 'Risk Event Test',
				ANG_Expiration__c = 24,
				ANG_Risk_ID__c = 'testRiskId',
				ANG_Agency_Risk_Calculation__c = rule.Id,
				Limit_Cash_conditions__c = false
			);
		insert ret;

		ANG_Agency_Risk_Event__c re1 = new ANG_Agency_Risk_Event__c(
				ANG_AccountId__c = accountToUpdateRiskEventCashAndCashless.id,
				ANG_Risk_Type__c = ret.id,
				ANG_Issued_Date__c = System.today(),
				Applicable_for_re_activation__c = true,
				ANG_Expiration_Date__c = Date.today().addDays(-10),
				ANG_Event_Status__c = ANG_Risk_Helper.STATUS_INACTIVE_CASHLESS 
			);

		insert re1;
		
		Test.stopTest();

		Test.setCreatedDate(ch1.id, Date.today().addDays(-3));
		Test.setCreatedDate(re1.id, Date.today().addDays(-10));


		PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
		pg.getParameters().put('id', testCase.Id);
		Test.setCurrentPage(pg);
		

		AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();
		system.assertEquals(true, controller.isEventRiskToActivate);
	}

}
