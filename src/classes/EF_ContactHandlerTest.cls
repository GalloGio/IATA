@isTest
private class EF_ContactHandlerTest {

    @testSetup
    static void setup()
    {
        User u = EF_TestDataFactory.getEfProfileAndRole(0, 4);
        EF_TestDataFactory.createCustomSettings();

        //System.runAs(u){
            EF_TestDataFactory.createBaseData();
        //}
    }

    @isTest static void testInactiveEFContact()
    {
        Contract contract = [select Id, AccountId, Account.Name, EF_Allow_Billing_Agreements__c from Contract where Account.Name = 'Test Account Client'];
        Account customer = [select Id, Name  from Account where Name = 'Test Account customer'];
        Account client = [select Id, Name from Account where Name = 'Test Account client'];

        contract.EF_Allow_Billing_Agreements__c = 'Allowed';
        update contract;

        Contact cont = new Contact();
        cont.RecordTypeId = schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        cont.LastName='UnitTestContactSomething';
        cont.AccountId = client.Id;
        cont.EF_Status__c='Active';
        insert cont;

        EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c();
        rel.Client__c = client.Id;
        rel.Airline__c = customer.Id;
        rel.Contract__c = contract.Id;
        rel.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
        rel.EF_Status__c='Active';
        insert rel;

        EF_Contact_Relationship__c cr = new EF_Contact_Relationship__c ();
        cr.Contact__c = cont.Id;
        cr.EF_Airline_Billing_Agreement__c = rel.Id;
        cr.Status__c='Active';
        cr.EF_Role__c='Operations';
        insert cr;

        EF_Contact_EF_Contract__c cc = new EF_Contact_EF_Contract__c();
        cc.EF_Contact__c = cont.Id;
        cc.EF_Contract__c = contract.Id;
        cc.EF_Status__c='Active';
        cc.Role__c='Operations';
        insert cc;

        EF_Critical_Field_Notification__c criticalFields = new EF_Critical_Field_Notification__c();
        criticalFields.name = 'test';
        criticalFields.Airline_Billing_Agreement_Fields__c = 'Bill_To__c,Ship_To__c,Payer__c,Sold_To__c';
        criticalFields.Account_Airline_Fields__c = 'EF_Status__c,EF_Legacy_Code__c,EF_Airline_ID__c,EF_SIS_Code__c,EF_SIS_Designator__c,EF_SIS_Code_Verified__c';
        criticalFields.Account_Client_Fields__c = 'Legal_name__c,EF_SIS_Code__c,EF_SIS_Designator__c,EF_SIS_Code_Verified__c,EF_Status__c';
        criticalFields.Contract_Fields__c = 'EF_Group_Code__c,EF_Admin_Fee__c,EF_Payment_Terms__c';
        criticalFields.Contact_Fields__c = 'EF_Signatory__c,Email,FirstName,LastName,EF_Status__c';
        insert criticalFields;

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
