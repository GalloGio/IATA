@isTest
private class ANG_RHCMassCalculationTest {

	@testSetup static void setup() {

		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();

		IATA_ISO_Country__c countryAA = new IATA_ISO_Country__c (
			Name = 'AA',
			ISO_Code__c = 'AA',
			ANG_Enable_NewGen__c = true,
			Region__c = 'Europe',
			AIMS_Area_ID__c = '3',
			Multicountry_Enabled__c = true
		);

		IATA_ISO_Country__c countryBB = new IATA_ISO_Country__c (
			Name = 'BB',
			ISO_Code__c = 'BB',
			ANG_Enable_NewGen__c = true,
			Region__c = 'Europe',
			AIMS_Area_ID__c = '3',
			Multicountry_Enabled__c = true
		);
		
		countries.add(countryAA);
		countries.add(countryBB);
		insert countries;

		List<Account> agencies = new List<Account>();

		Account agencyGE = new Account(
			Name = 'Agency GE',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.GE,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countryBB.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			BillingCountry = 'BB',
			Type = 'IATA Passenger Sales Agent'
		);

		Account agencyRevertBSP = new Account(
			Name = 'AgencyRevertBSP',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HE,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countryBB.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			BillingCountry = 'BB',
			Type = 'IATA Passenger Sales Agent'
		);

		Account agencyApplyBSP = new Account(
			Name = 'AgencyApplyBSP',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
			IATA_ISO_Country__c = countryBB.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			BillingCountry = 'BB',
			Type = 'IATA Passenger Sales Agent'
		);

		Account agencyRevertIATA = new Account(
			Name = 'AgencyRevertIATA',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
			IATA_ISO_Country__c = countryAA.Id,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			IataCode__c = '22222222',
			BillingCountry = 'AA',
			Type = 'IATA Passenger Sales Agent'
		);

		Account agencyApplyIATA = new Account(
			Name = 'AgencyApplyIATA',
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			Location_Type__c = AMS_Utils.HE,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = countryAA.Id,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
			Location_Class__c = 'P',
			Remittance_frequency__c = 'M',
			IataCode__c = '11111111',
			BillingCountry = 'AA',
			Type = 'IATA Passenger Sales Agent'
		);

		agencies.add(agencyGE);
		agencies.add(agencyRevertBSP);
		agencies.add(agencyApplyBSP);
		agencies.add(agencyRevertIATA);
		agencies.add(agencyApplyIATA);
		insert agencies;

		Test.startTest();

		List<Contact> contacts = new List<Contact>();

		for (Account a: agencies) {
			Contact con = ISSP_ObjectFactory.createNewContact();
			con.AccountId = a.Id;
			con.Financial_Assessment_Contact__c = true;
			contacts.add(con);
		}

		insert contacts;

		List<Case> cases = new List<Case>();

		Case c1 = new Case(
			AccountId = agencyRevertBSP.Id,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			ClosedDate = Date.today() - 10,
			Region__c = 'Europe',
			CaseArea__c = 'IDK',
			ContactId = contacts[0].Id
		);

		Case c2 = new Case(
			AccountId = agencyApplyBSP.Id,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			ClosedDate = Date.today() - 10,
			Region__c = 'Europe',
			CaseArea__c = 'IDK',
			ContactId = contacts[1].Id
		);

		Case c3 = new Case(
			AccountId = agencyRevertIATA.Id,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			ClosedDate = Date.today() - 10,
			Region__c = 'Europe',
			CaseArea__c = 'IDK',
			ContactId = contacts[2].Id
		);

		Case c4 = new Case(
			AccountId = agencyApplyIATA.Id,
			RecordTypeId = AMS_Utils.RECTYPE_IFAP,
			ClosedDate = Date.today() - 10,
			Region__c = 'Europe',
			CaseArea__c = 'IDK',
			ContactId = contacts[3].Id
		);

		cases.add(c1);
		cases.add(c2);
		cases.add(c3);
		cases.add(c4);
		insert cases;

		Test.stopTest();

		List<ANG_RHC_Information__c> rhcInfos = new List<ANG_RHC_Information__c>();

		ANG_RHC_Information__c rhcInfoToRevertBSP = new ANG_RHC_Information__c(
			ANG_AccountId__c = agencyGE.Id,
			CurrencyIsoCode = 'USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0,
			ANG_RHC_Amount_Equals_FS__c = true,
			ANG_RHC_Amount__c = 15,
			ANG_RME_Amount__c = 100,
			ANG_CashCondition__c = false
		);

		ANG_RHC_Information__c rhcInfoToApplyBSP = new ANG_RHC_Information__c(
			ANG_AccountId__c = agencyApplyBSP.Id,
			CurrencyIsoCode = 'USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0,
			ANG_RHC_Amount_Equals_FS__c = false,
			ANG_RHC_Amount__c = 15,
			ANG_RME_Amount__c = 100,
			ANG_CashCondition__c = false
		);

		ANG_RHC_Information__c rhcInfoToRevertIATA = new ANG_RHC_Information__c(
			ANG_AccountId__c = agencyRevertIATA.Id,
			CurrencyIsoCode = 'USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0,
			ANG_RHC_Amount_Equals_FS__c = true,
			ANG_RHC_Amount__c = 15,
			ANG_RME_Amount__c = 100,
			ANG_CashCondition__c = false
		);

		ANG_RHC_Information__c rhcInfoToApplyIATA = new ANG_RHC_Information__c(
			ANG_AccountId__c = agencyApplyIATA.Id,
			CurrencyIsoCode = 'USD',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0,
			ANG_RHC_Amount_Equals_FS__c = false,
			ANG_RHC_Amount__c = 15,
			ANG_RME_Amount__c = 100,
			ANG_CashCondition__c = false,
			ANG_ConsumedRHC__c = 50
		);

		rhcInfos.add(rhcInfoToRevertBSP);
		rhcInfos.add(rhcInfoToApplyBSP);
		rhcInfos.add(rhcInfoToRevertIATA);
		rhcInfos.add(rhcInfoToApplyIATA);
		insert rhcInfos;

		update new ANG_RHC_Information__c(Id = rhcInfoToApplyIATA.Id, ANG_RHC_Amount_Forecasted__c = 100);
	}

	@isTest
	static void test_method_one() {
		List<Case> retrievedCases = [SELECT Id FROM Case];

		for (Case c: retrievedCases) {
			Test.setCreatedDate(c.Id, Datetime.newInstance(Date.today() - 15, Time.newInstance(0, 0, 0, 0)));
			c.Status = 'Closed';
		}
		update retrievedCases;

		Test.startTest();

		ANG_RHCMassCalculation controller = new ANG_RHCMassCalculation();
		// search filters
		controller.userRegion = 'Europe';
		controller.days = 30;

		Integer days = controller.days;
		List<SelectOption> regions = controller.regions;

		controller.search();
		controller.next();
		controller.previous();
		controller.last();
		controller.pageNumber = 20;
		controller.first();
		controller.selectAll = true;
		
		System.assertEquals(1, controller.agents.size(), 'Expected one result');
		
		//controller.calculate(); // no account selected, no work for the batch
		//controller.fetchResults();

		Test.stopTest();
	}

	@isTest
	static void excludeMulticountryAccountsFromCalculationTest() {
		List<Case> retrievedCases = [SELECT Id FROM Case];

		for (Case c: retrievedCases) {
			Test.setCreatedDate(c.Id, Datetime.newInstance(Date.today() - 15, Time.newInstance(0, 0, 0, 0)));
			c.Status = 'Closed';
		}
		update retrievedCases;

		Test.startTest();

		ANG_RHCMassCalculation controller = new ANG_RHCMassCalculation();
		// search filters
		controller.userRegion = 'Europe';
		controller.days = 30;

		Integer days = controller.days;
		List<SelectOption> regions = controller.regions;

		controller.search();
		controller.next();
		controller.previous();
		controller.last();
		controller.pageNumber = 20;
		controller.first();
		controller.selectAll = true;
		
		System.assertEquals(1, controller.agents.size(), 'Expected one result');
		
		id RHCGEAccount = [SELECT ANG_AccountId__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__r.Location_Type__c = :AMS_Utils.GE].Id;
		system.debug('dtullo --> RHCGEAccount ' + RHCGEAccount);
		Id geAccount = [SELECT Id FROM Account WHERE Location_Type__c = :AMS_Utils.GE].Id;
		for(id i:controller.agents.keySet())
			System.assertNotEquals(geAccount, i, 'GE Accounts should not be retrieved in rhcQuery()');

		Test.stopTest();
	}

	@isTest
	static void testSearchByCountry() {

		Test.startTest();

		ANG_RHCMassCalculation controller = new ANG_RHCMassCalculation();
		// search filters
		controller.userRegion = 'Europe';
		controller.regionSelected();
		controller.country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'AA'].Id;

		controller.search();
		System.assertEquals(true, controller.validRegion);
		System.assertNotEquals(0, controller.countries.size());
		
		System.assertEquals(1, controller.agents.size(), 'Expected one result');

		Test.stopTest();
	}
}