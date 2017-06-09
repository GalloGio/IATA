@isTest
private class ANG_RiskEventGeneratorTest {

	@testSetup static void createData() {
        Id accRecType = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency');
		Id caseRecType = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');

		Account a = new Account(Name = 'Test', RecordTypeId = accRecType);
		insert a;

		Case c = new Case(AccountId = a.Id, Subject = 'Test', RecordTypeId = caseRecType, Update_AIMS_IRR__c = System.now());

		ANG_RiskEventGenerator.skip = true;
		insert c;
		ANG_RiskEventGenerator.skip = false;

		ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Test', ANG_Risk_Id__c = '99', ANG_Expiration__c = 12);
		insert riskType;

		ANG_Risk_Event_Configuration__c configActive = new ANG_Risk_Event_Configuration__c();
		configActive.ANG_Risk_Event_Type__c = riskType.Id;
		configActive.ANG_Risk_Event_Status__c = 'Active';
		configActive.ANG_isUpdateOnly__c = false;
		configActive.ANG_Object_Type__c = 'Case';
		configActive.ANG_Object_Record_Type__c = 'SIDRA';
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


		ANG_Risk_Event_Configuration__c configInactive = new ANG_Risk_Event_Configuration__c();
		configInactive.ANG_Risk_Event_Type__c = riskType.Id;
		configInactive.ANG_Risk_Event_Status__c = 'Inactive_Revoked';
		configInactive.ANG_isUpdateOnly__c = true;
		configInactive.ANG_Object_Type__c = 'Case';
		configInactive.ANG_Object_Record_Type__c = 'SIDRA';
		configInactive.ANG_Field01__c = 'Update_AIMS_IRR__c';
		configInactive.ANG_Field01_Conditions__c = 'Greater than today';
		configInactive.ANG_Field02__c = 'Account.Name';
		configInactive.ANG_Field02_Conditions__c = 'Not blank';
		insert new List<ANG_Risk_Event_Configuration__c>{configActive, configInactive};

	}
	
	static testMethod void test_generation_Match() {
		Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c, Subject FROM Case LIMIT 1];
		c.Update_AIMS_IRR__c = System.now().addDays(-1);
		c.IRR_Approval_Rejection__c = 'Approved'; //pass validation

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

		System.assertEquals([SELECT Id, ANG_Risk_Type__c, ANG_Event_Status__c FROM ANG_Agency_Risk_Event__c][0].ANG_Event_Status__c, 'Active');

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
		System.assertEquals(riskEvents[0].ANG_Event_Status__c, 'Inactive_Revoked');
		System.assertEquals(riskEvents[0].ANG_Risk_Type__c, [SELECT Id FROM ANG_Risk_Event_Type__c LIMIT 1].Id);
	}
	
	static testMethod void test_generation_noMatch() {
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
	}
	
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

		ANG_Risk_Event_Configuration__c config = [SELECT Id FROM ANG_Risk_Event_Configuration__c WHERE ANG_isUpdateOnly__c = false];
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

	static testMethod void test_loading() {
		Account a = [SELECT Id FROM Account];

		ANG_Agency_Risk_Event__c re = new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c = a.Id
			, ANG_Risk_Type__c = [SELECT Id FROM ANG_Risk_Event_Type__c].Id
			, ANG_Issued_date__c = Date.newInstance(2016, 10, 15)
		);

		Test.startTest();

		new ANG_RiskEventGenerator(new List<ANG_Agency_Risk_Event__c>{re}).loadInitialInformations();

		Test.stopTest();

		List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Expiration_Date__c, ANG_HE_AccountId__c FROM ANG_Agency_Risk_Event__c];
		System.assertEquals(Date.newInstance(2017, 10, 15), riskEvents[0].ANG_Expiration_Date__c);
		System.assertEquals(a.Id, riskEvents[0].ANG_HE_AccountId__c);
	}
	
}