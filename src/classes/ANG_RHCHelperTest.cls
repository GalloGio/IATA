@isTest
private class ANG_RHCHelperTest {
	
	static testMethod void rhcInfoInitialization() {

		Id devRecordTypeId = Schema.SObjectType.AMS_Country_Specific_Attribute__c.getRecordTypeInfosByName().get('Minimum RHC Amount').getRecordTypeId();

		List<IATA_ISO_Country__c> ctry = new List<IATA_ISO_Country__c>();

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c (
				CurrencyIsoCode = 'USD'
			);

		insert settlement;

		ctry.add(new IATA_ISO_Country__c(Name = 'USA', ISO_Code__c = 'US', AMS_Settlement_System__c = settlement.id));
		ctry.add(new IATA_ISO_Country__c(Name = 'WW', ISO_Code__c = 'WW'));		
		insert ctry;

		AMS_Country_Specific_Attribute__c config = new AMS_Country_Specific_Attribute__c (
                RecordTypeId = devRecordTypeId,
                IATA_ISO_Country__c = ctry[0].id,
                ANG_Minimum_RHC_Amount__c = 10
            );

        insert config;

		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account a = new Account(IATA_ISO_Country__c = ctry[0].id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');

		insert a;

		System.assertEquals(0, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());

		Test.startTest();

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());
	}

	static testMethod void rhcInfoInitialization2() {

		Id devRecordTypeId = Schema.SObjectType.AMS_Country_Specific_Attribute__c.getRecordTypeInfosByName().get('Minimum RHC Amount').getRecordTypeId();

		List<IATA_ISO_Country__c> ctry = new List<IATA_ISO_Country__c>();

		AMS_Settlement_System__c settlement = new AMS_Settlement_System__c (
				CurrencyIsoCode = 'USD'
			);

		insert settlement;

		ctry.add(new IATA_ISO_Country__c(Name = 'USA', ISO_Code__c = 'US', AMS_Settlement_System__c = settlement.id));
		ctry.add(new IATA_ISO_Country__c(Name = 'WW', ISO_Code__c = 'WW'));		
		insert ctry;

		AMS_Country_Specific_Attribute__c config = new AMS_Country_Specific_Attribute__c (
                RecordTypeId = devRecordTypeId,
                IATA_ISO_Country__c = ctry[1].id,
                ANG_Minimum_RHC_Amount__c = 10
            );

        insert config;

		Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Account a = new Account(IATA_ISO_Country__c = ctry[0].id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');

		insert a;

		System.assertEquals(0, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());

		Test.startTest();

		ANG_RHCHelper.createRHCInfo(new Set<Id>{a.Id}, false);

		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM ANG_RHC_Information__c WHERE ANG_AccountId__c = :a.Id].size());
	}

	
}