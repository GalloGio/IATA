@isTest
private class ANG_FinancialAssessmentTest {

	@testSetup static void setup(){

		Test.startTest();
		
        ANG_RME_Alert_Service_Test.createRMEMappings();
        
		AMS_Settlement_System__c bspSG = new AMS_Settlement_System__c(
			Name = 'BSP-SG',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'SGD'
		);

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert new List<AMS_Settlement_System__c>{bspSG, bspPT};

		IATA_ISO_Country__c countryWW = new IATA_ISO_Country__c(
			Name = 'All Countries',
			ISO_Code__c = 'WW'
		);

		IATA_ISO_Country__c countrySG = new IATA_ISO_Country__c (
			Name = 'Singapore', 
			ISO_Code__c = 'SG',
			AMS_Settlement_System__c = bspSG.Id,
			ANG_Enable_NewGen__c = true,
			Enable_Risk_Change_Codes__c = true
		);

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c (
			Name = 'Portugal', 
			ISO_Code__c = 'PT',
			AMS_Settlement_System__c = bspPT.Id,
			ANG_Enable_NewGen__c = false
		);

		insert new List<IATA_ISO_Country__c>{countryWW, countrySG, countryPT};

		Id recTypeCSA = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');

		AMS_Country_Specific_Attribute__c csa = new AMS_Country_Specific_Attribute__c(
			CurrencyIsoCode = 'EUR',
			RecordTypeId = recTypeCSA,
			IATA_ISO_Country__c = countryWW.Id,
			ANG_Minimum_RHC_Amount__c = 5000
		);

		insert csa;

		Account agentSG = new Account(
			Name = 'Agent SG',
			IATACode__c ='999999999',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countrySG.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			ANG_HE_RiskStatus__c = 'A',
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'Singapore',
			ANG_HE_CashCondition__c = TRUE,
			ANG_Accreditation_Model__c = 'Cash'
		);

		Account agentPT = new Account(
			Name = 'Agent PT',
			IATACode__c ='999999998',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HO,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countryPT.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'Portugal'
    	);

		insert new List<Account>{agentSG, agentPT};
			
		ANG_RHCHelper.createRHCInfo(new Set<Id>{agentSG.Id}, false);
		
    	Contact contSG = new Contact(
			FirstName = 'Agent',
			LastName = 'Singapore',
			Type_of_Contact__c = 'IFAP Contact',
			AccountId = agentSG.Id,
			Email = 'agent.singapore@test.com',
			Financial_Assessment_Contact__c = true
		);

		Contact contPT = new Contact(
			FirstName = 'Agent',
			LastName = 'Portugal',
			Type_of_Contact__c = 'IFAP Contact',
			AccountId = agentPT.Id,
			Email = 'agent.portugal@test.com',
			Financial_Assessment_Contact__c = true
		);
		
		insert new List<Contact>{contSG, contPT};
		
		Case caseSG = new Case(
			ContactId = contSG.Id,
			AccountId = agentSG.Id,
			Subject = 'Financial Review',
			Description = 'Financial Review - 2018',
			Status = 'Agent Notified',
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2018',
			Deadline_Date__c = System.today().addDays(-7)
		);

		Case casePT = new Case(
			ContactId = contPT.Id,
			AccountId = agentPT.Id,
			Subject = 'Financial Review',
			Description = 'Financial Review - 2018',
			Status = 'Agent Notified',
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2018',
			Deadline_Date__c = System.today().addDays(-7)
		);

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		insert new List<Case>{caseSG, casePT};

		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'Financial Institution', 
			Region__c = 'Asia & Pacific', 
			Country__c = 'Singapore', 
			Institution_Type__c = 'Bank'
		);

		insert fi;

		Case cc = new Case(AccountId = agentSG.Id);
		insert cc;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR', 
			Account__c = agentSG.Id, 
			Amount__c = 10000, 
			Expiry_date__c = System.Today().addDays(100), 
			Financial_Institution__c = fi.Id, 
			Security_Status__c = 'Not Active yet', 
			Security_Type__c = 'Bank Guarantee', 
			Region__c = 'Asia & Pacific', 
			Reception_Date__c = System.today(), 
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id
		);

		insert fs; 

		ANG_Risk_Event_Type__c riskEventType = new ANG_Risk_Event_Type__c(
			Name = 'Fail Financial Statements', 
			ANG_Risk_ID__c = '5', 
			ANG_Expiration__c = 12,
			Limit_Cash_conditions__c=false
		);

		insert riskEventType;

		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
    		ANG_AccountId__c = agentSG.Id,
			ANG_Event_Status__c = 'Active',
    		ANG_HE_AccountId__c = agentSG.Id,
    		ANG_Risk_Type__c = riskEventType.Id,
    		ANG_Issued_Date__c = System.today()
		);

		insert are;

		Test.stopTest();
		
	}

	@isTest static void applyCashConditionFromIFAPNonNewgenTest(){

		Case cse = 
			[SELECT 
				Id, 
				AccountId 
			 FROM 
				Case 
			 WHERE 
				Account.ANG_IsNewGenAgency__c = FALSE 
			 LIMIT 1
			];

		String message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, message); 

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-2);
		cse.Status = 'Agent Notified (Email)';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, message); 

		cse.FA_Second_Deadline_Date__c = System.today();
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, message); 

		cse.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		cse.Assessment_Performed_Date__c = System.today().addDays(1);
		cse.Status = 'Sanity Check Failure';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, message); 

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		cse.Assessment_Performed_Date__c = cse.FA_Second_Deadline_Date__c.addDays(-1);
		cse.Status = 'Agent Notified (Mail)';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, message); 

	}   

	@isTest static void applyCashConditionFromIFAPTest(){
		
		Case cse = 
			[SELECT 
				Id, 
				AccountId 
			 FROM 
				Case 
			 WHERE 
				Account.ANG_IsNewGenAgency__c = TRUE 
			 LIMIT 1
			];

		Account acct = new Account();
		acct.Id = cse.AccountId;
		acct.ANG_HE_CashCondition__c = FALSE;
		update acct;

		String message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, message); 

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-2);
		cse.Status = 'Agent Notified (Email)';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_TRIGGER_SIDRA_LITE, message); 

		cse.FA_Second_Deadline_Date__c = System.today();
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_APPLY, message); 

		cse.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		cse.Assessment_Performed_Date__c = System.today().addDays(1);
		cse.Status = 'Sanity Check Failure';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_REINSTATE_AGENT, message); 

		Financial_Security__c fs = 
			[SELECT 
				Id 
			 FROM 
				Financial_Security__c 
			 WHERE 
				Account__c = :cse.AccountId 
			 LIMIT 1
			];

		fs.Security_Status__c = 'Active';
		update fs;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_REMOVE_CASH_CONDITIONS, message); 

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		cse.Assessment_Performed_Date__c = cse.FA_Second_Deadline_Date__c.addDays(-1);
		cse.Status = 'Agent Notified (Mail)';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		System.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_APPLIED, message);

		ANG_Agency_Risk_Event__c riskEvent = 
			[SELECT
				Id,
				ANG_Limit_Cash_Conditions__c
			 FROM ANG_Agency_Risk_Event__c
			 WHERE
			 	ANG_Risk_Type__r.Name = 'Fail Financial Statements'
			 AND 
			 	ANG_Event_Status__c = 'Active'
			];

		system.assert(riskEvent.ANG_Limit_Cash_Conditions__c, 'Risk Event must have limit cash conditions TRUE');

		Case updCse = 
			[SELECT
				Id,
				Deadline_Date__c,
				FA_Third_Deadline_Date__c,
				secondFAnonComplianceDate__c
			 FROM 
				Case 
			 WHERE 
				Id = :cse.Id
			 LIMIT 1
			];

		system.assertEquals(updCse.secondFAnonComplianceDate__c, System.today());
		system.assertEquals(updCse.FA_Third_Deadline_Date__c, updCse.Deadline_Date__c.addDays(365));

	}

	@isTest static void removeCashConditionFromIFAPNonNewgenTest(){

		Case cse = 
			[SELECT 
				Id, 
				AccountId 
			 FROM 
				Case 
			 WHERE 
				Account.ANG_IsNewGenAgency__c = FALSE 
			 LIMIT 1
			];

		String message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE, message); 

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-2);
		cse.Status = 'Agent Notified (Email)';
		update cse;

		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE, message); 

		cse.FA_Second_Deadline_Date__c = System.today();
		update cse;

		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE, message); 

		cse.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		cse.Assessment_Performed_Date__c = System.today().addDays(1);
		cse.Status = 'Sanity Check Failure';
		update cse;

		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE, message); 

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		cse.Assessment_Performed_Date__c = cse.FA_Second_Deadline_Date__c.addDays(-1);
		cse.Status = 'Agent Notified (Mail)';
		update cse;

		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE, message);

	}   

	@isTest static void removeCashConditionFromIFAPTest(){
		
		Case cse = 
			[SELECT 
				Id, 
				AccountId 
			 FROM 
				Case 
			 WHERE 
				Account.ANG_IsNewGenAgency__c = TRUE 
			 LIMIT 1
			];
        
        Account acct = new Account(Id = cse.AccountId);
		acct.ANG_HE_CashCondition__c = FALSE;
		update acct;
        
		String message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE, message); 

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-2);
		cse.Status = 'Agent Notified (Email)';
		update cse;

		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE, message); 

		cse.FA_Second_Deadline_Date__c = System.today();
		update cse;

		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED_REMOVE, message); 
	
		cse.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		cse.Assessment_Performed_Date__c = System.today().addDays(1);
		cse.Status = 'Sanity Check Failure';
		update cse;

		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_REINSTATE_AGENT, message); 

		Financial_Security__c fs = 
			[SELECT 
				Id 
			 FROM 
				Financial_Security__c 
			 WHERE 
				Account__c = :cse.AccountId 
			 LIMIT 1
			];

		fs.Security_Status__c = 'Active';
		update fs;

        message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.AGENT_DOES_NOT_HAVE_CASH_CONDITION, message); 
        
        acct = new Account(Id = cse.AccountId);
		acct.ANG_HE_CashCondition__c = TRUE;
		update acct;
        
		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_REMOVED, message); 

		ANG_Agency_Risk_Event__c riskEvent = 
			[SELECT
				Id,
				ANG_Limit_Cash_Conditions__c
			 FROM ANG_Agency_Risk_Event__c
			 WHERE
			 	ANG_Risk_Type__r.Name = 'Fail Financial Statements'
			 AND 
			 	ANG_Event_Status__c = 'Active'
			];

		system.assert(!riskEvent.ANG_Limit_Cash_Conditions__c, 'Risk Event must have limit cash conditions FALSE');

	}

    @isTest
    static void updateThirdDeadlineDateForNewgenAgentsTest(){
    	Case ifapCase = [SELECT id, AccountId, Status
    					 FROM Case 
    					 WHERE Account.ANG_IsNewGenAgency__c = TRUE 
    					 LIMIT 1];
   
    	CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

    	ifapCase.Status = 'Agent Notified (Mail)';
    	ifapCase.Financial_Review_Type__c = 'Annual';
    	ifapCase.FA_Letter_Sent__c = true;    	
    	update ifapCase; 

    	Case sidraCase = createSIDRALite(ifapCase);
    	sidraCase.BSP_CASS__c = 'BSP';
    	insert sidraCase;

    	ifapCase.FA_Second_Deadline_Date__c = Date.today().addDays(-1);
    	ifapCase.secondFAnonComplianceDate__c = null;
    	update ifapCase;

    	Test.startTest();
  		WSSidraLite.updateSecondAndThirdDeadline(ifapCase.id);
    	Test.stopTest();

    	//For Newgen Agents -> Check the parentCase.FA_Third_Deadline_Date__c
    	Case parentCase = [SELECT id, AccountId, Status, Deadline_Date__c, FA_Third_Deadline_Date__c
    					 FROM Case WHERE Account.ANG_IsNewGenAgency__c = TRUE LIMIT 1];

    	System.assertEquals(parentCase.Deadline_Date__c.addDays(365), parentCase.FA_Third_Deadline_Date__c);

    }

    private static Case createSIDRALite(Case parent) {
        Case cse = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            ParentId = parent.Id,
            accountId = parent.accountId,
            BSPCountry__c = 'BSP-SG',
            SIDRA_Lite_Reason__c = SidraLiteHelperForIFAP.isFS(parent)? 'Financial Security Non-compliance': 'Financial Review Non-compliance'
        );
        return cse;
    }

	/**
	 * Verify when a IFAP Case is being set the Financial_Review_Result__c field
	 * and its Status = Financial Security Requested
	 * Financial_Review_Result__c and Financial_Assessment_Points__c(just for HK and MK) must be copied into the Account 
	 *
	 * ANG_CaseTriggerHandler.updateFinancialReviewResultOnAccount 
	 */
	@isTest
	static void copyFinancialReviewResultWhenFSRequestedCaseStatusTest(){

		Case cse = [SELECT Id, AccountId FROM Case WHERE Account.ANG_IsNewGenAgency__c = TRUE LIMIT 1];

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		Test.startTest();

		cse.Status = AMS_Utils.CASE_STATUS_FINANCIAL_SECURITY_REQUESTED;
		cse.Financial_Review_Result__c = 'Satisfactory - No Action';
		cse.Financial_Assessment_Points__c = 100;
		cse.Assessment_Performed_Date__c = Date.today();
		update cse;

		Test.stopTest();	

		Account accountUpdated = [SELECT id, Financial_Assessment_Points__c, Financial_Review_Result__c, Assessment_Performed_Date__c
								  FROM Account WHERE ANG_IsNewGenAgency__c = TRUE LIMIT 1];

		System.assertEquals('Satisfactory - No Action', accountUpdated.Financial_Review_Result__c);
		System.assertEquals(100, accountUpdated.Financial_Assessment_Points__c);
		System.assertEquals(Date.today(), accountUpdated.Assessment_Performed_Date__c);
	}


	@isTest
	static void generateNOTChangeCodeOnlyForLastIFAPClosed_NonComplianceStatusTest(){

		//Create AMS Change Code Custom Setting
		AMS_ChangeCodes__c amsChangeCode = new AMS_ChangeCodes__c(Name = 'ANG82', Accreditation_Model__c = 'NEWGEN', 
			Apply_to_hierarchy__c = true, Billable__c = false,  Class_Type__c = 'P', Change_Code__c = 'NOT', CurrencyIsoCode = 'EUR',
			Field1__c = 'SIDRA_Lite_Reason__c',  Field1Values__c = 'VALUES:Financial Review Non-compliance',
			Field2__c = 'DEF_Approval_Rejection__c',  Field2Values__c = 'VALUES:Approved',
			Field3__c = 'Reason_for_Default__c',  Field3Values__c = 'VALUES:Suspension - FA Non Compliance',
			Field4__c = 'Update_AIMS_DEF__c',  Field4Values__c = 'NOT Blank',
			Field5__c = 'Parent.Status',  Field5Values__c = 'VALUES:Sanity Check Failure',
			Field6__c = 'LastYearIFAP.Status',  Field6Values__c = 'VALUES:Closed_non compliance',
			Record_Type__c = 'SIDRA_Lite', Reason_Code__c = '61', Reason_Code_Description__c = 'NON COMPLIANCE TO FINANCIAL CRITERIA',
			Integration_RecId__c = 'C', Publish_HO_Only__c= true, Risk_ChangeCode__c = true, Published_in_bulletin__c = true
		);

		insert amsChangeCode;

		Contact contactAgentSG = [SELECT id, AccountId  FROM Contact WHERE Email = 'agent.singapore@test.com' LIMIT 1];

		//IFAP 2018 - Last year
		Case ifapCaseLastYear = [SELECT Id, AccountId FROM Case WHERE Account.ANG_IsNewGenAgency__c = TRUE LIMIT 1];

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

    	ifapCaseLastYear.Financial_Review_Type__c = 'Annual';
    	ifapCaseLastYear.FA_Letter_Sent__c = true;

    	//Set the Last IFAP Case as Closed this will create a Technical Log , in order to present an error message on the Sidra Page layout
		ifapCaseLastYear.Status = 'Closed';
    	update ifapCaseLastYear;

		//Create new IFAP Case
		Case currentIfapCase = new Case(
			ContactId = contactAgentSG.Id,
			AccountId = contactAgentSG.AccountId,
			Subject = 'Financial Review',
			Description = 'Financial Review - 2019',
			Status = 'Agent Notified',
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			IFAP_Financial_Year__c = '2019',
			Deadline_Date__c = System.today().addDays(31),
			Financial_Review_Type__c = 'Annual'
		);
		insert currentIfapCase;

		//Update currentIFAPCase
		currentIfapCase.Deadline_Date__c = System.today().addDays(-1);
		currentIfapCase.FA_Letter_Sent__c = true;
		currentIFAPCase.Status = 'Sanity Check Failure';
		update currentIfapCase;

    	Case sidraCase = createSIDRALite(currentIfapCase);
    	sidraCase.BSP_CASS__c = 'BSP';
    	insert sidraCase;

    	//Set this flag in order to Run again the AMS_OscarCase_RiskMgmt
    	AMS_OscarCase_RiskMgmt.EndRun();
		//Update SidraCase with the values from Excel
		sidraCase.SIDRA_Lite_Default_Date__c = Date.today();
		sidraCase.DEF_Approval_Rejection__c = 'Approved';
		sidraCase.Update_AIMS_DEF__c = DateTime.now();
		sidraCase.Reason_for_Default__c = 'Suspension - FA Non Compliance';
		sidraCase.DEF_Approval_Rejection_Date__c = DateTime.now();

		update sidraCase;

		//For the Last IFAP Case status = 'Closed' no NOT Change Code will be generated and a Technical Log will be created to show an error message
		List<Agency_Applied_Change_code__c> agencyChangeCode = [SELECT id, Change_Code__c FROM Agency_Applied_Change_code__c Where Account__c = :currentIfapCase.AccountId limit 1];
		//No change code generated
		System.assert(agencyChangeCode.isEmpty());

		Technical_Logs__c tecLogs = [SELECT id, Log__c FROM Technical_Logs__c limit 1];
		System.assert(tecLogs.Log__c.contains('NOT'));

		//Set the Last IFAP Case as Closed this will create a Technical Log , in order to present an error message on the Sidra Page layout
		ifapCaseLastYear.Status = 'Closed_Non compliance';
		update ifapCaseLastYear;

		//Set this flag in order to Run again the AMS_OscarCase_RiskMgmt
    	AMS_OscarCase_RiskMgmt.EndRun();
		//Update SidraCase with the values from Excel
		sidraCase.SIDRA_Lite_Default_Date__c = Date.today();
		sidraCase.DEF_Approval_Rejection__c = 'Approved';
		sidraCase.Update_AIMS_DEF__c = DateTime.now();
		sidraCase.Reason_for_Default__c = 'Suspension - FA Non Compliance';
		sidraCase.DEF_Approval_Rejection_Date__c = DateTime.now();
		update sidraCase;

		//With the previous data the NOT Change Code will be generated
		Agency_Applied_Change_code__c notChangeCode = [SELECT id, Change_Code__c FROM Agency_Applied_Change_code__c Where Account__c = :currentIfapCase.AccountId limit 1];
		System.assertEquals('NOT', notChangeCode.Change_Code__c);
		
	}

}