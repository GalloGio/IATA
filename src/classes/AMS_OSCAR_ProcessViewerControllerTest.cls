@isTest
private class AMS_OSCAR_ProcessViewerControllerTest {

	@testSetup static void setup(){
		AMS_OSCAR_TestDataFactory.createOSCARtestData();

		AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP8__c, STEP9__c, STEP10__c, STEP2__c, STEP6__c, STEP11__c, STEP15__c FROM AMS_OSCAR__c limit 1];

		System.assertEquals('Not Started', oscar.STEP8__c);
		System.assertEquals('Not Started', oscar.STEP9__c);
		System.assertEquals('Passed', oscar.STEP10__c);
		System.assertEquals('Not Started', oscar.STEP2__c);
		System.assertEquals('Not Started', oscar.STEP6__c);
		System.assertEquals('Not Started', oscar.STEP11__c);
		System.assertEquals('Not Started', oscar.STEP15__c);
		
		IATA_ISO_Country__c isoTest = new IATA_ISO_Country__c(
			Name = 'Iso Country Name Test',
			CurrencyIsoCode = 'EUR',
			ISO_Code_Numeric__c = 620,
			ISO_Code__c = 'PT',
			AIMS_Area_ID__c='1',
			ANG_Enable_NewGen__c = true,
			ANG_IEP_Model__c = 'Model A',
			Multicountry_Enabled__c = true
		);
		insert isoTest;

		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;

		Account accountToUpdateRiskEventCashAndCashless = new Account(
				Name ='account To Update Risk Event Cash to Cashless',
				Type = 'IATA Passenger Sales Agent',
				Sector__c='Travel Agent',
				Location_Type__c = AMS_Utils.HE,
				Location_Class__c = 'P',
				ANG_FA_Opt_out__c = false,
				IATACode__c='12345600',
				IATA_ISO_Country__c = isoTest.Id,
				BillingCountry='Iso Country Name Test',
				ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
				Status__c = AMS_Utils.ACC_S9_APPROVED,
				ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
				Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
				RecordTypeId = accRT
			);
		insert accountToUpdateRiskEventCashAndCashless;

		oscar.RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES;
		oscar.Account__c = accountToUpdateRiskEventCashAndCashless.Id;
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE;
		update oscar;

		Case testCase = ISSP_ObjectFactory.createNewCase();
		testCase.BSPCountry__c = 'Hong Kong (SAR), China';
		testCase.Reason1__c = 'Agency';
		testCase.Customer_recovery__c = false;
		testCase.BounceEmailCounter__c = 0.0;
		testCase.Case_Language__c = 'English';
		testCase.Subject = 'Test 006';
		testCase.Reopened_case__c = 0.0;
		testCase.IFAP_Country_ISO__c = 'tq';
		testCase.AccountId = accountToUpdateRiskEventCashAndCashless.id;
		testCase.Oscar__c = oscar.Id;
		insert testCase;

		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
		insert isoc;

		AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id, Account_Name__c = accountToUpdateRiskEventCashAndCashless.Name, ANG_Accreditation_Model_to_Change__c = AMS_Utils.ACCREDITATIONMODEL_CASH);
		insert onlineAccreditation;

		oscar.AMS_Online_Accreditation__c = onlineAccreditation.id;
		upsert oscar;

		AMS_Pax_Accreditation_Form__c onlineAccreditation2 = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id, Account_Name__c = accountToUpdateRiskEventCashAndCashless.Name, ANG_Accreditation_Model_to_Change__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS);
		insert onlineAccreditation2;

		AMS_OSCAR__c oscar2 = new AMS_OSCAR__c(AMS_Online_Accreditation__c = onlineAccreditation2.id, RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES, Account__c = accountToUpdateRiskEventCashAndCashless.Id, ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE);
		insert oscar2;


		Agency_Applied_Change_code__c ch1 = new Agency_Applied_Change_code__c(OSCAR__c = oscar2.id, Account__c = accountToUpdateRiskEventCashAndCashless.Id, Change_Code__c = 'CHA');
		insert ch1;
		Test.setCreatedDate(ch1.id, Date.today().addDays(-3));

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
		Test.setCreatedDate(re1.id, Date.today().addDays(-10));
	}

	@isTest static void test_ProcessViewer() {

		Boolean result;
		String stringResult;
		AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP8__c, STEP9__c, STEP10__c, STEP2__c, STEP6__c, STEP11__c, STEP15__c,Step34__c, Step35__c FROM AMS_OSCAR__c limit 1];

		System.assertEquals('Not Started', oscar.STEP8__c);
		System.assertEquals('Not Started', oscar.STEP9__c);
		System.assertEquals('Passed', oscar.STEP10__c);
		System.assertEquals('Not Started', oscar.STEP2__c);
		System.assertEquals('Not Started', oscar.STEP6__c);
		System.assertEquals('Not Started', oscar.STEP11__c);
		System.assertEquals('Not Started', oscar.STEP15__c);

		oscar.STEP8__c = 'Passed';
		oscar.STEP9__c = 'Failed';
		oscar.STEP10__c = 'Not Applicable';
		oscar.STEP2__c = 'Late';
		oscar.STEP6__c = 'In Progress';
		oscar.STEP11__c = 'Not Started';
		oscar.STEP15__c = 'Something else';
		oscar.STEP12__c = 'Something else';
		oscar.Payment_requested__c = Date.today();

		update oscar;

		Test.startTest();

		PageReference pageAMS_OSCAR_ProcessViewer = Page.AMS_OSCAR_ProcessViewer;
		pageAMS_OSCAR_ProcessViewer.getParameters().put('Id', oscar.Id);
		Test.setCurrentPage(pageAMS_OSCAR_ProcessViewer);

		//ApexPages.StandardController sc = new ApexPages.StandardController(oscar);
		AMS_OSCAR_ProcessViewerController controller = new AMS_OSCAR_ProcessViewerController();

		Boolean isNotNewGenProcessValue = controller.isNotNewGenProcess;

		oscar.Process__c = AMS_Utils.NEWGESTANDARD;
		update oscar;
		result = controller.showRequiredOverlay;
		stringResult = controller.getEffectiveDate();
		result = controller.getIsAgencyChange();
		result = controller.isNewGenHEProcess;
		result = controller.isAnalystProfile;
		System.assertNotEquals(null, controller.NGCONVERSIONMCTOSTANDARD);
		System.assertNotEquals(null, controller.NGCONVERSIONTOMULTICOUNTRY);
		System.assertNotEquals(null, controller.CONFIRM_MC_CONVERSION_MSG);
		System.assert(controller.isParentOscar);
		System.assertEquals(null, controller.cannotProceedConversionToStandardMessage);
		System.assert(! controller.isGEwithNoHierarchy);
		System.assert(! controller.isAMSCheckRemittance);
		System.assert(! controller.getIsGDIWithNoParentCase());
		System.assert(! controller.isNewGEConversion);
		System.assert(! controller.isNewGE);
		System.assert(! controller.isValidationCompleted);
		System.assert(! controller.isNewgenRT);
		System.assert(controller.blockFAoptOut);
		System.assert(!controller.hideFAoptOut);
		Test.stopTest();
	}

	@isTest static void test_ProcessViewer_2() {
		Test.startTest();
		AMS_OSCAR_ProcessViewerController ctr = new AMS_OSCAR_ProcessViewerController();
		ctr.checkAMSRemittance(new AMS_OSCAR__c());
		Test.stopTest();
	}

	@isTest static void test_ProcessViewer2() {

		Test.startTest();
		AMS_OSCAR_ProcessViewerController controller = new AMS_OSCAR_ProcessViewerController();
		Boolean a1 = controller.isToRemoveFieldsUI;
		Boolean a2 = controller.isPCICompliant;
		Set<String> a3 = controller.processToRemoveFields;
		Test.stopTest();
	}

	@isTest static void test_ProcessViewerReactiveRisckEvent() {
		
		AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP8__c, STEP9__c, STEP10__c, STEP2__c, STEP6__c, STEP11__c, STEP15__c,Step34__c, Step35__c FROM AMS_OSCAR__c limit 1];

		Test.startTest();

		PageReference pageAMS_OSCAR_ProcessViewer = Page.AMS_OSCAR_ProcessViewer;
		pageAMS_OSCAR_ProcessViewer.getParameters().put('Id', oscar.Id);
		Test.setCurrentPage(pageAMS_OSCAR_ProcessViewer);
		AMS_OSCAR_ProcessViewerController controller = new AMS_OSCAR_ProcessViewerController();
		System.assert(! controller.isGEwithNoHierarchy);
		
		Test.stopTest();
	}

}
