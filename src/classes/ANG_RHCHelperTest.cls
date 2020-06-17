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
					CurrencyIsoCode, RHC_Amount_Equals_FS_Percent__c, ANG_Minimum_Financial_Security__c
				FROM ANG_RHC_Information__c];

		ANG_RHCHelper.calculateRHCAmount(rhcinformationList);
	}
}
