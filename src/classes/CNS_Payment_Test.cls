@isTest
public class CNS_Payment_Test {

    @isTest
    public static void test1() {

        Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Westeros',
            ISO_Code__c = 'TS');
        insert isoc;

        Account acc1 = new Account(
            RecordTypeId = agencyRT,
            Name = 'Stardust Travels',
            Sector__c = 'Travel Agent',
            Category__c = 'IATA Passenger Sales Agent',
            IATA_ISO_Country__c = isoc.id,
            Reason_for_creation__c = 'Account is missing');
        insert acc1;

        Contact c1 = new Contact(
            AccountId = acc1.id,
            FirstName = 'Name',
            Lastname = 'LastName',
            Email = 'unique@email.com',
            Community__c = 'ISS Customer Portal',
            Phone = '3424322343');
        insert c1;

        User u = new User(
            Alias = 'dsfsdfds',
            Email = c1.email,
            Emailencodingkey = 'UTF-8',
            Firstname = c1.firstName,
            Lastname = c1.lastname,
            Languagelocalekey = 'en_US',
            Localesidkey = 'en_US',
            ContactId = c1.Id,
            Timezonesidkey = 'Asia/Dubai',
            Username = c1.email + 'dfgdf',
            PortalRole = 'Manager',
            CommunityNickname = 'nickname000',
            ProfileId = ISSP_Constant.TEST_User_ProfileID,
            IsActive = true);
        insert u;


        CNS_Payment__c cs = new CNS_Payment__c(
            Name = 'test',
            PROD_AccessKey__c = 'test',
            PROD_ProfileId__c = 'test',
            PROD_SecurityKey__c = 'test',
            PROD_SecurityKey_2__c = 'test',
            PROD_URL__c = 'test',
            QA_AccessKey__c = 'test',
            QA_ProfileId__c = 'test',
            QA_SecurityKey__c = 'test',
            QA_SecurityKey_2__c = 'test',
            QA_URL__c = 'test');
        insert cs;

        System.RunAs(u) {
            CNS_Payment cspay = new CNS_Payment();
            cspay.calculatedSignature = 'test';
            cspay.getListServiceType();
            cspay.machash('val', 'key');
            cspay.buildDataToSign();
        }
    }
    
}