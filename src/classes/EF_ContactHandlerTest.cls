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
        rel.Status__c='Active';
        insert rel;
        
        EF_Contact_Relationship__c cr = new EF_Contact_Relationship__c ();
        cr.Contact__c = cont.Id;
        cr.EF_Airline_Billing_Agreement__c = rel.Id;
        cr.Status__c='Active';
        cr.Role__c='Operations';
        insert cr;
        
        Test.startTest();
            cont.EF_Status__c='Inactive';
            update cont;
        Test.stopTest();
        
        EF_Contact_Relationship__c crAfter = [select Id, Status__c, Contact__c from EF_Contact_Relationship__c where Id=:cr.Id limit 1];
        System.assertEquals('Inactive', crAfter.Status__c);
        
        
        
    }
        


}