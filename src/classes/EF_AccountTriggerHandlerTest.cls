/**
 */
@isTest
private class EF_AccountTriggerHandlerTest {

    @testSetup
    static void setup() {
        User u = EF_TestDataFactory.getEfProfileAndRole(0,2);
        EF_TestDataFactory.createCustomSettings();

        System.runAs(u){
            //create parent client account
            Account parentClient = new Account(
                Name='Test Account Parent Client',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId(),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 7',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new client needed'
                );

            insert parentClient;


            //create chlid client and customer accounts
            List<Account> accounts = new List<Account>();

            Account childClient = new Account(
                Name='Test Account Child Client',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId(),
                ParentId = parentClient.Id,
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 7',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new client needed'
                );

            Account customer1 = new Account(
                Name='Test Account customer 1',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId(),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Operator',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 7',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new customer needed'
                );

            Account customer2 = new Account(
                Name='Test Account customer 2',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId(),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Operator',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 7',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new customer needed'
                );

            accounts.add(childClient);
            accounts.add(customer1);
            accounts.add(customer2);
            try{
                insert accounts;
            }
            catch(Exception e){
                System.debug('hop :'+e);
            }

            //create contracts
            List<Contract> contracts = new List<Contract>();

            Contract parentContract = new Contract (
                RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('E&F Client Agreement').getRecordTypeId(),
                accountId= parentClient.Id,
                ContractTerm=12,
                EF_Allow_Billing_Agreements__c = 'Allowed',
                StartDate= Date.today(),
                Type__c='Revenue',
                EF_Status__c = 'Active'
                );

            Contract childContract = new Contract (
                RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('E&F Client Agreement').getRecordTypeId(),
                accountId= childClient.Id,
                CCF_Number__c= '1',
                Budget_Section__c='aaaa',
                CCF_Amount__c=250000,
                ContractTerm=12,
                EF_Allow_Billing_Agreements__c = 'Allowed',
                StartDate= Date.today(),
                Type__c='Revenue',
                EF_Status__c = 'Active'
                );

            contracts.add(parentContract);
            contracts.add(childContract);
            insert contracts;

            //Create billing agreements
            List<EF_Billing_Agreement__c> billingAgreements = new List<EF_Billing_Agreement__c>();

            EF_Billing_Agreement__c parentBillingAgreement = new EF_Billing_Agreement__c(
                Contract__c = parentContract.Id,
                Airline__c = customer1.Id,
                EF_Status__c = 'Active'
            );

            EF_Billing_Agreement__c childBillingAgreement = new EF_Billing_Agreement__c(
                Contract__c = childContract.Id,
                Airline__c = customer2.Id,
                EF_Status__c = 'Active'
            );

            billingAgreements.add(parentBillingAgreement);
            billingAgreements.add(childBillingAgreement);
            insert billingAgreements;


            //Create contacts
            List<Contact> contacts = new List<Contact>();

            Contact customer1Contact = new Contact(
                AccountId = customer1.Id,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
                firstname = 'James',
                lastname = 'Bond',
                EF_Status__c = 'Active',
                email='customer1contact@testtest.com'
            );

            Contact customer2Contact = new Contact(
                AccountId = customer2.Id,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
                firstname = 'James',
                lastname = 'Bond',
                EF_Status__c = 'Active',
                email='customer2contact@testtest.com'
            );

            contacts.add(customer1Contact);
            contacts.add(customer2Contact);
            insert contacts;

            //Create contact billing agreement relationships
            List<EF_Contact_Relationship__c> relationships = new List<EF_Contact_Relationship__c>();

            EF_Contact_Relationship__c relationship1= new EF_Contact_Relationship__c(
                Contact__c = customer1Contact.Id,
                EF_Airline_Billing_Agreement__c = parentBillingAgreement.Id,
                Status__c = 'Active'
            );

            EF_Contact_Relationship__c relationship2 = new EF_Contact_Relationship__c(
                Contact__c = customer2Contact.Id,
                EF_Airline_Billing_Agreement__c = childBillingAgreement.Id,
                Status__c = 'Active'
            );

            relationships.add(relationship1);
            relationships.add(relationship2);
            insert relationships;
        }



    }

    static testMethod void testHandleAfterUpdate() {
        Account parent = [select Id, Name, EF_Status__c from Account where Name = 'Test Account Parent Client'];

        parent.EF_Status__c = 'Inactive';

        Test.startTest();
        update parent;
        Test.stopTest();

        Account child = [select Id, Name, EF_Status__c from Account where Name = 'Test Account Child Client'];
        System.assertEquals(child.EF_Status__c, 'Inactive');

        List<Contract> contracts = [select Id, EF_Status__c from Contract];
        for(Contract contract : contracts){
            System.assertEquals(contract.EF_Status__c, 'Inactive');
        }

        List<EF_Billing_Agreement__c> billingAgreements = [select Id, EF_Status__c from EF_Billing_Agreement__c];
        for(EF_Billing_Agreement__c billingAgreement : billingAgreements){
            System.assertEquals(billingAgreement.EF_Status__c, 'Inactive');
        }

        List<EF_Contact_Relationship__c> relationships = [select Id, Status__c from EF_Contact_Relationship__c];
        for(EF_Contact_Relationship__c relationship : relationships){
            System.assertEquals(relationship.Status__c, 'Inactive');
        }
        
    }
}