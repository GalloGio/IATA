@isTest
private class ANG_ChangeRHCCurrencyTest {

	private static Set<String> currencySet = new Set<String>{'USD', 'EUR'};

	@TestSetup
	static void setup(){

		Test.startTest();

		ANG_RHC_Currencies__c dollarCurrency = new ANG_RHC_Currencies__c();
		dollarCurrency.Name = 'USD';
		dollarCurrency.CurrencyIsoCode = 'USD';
		dollarCurrency.Currency_Name__c  = 'US Dollar';

		ANG_RHC_Currencies__c euroCurrency = new ANG_RHC_Currencies__c();
		euroCurrency.Name = 'EUR';
		euroCurrency.CurrencyIsoCode = 'EUR';
		euroCurrency.Currency_Name__c  = 'Euro';

		insert new List<ANG_RHC_Currencies__c>{dollarCurrency, euroCurrency};

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			CurrencyIsoCode = 'EUR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspGB = new AMS_Settlement_System__c(
			Name = 'BSP-GB',
			CurrencyIsoCode = 'EUR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspGB};

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

		insert new List<IATA_ISO_Country__c>{countryPT, countryUK};

		Id iataAgencyRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account accountGE = new Account();

		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = countryPT.Id;
		accountGE.RecordTypeId = iataAgencyRecTypeId;
		accountGE.Type = 'IATA Passenger Sales Agent';
		accountGE.IATACode__c = '999999999';
		accountGE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountGE.Status__c = 'Approved';
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountGE.Remittance_frequency__c = 'M';
		insert accountGE;

		Account accountHE = new Account();
		accountHE.Name = 'Multicountry HE UK';
		accountHE.ParentId = accountGE.Id;
		accountHE.Location_Type__c = AMS_Utils.HE;
		accountHE.Location_Class__c = 'P';
		accountHE.IATA_ISO_Country__c = countryUK.Id;
		accountHE.RecordTypeId = iataAgencyRecTypeId;
		accountHE.IATACode__c = '999999998';
		accountHE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountHE.Status__c = 'Approved';
		accountHE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountHE.Remittance_frequency__c = 'M';

		Account accountAE = new Account();
		accountAE.Name = 'Multicountry AE PT';
		accountAE.ParentId = accountGE.Id;
		accountAE.Location_Type__c = AMS_Utils.AE;
		accountAE.Location_Class__c = 'P';
		accountAE.IATA_ISO_Country__c = countryPT.Id;
		accountAE.RecordTypeId = iataAgencyRecTypeId;
		accountAE.IATACode__c = '999999997';
		accountAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAE.Status__c = 'Approved';
		accountAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountAE.Remittance_frequency__c = 'M';

		insert new List<Account>{accountHE, accountAE};

		ANG_RHCHelper.createRHCInfo(new Set<Id>{accountGE.Id}, false);

		Contact cont = new Contact(
			AccountId = accountGE.id,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'richard.vaughan@test.com',
			Financial_Assessment_Contact__c = true
		);

		insert cont;

		Case cse = new Case();
		cse.AccountId = accountGE.Id;
		cse.ContactId = cont.Id;
		cse.RecordTypeId = AMS_Utils.RECTYPE_SAAM;
		insert cse;

		Test.stopTest();

	}

	@isTest static void changeRhcCurrencyTest(){

		ANG_RHC_Information__c rhc =
			[SELECT
				Id,
				ANG_AccountId__c
			 FROM ANG_RHC_Information__c
			 WHERE
			 	ANG_AccountId__r.IATACode__c ='999999999'
			 LIMIT 1
			];

		Case cse =
			[SELECT
				Id
			 FROM Case
			 WHERE
			 	AccountId = :rhc.ANG_AccountId__c
			 LIMIT 1
			];

		PageReference pageRef = Page.ANG_ChangeRHCCurrency;

		pageRef.getParameters().put('Id', rhc.Id);

		Test.setCurrentPage(pageRef);

		ANG_ChangeRHCCurrency controller = new ANG_ChangeRHCCurrency();

		controller.toggleEditMode();

		system.assert(!controller.isEdit);

		controller.save();

		List<SelectOption> currencyLst = controller.plOptions;

		for(SelectOption so : currencyLst){
			System.assert(currencySet.contains(so.getValue()));
		}

		controller.rhc.CurrencyIsoCode = 'USD';
		controller.caseToUpdate.ParentId = cse.Id;

		controller.save();

		cse =
			[SELECT
				Id,
				Reason1__c,
				CaseArea__c,
				Subject
			 FROM Case
			 WHERE
			 	AccountId = :rhc.ANG_AccountId__c
			 LIMIT 1
			];

		System.assertEquals('RHC Changes', cse.Reason1__c, 'Reason1__c must be \'RHC Changes\'');
		System.assertEquals('Risk Management Process', cse.CaseArea__c, 'CaseArea__c must be \'RHC Changes\'');
		System.assertEquals('RHC currency updated', cse.Subject, 'Subject must be \'RHC Changes\'');

		rhc =
			[SELECT
				Id,
				CurrencyIsoCode
			 FROM ANG_RHC_Information__c
			 WHERE
			 	Id = :rhc.Id
			 LIMIT 1
			];

		System.assertEquals('USD', rhc.CurrencyIsoCode, 'RHC Currency must be USD');

	}
}