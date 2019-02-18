@isTest
public class FinancialSecurityExpiredBatchTest {
    static testMethod void testMethod1() {

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse', ISO_Code__c = 'SS', AIMS_Area_Name__c = 'suisse', AIMS_Area_ID__c = '1' );
        insert isoCountry;

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        Id Agency_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account a = new Account( name = 'IFAP ACCT', industry = 'pluto', IATA_ISO_Country__c = isoCountry.id, IATACode__c = '1234567', Type = 'IATA Cargo Agent',
                                 billingCountry = 'suisse', Location_Type__c = 'AO', RecordTypeId = Agency_RT_Id);
        insert a;

        Financial_Institution__c FI = new Financial_Institution__c(Name = 'FI1', INSTITUTION_TYPE__C = 'Bank');
        insert FI;

        date dead = date.today().addDays(40);
        
        Test.startTest();

        Contact con = new contact(FirstName = 'jupiter', lastname = 'pluto', phone = '123', accountid = a.id, Financial_Assessment_Contact__c = true);
        insert con;

        Case c = new Case(recordtypeID = IFAPcaseRecordTypeID, Status = 'Assessment Performed', Origin = 'asd', IFAP_Area__c = 'asda', Financial_Review_Type__c = 'bla',
                          IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
                          Deadline_Date__c = dead, contactid = con.id, AccountId = a.id, Assessment_Performed_Date__c = date.today(), Financial_Review_Result__c = 'Satisfactory - No Action');

        insert c;

        Financial_Security__c FS1 = new Financial_Security__c(CURRENCYISOCODE = 'USD', Account__c = a.Id, AMOUNT__C = 3000, EXPIRY_DATE__C = system.Today().AddDays(-100),
                FINANCIAL_INSTITUTION__c = FI.Id, SECURITY_STATUS__C = 'Active', Security_Type__c = 'Bank Guarantee', Region__c = 'Europe', Reception_Date__c = system.today(),
                Reasonforrequest__c = 'New Application', Reception_Case__c = c.Id);
        insert FS1;

        Financial_Security__c FS2 = new Financial_Security__c(CURRENCYISOCODE = 'USD', Account__c = a.Id, AMOUNT__C = 3000, EXPIRY_DATE__C = system.Today().AddDays(-100),
                FINANCIAL_INSTITUTION__c = FI.Id, SECURITY_STATUS__C = 'Active', Security_Type__c = 'Bank Guarantee', Region__c = 'Asia & Pacific', Reception_Date__c = system.today(),
                Reasonforrequest__c = 'New Application', Reception_Case__c = c.Id);
        insert FS2;        

        
        FinancialSecurityExpiredSchedulerAP bScheduler = new FinancialSecurityExpiredSchedulerAP();
        String sch = '20 30 8 10 2 ?';
        system.schedule('Test FinancialSecurityExpiredSchedulerAP', sch, bScheduler);
      

        FinancialSecurityExpiredSchedulerOthers bOScheduler = new FinancialSecurityExpiredSchedulerOthers();
        system.schedule('Test FinancialSecurityExpiredSchedulerOthers', sch, bOScheduler);

        Test.stopTest();

    }
}