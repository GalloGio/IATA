@isTest
public class WSSidraLiteTest {

    private static Case createSIDRALite(Case parent) {
        Case cse = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            ParentId = parent.Id,
            accountId = parent.accountId,
            BSPCountry__c = 'Canada',
            SIDRA_Lite_Reason__c = SidraLiteHelperForIFAP.isFS(parent)? 'Financial Security Non-compliance': 'Financial Review Non-compliance'
        );
        return cse;
    }

    @isTest
    public static void testThrowException() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = false;
        insert ifapCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(ifapCase.Id);
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true,'Exception thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FSPassenger() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FSCargo() {
        Case ifapCase = SidraLiteManagerTest.createIFAPCargo();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FSCargoForAmericas() {
        Case ifapCase = SidraLiteManagerTest.createIFAPCargo();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.Region__c = 'Americas';
        insert ifapCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(ifapCase.Id);
        Test.stopTest();
    }


    @isTest
    public static void testCreateDummyIFAP_FSCargoForNonActiveAccount() {
        Case ifapCase = SidraLiteManagerTest.createIFAPCargo();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        //set account as inactive
        Account acc = [Select Status__c from Account where id = :ifapCase.accountId];
        acc.Status__c = 'Cash basis/no commission';
        update acc;

        Test.startTest();
        WSSidraLite.checkBussinesRules(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FAPassengerAccountActive() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FAPassengerAccountNotActive() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        //set account as inactive
        Account acc = [Select Status__c from Account where id = :ifapCase.accountId];
        acc.Status__c = 'Cash basis/no commission';
        update acc;

        Test.startTest();
        WSSidraLite.checkBussinesRules(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FACargoAccountActive() {
        Case ifapCase = SidraLiteManagerTest.createIFAPCargo();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FACargoAccountNotActive() {
        Case ifapCase = SidraLiteManagerTest.createIFAPCargo();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;
        //set account as inactive
        Account acc = [Select Status__c from Account where id = :ifapCase.accountId];
        acc.Status__c = 'Cash basis/no commission';
        update acc;

        Test.startTest();
        WSSidraLite.checkBussinesRules(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_FSNoFirstComplianceDate() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFSnonComplianceDate__c = null;
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        try {
            WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
  /*
    //@isTest
    public static void testUpdateFSNoSecondDeadlineDate() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFSnonComplianceDate__c = Date.today();
        ifapCase.secondFSnonComplianceDate__c = null;
        ifapCase.FS_Second_Deadline_Date__c = null;
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        try {
            WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    */

    @isTest
    public static void testUpdateIFAP_FSFutureSecondDeadlineDate() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFSnonComplianceDate__c = Date.today();
        ifapCase.secondFSnonComplianceDate__c = null;
        ifapCase.FS_Second_Deadline_Date__c = Date.today().addDays(1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        try {
            WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_SecondFSForPassenger() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFSnonComplianceDate__c = Date.today();
        ifapCase.secondFSnonComplianceDate__c = null;
        ifapCase.FS_Second_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_SecondFSForCargo() {
        Case ifapCase = SidraLiteManagerTest.createIFAPCargo();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFSnonComplianceDate__c = Date.today();
        ifapCase.secondFSnonComplianceDate__c = null;
        ifapCase.FS_Second_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'CASS';

        Test.startTest();
        insert sidraCase;
        WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_FANoFirstComplianceDate() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFAnonComplianceDate__c = null;
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        try {
            WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_FAFutureSecondDeadlineDate() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFAnonComplianceDate__c = Date.today();
        ifapCase.secondFAnonComplianceDate__c = null;
        ifapCase.FA_Second_Deadline_Date__c = Date.today().addDays(1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        try {
            WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_SecondFAForPassenger() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFAnonComplianceDate__c = Date.today();
        ifapCase.secondFAnonComplianceDate__c = null;
        ifapCase.FA_Second_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_SecondFAForCargo() {
        Case ifapCase = SidraLiteManagerTest.createIFAPCargo();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFAnonComplianceDate__c = Date.today();
        ifapCase.secondFAnonComplianceDate__c = null;
        ifapCase.FA_Second_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'CASS';

        Test.startTest();
        insert sidraCase;
        WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
        Test.stopTest();
    }



    @isTest
    public static void testUpdateIFAP_ThirdFSWithFutureDeadline() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFSnonComplianceDate__c = Date.today();
        ifapCase.secondFSnonComplianceDate__c = Date.today();
        ifapCase.FS_Second_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.FS_Third_Deadline_Date__c = Date.today().addDays(1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        try {
            WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_ThirdFSOK() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFSnonComplianceDate__c = Date.today();
        ifapCase.secondFSnonComplianceDate__c = Date.today();
        ifapCase.FS_Second_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.FS_Third_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_ThirdFAWithFutureDeadline() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFAnonComplianceDate__c = Date.today();
        ifapCase.secondFAnonComplianceDate__c = Date.today();
        ifapCase.FA_Second_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.FA_Third_Deadline_Date__c = Date.today().addDays(1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        try {
            WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
            System.assert(false,'Exception required');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_ThirdFAOK() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.firstFAnonComplianceDate__c = Date.today();
        ifapCase.secondFAnonComplianceDate__c = Date.today();
        ifapCase.FA_Second_Deadline_Date__c = Date.today().addDays(-1);
        ifapCase.FA_Third_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        Case sidraCase = createSIDRALite(ifapCase);
        sidraCase.BSP_CASS__c = 'BSP';

        Test.startTest();
        insert sidraCase;
        WSSidraLite.updateSecondAndThirdDeadline(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testFormatDate() {
        Date today = Date.today();
        DateTime now = DateTime.now();
        Test.startTest();
        System.assertEquals(today.format(),WSSidraLite.formatDate(today));
        System.assertEquals(now.format(),WSSidraLite.formatDateTime(now));
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseSMAP_CaseAlreadyExists() {
        Case smapCase = SidraLiteManagerTest.createSMAPPassenger();
        insert smapCase;

        insert createSIDRALite(smapCase);

        Test.startTest();
        try {
            WSSidraLite.createCase(smapCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case already exists');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseSMAP_ErrorInDecision() {
        Case smapCase = SidraLiteManagerTest.createSMAPPassenger();
        insert smapCase;

        Test.startTest();
        try {
            WSSidraLite.createCase(smapCase.Id);
            System.assert(false,'No exception thrown for bad Decision__c value');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseSMAP_BadSuspensionDate() {
        Case smapCase = SidraLiteManagerTest.createSMAPPassenger();
        smapCase.Decision__c = 'Prejudiced Collection of Funds';
        smapCase.Suspension_Date__c = Date.today().addDays(1);
        insert smapCase;

        Test.startTest();
        try {
            WSSidraLite.createCase(smapCase.Id);
            System.assert(false,'No exception thrown for bad Suspension_Date__c value');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseSMAP_OK() {
        Case smapCase = SidraLiteManagerTest.createSMAPPassenger();
        smapCase.Decision__c = 'Prejudiced Collection of Funds';
        smapCase.Suspension_Date__c = Date.today().addDays(-1);
        insert smapCase;

        Test.startTest();
        WSSidraLite.createCase(smapCase.Id);
        Test.stopTest();

        System.assert(smapCase.Id!=null, 'Sidra Lite case for SMAP parent case was not created');
    }

    @isTest
    public static void testCreateCaseOSCAR_NotOSCARRecord() {
        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        insert oscarCase;

        insert createSIDRALite(oscarCase);

        Test.startTest();
        try {
            WSSidraLite.createCase(oscarCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case already exists');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_NoReason() {
        AMS_Oscar__c oscar = new AMS_Oscar__c( RPM_Approval__c = 'Authorize Disapproval');
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.OSCAR__c = oscar.Id;
        oscarCase.Reason1__c = '';
        insert oscarCase;

        Test.startTest();
        try {
            WSSidraLite.createCase(oscarCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for no Reason value');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_NoValidReason() {
        AMS_Oscar__c oscar = new AMS_Oscar__c( RPM_Approval__c = 'Authorize Disapproval');
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = 'wrong reason';
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        Test.startTest();
        try {
            WSSidraLite.createCase(oscarCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case when there is no OSCAR case');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    private static list<String> OSCARValidReasons = new list<String>(SidraLiteHelperForOSCAR.VALID_REASONS);

    @isTest
    public static void testCreateCaseOSCAR_NoOSCARReason() {
        AMS_Oscar__c oscar = new AMS_Oscar__c(
            Step6__c = '',
            Step9__c = '',
            Step11__c = '',
            Step12__c = '',
            Step14__c = '',
            RPM_Approval__c = '');
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        Test.startTest();
        try {
            WSSidraLite.createCase(oscarCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case when there is no OSCAR case');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK1() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(ISO_Code__c='BR');

        insert country;

        Account acct = new Account(
            Name = 'Test account',
            BillingCity = 'Montreal',
            BillingCountry = 'Canada',
            BillingStreet = 'some street',
            IATA_ISO_Country__c = country.Id,
            Location_Type__c = 'HO',
            IATACode__c = '1234567',
            Type = 'IATA Passenger Sales Agent'
        );
        insert acct;
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(Account__c = acct.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step6__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.createCase(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK2() {
        AMS_Oscar__c oscar = new AMS_Oscar__c();
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step9__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.createCase(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK3() {
        AMS_Oscar__c oscar = new AMS_Oscar__c();
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step11__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.createCase(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK4() {
        AMS_Oscar__c oscar = new AMS_Oscar__c();
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step12__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.createCase(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK5() {
        AMS_Oscar__c oscar = new AMS_Oscar__c();
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step14__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.createCase(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK6() {
        AMS_Oscar__c oscar = new AMS_Oscar__c();
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.RPM_Approval__c = 'Authorize Disapproval';
        update oscar;

        Test.startTest();
        WSSidraLite.createCase(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCase_InvalidRT() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.createCase(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case already exists');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_InvalidReason() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for invalid reason');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_FSNoGuaranteeDeadline() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Financial Security Renewal';
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for null Bank Guarantee Deadline');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_FSInvalidGuaranteeDeadline() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Financial Security Renewal';
        saamCase.Bank_Guarantee_deadline__c = Date.today();
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for invalid Bank Guarantee Deadline');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_FSInnactiveAccount() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Financial Security Renewal';
        saamCase.Bank_Guarantee_deadline__c = Date.today().addDays(-1);
        insert saamCase;

        //activate account
        Account acc = [Select Status__c from Account where id = :saamCase.AccountId];
        acc.Status__c = 'Terminated';
        update acc;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for invalid Bank Guarantee Deadline');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_FSOK() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Financial Security Renewal';
        saamCase.Bank_Guarantee_deadline__c = Date.today().addDays(-1);
        insert saamCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(saamCase.Id);
        Test.stopTest();

        System.assert(saamCase.Id!=null, 'Sidra Lite case for SAAM parent case was not created');
    }

    @isTest
    public static void testCreateDummySAAM_CertificateNoDeadlineDate() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Certificate DGR';
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for no SAAM deadline date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_CertificateInvalidDeadlineDate() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Certificate DGR';
        saamCase.SAAM_Deadline_Date__c = Date.Today();
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for invalid SAAM deadline date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_CertificateOK() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Certificate DGR';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        insert saamCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(saamCase.Id);
        Test.stopTest();

        System.assert(saamCase.Id!=null, 'Sidra Lite case for SAAM parent case was not created');
    }

    @isTest
    public static void testCreateDummySAAM_AnnualFeesNoDeadline() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for no SAAM deadline date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_AnnualFeesInvalidDeadline() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.Today();
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for invalid SAAM deadline date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_AnnualFeesInvalidAccount() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.Today();
        insert saamCase;

        // change account type
        Account acc = [Select Type from Account where id = :saamCase.AccountId];
        acc.Type = 'invalid type';
        update acc;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for invalid Account Type');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummySAAM_AnnualFeesOKForPassenger() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        insert saamCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(saamCase.Id);
        Test.stopTest();

        System.assert(saamCase.Id!=null, 'Sidra Lite case for SAAM parent case was not created');
    }

    @isTest
    public static void testCreateDummySAAM_AnnualFeesOKForCargo() {
        Case saamCase = SidraLiteManagerTest.createSAAMCargo();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        insert saamCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(saamCase.Id);
        Test.stopTest();

        System.assert(saamCase.Id!=null, 'Sidra Lite case for SAAM parent case was not created');
    }

    @isTest
    public static void testCreateDummySAAM_AnnualFeesOKForAgent() {
        Case saamCase = SidraLiteManagerTest.createSAAMAgent();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        insert saamCase;

        Test.startTest();
        WSSidraLite.checkBussinesRules(saamCase.Id);
        Test.stopTest();

        System.assert(saamCase.Id!=null, 'Sidra Lite case for SAAM parent case was not created');
    }


    @isTest
    public static void testSAAMCertificateUpdate_WithoutTerminationDate() {
        Case saamCase = SidraLiteManagerTest.createSAAMCargo();
        saamCase.Reason1__c = 'Certificate DGR';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite update without termination date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMCertificateUpdate_WithBadTerminationDate() {
        Case saamCase = SidraLiteManagerTest.createSAAMCargo();
        saamCase.Reason1__c = 'Certificate DGR';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite update with bad termination date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMCertificateUpdate_OK() {
        Case saamCase = SidraLiteManagerTest.createSAAMCargo();
        saamCase.Reason1__c = 'Certificate DGR';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today().addDays(-1);
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite update with bad termination date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_PassengerError1() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        saamCase.New_IFAP_Deadline_date__c = null;
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite update without new IFAP deadline date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_PassengerError2() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        saamCase.New_IFAP_Deadline_date__c = Date.today();
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite update with invalid new IFAP deadline date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_PassengerOK() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        saamCase.New_IFAP_Deadline_date__c = Date.today().addDays(-1);
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite update with invalid new IFAP deadline date');
        } catch (WSSidraLite.ShowConfirmationException e) {
            System.assert(true);
        } catch (Exception e) {
            System.assert(false,'Wrong exception caught');
        }
        WSSidraLite.updateSecondAndThirdDeadline(saamCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_Passenger3thError1() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.Termination_date_manual_entry__c = Date.today();
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite update with invalid Termination date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_Passenger3thError2() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.Termination_date_manual_entry__c = Date.today().addDays(-1);
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        childCase.Propose_Default__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite update with invalid Propose Default date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_Passenger3thError3() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.Termination_date_manual_entry__c = Date.today().addDays(-1);
        saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        childCase.Propose_Default__c = Date.today();
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception caught');
        } catch (WSSidraLite.SidraLiteException e) {
            System.assert(true);
        } catch (Exception e) {
            System.assert(false,'Wrong exception caught: ' + e.getMessage() );
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_Passenger3thOK() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.Termination_date_manual_entry__c = Date.today().addDays(-1);
        saamCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        childCase.Propose_Default__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.checkBussinesRules(saamCase.Id);
            System.assert(false,'No exception caught');
        } catch (WSSidraLite.ShowConfirmationException e) {
            System.assert(true);
        } catch (Exception e) {
            System.assert(false,'Wrong exception caught: ' + e.getMessage() );
        }
        WSSidraLite.updateSecondAndThirdDeadline(saamCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_AgentError1() {
        Case saamCase = SidraLiteManagerTest.createSAAMAgent();
        saamCase.Reason1__c = 'Annual Fees';
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSecondAndThirdDeadline(saamCase.Id);
            System.assert(false,'No exception caught');
        } catch (WSSidraLite.SidraLiteException e) {
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Wrong Exception');
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_CASSError1() {
        Case saamCase = SidraLiteManagerTest.createSAAMCargo();
        saamCase.Termination_date_manual_entry__c = null;
        saamCase.Reason1__c = 'Annual Fees';
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSecondAndThirdDeadline(saamCase.Id);
            System.assert(false,'No exception caught');
        } catch (WSSidraLite.SidraLiteException e) {
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Wrong Exception');
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_CASSError2() {
        Case saamCase = SidraLiteManagerTest.createSAAMCargo();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.Termination_date_manual_entry__c = Date.today();
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSecondAndThirdDeadline(saamCase.Id);
            System.assert(false,'No exception caught');
        } catch (WSSidraLite.SidraLiteException e) {
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Wrong Exception');
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_CASSError3() {
        Case saamCase = SidraLiteManagerTest.createSAAMCargo();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.Termination_date_manual_entry__c = Date.today();
        saamCase.Propose_Default__c = Date.today();
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSecondAndThirdDeadline(saamCase.Id);
            System.assert(false,'No exception caught');
        } catch (WSSidraLite.SidraLiteException e) {
            System.assert(true);
        } catch (Exception e) {
            System.assert(false, 'Wrong Exception');
        }
        Test.stopTest();
    }

    @isTest
    public static void testSAAMAnnualFeesUpdate_CASSOK() {
        Case saamCase = SidraLiteManagerTest.createSAAMCargo();
        saamCase.Reason1__c = 'Annual Fees';
        saamCase.Termination_date_manual_entry__c = Date.today().addDays(-1);
        saamCase.Propose_Default__c = null;
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = null;
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSecondAndThirdDeadline(saamCase.Id);
        } catch (Exception e) {
            System.assert(false, 'Wrong Exception');
        }
        Test.stopTest();
    }

}
