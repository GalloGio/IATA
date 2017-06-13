@isTest
private class ANG_RiskEventGeneratorTest {

    @testSetup static void createData() {
        Id recType = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');

        Account a = new Account(
            Name = 'Test',
            recordtypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') 
        );
        insert a;

        Case c = new Case(AccountId = a.Id, Subject = 'Test', RecordTypeId = recType, Update_AIMS_IRR__c = System.now());

        ANG_RiskEventGenerator.skip = true;
        insert c;
        ANG_RiskEventGenerator.skip = false;

		ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Test', ANG_Risk_Id__c = '99', ANG_Expiration__c = 12, ANG_IsMultiple__c = true);
        insert riskType;

        ANG_Risk_Event_Configuration__c config = new ANG_Risk_Event_Configuration__c();
        config.ANG_Risk_Event_Type__c = riskType.Id;
        config.ANG_Object_Type__c = 'Case';
        config.ANG_Object_Record_Type__c = 'SIDRA';
        config.ANG_Field01__c = 'Update_AIMS_IRR__c';
        config.ANG_Field01_Conditions__c = 'Less than today';
        config.ANG_Field02__c = 'Account.Name';
        config.ANG_Field02_Conditions__c = 'Not blank';
        insert config;

    }
    
    static testMethod void test_generation_Match() {
        Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c FROM Case LIMIT 1];
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

        //second time will just upsert
        new ANG_RiskEventGenerator(caseList, caseMap).generate();

        Test.stopTest();

        List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Risk_Type__c FROM ANG_Agency_Risk_Event__c];
        System.assertEquals(1, riskEvents.size());
        System.assertEquals(riskEvents[0].ANG_Risk_Type__c, [SELECT Id FROM ANG_Risk_Event_Type__c LIMIT 1].Id);
    }
    
    static testMethod void test_generation_noMatch() {
        Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c FROM Case LIMIT 1];

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
        Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c FROM Case LIMIT 1];
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
        Case c = [SELECT Id, AccountId, RecordTypeId, Update_AIMS_IRR__c FROM Case LIMIT 1];
        Case oldCase = c.clone(true, true);

        List<Case> caseList = new List<Case>{c};
        Map<Id, Case> caseMap = new Map<Id, Case>();
        caseMap.put(c.Id, oldCase);

        ANG_Risk_Event_Configuration__c config = [SELECT Id FROM ANG_Risk_Event_Configuration__c];
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
        );

        Test.startTest();

        new ANG_RiskEventGenerator(new List<ANG_Agency_Risk_Event__c>{re}).loadInitialInformations();

        Test.stopTest();

        List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Expiration_Date__c, ANG_HE_AccountId__c FROM ANG_Agency_Risk_Event__c];
        System.assertEquals(Date.newInstance(2017, 10, 15), riskEvents[0].ANG_Expiration_Date__c);
        System.assertEquals(a.Id, riskEvents[0].ANG_HE_AccountId__c);
    }
    
}