@isTest
private class ANG_AnnualRevCaseCreationTest {

	@testSetup 
	static void setup(){
		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',
			ISO_Code__c='US', 
			Region__c = 'Europe', 
			ANG_Enable_NewGen__c = true);

		insert ctry;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', 
			ISO_Code__c = 'TS', 
			IATA_ISO_Country__c = ctry.Id);

		insert stt;

		Account account = new Account(Name = 'Main HE Account H1',
			Sector__c = 'Travel Agent',
			IATACode__c = '12345678',
			Category__c = 'IATA Passenger Sales Agent',
			Location_Class__c = 'P',
			Location_Type__c = 'HE',
			ANG_Accreditation_Model__c = 'Cashless',
			IATA_ISO_Country__c = ctry.Id,
			ANG_IEP_HE_AccntNum__c = '1232132323',
			ANG_IEP_Status__c = 'Suspended',
			ANG_HE_CashCondition__c = true,
			ANG_HE_RiskHistoryAssessment__c = 'Not Applicable',
			ANG_HE_RiskStatus__c = 'Not Applicable',
			RecordTypeId = accountAgencyRT,
			Status__c = 'Approved',
			Accreditation_date__c = system.today().addMonths(-9),
			Financial_Year_End__c = 'December');

		insert account;

		Contact co1 = new Contact(AccountId = account.id, 
			Lastname='John',
			Email = 'rambo.johnj@test.com', 
			Financial_Assessment_Contact__c = true);
		
		insert co1;

		Account a1 = new Account(Status__c = 'Approved', Accreditation_date__c = system.today().addMonths(-9), IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' ,RecordTypeId = accountAgencyRT, IATACode__c='12345671',Name='Account AE1 H1',Short_Name__c='Account AE1 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);
		Account a2 = new Account(Status__c = 'Approved', Accreditation_date__c = system.today().addMonths(-9), IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' , RecordTypeId = accountAgencyRT, IATACode__c='12345672',Name='Account AE2 H1',Short_Name__c='Account AE2 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);
		Account a3 = new Account(Status__c = 'Approved', Accreditation_date__c = system.today().addMonths(-9), IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' , RecordTypeId = accountAgencyRT, IATACode__c='12345673',Name='Account AE3 H1',Short_Name__c='Account AE3 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);

		insert new List<Account>{a1, a2, a3};

		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy (old)');
		insert h;

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a1.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);
		AMS_Agencies_relationhip__c r2 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a2.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);
		AMS_Agencies_relationhip__c r3 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a3.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);

		insert new List<AMS_Agencies_relationhip__c>{r1,r2,r3};

		IATA_ISO_Country__c pt = ANG_TestDataHelper.insertBspAndIsoCountry(ANG_TestDataHelper.COUNTRY_INFORMATION.get('PT'));
		IATA_ISO_Country__c gb = ANG_TestDataHelper.insertBspAndIsoCountry(ANG_TestDataHelper.COUNTRY_INFORMATION.get('GB'));
		
		Account ac1 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 GE PT', (Id) null, (Id) null, AMS_Utils.GE, pt, '10000000');
		Account ac2 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 HE GB', ac1.Id, ac1.Id, AMS_Utils.HE, gb, '10000001');

		ac1.Accreditation_date__c = System.today().addMonths(-9);
		ac1.Status__c = AMS_Utils.ACC_S9_APPROVED;
		ac1.RecordTypeId = accountAgencyRT;

		ANG_TestDataHelper.insertHierarchy(new List<Account>{
			ac1, ac2
		});

		Account ac3 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 2 GE PT', (Id) null, (Id) null, AMS_Utils.GE, pt, '10000002');
		Account ac4 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 2 HE GB', ac3.Id, ac3.Id, AMS_Utils.HE, gb, '10000003');

		ac3.Accreditation_date__c = System.today().addMonths(-9);
		ac3.Status__c = AMS_Utils.ACC_S9_APPROVED;
		ac3.RecordTypeId = accountAgencyRT;

		ANG_TestDataHelper.insertHierarchy(new List<Account>{
			ac3, ac4
		});

		update new List<Account>{
			ac1, 
			ac3
		};

		Contact co2 = new Contact(AccountId = ac1.Id, 
			Lastname='John2',
			Email = 'secondj@test.com', 
			Financial_Assessment_Contact__c = true);
		
		insert co2;

		Database.executeBatch(new ANG_AnualRevalCaseCreationBatch(new Set<Id>{ac1.Id}), 1);

		Test.stopTest();
	}

	@isTest 
	static void createOscarFromBatchTest() {
		List<Account> retrievedAccount = [SELECT Id FROM Account LIMIT 1];
		
		Test.startTest();

		Database.executeBatch(new ANG_AnualRevalCaseCreationBatch(new Set<Id>{retrievedAccount[0].Id}), 1);

		Test.stopTest();

		List<Account> updatedAccount = [SELECT Id,
											(SELECT Id FROM Cases)
										FROM Account
										LIMIT 1];

		System.assertEquals(1, updatedAccount[0].Cases.size(), 'Should have created a case');
	}

	@isTest 
	static void createAnualRevalCaseCreationController() {
		IATA_ISO_Country__c country = [SELECT Id, Name, Region__c FROM IATA_ISO_Country__c LIMIT 1];
		
		Test.startTest();
		ANG_AnualRevalCaseCreationController ctrl = new ANG_AnualRevalCaseCreationController();

		System.assertEquals(ctrl.nonSelectedAccreditations.size(), ctrl.accredModelOptions.size(), 'At start, both lists should have the same elements');
		
		ctrl.selectedAccreditations = new List<SelectOption>{
			new SelectOption('Multicountry', 'Multicountry')
		};
		ctrl.validateAccreditationModel();

		System.assert(ctrl.multicountryAccreditationModelSelected, 'Multicountry selected variable should be true');
		System.assert(ctrl.infoNote.contains(AMS_Utils.GE), 'Info note should contain \'GE\'');

		ctrl.searchAgencies();

		System.assertEquals(1, ctrl.accountsToCreate.size(), 'Should only find account without change cases');

		ctrl.selectedAccreditations = new List<SelectOption>{
			new SelectOption('Cash', 'Cash'),
			new SelectOption('Cashless', 'Cashless')
		};
		ctrl.validateAccreditationModel();

		System.assert(ctrl.cashOrLiteAccreditationModelSelected, 'Multicountry selected variable should be false');
		System.assert(ctrl.infoNote.contains(AMS_Utils.HE), 'Info note should contain \'HE\'');

		System.assert(ctrl.getshouldDisableButton(), 'Button should be disbaled at this point');

		ctrl.getregionobj();
		ctrl.setregion('Europe');

		ctrl.getmodeObj();

		ctrl.setmode('Country');
		ctrl.getcountryobj();
		ctrl.setcountry(country.Id);
		ctrl.searchAgencies();

		System.assertEquals(1, ctrl.accountsToCreate.size(), 'Should find Parent Account');

		ctrl.setmode('IATA Code');
		ctrl.iataCode = '12345678';
		ctrl.searchAgencies();

		System.assertEquals(1, ctrl.accountsToCreate.size(), 'Should find Parent Account');

		ctrl.setmode('Financial year end');
		ctrl.getMonthList();
		ctrl.setMonth(ANG_AnualRevalCaseCreationController.DECEMBER);
		ctrl.searchAgencies();

		List<SelectOption> paginationOptions = ctrl.paginationSizeOptions;

		System.assertEquals(1, ctrl.accountsToCreate.size(), 'Should find Parent Account');

		Boolean hasNext = ctrl.hasNext;
		Boolean hasPrevious = ctrl.hasPrevious;
		Integer pageNumber = ctrl.pageNumber;
		ctrl.next();
		ctrl.previous();
		ctrl.last();
		ctrl.first();

		ctrl.refreshPageSize();

		for(ANG_AnualRevalCaseCreationController.AccountWrapper aw: ctrl.accountsToCreate) {
			aw.selected = true;
		}

		ctrl.checkSelectedRecords();
		System.assertEquals(false, ctrl.disableLaunchButton, 'Should find Parent Account');

		ctrl.launchCampaign();

		ctrl.getBatchStatus();

		Test.stopTest();

		List<Account> updatedAccount = [SELECT Id,
											(SELECT Id FROM Cases)
										FROM Account
										LIMIT 1];

		System.assertEquals(1, updatedAccount[0].Cases.size(), 'Should have created a case');
	}

	@isTest 
	static void createAnualRevalCaseCreationForMajorChanges(){
		insert new ANG_AgencyChangesConfig__c(Name = 'ChangeName', 
			TC_Location_type__c = false, TC_Legal_status__c = false, TC_Location__c = false,
			TC_Minor_Shareholding__c = false, TC_Legal_Name__c = true, TC_Ownership__c = false, TC_Hierarchy__c = false,
			TC_Major_Shareholding__c = false,  TC_VMFR__c = false, TCA_Sanity_check__c = 'CHN', TCA_Application_withdrawal__c = 'CWD',
			Valid_Accreditation_Models__c = 'ALL');

		insert new Portal_Applications__c(name = 'Risk Profile and RHC');
		
		Account he = null;
		Account ae1 = null;
		Account ae2 = null;
		Account ae3 = null;

		for (Account acct : [SELECT Id, Name, ParentId, IATA_ISO_Country__c, Location_Class__c, IATACode__c, Location_Type__c,
								 ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c,
								 ANG_HE_RiskStatus__c
							 FROM Account]) {
			if (acct.Name == 'Main HE Account H1') {
				he = acct;
			}
			
			if (acct.Name == 'Account AE1 H1') {
				ae1 = acct;
			}
			
			if (acct.Name == 'Account AE2 H1') {
				ae2 = acct;
			}
			
			if (acct.Name == 'Account AE3 H1') {
				ae3 = acct;
			}
		}

		ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = he.id, RecordTypeId = rtChange, Process__c = 'ANG.MAJOR.CHANGES.1.0');
		insert oscar;

		Contact co1 = new Contact(AccountId = he.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
		oscarCase.AccountId = he.Id;
		oscarCase.ContactId = co1.Id;
		insert oscarCase;

		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
			IATAcode__c = he.IATAcode__c,
			Branch_Office_Country__c = he.IATA_ISO_Country__c,
			Location_Class__c = he.Location_Class__c,
			Location_Type__c = he.Location_Type__c,
			SAAM_Case__c = oscarCase.Id,
			Account_Name__c = 'Main HE Account H1',
			ISSP_AMS_Legal_Status__c = 'Association',
			Short_Name__c = 'Main HE Account H1',
			TradeName__c = 'Main HE Account H1',
			Trade_Name__c = 'Main HE Account H1',
			ISSP_AMS_License_No__c = '111222333',
			ISSP_AMS_VAT_Number_Input__c = '111222333',
			Branch_Office_Email__c = 'ltg23@fefff2.com',
			Website__c = 'wwww.asdasidsss12233.pt',
			Branch_Office_Phone__c = '123456780',
			Branch_Office_Phone_National__c = '123456780',
			Branch_Office_FAX__c = '123456780',
			Branch_Office_Fax_National__c = '123456780',
			Abbreviated_name__c = 'Main HE Account H1',
			VAT_Number_2__c = '111222333',
			ISSP_AMS_GDS_with_signed_contract__c = 'Amadeus'
		);

		insert stagingArea;

		List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

		Id personAccreditationRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

		accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 20, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse1', Last_name__c='Last1', Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com', RecordTypeId=personAccreditationRT));
		accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 20, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse2', Last_name__c='Last2', Job_title__c='ABC2', Mobile__c='+4112345672', Phone__c='3424322342', Email__c='unique@email2.com', RecordTypeId=personAccreditationRT));
		accreditationContacts.add(new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 60, AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = he.Id, First_name__c='NameToUse3', Last_name__c='Last3', Job_title__c='ABC3', Mobile__c='+4112345673', Phone__c='3424322343', Email__c='unique@email3.com', RecordTypeId=personAccreditationRT));

		insert accreditationContacts;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LEGAL_NAME;
        oscar.Status__c = 'Closed';
		oscar.RPM_Approval__c = 'Authorize Approval';
		oscar.STEP36__c = 'Passed';
		oscar.Risk_event_creation_date__c = system.today();
		update oscar;

		Test.startTest();
		ANG_AnualRevalCaseCreationController annualRevalCaseCtrl = new ANG_AnualRevalCaseCreationController();

		annualRevalCaseCtrl.selectedAccreditations = new List<SelectOption>{
			new SelectOption('Cash', 'Cash'),
			new SelectOption('Cashless', 'Cashless')
		};
		annualRevalCaseCtrl.validateAccreditationModel();

		annualRevalCaseCtrl.setmode('Country');
		annualRevalCaseCtrl.setregion('Europe');
		annualRevalCaseCtrl.setcountry(he.IATA_ISO_Country__c);
		annualRevalCaseCtrl.searchAgencies();

		for(ANG_AnualRevalCaseCreationController.AccountWrapper aw: annualRevalCaseCtrl.accountsToCreate) {
			aw.selected = true;
		}

		annualRevalCaseCtrl.launchCampaign();

		Boolean flag = false;
		ANG_AnualRevalCaseCreationController.AccountWrapper validateAcc = new ANG_AnualRevalCaseCreationController.AccountWrapper(he, null, true);

		for (ANG_AnualRevalCaseCreationController.AccountWrapper a: annualRevalCaseCtrl.accountsToCreate) {
			flag = true;
			break;
		}
		
		System.assert(flag, 'Its expected that the account map contains the account he for the filter criteria');

		Test.stopTest();

	}
}