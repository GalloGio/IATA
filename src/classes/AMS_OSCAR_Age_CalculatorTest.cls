@isTest
private class AMS_OSCAR_Age_CalculatorTest {

	@testSetup static void setup() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name= 'Portugal',
			ISO_Code__c= 'PT',
			Region__c= 'Europe',
			ISO_Code_Numeric__c= 11
		);
		insert country;
		Account acc = new Account(
			Name= 'Test Ag',
			RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
			IATA_ISO_Country__c= country.Id
		);
		insert acc;
		Case cse = new Case(
			AccountId= acc.Id,
			Reason1__c= 'New HO',
			CaseArea__c= 'Accreditation Process',
			Status= 'Open',
			RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication')
		);
		insert cse;

		AMS_Pax_Accreditation_Form__c stgArea = new AMS_Pax_Accreditation_Form__c(
			SAAM_Case__c= cse.Id
		);
		insert stgArea;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Name= '11111',
			RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c','NEW'),
			AMS_Online_Accreditation__c= stgArea.Id,
			Account__c= acc.Id,
			Dossier_Reception_Date__c= Date.today()
		);
		insert oscar;

		cse.OSCAR__c = oscar.Id;
		update cse;
	}

	@isTest static void closeCase() {
		Test.startTest();
		AMS_OSCAR__c oscar = [SELECT Id, Status__c FROM AMS_OSCAR__c LIMIT 1];
		oscar.Status__c = 'Closed';
		update oscar;
		Test.stopTest();
	}

	@isTest static void runBatch() {
		Test.startTest();
		AMS_OSCAR_Age_Calculator b = new AMS_OSCAR_Age_Calculator('Europe', 5);
		Database.executeBatch(b);
		Test.stopTest();
	}

	@isTest static void scheduleBatch() {
		Test.startTest();
		AMS_OSCAR_Age_Calculator.start('0 0 22 * * ? *', 'Europe', 5);
		AMS_OSCAR_Age_Calculator.stop('Europe');
		Test.stopTest();
	}

}
