@isTest
private class FinancialSecurityHandlerTest {

    @testSetup static void setup() {
        //Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;

        //Create Agency HQ
        Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account a = new Account(Name = 'Trave A', RecordTypeId = agencyRT, Type = 'IATA Passenger Sales Agent');
        insert a;  

        Contact co1 = new Contact(AccountId = a.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', BSP_CASS_Payment_contact__c = true, Financial_Assessment_Contact__c = true, User_Portal_Status__c = 'Approved Admin');
        Contact co2 = new Contact(AccountId = a.id, Firstname = 'teste2', Lastname='test2', Phone = '911111112', MobilePhone = '911111112', Email = 'test2@test.com', BSP_CASS_Payment_contact__c = false, User_Portal_Status__c = 'Approved Admin');
        insert new List<Contact> {co1,co2};

        // Create a new Financial Institution
        Financial_Institution__c fi = new Financial_Institution__c(Name = 'Test FI', Region__c = 'Americas', Country__c = 'Canada', Institution_Type__c = 'Bank');
        insert fi;

        // create a reception case
        Case c = new Case(Subject= 'Reception case', AccountId= a.Id, Status= 'Open', RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE'));
        insert c;

        // Create a new Financial Security
        Financial_Security__c fs = new Financial_Security__c(
            Region__c= 'Americas', 
            Security_status__c= 'Active', 
            Account__c= a.Id, 
            CurrencyIsoCode= 'USD', 
            Amount__c= 100,
            Expiry_date__c= Date.today().addYears(2), 
            Financial_Institution__c= fi.Id, 
            Security_Type__c= 'Cross Border Guarantee', 
            Validity_Start_Date__c= Date.today().addDays(-2), 
            Reception_Case__c= c.Id, 
            Reception_Date__c= Date.today(), 
            Reasonforrequest__c= 'New Application'
        );
        insert fs;
    }

    @isTest static void testRenewalCase() {
        Financial_Security__c fs = [SELECT Id, Security_Status__c FROM Financial_Security__c];
        Test.startTest();
        fs.Security_Status__c = 'Close to Expiry Date';
        update fs;
        fs = [SELECT Id, Renewal_Case__c,Region__c FROM Financial_Security__c WHERE Id = :fs.Id];
        System.assertNotEquals(null, fs.Renewal_Case__c);
        Test.stopTest();
    }

    @isTest static void testDeleteAndUndelete() {
        Financial_Security__c fs = [SELECT Id, Security_Status__c FROM Financial_Security__c];
        Test.startTest();
        delete fs;
        undelete fs;
        Test.stopTest();
    }

    @isTest static void testAcknowledge() {
        Financial_Security__c fs = [SELECT Id, Account__c, Security_Status__c, Send_FS_acknowledgment__c FROM Financial_Security__c limit 1];
        Test.startTest();
        fs.Send_FS_acknowledgment__c = true;
        FinancialSecurityUtil.acknowledgeRunning = true;
        update fs;
        Test.stopTest();       
    }
}