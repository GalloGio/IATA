@isTest
private class ANG_MulticountryFinancialAssessmentTest {

	private static final String CURRENCY_EUR = 'EUR';
	private static final String CURRENCY_BOP = 'BOP';

	@TestSetup
	static void setup(){

		ANG_RME_Alert_Service_Test.createRMEMappings();

		IATA_ISO_Country__c pt = ANG_TestDataHelper.insertBspAndIsoCountry(ANG_TestDataHelper.COUNTRY_INFORMATION.get('PT'));
		IATA_ISO_Country__c gb = ANG_TestDataHelper.insertBspAndIsoCountry(ANG_TestDataHelper.COUNTRY_INFORMATION.get('GB'));

		Id recTypeCSA = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');

		IATA_ISO_Country__c countryWW = new IATA_ISO_Country__c(
			Name = 'All Countries',
			ISO_Code__c = 'WW'
		);
		insert countryWW;

		AMS_Country_Specific_Attribute__c csa = new AMS_Country_Specific_Attribute__c(
			CurrencyIsoCode = CURRENCY_EUR,
			RecordTypeId = recTypeCSA,
			IATA_ISO_Country__c = countryWW.Id,
			ANG_Minimum_RHC_Amount__c = 5000
		);

		insert csa;

		ANG_RHC_Currencies__c rhcCurrencies = new ANG_RHC_Currencies__c();
		rhcCurrencies.Name = CURRENCY_EUR;
		rhcCurrencies.CurrencyIsoCode = CURRENCY_EUR;
		rhcCurrencies.Currency_Name__c  = 'Euro';

		insert rhcCurrencies;

		Account agentPT = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 GE PT', (Id) null, (Id) null, AMS_Utils.GE, pt, '10000000');
		Account agentGB = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 HE GB', agentPT.Id, agentPT.Id, AMS_Utils.HE, gb, '10000002');

		agentPT.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
		agentGB.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;

		update new List<Account>{ agentPT, agentGB};

		ANG_TestDataHelper.insertHierarchy(new List<Account> { agentPT, agentGB });
		ANG_TestDataHelper.insertAccountOwner(agentPT.Id);

		Contact contPT = ANG_TestDataHelper.insertContact(agentPT.Id);	
	
		contPT.Financial_Assessment_Contact__c = true;
		update contPT;

		ANG_RHCHelper.createRHCInfo(new Set<Id>{agentPT.Id}, false);

		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'Financial Institution',
			Region__c = 'Europe',
			Country__c = 'Portugal',
			Institution_Type__c = 'Bank'
		);

		insert fi;

		Test.startTest();

		Case cc = new Case(AccountId = agentPT.Id);
		insert cc;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = CURRENCY_EUR,
			Account__c = agentPT.Id,
			Amount__c = 10000,
			Expiry_date__c = System.Today().addDays(1000),
			Financial_Institution__c = fi.Id,
			Security_Status__c = AMS_Utils.ACTIVE,
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Asia & Pacific',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id
		);

		insert fs;

		Case multicountryAnnual = new Case(
			ContactId = contPT.Id,
			AccountId = agentPT.Id,
			Subject = 'MC - Financial Review',
			Description = 'MC - Annual Financial Review - 2020',
			Status = AMS_Utils.CASE_STATUS_AGENT_NOTIFIED_EMAIL,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2020',
			Deadline_Date__c = System.today(),
			Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL,
			FA_Letter_Sent__c = true
		);

		Case multicountryAdhoc = new Case(
			ContactId = contPT.Id,
			AccountId = agentPT.Id,
			Subject = 'MC - Financial Review',
			Description = 'MC - Adhoc Financial Review - 2020',
			Status = AMS_Utils.CASE_STATUS_AGENT_NOTIFIED_EMAIL,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2020',
			Deadline_Date__c = System.today(),
			Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ADHOC,
			FA_Letter_Sent__c = true
		);
		
		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		insert new List<Case>{multicountryAnnual, multicountryAdhoc};

		ANG_Risk_Event_Type__c riskEventType = new ANG_Risk_Event_Type__c(
			Name = ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS,
			ANG_Risk_ID__c = '5',
			ANG_Expiration__c = 12,
			Limit_Cash_conditions__c=false
		);

		insert riskEventType;

		Test.stopTest();

	}

	@isTest static void annualComplianceTest(){

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Case multicountryAnnual = [SELECT 
										Id, AccountId, Account.Financial_Assessment_Points__c, 
										Account.Financial_Review_Result__c, Account.Assessment_Performed_Date__c,
										(SELECT Id
									   FROM Hierarchy_Account_Selections__r
									   WHERE RecordType.DeveloperName = 'Multicountry_Yearly_Financial_Review')
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL
								   LIMIT 1];

		System.assertEquals(1, multicountryAnnual.Hierarchy_Account_Selections__r.size(), 'Multicountry Annual IFAP should have one AMS_Process_Detail__c related record');
		System.assertNotEquals(AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS, multicountryAnnual.Account.Financial_Review_Result__c, 'Financial review result should not be "' + AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS + '"');
		System.assertNotEquals(50, multicountryAnnual.Account.Financial_Assessment_Points__c, 'Financial assessment points should not be 50');
		System.assertNotEquals(Date.today(), multicountryAnnual.Account.Assessment_Performed_Date__c, 'Assessment performed date should not be today');

		Test.startTest();

		multicountryAnnual.Status = AMS_Utils.CASE_STATUS_ASSESSMENT_PERFORMED;
		multicountryAnnual.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryAnnual.Financial_Assessment_Points__c = 50;
		multicountryAnnual.Assessment_Performed_Date__c = Date.today();
		update multicountryAnnual;

		multicountryAnnual.Status = AMS_Utils.CASE_STATUS_CLOSED;
		update multicountryAnnual;

		Test.stopTest();

		Account accountUpdated = [SELECT id, Financial_Assessment_Points__c, Financial_Review_Result__c, Assessment_Performed_Date__c
								  FROM Account
								  WHERE Id = :multicountryAnnual.AccountId
								  LIMIT 1];

		System.assertEquals(AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS, accountUpdated.Financial_Review_Result__c, 'Financial review result should be "' + AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS + '"');
		System.assertEquals(50, accountUpdated.Financial_Assessment_Points__c, 'Financial assessment points should be 50');
		System.assertEquals(Date.today(), accountUpdated.Assessment_Performed_Date__c, 'Assessment performed date should be today');

	}

	@isTest static void quarterlyComplianceTest(){

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Case multicountryAnnual = [SELECT Id, AccountId, ContactId, Account.Financial_Assessment_Points__c, Account.Financial_Review_Result__c,
									   Account.Assessment_Performed_Date__c
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL
								   LIMIT 1];

		multicountryAnnual.Status = AMS_Utils.CASE_STATUS_FINANCIAL_SECURITY_REQUESTED;
		multicountryAnnual.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryAnnual.Financial_Assessment_Points__c = 50;
		multicountryAnnual.Assessment_Performed_Date__c = Date.today().addDays(-1);
		update multicountryAnnual;

		Account accountUpdated = [SELECT id, Financial_Assessment_Points__c, Financial_Review_Result__c, Assessment_Performed_Date__c
								  FROM Account
								  WHERE Id = :multicountryAnnual.AccountId
								  LIMIT 1];

		System.assertEquals(AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS, accountUpdated.Financial_Review_Result__c, 'Financial review result should be "' + AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS + '"');
		System.assertEquals(50, accountUpdated.Financial_Assessment_Points__c, 'Financial assessment points should be 50');
		System.assertEquals(Date.today().addDays(-1), accountUpdated.Assessment_Performed_Date__c, 'Assessment performed date should be yesterday');

		Test.startTest();

		Case multicountryQuarterly= new Case(
			ContactId = multicountryAnnual.ContactId,
			AccountId = multicountryAnnual.AccountId,
			ParentId = multicountryAnnual.Id,
			Subject = 'MC - Q1 Financial Review - 2020',
			Description = 'MC - Q1 Financial Review - 2020',
			Status = AMS_Utils.CASE_STATUS_AGENT_NOTIFIED_EMAIL,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2020',
			Deadline_Date__c = System.today(),
			Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_QUARTERLY,
			FA_Letter_Sent__c = true
		);

		insert multicountryQuarterly;

		List<AMS_Process_Detail__c> pdLst = [SELECT Id
											 FROM AMS_Process_Detail__c
											 WHERE RecordType.DeveloperName = 'Multicountry_Yearly_Financial_Review'
												 AND Case__c = :multicountryQuarterly.Id];

		System.assert(pdLst.isEmpty(), 'Multicountry Quarterly IFAP should NOT have AMS_Process_Detail__c related records');

		multicountryQuarterly.Status = AMS_Utils.CASE_STATUS_ASSESSMENT_PERFORMED;
		multicountryQuarterly.Financial_Review_Result__c = AMS_Utils.FA_RESULT_SATISFACTORY_NO_ACTION;
		multicountryQuarterly.Financial_Assessment_Points__c = 150;
		multicountryQuarterly.Assessment_Performed_Date__c = Date.today();
		update multicountryQuarterly;

		multicountryQuarterly.Status = AMS_Utils.CASE_STATUS_CLOSED;
		update multicountryQuarterly;

		Test.stopTest();

		accountUpdated = [SELECT id, Financial_Assessment_Points__c, Financial_Review_Result__c, Assessment_Performed_Date__c
						  FROM Account
						  WHERE Id = :multicountryQuarterly.AccountId
						  LIMIT 1];

		System.assertEquals(AMS_Utils.FA_RESULT_SATISFACTORY_NO_ACTION, accountUpdated.Financial_Review_Result__c, 'Financial review result should be "' + AMS_Utils.FA_RESULT_SATISFACTORY_NO_ACTION + '"');
		System.assertEquals(150, accountUpdated.Financial_Assessment_Points__c, 'Financial assessment points should be 150');
		System.assertEquals(Date.today(), accountUpdated.Assessment_Performed_Date__c, 'Assessment performed date should be today');

	}

	@isTest static void adhocComplianceTest(){

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Case multicountryAdhoc = [SELECT Id, AccountId, Account.Financial_Assessment_Points__c, Account.Financial_Review_Result__c,
									  Account.Assessment_Performed_Date__c,
									  (SELECT Id
									   FROM Hierarchy_Account_Selections__r
									   WHERE RecordType.DeveloperName = 'Multicountry_Yearly_Financial_Review')
								  FROM Case
								  WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ADHOC
								  LIMIT 1];

		System.assertEquals(1, multicountryAdhoc.Hierarchy_Account_Selections__r.size(), 'Multicountry Adhoc IFAP should have one AMS_Process_Detail__c related record');
		System.assertNotEquals(AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS, multicountryAdhoc.Account.Financial_Review_Result__c, 'Financial review result should not be "' + AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS + '"');
		System.assertNotEquals(50, multicountryAdhoc.Account.Financial_Assessment_Points__c, 'Financial assessment points should not be 50');
		System.assertNotEquals(Date.today(), multicountryAdhoc.Account.Assessment_Performed_Date__c, 'Assessment performed date should not be today');

		Test.startTest();

		multicountryAdhoc.Status = AMS_Utils.CASE_STATUS_ASSESSMENT_PERFORMED;
		multicountryAdhoc.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryAdhoc.Financial_Assessment_Points__c = 50;
		multicountryAdhoc.Assessment_Performed_Date__c = Date.today();
		update multicountryAdhoc;

		multicountryAdhoc.Status = AMS_Utils.CASE_STATUS_CLOSED;
		update multicountryAdhoc;

		Test.stopTest();

		Account accountUpdated = [SELECT id, Financial_Assessment_Points__c, Financial_Review_Result__c, Assessment_Performed_Date__c
								  FROM Account
								  WHERE Id = :multicountryAdhoc.AccountId
								  LIMIT 1];

		System.assertEquals(AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS, accountUpdated.Financial_Review_Result__c, 'Financial review result should be "' + AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS + '"');
		System.assertEquals(50, accountUpdated.Financial_Assessment_Points__c, 'Financial assessment points should be 50');
		System.assertEquals(Date.today(), accountUpdated.Assessment_Performed_Date__c, 'Assessment performed date should be today');

	}

	@isTest static void annualNonComplianceWithFinancialSecurityTest(){

		Test.startTest();

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Case multicountryAnnual = [SELECT 
										Id, AccountId, Account.Financial_Assessment_Points__c, 
										Account.Financial_Review_Result__c, Account.Assessment_Performed_Date__c
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL
								   LIMIT 1];

		multicountryAnnual.Deadline_Date__c = System.today().addDays(-1);
		update multicountryAnnual;

		IFAP_WebService.IFAPActionWrapper ifapAction = IFAP_WebService.applyCashCondition(multicountryAnnual.Id, multicountryAnnual.AccountId);
		System.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, ifapAction.message);

		ANG_Risk_Event_Type__c riskEventType = new ANG_Risk_Event_Type__c(ANG_Risk_ID__c = '5');

		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = multicountryAnnual.AccountId,
			ANG_Event_Status__c = AMS_Utils.ACTIVE,
			ANG_HE_AccountId__c = multicountryAnnual.AccountId,
			ANG_Risk_Type__r = riskEventType,
			ANG_Issued_Date__c = System.today()
		);

		insert are;

		multicountryAnnual.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		update multicountryAnnual;

		ifapAction = IFAP_WebService.applyCashCondition(multicountryAnnual.Id, multicountryAnnual.AccountId);
		System.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_APPLIED, ifapAction.message);

		ANG_Agency_Risk_Event__c riskEvent = [SELECT Id, ANG_Limit_Cash_Conditions__c
											  FROM ANG_Agency_Risk_Event__c
											  WHERE ANG_AccountId__c = :multicountryAnnual.AccountId
											  	AND ANG_Risk_Type__r.Name = :ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS
												AND ANG_Event_Status__c = :AMS_Utils.ACTIVE];

		System.assert(riskEvent.ANG_Limit_Cash_Conditions__c, 'Risk Event must have limit cash conditions TRUE');

		Case updCse = [SELECT Id, Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c
					   FROM Case
					   WHERE Id = :multicountryAnnual.Id
					   LIMIT 1];

		System.assertEquals(System.today(), updCse.secondFAnonComplianceDate__c);
		System.assertEquals(updCse.Deadline_Date__c.addDays(365), updCse.FA_Third_Deadline_Date__c);

		multicountryAnnual.Status = AMS_Utils.CASE_STATUS_ASSESSMENT_PERFORMED;
		multicountryAnnual.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryAnnual.Financial_Assessment_Points__c = 50;
		multicountryAnnual.Assessment_Performed_Date__c = Date.today();
		update multicountryAnnual;

		ifapAction = IFAP_WebService.removeCashCondition(multicountryAnnual.Id, multicountryAnnual.AccountId);
		System.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_REMOVED, ifapAction.message);

		Test.stopTest();
	}

	@isTest static void annualNonComplianceWithoutFinancialSecurityTest(){

		Test.startTest();

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Case multicountryAnnual = [SELECT 
										Id, AccountId, Account.Financial_Assessment_Points__c, 
										Account.Financial_Review_Result__c, Account.Assessment_Performed_Date__c
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL
								   LIMIT 1];

		List<Financial_Security__c> fsLst = new List<Financial_Security__c>();
		for(Financial_Security__c fs : [SELECT Id FROM Financial_Security__c WHERE Account__c = :multicountryAnnual.AccountId]){
			fs.Security_Status__c = 'Expired';
			fsLst.add(fs);
		}
		update fsLst;

		Boolean exceptionRaised = false;

		try {
			WSSidraLite.sidraLiteAction(multicountryAnnual.Id);
		}
		catch(WSSidraLite.SidraLiteException e){
			exceptionRaised = true;
			System.assert(e.getMessage().contains('Cannot create a 1st FA non-compliance case'));
		}

		System.assert(exceptionRaised, 'A SidraLiteException should have been raised');

		multicountryAnnual.Deadline_Date__c = System.today().addDays(-1);
		update multicountryAnnual;

		Case sidraLite = WSSidraLite.sidraLiteAction(multicountryAnnual.Id);
		insert sidraLite;

		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = multicountryAnnual.AccountId,
			ANG_Event_Status__c = AMS_Utils.ACTIVE,
			ANG_HE_AccountId__c = multicountryAnnual.AccountId,
			ANG_Risk_Type__r = new ANG_Risk_Event_Type__c(ANG_Risk_ID__c = '5'),
			ANG_Issued_Date__c = System.today()
		);

		insert are;

		multicountryAnnual.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		update multicountryAnnual;

		IFAP_WebService.IFAPActionWrapper ifapAction = IFAP_WebService.applyCashCondition(multicountryAnnual.Id, multicountryAnnual.AccountId);
		System.assertEquals(IFAP_WebService.INVALID_ACTION_TRIGGER_SIDRA_LITE, ifapAction.message);

		exceptionRaised = false;

		try {
			sidraLite = WSSidraLite.sidraLiteAction(multicountryAnnual.Id);
		} catch(WSSidraLite.ShowConfirmationException e){
			exceptionRaised = true;
			System.assertEquals(SidraLiteHelperForIFAP.SIDRA_LITE_PROCESS_SECOND_NON_COMPLIANCE_WARNING, e.getMessage());
		}

		System.assert(exceptionRaised, 'A ShowConfirmationException should have been raised');

		Test.stopTest();

		WSSidraLite.updateSecondAndThirdDeadline(multicountryAnnual.Id);

		Case updCse = [SELECT Id, Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c
					   FROM Case
					   WHERE Id = :multicountryAnnual.Id
					   LIMIT 1];

		System.assertEquals(System.today(), updCse.secondFAnonComplianceDate__c);
		System.assertEquals(updCse.Deadline_Date__c.addDays(365), updCse.FA_Third_Deadline_Date__c);

		multicountryAnnual.Status = AMS_Utils.CASE_STATUS_ASSESSMENT_PERFORMED;
		multicountryAnnual.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryAnnual.Financial_Assessment_Points__c = 50;
		multicountryAnnual.Assessment_Performed_Date__c = Date.today();
		update multicountryAnnual;

		ifapAction = IFAP_WebService.removeCashCondition(multicountryAnnual.Id, multicountryAnnual.AccountId);
		System.assertEquals(IFAP_WebService.INVALID_ACTION_REINSTATE_AGENT, ifapAction.message);

	}

	@isTest static void adhocNonComplianceWithFinancialSecurityTest(){

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Case multicountryAdhoc = [SELECT 
										Id, AccountId, Account.Financial_Assessment_Points__c, 
										Account.Financial_Review_Result__c, Account.Assessment_Performed_Date__c
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ADHOC
								   LIMIT 1];

		multicountryAdhoc.Deadline_Date__c = System.today().addDays(-1);
		update multicountryAdhoc;

		IFAP_WebService.IFAPActionWrapper ifapAction = IFAP_WebService.applyCashCondition(multicountryAdhoc.Id, multicountryAdhoc.AccountId);
		System.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, ifapAction.message);

		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = multicountryAdhoc.AccountId,
			ANG_Event_Status__c = AMS_Utils.ACTIVE,
			ANG_HE_AccountId__c = multicountryAdhoc.AccountId,
			ANG_Risk_Type__r = new ANG_Risk_Event_Type__c(ANG_Risk_ID__c = '5'),
			ANG_Issued_Date__c = System.today()
		);

		insert are;

		multicountryAdhoc.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		update multicountryAdhoc;

		Test.startTest();

		ifapAction = IFAP_WebService.applyCashCondition(multicountryAdhoc.Id, multicountryAdhoc.AccountId);
		System.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_APPLIED, ifapAction.message);

		ANG_Agency_Risk_Event__c riskEvent = [SELECT Id, ANG_Limit_Cash_Conditions__c
											  FROM ANG_Agency_Risk_Event__c
											  WHERE ANG_AccountId__c = :multicountryAdhoc.AccountId
											  	AND ANG_Risk_Type__r.Name = :ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS
												AND ANG_Event_Status__c = :AMS_Utils.ACTIVE];

		System.assert(riskEvent.ANG_Limit_Cash_Conditions__c, 'Risk Event must have limit cash conditions TRUE');

		Case updCse = [SELECT Id, Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c
					   FROM Case
					   WHERE Id = :multicountryAdhoc.Id
					   LIMIT 1];

		System.assertEquals(System.today(), updCse.secondFAnonComplianceDate__c);
		System.assertEquals(updCse.Deadline_Date__c.addDays(365), updCse.FA_Third_Deadline_Date__c);

		multicountryAdhoc.Status = AMS_Utils.CASE_STATUS_ASSESSMENT_PERFORMED;
		multicountryAdhoc.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryAdhoc.Financial_Assessment_Points__c = 50;
		multicountryAdhoc.Assessment_Performed_Date__c = Date.today();
		update multicountryAdhoc;

		ifapAction = IFAP_WebService.removeCashCondition(multicountryAdhoc.Id, multicountryAdhoc.AccountId);
		System.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_REMOVED, ifapAction.message);

		Test.stopTest();
	}

	@isTest static void adhocNonComplianceWithoutFinancialSecurityTest(){
		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Test.startTest();

		Case multicountryAdhoc = [SELECT 
										Id, AccountId, Account.Financial_Assessment_Points__c, 
										Account.Financial_Review_Result__c, Account.Assessment_Performed_Date__c
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ADHOC
								   LIMIT 1];

		List<Financial_Security__c> fsLst = new List<Financial_Security__c>();
		for(Financial_Security__c fs : [SELECT Id FROM Financial_Security__c WHERE Account__c = :multicountryAdhoc.AccountId]){
			fs.Security_Status__c = 'Expired';
			fsLst.add(fs);
		}
		update fsLst;

		Boolean exceptionRaised = false;

		try {
			WSSidraLite.sidraLiteAction(multicountryAdhoc.Id);
		}
		catch(WSSidraLite.SidraLiteException e){
			exceptionRaised = true;
			System.assert(e.getMessage().contains('Cannot create a 1st FA non-compliance case'));
		}

		System.assert(exceptionRaised, 'A SidraLiteException should have been raised');

		multicountryAdhoc.Deadline_Date__c = System.today().addDays(-1);
		update multicountryAdhoc;

		Case sidraLite = WSSidraLite.sidraLiteAction(multicountryAdhoc.Id);
		insert sidraLite;

		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = multicountryAdhoc.AccountId,
			ANG_Event_Status__c = AMS_Utils.ACTIVE,
			ANG_HE_AccountId__c = multicountryAdhoc.AccountId,
			ANG_Risk_Type__r = new ANG_Risk_Event_Type__c(ANG_Risk_ID__c = '5'),
			ANG_Issued_Date__c = System.today()
		);

		insert are;

		multicountryAdhoc.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		update multicountryAdhoc;

		IFAP_WebService.IFAPActionWrapper ifapAction = IFAP_WebService.applyCashCondition(multicountryAdhoc.Id, multicountryAdhoc.AccountId);
		System.assertEquals(IFAP_WebService.INVALID_ACTION_TRIGGER_SIDRA_LITE, ifapAction.message);

		exceptionRaised = false;

		try {
			sidraLite = WSSidraLite.sidraLiteAction(multicountryAdhoc.Id);
		} catch(WSSidraLite.ShowConfirmationException e){
			exceptionRaised = true;
			System.assertEquals(SidraLiteHelperForIFAP.SIDRA_LITE_PROCESS_SECOND_NON_COMPLIANCE_WARNING, e.getMessage());
		}

		System.assert(exceptionRaised, 'A ShowConfirmationException should have been raised');

		WSSidraLite.updateSecondAndThirdDeadline(multicountryAdhoc.Id);

		Case updCse = [SELECT Id, Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c
					   FROM Case
					   WHERE Id = :multicountryAdhoc.Id
					   LIMIT 1];

		System.assertEquals(System.today(), updCse.secondFAnonComplianceDate__c);
		System.assertEquals(updCse.Deadline_Date__c.addDays(365), updCse.FA_Third_Deadline_Date__c);

		multicountryAdhoc.Status = AMS_Utils.CASE_STATUS_ASSESSMENT_PERFORMED;
		multicountryAdhoc.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryAdhoc.Financial_Assessment_Points__c = 50;
		multicountryAdhoc.Assessment_Performed_Date__c = Date.today();
		update multicountryAdhoc;

		ifapAction = IFAP_WebService.removeCashCondition(multicountryAdhoc.Id, multicountryAdhoc.AccountId);
		System.assertEquals(IFAP_WebService.INVALID_ACTION_REINSTATE_AGENT, ifapAction.message);

		Test.stopTest();
	}

	@isTest static void overlappingNonCompliancesWithFinancialSecurityTest(){

		Test.startTest();

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
		
		Case multicountryAnnual = [SELECT 
									Id, CreatedDate, CaseNumber, AccountId, 
									Financial_Review_Type__c, ContactId, Account.Financial_Assessment_Points__c,
									Account.Financial_Review_Result__c, Account.Assessment_Performed_Date__c
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL
								   LIMIT 1];
		
		ANG_Risk_Event_Type__c riskEventType = new ANG_Risk_Event_Type__c(ANG_Risk_ID__c = '5');

		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = multicountryAnnual.AccountId,
			ANG_Event_Status__c = AMS_Utils.ACTIVE,
			ANG_HE_AccountId__c = multicountryAnnual.AccountId,
			ANG_Risk_Type__r = riskEventType,
			ANG_Issued_Date__c = System.today()
		);

		insert are;

		multicountryAnnual.Deadline_Date__c = System.today().addDays(-1);
		multicountryAnnual.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		update multicountryAnnual;

		IFAP_WebService.IFAPActionWrapper ifapAction = IFAP_WebService.applyCashCondition(multicountryAnnual.Id, multicountryAnnual.AccountId);
		System.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_APPLIED, ifapAction.message);

		ANG_Agency_Risk_Event__c riskEvent = [SELECT Id, ANG_Limit_Cash_Conditions__c
											  FROM ANG_Agency_Risk_Event__c
											  WHERE ANG_AccountId__c = :multicountryAnnual.AccountId
											  	AND ANG_Risk_Type__r.Name = :ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS
												AND ANG_Event_Status__c = :AMS_Utils.ACTIVE];

		System.assert(riskEvent.ANG_Limit_Cash_Conditions__c, 'Risk Event must have limit cash conditions TRUE');

		Case updCse = [SELECT Id, CaseNumber, Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c
					   FROM Case
					   WHERE Id = :multicountryAnnual.Id
					   LIMIT 1];

		System.assertEquals(System.today(), updCse.secondFAnonComplianceDate__c);
		System.assertEquals(updCse.Deadline_Date__c.addDays(365), updCse.FA_Third_Deadline_Date__c);

		Case multicountryQuarterly= new Case(
			ContactId = multicountryAnnual.ContactId,
			AccountId = multicountryAnnual.AccountId,
			ParentId = multicountryAnnual.Id,
			Subject = 'MC - Q1 Financial Review - 2020',
			Description = 'MC - Q1 Financial Review - 2020',
			Status = AMS_Utils.CASE_STATUS_AGENT_NOTIFIED_EMAIL,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2020',
			Deadline_Date__c = System.today().addDays(-1),
			Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_QUARTERLY,
			FA_Letter_Sent__c = true
		);

		insert multicountryQuarterly;

		String expectedNonComplianceMessage = ANG_MulticountryHelper.NON_COMPLIANCE_ON_DIFFERENT_IFAP_MESSAGE.replace('{{caseNumber}}', multicountryAnnual.CaseNumber);

		ifapAction = IFAP_WebService.removeCashCondition(multicountryQuarterly.Id, multicountryQuarterly.AccountId);
		System.assertEquals(expectedNonComplianceMessage, ifapAction.message);

		ifapAction = IFAP_WebService.applyCashCondition(multicountryQuarterly.Id, multicountryQuarterly.AccountId);
		System.assertEquals(expectedNonComplianceMessage, ifapAction.message);
		
		multicountryQuarterly.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryQuarterly.Financial_Assessment_Points__c = 50;
		multicountryQuarterly.Assessment_Performed_Date__c = Date.today();

		update multicountryQuarterly; 

		expectedNonComplianceMessage += ' ' + ANG_MulticountryHelper.NON_COMPLIANCE_ON_DIFFERENT_IFAP_CONFIRMATION_TOKEN;

		ifapAction = IFAP_WebService.removeCashCondition(multicountryQuarterly.Id, multicountryQuarterly.AccountId);
		System.assertEquals(expectedNonComplianceMessage, ifapAction.message);

		ifapAction = IFAP_WebService.applyCashCondition(multicountryQuarterly.Id, multicountryQuarterly.AccountId);
		System.assertEquals(expectedNonComplianceMessage, ifapAction.message);

		String result = IFAP_WebService.processNonComplianceOnDifferentIfap(ifapAction.ifapId);
		
		System.assertEquals(AMS_Utils.SUCCESS, result, 'The result should be ' + AMS_Utils.SUCCESS);

		List<Task> taskLst = ANG_MulticountryHelper.fetchCaseNonComplianceTasks(ifapAction.ifapId);

		System.assertEquals(1, taskLst.size(), 'One Non Compliance task must be created for Case ' + ifapAction.ifapId);

		ifapAction = IFAP_WebService.removeCashCondition(multicountryAnnual.Id, multicountryAnnual.AccountId);
		System.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_REMOVED, ifapAction.message);

		Test.stopTest();

	}

	@isTest static void overlappingNonCompliancesWithoutFinancialSecurityTest(){

		Test.startTest();

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
		
		Case multicountryAnnual = [SELECT 
									Id, CreatedDate, CaseNumber, AccountId, 
									Financial_Review_Type__c, ContactId, Account.Financial_Assessment_Points__c,
									Account.Financial_Review_Result__c, Account.Assessment_Performed_Date__c
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL
								   LIMIT 1];
		
		List<Financial_Security__c> fsLst = new List<Financial_Security__c>();
		for(Financial_Security__c fs : [SELECT Id FROM Financial_Security__c WHERE Account__c = :multicountryAnnual.AccountId]){
			fs.Security_Status__c = 'Expired';
			fsLst.add(fs);
		}
		update fsLst;

		ANG_Risk_Event_Type__c riskEventType = new ANG_Risk_Event_Type__c(ANG_Risk_ID__c = '5');

		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = multicountryAnnual.AccountId,
			ANG_Event_Status__c = AMS_Utils.ACTIVE,
			ANG_HE_AccountId__c = multicountryAnnual.AccountId,
			ANG_Risk_Type__r = riskEventType,
			ANG_Issued_Date__c = System.today()
		);

		insert are;

		multicountryAnnual.Deadline_Date__c = System.today().addDays(-1);
		update multicountryAnnual;

		Case sidraLite = WSSidraLite.sidraLiteAction(multicountryAnnual.Id);
		insert sidraLite;

		multicountryAnnual.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		update multicountryAnnual;

		Boolean exceptionRaised = false;

		try {
			sidraLite = WSSidraLite.sidraLiteAction(multicountryAnnual.Id);
		} catch(WSSidraLite.ShowConfirmationException e){
			exceptionRaised = true;
			System.assertEquals(SidraLiteHelperForIFAP.SIDRA_LITE_PROCESS_SECOND_NON_COMPLIANCE_WARNING, e.getMessage());
		}

		System.assert(exceptionRaised, 'A ShowConfirmationException should have been raised');

		WSSidraLite.updateSecondAndThirdDeadline(multicountryAnnual.Id);

		Case updCse = [SELECT Id, Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c
					   FROM Case
					   WHERE Id = :multicountryAnnual.Id
					   LIMIT 1];

		System.assertEquals(System.today(), updCse.secondFAnonComplianceDate__c);
		System.assertEquals(updCse.Deadline_Date__c.addDays(365), updCse.FA_Third_Deadline_Date__c);

		Case multicountryQuarterly= new Case(
			ContactId = multicountryAnnual.ContactId,
			AccountId = multicountryAnnual.AccountId,
			ParentId = multicountryAnnual.Id,
			Subject = 'MC - Q1 Financial Review - 2020',
			Description = 'MC - Q1 Financial Review - 2020',
			Status = AMS_Utils.CASE_STATUS_AGENT_NOTIFIED_EMAIL,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2020',
			Deadline_Date__c = System.today().addDays(-1),
			Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_QUARTERLY,
			FA_Letter_Sent__c = true
		);

		insert multicountryQuarterly;

		Test.stopTest();

		String expectedNonComplianceMessage = ANG_MulticountryHelper.NON_COMPLIANCE_ON_DIFFERENT_IFAP_MESSAGE.replace('{{caseNumber}}', multicountryAnnual.CaseNumber);

		IFAP_WebService.IFAPActionWrapper ifapAction = IFAP_WebService.removeCashCondition(multicountryQuarterly.Id, multicountryQuarterly.AccountId);
		System.assertEquals(expectedNonComplianceMessage, ifapAction.message);

		ifapAction = IFAP_WebService.applyCashCondition(multicountryQuarterly.Id, multicountryQuarterly.AccountId);
		System.assertEquals(expectedNonComplianceMessage, ifapAction.message);
		
		exceptionRaised = false;

		try {
			sidraLite = WSSidraLite.sidraLiteAction(multicountryQuarterly.Id);
		} catch(WSSidraLite.SidraLiteException e){
			exceptionRaised = true;
			System.assertEquals(expectedNonComplianceMessage, e.getMessage());
		}

		System.assert(exceptionRaised, 'A SidraLiteException should have been raised');

		multicountryQuarterly.Financial_Review_Result__c = AMS_Utils.FA_RESULT_UNSATISFACTORY_UPDATE_FS;
		multicountryQuarterly.Financial_Assessment_Points__c = 50;
		multicountryQuarterly.Assessment_Performed_Date__c = Date.today();

		update multicountryQuarterly; 

		expectedNonComplianceMessage += ' ' + ANG_MulticountryHelper.NON_COMPLIANCE_ON_DIFFERENT_IFAP_CONFIRMATION_TOKEN;

		ifapAction = IFAP_WebService.removeCashCondition(multicountryQuarterly.Id, multicountryQuarterly.AccountId);
		System.assertEquals(expectedNonComplianceMessage, ifapAction.message);

		ifapAction = IFAP_WebService.applyCashCondition(multicountryQuarterly.Id, multicountryQuarterly.AccountId);
		System.assertEquals(expectedNonComplianceMessage, ifapAction.message);

		exceptionRaised = false;

		try {
			sidraLite = WSSidraLite.sidraLiteAction(multicountryQuarterly.Id);
		} catch(WSSidraLite.ShowOnGoingNonComplianceConfirmationException e){
			exceptionRaised = true;
			System.assertEquals(expectedNonComplianceMessage, e.getMessage());
		}

		System.assert(exceptionRaised, 'A ShowOnGoingNonComplianceConfirmationException should have been raised');

		Id nonComplianceOnGoingIfapId = WSSidraLite.processNonComplianceOnDifferentIfap(multicountryQuarterly.Id);

		System.assertEquals(multicountryAnnual.Id, nonComplianceOnGoingIfapId, 'The on going non compliance must be the Multicountry Annual IFAP: ' + multicountryAnnual.Id);

		List<Task> taskLst = ANG_MulticountryHelper.fetchCaseNonComplianceTasks(multicountryAnnual.Id);

		System.assertEquals(1, taskLst.size(), 'One Non Compliance task must be created for Case ' + multicountryAnnual.Id);

	}

	@isTest static void financialSecurityCurrencyValidationTest(){

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Case multicountryAnnual = [SELECT 
										Id, AccountId, Account.Financial_Assessment_Points__c, 
										Account.Financial_Review_Result__c, Account.Assessment_Performed_Date__c
								   FROM Case
								   WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL
								   LIMIT 1];

		Test.startTest();

		try {
			multicountryAnnual.Financial_Security_Currency__c = CURRENCY_BOP;
			update multicountryAnnual;
		}
		catch (Exception e){
			System.assert(e.getMessage().contains('The Financial Security Currency selected is not allowed'));
		}

		multicountryAnnual.Financial_Security_Currency__c = CURRENCY_EUR;
		update multicountryAnnual;

		Test.stopTest();

	}

	@isTest static void insertMultipleMulticountryIFAPsOpenTest() {

		Account acct = [SELECT Id, (SELECT Id FROM Contacts) FROM Account LIMIT 1];

		Case ifapCase = new Case(
			ContactId = acct.Contacts.get(0).Id,
			AccountId = acct.Id,
			Subject = 'MC - Annual Financial Review - 2021',
			Description = 'MC - Annual Financial Review - 2021',
			Status = AMS_Utils.CASE_STATUS_AGENT_NOTIFIED_EMAIL,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2021',
			Deadline_Date__c = System.today().addDays(365),
			Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL,
			FA_Letter_Sent__c = true
		);

		Test.startTest();

		Boolean exceptionThrown = false;

		try {
			insert ifapCase;
		} catch (DMLException e) {
			exceptionThrown = true;
			System.assert(e.getMessage().contains(ANG_MulticountryHelper.MULTICOUNTRY_ACCOUNT_ALREADY_HAS_OPEN_IFAPS), 'Should throw the exception \''
				+ ANG_MulticountryHelper.MULTICOUNTRY_ACCOUNT_ALREADY_HAS_OPEN_IFAPS + '\'');
		}
		
		System.assert(exceptionThrown, 'Exception should have been thrown');
		
		exceptionThrown = false;
		
		try {
			ifapCase.Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ADHOC;
			insert ifapCase;
		} catch (DMLException e) {
			exceptionThrown = true;
			System.assert(e.getMessage().contains(ANG_MulticountryHelper.MULTICOUNTRY_ACCOUNT_ALREADY_HAS_OPEN_IFAPS), 'Should throw the exception \''
				+ ANG_MulticountryHelper.MULTICOUNTRY_ACCOUNT_ALREADY_HAS_OPEN_IFAPS + '\'');
		}

		System.assert(exceptionThrown, 'Exception should have been thrown');

		Test.stopTest();

	}

	@isTest
	static void updateMultipleMulticountryIFAPsOpenTest() {
		
		Case ifapCase = [SELECT Id, AccountId, Account.Financial_Assessment_Points__c, Account.Financial_Review_Result__c,
							 Account.Assessment_Performed_Date__c
						 FROM Case
						 WHERE Financial_Review_Type__c = :AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL
						 LIMIT 1];
		
		Test.startTest();

		Boolean exceptionThrown = false;
		
		try {
			ifapCase.Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ADHOC;
			update ifapCase;
		} catch (DMLException e) {
			exceptionThrown = true;
			System.assert(e.getMessage().contains(ANG_MulticountryHelper.MULTICOUNTRY_ACCOUNT_ALREADY_HAS_OPEN_IFAPS), 'Should throw the exception \''
				+ ANG_MulticountryHelper.MULTICOUNTRY_ACCOUNT_ALREADY_HAS_OPEN_IFAPS + '\'');
		}
		
		System.assert(exceptionThrown, 'Exception should have been thrown');

		Test.stopTest();

	}

}