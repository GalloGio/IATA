@isTest
private class ANG_MulticountryRHCTest {

	@testSetup
	static void setup(){

		Test.startTest();

		List<String> listAgencyId = new List<String>();
		List<String> listAirlineId = new List<String>();

		for (Profile profile: [SELECT Id, Name FROM Profile WHERE Name LIKE 'ISS Portal Airline%' OR Name LIKE 'ISS Portal Agency%']) {
			if(profile.Name.contains('ISS Portal Airline')){
				listAirlineId.add(profile.Id);
			}
			else {
				listAgencyId.add(profile.Id);
			}
		}

		List<ISSP_CS__c> listCs = new List<ISSP_CS__c>();

		listCs.add(
			new ISSP_CS__c(
				Name = 'ISS OperationalCalendar Airline Profil',
				Value__c = String.join(listAirlineId,',')
			)
		);

		listCs.add(
			new ISSP_CS__c(
				Name = 'ISS OperationalCalendar Agency Profile',
				Value__c = String.join(listAgencyId,',')
			)
		);

		insert listCs;

		ANG_RHC_Currencies__c rhcCurrencies = new ANG_RHC_Currencies__c();
		rhcCurrencies.Name = 'EUR';
		rhcCurrencies.CurrencyIsoCode = 'EUR';
		rhcCurrencies.Currency_Name__c  = 'Euro';
		insert rhcCurrencies;

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR',
			ANG_RHC_Amount_Equals_FS__c = TRUE
		);

		AMS_Settlement_System__c bspFR = new AMS_Settlement_System__c(
			Name = 'BSP-FR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspFR};

		List<Operational_Calendar__c> opCalendarList = new List<Operational_Calendar__c>();

		Operational_Calendar__c ptCalendarWeekly = new Operational_Calendar__c(
			First_Day__c = Date.today().addDays(5),
			Frequency_code__c = 'D',
			ISS_operation__c = bspPT.Id,
			Last_day__c = Date.today().addDays(10)
		);

		Operational_Calendar__c frCalendarWeekly = new Operational_Calendar__c(
			First_Day__c = Date.today().addDays(10),
			Frequency_code__c = 'D',
			ISS_operation__c = bspFR.Id,
			Last_day__c = Date.today().addDays(20)
		);

		opCalendarList.add(ptCalendarWeekly);
		opCalendarList.add(frCalendarWeekly);

		insert opCalendarList;

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c();

		countryPT.Name = 'Portugal';
		countryPT.ISO_Code__c = 'PT';
		countryPT.ANG_Enable_NewGen__c = true;
		countryPT.AMS_Settlement_System__c = bspPT.Id;
		countryPT.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c();

		countryFR.Name = 'France';
		countryFR.ISO_Code__c = 'FR';
		countryFR.ANG_Enable_NewGen__c = true;
		countryFR.AMS_Settlement_System__c = bspFR.Id;
		countryFR.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countryWW = new IATA_ISO_Country__c();

		countryWW.Name = 'All Countries';
		countryWW.ISO_Code__c = 'WW';

		insert new List<IATA_ISO_Country__c>{countryPT, countryFR, countryWW};

		AMS_Country_Specific_Attribute__c amsCountrySpecificAttr = new AMS_Country_Specific_Attribute__c(
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount'),
			IATA_ISO_Country__c = countryWW.Id,
			ANG_Minimum_RHC_Amount__c = 1000,
			CurrencyIsoCode = 'EUR'
		);

		insert amsCountrySpecificAttr;

		Id agencyRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account accountGE = new Account();
		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = countryPT.Id;
		accountGE.RecordTypeId = agencyRecTypeId;
		accountGE.IATACode__c = '99999999';
		accountGE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountGE.Status__c = 'Approved';
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountGE.Remittance_frequency__c = 'D';

		insert accountGE;

		Account accountFrHE = new Account();
		accountFrHE.Name = 'Multicountry HE FR';
		accountFrHE.ParentId = accountGE.Id;
		accountFrHE.Location_Type__c = AMS_Utils.HE;
		accountFrHE.Location_Class__c = 'P';
		accountFrHE.IATA_ISO_Country__c = countryFR.Id;
		accountFrHE.RecordTypeId = agencyRecTypeId;
		accountFrHE.IATACode__c = '99999997';
		accountFrHE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrHE.Status__c = 'Approved';
		accountFrHE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountFrHE.Remittance_frequency__c = 'D';

		Account accountAE = new Account();
		accountAE.Name = 'Multicountry AE PT';
		accountAE.ParentId = accountGE.Id;
		accountAE.Location_Type__c = AMS_Utils.AE;
		accountAE.Location_Class__c = 'P';
		accountAE.IATA_ISO_Country__c = countryPT.Id;
		accountAE.RecordTypeId = agencyRecTypeId;
		accountAE.IATACode__c = '99999996';
		accountAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAE.Status__c = 'Approved';
		accountAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountAE.Remittance_frequency__c = 'D';

		Account accountAE_2 = new Account();
		accountAE_2.Name = 'Multicountry AE PT 2';
		accountAE_2.ParentId = accountGE.Id;
		accountAE_2.Location_Type__c = AMS_Utils.AE;
		accountAE_2.Location_Class__c = 'P';
		accountAE_2.IATA_ISO_Country__c = countryPT.Id;
		accountAE_2.RecordTypeId = agencyRecTypeId;
		accountAE_2.IATACode__c = '99999995';
		accountAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAE_2.Status__c = 'Approved';
		accountAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountAE_2.Remittance_frequency__c = 'D';

		insert new List<Account>{accountFrHE, accountAE, accountAE_2};

		Account accountFrAE = new Account();
		accountFrAE.Name = 'Multicountry AE FR';
		accountFrAE.ParentId = accountFrHE.Id;
		accountFrAE.Location_Type__c = AMS_Utils.AE;
		accountFrAE.Location_Class__c = 'P';
		accountFrAE.IATA_ISO_Country__c = countryFR.Id;
		accountFrAE.RecordTypeId = agencyRecTypeId;
		accountFrAE.IATACode__c = '99999994';
		accountFrAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrAE.Status__c = 'Approved';
		accountFrAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountFrAE.Remittance_frequency__c = 'D';

		Account accountFrAE_2 = new Account();
		accountFrAE_2.Name = 'Multicountry AE FR 2';
		accountFrAE_2.ParentId = accountFrHE.Id;
		accountFrAE_2.Location_Type__c = AMS_Utils.AE;
		accountFrAE_2.Location_Class__c = 'P';
		accountFrAE_2.IATA_ISO_Country__c = countryFR.Id;
		accountFrAE_2.RecordTypeId = agencyRecTypeId;
		accountFrAE_2.IATACode__c = '99999993';
		accountFrAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrAE_2.Status__c = 'Approved';
		accountFrAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountFrAE_2.Remittance_frequency__c = 'D';

		insert new List<Account>{accountFrAE, accountFrAE_2};

		ANG_RHCHelper.createRHCInfo(new Set<Id>{accountGE.Id}, false);

		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'Bank',
			Region__c = 'Europe',
			Country__c = 'Portugal',
			Institution_Type__c = 'Bank',
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Financial_Institution__c', 'Generic_FI')
		);

		insert fi;

		Test.stopTest();

	}

	@isTest static void rhcCashConditionCalculationTest(){

		Financial_Institution__c fi =
			[SELECT Id
			 FROM Financial_Institution__c
			 LIMIT 1
			];

		Account accountGE =
			[SELECT Id
			 FROM Account
			 WHERE Location_Type__c = :AMS_Utils.GE
			 LIMIT 1
			];

		accountGE.ANG_HE_CashCondition__c = TRUE;

		update accountGE;

		Case cc = new Case(AccountId = accountGE.Id);
		insert cc;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = accountGE.Id,
			Amount__c = 100000,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);

		insert fs;

		cc.Financial_Security_Amount__c = 1000;
		cc.Financial_Security_Currency__c = 'EUR';
		update cc;

		ANG_RHC_Information__c rhcInfo =
			[SELECT
				Id,
				ANG_RHC_Amount_Forecasted__c
			 FROM ANG_RHC_Information__c
			 WHERE ANG_AccountId__c = :accountGE.Id
			];

		System.assertEquals(fs.Amount__c, rhcInfo.ANG_RHC_Amount_Forecasted__c);

	}

	@isTest static void rhcFormulaCalculationTest(){

		Financial_Institution__c fi =
			[SELECT Id
			 FROM Financial_Institution__c
			 LIMIT 1
			];

		Account accountGE =
			[SELECT Id
			 FROM Account
			 WHERE Location_Type__c = :AMS_Utils.GE
			 LIMIT 1
			];

		Case cc = new Case(AccountId = accountGE.Id);
		insert cc;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = accountGE.Id,
			Amount__c = 100000,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);

		insert fs;

		cc.Financial_Security_Amount__c = 50000;
		cc.Financial_Security_Currency__c = 'EUR';
		update cc;

		Test.startTest();

		ANG_RHC_Information__c rhcInfo =
			[SELECT
				Id,
				ANG_RHC_Amount_Forecasted__c
			 FROM ANG_RHC_Information__c
			 WHERE ANG_AccountId__c = :accountGE.Id
			];

		System.assertEquals(fs.Amount__c, rhcInfo.ANG_RHC_Amount_Forecasted__c);

		rhcInfo.ANG_RHC_Amount_Provisional__c = 4000;
		update rhcInfo;

		rhcInfo =
			[SELECT
				Id,
				ANG_RHC_Amount_Forecasted__c,
				ANG_RHC_Amount_Provisional__c,
				ANG_Exceeding_Financial_Security__c
			 FROM ANG_RHC_Information__c
			 WHERE ANG_AccountId__c = :accountGE.Id
			];

		System.assertEquals(400004000, rhcInfo.ANG_RHC_Amount_Forecasted__c);

		//After the stop test the future method that updates the Min FS on the RHC record is executed
		//and therefore the RHC Amount Forecasted will change again
		Test.stopTest();

		rhcInfo =
			[SELECT
				Id,
				ANG_RHC_Amount_Forecasted__c,
				ANG_RHC_Amount_Provisional__c,
				ANG_Exceeding_Financial_Security__c
			 FROM ANG_RHC_Information__c
			 WHERE ANG_AccountId__c = :accountGE.Id
			];

		System.assertEquals(fs.Amount__c, rhcInfo.ANG_RHC_Amount_Forecasted__c);



	}

	@isTest static void rhcEffectiveNewGeRiskEventGenerationTest(){

		Financial_Institution__c fi =
			[SELECT Id
			 FROM Financial_Institution__c
			 LIMIT 1
			];

		Account accountGE =
			[SELECT Id
			 FROM Account
			 WHERE Location_Type__c = :AMS_Utils.GE
			 LIMIT 1
			];

		Case cc = new Case(AccountId = accountGE.Id);
		insert cc;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = accountGE.Id,
			Amount__c = 100000,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);

		insert fs;

		cc.Financial_Security_Amount__c = 50000;
		cc.Financial_Security_Currency__c = 'EUR';
		update cc;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = accountGE.Id,
			Process__c = AMS_Utils.NEWGESTANDARD,
			RecordTypeId = AMS_Utils.RECTYPE_NEWGE,
			RPM_Approval__c = AMS_Utils.AUTH_APPROVAL
		);

		insert oscar;

		Case caseOscar = new Case(
			Oscar__c = oscar.Id,
			AccountId = accountGE.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication')
		);

		insert caseOscar;

		ANG_RHC_Information__c rhcInfo =
			[SELECT
				Id,
				ANG_RHC_Amount__c,
				ANG_RHC_Amount_Forecasted__c
			 FROM ANG_RHC_Information__c
			 WHERE
			 	ANG_AccountId__c = :accountGE.Id
			];

		System.assertNotEquals(rhcInfo.ANG_RHC_Amount__c, rhcInfo.ANG_RHC_Amount_Forecasted__c, 'RHC Amount must NOT be effective yet');

		Test.startTest();

		AMS_OSCAR_Webservice.createRiskEvent(oscar.Id);

		Test.stopTest();

		rhcInfo =
			[SELECT
				Id,
				ANG_RHC_Amount__c,
				ANG_RHC_Amount_Forecasted__c
			 FROM ANG_RHC_Information__c
			 WHERE
			 	ANG_AccountId__c = :accountGE.Id
			];

		System.assertEquals(rhcInfo.ANG_RHC_Amount__c, rhcInfo.ANG_RHC_Amount_Forecasted__c, 'RHC Amount must be effective');

	}

	@isTest
	public static void testRhcFormulaCalculationScenario1()
	{
		Id recId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');
		AMS_Country_Specific_Attribute__c amsCountrySpecificAttr = [SELECT Id
																	FROM AMS_Country_Specific_Attribute__c
																	WHERE RecordTypeId = :recId];
		amsCountrySpecificAttr.ANG_Minimum_RHC_Amount__c = 10000;
		update amsCountrySpecificAttr;

		Financial_Institution__c fi = [SELECT Id FROM Financial_Institution__c LIMIT 1];
		Account accountGE = [SELECT Id FROM Account WHERE Location_Type__c = :AMS_Utils.GE LIMIT 1];

		Case cc = new Case(AccountId = accountGE.Id);
		insert cc;

		ANG_RHC_Information__c rhcInfo = [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :accountGE.Id];
		rhcInfo.ANG_RME_Amount__c = 1000000;
		rhcInfo.ANG_RHC_Amount_Provisional__c = 1000000;
		rhcInfo.ANG_Minimum_Financial_Security__c = 700000;
		rhcInfo.ANG_Financial_Security__c = 700000;
		update rhcInfo;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = accountGE.Id,
			Amount__c = 700000,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);
		insert fs;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = accountGE.Id,
			Process__c = AMS_Utils.NEWGESTANDARD,
			RecordTypeId = AMS_Utils.RECTYPE_NEWGE,
			RPM_Approval__c = AMS_Utils.AUTH_APPROVAL
		);
		insert oscar;

		Case caseOscar = new Case(
			Oscar__c = oscar.Id,
			AccountId = accountGE.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication')
		);
		insert caseOscar;

		rhcInfo = [SELECT Id,
					ANG_RHC_Amount__c,
					ANG_RHC_Amount_Forecasted__c,
					ANG_Forecasted_RHC_Effective_date__c
			 	   FROM ANG_RHC_Information__c
			 	   WHERE ANG_AccountId__c = :accountGE.Id];

		System.assertEquals(1000000, rhcInfo.ANG_RHC_Amount_Forecasted__c);
		System.assertEquals(Date.today().addDays(5), rhcInfo.ANG_Forecasted_RHC_Effective_date__c);
	}

	@isTest
	public static void testRhcFormulaCalculationScenario2()
	{
		Id recId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');
		AMS_Country_Specific_Attribute__c amsCountrySpecificAttr = [SELECT Id
																	FROM AMS_Country_Specific_Attribute__c
																	WHERE RecordTypeId = :recId];
		amsCountrySpecificAttr.ANG_Minimum_RHC_Amount__c = 10000;
		update amsCountrySpecificAttr;

		Financial_Institution__c fi = [SELECT Id FROM Financial_Institution__c LIMIT 1];
		Account accountGE = [SELECT Id FROM Account WHERE Location_Type__c = :AMS_Utils.GE LIMIT 1];

		Case cc = new Case(AccountId = accountGE.Id);
		insert cc;

		ANG_RHC_Information__c rhcInfo = [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :accountGE.Id];
		rhcInfo.ANG_RME_Amount__c = 1000000;
		rhcInfo.ANG_RHC_Amount_Provisional__c = 1000000;
		rhcInfo.ANG_Minimum_Financial_Security__c = 700000;
		rhcInfo.ANG_Financial_Security__c = 400000;
		update rhcInfo;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = accountGE.Id,
			Amount__c = 400000,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);
		insert fs;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = accountGE.Id,
			Process__c = AMS_Utils.NEWGESTANDARD,
			RecordTypeId = AMS_Utils.RECTYPE_NEWGE,
			RPM_Approval__c = AMS_Utils.AUTH_APPROVAL
		);
		insert oscar;

		Case caseOscar = new Case(
			Oscar__c = oscar.Id,
			AccountId = accountGE.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication')
		);
		insert caseOscar;

		rhcInfo = [SELECT Id,
					ANG_RHC_Amount__c,
					ANG_RHC_Amount_Forecasted__c,
					ANG_Forecasted_RHC_Effective_date__c
			 	   FROM ANG_RHC_Information__c
			 	   WHERE ANG_AccountId__c = :accountGE.Id];

		System.assertEquals(571429, rhcInfo.ANG_RHC_Amount_Forecasted__c);
		System.assertEquals(Date.today().addDays(5), rhcInfo.ANG_Forecasted_RHC_Effective_date__c);
	}

	@isTest
	public static void testRhcFormulaCalculationScenario3()
	{
		Id recId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');
		AMS_Country_Specific_Attribute__c amsCountrySpecificAttr = [SELECT Id
																	FROM AMS_Country_Specific_Attribute__c
																	WHERE RecordTypeId = :recId];
		amsCountrySpecificAttr.ANG_Minimum_RHC_Amount__c = 10000;
		update amsCountrySpecificAttr;

		Financial_Institution__c fi = [SELECT Id FROM Financial_Institution__c LIMIT 1];
		Account accountGE = [SELECT Id FROM Account WHERE Location_Type__c = :AMS_Utils.GE LIMIT 1];

		Case cc = new Case(AccountId = accountGE.Id);
		insert cc;

		ANG_RHC_Information__c rhcInfo = [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :accountGE.Id];
		rhcInfo.ANG_RME_Amount__c = 1000000;
		rhcInfo.ANG_RHC_Amount_Provisional__c = 1000000;
		rhcInfo.ANG_Minimum_Financial_Security__c = 700000;
		rhcInfo.ANG_Financial_Security__c = 900000;
		update rhcInfo;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = accountGE.Id,
			Amount__c = 900000,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);
		insert fs;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = accountGE.Id,
			Process__c = AMS_Utils.NEWGESTANDARD,
			RecordTypeId = AMS_Utils.RECTYPE_NEWGE,
			RPM_Approval__c = AMS_Utils.AUTH_APPROVAL
		);
		insert oscar;

		Case caseOscar = new Case(
			Oscar__c = oscar.Id,
			AccountId = accountGE.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication')
		);
		insert caseOscar;

		rhcInfo = [SELECT Id,
					ANG_RHC_Amount__c,
					ANG_RHC_Amount_Forecasted__c,
					ANG_Forecasted_RHC_Effective_date__c
			 	   FROM ANG_RHC_Information__c
			 	   WHERE ANG_AccountId__c = :accountGE.Id];

		System.assertEquals(1285714, rhcInfo.ANG_RHC_Amount_Forecasted__c);
		System.assertEquals(Date.today().addDays(5), rhcInfo.ANG_Forecasted_RHC_Effective_date__c);
	}

	@isTest
	public static void testRhcFormulaCalculationScenario_minRHCAmount()
	{
		Id recId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');
		AMS_Country_Specific_Attribute__c amsCountrySpecificAttr = [SELECT Id
																	FROM AMS_Country_Specific_Attribute__c
																	WHERE RecordTypeId = :recId];
		amsCountrySpecificAttr.ANG_Minimum_RHC_Amount__c = 10000;
		update amsCountrySpecificAttr;

		Financial_Institution__c fi = [SELECT Id FROM Financial_Institution__c LIMIT 1];
		Account accountGE = [SELECT Id FROM Account WHERE Location_Type__c = :AMS_Utils.GE LIMIT 1];

		Case cc = new Case(AccountId = accountGE.Id);
		insert cc;

		ANG_RHC_Information__c rhcInfo = [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :accountGE.Id];
		rhcInfo.ANG_RME_Amount__c = 100;
		rhcInfo.ANG_RHC_Amount_Provisional__c = 100;
		rhcInfo.ANG_Minimum_Financial_Security__c = 70;
		rhcInfo.ANG_Financial_Security__c = 90;
		update rhcInfo;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = accountGE.Id,
			Amount__c = 90,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);
		insert fs;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = accountGE.Id,
			Process__c = AMS_Utils.NEWGESTANDARD,
			RecordTypeId = AMS_Utils.RECTYPE_NEWGE,
			RPM_Approval__c = AMS_Utils.AUTH_APPROVAL
		);
		insert oscar;

		Case caseOscar = new Case(
			Oscar__c = oscar.Id,
			AccountId = accountGE.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication')
		);
		insert caseOscar;

		rhcInfo = [SELECT Id,
					ANG_RHC_Amount__c,
					ANG_RHC_Amount_Forecasted__c,
					ANG_Forecasted_RHC_Effective_date__c
			 	   FROM ANG_RHC_Information__c
			 	   WHERE ANG_AccountId__c = :accountGE.Id];

		System.assertEquals(10000, rhcInfo.ANG_RHC_Amount_Forecasted__c);
		System.assertEquals(Date.today().addDays(5), rhcInfo.ANG_Forecasted_RHC_Effective_date__c);
	}

	@isTest
	public static void testRhcFormulaCalculationScenario_maxFS()
	{
		Id recId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');
		AMS_Country_Specific_Attribute__c amsCountrySpecificAttr = [SELECT Id
																	FROM AMS_Country_Specific_Attribute__c
																	WHERE RecordTypeId = :recId];
		amsCountrySpecificAttr.ANG_Minimum_RHC_Amount__c = 10000;
		update amsCountrySpecificAttr;

		Financial_Institution__c fi = [SELECT Id FROM Financial_Institution__c LIMIT 1];
		Account accountGE = [SELECT Id FROM Account WHERE Location_Type__c = :AMS_Utils.GE LIMIT 1];

		Case cc = new Case(AccountId = accountGE.Id);
		insert cc;

		ANG_RHC_Information__c rhcInfo = [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :accountGE.Id];
		rhcInfo.ANG_RME_Amount__c = 100;
		rhcInfo.ANG_RHC_Amount_Provisional__c = 100;
		rhcInfo.ANG_Minimum_Financial_Security__c = 90000;
		rhcInfo.ANG_Financial_Security__c = 90000;
		update rhcInfo;

		Financial_Security__c fs = new Financial_Security__c(
			CurrencyIsoCode = 'EUR',
			Account__c = accountGE.Id,
			Amount__c = 90000,
			Expiry_date__c = System.Today().AddDays(100),
			Financial_Institution__c = fi.Id,
			Security_Status__c = 'Active',
			Security_Type__c = 'Bank Guarantee',
			Region__c = 'Europe',
			Reception_Date__c = System.today(),
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id,
			Financial_Security_Validation_Case__c = cc.Id
		);
		insert fs;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = accountGE.Id,
			Process__c = AMS_Utils.NEWGESTANDARD,
			RecordTypeId = AMS_Utils.RECTYPE_NEWGE,
			RPM_Approval__c = AMS_Utils.AUTH_APPROVAL
		);
		insert oscar;

		Case caseOscar = new Case(
			Oscar__c = oscar.Id,
			AccountId = accountGE.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication')
		);
		insert caseOscar;

		rhcInfo = [SELECT Id,
					ANG_RHC_Amount__c,
					ANG_RHC_Amount_Forecasted__c,
					ANG_Forecasted_RHC_Effective_date__c
			 	   FROM ANG_RHC_Information__c
			 	   WHERE ANG_AccountId__c = :accountGE.Id];

		System.assertEquals(90000, rhcInfo.ANG_RHC_Amount_Forecasted__c);
		System.assertEquals(Date.today().addDays(5), rhcInfo.ANG_Forecasted_RHC_Effective_date__c);
	}


}
