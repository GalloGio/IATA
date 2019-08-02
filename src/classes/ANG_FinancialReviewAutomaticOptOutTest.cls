@isTest
private class ANG_FinancialReviewAutomaticOptOutTest {

	@testSetup static void setup() {

		Test.startTest();

		Portal_Applications__c par = new Portal_Applications__c(
			Name = ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE
		);

		insert par;
		AMS_ChangeCodes__c chgFin = new AMS_ChangeCodes__c();
		chgFin.Name = 'FIN-AMS';
		chgFin.Account_status_change__c = '9';
		chgFin.Billable__c = FALSE;
		chgFin.Bulletin_Memo_Text__c = 'Filled in by AMS_Utis';
		chgFin.Change_Code__c = 'FIN';
		chgFin.Reason_Code_Description__c = 'ACCREDITED-MEETS-STANDARDS';
		chgFin.Reason_Code__c = '91';
		chgFin.Integration_RecId__c = 'A';
		chgFin.Published_in_bulletin__c = TRUE;
		chgFin.Used_By_CNS__c = TRUE;

		AMS_ChangeCodes__c chgNew = new AMS_ChangeCodes__c();
		chgNew.Name = 'NEW-AMS';
		chgNew.Account_status_change__c = '2';
		chgNew.Billable__c = TRUE;
		chgNew.Bulletin_Memo_Text__c = 'New application in progress';
		chgNew.Change_Code__c = 'NEW';
		chgNew.Reason_Code_Description__c = 'NEW APPLICATION IN PROGRESS';
		chgNew.Reason_Code__c = '21';
		chgNew.Integration_RecId__c = 'A';
		chgNew.Billable_Location_Class__c = 'P;C;D;R;T;I';

		insert new List<AMS_ChangeCodes__c>{chgNew, chgFin};

		AMS_Settlement_System__c bspCN = new AMS_Settlement_System__c(
			Name = 'BSP-CN',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			ANG_RHC_Amount_Equals_FS__c = false
		);

		insert new List<AMS_Settlement_System__c>{bspCN};

		IATA_ISO_Country__c countryWW = new IATA_ISO_Country__c(
			Name = 'All Countries',
			ISO_Code__c = 'WW'
		);		

		IATA_ISO_Country__c countryCN = new IATA_ISO_Country__c(
			Name = 'China (People\'s Republic of)', 
			ISO_Code__c = 'CN',
			AMS_Settlement_System__c = bspCN.Id,
			ANG_Enable_NewGen__c = true
		);

		insert new List<IATA_ISO_Country__c>{countryWW, countryCN};

		Id recTypeCSA = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', AMS_Utils.OPT_OUT_ACCREDITATION_CFG_RT_NAME);

		AMS_Country_Specific_Attribute__c csaLocD = new AMS_Country_Specific_Attribute__c(
			RecordTypeId = recTypeCSA,
			Location_Class__c = 'D',
			IATA_ISO_Country__c = countryCN.Id
		);

		insert new List<AMS_Country_Specific_Attribute__c>{csaLocD};

		Id standardAcctRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account agentCN = new Account(
			Name = 'Agent CN',
			IATACode__c = '999999999',
			Location_Type__c = AMS_Utils.HE,
			//Status__c = AMS_Utils.ACC_S9_APPROVED,
			RecordTypeId = standardAcctRecTypeId,
			IATA_ISO_Country__c = countryCN.Id,
			Location_Class__c = 'D',
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'China'
		);

		insert agentCN;

		Account agentAeCN = new Account(
			Name = 'Agent AE CN',
			IATACode__c = '999999998',
			Location_Type__c = AMS_Utils.AE,
			RecordTypeId = standardAcctRecTypeId,
			IATA_ISO_Country__c = countryCN.Id,
			Location_Class__c = 'D',
			ParentId = agentCN.Id
		);

		Account agentAe2CN = new Account(
			Name = 'Agent AE 2 CN',
			IATACode__c = '999999997',
			Location_Type__c = AMS_Utils.AE,
			RecordTypeId = standardAcctRecTypeId,
			IATA_ISO_Country__c = countryCN.Id,
			Location_Class__c = 'D',
			ParentId = agentCN.Id
		);

		Account cashlessAgent = new Account(
			Name = 'Agent Cashless CN',
			IATACode__c = '999999996',
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = agencyRecordTypeId,
			IATA_ISO_Country__c = countryCN.Id,
			Location_Class__c = 'D',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'China',
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS
		);

		insert new List<Account>{agentAeCN, agentAe2CN, cashlessAgent};

		Account cashlessAgentAE = new Account(
			Name = 'Agent Cashless AE CN',
			IATACode__c = '999999995',
			Location_Type__c = AMS_Utils.AE,
			RecordTypeId = agencyRecordTypeId,
			IATA_ISO_Country__c = countryCN.Id,
			Location_Class__c = 'D',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'China',
			ParentId = cashlessAgent.Id,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS
		);

		Account cashlessAgent2AE = new Account(
			Name = 'Agent Cashless 2 AE CN',
			IATACode__c = '999999994',
			Location_Type__c = AMS_Utils.AE,
			RecordTypeId = agencyRecordTypeId,
			IATA_ISO_Country__c = countryCN.Id,
			Location_Class__c = 'D',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Type = 'IATA Passenger Sales Agent',
			BillingCountry = 'China',
			ParentId = cashlessAgent.Id,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS
		);

		insert new List<Account>{cashlessAgentAE, cashlessAgent2AE};

		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c(
			Hierarchy_Name__c = 'Newgen Hierarchy Cashless'
		);
		
		insert h;

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true, 
			Child_Account__c = cashlessAgentAE.Id, 
			Parent_Account__c = cashlessAgent.Id, 
			Hierarchy__c = h.Id
		);
		
		AMS_Agencies_relationhip__c r2 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true, 
			Child_Account__c = cashlessAgent2AE.Id, 
			Parent_Account__c = cashlessAgent.Id, 
			Hierarchy__c = h.Id
		);

		insert new List<AMS_Agencies_relationhip__c>{r1, r2};

		Contact co1 = new Contact(
			AccountId = agentCN.id, 
			Firstname = 'John', 
			Lastname = 'Test', 
			Phone = '666123456', 
			MobilePhone = '911111111', 
			Email = 'test.john@test.com', 
			Financial_Assessment_Contact__c = false
		);

		Contact co2 = new Contact(
			FirstName = 'Agent',
			LastName = 'CN',
			Type_of_Contact__c = 'IFAP Contact',
			AccountId = agentCN.Id,
			Email = 'agent.china@test.com',
			Financial_Assessment_Contact__c = true
		);

		Contact co3 = new Contact(
			AccountId = cashlessAgent.id, 
			Firstname = 'Cashless', 
			Lastname = 'Agent', 
			Phone = '666122222', 
			MobilePhone = '911111112', 
			Email = 'cashless.agent@test.com', 
			Financial_Assessment_Contact__c = false
		);
		
		insert new List<Contact>{co1, co2, co3};

		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Process__c = AMS_Utils.NEWHESTANDARD, 
			Account__c = agentCN.Id,
			RecordTypeId = AMS_Utils.RECTYPE_NEWHE
		);

		insert oscar;

		//Since the trigger is not bulkified 
		//we have to insert oscars's separately
		AMS_OSCAR__c changesOscar = new AMS_OSCAR__c(
			Process__c = AMS_Utils.NGCHANGES, 
			Account__c = cashlessAgent.Id,
			RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES
		);

		insert changesOscar;

		Case oscarCase = new Case(
			Oscar__c = oscar.Id, 
			RecordTypeId = caseRT,
			AccountId = agentCN.Id,
			ContactId = co1.Id
		);

		insert oscarCase;
		
		Test.stopTest();

		Case changesOscarCase = new Case(
			Oscar__c = changesOscar.Id, 
			RecordTypeId = caseRT,
			AccountId = cashlessAgent.Id,
			ContactId = co3.Id
		);

		insert changesOscarCase;

		AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c(
			Account_Name__c = agentCN.Name,
			IATAcode__c = agentCN.IATAcode__c,
			Branch_Office_Country__c = agentCN.IATA_ISO_Country__c,
			SAAM_Case__c = oscarCase.Id,
			Remittance_frequency__c = 'M',
			Location_Class__c = 'D',
			Location_Type__c = AMS_Utils.HE
		);

		Id rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		AMS_Pax_Accreditation_Form__c chgsStagingArea = new AMS_Pax_Accreditation_Form__c(
			Account_Name__c = cashlessAgent.Name,
			IATAcode__c = cashlessAgent.IATAcode__c,
			Branch_Office_Country__c = cashlessAgent.IATA_ISO_Country__c,
			SAAM_Case__c = changesOscarCase.Id,
			Remittance_frequency__c = 'M',
			Location_Class__c = 'D',
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = rtChangesStagingId,
			ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_CASH
		);

		insert new List<AMS_Pax_Accreditation_Form__c>{stagingArea, chgsStagingArea};

		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		oscar.AMS_Online_Accreditation__c = stagingArea.Id;

		changesOscar.Oscar_Communication_Case_Id__c = changesOscarCase.Id;
		changesOscar.AMS_Online_Accreditation__c = chgsStagingArea.Id;

		update new List<AMS_OSCAR__c>{oscar, changesOscar};
		
		Attachment attc = new Attachment(
			OwnerId = UserInfo.getUserId(),
			IsPrivate = true,
			ParentId = oscar.Oscar_Communication_Case_Id__c,
			Body = Blob.valueOf('Test'),
			Name = 'test'
		);

		Attachment attcChg = new Attachment(
			OwnerId = UserInfo.getUserId(),
			IsPrivate = true,
			ParentId = changesOscar.Oscar_Communication_Case_Id__c,
			Body = Blob.valueOf('Test'),
			Name = 'test'
		);

		insert new List<Attachment>{attc, attcChg};

		AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
			Name= 'test owner',
			First_name__c = 'test',
			Last_name__c = 'owner',
			Email__c = 'owner.test@test.com',
			Phone__c = '123456789',
			Agency_owner__c = true,
			Financial_interest__c = 100,
			AMS_Pax_Accreditation_Form__c = oscar.AMS_Online_Accreditation__c,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
		);

		AMS_Accreditation_Contact__c ownerChg = new AMS_Accreditation_Contact__c(
			Name= 'test owner',
			First_name__c = 'test',
			Last_name__c = 'owner',
			Email__c = 'owner.test@test.com',
			Phone__c = '123456789',
			Financial_interest__c = 100,
			AMS_Pax_Accreditation_Form__c = changesOscar.AMS_Online_Accreditation__c,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'),
			Agency_owner__c = true
		);

		insert new List<AMS_Accreditation_Contact__c>{owner, ownerChg};
		
		Case cseIfap = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_CASEIFAP,
			Status = 'Open',
			Region__c = 'Asia & Pacific', 
			Origin= 'Agent Financial Review Notification', 
			Subject =  'Financial Review Case', 
			AccountId = oscar.Account__c, 
			BSPCountry__c = 'CN', 
			IFAP_Area__c = 'Area 3', 
			IFAP_Financial_Year__c =  String.valueOf(Date.today().year()),
			Deadline_Date__c = Date.today().addDays(360), 
			Contactid = co2.id, 
			Assessment_Performed_Date__c = Date.today()
		);

		Case cseChgIfap = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_CASEIFAP,
			Status = 'Open',
			Region__c = 'Asia & Pacific', 
			Origin= 'Agent Financial Review Notification', 
			Subject =  'Financial Review Case', 
			AccountId = changesOscar.Account__c, 
			BSPCountry__c = 'CN', 
			IFAP_Area__c = 'Area 3', 
			IFAP_Financial_Year__c =  String.valueOf(Date.today().year()),
			Deadline_Date__c = Date.today().addDays(360), 
			Contactid = co2.id, 
			Assessment_Performed_Date__c = Date.today()
		);

		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
		  
		insert new List<Case>{cseIfap, cseChgIfap};

	}

	@isTest static void newHEStandardAgentOptOutFieldOscarLeftPanelTest(){

		AMS_OSCAR__c oscar = 
			[SELECT 
				Id,
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c
			 WHERE
				Process__c = :AMS_Utils.NEWHESTANDARD
			 LIMIT 1
			];
		
		PageReference pageRef = Page.AMS_OSCAR_ProcessViewer;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', oscar.Id);
		
		AMS_OSCAR_ProcessViewerController ctrl = new AMS_OSCAR_ProcessViewerController();

		system.assert(ctrl.blockFAoptOut, 'Financial assessment opt-in / opt-out field should be blocked for edition');
		system.assert(!ctrl.hideFAoptOut, 'Financial assessment opt-in / opt-out field should NOT be hidden');
		
		AMS_OSCAR_JSON.Process process = ctrl.process.get(AMS_Utils.NEWHESTANDARD);

		Boolean faOptOutFldFound = false;

		//Find Financial assessment opt-in / opt-out field
		for(AMS_OSCAR_JSON.Flow flow : process.flows){
			if(flow.name == 'AMS_OSCAR_APPLICATIONPROCESSING'){
				for(AMS_OSCAR_JSON.Step step : flow.steps){
					if(step.name == 'STEP11'){
						for(String fldName : step.displayFields){
							if(fldName == 'ANG_FA_Opt_out__c'){
								faOptOutFldFound = true;
								break;
							}
						}
						break;
					}
				}
				break;
			}
		}

		system.assert(faOptOutFldFound, 'Financial assessment opt-in / opt-out field should be shown in the OSCAR left panel');

	}

	@isTest static void newHEStandardAgentNotApplicableFATest(){

		List<AMS_Country_Specific_Attribute__c> csaLst = new List<AMS_Country_Specific_Attribute__c>(
			[SELECT Id FROM AMS_Country_Specific_Attribute__c]
		);

		//force delete the configuration so the Opt Out field is set as 'N/A'
		delete csaLst;

		AMS_OSCAR__c oscar = 
			[SELECT 
				Id,
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c
			 WHERE
				Process__c = :AMS_Utils.NEWHESTANDARD
			 LIMIT 1
			];

		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.STEP6__c = AMS_Utils.PASSED;

		update oscar;

		oscar = 
			[SELECT 
				Id,
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c
			 WHERE
				Id = :oscar.Id
			 LIMIT 1
			];

		system.assert(oscar.ANG_FA_Opt_Out__c == AMS_Utils.NOT_APPLICABLE, 'The OSCAR should have the value \'' + AMS_Utils.NOT_APPLICABLE + '\' for \'Financial Assessment opt-in/opt-out\'');

	}

	@isTest static void newHEStandardAgentAutomaticallyOptOutFATest(){
		
        AMS_OSCARTriggerHandler.allOnlineAccr = null;
        
		AMS_OSCAR__c oscar = 
			[SELECT
				Id,
				ANG_FA_Opt_Out__c,
             	AMS_Online_Accreditation__c
			 FROM 
				AMS_OSCAR__c
			 WHERE
				Process__c = :AMS_Utils.NEWHESTANDARD
			 LIMIT 1
			];
		        
		system.assert(oscar.ANG_FA_Opt_Out__c == AMS_Utils.NOT_APPLICABLE, 'The OSCAR should have the default value \'' + AMS_Utils.NOT_APPLICABLE + '\' for \'Financial Assessment opt-in/opt-out\' before passing the sanity check');

		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.STEP6__c = AMS_Utils.PASSED;

		update oscar;

		oscar = 
			[SELECT
				Id,
				Account__c,
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c
			 WHERE
				Id = :oscar.Id
			 LIMIT 1
			];

		system.assert(oscar.ANG_FA_Opt_Out__c == AMS_Utils.FA_OPT_OUT, 'The OSCAR should have the value \'' + AMS_Utils.FA_OPT_OUT + '\' for \'Financial Assessment opt-in/opt-out\'');

		//It should be generated after the Step2 but to avoid
		//hiting the governor limits generates the change code before
		//just for the purpose of this test
		AMS_OSCAR_Webservice.createChangeCodeNEW(oscar.Id);
		
		Test.startTest();

		oscar.STEP11__c = AMS_Utils.PASSED;
		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.STEP34__c = AMS_Utils.PASSED;
		oscar.STEP35__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;


		assessfinancialReviewOptOut(oscar.Id);
		Test.stopTest();

	}

	@isTest static void changeOfAccreditationTypeNotApplicableFATest(){
		
		ANG_AgencyChangesHelper.testRunnningForNonBackup = true;

		List<AMS_Country_Specific_Attribute__c> csaLst = new List<AMS_Country_Specific_Attribute__c>(
			[SELECT Id FROM AMS_Country_Specific_Attribute__c]
		);

		//force delete the configuration so the Opt Out field is set as 'N/A'
		delete csaLst;

		ANG_AgencyChangesConfig__c chgCfg = new ANG_AgencyChangesConfig__c(
			Name = 'ChangeAccreditationType', 
			TC_Accreditation_Type__c = true,
			TCA_Sanity_check__c = 'CHI', 
			TCA_Application_withdrawal__c = 'CWD'
		);

		insert chgCfg;

		AMS_OSCAR__c oscar = 
			[SELECT 
				Id,
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c 
			 WHERE
				Process__c = :AMS_Utils.NGCHANGES
			 LIMIT 1
			];

		system.assert(oscar.ANG_FA_Opt_Out__c == AMS_Utils.NOT_APPLICABLE, 'The OSCAR should have the default value \'' + AMS_Utils.NOT_APPLICABLE + '\' for \'Financial Assessment opt-in/opt-out\' before passing the sanity check');

		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE;
		oscar.Change_effective_as_of__c = Date.Today();

		Test.startTest();

		update oscar;

		Test.stopTest();
		
		oscar = 
			[SELECT 
				Id, 
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c 
			 WHERE
				Id = :oscar.Id
			 LIMIT 1
			];

		system.assert(oscar.ANG_FA_Opt_Out__c == AMS_Utils.NOT_APPLICABLE, 'The OSCAR should have the value \'' + AMS_Utils.NOT_APPLICABLE + '\' for \'Financial Assessment opt-in/opt-out\'');

	}

	@isTest static void changeOfAccreditationTypeAutomaticallyOptOutFATest(){
		
		ANG_AgencyChangesHelper.testRunnningForNonBackup = true;

		ANG_AgencyChangesConfig__c chgCfg = new ANG_AgencyChangesConfig__c(
			Name = 'ChangeAccreditationType', 
			TC_Accreditation_Type__c = true,
			TCA_Sanity_check__c = 'CHI', 
			TCA_Application_withdrawal__c = 'CWD'
		);

		insert chgCfg;

		AMS_OSCAR__c oscar = 
			[SELECT 
				Id,
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c 
			 WHERE
				Process__c = :AMS_Utils.NGCHANGES
			 LIMIT 1
			];

		system.assert(oscar.ANG_FA_Opt_Out__c == AMS_Utils.NOT_APPLICABLE, 'The OSCAR should have the default value \'' + AMS_Utils.NOT_APPLICABLE + '\' for \'Financial Assessment opt-in/opt-out\' before passing the sanity check');

		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE;
		oscar.Change_effective_as_of__c = Date.Today();

		Test.startTest();

		update oscar;

		oscar = 
			[SELECT 
				Id, 
				Account__c,
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c 
			 WHERE
				Id = :oscar.Id
			 LIMIT 1
			];

		system.assert(oscar.ANG_FA_Opt_Out__c == AMS_Utils.FA_OPT_OUT, 'The OSCAR should have the value \'' + AMS_Utils.FA_OPT_OUT + '\' for \'Financial Assessment opt-in/opt-out\'');
		
		oscar.STEP11__c = AMS_Utils.PASSED;
		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.STEP34__c = AMS_Utils.PASSED;
		oscar.STEP35__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;

		Test.stopTest();
		
		assessfinancialReviewOptOut(oscar.Id);

	}

	private static void assessfinancialReviewOptOut(Id oscarId){

		AMS_OSCAR__c oscar = 
			[SELECT 
				Id,
				Account__c, 
				AMS_Online_Accreditation__c,
				Oscar_Communication_Case_Id__c,
				RecordType.DeveloperName,
				Account__r.ANG_isNewGenAgency__c,
				Account__r.ANG_FA_Opt_Out__c,
				Account__r.ANG_CashCondition__c,
				Account__r.ANG_RiskStatus__c,
				ANG_FA_Opt_Out__c
			 FROM 
				AMS_OSCAR__c
			 WHERE
				Id = :oscarId 
			 LIMIT 1
			];

		system.assert(oscar.Account__r.ANG_FA_Opt_Out__c, 'Agent should be Opt Out from Financial Assessment');
		system.assert(oscar.Account__r.ANG_CashCondition__c, 'Agent should have Cash Condition');
		system.assert(oscar.Account__r.ANG_RiskStatus__c == AMS_Utils.NOT_APPLICABLE, 'Agent should have \'Not Applicable\' risk status');

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				Name,
				ANG_FA_Opt_Out__c
			 FROM
				Account
			 WHERE
				ParentId = :oscar.Account__c
			]
		);

		for(Account acct : accountLst){
			system.assert(acct.ANG_FA_Opt_Out__c, 'Every agent from the hierarchy should be Opt Out from Financial Assessment');
		}

		List<Case> ifapLst = new List<Case>(
			[SELECT
				Id,
				Status
			 FROM
				Case
			 WHERE
				AccountId = :oscar.Account__c
			 AND
				RecordTypeId = :AMS_Utils.RECTYPE_CASEIFAP
			]
		); 

		for(Case cse : ifapLst){
			system.assert(cse.Status == IFAP_BusinessRules.CLOSEDOPTOUT, 'All IFAP cases should be in status \'' + IFAP_BusinessRules.CLOSEDOPTOUT + '\'');
		}

	}

}