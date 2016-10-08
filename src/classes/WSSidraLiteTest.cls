@isTest
public class WSSidraLiteTest {


    private static Case createSIDRALite(Case parent) {
        Case cse = new Case(
            RecordtypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE,
            ParentId = parent.Id,
            accountId = parent.accountId,
            SIDRA_Lite_Reason__c = SidraLiteManager.isFS(parent)? 'Financial Security Non-compliance': 'Financial Review Non-compliance'
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
    public static void testCreateDummyFSPassenger() {
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
    public static void testCreateDummyFSCargo() {
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
    public static void testCreateDummyFSCargoForAmericas() {
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
    public static void testCreateDummyFSCargoForNonActiveAccount() {
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
    public static void testCreateDummyFAPassengerAccountActive() {
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
    public static void testCreateDummyFAPassengerAccountNotActive() {
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
    public static void testCreateDummyFACargoAccountActive() {
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
    public static void testCreateDummyFACargoAccountNotActive() {
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
    public static void testUpdateFSNoFirstComplianceDate() {
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
    @isTest
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
    public static void testUpdateFSFutureSecondDeadlineDate() {
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
    public static void testUpdateSecondFSForPassenger() {
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
    public static void testUpdateSecondFSForCargo() {
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
    public static void testUpdateFANoFirstComplianceDate() {
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
    public static void testUpdateFAFutureSecondDeadlineDate() {
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
    public static void testUpdateSecondFAForPassenger() {
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
    public static void testUpdateSecondFAForCargo() {
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
    public static void testUpdateThirdFSWithFutureDeadline() {
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
    public static void testUpdateThirdFSOK() {
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
    public static void testUpdateThirdFAWithFutureDeadline() {
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
    public static void testUpdateThirdFAOK() {
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

}