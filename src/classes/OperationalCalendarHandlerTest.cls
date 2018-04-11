@isTest
private class OperationalCalendarHandlerTest {

    @isTest
    private static void testBeforeInsertForBSP() {
        AMS_Settlement_System__c issOperation = new AMS_Settlement_System__c(Name = 'BSP-SP');
        insert issOperation;
        
        Test.StartTest();
        Operational_Calendar__c operation = new Operational_Calendar__c(
            Operation_Code__c= 'SP_BSP_Y_EUR_D',
            Period_Code__c= '20180202M'
        );
        insert operation;
        Test.stopTest();
        
        operation = [
            SELECT Id, Operation_Code__c, Period_Code__c, Operation_Currency__c, Operation_Period_code__c,
                Frequency_code__c, Operation_Type__c, ISS_operation__c,Recordtype.DeveloperName
            FROM Operational_Calendar__c
            WHERE Id = :operation.Id];
        System.assertEquals('EUR',operation.Operation_Currency__c);
        System.assertEquals('M',operation.Frequency_code__c);
        System.assertEquals('BSP Domestic',operation.Operation_Type__c);
        System.assertEquals(issOperation.Id,operation.ISS_operation__c);
        System.assertEquals(operation.Operation_Code__c + '_RM_' + operation.Period_Code__c ,operation.Operation_Period_code__c);
        System.assertEquals('ISS_Calendar',operation.Recordtype.DeveloperName);
    }
    
    @isTest
    private static void testBeforeInsertForCASS() {
        AMS_Settlement_System__c issOperation = new AMS_Settlement_System__c(Name = 'CASS-SP');
        insert issOperation;
        
        Test.StartTest();
        Operational_Calendar__c operation = new Operational_Calendar__c(
            Operation_Code__c= 'SP_CAS_E_EUR_X',
            Period_Code__c= '20180202M'
        );
        insert operation;
        Test.stopTest();
        
        operation = [
            SELECT Id, Operation_Code__c, Period_Code__c, Operation_Currency__c, Operation_Period_code__c,
                Frequency_code__c, Operation_Type__c, ISS_operation__c,Recordtype.DeveloperName
            FROM Operational_Calendar__c
            WHERE Id = :operation.Id];
        System.assertEquals('EUR',operation.Operation_Currency__c);
        System.assertEquals('M',operation.Frequency_code__c);
        System.assertEquals('CASS Export',operation.Operation_Type__c);
        System.assertEquals(issOperation.Id,operation.ISS_operation__c);
        System.assertEquals(operation.Operation_Code__c + '_RM_' + operation.Period_Code__c ,operation.Operation_Period_code__c);
        System.assertEquals('ISS_Calendar',operation.Recordtype.DeveloperName);
    }
}