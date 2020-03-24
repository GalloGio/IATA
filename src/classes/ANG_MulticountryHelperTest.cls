@isTest
private class ANG_MulticountryHelperTest {

	@testSetup static void setup(){

		Test.startTest();

		Portal_Applications__c pa = new Portal_Applications__c(name = 'Risk Profile and RHC');
		insert pa;

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspGB = new AMS_Settlement_System__c(
			Name = 'BSP-GB',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspFR = new AMS_Settlement_System__c(
			Name = 'BSP-FR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspGB, bspFR};

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c();

		countryPT.Name = 'Portugal';
		countryPT.ISO_Code__c = 'PT';
		countryPT.ANG_Enable_NewGen__c = true;
		countryPT.AMS_Settlement_System__c = bspPT.Id;
		countryPT.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countryUK = new IATA_ISO_Country__c();

		countryUK.Name = 'United Kingdom';
		countryUK.ISO_Code__c = 'GB';
		countryUK.ANG_Enable_NewGen__c = true;
		countryUK.AMS_Settlement_System__c = bspGB.Id;
		countryUK.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c();

		countryFR.Name = 'France';
		countryFR.ISO_Code__c = 'FR';
		countryFR.ANG_Enable_NewGen__c = true;
		countryFR.AMS_Settlement_System__c = bspFR.Id;
		countryFR.Multicountry_Enabled__c = true;

		insert new List<IATA_ISO_Country__c>{countryPT, countryUK, countryFR};

		Id standardAcctRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account accountGE = new Account();

		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = countryPT.Id;
		accountGE.RecordTypeId = standardAcctRecId;
		accountGE.Type = 'IATA Passenger Sales Agent';

		insert accountGE;

		Account accountHE = new Account();
		accountHE.Name = 'Multicountry HE UK';
		accountHE.ParentId = accountGE.Id;
		accountHE.Location_Type__c = AMS_Utils.HE;
		accountHE.Location_Class__c = 'P';
		accountHE.IATA_ISO_Country__c = countryUK.Id;
		accountHE.RecordTypeId = standardAcctRecId;

		Account accountAE = new Account();
		accountAE.Name = 'Multicountry AE PT';
		accountAE.ParentId = accountGE.Id;
		accountAE.Location_Type__c = AMS_Utils.AE;
		accountAE.Location_Class__c = 'P';
		accountAE.IATA_ISO_Country__c = countryPT.Id;
		accountAE.RecordTypeId = standardAcctRecId;

		insert new List<Account>{accountHE, accountAE};

		createStandardHierarchy(countryPT, countryUK, countryFR);
		createMulticountryHierarchy(countryPT, countryUK, countryFR);

		Test.stopTest();

	}

	/*
	 * S Account HE UK
	 *	|_ S Account AE UK
	 *	|_ S Account 2 AE UK
	 */
	private static void createStandardHierarchy(
		IATA_ISO_Country__c countryPT, IATA_ISO_Country__c countryUK, IATA_ISO_Country__c countryFR)
	{
		Id standardAcctRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

			Account accountHEUK = makeAccount('S Account HE UK', (Id) null, AMS_Utils.HE, countryUK.Id,
				'12341234', ANG_Risk_Helper.RISK_STATUS_B);
			insert accountHEUK;

		Account accountAEUK = makeAccount('S Account AE UK', accountHEUK.Id, AMS_Utils.AE, countryUK.Id,
			'12341235', ANG_Risk_Helper.RISK_STATUS_B);
		insert accountAEUK;

		Account accountAEUK2 = makeAccount('S Account 2 AE UK', accountHEUK.Id, AMS_Utils.AE, countryUK.Id,
			'12341236', ANG_Risk_Helper.RISK_STATUS_B);
		insert accountAEUK2;


	}

	/*
	 * MC Account GE PT
	 *	|_ MC Account AE PT
	 *  |_ MC Account HE UK
	 *  |   |_ MC Account AE UK
	 *  |   |_ MC Account 2 AE UK
	 */
	private static void createMulticountryHierarchy(
		IATA_ISO_Country__c countryPT, IATA_ISO_Country__c countryUK, IATA_ISO_Country__c countryFR)
	{
		Id standardAcctRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account accountGEPT = makeAccount('MC Account GE PT', (Id) null, AMS_Utils.GE, countryPT.Id,
			'12312345', ANG_Risk_Helper.RISK_STATUS_B);
		insert accountGEPT;

		Account accountAEPT = makeAccount('MC Account AE PT', accountGEPT.Id, AMS_Utils.AE, countryPT.Id,
			'12312346', ANG_Risk_Helper.RISK_STATUS_B);
		insert accountAEPT;

		Account accountHEUK = makeAccount('MC Account HE UK', accountGEPT.Id, AMS_Utils.HE, countryUK.Id,
			'12312347', ANG_Risk_Helper.RISK_STATUS_B);
		insert accountHEUK;

		Account accountAEUK = makeAccount('MC Account AE UK', accountHEUK.Id, AMS_Utils.AE, countryUK.Id,
			'12312348', ANG_Risk_Helper.RISK_STATUS_B);
		insert accountAEUK;

		Account accountAEUK2 = makeAccount('MC Account 2 AE UK', accountHEUK.Id, AMS_Utils.AE, countryUK.Id,
			'12312349', ANG_Risk_Helper.RISK_STATUS_B);
		insert accountAEUK2;
	}

	private static Account makeAccount(String name, Id parent, String location, Id country, String iataCode, String risk)
	{
		Account acct = new Account();
		acct.Name = name;
		acct.ParentId = parent;
		acct.Location_Type__c = location;
		acct.Location_Class__c = 'P';
		acct.IATA_ISO_Country__c = country;
		acct.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		acct.IATACode__c = iataCode;
		acct.Status__c = AMS_Utils.ACC_S9_APPROVED;
		acct.ANG_HE_RiskStatus__c = risk;
		acct.Financial_Review_Result__c = ANG_Risk_Helper.FR_SATISFACTORY;
		acct.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
		acct.ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED;
		acct.ANG_HE_CashCondition__c = false;
		return acct;
	}

	@isTest static void allowIATACodeGenerationTest(){

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id
			 FROM Account
			 WHERE
				Name IN ('Multicountry HE UK', 'Multicountry GE PT')
			 ORDER BY
				Name ASC
			]
		);

		Account accountHE = accountLst.get(1);

		AMS_Oscar__c oscar = new AMS_OSCAR__c(
			RecordTypeId = AMS_Utils.RECTYPE_MCAE,
			Account__c = accountHE.Id
		);

		insert oscar;

		Case cse = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM,
			AccountId = accountHE.Id,
			Oscar__c = oscar.Id
		);

		insert cse;

		Test.startTest();

		AMS_OSCAR__c oscarWithRels = [SELECT Account__c, Account__r.Parent.Status__c FROM AMS_OSCAR__c];

		Boolean allowIATACodeGeneration = ANG_MulticountryHelper.allowIATACodeGeneration(oscarWithRels);

		System.assert(!allowIATACodeGeneration, 'Should not allow the IATA code generation.');

		Account accountGE = accountLst.get(0);

		accountGE.Status__c = AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING;
		accountGE.IATACode__c = '12345678';

		update accountGE;

		Agency_Applied_Change_code__c changeCodeApplied = new Agency_Applied_Change_code__c(
			Account__c = accountGE.Id,
			Change_Code__c = 'NEW',
			Sent_to_external_system__c = false
		);

		insert changeCodeApplied;

		oscarWithRels = [SELECT Account__c, Account__r.Parent.Status__c FROM AMS_OSCAR__c];

		allowIATACodeGeneration = ANG_MulticountryHelper.allowIATACodeGeneration(oscarWithRels);

		System.assert(allowIATACodeGeneration, 'Should allow the IATA code generation.');

		Test.stopTest();

	}

	@isTest static void allowApprovalStepTest(){

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id
			 FROM Account
			 WHERE
				Name IN ('Multicountry AE PT', 'Multicountry GE PT')
			 ORDER BY
				Name ASC
			]
		);

		Account accountAE = accountLst.get(0);

		AMS_Oscar__c oscar = new AMS_OSCAR__c(
			RecordTypeId = AMS_Utils.RECTYPE_MCAE,
			Account__c = accountAE.Id
		);

		insert oscar;

		Case cse = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM,
			AccountId = accountAE.Id,
			Oscar__c = oscar.Id
		);

		insert cse;

		Test.startTest();

		Boolean allowApproval = ANG_MulticountryHelper.allowApprovalStep(oscar);

		System.assert(!allowApproval, 'Should not allow the approval step.');

		Account accountGE = accountLst.get(1);

		Agency_Applied_Change_code__c changeCodeApplied = new Agency_Applied_Change_code__c(
			Account__c = accountGE.Id,
			Change_Code__c = 'FIN',
			Sent_to_external_system__c = false
		);

		insert changeCodeApplied;

		allowApproval = ANG_MulticountryHelper.allowApprovalStep(oscar);

		System.assert(allowApproval, 'Should allow the approval step.');

		Test.stopTest();

	}

	@isTest static void multicountryAccountValidationsTest() {

		Id standardAcctRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		List<IATA_ISO_Country__c> countriesLst = new List<IATA_ISO_Country__c>(
			[SELECT
				Id,
				Name
			 FROM IATA_ISO_Country__c
			 ORDER BY
				Name ASC
			]
		);

		IATA_ISO_Country__c countryFR = countriesLst.get(0);
		IATA_ISO_Country__c countryPT = countriesLst.get(1);
		IATA_ISO_Country__c countryUK = countriesLst.get(2);

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				IATA_ISO_Country__c
			 FROM Account
			 WHERE
				Name IN ('Multicountry GE PT', 'Multicountry HE UK')
			 ORDER BY
				Name ASC
			]
		);

		Account accountGE = accountLst.get(0);
		Account accountHE = accountLst.get(1);

		Test.startTest();

		Account HESameGEBSPCountry = new Account(
			Name = 'Trigger HE same bsp than GE',
			RecordTypeId = standardAcctRecId,
			IATA_ISO_Country__c = accountGE.IATA_ISO_Country__c,
			Location_Type__c = AMS_Utils.HE,
			Location_Class__c = 'P',
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			ParentId = accountGE.Id
		);

		try{
			insert HESameGEBSPCountry;
		}
		catch(Exception e){
			Boolean expectedExceptionThrown = e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error);
			System.assert(expectedExceptionThrown, 'Should throw \'' + Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error + '\'.');
		}

		Account HESameCountry = new Account(
			Name = 'Validation trigger same HE',
			RecordTypeId = standardAcctRecId,
			IATA_ISO_Country__c = countryUK.Id,
			Location_Type__c = AMS_Utils.HE,
			Location_Class__c = 'P',
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			ParentId = accountGE.Id
		);

		try{
			insert HESameCountry;
		}
		catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_With_Correct_HE_Error);
			System.assert(expectedExceptionThrown, 'Should throw \'' + Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_With_Correct_HE_Error + '\'.');
		}

		Account AECountry = new Account(
			Name = 'Validation trigger AE with no HE',
			IATA_ISO_Country__c = countryFR.Id,
			Location_Type__c = AMS_Utils.AE,
			Location_Class__c = 'P',
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			ParentId = accountGE.Id
		);

		try{
			insert AECountry;
		}
		catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_HE_Error);
			System.assert(expectedExceptionThrown, 'Should throw \'' + Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_HE_Error + '\'.');
		}

		accountHE.IATA_ISO_Country__c = countryPT.id;

		try{
			update accountHE;
		}
		catch(Exception e){
			Boolean expectedExceptionThrown = e.getMessage().contains(Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error);
			System.assert(expectedExceptionThrown, 'Should throw \'' + Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error + '\'.');
		}

		// Test country is not a Multicountry Enable
		countryPT.Multicountry_Enabled__c = false;
		update countryPT;

		Account GEnotMulticountryEnabled = new Account(
			Name = 'Account GE No Multicountry ',
			RecordTypeId = standardAcctRecId,
			IATA_ISO_Country__c = countryPT.id,
			Location_Type__c = AMS_Utils.GE,
			Location_Class__c = 'P',
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
		);

		try{
			insert GEnotMulticountryEnabled;
		}
		catch(Exception e){
			Boolean expectedExceptionThrown = e.getMessage().contains('The selected country is not enabled for multicountry');
			System.assert(expectedExceptionThrown, 'Should throw The selected country is not enabled for multicountry.');
		}

		Test.stopTest();
	}


	@isTest static void testmulticountryAccountHasRemittenceFrequencyEmpty() {

		List<Account> accountLst = new List<Account>(
			[SELECT Id
			 FROM Account
			 WHERE  Name IN ('Multicountry HE UK')
			 ORDER BY Name ASC
			]);

		Account accountHE = accountLst.get(0);

		AMS_Oscar__c oscar = new AMS_OSCAR__c(
			RecordTypeId = AMS_Utils.RECTYPE_MCAE,
			Account__c = accountHE.Id,
			Process__c = AMS_Utils.MCAE
		);

		insert oscar;

		Case cse = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM,
			AccountId = accountHE.Id,
			Oscar__c = oscar.Id
		);

		insert cse;

		AMS_Pax_Accreditation_Form__c paxAccreditation = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = cse.Id);
		insert paxAccreditation;

		oscar.AMS_Online_Accreditation__c = paxAccreditation.id;
		update oscar;

		AMS_Oscar__c oscar2 = [SELECT Id, Account__c, Process__c, Location_Type__c, AMS_Online_Accreditation__c
								FROM AMS_Oscar__c WHERE Account__c = : accountHE.Id limit 1];

		Test.startTest();

		Boolean hasRF = ANG_MulticountryHelper.multicountryAccountHasRemittenceFrequencyEmpty(oscar2);

		Test.stopTest();

		//Has empty Remittance Frequency
		System.assert(hasRF);

	}

	@isTest static void cloneOwnersFromParentAccountTest() {

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id , ParentId, Name
			 FROM Account
			 WHERE
				Name IN ('Multicountry HE UK', 'Multicountry GE PT')
			 ORDER BY
				Name ASC
			]
		);

		Account accountGE = accountLst.get(1).Name == 'Multicountry GE PT' ? accountLst.get(1) : accountLst.get(0);
		Account accountAE = accountLst.get(1).Name == 'Multicountry GE PT' ? accountLst.get(0) : accountLst.get(1);

		AMS_Oscar__c oscar = new AMS_OSCAR__c(
			RecordTypeId = AMS_Utils.RECTYPE_MCAE,
			Account__c = accountGE.Id
		);

		insert oscar;

		Case cse = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM,
			AccountId = accountGE.Id,
			Oscar__c = oscar.Id
		);

		insert cse;

		AMS_Pax_Accreditation_Form__c onlineAccreditation  = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', SAAM_Case__c = cse.Id, Account_Name__c = accountGE.Name);
		insert onlineAccreditation;

		System.assertEquals('The Parent Account could not be found.',ANG_MulticountryHelper.cloneOwnersFromParentAccount(onlineAccreditation.Id),'Expecting: The Parent Account could not be found.');

		Contact c1 = new Contact(AccountId = accountGE.id, Firstname = 'firstNAme', Lastname='LastNAme', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert c1;

		Id ownerRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

		AMS_Account_Role__c accountRole = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = accountGE.Id, Person__c = null, Contact__c = c1.Id, Percentage__c=100.0);
		insert accountRole;

		Test.startTest();

		Contact c2 = new Contact(AccountId = accountAE.id, Firstname = 'firstNAme', Lastname='LastNAme', Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com', Financial_Assessment_Contact__c = false);
		insert c2;

		AMS_Account_Role__c accountRoleAE = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = accountAE.Id, Person__c = null, Contact__c = c1.Id, Percentage__c=100.0);
		insert accountRoleAE;

		//for the AE
		AMS_Oscar__c oscarAE = new AMS_OSCAR__c(
			RecordTypeId = AMS_Utils.RECTYPE_MCAE,
			Account__c = accountAE.Id
		);

		insert oscarAE;

		Case cseAE = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM,
			AccountId = accountAE.Id,
			Oscar__c = oscarAE.Id
		);

		insert cseAE;

		AMS_Pax_Accreditation_Form__c onlineAccreditationAE  = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', SAAM_Case__c = cseAE.Id, Account_Name__c = accountAE.Name);
		insert onlineAccreditationAE;

		String result = ANG_MulticountryHelper.cloneOwnersFromParentAccount(onlineAccreditationAE.Id);

		System.assert(result == null);
		System.assertEquals(1,[Select Id from AMS_Accreditation_Contact__c].size(),'The expected size is 1.');
		System.assertEquals('You must provide a valid Online Accreditation Form Id.',ANG_MulticountryHelper.cloneOwnersFromParentAccount(null),'Expecting: You must provide a valid Online Accreditation Form Id.');
		Test.stopTest();

	}


	@isTest static void testGEAccreditationWithoutRequestFinancialSecurityStep() {

		AMS_ChangeCodes__c changeCodeCustomsettings = new AMS_ChangeCodes__c(Name = 'FIN-AMS', Change_Code__c = 'FIN', Reason_Code__c = '', Reason_Code_Description__c = '', Account_status_change__c = '',Integration_RecId__c = 'C');
		insert changeCodeCustomsettings;

		Account accountGE = [SELECT Id, ParentId, Name FROM Account WHERE Name IN ('Multicountry GE PT') Limit 1];

		accountGE.IATACode__c = '12345678';
		update accountGE;

		AMS_Oscar__c oscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_MCAE, Account__c = accountGE.Id, STEP6__c = AMS_Utils.PASSED, Process__c = AMS_Utils.NEWGESTANDARD);

		insert oscar;

		Test.startTest();

		oscar.STEP10__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		oscar.First_Step_Completed__c = true;
		try{
			update oscar;
		}catch(Exception ex){
			Boolean expectedExceptionThrown = ex.getMessage().contains('Approval can\'t be set if Request financial security step is not Passed.');
			System.assert(expectedExceptionThrown,'Should throw ' +  ex.getMessage());
		}

		Test.stopTest();
	}

	@isTest static void riskAssessmentCalcNewHeMulticountryTest(){

		AMS_ChangeCodes__c finChgCode = new AMS_ChangeCodes__c(
			Name = 'FIN-AMS',
			Change_Code__c = 'FIN',
			Reason_Code__c = '',
			Reason_Code_Description__c = '',
			Account_status_change__c = '',
			Integration_RecId__c = 'C'
		);
		insert finChgCode;

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				ISO_State__c,
				IATA_ISO_Country__c,
				ANG_HE_RiskHistoryAssessment__c
			 FROM Account
			 WHERE
				Name IN ('Multicountry HE UK', 'Multicountry GE PT')
			 ORDER BY
				Name ASC
			]
		);

		Account accountGE = accountLst.get(0);

		accountGE.Status__c = AMS_Utils.ACC_S9_APPROVED;
		accountGE.IATACode__c = '12345678';

		update accountGE;

		Agency_Applied_Change_code__c changeCodeAppliedNew = new Agency_Applied_Change_code__c(
			Account__c = accountGE.Id,
			Change_Code__c = 'NEW',
			Sent_to_external_system__c = false
		);

		Agency_Applied_Change_code__c changeCodeAppliedFin = new Agency_Applied_Change_code__c(
			Account__c = accountGE.Id,
			Change_Code__c = 'FIN',
			Sent_to_external_system__c = false
		);

		insert new List<Agency_Applied_Change_Code__c>{changeCodeAppliedNew, changeCodeAppliedFin};

		Account accountHE = accountLst.get(1);

		AMS_Oscar__c oscar = new AMS_OSCAR__c(
			RecordTypeId = AMS_Utils.RECTYPE_MCAE,
			Process__c = AMS_Utils.MCAE,
			Account__c = accountHE.Id,
			STEP6__c = AMS_Utils.PASSED,
			First_Step_Completed__c = true
		);

		insert oscar;

		Case cse = new Case(
			RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM,
			AccountId = accountHE.Id,
			Oscar__c = oscar.Id
		);

		insert cse;

		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c();
		theAccreditation.Account_Name__c='NEWGEN HE';
		theAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theAccreditation.Branch_Office_Country__c= accountHE.IATA_ISO_Country__c;
		theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
		theAccreditation.Branch_Office_City__c='City';
		theAccreditation.IATA_ISO_State__c= accountHE.ISO_State__c;
		theAccreditation.Branch_Office_Email__c='email@test.com';
		theAccreditation.Branch_Office_Phone__c='123123123';
		theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
		theAccreditation.Abbreviated_name__c='NEWGEN HE';
		theAccreditation.Abbreviated_Address__c='Street';
		theAccreditation.Remittance_frequency__c='M';
		theAccreditation.Solicitation_Flag__c=false;
		theAccreditation.Location_Class__c='P';
		theAccreditation.Location_Type__c='HE';
		theAccreditation.SAAM_Case__c=cse.Id;
		theAccreditation.ISSP_Branch_AccountId__c = accountHE.Id;
		insert theAccreditation;

		oscar.AMS_Online_Accreditation__c = theAccreditation.id;
		update oscar;

		accountHE.Status__c = AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING;
		accountHE.IATACode__c = '92345677';

		update accountHE;

		changeCodeAppliedNew = new Agency_Applied_Change_code__c(
			Account__c = accountHE.Id,
			Change_Code__c = 'NEW',
			Sent_to_external_system__c = false
		);

		insert changeCodeAppliedNew;

		Test.startTest();

		system.assertEquals(accountGE.ANG_HE_RiskHistoryAssessment__c, null, 'The risk assessment information should be empty');

		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;

		update oscar;

		accountGE = [SELECT Id, ANG_HE_RiskHistoryAssessment__c FROM Account WHERE Id = :accountGE.Id];
		system.assertEquals(accountGE.ANG_HE_RiskHistoryAssessment__c, 'Passed', 'The risk history assessment should pass');

		Test.stopTest();

	}

	@isTest
	public static void testGetChildHEAccounts()
	{
		Map<Id, Account> accountIds = new Map<Id, Account>([SELECT Id, Name, Location_type__c FROM Account
			 													WHERE Name IN ('MC Account GE PT', 'S Account HE UK')]);
		        
		Test.startTest();
		Map<Id, Account> accounts = ANG_MulticountryHelper.getAccountsInfo(accountIds.keySet());

		Test.stopTest();

		System.assertEquals(3, accounts.size()); // the 1 HE child for PT GE and the HE Standard

		List<String> names = new List<String>();
		for (Account a : accounts.values())
			names.add(a.Name);

		System.assert(names.contains('MC Account HE UK'), '"MC Account HE UK" account not found');
	}

	@isTest
	public static void testMulticountryDowngrade_Event()
	{
		List<Account> accounts = [SELECT Id FROM Account
									WHERE Name IN ('MC Account GE PT')
									ORDER BY Name ASC];

		Account accountGE = accounts.get(0);
		accountGE.Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY;
		accountGE.ANG_HE_RiskStatus__c = ANG_Risk_Helper.RISK_STATUS_C;

		Test.startTest();
		update accountGE;
		Test.stopTest();

		// the child cases are created from the batch which is not executed, but have to be registered
		List<AsyncApexJob> batches = [SELECT Id, Status, MethodName, ApexClass.Name, createddate
										FROM AsyncApexJob
										WHERE ApexClass.Name = 'ANG_RiskStatusDowngradeBatch'];
        
		System.assertEquals(1, batches.size(), 'Should have scheduled a Batch job');

	}

	@isTest
	public static void testMulticountryDowngrade_Batch()
	{
		List<Account> accounts = [SELECT Id FROM Account
									WHERE Name IN ('MC Account GE PT')
									ORDER BY Name ASC];

		Test.startTest();
		ANG_RiskStatusDowngradeBatch batch = new ANG_RiskStatusDowngradeBatch(new Set<Id> { accounts.get(0).Id });
		Id batchId = Database.executeBatch(batch);
		Test.stopTest();


		List<Case> cases = [SELECT Id, Account_Concerned__c FROM Case];
		System.assertEquals(1, cases.size()); 
		
		// 1 for each GE and 1 for each child HE accounts. In this case because of max number of batch executes, 
		Map<Id, Account> accountIds = new Map<Id, Account>([SELECT Id FROM Account
											 WHERE Name IN ('MC Account GE PT', 'MC Account HE UK')]);

		for (Case c : cases)
		{
			System.assert(accountIds.keySet().contains(c.Account_Concerned__c),
				'The cases were not associated with the right accounts');
		}
	}

	@isTest
	static void createIfapForMulticountryAgentTest(){

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				Name,
				ISO_State__c,
				Location_Type__c,
				Location_Class__c,
				IATA_ISO_Country__c
			 FROM Account
			 WHERE
			 	Location_Type__c = :AMS_Utils.GE
			 LIMIT 1
			]
		);

		Account acct = accountLst.get(0);

		acct.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		acct.IATACode__c = '99999999';
		update acct;

		Contact cont = new Contact(
			AccountId = acct.id,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'richard.vaughan@test.com',
			Financial_Assessment_Contact__c = true
		);

		insert cont;

		ANG_AgencyChangesHelper.testRunnningForNonBackup = true;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = acct.Id,
			Process__c = AMS_Utils.NGCHANGES,
			RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES,
			Status__c = 'Open'
		);

		insert oscar;

		Case oscarCase = new Case();
		oscarCase.Oscar__c = oscar.Id;
		oscarCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
		oscarCase.AccountId = acct.Id;
		oscarCase.ContactId = cont.Id;
		insert oscarCase;

		AMS_Pax_Accreditation_Form__c staging = new AMS_Pax_Accreditation_Form__c();

		staging.RecordTypeId = AMS_Utils.RECTYPE_NEWGEN_CHANGES_PAX;
		staging.Account_Name__c = acct.Name;
		staging.ISSP_AMS_Legal_Status__c = 'Association';
		staging.Branch_Office_Country__c = acct.IATA_ISO_Country__c;
		staging.Branch_Office_Street_name_number__c = 'sdfsdf';
		staging.Branch_Office_City__c = 'sdfsdfdf';
		staging.IATA_ISO_State__c = acct.Iso_State__c;
		staging.Branch_Office_Email__c = 'sdfsdfgdg@f3434.com';
		staging.Branch_Office_Phone__c = '123123123';
		staging.ISSP_AMS_Premises_located_at_airport__c = 'No';
		staging.Abbreviated_name__c = 'Multicountry ';
		staging.Abbreviated_Address__c = 'sdfsdf';
		staging.Remittance_frequency__c = 'M';
		staging.Solicitation_Flag__c = false;
		staging.Location_Class__c = acct.Location_Class__c;
		staging.Location_Type__c = acct.Location_Type__c;
		staging.SAAM_Case__c = oscarCase.Id;
		staging.ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert staging;

		AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c(
			AMS_Pax_Accreditation_Form__c = staging.Id,
			First_name__c = 'Richard',
			Last_name__c = 'Vaughan',
			Agency_owner__c = true,
			Email__c = 'richard.vaughan@test.com',
			PhoneNational__c = '123123123',
			Phone__c = '123123123',
			Contact__c = cont.Id,
			Financial_interest__c = 100,
			RecordTypeId = AMS_Utils.AccreditationContactPersonRT
		);

		insert acontact;

		Test.startTest();

		oscar.AMS_Online_Accreditation__c = staging.Id;
		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;

		update oscar;

		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

		String ifapCaseStr = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar.Id);

		Id ifapCaseId = Id.valueOf(ifapCaseStr.split(':')[0]);

		Case ifap = [SELECT Id, Deadline_Date__c, Financial_Review_Type__c FROM Case WHERE Id = :ifapCaseId];

		system.assertEquals(ifap.Deadline_Date__c, System.today().addDays(60), 'Deadline date must be 60 days from today\'s date');
		system.assertEquals(ifap.Financial_Review_Type__c, AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL, 'Financial Review Type must be \'Multicountry\'');

		Id financialReviewPdRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Multicountry_Yearly_Financial_Review');

		List<AMS_Process_Detail__c> pdLst = [SELECT Id FROM AMS_Process_Detail__c WHERE Case__c = :ifapCaseId AND RecordTypeId = :financialReviewPdRecordTypeId];

		system.assertEquals(pdLst.size(), 1, 'There must be a single process detail record with the record type \'Multicountry Yearly Financial Review\'');

		Test.stopTest();

	}

	@isTest static void updateFinancialReviewResultMulticountryTest(){
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				Name,
				ISO_State__c,
				Location_Type__c,
				Location_Class__c,
				IATA_ISO_Country__c
			 FROM Account
			 WHERE
			 	Location_Type__c = :AMS_Utils.GE
			 LIMIT 1
			]
		);

		Account accountGE = accountLst.get(0);

		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountGE.IATACode__c = '99999999';
		update accountGE;

		Contact cont = new Contact(
			AccountId = accountGE.Id,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'richard.vaughan@test.com',
			Financial_Assessment_Contact__c = true
		);
		insert cont;

		ID ifapCaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

		Case ifap = new Case();
		ifap.AccountId = accountGE.Id;
		ifap.ContactId = cont.Id;
		ifap.Subject = 'IFAP Multicountry';
		ifap.Status = 'Agent to be Notified';
		ifap.RecordTypeId = ifapCaseRecordTypeId;
		ifap.IFAP_Financial_Year__c = String.valueOf(Date.today().year());
		ifap.ArchivedDate__c = Date.today();
		ifap.Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL;
		insert ifap;

		Test.startTest();

		ifap.Financial_Assessment_Points__c = 70;
		ifap.Assessment_Performed_Date__c = System.today();
		ifap.Financial_Review_Result__c = AMS_Utils.FA_RESULT_SATISFACTORY_NO_ACTION;
		ifap.Reason_for_change_of_Financial_result__c = 'Testing';
		ifap.Status = AMS_Utils.CASE_STATUS_FINANCIAL_SECURITY_REQUESTED;

		update ifap;

		accountGE =
			[SELECT
				Id,
				Financial_Review_Result__c,
				Assessment_Performed_Date__c,
				Financial_Assessment_Points__c
			FROM Account
			WHERE
				Id = :accountGE.Id
			];

		system.assertEquals(accountGE.Financial_Assessment_Points__c, ifap.Financial_Assessment_Points__c);
		system.assertEquals(accountGE.Financial_Review_Result__c, ifap.Financial_Review_Result__c);
		system.assertEquals(accountGE.Assessment_Performed_Date__c, ifap.Assessment_Performed_Date__c);

		Test.stopTest();

	}

	@isTest static void doNotUpdateFinancialReviewResultMulticountryTest(){
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				Name,
				ISO_State__c,
				Location_Type__c,
				Location_Class__c,
				IATA_ISO_Country__c
			 FROM Account
			 WHERE
			 	Location_Type__c = :AMS_Utils.GE
			 LIMIT 1
			]
		);

		Account accountGE = accountLst.get(0);

		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountGE.IATACode__c = '99999999';
		update accountGE;

		Contact cont = new Contact(
			AccountId = accountGE.Id,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'richard.vaughan@test.com',
			Financial_Assessment_Contact__c = true
		);
		insert cont;

		ID ifapCaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

		Case ifap = new Case();
		ifap.AccountId = accountGE.Id;
		ifap.ContactId = cont.Id;
		ifap.Subject = 'IFAP Multicountry';
		ifap.Status = 'Agent to be Notified';
		ifap.RecordTypeId = ifapCaseRecordTypeId;
		ifap.IFAP_Financial_Year__c = String.valueOf(Date.today().year());
		ifap.ArchivedDate__c = Date.today();
		ifap.Financial_Review_Type__c = AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL;
		insert ifap;

		Test.startTest();

		ifap.Financial_Assessment_Points__c = 70;
		ifap.Assessment_Performed_Date__c = System.today();
		ifap.Financial_Review_Result__c = AMS_Utils.FA_RESULT_SATISFACTORY_NO_ACTION;
		ifap.Status = AMS_Utils.CASE_STATUS_FINANCIAL_SECURITY_REQUESTED;
		ifap.Exception_Approved_On__c = System.today();
		ifap.Reason_for_change_of_Financial_result__c = 'Testing';

		update ifap;

		accountGE =
			[SELECT
				Id,
				Financial_Review_Result__c,
				Assessment_Performed_Date__c,
				Financial_Assessment_Points__c
			FROM Account
			WHERE
				Id = :accountGE.Id
			];

		system.assertNotEquals(accountGE.Financial_Assessment_Points__c, ifap.Financial_Assessment_Points__c);
		system.assertNotEquals(accountGE.Financial_Review_Result__c, ifap.Financial_Review_Result__c);
		system.assertNotEquals(accountGE.Assessment_Performed_Date__c, ifap.Assessment_Performed_Date__c);

		Test.stopTest();

	}

	@isTest
	public static void testIsAccountInMulticountryCountry()
	{
		List<Account> accounts = [SELECT Id, IATA_ISO_Country__c
									FROM Account
									WHERE Name IN ('MC Account GE PT')
									ORDER BY Name ASC];
		Test.startTest();
		List<IATA_ISO_Country__c> countries = ANG_MulticountryHelper.getAccountCountry(accounts);
		for (IATA_ISO_Country__c c : countries)
			system.assert(ANG_MulticountryHelper.isMulticountryCountry(c));
		Test.stopTest();
	}

}