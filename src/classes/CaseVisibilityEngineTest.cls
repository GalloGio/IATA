@isTest
private class CaseVisibilityEngineTest {
	
	@testSetup
	static void setup() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'TestCountry', ISO_Code__c = 'TC', ISO_Code_Numeric__c = 11,
			Region__c = 'Europe');
		
		Account acc = new Account(Name = 'Test Ag', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account',
			'IATA_Agency'), IATA_ISO_Country__c = country.Id, Location_Type__c = 'HO', Location_Class__c = 'P', Sector__c = 'Travel Agent',
			Category__c = 'IATA Passenger Sales Agent', IATACode__c = '145362');
		insert acc;
		
		Contact con = new Contact(FirstName = 'Test', Lastname = 'Contact', Email = 'test.contact@yopmail.com', AccountId = acc.Id);
		insert con;
		
		Group g1 = [SELECT Id FROM Group WHERE Name LIKE '%Recycle%' LIMIT 1];
		
		UtilityCS__c recycleBinCS = new UtilityCS__c(Name = 'CaseRecycleBinIds', Value__c = g1.Id);
		insert recycleBinCS;
	}
	
	@isTest
	static void testComparisonMethods() {
		Test.startTest();
		System.assertEquals(false, CaseVisibilityEngine.compareDates(Date.today(), Date.today(), '<'));
		System.assertEquals(false, CaseVisibilityEngine.compareDates(Date.today(), Date.today(), '>'));
		System.assertEquals(true, CaseVisibilityEngine.compareDates(Date.today(), Date.today(), '<='));
		System.assertEquals(true, CaseVisibilityEngine.compareDates(Date.today(), Date.today(), '>='));
		
		System.assertEquals(false, CaseVisibilityEngine.compareDatetimes(Datetime.now(), Datetime.now(), '<'));
		System.assertEquals(false, CaseVisibilityEngine.compareDatetimes(Datetime.now(), Datetime.now(), '>'));
		System.assertEquals(true, CaseVisibilityEngine.compareDatetimes(Datetime.now(), Datetime.now(), '<='));
		System.assertEquals(true, CaseVisibilityEngine.compareDatetimes(Datetime.now(), Datetime.now(), '>='));
		
		System.assertEquals(false, CaseVisibilityEngine.compareIntegers(1, 1, '<'));
		System.assertEquals(false, CaseVisibilityEngine.compareIntegers(1, 1, '>'));
		System.assertEquals(true, CaseVisibilityEngine.compareIntegers(1, 1, '<='));
		System.assertEquals(true, CaseVisibilityEngine.compareIntegers(1, 1, '>='));
		Test.stopTest();
	}
	
	@isTest
	static void testRecycleBinOwner() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		Id recycleBinId = (Id) UtilityCS__c.getValues('CaseRecycleBinIds').Value__c;
		
		Test.startTest();
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'CasesEurope'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Phone');
		insert cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		
		cse.OwnerId = recycleBinId;
		update cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(false, cse.Visible_on_ISS_Portal__c);
		Test.stopTest();
	}
	
	@isTest
	static void testCasesGlobalPositive() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		
		Test.startTest();
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'Cases_Global'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Phone',
				Phone_Redirected_to_Web__c = false);
		insert cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		Test.stopTest();
	}
	
	@isTest
	static void testCasesGlobalNegative() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		
		Test.startTest();
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'Cases_Global'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Phone',
				Phone_Redirected_to_Web__c = true);
		insert cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(false, cse.Visible_on_ISS_Portal__c);
		Test.stopTest();
	}
	
	@isTest
	static void testChangeCaseRecordTypesToBeInvisible() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		
		Test.startTest();
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'Cases_Global'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Voicemail',
				Phone_Redirected_to_Web__c = false);
		insert cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c, RecordTypeId FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		
		cse.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
		update cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c, RecordTypeId FROM Case WHERE Id = :cse.Id];
		System.assertEquals(false, cse.Visible_on_ISS_Portal__c);
		
		Test.stopTest();
	}
	
	@isTest
	static void testChangeCaseRecordTypesToBeVisible() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		
		Test.startTest();
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'CasesEurope'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Voicemail',
				Phone_Redirected_to_Web__c = false);
		insert cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c, RecordTypeId FROM Case WHERE Id = :cse.Id];
		System.assertEquals(false, cse.Visible_on_ISS_Portal__c);
		
		cse.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_Global');
		update cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c, RecordTypeId FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		
		Test.stopTest();
	}
	
	@isTest
	static void testAffectedFields() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		
		Test.startTest();
		
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'Cases_Global'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Phone',
				Phone_Redirected_to_Web__c = false);
		insert cse;
		
		// on insert should be visbile
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		
		// removing visibility manually
		cse.Visible_on_ISS_Portal__c = false;
		update cse;
		cse = [SELECT Visible_on_ISS_Portal__c, Subject FROM Case WHERE Id = :cse.Id];
		System.assertEquals(false, cse.Visible_on_ISS_Portal__c);
		
		// changing fields not used in the rule MUST NOT affect visbility
		cse.Subject = 'Testing Affected rows';
		update cse;
		cse = [SELECT Visible_on_ISS_Portal__c, Origin FROM Case WHERE Id = :cse.Id];
		System.assertEquals(false, cse.Visible_on_ISS_Portal__c);
		
		// changing fields used in the rule MUST affect visibility
		cse.Origin = 'Voicemail';
		update cse;
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		
		Test.stopTest();
		
	}
	
	@isTest
	static void testCasesSAAM() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		
		Test.startTest();
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'ProcessEuropeSCE'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Email',
				CaseArea__c = 'Accreditation Process', Reason1__c = 'New HO');
		insert cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		Test.stopTest();
	}
	
	@isTest
	static void testCasesSIDRA() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		
		Test.startTest();
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'SIDRA'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Email', CaseArea__c = 'Remittance & Settlement',
				IATAcode__c = '12345678', BSP_CASS__c = 'BSP');
		insert cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		Test.stopTest();
	}
	
	@isTest
	static void testCasesIFG() {
		Account acc = [SELECT Id,
						   (SELECT Id FROM Contacts)
					   FROM Account];
		
		Test.startTest();
		Case cse = new Case(AccountId = acc.Id, ContactId = acc.Contacts[0].Id, RecordTypeId = RecordTypeSingleton.getInstance()
			.getRecordTypeId('Case', 'Cases_IFG'), Subject = 'Test', Type = 'Request', Status = 'Open', Origin = 'Email', CaseArea__c = 'Remittance & Settlement',
				IATAcode__c = '12345678', BSP_CASS__c = 'BSP');
		insert cse;
		
		cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
		System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
		Test.stopTest();
	}
}