@isTest
private class ANG_AccountTriggerHandlerTest {


	@testSetup static void createData() {
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Prov', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/calculatedrhc/{agencyId}/v1', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		customsettings.add(new ANG_CalloutMapping__c(Name = 'BTN_Bal', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/consumedrhc/{agencyId}/v1/', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		insert customsettings;

        Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
        Id riskStatusAssessmentRT = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT;

        IATA_ISO_Country__c isoTest = new IATA_ISO_Country__c(
        		Name = 'Iso Country Name Test', 
        		CurrencyIsoCode = 'EUR', 
        		ISO_Code_Numeric__c = 620, 
        		ISO_Code__c = 'PT',
        		AIMS_Area_ID__c='1',
        		ANG_Enable_NewGen__c = true
        	);

        insert isoTest;

        Account a = new Account(
        		Name ='Test', 
        		Type = 'IATA Passenger Sales Agent',
        		Sector__c='Travel Agent', 
        		Location_Type__c = AMS_Utils.HE,
        		Location_Class__c = 'P',
        		ANG_FA_Opt_out__c = false,
        		IATACode__c='12345678',
        		IATA_ISO_Country__c = isoTest.Id,
        		BillingCountry='Iso Country Name Test',
        		ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
        		Status__c = AMS_Utils.ACC_S9_APPROVED,
        		ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
        		Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
        		RecordTypeId = accRT
        	);
		insert a;

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
		Account a = [SELECT Id FROM Account WHERE Name = 'Test'];
		// fill accounts last financial review result and risk history and assert new risk status
		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] first update should be A');
		a.Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY;
		a.ANG_HE_RiskHistoryAssessment__c = AMS_Utils.PASSED;

		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, Subject FROM Cases) FROM Account WHERE Name = 'Test'];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_A, a.ANG_RiskStatus__c);

		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] second update should be B');
		// change values and check downgrade and SAAM case creation
		a.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		update a;

		Test.startTest();

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, Subject FROM Cases ORDER BY CreatedDate) FROM Account WHERE Name = 'Test'];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_B, a.ANG_RiskStatus__c);
		System.assertEquals(1, a.Cases.size());
		System.assertEquals('Test - 12345678 - Downgrade Risk Status', a.Cases[0].Subject);


		System.debug(loggingLevel.FINE, '____ [cls ANG_AccountTriggerHandlerTest - test_riskStatus_allcases] third update should be C');
		// change values one more time and check downgrade and OSCAR creation
		a.ANG_HE_RiskHistoryAssessment__c =  AMS_Utils.FAILED;
		update a;

		a = [SELECT Id, ANG_RiskStatus__c, (SELECT Id, RecordType.DeveloperName FROM Cases ORDER BY CreatedDate) FROM Account WHERE Name = 'Test'];
		System.assertEquals(ANG_Risk_Helper.RISK_STATUS_C, a.ANG_RiskStatus__c);
		System.assertEquals(2, a.Cases.size());
		System.assertEquals('OSCAR_Communication', a.Cases[1].RecordType.DeveloperName);
		System.assert([SELECT Id, ANG_CashCondition__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].ANG_CashCondition__c);

		Test.stopTest();
	}

	static testMethod void test_RHCupdate() {
		
		Account a = [SELECT Id FROM Account WHERE Name = 'Test'];
		a.Status__c = AMS_Utils.ACC_S0_TERMINATED;

		update a;

		Test.startTest();

		a.Status__c = AMS_Utils.ACC_S9_APPROVED;

		update a;

		Test.stopTest();
	}
	
	static testMethod void test_shortNameModification() {
		
		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
		ID standardRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account') ;

		Account a1 = new Account(Name = 'NameTest1', IATACode__c = '12344560', TradeName__c = 'tradeName1', RecordTypeId = standardRT,      Short_Name__c = 'ShortNameTest1Example1');	
		Account a2 = new Account(Name = 'NameTest2', IATACode__c = '12344568', TradeName__c = 'tradeName2', RecordTypeId = accRT, Short_Name__c = 'ShortNameTest1Example2');
		Account a3 = new Account(Name = 'NameTest3', IATACode__c = '12344569', TradeName__c = '', RecordTypeId = accRT, Short_Name__c = 'ShortNameTest1Example3');
		
		insert new List<Account>{a1,a2,a3};
		
		Test.startTest();

		List<Account> acctsRetreived = [Select Id, Name, Short_Name__c, TradeName__c from Account where Name in ('NameTest1','NameTest2','NameTest3')];

		Map<String,Account> acctsRetreivedMap = new Map<String,Account>();
		
		for(Account a: acctsRetreived){
			acctsRetreivedMap.put(a.Name,a);
		}

		System.assertEquals('ShortNameTest1Example1',acctsRetreivedMap.get('NameTest1').Short_Name__c);
		System.assertEquals('tradeName2',acctsRetreivedMap.get('NameTest2').Short_Name__c);
		System.assertEquals('NameTest3',acctsRetreivedMap.get('NameTest3').Short_Name__c);

		a1.Name = 'NameTest11';
		a2.IATACode__c = '12344566';
		a2.TradeName__c = 'tradeName22';
		a3.Name = 'NameTest33';
		a3.Short_Name__c = 'ShortNameTest1Example33';
		a3.TradeName__c = 'tradeName3';

		update new List<Account>{a1,a2,a3};

		acctsRetreived = [Select Id, Name, Short_Name__c, TradeName__c from Account where Name in ('NameTest11','NameTest2','NameTest33')];

		acctsRetreivedMap = new Map<String,Account>();
		
		for(Account a: acctsRetreived){
			acctsRetreivedMap.put(a.Name,a);
		}

		System.assertEquals('ShortNameTest1Example1',acctsRetreivedMap.get('NameTest11').Short_Name__c);
		System.assertEquals('tradeName22',acctsRetreivedMap.get('NameTest2').Short_Name__c);
		System.assertEquals('tradeName3',acctsRetreivedMap.get('NameTest33').Short_Name__c);

		Test.stopTest();

	}

	static testMethod void test_updateRHCInformation_OptIN_OptOUT() {

		//
		// Test ANG_FA_Opt_out__c TRUE to FALSE (Oscar)
		//

		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
		ID standardRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account') ;

		Account a = new Account(ANG_FA_Opt_out__c = true, Name = 'NameTest1', IATACode__c = '12344567', TradeName__c = 'tradeName1', RecordTypeId = standardRT,      Short_Name__c = 'ShortNameTest1Example1');

		insert a;

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		List<ANG_RHC_Information__c> rhcList1 = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c
												  from ANG_RHC_Information__c 
												 Where ANG_AccountId__c =: a.id];
        
        rhcList1[0].CurrencyIsoCode = 'USD';
        rhcList1[0].ANG_RME_Amount__c = 200;
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

		System.assertEquals(message.provisionalRHC, rhcList[0].ANG_RME_Amount__c);

	}

	static testMethod void test_updateRHCInformation_OptIN_OptOUT_ALT() {

		//
		// Test ANG_FA_Opt_out__c TRUE to FALSE (Oscar)
		//

		Id accRT = AMS_Utils.RECTYPE_IATAAGENCY;
		ID standardRT = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account') ;

		Account a = new Account(ANG_FA_Opt_out__c = true, Name = 'NameTest1', IATACode__c = '12344567', TradeName__c = 'tradeName1', RecordTypeId = standardRT,      Short_Name__c = 'ShortNameTest1Example1');

		insert a;

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		List<ANG_RHC_Information__c> rhcList1 = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c
												  from ANG_RHC_Information__c 
												 Where ANG_AccountId__c =: a.id];
        
        rhcList1[0].CurrencyIsoCode = 'USD';
        rhcList1[0].ANG_RME_Amount__c = 200;
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

		System.assertEquals(message.provisionalRHC, rhcList[0].ANG_RME_Amount__c);

	}

	static testMethod void test_updateRHCInformation_OptIN_OptOUT_2() {

		Account a = [SELECT Id FROM Account];

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
				RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review'),
				IFAP_Area__c = 'asda44'
			);
		insert cFS;

		cFS.Status = AMS_Utils.CASE_STATUS_FINANCIAL_SECURITY_REQUESTED;

		List<ANG_RHC_Information__c> rhcList1 = [Select ANG_RHC_Amount_Provisional__c,
													   ANG_Provisional_RHC_Last_Update__c,
													   ANG_RME_Amount__c
												  from ANG_RHC_Information__c 
												 Where ANG_AccountId__c =: a.id];
        
        rhcList1[0].CurrencyIsoCode = 'USD';
        rhcList1[0].ANG_RME_Amount__c = 200;
        upsert rhcList1[0];

		ANG_RME_Alert_Service.RHCMessage message = new ANG_RME_Alert_Service.RHCMessage();

		message.provisionalRHC = 300;
		message.storedBaseCurrency = 'USD';
		message.consumedRHCAmount = 100;
		message.consumedRHCPercentage = 0.1;
		message.iataCode = '12345678';
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

		System.assertEquals(message.provisionalRHC, rhcList[0].ANG_RME_Amount__c);
	}	
	
}