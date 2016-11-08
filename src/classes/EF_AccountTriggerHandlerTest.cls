/**
 */
@isTest
private class EF_AccountTriggerHandlerTest {

    @testSetup
    static void setup() {
        EF_TestDataFactory.createCustomSettings();
      
            //create parent client account
            Account parentClient = new Account(
                Name='Test Account Parent Client',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId(), // Standard Account
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 7',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new client needed',
                EF_Client_Services_Specialist__c = EF_TestDataFactory.getEfProfileAndRole(1,5).Id
                );

            insert parentClient;


            //create chlid client and customer accounts
            List<Account> accounts = new List<Account>();

            Account childClient = new Account(
                Name='Test Account Child Client',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Others').getRecordTypeId(), 
                ParentId = parentClient.Id,
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 7',
                EF_Effective_Date__c = Date.today(),
                EF_SIS_Code__c = 'test',
                EF_SIS_Designator__c = 'te',
                EF_SIS_Code_Verified__c = true,
                Reason_for_creation__c = 'new client needed',
                EF_Client_Services_Specialist__c = EF_TestDataFactory.getEfProfileAndRole(1,4).Id
                );


            Account customer1 = new Account(
                Name='Test Account customer 1',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Operator').getRecordTypeId(),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Operator',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 7',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new customer needed',
                EF_Client_Services_Specialist__c = EF_TestDataFactory.getEfProfileAndRole(1,3).Id
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
                Reason_for_creation__c = 'new customer needed',
                EF_Client_Services_Specialist__c = EF_TestDataFactory.getEfProfileAndRole(1,2).Id
                );

            accounts.add(childClient);
            accounts.add(customer1);
            accounts.add(customer2);
            try{
                insert accounts;
            }
            catch(Exception e){
                System.debug('##### hop acounts :'+e);
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
          try{
                insert contracts;
            }
            catch(Exception e){
                System.debug('##### hop contracts :'+e);
            }
        
        	Product2 prod = EF_TestDataFactory.createEFProduct();
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
            try{
                insert contacts;
            }
            catch(Exception e){
                System.debug('##### hop contacts :'+e);
            }
        	
        	//Insert Material Line Items on Contract
        	List <EF_Material_Line_Item__c> mliList = new List <EF_Material_Line_Item__c> ();
        	//Insert contacts to Contracts
        	List <EF_Contact_EF_Contract__c> ccontactList = new List <EF_Contact_EF_Contract__c> ();
        
        	for(Contract c: contracts){
                EF_Material_Line_Item__c mliC = new EF_Material_Line_Item__c();
                mliC.RecordTypeId= Schema.SObjectType.EF_Material_Line_Item__c.getRecordTypeInfosByName().get('Contract Line Item').getRecordTypeId();
            	mliC.Contract__c = c.Id;            	
            	mliC.EF_Status__c = 'Active';
                mliC.EF_Material__c= prod.Id;
                mliList.add(mliC); 
                
                EF_Contact_EF_Contract__c cc = new EF_Contact_EF_Contract__c ();
                cc.EF_Contact__c = customer1Contact.Id;
                cc.EF_Contract__c= c.Id;
                cc.Role__c='Operations';
                cc.EF_Status__c='Active';
                ccontactList.add(cc);                
        	}
            
        	insert mliList;
        	insert ccontactList;

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
            try{
                insert billingAgreements;
            }
            catch(Exception e){
                System.debug('##### hop billing agreements :'+e);
            }
        
            //Insert Material Line Items on Contract
        	List <EF_Material_Line_Item__c> mliListBA = new List <EF_Material_Line_Item__c> ();
        	
        	//insert Contacts related to BA
        	List<EF_Contact_Relationship__c> contRel = new List<EF_Contact_Relationship__c>();
        
        	for(EF_Billing_Agreement__c ba: billingAgreements){
                EF_Material_Line_Item__c mliC = new EF_Material_Line_Item__c();
                mliC.RecordTypeId= Schema.SObjectType.EF_Material_Line_Item__c.getRecordTypeInfosByName().get('Relationship Line Item').getRecordTypeId();
            	mliC.EF_Relationship__c = ba.Id;            	
            	mliC.EF_Status__c = 'Active';
                mliC.EF_Material__c= prod.Id;
                mliList.add(mliC);
                
                EF_Contact_Relationship__c rel1= new EF_Contact_Relationship__c();
                rel1.Contact__c = customer1Contact.Id;
                rel1.EF_Airline_Billing_Agreement__c = parentBillingAgreement.Id;
                rel1.Status__c = 'Active';
                rel1.EF_Role__c ='Operations';
            	contRel.add(rel1);
                
        	}
            
        try{insert mliList; insert contRel;}catch( Exception e){System.debug('#### what?? ' +e);}
     
           
    }

    static testMethod void testHandleAfterUpdate() {
        Account parent = [select Id, Name, EF_Status__c from Account where Name = 'Test Account Parent Client'];

        parent.EF_Status__c = 'Inactive';

        Test.startTest();
        update parent;
        Test.stopTest();

        
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

        List<EF_Material_Line_Item__c> materialLineItems = [select Id, EF_Status__c from EF_Material_Line_Item__c ];
        for(EF_Material_Line_Item__c materialLineItem : materialLineItems){
            System.assertEquals(materialLineItem.EF_Status__c, 'Inactive');
        }
        
        List <EF_Contact_EF_Contract__c> ccontactList = [select Id, EF_Status__c from EF_Contact_EF_Contract__c ];
         for(EF_Contact_EF_Contract__c cc : ccontactList){
            System.assertEquals(cc.EF_Status__c, 'Inactive');
        }
        
        Account child = [select Id, Name, EF_Status__c from Account where Name = 'Test Account Child Client'];
        System.assertEquals(child.EF_Status__c, 'Inactive');
		
        

    }
}