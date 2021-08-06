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

		Case oscarCase = new Case(
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
		Case idfsCase = new Case(
			RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case','InternalCasesEuropeSCE'),
			Subject= 'IDFS Case Test',
			Status='Open',
			Region__c= 'Europe',
			BSPCountry__c = 'Spain',
			Closed_by_Role__c= 'Test Class User',
			AccountId= acc.Id,
			ContactId= con.Id,
			CaseArea__c= 'Accreditation Process',
			Reason1__c = 'New HO'
		);
		insert new list<Case>{oscarCase,idfsCase};

		AMS_Pax_Accreditation_Form__c stgArea = new AMS_Pax_Accreditation_Form__c(
			SAAM_Case__c= oscarCase.Id
		);
		insert stgArea;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c','NEW'),
			AMS_Online_Accreditation__c= stgArea.Id,
			Account__c= acc.Id
		);
		insert oscar;

		oscarCase.OSCAR__c = oscar.Id;
		update oscarCase;
	}

	@isTest 
	static void testKPICalculation() {
		Test.startTest();
		AMS_OSCAR__c oscar = [SELECT Id, Accreditation_Process_Type__c, AMS_Online_Accreditation__r.SAAM_Case__c  FROM AMS_OSCAR__c LIMIT 1];
		oscar.Status__c = 'Closed';
		update oscar;

		Case cse = [SELECT Id, Reason1__c, Status FROM Case WHERE RecordTypeId = :RecordTypeSingleton.getInstance().getRecordTypeId('Case','OSCAR_Communication') LIMIT 1];
		cse.Reason1__c = 'New HO';
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Process_Age__c, KPI_Calculation__c FROM Case WHERE Id = :cse.Id];
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

		Case cse = [SELECT Id, Reason1__c, Status FROM Case WHERE RecordTypeId = :RecordTypeSingleton.getInstance().getRecordTypeId('Case','OSCAR_Communication') LIMIT 1];
		cse.Reason1__c = 'FoP Management';
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Process_Age__c, KPI_Calculation__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(1, cse.KPI_Calculation__c);
		oscar = [SELECT Id, Accreditation_Process_Type__c FROM AMS_OSCAR__c LIMIT 1];
		System.assertEquals('Medium 20d', oscar.Accreditation_Process_Type__c);
	}

	@isTest
	static void testKPI_FOPManagement_NotPassed() {
		Test.startTest();
		AMS_OSCAR__c oscar = [SELECT Id, Accreditation_Process_Type__c, AMS_Online_Accreditation__r.SAAM_Case__c  FROM AMS_OSCAR__c LIMIT 1];
		oscar.STEP40__c = 'Not Applicable';
		oscar.Status__c = 'Closed';
		update oscar;

		Case cse = [SELECT Id, Reason1__c, Status FROM Case WHERE RecordTypeId = :RecordTypeSingleton.getInstance().getRecordTypeId('Case','OSCAR_Communication') LIMIT 1];
		cse.Reason1__c = 'FoP Management';
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Process_Age__c, KPI_Calculation__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(1, cse.KPI_Calculation__c);
		oscar = [SELECT Id, Accreditation_Process_Type__c FROM AMS_OSCAR__c LIMIT 1];
		System.assertEquals('Short 24h', oscar.Accreditation_Process_Type__c);
	}

	/**
	 * An oscar Case without an OSCAR record is ignored from the process
	 */
	@isTest static void testKPI_OSCAR_NotProcessed() {

		Case cse = [SELECT Id, KPI_Calculation__c FROM Case LIMIT 1];
		System.assertEquals(null, cse.KPI_Calculation__c);

		Test.startTest();
		AMS_OSCAR__c oscar = [SELECT Id, Accreditation_Process_Type__c, AMS_Online_Accreditation__r.SAAM_Case__c  FROM AMS_OSCAR__c LIMIT 1];
		delete oscar;

		cse.Reason1__c = 'FoP Management';
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, KPI_Calculation__c FROM Case LIMIT 1];
		System.assertEquals(null, cse.KPI_Calculation__c);
	}

	@isTest
	static void testKPI_InternalCaseRequest_Passed() {
		Case cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c FROM Case WHERE Subject = 'IDFS Case Test' LIMIT 1];

		// create a parent Request case
		Case parent = cse.clone();
		parent.Type = 'Request';
		insert parent;

		// change time to set Case_Age_with_IATA__c = 10
		cse.Time_Unassigned__c = 10;
		cse.Time_With_Customer__c = 0;
		cse.Time_With_Support__c = 0;
		cse.ParentId = parent.Id;
		update cse;

		// test initial values
		cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c, KPI_Calculation__c FROM Case WHERE id = :cse.Id];
		System.assertEquals(10,cse.Case_Age_with_IATA__c);
		System.assertEquals(null,cse.KPI_Calculation__c);

		Test.startTest();
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c, KPI_Calculation__c FROM Case WHERE id = :cse.Id];
		System.assertEquals(0, cse.KPI_Calculation__c);
	}

	@isTest
	static void testKPI_InternalCaseRequest_KPI1_Passed() {
		Case cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c FROM Case WHERE Subject = 'IDFS Case Test' LIMIT 1];

		// create a parent Request case
		Case parent = cse.clone();
		parent.Type = 'Request';
		insert parent;

		cse.Time_Unassigned__c = 5.0;
		cse.Time_With_Customer__c = 0;
		cse.Time_With_Support__c = 0;
		cse.ParentId = parent.Id;
		update cse;

		// test initial values
		cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c, KPI_Calculation__c FROM Case WHERE id = :cse.Id];
		System.assertEquals(5.0,cse.Case_Age_with_IATA__c);
		System.assertEquals(null,cse.KPI_Calculation__c);

		Test.startTest();
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c, KPI_Calculation__c FROM Case WHERE id = :cse.Id];
		System.assertEquals(1, cse.KPI_Calculation__c);
	}

	@isTest
	static void testKPI_InternalCaseRequest_KPI0_TestDecimals() {
		Case cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c FROM Case WHERE Subject = 'IDFS Case Test' LIMIT 1];

		// create a parent Request case
		Case parent = cse.clone();
		parent.Type = 'Request';
		insert parent;

		cse.Time_Unassigned__c = 5.01;
		cse.Time_With_Customer__c = 0;
		cse.Time_With_Support__c = 0;
		cse.ParentId = parent.Id;
		update cse;

		// test initial values
		cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c, KPI_Calculation__c FROM Case WHERE id = :cse.Id];
		System.assertEquals(5.01,cse.Case_Age_with_IATA__c);
		System.assertEquals(null,cse.KPI_Calculation__c);

		Test.startTest();
		cse.Status = 'Closed';
		update cse;
		Test.stopTest();

		cse = [SELECT Id, Reason1__c, Status, Case_Age_with_IATA__c, KPI_Calculation__c FROM Case WHERE id = :cse.Id];
		System.assertEquals(0, cse.KPI_Calculation__c);
	}
}
