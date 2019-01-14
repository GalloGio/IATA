@isTest
private class ANG_RiskEventGeneratorTest {

	@testSetup static void createData() {
		Id accRecType = AMS_Utils.RECTYPE_IATAAGENCY;
		Id caseRecType = AMS_Utils.RECTYPE_SIDRA;

		Account a = new Account(Name = 'Test', RecordTypeId = accRecType);
		insert a;

		Case c = new Case(AccountId = a.Id, Subject = 'Test', RecordTypeId = caseRecType, Update_AIMS_IRR__c = System.now(),Late_Payment_Date__c=Date.today());

		ANG_RiskEventGenerator.skip = true;
		insert c;
		ANG_RiskEventGenerator.skip = false;

		ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Test', ANG_Risk_Id__c = '99', ANG_Expiration__c = 12);
		insert riskType;

		ANG_Risk_Event_Configuration__c configActive = new ANG_Risk_Event_Configuration__c();
		configActive.ANG_Risk_Event_Type__c = riskType.Id;
		configActive.ANG_Risk_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE;
		configActive.ANG_isUpdateOnly__c = false;
		configActive.ANG_Object_Type__c = 'Case';
		configActive.ANG_Object_Record_Type__c = 'SIDRA';
		configActive.ANG_TargetAgency__c = 'Related Account';
		configActive.ANG_Field01__c = 'Update_AIMS_IRR__c';
		configActive.ANG_Field01_Conditions__c = 'Less than today';
		configActive.ANG_Field02__c = 'Account.Name';
		configActive.ANG_Field02_Conditions__c = 'Not blank';
		configActive.ANG_Field03__c = 'Subject';
		configActive.ANG_Field03_Conditions__c = 'Equal to';
		configActive.ANG_Field03_Values__c = 'Test';
		configActive.ANG_Field04__c = 'Subject';
		configActive.ANG_Field04_Conditions__c = 'Not equal to';
		configActive.ANG_Field04_Values__c = 'Something else';

		ANG_Risk_Event_Configuration__c configMultiple = new ANG_Risk_Event_Configuration__c();
		configMultiple.ANG_Risk_Event_Type__c = riskType.Id;
		configMultiple.ANG_Risk_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE;
		configMultiple.ANG_isUpdateOnly__c = false;
		configMultiple.ANG_Object_Type__c = 'AMS_OSCAR__c';
		configMultiple.ANG_Object_Record_Type__c = 'CHANGE';
		configMultiple.ANG_TargetAgency__c = 'Selected Accounts';
		configMultiple.ANG_Field01__c = 'Type_of_Change__c';
		configMultiple.ANG_Field01_Conditions__c = 'Includes';
		configMultiple.ANG_Field01_Values__c = 'VMFR';
		configMultiple.ANG_Field02__c = 'Type_of_Change__c';
		configMultiple.ANG_Field02_Conditions__c = 'Does not Include';
		configMultiple.ANG_Field02_Values__c = 'Location Type';


		ANG_Risk_Event_Configuration__c configInactive = new ANG_Risk_Event_Configuration__c();
		configInactive.ANG_Risk_Event_Type__c = riskType.Id;
		configInactive.ANG_Risk_Event_Status__c = ANG_Risk_Helper.STATUS_REVOKED;
		configInactive.ANG_isUpdateOnly__c = true;
		configInactive.ANG_Object_Type__c =  'Case';
		configInactive.ANG_Object_Record_Type__c = 'SIDRA';
		configInactive.ANG_TargetAgency__c = 'Related Account';
		configInactive.ANG_Field01__c = 'Update_AIMS_IRR__c';
		configInactive.ANG_Field01_Conditions__c = 'Greater than today';
		configInactive.ANG_Field02__c = 'Account.Name';
		configInactive.ANG_Field02_Conditions__c = 'Not blank';
		insert new List<ANG_Risk_Event_Configuration__c>{configActive, configInactive, configMultiple};

	}
	
	static testMethod void test_generation_Match() {
	/*
		Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c, Subject FROM Case LIMIT 1];
		c.Update_AIMS_IRR__c = System.now().addDays(-1);
		c.IRR_Approval_Rejection__c = ANG_Risk_Helper.CASE_IRR_APPROVED; //pass validation

		ANG_RiskEventGenerator.skip = true;
		update c;
		ANG_RiskEventGenerator.skip = false;

		Case oldCase = c.clone(true, true);
		oldCase.Update_AIMS_IRR__c = null;
		oldCase.AccountId = null;

		List<Case> caseList = new List<Case>{c};
		Map<Id, Case> caseMap = new Map<Id, Case>();
		caseMap.put(c.Id, oldCase);

		
		Test.startTest();

		new ANG_RiskEventGenerator(caseList, caseMap).generate();

		System.assertEquals([SELECT Id, ANG_Risk_Type__c, ANG_Event_Status__c FROM ANG_Agency_Risk_Event__c][0].ANG_Event_Status__c, ANG_Risk_Helper.STATUS_ACTIVE);

		ANG_RiskEventGenerator.skip = false; //allow recurrence
		//second time will just trigger duplicate error validation
		new ANG_RiskEventGenerator(caseList, caseMap).generate();

		//Updating case to match second config
		c.Update_AIMS_IRR__c = System.now().addDays(1);

		ANG_RiskEventGenerator.skip = true;
		update c;
		ANG_RiskEventGenerator.skip = false;

		//testing revoking
		new ANG_RiskEventGenerator(caseList, caseMap).generate();

		Test.stopTest();

		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Risk_Type__c, ANG_Event_Status__c FROM ANG_Agency_Risk_Event__c];
		System.assertEquals(1, riskEvents.size());
		System.assertEquals(riskEvents[0].ANG_Event_Status__c, ANG_Risk_Helper.STATUS_REVOKED);
		System.assertEquals(riskEvents[0].ANG_Risk_Type__c, [SELECT Id FROM ANG_Risk_Event_Type__c LIMIT 1].Id);
	*/
	}
	
	static testMethod void test_generation_noMatch() {
	/*
		Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c, Subject FROM Case LIMIT 1];

		Case oldCase = c.clone(true, true);
		oldCase.Update_AIMS_IRR__c = null;

		List<Case> caseList = new List<Case>{c};
		Map<Id, Case> caseMap = new Map<Id, Case>();
		caseMap.put(c.Id, oldCase);


		Test.startTest();

		new ANG_RiskEventGenerator(caseList, caseMap).generate();

		Test.stopTest();

		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id FROM ANG_Agency_Risk_Event__c];
		System.assertEquals(0, riskEvents.size());
		*/
	}
	/*
	static testMethod void test_generation_noChange() {
	
		Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c, Subject FROM Case LIMIT 1];
		Case oldCase = c.clone(true, true);

		List<Case> caseList = new List<Case>{c};
		Map<Id, Case> caseMap = new Map<Id, Case>();
		caseMap.put(c.Id, oldCase);


		Test.startTest();

		new ANG_RiskEventGenerator(caseList, caseMap).generate();

		Test.stopTest();

		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id FROM ANG_Agency_Risk_Event__c];
		System.assertEquals(0, riskEvents.size());
	}
	
	static testMethod void test_generation_configError() {
		Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c, Subject FROM Case LIMIT 1];
		Case oldCase = c.clone(true, true);

		List<Case> caseList = new List<Case>{c};
		Map<Id, Case> caseMap = new Map<Id, Case>();
		caseMap.put(c.Id, oldCase);

		ANG_Risk_Event_Configuration__c config = [SELECT Id FROM ANG_Risk_Event_Configuration__c WHERE ANG_isUpdateOnly__c = false AND ANG_Object_Type__c = 'Case'];
		config.ANG_Field03__c = 'TestField';
		config.ANG_Field03_Conditions__c = 'Not blank';
		update config;

		Test.startTest();

		try{
			new ANG_RiskEventGenerator(caseList, caseMap).generate();
		}catch(Exception e){
			System.assertEquals('ANG_RiskEventGenerator.RiskEventGeneratorException',  e.getTypeName());
			System.assert(e.getMessage().contains('Some of the fields mentioned were not found'));
		}
		

		Test.stopTest();

		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id FROM ANG_Agency_Risk_Event__c];
		System.assertEquals(0, riskEvents.size());
	}

	static testMethod void test_multipleGeneration() {
		
		Account a = [SELECT Id, RecordTypeId FROM Account];
		Id accRecType = a.RecordTypeId;

		Account a1 = new Account(Name = 'Test1', RecordTypeId = accRecType, ParentId = a.Id);
		Account a2 = new Account(Name = 'Test2', RecordTypeId = accRecType, ParentId = a.Id);
		insert new List<Account>{a1, a2};

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a.Id);
		insert oscar;

		AMS_Process_Detail__c p1 = new AMS_Process_Detail__c(Account__c = a1.Id, OSCAR__c = oscar.Id);
		AMS_Process_Detail__c p2 = new AMS_Process_Detail__c(Account__c = a2.Id, OSCAR__c = oscar.Id);
		insert new List<AMS_Process_Detail__c>{p1, p2};

		Test.startTest();

		insert new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = a.Id
			, ANG_Risk_Type__c = [SELECT Id FROM ANG_Risk_Event_Type__c].Id
			, ANG_Issued_date__c = System.today()
			, ANG_OscarId__c = oscar.Id
			, ANG_Risk_Configuration__c = [SELECT Id FROM ANG_Risk_Event_Configuration__c WHERE ANG_isUpdateOnly__c = false AND ANG_Object_Type__c = 'AMS_OSCAR__c'].Id
		);

		Test.stopTest();
		System.assertEquals(3, [SELECT Id FROM ANG_Agency_Risk_Event__c].size());

	}

	static testMethod void test_loading() {
		Account a = [SELECT Id FROM Account];

		ANG_Agency_Risk_Event__c re = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = a.Id
			, ANG_Risk_Type__c = [SELECT Id FROM ANG_Risk_Event_Type__c].Id
			, ANG_Issued_date__c = Date.newInstance(2016, 10, 15)
			, ANG_Expiration_Date__c =system.today()
		);


		Test.startTest();
		insert re;
		Test.stopTest();

		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Expiration_Date__c, ANG_HE_AccountId__c FROM ANG_Agency_Risk_Event__c];
		System.assertEquals(Date.newInstance(2017, 10, 15), riskEvents[0].ANG_Expiration_Date__c);
		System.assertEquals(a.Id, riskEvents[0].ANG_HE_AccountId__c);
	}
	*/
	
}