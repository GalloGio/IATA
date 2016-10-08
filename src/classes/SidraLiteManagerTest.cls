@isTest
public class SidraLiteManagerTest {

    public static Case createIFAPPassenger() {
        return createIFAP(true);
    }

    public static Case createIFAPCargo() {
        return createIFAP(false);
    }

    private static Case createIFAP(Boolean isPassenger) {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name = 'Canada',
            ISO_Code__c = 'CA',
            AIMS_Area_Name__c = 'Canada',
            AIMS_Area_ID__c = '1'
        );
        insert country;

        Account account = new Account(
            Name = 'Test account',
            BillingCity = 'Montreal',
            BillingCountry = 'Canada',
            BillingStreet = 'some street',
            IATA_ISO_Country__c = country.Id,
            Location_Type__c = 'HO',
            IATACode__c = '1234567',
            Type = isPassenger? 'IATA Passenger Sales Agent':'IATA Cargo Agent'
        );
        insert account;

        IATA_ISO_Country__c[] associatedCountry = [Select i.Name, i.Id From IATA_ISO_Country__c i where Name = :account.BillingCountry];
        System.assert((associatedCountry != null && associatedCountry.size() > 0));

        Contact contact = new Contact(
            FirstName = 'Dummy',
            LastName = 'Contact',
            Type_of_Contact__c = 'IFAP Contact',
            AccountId = account.Id,
            Email = 'some@email.org',
            Financial_Assessment_Contact__c = true
        );
        insert contact;

        Case cse = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_IFAP,
            Subject = 'Test Case 1',
            Status = 'Agent to be Notified',
            Origin = 'Agent Financial Review Notification',
            Priority = 'Normal',
            Financial_Review_Type__c = 'New applications',
            IFAP_Financial_Year__c = String.valueOf(Date.today().year()),
            Deadline_Date__c = Date.today().addMonths(1),
            Agent_Code__c = '1234567',
            ContactId = contact.Id,
            AccountId = account.Id,
            Description = 'Test Case 1'
        );
        return cse;
    }

    private static Case createSIDRALite() {
        Case cse = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE
        );
        return cse;
    }

    @isTest
    public static void testInsertWithFALetterSent() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = false;
        ifapCase.Status = 'Financial Statements Uploaded';
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true,'Exception thrown: ' + e.getMessage());
        }
        Test.stopTest();

    }

    @isTest
    public static void testInsertWithFSLetterSent() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = false;
        ifapCase.Status = 'Financial Security Requested';
        //ifapCase.FS_Second_Deadline_Date__c = Date.today();
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        //Action
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testInsertCheckParentStatus() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Action Needed';
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFirstFSDeadlineOnly() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Second_Deadline_Date__c = Date.today();
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFSDeadlineIsEmpty() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = null;
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFSDeadlineIsFutureDate() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFirstFADeadlineOnly() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.FA_Second_Deadline_Date__c = Date.today();
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFADeadlineIsEmpty() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = null;
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFADeadlineIsFutureDate() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFSWrongBSPValue() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;
        sidraCase.BSP_CASS__c = '';

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFSWrongCASSValue() {
        Case ifapCase = createIFAPCargo();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;
        sidraCase.BSP_CASS__c = '';

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFSWrongReasonValue() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        try {
            insert sidraCase;
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testFSPassengerOK() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;
        sidraCase.BSP_CASS__c = 'BSP';
        sidraCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';

        Test.startTest();
        insert sidraCase;
        Test.stopTest();

        sidraCase = [Select Propose_Irregularity__c from Case Where id = :sidraCase.Id];
        System.assertEquals(Date.today(),sidraCase.Propose_Irregularity__c);

        ifapCase = [Select FirstFSnonComplianceDate__c, FS_Second_Deadline_Date__c from Case Where id = :ifapCase.Id];
        System.assertEquals(Date.today(),ifapCase.FirstFSnonComplianceDate__c);
        System.assertEquals(Date.today().addDays(31),ifapCase.FS_Second_Deadline_Date__c);
    }

    @isTest
    public static void testFSCargoOK() {
        Case ifapCase = createIFAPCargo();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;
        sidraCase.BSP_CASS__c = 'CASS';
        sidraCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';

        Test.startTest();
        insert sidraCase;
        Test.stopTest();

        sidraCase = [Select Propose_Irregularity__c from Case Where id = :sidraCase.Id];
        System.assertEquals(Date.today(),sidraCase.Propose_Irregularity__c);

        ifapCase = [Select FirstFSnonComplianceDate__c, FS_Second_Deadline_Date__c from Case Where id = :ifapCase.Id];
        System.assertEquals(Date.today(),ifapCase.FirstFSnonComplianceDate__c);
        System.assertEquals(Date.today().addDays(30),ifapCase.FS_Second_Deadline_Date__c);
    }

    @isTest
    public static void testFAPassengerOK() {
        Case ifapCase = createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;
        sidraCase.BSP_CASS__c = 'BSP';
        sidraCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';

        Test.startTest();
        insert sidraCase;
        Test.stopTest();

        ifapCase = [Select FirstFAnonComplianceDate__c, FA_Second_Deadline_Date__c from Case Where id = :ifapCase.Id];
        System.assertEquals(Date.today(),ifapCase.FirstFAnonComplianceDate__c);
        System.assertEquals(Date.today().addDays(31),ifapCase.FA_Second_Deadline_Date__c);
    }

    @isTest
    public static void testFACargoOK() {
        Case ifapCase = createIFAPCargo();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        SidraLiteManager.BLOCK_EXECUTION = false;

        Case sidraCase = createSIDRALite();
        sidraCase.ParentId = ifapCase.Id;
        sidraCase.accountId = ifapCase.accountId;
        sidraCase.BSP_CASS__c = 'CASS';
        sidraCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';

        Test.startTest();
        insert sidraCase;
        Test.stopTest();

        ifapCase = [Select FirstFAnonComplianceDate__c, FA_Second_Deadline_Date__c from Case Where id = :ifapCase.Id];
        System.assertEquals(Date.today(),ifapCase.FirstFAnonComplianceDate__c);
        System.assertEquals(Date.today().addDays(30),ifapCase.FA_Second_Deadline_Date__c);
    }

}