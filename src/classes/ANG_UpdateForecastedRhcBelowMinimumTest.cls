@isTest
private class ANG_UpdateForecastedRhcBelowMinimumTest {

	@testSetup static void setup() {
		Id devRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');

		AMS_Settlement_System__c bsp = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			CurrencyIsoCode = 'USD'
		);
		insert bsp;

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
		List<Operational_Calendar__c> opCalendarList = new List<Operational_Calendar__c>();

		Operational_Calendar__c opCalendar1 = new Operational_Calendar__c(
			First_Day__c = operationDate.addDays(5), 
			Frequency_code__c = 'W',
			ISS_operation__c = bsp.id, 
			Last_day__c = operationDate.addDays(10)
		);
		opCalendarList.add(opCalendar1);

		Operational_Calendar__c opCalendar2 = new Operational_Calendar__c(
			First_Day__c = operationDate.addDays(11), 
			Frequency_code__c = 'W',
			ISS_operation__c = bsp.id, 
			Last_day__c = operationDate.addDays(18)
		);
		opCalendarList.add(opCalendar2);

		Operational_Calendar__c opCalendar3 = new Operational_Calendar__c(
			First_Day__c = operationDate.addDays(1), 
			Frequency_code__c = 'D',
			ISS_operation__c = bsp.id, 
			Last_day__c = operationDate.addDays(2)
		);
		opCalendarList.add(opCalendar3);

		Operational_Calendar__c opCalendar4 = new Operational_Calendar__c(
			First_Day__c = operationDate.addDays(3), 
			Frequency_code__c = 'D',
			ISS_operation__c = bsp.id, 
			Last_day__c = operationDate.addDays(4)
		);
		opCalendarList.add(opCalendar4);
		
		insert opCalendarList;

		List<IATA_ISO_Country__c> ctry = new List<IATA_ISO_Country__c>();
		ctry.add(new IATA_ISO_Country__c(Name = 'Portugal', ISO_Code__c = 'PT', AMS_Settlement_System__c = bsp.id, ANG_Enable_NewGen__c = true));
		ctry.add(new IATA_ISO_Country__c(Name = 'WW', ISO_Code__c = 'WW', ANG_Enable_NewGen__c = true));
		insert ctry;

		AMS_Country_Specific_Attribute__c config = new AMS_Country_Specific_Attribute__c (
			RecordTypeId = devRecordTypeId, 
			IATA_ISO_Country__c = ctry[1].id,
			ANG_Minimum_RHC_Amount__c = 10000,
			CurrencyIsoCode = 'USD'
		);

		insert config;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		List<Account> accountList = new List<Account>();

		Account a1 = new Account(
			IATA_ISO_Country__c = ctry[0].id, 
			RecordTypeId = accountAgencyRT, 
			IATACode__c='1234562',
			Location_Type__c='HE',
			Name='Test2 Agency OK',
			Short_Name__c='Test1 Agency', 
			Sector__c = 'Travel Agent',
			Location_Class__c = 'P', 
			Remittance_frequency__c = 'W',
			Type = 'IATA Passenger Sales Agent',
			ANG_Accreditation_Model__c = 'Cash',
			Status__c = 'APPROVED'
		);
		accountList.add(a1);

		Account a2 = new Account(
			IATA_ISO_Country__c = ctry[0].id, 
			RecordTypeId = accountAgencyRT, 
			IATACode__c='1234569',
			Location_Type__c='HE',
			Name='Test3 Agency OK',
			Short_Name__c='Test3 Agency', 
			Sector__c = 'Travel Agent 3',
			Location_Class__c = 'P', 
			Remittance_frequency__c = 'D',
			Type = 'IATA Passenger Sales Agent',
			ANG_Accreditation_Model__c = 'Cash',
			Status__c = 'APPROVED'
		);
		accountList.add(a2);

		Account a3 = new Account(
			IATA_ISO_Country__c = ctry[0].id, 
			RecordTypeId = accountAgencyRT, 
			IATACode__c='9999999',
			Location_Type__c='HE',
			Name='Test3 Agency OK',
			Short_Name__c='Test3 Agency', 
			Sector__c = 'Travel Agent 3',
			Location_Class__c = 'P', 
			Remittance_frequency__c = 'D',
			Type = 'IATA Passenger Sales Agent',
			ANG_Accreditation_Model__c = 'Cash'
		);
		accountList.add(a3);

		insert accountList;

	}

	@isTest
	static void updateForecastedRhcTest(){
		Set<ID> accountIdSet = new Set<ID>();
		for(Account a : [Select id FROM Account])
			accountIdSet.add(a.ID);


		ANG_RHCHelper.createRHCInfo(accountIdSet, false);

		List<ANG_RHC_Information__c> rhcUpdated = 
			[SELECT Id, 
					ANG_Forecasted_RHC_Effective_date__c, 
					ANG_RHC_Amount_Forecasted__c, 
					ANG_AccountId__r.IATACode__c
			 FROM ANG_RHC_Information__c
			];

		for(ANG_RHC_Information__c rhc : rhcUpdated){
			rhc.ANG_RHC_Amount_Forecasted__c = 1000;
		}

		update rhcUpdated;

		Test.startTest();
		Database.executeBatch(new ANG_UpdateForecastedRhcBelowMinimumBatch(null));
		Test.stopTest();

		rhcUpdated = 
			[SELECT Id, 
					ANG_Forecasted_RHC_Effective_date__c, 
					ANG_RHC_Amount_Forecasted__c, 
					ANG_AccountId__r.IATACode__c
			 FROM ANG_RHC_Information__c
			];

		for(ANG_RHC_Information__c rhc : rhcUpdated){
			if(rhc.ANG_AccountId__r.IATACode__c == '9999999'){
				//This account should be discarded because is not in the appropriate status
				system.assertEquals(rhc.ANG_RHC_Amount_Forecasted__c, 1000);
			}else {
				system.assertEquals(rhc.ANG_RHC_Amount_Forecasted__c, 10000);
				if(rhc.ANG_AccountId__r.IATACode__c == '1234562'){
					System.assertEquals(Date.today().addDays(5), rhc.ANG_Forecasted_RHC_Effective_date__c);
				}
				else if(rhc.ANG_AccountId__r.IATACode__c == '1234569'){
					System.assertEquals(Date.today().addDays(1), rhc.ANG_Forecasted_RHC_Effective_date__c);
				}
			} 
		}
	}

}