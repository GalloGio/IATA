@isTest
public class AMS_OSCAR_WebserviceTest {

    private static AMS_OSCAR__c oscar;
    private static AMS_OSCAR__c oscar2;
    private static AMS_OSCAR__c oscar3;
    private static AMS_OSCAR__c oscar4;
    private static AMS_OSCAR__c oscar5;
    private static AMS_OSCAR__c oscar6;
    private static Account a1;
    private static Account a2;
    private static Account a3;
    private static Account a4;
    private static Account a5;

    private static void setup(){
        
        oscar = new AMS_OSCAR__c(Status__c = 'Reopen', Billing_Document_Number__c = '54321');
        insert oscar;

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
        a1 = new Account(RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency', IATA_ISO_Country__c = ctry.id);
        a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Name='Test1 Agency',Short_Name__c='Test1 Agency',BillingCountry='Brazil');
        a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Location_Type__c='HO',Name='Test1 Agency',Short_Name__c='Test1 Agency',Type='IATA Cargo Agent',BillingCountry='Brazil');
        a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Location_Type__c='HO',Name='Test1 Agency',Short_Name__c='Test1 Agency',Type='IATA Cargo Agent',BillingCountry='Brazil');
        a5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Location_Type__c='HO',Name='Test1 Agency',Short_Name__c='Test1 Agency',Type='IATA Cargo Agent',BillingCountry='Brazil');

        
        insert new List<Account>{a1, a2, a3, a4, a5};

        oscar2 = new AMS_OSCAR__c(Account__c = a1.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
        oscar3 = new AMS_OSCAR__c(Account__c = a2.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
        oscar4 = new AMS_OSCAR__c(Account__c = a3.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
        oscar5 = new AMS_OSCAR__c(Account__c = a4.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
        oscar6 = new AMS_OSCAR__c(Account__c = a5.Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
        
        insert new List<AMS_OSCAR__c>{oscar2, oscar3, oscar4, oscar5, oscar6};

        Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
        insert aacc;

        Contact co1 = new Contact(AccountId = a4.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = true);
        Contact co2 = new Contact(AccountId = a5.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = true);
        insert new List<Contact>{co1, co2};

        Case oscarCase = new Case(Oscar__c = oscar6.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = a5.Id;
        oscarCase.ContactId = co2.Id;
        insert oscarCase;  
        
    }
    

    static testMethod void test_updateFormFields() {
        
        setup();
        
        List<String> fieldApiName = new List<String>{'Status__c', 'Billing_Document_Number__c', 'Invoice_number__c', 'Bank_Guarantee_amount__c', 'Send_agreement__c'};
        List<String> fieldValue = new List<String>{'Open', '12345', '', '50,2', 'true'};
        
        Test.startTest();

        String resultFormFields = AMS_OSCAR_Webservice.updateFormFields(fieldApiName, fieldValue, oscar.Id);

        Test.stopTest();
    }

    static testMethod void test_createIFAP() {
        
        setup();
        
        Test.startTest();

        String resultIFAPFromOSCAR = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar.Id);
        String resultIFAPFromOSCAR2 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar2.Id);
        String resultIFAPFromOSCAR3 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar3.Id);
        String resultIFAPFromOSCAR4 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar4.Id);
        String resultIFAPFromOSCAR5 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar5.Id);
        String resultIFAPFromOSCAR6 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar6.Id);

        Test.stopTest();
    }

    static testMethod void test_createAML() {
        
        setup();
        
        Test.startTest();

        String resultcreateAMLCase = AMS_OSCAR_Webservice.createAMLCase(oscar.Id);
        String resultcreateAMLCase4 = AMS_OSCAR_Webservice.createAMLCase(oscar6.Id);
        String resultcreateAMLCasenoUpdate = AMS_OSCAR_Webservice.createAMLCaseWithNoOscarUpdate([select Name, STEP17__c, Account__c, Account__r.Name, Account__r.IATA_ISO_Country__r.Region__c, Account__r.IATA_ISO_Country__r.Name from AMS_OSCAR__c where Id =: oscar6.Id]);

        Test.stopTest();
    }

    static testMethod void test_copyDataToAccount() {
        
        setup();
        
        // cover regulation update on copyDataToAccount
        Account a1 = [SELECT Id, IATA_ISO_Country__c FROM Account WHERE Name = 'Test1 Agency'][0];
        a1.Sector__c = AMS_Utils.SECTOR_CARGO;
        a1.Reason_for_creation__c = 'Account is missing';

        update a1;

        IATA_ISO_State__c amss = new IATA_ISO_State__c(ISO_Code__c='TS01', IATA_ISO_Country__c=a1.IATA_ISO_Country__c, Name='TestAMS');
        insert amss;

        AMS_Agency_Regulation__c reg1 = new AMS_Agency_Regulation__c(First_Name__c = 'Test1', Last_Name__c = 'test1', Type_of_Certificate__c = 'DGR', Expiry_Date__c = Date.today().addYears(2), Account__c = a1.Id);
        AMS_Agency_Regulation__c reg2 = new AMS_Agency_Regulation__c(First_Name__c = 'Test2', Last_Name__c = 'test2', Type_of_Certificate__c = 'DGR', Expiry_Date__c = Date.today().addYears(2), Account__c = a1.Id);

        insert new List<AMS_Agency_Regulation__c>{reg1, reg2};

        Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));

        oscarCase.Financial_Assessment_requested__c = date.today();
        oscarCase.Deadline_Date__c= date.today();
        oscarCase.Assessment_Performed_Date__c= date.today();
        oscarCase.Financial_Review_Result__c = 'Satisfactory';
        oscarCase.Financial_Security_Amount__c = 1235;
        oscarCase.Financial_Security_Currency__c = 'EUR';
        oscarCase.FS_Deadline_Date__c = date.today();

        insert oscarCase;

        AMS_Pax_Accreditation_Form__c accr = new AMS_Pax_Accreditation_Form__c(Is_your_firm_handling_Dangerous_Goods__c = 'Yes', SAAM_Case__c = oscarCase.Id,  CASS_Number__c = '123', IATA_ISO_State__c = amss.Id, Location_Class__c = 'C',
                                                                                Account_Name__c = 'Test', IATACode__c ='12345657', Branch_Office_Street_name_number__c = 'test',Branch_Office_Country__c= a1.IATA_ISO_Country__c,
                                                                                Branch_Office_Phone__c = 'test@istes.test', ISSP_AMS_Legal_Status__c='Association');

        insert accr;

        oscar.Name= '12345';
        oscar.Account__c = a1.Id;
        oscar.AMS_Online_Accreditation__c = accr.id;

        update oscar;

        Test.startTest();

        String resultcopyDataToAccount = AMS_OSCAR_Webservice.copyDataToAccount(oscar.Id);

        Test.stopTest();
    }

    static testMethod void test_createNEWChangeCode() {
        
        setup();
        
        Test.startTest();

        String resultcreateChangeCodeNEW = AMS_OSCAR_Webservice.createChangeCodeNEW(oscar.Id);

        Test.stopTest();
    }

    static testMethod void test_createSidraLite() {
        
        setup();
        
        Test.startTest();

        String resultcreateSIDRALiteERROR = AMS_OSCAR_Webservice.createSIDRALite(oscar.Id);
        String resultcreateSIDRALiteSUCCESS = AMS_OSCAR_Webservice.createSIDRALite(oscar6.Id);

        Test.stopTest();
    }

    static testMethod void test_createCommissionerCase() {
        
        setup();
        
        Test.startTest();

        String resultcreateCommissionerCaseERROR = AMS_OSCAR_Webservice.createCommissionerCase(oscar.Id);
        String resultcreateCommissionerCaseSUCCESS = AMS_OSCAR_Webservice.createCommissionerCase(oscar6.Id);

        Test.stopTest();
    }

    static testMethod void test_createFSRelease() {
        
        setup();
        
        Test.startTest();

        String resultFSReleaseERROR = AMS_OSCAR_Webservice.createFSReleaseCase(oscar.Id);
        System.assert(resultFSReleaseERROR.contains('Could not find a the Oscar Communication case related to this OSCAR.'));

        String resultFSReleaseSUCCESS = AMS_OSCAR_Webservice.createFSReleaseCase(oscar6.Id);
        System.assert(Id.valueOf(resultFSReleaseSUCCESS).getSObjectType() == Case.SObjectType, 'FS Release: did not create case');

        Test.stopTest();
    }

    static testMethod void test_generateCertificates() {
        
        setup();

        AmazonRestTest.createCredentials(AMS_CertificateHelper.CREDENTIAL_NAME);
        AmazonRestTest.createCredentials('RecycleBin');
        
        Test.startTest();

        String resultgenerateCertificates = AMS_OSCAR_Webservice.generateCertificates(oscar6.Id, oscar.Account__c);
        System.debug(loggingLevel.ERROR, '____ [cls AMS_OSCAR_WebserviceTest - test_generateCertificates] resultgenerateCertificates - ' + resultgenerateCertificates);

        Test.stopTest();
    }

}