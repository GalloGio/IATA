@isTest
private class ANG_RHCHelperTest {

	@testSetup static void setup() {

		Id devRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');

		List<AMS_Settlement_System__c> bspList = new List<AMS_Settlement_System__c>();
		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c(CurrencyIsoCode = 'USD', ANG_RHC_Amount_Equals_FS__c = true);
		bspList.add(settlement);
		AMS_Settlement_System__c settlement2 = new AMS_Settlement_System__c(CurrencyIsoCode = 'USD', ANG_RHC_Amount_Equals_FS__c = false);
		bspList.add(settlement2);
		insert bspList;

		list<String> listAirlineId = new list<String>();
		for (Profile profile: [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Airline%']) {
			listAirlineId.add(profile.Id);
		}

		list<String> listAgencyId = new list<String>();
		for (Profile profile: [SELECT Id FROM Profile WHERE Name LIKE 'ISS Portal Agency%']) {
			listAgencyId.add(profile.Id);
		}

		List<ISSP_CS__c> listCs = new list<ISSP_CS__c>();
		listCs.add(new ISSP_CS__c(Name='ISS OperationalCalendar Airline Profil',Value__c=String.join(listAirlineId,',')));
		listCs.add(new ISSP_CS__c(Name='ISS OperationalCalendar Agency Profile',Value__c=String.join(listAgencyId,',')));
		insert listCs;

		Date operationDate = Date.today();

		//Calendars for BSP1
		List<Operational_Calendar__c> opCalanderList = new List<Operational_Calendar__c>();
		Operational_Calendar__c opCalendar1 = new Operational_Calendar__c(First_Day__c = operationDate.addDays(5), Frequency_code__c = 'W',
			ISS_operation__c = settlement.id, Last_day__c = operationDate.addDays(10));
		opCalanderList.add(opCalendar1);
		Operational_Calendar__c opCalendar2 = new Operational_Calendar__c(First_Day__c = operationDate.addDays(11), Frequency_code__c = 'W',
			ISS_operation__c = settlement.id, Last_day__c = operationDate.addDays(18));
		opCalanderList.add(opCalendar2);
		Operational_Calendar__c opCalendar3 = new Operational_Calendar__c(First_Day__c = operationDate.addDays(1), Frequency_code__c = 'D',
			ISS_operation__c = settlement.id, Last_day__c = operationDate.addDays(2));
		opCalanderList.add(opCalendar3);
		Operational_Calendar__c opCalendar4 = new Operational_Calendar__c(First_Day__c = operationDate.addDays(3), Frequency_code__c = 'D',
			ISS_operation__c = settlement.id, Last_day__c = operationDate.addDays(4));
		opCalanderList.add(opCalendar4);

		//Calendars for BSP2
		Operational_Calendar__c opCalendar5 = new Operational_Calendar__c(First_Day__c = operationDate.addDays(5), Frequency_code__c = 'W',
			ISS_operation__c = settlement2.id, Last_day__c = operationDate.addDays(10));
		opCalanderList.add(opCalendar5);
		Operational_Calendar__c opCalendar6 = new Operational_Calendar__c(First_Day__c = operationDate.addDays(11), Frequency_code__c = 'W',
			ISS_operation__c = settlement2.id, Last_day__c = operationDate.addDays(18));
		opCalanderList.add(opCalendar6);
		Operational_Calendar__c opCalendar7 = new Operational_Calendar__c(First_Day__c = operationDate.addDays(1), Frequency_code__c = 'D',
			ISS_operation__c = settlement2.id, Last_day__c = operationDate.addDays(2));
		opCalanderList.add(opCalendar7);
		Operational_Calendar__c opCalendar8 = new Operational_Calendar__c(First_Day__c = operationDate.addDays(3), Frequency_code__c = 'D',
			ISS_operation__c = settlement2.id, Last_day__c = operationDate.addDays(4));
		opCalanderList.add(opCalendar8);
		insert opCalanderList;

		List<IATA_ISO_Country__c> ctry = new List<IATA_ISO_Country__c>();
		ctry.add(new IATA_ISO_Country__c(Name = 'USA', ISO_Code__c = 'US', AMS_Settlement_System__c = settlement.id, ANG_Enable_NewGen__c = true));
		ctry.add(new IATA_ISO_Country__c(Name = 'WW', ISO_Code__c = 'WW', AMS_Settlement_System__c = settlement2.id, ANG_Enable_NewGen__c = true));
		insert ctry;

		AMS_Country_Specific_Attribute__c config = new AMS_Country_Specific_Attribute__c (
				RecordTypeId = devRecordTypeId, IATA_ISO_Country__c = ctry[1].id,
				ANG_Minimum_RHC_Amount__c = 10,CurrencyIsoCode = 'USD'  );

		insert config;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry[0].id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',
			Location_Type__c='HE',Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent',
			Location_Class__c = 'P', Remittance_frequency__c = 'W' );
		accountList.add(a1);

		Account a2 = new Account(IATA_ISO_Country__c = ctry[1].id, RecordTypeId = accountAgencyRT, IATACode__c='1234569',
			Location_Type__c='HE',Name='Test3 Agency OK',Short_Name__c='Test3 Agency', Sector__c = 'Travel Agent 3',
			Location_Class__c = 'P', Remittance_frequency__c = 'D' );
		accountList.add(a2);

		insert accountList;

	}


	static testMethod void rhcInfoInitialization() {

		Account a = [Select id FROM Account WHERE IATACode__c='1234562' limit 1];

		System.assertEquals(0, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());

		Test.startTest();

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());
	}


	static testMethod void rhcInfoInitialization2() {

		IATA_ISO_Country__c ctry2 = [SELECT id, Name FROM IATA_ISO_Country__c WHERE Name = 'WW' limit 1];

		Id devRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');

		AMS_Country_Specific_Attribute__c config = new AMS_Country_Specific_Attribute__c( RecordTypeId = devRecordTypeId,
					 IATA_ISO_Country__c = ctry2.id, ANG_Minimum_RHC_Amount__c = 10);

		insert config;

		Account a = [Select id FROM Account WHERE IATACode__c='1234562' limit 1];

		System.assertEquals(0, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());

		Test.startTest();

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());
	}


	/**
	 * Test calculateRHCAmount method
	 */
	static testMethod void testRHCinformation_calculateRHCAmount() {

		Set<ID> accountIdSet = new Set<ID>();
		for(Account a : [Select id FROM Account])
			accountIdSet.add(a.ID);

		Test.startTest();

		ANG_RHCHelper.createRHCInfo(accountIdSet, false);

		List<ANG_RHC_Information__c> rhcinformationList =
				[SELECT id, ANG_CashCondition__c, ANG_AccountId__c,ANG_RHC_Amount_Equals_FS__c, ANG_Financial_Security__c,
					ANG_RME_Amount__c, ANG_RHC_Amount_Provisional__c, ANG_Exceeding_Financial_Security__c,ANG_RHC_Amount_Forecasted__c,
					CurrencyIsoCode, RHC_Amount_Equals_FS_Percent__c, ANG_Forecasted_RHC_Effective_date__c, ANG_Minimum_Financial_Security__c
				FROM ANG_RHC_Information__c];

		ANG_RHCHelper.calculateRHCAmount(rhcinformationList);

		Test.stopTest();

		List<ANG_RHC_Information__c> rhcUpdated = [SELECT Id, ANG_Forecasted_RHC_Effective_date__c, ANG_RHC_Amount_Forecasted__c, ANG_AccountId__r.IATACode__c
												  FROM ANG_RHC_Information__c];

		System.debug('__[ANG_RHCHelperTest - testRHCinformation_calculateRHCAmount] List<ANG_RHC_Information__c>:' +
			[SELECT Id, ANG_Forecasted_RHC_Effective_date__c, ANG_RHC_Amount_Forecasted__c FROM ANG_RHC_Information__c]);

		for(ANG_RHC_Information__c rhc : rhcUpdated){
			if(rhc.ANG_AccountId__r.IATACode__c == '1234562')
				System.assertEquals(Date.today().addDays(5), rhc.ANG_Forecasted_RHC_Effective_date__c);
			else if(rhc.ANG_AccountId__r.IATACode__c == '1234569')
				System.assertEquals(Date.today().addDays(1), rhc.ANG_Forecasted_RHC_Effective_date__c);

		}


	}
}
