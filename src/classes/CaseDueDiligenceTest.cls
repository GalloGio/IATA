@isTest
private class CaseDueDiligenceTest {

    public static final Id RT_ICCS_ASP_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case','IDFS_Airline_Participation_Process');
    public static final Id RT_CODING_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case','Airline_Coding_Application');


    static testMethod void testCaseBeforeUpdate() {
        insert new Case_Reason_Service__c(Name = 'SIS Client', Service__c = 'SIS Client', Provider_Required__c = false);
        Account account = new Account(
            RecordtypeId = RecordTypeSingleton.getInstance().getRecordType('Account','IATA_Airline').Id,
            Name='testaccount',
            Date_of_last_clearance__c = Date.today().addYears(-1)
        );
        insert account;
        
        Contact contact = new Contact(FirstName = 'testContact', LastName = 'testContact');
        insert contact;
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'Airline Joining',
            Reason1__c = 'SIS Client',
            Type = 'TOU',
            ContactId = contact.Id
        );
        insert cse;
        
        Test.startTest();
        try {
            cse.Status = 'Closed';
            update cse;
            System.assert(false,'DueDiligenceException expected');
        } catch(Exception e) {
            System.assert(e.getMessage().contains('Last clearance date is approaching'), 'Wrong Exception: ' + e.getTypeName() + ' -> ' + e.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void testvalidateSIS_TOU() {
        insert new Case_Reason_Service__c(Name = 'SIS Client', Service__c = 'SIS Client', Provider_Required__c = false);
        Account account = new Account(
            Name='testaccount',
            Date_of_last_clearance__c = Date.today()
        );
        insert account;
        
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'Airline Joining',
            Reason1__c = 'SIS Client',
            Type = 'TOU'
        );
        insert cse;
        
        Test.startTest();
        assertException(cse,account);
        Test.stopTest();
    }

    static testMethod void testvalidateSIS_ISPA() {
        insert new Case_Reason_Service__c(Name = 'SIS Client', Service__c = 'SIS Client', Provider_Required__c = false);
        Account account = new Account(
            Name='testaccount',
            Date_of_last_clearance__c = Date.today()
        );
        insert account;
        
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'Airline Joining',
            Reason1__c = 'SIS Client',
            Type = 'ISPA'
        );
        insert cse;
        
        Test.startTest();
        assertException(cse,account);
        account.Date_of_last_clearance__c = Date.today().addMonths(-11);
        assertException(cse,account);
        account.Clearance_level__c = '1';
        assertException(cse,account);
        Test.stopTest();
    }

    static testMethod void testvalidateSIS_ISUA() {
        insert new Case_Reason_Service__c(Name = 'SIS Client', Service__c = 'SIS Client', Provider_Required__c = false);
        Account account = new Account(
            Name='testaccount',
            Date_of_last_clearance__c = Date.today()
        );
        insert account;
        
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'Airline Joining',
            Reason1__c = 'SIS Client',
            Type = 'ISUA'
        );
        insert cse;
        
        Test.startTest();
        assertException(cse,account);
        Test.stopTest();
    }

    static testMethod void testvalidateMITA() {
        insert new Case_Reason_Service__c(Name = 'MITA', Service__c = 'MITA', Provider_Required__c = false);
        Account account = new Account(
            Name='testaccount',
            Date_of_last_clearance__c = Date.today()
        );
        insert account;
        
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'Airline Joining',
            Reason1__c = 'MITA'
        );
        insert cse;
        
        Test.startTest();
        assertException(cse,account);
        Test.stopTest();
    }

    static testMethod void testvalidateBSPCASS() {
        insert new Case_Reason_Service__c(Name = 'BSP Direct - Member', Service__c = 'BSP Direct - Member', Provider_Required__c = false);
        Account account = new Account(
            Name='testaccount',
            Date_of_last_clearance__c = Date.today()
        );
        insert account;
        
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'Airline Joining',
            Reason1__c = 'BSP Direct - Member',
            Type = 'TOU'
        );
        insert cse;
        
        Test.startTest();
        assertException(cse,account);
        Test.stopTest();
    }

    static testMethod void testvalidateICH() {
        Account account = new Account(
            Name='testaccount',
            Date_of_last_clearance__c = Date.today()
        );
        insert account;
        
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'ICH',
            Type = 'ICH Membership'
        );
        insert cse;
        
        Test.startTest();
        assertException(cse,account);
        Test.stopTest();
    }

    static testMethod void testvalidateCoding() {
        insert new Case_Reason_Service__c(Name = 'Designator Form', Service__c = 'Designator Form', Provider_Required__c = false);
        Account account = new Account(
            Name='testaccount',
            Date_of_last_clearance__c = Date.today()
        );
        insert account;
        
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_CODING_ID,
            CaseArea__c = 'Airline Coding Application',
            Reason1__c = 'Designator Form'
        );
        insert cse;
        
        Test.startTest();
        assertException(cse,account);
        Test.stopTest();
    }

    static testMethod void testvalidateWithTopParent() {
        insert new Case_Reason_Service__c(Name = 'SIS Client', Service__c = 'SIS Client', Provider_Required__c = false);
        Account topAccount = new Account(
            RecordtypeId = RecordTypeSingleton.getInstance().getRecordType('Account','IATA_Airline').Id,
            Name='TopAccount',
            Date_of_last_clearance__c = Date.today(),
            Clearance_level__c = '4'
        );
        insert topAccount;
        Account account = new Account(
            RecordtypeId = RecordTypeSingleton.getInstance().getRecordType('Account','IATA_Airline').Id,
            ParentId = topAccount.Id,
            Name='testaccount',
            Date_of_last_clearance__c = Date.today().addYears(-1)
        );
        insert account;
        
        Contact contact = new Contact(FirstName = 'testContact', LastName = 'testContact');
        insert contact;
        Case cse = new Case(
            AccountId = account.Id,
            RecordTypeId = RT_ICCS_ASP_ID,
            CaseArea__c = 'Airline Joining',
            Reason1__c = 'SIS Client',
            Type = 'TOU',
            ContactId = contact.Id
        );
        insert cse;

        Test.startTest();
        try {
            cse.Status = 'Closed';
            update cse;
        } catch(Exception e) {
            System.assert(false, e.getMessage());
        }
        CaseDueDiligence.isValid(cse,account);
        Test.stopTest();
    }

    private static void assertException(Case cse, Account account) {
        try {
            CaseDueDiligence.validate(cse,account);
            System.assert(false,'DueDiligenceException expected');
        } catch(CaseDueDiligence.DueDiligenceException e) {
            System.assert(true);
        } catch(Exception e) {
            System.assert(false,'Wrong exception');
        }
    }
}