@isTest
private class EF_ContactHandlerTest {

    @testSetup
    static void setup()
    {
        User u = EF_TestDataFactory.getEfProfileAndRole(0, 2);
        // EF_TestDataFactory.createCustomSettings();

        System.runAs(u){
            EF_TestDataFactory.createBaseData();
        }
    }

    @isTest static void testInactiveEFContact()
    {
        User u = [SELECT Id FROM User WHERE Username='efUnit@test.ch2' LIMIT 1];
        System.runAs(u) {
        Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
        // Account customer = [select Id, Name  from Account where Name = 'Test Account customer'];
        Account client = [select Id, Name from Account where Name = 'Test Account client'];

        contract.EF_Allow_Billing_Agreements__c = 'Allowed';
        update contract;

        Contact cont = new Contact();
        cont.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        cont.LastName='UnitTestContactSomething';
        cont.FirstName='Name';
            cont.Phone='555-fakephone';
        cont.AccountId = client.Id;
        cont.EF_Status__c='Active';
        insert cont;

        List<EF_Billing_Agreement__c> lsBillingAgreements = [SELECT Id, Data_Currency__c FROM EF_Billing_Agreement__c WHERE Contract__c =:contract.Id];

        EF_Contact_Relationship__c cr = new EF_Contact_Relationship__c ();
        cr.Contact__c = cont.Id;
        cr.EF_Airline_Billing_Agreement__c = lsBillingAgreements[0].Id;
        cr.Status__c='Active';
        cr.EF_Role__c='Operations';
        insert cr;

        EF_Contact_EF_Contract__c cc = new EF_Contact_EF_Contract__c();
        cc.EF_Contact__c = cont.Id;
        cc.EF_Contract__c = contract.Id;
        cc.EF_Status__c='Active';
        cc.Role__c='Operations';
        insert cc;

        Test.startTest();
            cont.EF_Status__c='Inactive';
            cont.EF_Signatory__c=true;
            update cont;
        Test.stopTest();

        EF_Contact_Relationship__c crAfter = [select Id, Status__c, Contact__c from EF_Contact_Relationship__c where Id=:cr.Id limit 1];
        System.assertEquals('Inactive', crAfter.Status__c);

        EF_Contact_EF_Contract__c ccAfter = [select Id, EF_Status__c, EF_Contact__c from EF_Contact_EF_Contract__c where Id=:cc.Id limit 1];
        System.assertEquals('Inactive', ccAfter.EF_Status__c);

    }
    }

}