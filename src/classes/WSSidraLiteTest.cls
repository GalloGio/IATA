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
            WSSidraLite.sidraLiteAction(ifapCase.Id);
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
        WSSidraLite.sidraLiteAction(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testUpdateIFAP_FSPassenger() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        insert ifapCase;

        WSSidraLite.sidraLiteAction(ifapCase.Id);

        Test.startTest();
        WSSidraLite.sidraLiteAction(ifapCase.Id);
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
        WSSidraLite.sidraLiteAction(ifapCase.Id);
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
        WSSidraLite.sidraLiteAction(ifapCase.Id);
        Test.stopTest();
    }


    @isTest
    public static void testCreateDummyIFAP_FSCargoForNonActiveAccount() {
        Case ifapCase = SidraLiteManagerTest.createIFAPCargo();
        ifapCase.FS_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Security Requested';
        ifapCase.FS_Deadline_Date__c = Date.today().addDays(-1);
        ifapcase.Bank_Guarantee_received__c = Date.today();
        insert ifapCase;
        //set account as inactive
        Account acc = [Select Status__c from Account where id = :ifapCase.accountId];
        acc.Status__c = 'Cash basis/no commission';
        update acc;

        Test.startTest();
        WSSidraLite.sidraLiteAction(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FAPassengerAccountActive() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapcase.Bank_Guarantee_received__c = Date.today();
        insert ifapCase;

        Test.startTest();
        WSSidraLite.sidraLiteAction(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyIFAP_FAPassengerAccountNotActive() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        ifapCase.FA_Letter_Sent__c = true;
        ifapCase.Status = 'Financial Statements Uploaded';
        ifapCase.Deadline_Date__c = Date.today().addDays(-1);
        ifapcase.Bank_Guarantee_received__c = Date.today();
        insert ifapCase;
        //set account as inactive
        Account acc = [Select Status__c from Account where id = :ifapCase.accountId];
        acc.Status__c = 'Cash basis/no commission';
        update acc;

        Test.startTest();
        WSSidraLite.sidraLiteAction(ifapCase.Id);
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
        WSSidraLite.sidraLiteAction(ifapCase.Id);
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
        WSSidraLite.sidraLiteAction(ifapCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyInvoicing_PassengerAnnualFees() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert invoicingCase;

        Test.startTest();
        WSSidraLite.sidraLiteAction(invoicingCase.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateDummyInvoicing_PassengerAdminCharges() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert invoicingCase;

        Test.startTest();
        WSSidraLite.sidraLiteAction(invoicingCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyInvoicing_CargoAnnualFees() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingCargo();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert invoicingCase;

        //set account category to CASS Associate
        Account acc = [Select Status__c from Account where id = :invoicingCase.accountId];
        acc.Category__c = 'CASS Associate';
        update acc;

        Test.startTest();
        WSSidraLite.sidraLiteAction(invoicingCase.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateDummyInvoicing_CargoAdminCharges() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingCargo();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert invoicingCase;

        //set account category to CASS Associate
        Account acc = [Select Status__c from Account where id = :invoicingCase.accountId];
        acc.Category__c = 'CASS Associate';
        update acc;

        Test.startTest();
        WSSidraLite.sidraLiteAction(invoicingCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyInvoicing_AgentAnnualFees() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingAgent();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert invoicingCase;

        Test.startTest();
        WSSidraLite.sidraLiteAction(invoicingCase.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateDummyInvoicing_AgentAdminCharges() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingAgent();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert invoicingCase;

        Test.startTest();
        WSSidraLite.sidraLiteAction(invoicingCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateDummyInvoicing_InactiveAccountAnnualFees() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert invoicingCase;

        //set account as inactive
        Account acc = [Select Status__c from Account where id = :invoicingCase.accountId];
        acc.Status__c = 'Cash basis/no commission';
        update acc;

        Test.startTest();
        WSSidraLite.sidraLiteAction(invoicingCase.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateDummyInvoicing_InactiveAccountAdminCharges() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        invoicingCase.SAAM_Deadline_Date__c = Date.today().addDays(-1);
        insert invoicingCase;

        //set account as inactive
        Account acc = [Select Status__c from Account where id = :invoicingCase.accountId];
        acc.Status__c = 'Cash basis/no commission';
        update acc;

        Test.startTest();
        WSSidraLite.sidraLiteAction(invoicingCase.Id);
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
            WSSidraLite.sidraLiteAction(smapCase.Id);
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
            WSSidraLite.sidraLiteAction(smapCase.Id);
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
            WSSidraLite.sidraLiteAction(smapCase.Id);
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
        WSSidraLite.sidraLiteAction(smapCase.Id);
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
            WSSidraLite.sidraLiteAction(oscarCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case already exists');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_NoReason() {
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;
        
        AMS_Oscar__c oscar = new AMS_Oscar__c( Validation_Status__c = AMS_Utils.FAILED, RPM_Approval__c = 'Authorize Disapproval', Account__c=account.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.OSCAR__c = oscar.Id;
        oscarCase.Reason1__c = '';
        insert oscarCase;

        Test.startTest();
        try {
            WSSidraLite.sidraLiteAction(oscarCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case for no Reason value');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_NoValidReason() {
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;

        AMS_Oscar__c oscar = new AMS_Oscar__c( Validation_Status__c = AMS_Utils.FAILED, RPM_Approval__c = 'Authorize Disapproval',Account__c=Account.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = 'wrong reason';
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        Test.startTest();
        try {
            WSSidraLite.sidraLiteAction(oscarCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case when there is no OSCAR case');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    private static list<String> OSCARValidReasons = new list<String>(SidraLiteHelperForOSCAR.VALID_REASONS);

    @isTest
    public static void testCreateCaseOSCAR_NoOSCARReason() {
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(
            Step6__c = '',
            Step9__c = '',
            Step11__c = '',
            Step12__c = '',
            Step14__c = '',
            RPM_Approval__c = '',
            Account__c = account.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        Test.startTest();
        try {
            WSSidraLite.sidraLiteAction(oscarCase.Id);
            System.assert(false,'No exception thrown for SIDRA Lite case when there is no OSCAR case');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK1() {
        insert new AMS_Trigger_Execution_Manager__c(All__c = true);

        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        AMS_Oscar__c oscar = new AMS_Oscar__c();
        oscar.Status__c = oscarCase.Status;
        oscar.Account__c = account.Id;
        insert oscar;

        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step6__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.sidraLiteAction(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK2() {
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(Account__c=account.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step9__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.sidraLiteAction(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK3() {
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(Account__c=account.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step11__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.sidraLiteAction(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK4() {
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(Account__c=account.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step12__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.sidraLiteAction(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK5() {
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(Account__c=account.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Step14__c = 'Failed';
        update oscar;

        Test.startTest();
        WSSidraLite.sidraLiteAction(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCaseOSCAR_OK6() {
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account account = new Account(RecordTypeId = agencyRT, Name='Test Account');
        insert account;
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(Account__c=account.Id);
        insert oscar;

        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        oscarCase.Reason1__c = OSCARValidReasons.get(0);
        oscarCase.OSCAR__c = oscar.Id;
        insert oscarCase;

        oscar.Validation_Status__c = AMS_Utils.FAILED;
        oscar.RPM_Approval__c = 'Authorize Disapproval';
        update oscar;

        Test.startTest();
        WSSidraLite.sidraLiteAction(oscarCase.Id);
        Test.stopTest();
    }

    @isTest
    public static void testCreateCase_InvalidRT() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
        WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
        WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
        WSSidraLite.sidraLiteAction(saamCase.Id);
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
        WSSidraLite.sidraLiteAction(saamCase.Id);
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
        WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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
            WSSidraLite.sidraLiteAction(saamCase.Id);
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

    @isTest
    public static void testThrowPopUpMessageIFAP() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        insert ifapCase;

        Test.startTest();
        try {
            WSSidraLite.throwPopUpMessage(ifapCase);
            System.assert(false, 'Expected Exception for IFAP');
        } catch (WSSidraLite.ShowConfirmationException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testThrowPopUpMessageSAAM() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        insert saamCase;

        Test.startTest();
        try {
            WSSidraLite.throwPopUpMessage(saamCase);
            System.assert(false, 'Expected Exception for SAAM');
        } catch (WSSidraLite.ShowConfirmationException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testThrowPopUpMessageInvoicing_AnnualFees() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Test.startTest();
        try {
            WSSidraLite.throwPopUpMessage(invoicingCase);
            System.assert(false, 'Expected Exception for Ivoicing collection');
        } catch (SidraLiteUtil.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testThrowPopUpMessageInvoicing_AdminCharges() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        insert invoicingCase;

        Test.startTest();
        try {
            WSSidraLite.throwPopUpMessage(invoicingCase);
            System.assert(false, 'Expected Exception for Ivoicing collection');
        } catch (WSSidraLite.ShowConfirmationException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testThrowPopUpMessageSMAP() {
        Case smapCase = SidraLiteManagerTest.createSMAPPassenger();
        insert smapCase;

        Test.startTest();
        try {
            WSSidraLite.throwPopUpMessage(smapCase);
            System.assert(false, 'Expected Exception for SMAP');
        } catch (SidraLiteHelperForSMAP.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testThrowPopUpMessageOSCAR() {
        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        insert oscarCase;

        Test.startTest();
        try {
            WSSidraLite.throwPopUpMessage(oscarCase);
            System.assert(false, 'Expected Exception for OSCAR');
        } catch (WSSidraLite.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testThrowPopUpMessage_ERROR() {
        Case dummyCase = new Case();
        insert dummyCase;

        Test.startTest();
        try {
            WSSidraLite.throwPopUpMessage(dummyCase);
            System.assert(false, 'Expected Exception for dummyCase');
        } catch (WSSidraLite.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testupdateSidraLiteAndParentIFAP() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        insert ifapCase;

        Test.startTest();
        Case childCase = createSIDRALite(ifapCase);
        insert childCase;
        
        try {
            WSSidraLite.updateSidraLiteAndParent(ifapCase, childCase);
        } catch (SidraLiteHelperForIFAP.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testupdateSidraLiteAndParentSAAM() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(saamCase, childCase);
        } catch (SidraLiteHelperForSAAM.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees1() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;
        
        invoicingCase.New_IFAP_Deadline_date__c = null;
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees2() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;
        
        invoicingCase.New_IFAP_Deadline_date__c = Date.Today();
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees3() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;
        
        invoicingCase.New_IFAP_Deadline_date__c = Date.Today().addDays(-1);
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(true);
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(false, 'Exception not expected');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees4() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;
        
        invoicingCase.Termination_date_manual_entry__c = Date.today();
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees5() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;
        
        invoicingCase.Termination_date_manual_entry__c = Date.today().addDays(-1);
        invoicingCase.Propose_Default__c = Date.today();
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(true);
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(false, 'Exception not expected');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees6() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;
        
        invoicingCase.Termination_date_manual_entry__c = Date.today().addDays(-1);
        invoicingCase.Propose_Default__c = null;
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(true);
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(false, 'Exception expected');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees7() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingAgent();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;

        invoicingCase.Termination_date_manual_entry__c = null;
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees8() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingCargo();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;

        invoicingCase.Termination_date_manual_entry__c = null;
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees9() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingCargo();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;

        invoicingCase.Termination_date_manual_entry__c = Date.today();
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees10() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingCargo();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        childCase.Propose_Default__c = Date.today();
        insert childCase;

        invoicingCase.Termination_date_manual_entry__c = Date.today().adddays(-1);
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AnnualFees11() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingCargo();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ANNUAL_FEES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        childCase.Propose_Default__c = null;
        insert childCase;

        invoicingCase.Termination_date_manual_entry__c = Date.today().adddays(-1);
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(true);
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(false, 'Exception not expected');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AdminCharges1() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AdminCharges2() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        insert childCase;

        invoicingCase.Termination_date_manual_entry__c = Date.today();
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AdminCharges3() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        childCase.Propose_Default__c = Date.today();
        insert childCase;

        invoicingCase.Termination_date_manual_entry__c = Date.today().adddays(-1);
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(false, 'Exception expected');
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParentInvoicing_AdminCharges4() {
        Case invoicingCase = SidraLiteManagerTest.createInvoicingPassenger();
        invoicingCase.Reason1__c = SidraLiteHelperForInvoicing.ADMIN_CHARGES;
        insert invoicingCase;

        Case childCase = createSIDRALite(invoicingCase);
        childCase.Propose_Default__c = null;
        insert childCase;

        invoicingCase.Termination_date_manual_entry__c = Date.today().adddays(-1);
        update invoicingCase;
        invoicingCase = WSSidraLite.queryCase(invoicingCase.Id);
        childCase = invoicingCase.cases[0];

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(invoicingCase, childCase);
            System.assert(true);
        } catch (SidraLiteHelperForInvoicing.SidraLiteException e) {
            System.assert(false, 'Exception not expected');
        }
        Test.stopTest();
    }

    @isTest
    public static void testupdateSidraLiteAndParentSMAP() {
        Case smapCase = SidraLiteManagerTest.createSMAPPassenger();
        insert smapCase;

        Case childCase = createSIDRALite(smapCase);
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(smapCase, childCase);
        } catch (SidraLiteHelperForSMAP.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest
    public static void testupdateSidraLiteAndParentOSCAR() {
        Case oscarCase = SidraLiteManagerTest.createOSCARPassenger();
        insert oscarCase;

        Case childCase = createSIDRALite(oscarCase);
        insert childCase;

        Test.startTest();
        try {
            WSSidraLite.updateSidraLiteAndParent(oscarCase, childCase);
        } catch (WSSidraLite.SidraLiteException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSidraLiteAndParent_ERROR() {
        Case dummyCase = new Case();
        insert dummyCase;

        Test.startTest();
        list<Case> result = WSSidraLite.updateSidraLiteAndParent(dummyCase, dummyCase);
        System.assert(result==null, 'Expected Exception for dummyCase');
        Test.stopTest();
    }

    @isTest
    public static void testNewCaseComments_NoCases() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        insert ifapCase;

        Test.startTest();
        Case sidraLiteCase = createSIDRALite(ifapCase);
        insert sidraLiteCase;
        
        Account account = [Select Id, Status__c from Account where id =:sidraLiteCase.AccountId];
        account.Status__c = new list<string>(SidraLiteUtil.ACCOUNT_INACTIVE_STATUS)[0];
        update account;

       
        list<CaseComment> result = WSSidraLite.newCaseComments(sidraLiteCase, account);
        System.assert(result.size()==1, 'Expected 1 case comment');
        Test.stopTest();
    }
    
    @isTest
    public static void testNewCaseComments_OtherCaseFound() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        insert ifapCase;

        Test.startTest();
        Case sidraLiteCase1 = createSIDRALite(ifapCase);
        Case sidraLiteCase2 = createSIDRALite(ifapCase);
        insert new list<Case>{sidraLiteCase1, sidraLiteCase2};

        Account account = [Select Id, Status__c,
            (Select id, caseNumber, Comments__c, Termination_date__c from Cases where id != :sidraLiteCase1.id)
            from Account
            where id =:ifapCase.AccountId];
        account.Status__c = new list<string>(SidraLiteUtil.ACCOUNT_INACTIVE_STATUS)[0];
        update account;

        
        list<CaseComment> result = WSSidraLite.newCaseComments(sidraLiteCase1, account);
        System.assert(result.size()==2, 'Expected 2 case comments');
        Test.stopTest();
    }

    @isTest
    public static void testUpdateTerminationDate_OK() {
        Case ifapCase = SidraLiteManagerTest.createIFAPPassenger();
        insert ifapCase;

        Test.startTest();
        WSSidraLite.updateTerminationDate(ifapCase.Id, Date.today());
        Test.stopTest();

        ifapCase = [Select Termination_date__c from Case where Id = :ifapCase.Id];
        System.assert( ifapCase.Termination_date__c == Date.today(), 'Termination date not changed');
    }

    @isTest
    public static void testUpdateTerminationDate_ERROR() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        insert saamCase;
        Id caseId = saamCase.Id;
        delete saamCase;

        Test.startTest();
        WSSidraLite.updateTerminationDate(caseId, Date.today());
        Test.stopTest();
    }

    @isTest
    public static void testinsertCommentsWhenNotUpdate_OK() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        insert saamCase;

        Case sidraLiteCase = createSIDRALite(saamCase);
        insert sidraLiteCase;

        Test.startTest();
        WSSidraLite.insertCommentsWhenNotUpdate(saamCase, sidraLiteCase);
        Test.stopTest();
    }
    
    @isTest
    public static void testinsertCommentsWhenNotUpdate_ERROR() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();

        Test.startTest();
        try {
            WSSidraLite.insertCommentsWhenNotUpdate(saamCase, saamCase);
            System.assert(false,'Exception expected');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest //SidraLiteHelperForSAAM.updateSidraLiteAndParent
    public static void testCreateDummyInvoicing_Passenger2() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Other';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        saamCase.New_IFAP_Deadline_date__c = Date.Today().addDays(-1);
        saamCase.firstFSnonComplianceDate__c = Date.Today().addDays(-1);
        saamCase.FS_Second_Deadline_Date__c = Date.Today().addDays(-1);
        saamCase.FS_Third_Deadline_Date__c = null;
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        insert childCase;

        Test.startTest();
        try {
            list<Case> lsttest = SidraLiteHelperForSAAM.updateSidraLiteAndParent(saamCase, childCase);
            //System.assert(false,'No exception thrown for SIDRA Lite update with invalid new IFAP deadline date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @isTest //SidraLiteHelperForSAAM.updateSidraLiteAndParent
    public static void testCreateDummyInvoicing_Passenger3() {
        Case saamCase = SidraLiteManagerTest.createSAAMPassenger();
        saamCase.Reason1__c = 'Other';
        saamCase.SAAM_Deadline_Date__c = Date.Today().addDays(-1);
        saamCase.New_IFAP_Deadline_date__c = Date.Today().addDays(-1);
        saamCase.firstFSnonComplianceDate__c = Date.Today().addDays(-1);
        saamCase.FS_Second_Deadline_Date__c = Date.Today().addDays(-1);
        saamCase.FS_Third_Deadline_Date__c = Date.Today().addDays(-1);
        insert saamCase;

        Case childCase = createSIDRALite(saamCase);
        childcase.Termination_date_manual_entry__c = Date.today();
        insert childCase;

        Test.startTest();
        try {
            list<Case> lsttest = SidraLiteHelperForSAAM.updateSidraLiteAndParent(saamCase, childCase);
            //System.assert(false,'No exception thrown for SIDRA Lite update with invalid new IFAP deadline date');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

}
