@isTest
private class AMS_OSCAR_Age_CalculatorTest {

    @testSetup static void setup() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name= 'Portugal',
            ISO_Code__c= 'PT',
            ISO_Code_Numeric__c= 11
        );
        insert country;
        Account acc = new Account(
            Name= 'Test Ag',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
            IATA_ISO_Country__c= country.Id
        );
        insert acc;
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(
            Name= '11111',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW'),
            Account__c= acc.Id,
            Dossier_Reception_Date__c= Date.today()
        );
        insert oscar;
        Case cse = new Case(
            AccountId= acc.Id,
            Reason1__c= 'New HO',
            CaseArea__c= 'Accreditation Process',
            Status= 'Open',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'),
            OSCAR__c= oscar.Id
        );
        insert cse;
    }

    @isTest static void closeCase() {
        Test.startTest();
        AMS_OSCAR__c oscar = [SELECT Id, Status__c FROM AMS_OSCAR__c LIMIT 1];
        oscar.Status__c = 'Closed';
        update oscar;
        Test.stopTest();
    }

    @isTest static void runBatch() {
        Test.startTest();
        AMS_OSCAR_Age_Calculator b = new AMS_OSCAR_Age_Calculator(5);
        Database.executeBatch(b);
        Test.stopTest();
    }

    @isTest static void scheduleBatch() {
        Test.startTest();
        AMS_OSCAR_Age_Calculator.start('0 0 22 * * ? *', 5);
        AMS_OSCAR_Age_Calculator.stop();
        Test.stopTest();
    }

}