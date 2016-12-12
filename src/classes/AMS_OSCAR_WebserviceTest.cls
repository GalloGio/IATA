@isTest
public class AMS_OSCAR_WebserviceTest {

    private static AMS_OSCAR__c oscar;
    private static AMS_OSCAR__c oscar2;
    private static AMS_OSCAR__c oscar3;
    private static AMS_OSCAR__c oscar4;
    private static Account a1;
    private static Account a2;
    private static Account a3;

    private static void setup(){
        
        oscar = new AMS_OSCAR__c(Status__c = 'Reopen', Billing_Document_Number__c = '54321');
        insert oscar;

System.debug('******* oscar: ' + oscar);

        Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        List<Account> accList = new List<Account>();
            a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
            a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Name='Test1 Agency',Short_Name__c='Test1 Agency',BillingCountry='Brazil');
            a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234562',Location_Type__c='HO',Name='Test1 Agency',Short_Name__c='Test1 Agency',Type='IATA Cargo Agent',BillingCountry='Brazil');
        
        accList.add(a1);
        accList.add(a2);
        accList.add(a3);
        insert accList;

        List<AMS_OSCAR__c> oscarList = new List<AMS_OSCAR__c>();

            oscar2 = new AMS_OSCAR__c(Account__c = accList[0].Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
            oscar3 = new AMS_OSCAR__c(Account__c = accList[1].Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
            oscar4 = new AMS_OSCAR__c(Account__c = accList[2].Id, Status__c = 'Reopen', Billing_Document_Number__c = '54321');
        
        oscarList.add(oscar2);
        oscarList.add(oscar3);
        oscarList.add(oscar4);
        insert oscarList;

        Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Active__c = true, /*Change_Code__c = acc.id,MACREVIEW*/ Account__c = a1.id);
        insert aacc;
        Contact co1 = new Contact(AccountId = a3.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = true);
        insert co1;
        Case oscarCase = new Case(Oscar__c = oscar4.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;  
        
    }
    
    @isTest static void test_updateOSCARFields(){
        setup();
        
        
System.debug('******* 2 oscar: ' + oscar);        
        AMS_OSCAR__c oscar1 = [SELECT Id, Status__c, Billing_Document_Number__c FROM AMS_OSCAR__c where id = :oscar.Id limit 1];
        
        List<String> fieldApiName = new List<String>{'Status__c', 'Billing_Document_Number__c'};
        List<String> fieldValue = new List<String>{'Open', '12345'};
        
        
        String result = AMS_OSCAR_Webservice.updateFormFields(fieldApiName, fieldValue, oscar1.Id);
        System.debug('****************** result: '+result);
        
        
        oscar = [SELECT Id, Status__c, Billing_Document_Number__c FROM AMS_OSCAR__c WHERE Id = :oscar1.Id limit 1];
        Test.startTest();
        
         System.assertEquals(oscar.Billing_Document_Number__c, '12345');
        //System.assertEquals(oscar.Billing_Document_Number__c, '54321');
        /**
            REVIEW - the Assert below is failing!
        */
        //System.assertEquals(oscar.Status__c, 'Open');

        /**
            REVIEW - add Asserts to calls below!
        */
        String resultIFAPFromOSCAR = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar.Id);
        String resultIFAPFromOSCAR2 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar2.Id);
        String resultIFAPFromOSCAR3 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar3.Id);
        String resultIFAPFromOSCAR4 = AMS_OSCAR_Webservice.createIFAPFromOSCAR(oscar4.Id);
        String resultcreateAMLCase = AMS_OSCAR_Webservice.createAMLCase(oscar.Id);
        String resultcreateAMLCase4 = AMS_OSCAR_Webservice.createAMLCase(oscar4.Id);
        String resultcopyDataToAccount = AMS_OSCAR_Webservice.copyDataToAccount(oscar.Id);
        String resultcreateChangeCodeNEW = AMS_OSCAR_Webservice.createChangeCodeNEW(oscar.Id);

        Test.stopTest();
    }

    static testMethod void vr_tests() {
        setup();

        Test.startTest();
        String resultFSRelease = AMS_OSCAR_Webservice.createFSReleaseCase(oscar4.id);
        Test.stopTest();

        System.assert(Id.valueOf(resultFSRelease).getSObjectType() == Case.SObjectType, 'Returned error');
    }

}