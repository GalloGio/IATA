@isTest
private class CaseProcessTypeHelperTest {

	@testSetup static void setup() {

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name= 'Portugal',
			ISO_Code__c= 'PT',
			ISO_Code_Numeric__c= 11,
			Region__c= 'Europe'
		);
		insert country;

		Account acc = new Account(
			Name= 'Test Ag',
			RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
			IATA_ISO_Country__c= country.Id,
			Location_Type__c= 'HO',
			Location_Class__c= 'P',
			Sector__c= 'Travel Agent',
			Category__c= 'IATA Passenger Sales Agent',
			IATACode__c= '145362'
		);
		insert acc;

		Contact con = new Contact(
			FirstName= 'Test',
			Lastname= 'Contact',
			Email= 'test.contact@yopmail.com',
			AccountId= acc.Id
		);
		insert con;

		Case cse = new Case(
			RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case','OSCAR_Communication'),
			Subject= 'New HO Test',
			Status='Open',
			Region__c= 'Europe',
			BSPCountry__c = 'Spain',
			Closed_by_Role__c= 'Test Class User',
			AccountId= acc.Id,
			ContactId= con.Id,
			CaseArea__c= 'Accreditation Process',
			Reason1__c = 'New HO'
		);
		insert cse;

		AMS_Pax_Accreditation_Form__c stgArea = new AMS_Pax_Accreditation_Form__c(
			SAAM_Case__c= cse.Id
		);
		insert stgArea;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c','NEW'),
			AMS_Online_Accreditation__c= stgArea.Id,
			Account__c= acc.Id
		);
		insert oscar;

		cse.OSCAR__c = oscar.Id;
		update cse;
	}

	@isTest 
	static void testKPICalculation() {
		Test.startTest();
		AMS_OSCAR__c oscar = [SELECT Id, Accreditation_Process_Type__c, AMS_Online_Accreditation__r.SAAM_Case__c  FROM AMS_OSCAR__c LIMIT 1];
		oscar.Status__c = 'Closed';
		update oscar;

		Case cse = [SELECT Id, Reason1__c, Status FROM Case LIMIT 1];
		cse.Reason1__c = 'New HO';
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Process_Age__c, KPI_Calculation__c FROM Case LIMIT 1];
		System.assertEquals(1, cse.KPI_Calculation__c);
		oscar = [SELECT Id, Accreditation_Process_Type__c FROM AMS_OSCAR__c LIMIT 1];
		System.assertEquals('Long 40d', oscar.Accreditation_Process_Type__c);
	}

	@isTest 
	static void testKPI_FOPManagement_Passed() {
		Test.startTest();
		AMS_OSCAR__c oscar = [SELECT Id, Accreditation_Process_Type__c, AMS_Online_Accreditation__r.SAAM_Case__c  FROM AMS_OSCAR__c LIMIT 1];
		oscar.STEP40__c = 'Passed';
		oscar.Status__c = 'Closed';
		update oscar;

		Case cse = [SELECT Id, Reason1__c, Status FROM Case LIMIT 1];
		cse.Reason1__c = 'FoP Management';
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Process_Age__c, KPI_Calculation__c FROM Case LIMIT 1];
		System.assertEquals(1, cse.KPI_Calculation__c);
		oscar = [SELECT Id, Accreditation_Process_Type__c FROM AMS_OSCAR__c LIMIT 1];
		System.assertEquals('Medium 20d', oscar.Accreditation_Process_Type__c);
	}

	@isTest static void testKPI_FOPManagement_NotPassed() {
		Test.startTest();
		AMS_OSCAR__c oscar = [SELECT Id, Accreditation_Process_Type__c, AMS_Online_Accreditation__r.SAAM_Case__c  FROM AMS_OSCAR__c LIMIT 1];
		oscar.STEP40__c = 'Not Applicable';
		oscar.Status__c = 'Closed';
		update oscar;

		Case cse = [SELECT Id, Reason1__c, Status FROM Case LIMIT 1];
		cse.Reason1__c = 'FoP Management';
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Process_Age__c, KPI_Calculation__c FROM Case LIMIT 1];
		System.assertEquals(1, cse.KPI_Calculation__c);
		oscar = [SELECT Id, Accreditation_Process_Type__c FROM AMS_OSCAR__c LIMIT 1];
		System.assertEquals('Short 24h', oscar.Accreditation_Process_Type__c);
	}

}
