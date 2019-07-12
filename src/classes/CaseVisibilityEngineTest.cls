@isTest 
private class CaseVisibilityEngineTest {

    private static Map<String,SObject> setupData(String region) {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name= 'TestCountry',
            ISO_Code__c= 'TC',
            ISO_Code_Numeric__c= 11,
            Region__c= region
        );

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

        Group g1 = [SELECT Id FROM Group WHERE Name LIKE '%Recycle%' LIMIT 1];

        UtilityCS__c recycleBinCS = new UtilityCS__c(Name= 'CaseRecycleBinIds', Value__c= g1.Id);
        insert recycleBinCS;

        return new Map<String,SObject> {
            'Account' => acc,
            'Contact' => con,
            'Group' => g1
        };
    }

    @isTest static void testComparisonMethods() {
        Test.startTest();
        CaseVisibilityEngine.compareDates(Date.today(), Date.today(), '<');
        CaseVisibilityEngine.compareDates(Date.today(), Date.today(), '>');
        CaseVisibilityEngine.compareDates(Date.today(), Date.today(), '<=');
        CaseVisibilityEngine.compareDates(Date.today(), Date.today(), '>=');

        CaseVisibilityEngine.compareDatetimes(Datetime.now(), Datetime.now(), '<');
        CaseVisibilityEngine.compareDatetimes(Datetime.now(), Datetime.now(), '>');
        CaseVisibilityEngine.compareDatetimes(Datetime.now(), Datetime.now(), '<=');
        CaseVisibilityEngine.compareDatetimes(Datetime.now(), Datetime.now(), '>=');

        CaseVisibilityEngine.compareIntegers(1, 1, '<');
        CaseVisibilityEngine.compareIntegers(1, 1, '>');
        CaseVisibilityEngine.compareIntegers(1, 1, '<=');
        CaseVisibilityEngine.compareIntegers(1, 1, '>=');
        Test.stopTest();
    }

    @isTest static void testRecycleBinOwner() {
        Map<String,SObject> mapData = setupData('Europe');
        Account acc = (Account) mapData.get('Account');
        Contact con = (Contact) mapData.get('Contact');
        Group g1 = (Group) mapData.get('Group');

        Test.startTest();
        Case cse = new Case(
            AccountId= acc.Id,
            ContactId= con.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope'),
            Subject= 'Test',
            Type= 'Request',
            Status= 'Open',
            Origin= 'Phone'
        );
        insert cse;

        cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
        System.assertEquals(true, cse.Visible_on_ISS_Portal__c);

        cse.OwnerId = g1.Id;
        update cse;

        cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
        System.assertEquals(false, cse.Visible_on_ISS_Portal__c);
        Test.stopTest();
    }

    @isTest static void testCasesGlobal() {
        Map<String,SObject> mapData = setupData('Europe');
        Account acc = (Account) mapData.get('Account');
        Contact con = (Contact) mapData.get('Contact');

        Test.startTest();
        Case cse = new Case(
            AccountId= acc.Id,
            ContactId= con.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_Global'),
            Subject= 'Test',
            Type= 'Request',
            Status= 'Open',
            Origin= 'Phone'
        );
        insert cse;

        cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
        System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
        Test.stopTest();
    }

    @isTest static void testCasesSAAM() {
        Map<String,SObject> mapData = setupData('Europe');
        Account acc = (Account) mapData.get('Account');
        Contact con = (Contact) mapData.get('Contact');

        Test.startTest();
        Case cse = new Case(
            AccountId= acc.Id,
            ContactId= con.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE'),
            Subject= 'Test',
            Type= 'Request',
            Status= 'Open',
            Origin= 'Email',
            CaseArea__c= 'Accreditation Process',
            Reason1__c= 'New HO'
        );
        insert cse;

        cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
        System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
        Test.stopTest();
    }

    @isTest static void testCasesSIDRA() {
        Map<String,SObject> mapData = setupData('Europe');
        Account acc = (Account) mapData.get('Account');
        Contact con = (Contact) mapData.get('Contact');

        Test.startTest();
        Case cse = new Case(
            AccountId= acc.Id,
            ContactId= con.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA'),
            Subject= 'Test',
            Type= 'Request',
            Status= 'Open',
            Origin= 'Email',
            CaseArea__c= 'Remittance & Settlement',
            IATAcode__c= '12345678',
            BSP_CASS__c= 'BSP'
        );
        insert cse;

        cse = [SELECT Visible_on_ISS_Portal__c FROM Case WHERE Id = :cse.Id];
        System.assertEquals(true, cse.Visible_on_ISS_Portal__c);
        Test.stopTest();
    }


}
