@isTest
private class ANG_FinancialAssessmentTest {

	@testSetup static void setup(){

		Test.startTest();

		AMS_Settlement_System__c bspSG = new AMS_Settlement_System__c(
			Name = 'BSP-SG',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
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
			ANG_Enable_NewGen__c = true
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
			BillingCountry = 'Singapore'
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

		cse =
			[SELECT
				Id,
				Deadline_Date__c,
				FA_Third_Deadline_Date__c,
				secondFAnonComplianceDate__c,
				AccountId
			 FROM
				Case
			 WHERE
				Id = :cse.Id
			 LIMIT 1
			];

		System.assertEquals(cse.secondFAnonComplianceDate__c, System.today());
		System.assertEquals(cse.FA_Third_Deadline_Date__c, cse.Deadline_Date__c.addDays(365));

		Account acct = 
			[SELECT 
				Id, 
				ANG_HE_CashCondition__c 
			 FROM 
				Account 
			 WHERE 
				Id = :cse.AccountId
			 LIMIT 1
			];

		system.assert(acct.ANG_HE_CashCondition__c);

		Case updCse = 
			[SELECT
				Id, 
				FA_Third_Deadline_Date__c,
				secondFAnonComplianceDate__c
			 FROM 
				Case 
			 WHERE 
				Id = :cse.Id
			 LIMIT 1
			];

		system.assertEquals(updCse.secondFAnonComplianceDate__c, System.today());
		system.assertEquals(updCse.FA_Third_Deadline_Date__c, System.today().addDays(365));

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

		Account acct = new Account(Id = cse.AccountId);
		acct.ANG_HE_CashCondition__c = true;
		update acct;

		message = IFAP_WebService.removeCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.CASH_CONDITION_SUCCESSFULLY_REMOVED, message); 

		acct = 
			[SELECT 
				Id, 
				ANG_HE_CashCondition__c 
			 FROM 
				Account 
			 WHERE 
				Id = :cse.AccountId
			 LIMIT 1
			];

		system.assert(!acct.ANG_HE_CashCondition__c);

	}

    @isTest
    static void updateThirdDeadlineDateForNewgenAgents(){
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
    	Case parentCase = [SELECT id, AccountId, Status, FA_Third_Deadline_Date__c
    					 FROM Case WHERE Account.ANG_IsNewGenAgency__c = TRUE LIMIT 1];

    	System.assertEquals(Date.today().addDays(365), parentCase.FA_Third_Deadline_Date__c);

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
	static void copyFinancialReviewResultWhenFSRequestedCaseStatus(){

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


}
