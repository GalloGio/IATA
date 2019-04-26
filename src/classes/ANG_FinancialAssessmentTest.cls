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
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED, message); 

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-2);
		cse.Status = 'Agent Notified (Email)';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED, message); 

		cse.FA_Second_Deadline_Date__c = System.today();
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED, message); 

		cse.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		cse.Assessment_Performed_Date__c = System.today().addDays(1);
		cse.Status = 'Sanity Check Failure';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED, message); 

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-1);
		cse.Assessment_Performed_Date__c = cse.FA_Second_Deadline_Date__c.addDays(-1);
		cse.Status = 'Agent Notified (Mail)';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED, message); 

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
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED, message); 

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

		cse.FA_Second_Deadline_Date__c = System.today().addDays(-2);
		cse.Status = 'Agent Notified (Email)';
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_TRIGGER_SIDRA_LITE, message); 

		cse.FA_Second_Deadline_Date__c = System.today();
		update cse;

		message = IFAP_WebService.applyCashCondition(cse.Id, cse.AccountId);
		system.assertEquals(IFAP_WebService.INVALID_ACTION_CONDITIONS_NOT_SATISFIED, message); 

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

	}

}