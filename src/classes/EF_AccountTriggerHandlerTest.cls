/**
 */
@isTest
private class EF_AccountTriggerHandlerTest {

    @testSetup
    static void setup() {
        User CSpecialist = EF_TestDataFactory.getEfProfileAndRole(1, 5);
        User CSpecialist2 = EF_TestDataFactory.getEfProfileAndRole(1, 2);
        User CSpecialist3 = EF_TestDataFactory.getEfProfileAndRole(1, 3);
        User runningUser =  EF_TestDataFactory.getEfProfileAndRole(0, 4);
        EF_TestDataFactory.createCustomSettings();
        EF_TestDataFactory.skipContractCreationValidationRule();

        System.runAs(runningUser) {
            //create parent client account
            Account parentClient = new Account(
                Name = 'Test Account Parent Client',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'), // Standard Account
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 11',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new client needed',
                EF_Client_Services_Specialist__c = CSpecialist.Id
            );

            insert parentClient;


            //create chlid client and customer accounts
            List<Account> accounts = new List<Account>();

            Account childClient = new Account(
                Name = 'Test Account Child Client',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others'),
                ParentId = parentClient.Id,
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 11',
                EF_Effective_Date__c = Date.today(),
                EF_SIS_Code__c = 'test',
                EF_SIS_Designator__c = 'te',
                EF_SIS_Code_Verified__c = true,
                Reason_for_creation__c = 'new client needed',
                EF_Client_Services_Specialist__c = CSpecialist2.Id
            );


            Account customer1 = new Account(
                Name = 'Test Account customer 1',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Operator',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 11',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new customer needed',
                EF_Client_Services_Specialist__c = CSpecialist3.Id,
                EF_SIS_Code__c = 'test',
                EF_SIS_Designator__c = 'te',
                EF_SIS_Code_Verified__c = true
            );

            Account customer2 = new Account(
                Name = 'Test Account customer 2',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Operator',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 11',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new customer needed',
                EF_Client_Services_Specialist__c = CSpecialist.Id,
                EF_SIS_Code__c = 'test',
                EF_SIS_Designator__c = 'te',
                EF_SIS_Code_Verified__c = true
            );

            accounts.add(childClient);
            accounts.add(customer1);
            accounts.add(customer2);
            try {
                insert accounts;
            } catch (Exception e) {
                System.debug('##### error acounts :' + e);
            }

            //create contracts
            List<Contract> contracts = new List<Contract>();

            Contract parentContract = new Contract (
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'EF_Client_Agreement'),
                accountId = parentClient.Id,
                ContractTerm = 12,
                EF_Allow_Billing_Agreements__c = 'Allowed',
                StartDate = Date.today(),
                Type__c = 'Revenue',
                EF_Status__c = 'Active'
            );

            Contract childContract = new Contract (
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'EF_Client_Agreement'),
                accountId = childClient.Id,
                CCF_Number__c = '1',
                Budget_Section__c = 'aaaa',
                CCF_Amount__c = 250000,
                ContractTerm = 12,
                EF_Allow_Billing_Agreements__c = 'Allowed',
                StartDate = Date.today(),
                Type__c = 'Revenue',
                EF_Status__c = 'Active'
            );

            contracts.add(parentContract);
            contracts.add(childContract);
            try {
                insert contracts;
            } catch (Exception e) {
                System.debug('##### error contracts :' + e);
            }

            Product2 prod = EF_TestDataFactory.createEFProduct();

            //Create contacts
            List<Contact> contacts = new List<Contact>();

            Contact customer1Contact = new Contact(
                AccountId = customer1.Id,
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'),
                firstname = 'James',
                lastname = 'Bond',
                EF_Status__c = 'Active',
                email = 'customer1contact@testtest.com'
            );

            Contact customer2Contact = new Contact(
                AccountId = customer2.Id,
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'),
                firstname = 'James',
                lastname = 'Bond',
                EF_Status__c = 'Active',
                email = 'customer2contact@testtest.com'
            );

            contacts.add(customer1Contact);
            contacts.add(customer2Contact);
            try {
                insert contacts;
            } catch (Exception e) {
                System.debug('##### error contacts :' + e);
            }

            //Insert Material Line Items on Contract
            List <EF_Material_Line_Item__c> mliList = new List <EF_Material_Line_Item__c> ();
            //Insert contacts to Contracts
            List <EF_Contact_EF_Contract__c> ccontactList = new List <EF_Contact_EF_Contract__c> ();

            for (Contract c : contracts) {
                EF_Material_Line_Item__c mliC = new EF_Material_Line_Item__c();
                mliC.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Contract_Line_Item');
                mliC.Contract__c = c.Id;
                mliC.EF_Status__c = 'Active';
                mliC.EF_Material__c = prod.Id;
                mliList.add(mliC);

                EF_Contact_EF_Contract__c cc = new EF_Contact_EF_Contract__c ();
                cc.EF_Contact__c = customer1Contact.Id;
                cc.EF_Contract__c = c.Id;
                cc.Role__c = 'Operations';
                cc.EF_Status__c = 'Active';
                ccontactList.add(cc);
            }

            try { //insert mliList;
                insert ccontactList;
            } catch (Exception e) {System.debug('#### error inserting materials or contacts on contract ' );}

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
            try {
                insert billingAgreements;
            } catch (Exception e) {
                System.debug('##### error billing agreements :' + e);
            }

            //Insert Material Line Items on Contract
            List <EF_Material_Line_Item__c> mliListBA = new List <EF_Material_Line_Item__c> ();

            //insert Contacts related to BA
            List<EF_Contact_Relationship__c> contRel = new List<EF_Contact_Relationship__c>();

            for (EF_Billing_Agreement__c ba : billingAgreements) {
                EF_Material_Line_Item__c mliC = new EF_Material_Line_Item__c();
                mliC.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item');
                mliC.EF_Relationship__c = ba.Id;
                mliC.EF_Status__c = 'Active';
                mliC.EF_Material__c = prod.Id;
                mliListBA.add(mliC);

                EF_Contact_Relationship__c rel1 = new EF_Contact_Relationship__c();
                rel1.Contact__c = customer1Contact.Id;
                rel1.EF_Airline_Billing_Agreement__c = ba.Id;
                rel1.Status__c = 'Active';
                rel1.EF_Role__c = 'Operations';
                contRel.add(rel1);

            }

            try {
                insert mliListBA;
                //System.debug('#### materials for BA created? ' +mliListBA);
                insert contRel;

                // once BA material line items have been created, we can activate the billing agreements
                parentBillingAgreement.EF_Status__c = 'Active';
                childBillingAgreement.EF_Status__c = 'Active';

                update billingAgreements;

            } catch ( Exception e) {System.debug('#### what?? ' + e);}

        }

    }

    static testMethod void testHandleAfterUpdate() {

        Account parent = [select Id, Name, EF_Status__c from Account where Name = 'Test Account Parent Client'];

        parent.EF_Status__c = 'Inactive';

        Test.startTest();
        update parent;
        Test.stopTest();

        List<Contract> contracts = [select Id, EF_Status__c from Contract];
        for (Contract contract : contracts) {
            System.assertEquals(contract.EF_Status__c, 'Inactive');
        }

        List<EF_Billing_Agreement__c> billingAgreements = [select Id, EF_Status__c from EF_Billing_Agreement__c];
        for (EF_Billing_Agreement__c billingAgreement : billingAgreements) {
            System.assertEquals(billingAgreement.EF_Status__c, 'Inactive');
        }

        List<EF_Material_Line_Item__c> materialLineItems = [select Id, EF_Status__c from EF_Material_Line_Item__c ];
        for (EF_Material_Line_Item__c materialLineItem : materialLineItems) {
            System.assertEquals(materialLineItem.EF_Status__c, 'Inactive');
        }

        List <EF_Contact_EF_Contract__c> ccontactList = [select Id, EF_Status__c from EF_Contact_EF_Contract__c ];
        for (EF_Contact_EF_Contract__c cc : ccontactList) {
            System.assertEquals(cc.EF_Status__c, 'Inactive');
        }
        List <EF_Contact_Relationship__c> ccontactBAList = [select Id, Status__c from EF_Contact_Relationship__c ];
        for (EF_Contact_Relationship__c cc : ccontactBAList) {
            System.assertEquals(cc.Status__c, 'Inactive');
        }

        Account child = [select Id, Name, EF_Status__c from Account where Name = 'Test Account Child Client'];
        System.assertEquals(child.EF_Status__c, 'Inactive');


    }
}