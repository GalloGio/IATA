@isTest
private class ANG_AccountTriggerHandlerTest {

	@testSetup static void createData() {
		List<Portal_Applications__c> pas = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);
		Portal_Applications__c iataEasyPayEdenRed = pas.get(0);
		iataEasyPayEdenRed.Name = 'IATA EasyPay (EDENRED)';
		iataEasyPayEdenRed.Functional_Role__c = 'IATA EasyPay (EDENRED)';
		Portal_Applications__c iataEasyPayMSTS = pas.get(1);
		iataEasyPayMSTS.Name = 'IATA EasyPay (MSTS)';
		iataEasyPayMSTS.Functional_Role__c = 'IATA EasyPay (MSTS)';
		insert pas;

		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Prov', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/calculatedrhc/{agencyId}/v1', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Bal', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/consumedrhc/{agencyId}/v1/', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		customsettings.add(new ANG_CalloutMapping__c(Name = 'MAPDF', Change_Code__c = 'MAPDF', CalloutClass__c = 'ANG_CalloutIEPMasterdata', Action__c = 'PUT', Event_Type__C = 'MS_Update', Credential__c = '/agencies/v1/', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'ChangeCode'));
		customsettings.add(new ANG_CalloutMapping__c(Name = 'MBDIL', Change_Code__c = 'MBDIL', CalloutClass__c = 'ANG_CalloutIEPMasterdata', Action__c = 'PUT', Event_Type__C = 'MS_Update', Credential__c = '/agencies/v1/', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'ChangeCode'));
		customsettings.add(new ANG_CalloutMapping__c(Name = 'MBPDD', Change_Code__c = 'MBPDD', CalloutClass__c = 'ANG_CalloutIEPMasterdata', Action__c = 'PUT', Event_Type__C = 'MS_Update', Credential__c = '/agencies/v1/', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'ChangeCode'));
		customsettings.add(
			new ANG_CalloutMapping__c(
				Name = 'IEP_PCI_Compliance',
				Change_Code__c = 'IEPPC',
				CalloutClass__c = 'ANG_CalloutIEPMasterdata',
				Action__c = 'PUT',
				Event_Type__C = 'MS_Update',
				Credential__c = '/agencies/v1/',
				Named_Credential__c = 'Mulesoft_Credential_Masterdata',
				Integration_System__c = 'Mulesoft',
				Type__c = 'Account',
				Field__c = 'Is_PCI_compliant__c'
			)
		);

		insert customsettings;

		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
		Id riskStatusAssessmentRT = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT;

		List<AMS_Settlement_System__c> settlementSystemList = new List<AMS_Settlement_System__c>();
		settlementSystemList.add(new AMS_Settlement_System__c(name = 'BSP-01', Enable_Provisional_RHC_Request__c=true));
		settlementSystemList.add(new AMS_Settlement_System__c(name = 'BSP-02', Enable_Provisional_RHC_Request__c=true));
		settlementSystemList.add(new AMS_Settlement_System__c(name = 'BSP-03', Enable_Provisional_RHC_Request__c=true));
		insert settlementSystemList;

		List<ANG_BSP_Attributes__c> bspAttrLst = new List<ANG_BSP_Attributes__c>();
		for(AMS_Settlement_System__c iss:settlementSystemList){
			bspAttrLst.addAll(AMS_OSCAR_TestDataFactory.createOperationAttributes(iss));
		}
		insert bspAttrLst;

		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();

		IATA_ISO_Country__c isoTest = new IATA_ISO_Country__c(
				Name = 'Iso Country Name Test',
				CurrencyIsoCode = 'EUR',
				ISO_Code_Numeric__c = 620,
				ISO_Code__c = 'PT',
				AIMS_Area_ID__c='1',
				ANG_Enable_NewGen__c = true,
				ANG_IEP_Model__c = 'Model A',
				Multicountry_Enabled__c = true,
				AMS_Settlement_System__c = settlementSystemList[0].id
			);
		countries.add(isoTest);

		IATA_ISO_Country__c isoTest2 = new IATA_ISO_Country__c(
				Name = 'Iso Country Name Test2',
				CurrencyIsoCode = 'EUR',
				ISO_Code_Numeric__c = 625,
				ISO_Code__c = 'ES',
				AIMS_Area_ID__c='1',
				ANG_Enable_NewGen__c = true,
				ANG_IEP_Model__c = 'Model B',
				AMS_Settlement_System__c = settlementSystemList[1].id
			);
		countries.add(isoTest2);

		IATA_ISO_Country__c ukCountry = new IATA_ISO_Country__c(
				Name = 'United Kingdom',
				CurrencyIsoCode = 'EUR',
				ISO_Code_Numeric__c = 999,
				ISO_Code__c = 'UK',
				AIMS_Area_ID__c='1',
				ANG_Enable_NewGen__c = true,
				ANG_IEP_Model__c = 'Model B+',
				AMS_Settlement_System__c = settlementSystemList[2].id
			);

		countries.add(ukCountry);

		insert countries;

		List<Account> accs = new List<Account>();

		Account a = new Account(
				Name ='Test',
				Type = 'IATA Passenger Sales Agent',
				Sector__c='Travel Agent',
				Location_Type__c = AMS_Utils.HE,
				Location_Class__c = 'P',
				ANG_FA_Opt_out__c = false,
				IATACode__c='12345671',
				IATA_ISO_Country__c = countries[0].Id,
				BillingCountry='Iso Country Name Test',
				ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
				Status__c = AMS_Utils.ACC_S9_APPROVED,
				ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
				Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
				RecordTypeId = accRT
			);
		accs.add(a);

		Account a5 = new Account(
				Name ='Test5',
				Type = 'IATA Passenger Sales Agent',
				Sector__c='Travel Agent',
				Location_Type__c = AMS_Utils.GE,
				Location_Class__c = 'P',
				ANG_FA_Opt_out__c = false,
				IATACode__c='12345675',
				IATA_ISO_Country__c = countries[0].Id,
				BillingCountry='Iso Country Name Test',
				ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
				Status__c = AMS_Utils.ACC_S9_APPROVED,
				ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
				Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
				RecordTypeId = accRT
			);
		accs.add(a5);

		Account a2 = new Account(
				Name ='Test2',
				Type = 'IATA Passenger Sales Agent',
				Sector__c='Travel Agent',
				Location_Type__c = AMS_Utils.HE,
				Location_Class__c = 'P',
				ANG_FA_Opt_out__c = false,
				IATACode__c='12345672',
				IATA_ISO_Country__c = countries[1].Id,
				BillingCountry='Iso Country Name Test2',
				ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
				Status__c = AMS_Utils.ACC_S9_APPROVED,
				ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
				Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
				RecordTypeId = accRT
			);
		accs.add(a2);

		Account a3 = new Account(
				Name ='UK Test',
				Type = 'IATA Passenger Sales Agent',
				Sector__c='Travel Agent',
				Location_Type__c = AMS_Utils.HE,
				Location_Class__c = 'P',
				ANG_FA_Opt_out__c = false,
				IATACode__c='12345673',
				IATA_ISO_Country__c = ukCountry.Id,
				BillingCountry='UK Test',
				ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
				Status__c = AMS_Utils.ACC_S9_APPROVED,
				ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
				Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
				RecordTypeId = accRT
			);
		accs.add(a3);

		insert accs;

		insert new ANG_RHC_Information__c (ANG_AccountId__c = a.Id);

		ANG_Agency_Risk_Calculation__c calcA = new ANG_Agency_Risk_Calculation__c(
			RecordTypeId = riskStatusAssessmentRT,
			ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY,
			ANG_Risk_History_Assessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
			ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_A,
			ANG_Limit_Cash_Condition__c = false);

		ANG_Agency_Risk_Calculation__c calcB = new ANG_Agency_Risk_Calculation__c(
			RecordTypeId = riskStatusAssessmentRT,
			ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
			ANG_Risk_History_Assessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
			ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_B,
			ANG_Limit_Cash_Condition__c = false);

		ANG_Agency_Risk_Calculation__c calcB2 = new ANG_Agency_Risk_Calculation__c(
			RecordTypeId = riskStatusAssessmentRT,
			ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY,
			ANG_Risk_History_Assessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,
			ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_B,
			ANG_Limit_Cash_Condition__c = false);

		ANG_Agency_Risk_Calculation__c calcC = new ANG_Agency_Risk_Calculation__c(
			RecordTypeId = riskStatusAssessmentRT,
			ANG_Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
			ANG_Risk_History_Assessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,
			ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_C,
			ANG_Limit_Cash_Condition__c = true);

		ANG_Agency_Risk_Calculation__c calcC2 = new ANG_Agency_Risk_Calculation__c(
			RecordTypeId = riskStatusAssessmentRT,
		 	ANG_Financial_Review_Result__c = null,
		 	ANG_Risk_History_Assessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,
		 	ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_C,
		 	ANG_Limit_Cash_Condition__c = true);

		ANG_Agency_Risk_Calculation__c rule = new ANG_Agency_Risk_Calculation__c(
			ANG_Order__c = 1,
			ANG_Occurrence_Num__c = 1,
			ANG_Adjusted__c = ANG_Risk_Helper.ADJ_NO,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
			RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES);

		insert new List<ANG_Agency_Risk_Calculation__c>{calcA, calcB, calcB2, calcC, calcC2, rule};

		ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(
				Name = 'Risk Event Test',
				ANG_Description__c = 'Risk Event Test',
				ANG_Expiration__c = 24,
				ANG_Risk_ID__c = 'testRiskId',
				ANG_Agency_Risk_Calculation__c = rule.Id,
				Limit_Cash_conditions__c = false
			);
		insert ret;
	}

	static testMethod void test_riskStatus_allcases() {
		Test.startTest();
		Account a = AccountSelector.selectNewGenFieldsMapByName(null, new Set<String>{'Test'}, null).values().get(0);
		// fill accounts last financial review result and risk history and assert new risk status
		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] first update should be A');
		a.Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY;
		a.ANG_HE_RiskHistoryAssessment__c = AMS_Utils.PASSED;
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, Subject FROM Cases) FROM Account WHERE Id = :a.Id];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_A, a.ANG_RiskStatus__c);

		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] second update should be B');
		// change values and check downgrade and SAAM case creation
		a.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, IATACode__c, (SELECT Id, Subject FROM Cases ORDER BY CreatedDate) FROM Account WHERE Id = :a.Id];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_B, a.ANG_RiskStatus__c);
		System.assertEquals(1, a.Cases.size());
		System.assertEquals('Test - ' + a.IATACode__c + ' - Downgrade Risk Status', a.Cases[0].Subject);


		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] third update should be C');
		// change values one more time and check downgrade and OSCAR creation
		a.ANG_HE_RiskHistoryAssessment__c =  AMS_Utils.FAILED;
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, RecordType.DeveloperName FROM Cases ORDER BY CreatedDate) FROM Account WHERE Id = :a.Id];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_C, a.ANG_RiskStatus__c);
		System.assert([SELECT Id, ANG_CashCondition__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].ANG_CashCondition__c);

		Test.stopTest();
	}

	static testMethod void test_RHCupdate() {
		Account a = AccountSelector.selectNewGenFieldsMapByName(null, new Set<String>{'Test'}, null).values().get(0);
		a.Status__c = AMS_Utils.ACC_S0_TERMINATED;

		update a;

		Test.startTest();

		a.Status__c = AMS_Utils.ACC_S9_APPROVED;

		update a;

		Test.stopTest();
	}

	static testMethod void test_shortNameModification() {
		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
		ID standardRT = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'Standard_Account');

		Account a1 = new Account(Name = 'NameTest1', IATACode__c = '12344560', TradeName__c = 'tradeName1', RecordTypeId = standardRT,      Short_Name__c = 'ShortNameTest1Example1');
		Account a2 = new Account(Name = 'NameTest2', IATACode__c = '12344568', TradeName__c = 'tradeName2', RecordTypeId = accRT, Short_Name__c = 'ShortNameTest1Example2');
		Account a3 = new Account(Name = 'NameTest3', IATACode__c = '12344569', TradeName__c = '', RecordTypeId = accRT, Short_Name__c = 'ShortNameTest1Example3');
		insert new List<Account>{a1,a2,a3};

		Test.startTest();

		Map<String,Account> accountMap = AccountSelector.selectNewGenFieldsMapByName(null, new Set<String>{'NameTest1', 'NameTest2', 'NameTest3'}, null);

		System.assertEquals('ShortNameTest1Example1',accountMap.get('NameTest1').Short_Name__c);
		System.assertEquals('tradeName2',accountMap.get('NameTest2').Short_Name__c);
		System.assertEquals('NameTest3',accountMap.get('NameTest3').Short_Name__c);

		a1.Name = 'NameTest11';
		a2.IATACode__c = '12344566';
		a2.TradeName__c = 'tradeName22';
		a3.Name = 'NameTest33';
		a3.Short_Name__c = 'ShortNameTest1Example33';
		a3.TradeName__c = 'tradeName3';

		update new List<Account>{a1,a2,a3};

		accountMap = AccountSelector.selectNewGenFieldsMapByName(null, new Set<String>{'NameTest11', 'NameTest2', 'NameTest33'}, null);

		System.assertEquals('ShortNameTest1Example1',accountMap.get('NameTest11').Short_Name__c);
		System.assertEquals('tradeName22',accountMap.get('NameTest2').Short_Name__c);
		System.assertEquals('tradeName3',accountMap.get('NameTest33').Short_Name__c);

		Test.stopTest();
	}

	static testMethod void test_updateRHCInformation_OptIN_OptOUT() {

		//
		// Test ANG_FA_Opt_out__c TRUE to FALSE (Oscar)
		//

		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
		ID standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		IATA_ISO_Country__c isoTest = [SELECT Id
									FROM IATA_ISO_Country__c
									WHERE Name = 'Iso Country Name Test'];

		Account a = new Account(ANG_FA_Opt_out__c = true,
								Name = 'NameTest1',
								IATACode__c = '12344567',
								TradeName__c = 'tradeName1',
								RecordTypeId = standardRT,
								Short_Name__c = 'ShortNameTest1Example1',
								IATA_ISO_Country__c = isoTest.Id);

		insert a;

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		List<ANG_RHC_Information__c> rhcList1 = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c, ANG_AccountId__c, ANG_Financial_Security__c,
													   RHC_Amount_Equals_FS_Percent__c, ANG_RHC_Amount_Equals_FS__c,
													   ANG_CashCondition__c, ANG_Exceeding_Financial_Security__c,
													   ANG_RHC_Amount_Forecasted__c,
													   Amount_At_Risk_USD__c, Forecasted_Tier__c, RHC_Amount_USD__c, Tier__c, Tiered_Provisional_Amount__c
												  from ANG_RHC_Information__c
												 Where ANG_AccountId__c =: a.id];

		ANG_RHCHelper.calculateRHCAmount(rhcList1);

		rhcList1[0].CurrencyIsoCode = 'USD';
		rhcList1[0].ANG_RME_Amount__c = 200;
		rhcList1[0].ANG_RHC_Amount__c = rhcList1[0].ANG_RHC_Amount_Forecasted__c;
		upsert rhcList1[0];

		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();

		message.provisionalRHC = 300;
		message.storedBaseCurrency = 'USD';
		message.consumedRHCAmount = 100;
		message.consumedRHCPercentage = 0.1;
		message.iataCode = '12344567';
		message.eventTime = System.now();
		message.storedRHCValue = 200;

		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		a.ANG_FA_Opt_out__c = false;

		Test.startTest();

		update a;

		//forcing call as test will not "chain" processes
		//new ANG_UpdateRHCInformationBatch(new Set<Id>{a.Id}, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 100).execute(null);
		new ANG_UpdateRHCInformationQueueable(new Set<Id>{a.Id}, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 100).execute(null);
		Test.stopTest();

		List<ANG_RHC_Information__c> rhcList = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c
												  from ANG_RHC_Information__c
												 Where ANG_AccountId__c =: a.id];

		System.assertEquals(message.provisionalRHC, rhcList[0].ANG_RHC_Amount_Provisional__c);
		System.assertEquals(200, rhcList[0].ANG_RME_Amount__c);
	}

	static testMethod void test_updateRHCInformation_OptIN_OptOUT_ALT() {

		//
		// Test ANG_FA_Opt_out__c TRUE to FALSE (Oscar)
		//

		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
		ID standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		IATA_ISO_Country__c isoTest = [SELECT Id
									FROM IATA_ISO_Country__c
									WHERE Name = 'Iso Country Name Test'];

		Account a = new Account(ANG_FA_Opt_out__c = true,
								Name = 'NameTest1',
								IATACode__c = '12344567',
								TradeName__c = 'tradeName1',
								RecordTypeId = standardRT,
								Short_Name__c = 'ShortNameTest1Example1',
								IATA_ISO_Country__c = isoTest.Id);

		insert a;

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		List<ANG_RHC_Information__c> rhcList1 = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c, ANG_AccountId__c, ANG_Financial_Security__c,
													   RHC_Amount_Equals_FS_Percent__c, ANG_RHC_Amount_Equals_FS__c,
													   ANG_CashCondition__c, ANG_Exceeding_Financial_Security__c,
													   ANG_RHC_Amount_Forecasted__c,
													   Amount_At_Risk_USD__c, Forecasted_Tier__c, RHC_Amount_USD__c, Tier__c, Tiered_Provisional_Amount__c
												  from ANG_RHC_Information__c
												 Where ANG_AccountId__c =: a.id];

		ANG_RHCHelper.calculateRHCAmount(rhcList1);

		rhcList1[0].CurrencyIsoCode = 'USD';
		rhcList1[0].ANG_RME_Amount__c = 200;
		rhcList1[0].ANG_RHC_Amount__c = rhcList1[0].ANG_RHC_Amount_Forecasted__c;
		upsert rhcList1[0];

		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();

		message.provisionalRHC = 300;
		message.storedBaseCurrency = 'USD';
		message.consumedRHCAmount = 100;
		message.consumedRHCPercentage = 0.1;
		message.iataCode = '12344567';
		message.eventTime = System.now();
		message.storedRHCValue = 200;

		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		a.ANG_FA_Opt_out__c = false;

		Test.startTest();

		update a;

		//forcing call as test will not "chain" processes
		//new ANG_UpdateRHCInformationBatch(new Set<Id>{a.Id}, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 100).execute(null);
		new ANG_UpdateRHCInformationQueueable(new Set<Id>{a.Id}, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true).execute(null);
		Test.stopTest();

		List<ANG_RHC_Information__c> rhcList = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c
												  from ANG_RHC_Information__c
												 Where ANG_AccountId__c =: a.id];

		System.assertEquals(message.provisionalRHC, rhcList[0].ANG_RHC_Amount_Provisional__c);
		System.assertEquals(200, rhcList[0].ANG_RME_Amount__c);
	}

	static testMethod void test_updateRHCInformation_OptIN_OptOUT_2() {

		Account a = [SELECT Id, IATACode__c FROM Account][0];

  		Contact cont = new Contact(
				lastName ='lastName',
				Financial_Assessment_Contact__c = true,
				AccountId = a.Id,
				email ='test@test.com'
			);
		insert cont;

		ANG_Risk_Event_Type__c ret = [Select Id from ANG_Risk_Event_Type__c Where Name = 'Risk Event Test'];

		ANG_Agency_Risk_Event__c re1 = new ANG_Agency_Risk_Event__c(
				ANG_AccountId__c = a.id,
				ANG_Risk_Type__c = ret.id,
				ANG_Issued_Date__c = System.today(),
				ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE
			);

		insert re1;

		Test.startTest();

		Case cFS = new Case(
				Subject = 'rception case',
				AccountId = a.Id,
				contactId = cont.Id,
				Status = 'Open',
				Assessment_Performed_Date__c = system.today(),
				Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY,
				RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review'),
				IFAP_Area__c = 'asda44'
			);
		insert cFS;

		cFS.Status = AMS_Utils.CASE_STATUS_FINANCIAL_SECURITY_REQUESTED;

		List<ANG_RHC_Information__c> rhcList1 = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c, ANG_AccountId__c, ANG_Financial_Security__c,
													   RHC_Amount_Equals_FS_Percent__c, ANG_RHC_Amount_Equals_FS__c,
													   ANG_CashCondition__c, ANG_Exceeding_Financial_Security__c,
													   ANG_RHC_Amount_Forecasted__c,
													   Amount_At_Risk_USD__c, Forecasted_Tier__c, RHC_Amount_USD__c, Tier__c, Tiered_Provisional_Amount__c
												  from ANG_RHC_Information__c
												 Where ANG_AccountId__c =: a.id];

		ANG_RHCHelper.calculateRHCAmount(rhcList1);

		rhcList1[0].CurrencyIsoCode = 'USD';
		rhcList1[0].ANG_RME_Amount__c = 200;
		rhcList1[0].ANG_RHC_Amount__c = rhcList1[0].ANG_RHC_Amount_Forecasted__c;
		upsert rhcList1[0];

		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();

		message.provisionalRHC = 300;
		message.storedBaseCurrency = 'USD';
		message.consumedRHCAmount = 100;
		message.consumedRHCPercentage = 0.1;
		message.iataCode = a.IATACode__c;
		message.eventTime = System.now();
		message.storedRHCValue = 200;

		Test.setMock(HttpCalloutMock.class, new HttpResponseGenerator(200, JSON.serialize(message)));

		update cFS;

		//forcing call as test will not "chain" processes
		//new ANG_UpdateRHCInformationBatch(new Set<Id>{a.Id}, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 100).execute(null);
		new ANG_UpdateRHCInformationQueueable(new Set<Id>{a.Id}, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 100).execute(null);
		Test.stopTest();

		List<ANG_RHC_Information__c> rhcList = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c
												  from ANG_RHC_Information__c
												 Where ANG_AccountId__c =: a.id];

		System.assertEquals(message.provisionalRHC, rhcList[0].ANG_RHC_Amount_Provisional__c);
		System.assertEquals(200, rhcList[0].ANG_RME_Amount__c);
	}

	@isTest static void test_CreateIEPOscars() {

		List<Account> accs = [SELECT Id, ANG_IEP_Status__c FROM Account WHERE Name = 'Test' OR Name = 'Test2' ORDER BY NAME ASC];

		List<Contact> cons = new List<Contact>();
		Contact con1 = new Contact(LastName = 'con1',
				Email = 'test1@istest.newgen',
				Preferred_Language__c = 'English',
				BSP_CASS_Payment_contact__c = true,
				Financial_Assessment_Contact__c = true,
				AccountId = accs[0].Id
		);
		cons.add(con1);

		Contact con2 = new Contact(LastName = 'con2',
				Email = 'test2@istest.newgen',
				Preferred_Language__c = 'English',
				BSP_CASS_Payment_contact__c = true,
				Financial_Assessment_Contact__c = true,
				AccountId = accs[1].Id
		);
		cons.add(con2);

		insert cons;


		Map<String, Portal_Applications__c> easyPayNameMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{'IATA EasyPay (EDENRED)', 'IATA EasyPay (MSTS)'});

		List<Portal_Application_Right__c> pars = new List<Portal_Application_Right__c> ();
		pars.add(new Portal_Application_Right__c(Right__c = 'Access Granted', ANG_Portal_Service_Role__c = 'IEP Admin', Portal_Application__c = easyPayNameMap.get('IATA EasyPay (EDENRED)').Id, Contact__c = con1.Id ));
		pars.add(new Portal_Application_Right__c(Right__c = 'Access Granted', ANG_Portal_Service_Role__c = 'IEP Admin', Portal_Application__c = easyPayNameMap.get('IATA EasyPay (MSTS)').Id, Contact__c = con2.Id ));
		insert pars;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

		for (Account a :accs){
			a.ANG_IEP_Status__c = 'In Progress';
		}

		update accs;

		List<AMS_Oscar__c> oscars = [SELECT Id, STEP17__c FROM AMS_Oscar__c WHERE Process__c = :AMS_Utils.IEPMODELAACCOUNTSETUP OR Process__c = :AMS_Utils.IEPMODELBACCOUNTSETUP];

		System.assertEquals(2,oscars.size());

		for (AMS_Oscar__c oscar : oscars){
			oscar.STEP17__c = 'Passed';
		}

		update oscars;

		Test.stopTest();

		System.assertEquals(2, [SELECT Id FROM AMS_Agency_Updates__c WHERE Change_Code__c = 'MAPDF' OR Change_Code__c ='MBDIL'].size());
	}

	@isTest static void testChangeFOPsStatusAccordingly(){

		List<Agency_Authorization__c> fops = new List<Agency_Authorization__c>();
		Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');
		Account a = [SELECT Id,Is_PCI_compliant__c FROM Account WHERE Name = 'Test'];

		Agency_Authorization__c cashfop = new Agency_Authorization__c(Account__c = a.id, ANG_FormOfPayment_ID__c = 'CA', RecordTypeId = formOfPaymentRT);
		   fops.add(cashfop);

		   Agency_Authorization__c creditCardfop = new Agency_Authorization__c(Account__c = a.id, ANG_FormOfPayment_ID__c = 'CC', RecordTypeId = formOfPaymentRT);
		   fops.add(creditCardfop);

		   Agency_Authorization__c bopMethod = new Agency_Authorization__c(Account__c = a.id, ANG_FormOfPayment_ID__c = 'EP', RecordTypeId = formOfPaymentRT);
		   fops.add(bopMethod);
		   insert fops;

		a.Status__c = AMS_Utils.ACC_S0_TERMINATED;
		update a;

		for(Agency_Authorization__c aa : [SELECT Status__c FROM Agency_Authorization__c ]){
			system.assertEquals(aa.Status__c, 'Non-Active');
		}

		a.Status__c = AMS_Utils.ACC_S9_APPROVED;
		update a;

		for(Agency_Authorization__c aa : [SELECT ANG_FormOfPayment_ID__c, Status__c FROM Agency_Authorization__c ]){

			if(aa.ANG_FormOfPayment_ID__c == AMS_Utils.CC)
				system.assertEquals(aa.Status__c, 'Non-Active');
			else
				system.assertEquals(aa.Status__c, 'Active');
		}
	}

	@isTest static void dueDiligenceModelBPlusTest(){

		List<Account> accs = [SELECT Id, ANG_IEP_Status__c FROM Account WHERE Name = 'UK Test'];

		List<Contact> cons = new List<Contact>();
		Contact con1 = new Contact(LastName = 'con1',
				Email = 'test1@istest.newgen',
				Preferred_Language__c = 'English',
				BSP_CASS_Payment_contact__c = true,
				Financial_Assessment_Contact__c = true,
				AccountId = accs[0].Id
		);
		cons.add(con1);

		insert cons;

		Map<String, Portal_Applications__c> easyPayNameMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{'IATA EasyPay (EDENRED)'});
		List<Portal_Application_Right__c> pars = new List<Portal_Application_Right__c> ();
		pars.add(new Portal_Application_Right__c(Right__c = 'Access Granted', ANG_Portal_Service_Role__c = 'IEP Admin', Portal_Application__c = easyPayNameMap.get('IATA EasyPay (EDENRED)').Id, Contact__c = con1.Id ));
		insert pars;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

		for (Account a :accs){
			a.ANG_IEP_Status__c = 'In Progress';
		}

		update accs;

		List<AMS_Oscar__c> oscars = [SELECT Id, STEP17__c FROM AMS_Oscar__c WHERE Process__c = :AMS_Utils.IEPMODELBPLUSACCOUNTSETUP];

		for (AMS_Oscar__c oscar : oscars){
			oscar.STEP17__c = 'Passed';
		}

		update oscars;

		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM AMS_Agency_Updates__c WHERE Change_Code__c = :AMS_Utils.MBPDD_CHANGE_CODE].size());

	}

	@isTest static void pciCompliantUpdateTriggerMasterDataTest() {

		List<Account> accs = [SELECT Id, ANG_IEP_Status__c FROM Account WHERE Name = 'Test' OR Name = 'Test2' ORDER BY NAME ASC];

		List<Contact> cons = new List<Contact>();
		Contact con1 = new Contact(LastName = 'con1',
				Email = 'test1@istest.newgen',
				Preferred_Language__c = 'English',
				BSP_CASS_Payment_contact__c = true,
				Financial_Assessment_Contact__c = true,
				AccountId = accs[0].Id
		);
		cons.add(con1);

		Contact con2 = new Contact(LastName = 'con2',
				Email = 'test2@istest.newgen',
				Preferred_Language__c = 'English',
				BSP_CASS_Payment_contact__c = true,
				Financial_Assessment_Contact__c = true,
				AccountId = accs[1].Id
		);
		cons.add(con2);

		insert cons;

		Map<String, Portal_Applications__c> easyPayNameMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{'IATA EasyPay (EDENRED)', 'IATA EasyPay (MSTS)'});

		List<Portal_Application_Right__c> pars = new List<Portal_Application_Right__c> ();
		pars.add(new Portal_Application_Right__c(Right__c = 'Access Granted', ANG_Portal_Service_Role__c = 'IEP Admin', Portal_Application__c = easyPayNameMap.get('IATA EasyPay (EDENRED)').Id, Contact__c = con1.Id ));
		pars.add(new Portal_Application_Right__c(Right__c = 'Access Granted', ANG_Portal_Service_Role__c = 'IEP Admin', Portal_Application__c = easyPayNameMap.get('IATA EasyPay (MSTS)').Id, Contact__c = con2.Id ));
		insert pars;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

		integer i=0;
		for (Account a :accs){
			a.Is_PCI_compliant__c = (Math.mod(i, 2) == 0) ? 'Corporate Card' : 'Nil CC';
			a.ANG_IEP_Status__c = 'In Progress';
			i++;
		}

		update accs;

		Test.stopTest();

		List<AMS_Agency_Updates__c> agencyUpdLst = new List<AMS_Agency_Updates__c>(
			[SELECT
				Id,
				Account__c,
				Change_Code__c
			 FROM
			 	AMS_Agency_Updates__c
			]
		);

		system.assert(agencyUpdLst.size() == accs.size(), 'Should have created ' + accs.size() + ' agency updates records');

		for(AMS_Agency_Updates__c upd : agencyUpdLst){
			system.assert(upd.Change_Code__c == 'IEPPC', 'Should have created an update for the IEPPC pci compliant callout entry');
		}

	}

	@isTest static void pciCompliantUpdateDoNotTriggerMasterDataTest() {

		List<Account> accs = [SELECT Id, ANG_IEP_Status__c FROM Account WHERE Name = 'Test' OR Name = 'Test2' ORDER BY NAME ASC];

		List<Contact> cons = new List<Contact>();
		Contact con1 = new Contact(LastName = 'con1',
				Email = 'test1@istest.newgen',
				Preferred_Language__c = 'English',
				BSP_CASS_Payment_contact__c = true,
				Financial_Assessment_Contact__c = true,
				AccountId = accs[0].Id
		);
		cons.add(con1);

		Contact con2 = new Contact(LastName = 'con2',
				Email = 'test2@istest.newgen',
				Preferred_Language__c = 'English',
				BSP_CASS_Payment_contact__c = true,
				Financial_Assessment_Contact__c = true,
				AccountId = accs[1].Id
		);
		cons.add(con2);

		insert cons;

		Map<String, Portal_Applications__c> easyPayNameMap = PortalApplicationSelector.selectNewGenFieldsMapByName(new Set<String>{'IATA EasyPay (EDENRED)', 'IATA EasyPay (MSTS)'});

		List<Portal_Application_Right__c> pars = new List<Portal_Application_Right__c> ();
		pars.add(new Portal_Application_Right__c(Right__c = 'Access Granted', ANG_Portal_Service_Role__c = 'IEP Admin', Portal_Application__c = easyPayNameMap.get('IATA EasyPay (EDENRED)').Id, Contact__c = con1.Id ));
		pars.add(new Portal_Application_Right__c(Right__c = 'Access Granted', ANG_Portal_Service_Role__c = 'IEP Admin', Portal_Application__c = easyPayNameMap.get('IATA EasyPay (MSTS)').Id, Contact__c = con2.Id ));
		insert pars;

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessGenerator());

		integer i=0;
		for (Account a :accs){
			a.Is_PCI_compliant__c = (Math.mod(i, 2) == 0) ? 'Corporate Card' : 'Nil CC';
			a.ANG_IEP_Status__c = (Math.mod(i, 2) == 0) ? 'No IEP Account' : NULL;
			i++;
		}

		update accs;

		Test.stopTest();

		List<AMS_Agency_Updates__c> agencyUpdLst = new List<AMS_Agency_Updates__c>(
			[SELECT
				Id
			 FROM
			 	AMS_Agency_Updates__c
			]
		);

		system.assert(agencyUpdLst.size() == 0, 'Should NOT have created agency updates records');

	}

	@isTest static void testValidationRuleToEnsureHierarchy() {

		Account accountHE = [Select Id, ParentId From Account Where name = 'Test'];
		Account accountHE2 = [Select Id From Account Where name = 'Test2'];
		Test.startTest();

		try {
			accountHE.ParentId = accountHE2.Id;
			update accountHE;
		}
		catch(Exception e){
			system.assert(e.getMessage().contains('The selected location type is not allowed for this account.'), 'Please make sure that the location type is allowed.');
		}

		Test.stopTest();

	}

	static testMethod void test_UpdateRiskEventCashAndCashless() {

		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
		IATA_ISO_Country__c countries = [SELECT id FROM IATA_ISO_Country__c WHERE Name = 'Iso Country Name Test' limit 1];

		Account accountToUpdateRiskEventCashAndCashless = new Account(
			Name ='account To Update Risk Event Cash to Cashless',
			Type = 'IATA Passenger Sales Agent',
			Sector__c='Travel Agent',
			Location_Type__c = AMS_Utils.HE,
			Location_Class__c = 'P',
			ANG_FA_Opt_out__c = false,
			IATACode__c='12345600',
			IATA_ISO_Country__c = countries.Id,
			BillingCountry='Iso Country Name Test',
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
			Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
			RecordTypeId = accRT
		);
		insert accountToUpdateRiskEventCashAndCashless;
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES, Account__c = accountToUpdateRiskEventCashAndCashless.Id, ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE);
		insert oscar;

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
		update oscar;


		Agency_Applied_Change_code__c ch1 = new Agency_Applied_Change_code__c(OSCAR__c = oscar.id, Account__c = accountToUpdateRiskEventCashAndCashless.Id, Change_Code__c = 'CHA');
		insert ch1;
		Test.setCreatedDate(ch1.id, Date.today().addYears(-3));

		ANG_Risk_Event_Type__c ret2 = [Select Id from ANG_Risk_Event_Type__c Where Name = 'Risk Event Test'];
		ANG_Agency_Risk_Event__c re1 = new ANG_Agency_Risk_Event__c(
				ANG_AccountId__c = accountToUpdateRiskEventCashAndCashless.id,
				ANG_Risk_Type__c = ret2.id,
				ANG_Issued_Date__c = System.today(),
				ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE
			);

		insert re1;
		Test.setCreatedDate(re1.id, Date.today().addDays(-10));

		accountToUpdateRiskEventCashAndCashless.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS;
		update accountToUpdateRiskEventCashAndCashless;

		accountToUpdateRiskEventCashAndCashless.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
		update accountToUpdateRiskEventCashAndCashless;

		Agency_Applied_Change_code__c ch2 = new Agency_Applied_Change_code__c(OSCAR__c = oscar.id, Account__c = accountToUpdateRiskEventCashAndCashless.Id, Change_Code__c = 'CWD');
		insert ch2;
		Test.setCreatedDate(ch1.id, Date.today().addYears(-2));
		accountToUpdateRiskEventCashAndCashless.Accreditation_date__c = Date.today().addYears(-3);
		accountToUpdateRiskEventCashAndCashless.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS;
		update accountToUpdateRiskEventCashAndCashless;
	}
	
	public class MockHttpResponseSuccessGenerator implements HttpCalloutMock {
		// Implement this interface method
		public HTTPResponse respond(HTTPRequest req) {
			// Optionally, only send a mock response for a specific endpoint
			// and method.
			System.assertEquals('PUT', req.getMethod());

			// Create a fake response
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setStatusCode(200);
			return res;
		}
	}

}