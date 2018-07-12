@isTest
public class EF_MaterialLineItemTriggerTest {

    @testSetup 
    static void setup() {
        
        User u = EF_TestDataFactory.getEfProfileAndRole(0, 2);
        EF_TestDataFactory.createCustomSettings();
        
        System.runAs(u){
            
            List <Account> accList = new List <Account> ();
            
            //create account 
            Account client = new Account(
                Name='Test Account client',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 11',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new client needed'
                );
            
            accList.add(client);
    
            //create account 
            Account client2 = new Account(
                Name='Test Account client 2',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 11',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new client needed'
                );
            
            accList.add(client2);
    
            //create account
            Account client3 = new Account(
                Name='Test Account client 3',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Client',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 11',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new client needed'
                );
            
            accList.add(client3);
    
            //create account 
            Account customer = new Account(
                Name='Test Account customer',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
                Sector__c = 'IATA Supplier',
                Category__c = 'ANSP',
                EF_type__c = 'E&F Operator',
                EF_Status__c = 'Active',
                EF_SubStatus__c = 'Chapter 11',
                EF_Effective_Date__c = Date.today(),
                Reason_for_creation__c = 'new customer needed'
                );
            
            accList.add(customer);
            insert accList;
                    
            //create contract
            Contract contract = new Contract (
                accountId = client.Id,
                CCF_Number__c = '1',
                Budget_Section__c ='aaaa',
                CCF_Amount__c = 250000,
                ContractTerm = 12,
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'EF_Client_Agreement'),
                StartDate = Date.today(),
                Type__c ='Revenue',
                EF_Status__c = 'Active',
                EF_Billing_Currency__c = 'AED',
                EF_Data_Currency__c = 'AED',
                EF_Payment_Currency__c = 'AED'
                );
            insert contract;
    
            //create contract
            Contract contract2 = new Contract (
                accountId = client2.Id,
                CCF_Number__c = '1',
                Budget_Section__c ='aaaa',
                CCF_Amount__c = 250000,            
                ContractTerm = 12,
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'EF_Client_Agreement'),
                StartDate = Date.today(),
                Type__c ='Revenue',
                EF_Status__c = 'Active'
                );
            insert contract2;
            
            List <Product2> prodList = new List <Product2> ();
            Product2 prd = new Product2 (
                Name = 'Test product 1',
                Product_Segment__c = 'TBA',
                Product_Marketing_Manager__c = 'Eve-Marie Morgo',
                Family = 'Accreditation',
                Line_of_Business__c = 'Advertising'            
            );                
            
            prodList.add(prd);    
                
            Product2 prd2 = new Product2 (
                Name = 'Test product 2',
                Product_Segment__c = 'TBA',
                Product_Marketing_Manager__c = 'Eve-Marie Morgo',
                Family = 'Accreditation',
                Line_of_Business__c = 'Advertising'            
            );                
            
            prodList.add(prd2);
            
            Product2 prd3 = new Product2 (
                Name = 'Test product 3',
                Product_Segment__c = 'TBA',
                Product_Marketing_Manager__c = 'Eve-Marie Morgo',
                Family = 'Accreditation',
                Line_of_Business__c = 'Advertising'            
            );                
            
            prodList.add(prd3);
            insert prodList;
            
    
            EF_Related_Records__c loc = new EF_Related_Records__c (
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Location'),
                name = 'Main'               
            );
            
            insert loc;
                    
            EF_Location_Currency__c locCurr = new EF_Location_Currency__c (
                EF_Billing_Currency__c = 'AED',
                Contract__c = contract.id,
                Location_ID__c = loc.id                
            );
            
            insert locCurr;                               
            
            EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c (
                EF_Location_ID__c = loc.id,
                Contract__c = contract.id,
                Data_Currency__c = 'AED',            
                Payment_Method__c = 'Credit Card',
                Location_Code__c = '1234',
                Airline__c = customer.id,
                EF_Status__c = 'Active',
                Billing_Currency__c = 'AED',
                Payment_Currency__c = 'AED',
                //Payment_Terms__c = '30 days after invoice date',
                Invoice_Distribution_Method__c = 'Electronic Via Platform'           
            );
            
            insert rel;    
            
            List <EF_Material_Line_Item__c> mliList = new List <EF_Material_Line_Item__c> ();
            EF_Material_Line_Item__c mli = new EF_Material_Line_Item__c(
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Contract_Line_Item'),
                Contract__c = contract.id,
                EF_Material__c = prd.id            
                );
            
            mliList.add(mli);
            
            EF_Material_Line_Item__c mli2 = new EF_Material_Line_Item__c(
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Contract_Line_Item'),
                Contract__c = contract.id,
                EF_Material__c = prd3.id            
                );
            
             mliList.add(mli2);
            insert mliList;
            
        }
        
    }

    @isTest static void EF_MaterialLineItemTrigger_InsertMaterialLineItem() {
        
        EF_Billing_Agreement__c rel = [Select id From EF_Billing_Agreement__c where Location_Code__c = '1234'];
        Product2 prd = [Select id From Product2 where Name = 'Test product 1'];
        
        EF_Material_Line_Item__c mli = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd.id            
            );
        
        try {
            Test.startTest();
                insert mli;
            Test.stopTest();
            System.assert(true);               
        } catch(System.DmlException e) {
            System.assert(false);
        }        
    }
    
    @isTest static void EF_MaterialLineItemTrigger_InsertMaterialLineItemProductDoesntExistsOnContract() {
        EF_Billing_Agreement__c rel = [Select id From EF_Billing_Agreement__c where Location_Code__c = '1234'];
        Product2 prd = [Select id From Product2 where Name = 'Test product 2'];
        
        EF_Material_Line_Item__c mli = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd.id
            );
        
        try {
            Test.startTest();
                insert mli;
            Test.stopTest();
            System.assert(false);                                   
        } catch(System.DmlException e) {
            System.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Can\'t select E&F Material not present in the related Contract: []', e.getMessage());
        }        
    }


    @isTest static void EF_MaterialLineItemTrigger_InsertMaterialLineItemUpdateToWrongMaterial() {        
        EF_Billing_Agreement__c rel = [Select id From EF_Billing_Agreement__c where Location_Code__c = '1234'];
        Product2 prd = [Select id From Product2 where Name = 'Test product 1'];
        
        Product2 prd2 = [Select id From Product2 where Name = 'Test product 2'];
                
        EF_Material_Line_Item__c mli = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd.id
            );
        
        try {
            Test.startTest();
                insert mli;
            
                mli.EF_Material__c = prd2.id;
                update mli;            
            Test.stopTest();
            System.assert(false);               
        } catch(System.Exception e) {
            System.assert(e.getMessage().contains('Can\'t select E&F Material not present in the related Contract'));
        }        
    }
    
    @isTest static void EF_MaterialLineItemTrigger_InsertMaterialLineItemUpdateToGoodMaterial() {        
        EF_Billing_Agreement__c rel = [Select id From EF_Billing_Agreement__c where Location_Code__c = '1234'];
        Product2 prd = [Select id From Product2 where Name = 'Test product 1'];
        
        Product2 prd3 = [Select id From Product2 where Name = 'Test product 3'];
                
        EF_Material_Line_Item__c mli = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd.id
            );
        
        try {
            Test.startTest();
                insert mli;
            
                mli.EF_Material__c = prd3.id;
                update mli;            
            Test.stopTest();
            System.assert(true);               
        } catch(System.Exception e) {
            System.assert(false, 'An unexpected exception has occurred : ' + e.getMessage());
        }        
    }    
    
    @isTest static void EF_MaterialLineItemTrigger_InsertMaterialLineItemAddLineWithWrongMaterial() {        
        EF_Billing_Agreement__c rel = [Select id From EF_Billing_Agreement__c where Location_Code__c = '1234'];
        Product2 prd = [Select id From Product2 where Name = 'Test product 1'];
        
        Product2 prd2 = [Select id From Product2 where Name = 'Test product 2'];
                
        EF_Material_Line_Item__c mli = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd.id
            );
        
        EF_Material_Line_Item__c mli2 = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd2.id
            );        
        
        try {
            Test.startTest();
                insert mli;           
                insert mli2;
            Test.stopTest();
            System.assert(false);               
        } catch(System.Exception e) {
            System.assert(e.getMessage().contains('Can\'t select E&F Material not present in the related Contract'));
        }        
    }
    
    @isTest static void EF_MaterialLineItemTrigger_InsertMaterialLineItemInsertAndDeleteSeveralLines() {        
        EF_Billing_Agreement__c rel = [Select id, Contract__c From EF_Billing_Agreement__c where Location_Code__c = '1234'];
        Product2 prd = [Select id From Product2 where Name = 'Test product 1'];
        
        Product2 prd3 = [Select id From Product2 where Name = 'Test product 3'];
        
        EF_Material_Line_Item__c mli = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd.id
            );
        
        EF_Material_Line_Item__c mli2 = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd3.id
            );
        
        List<EF_Material_Line_Item__c> lines = new List<EF_Material_Line_Item__c>();
        
        lines.add(mli);
        lines.add(mli2);
        
        try {
            Test.startTest();
                insert lines;            
                delete lines;
            Test.stopTest();
            System.assert(true);               
        } catch(System.Exception e) {
            System.assert(false, 'An unexpected exception has occurred : ' + e.getMessage());
        }        
    }       
    
    @isTest static void EF_MaterialLineItemTrigger_InsertMaterialLineItemInsertSeveralLinesOneHasWrongMaterial() {        
        EF_Billing_Agreement__c rel = [Select id From EF_Billing_Agreement__c where Location_Code__c = '1234'];
        Product2 prd = [Select id From Product2 where Name = 'Test product 1'];
        Product2 prd2 = [Select id From Product2 where Name = 'Test product 2'];        
        Product2 prd3 = [Select id From Product2 where Name = 'Test product 3'];
                
        EF_Material_Line_Item__c mli = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd.id
            );
        
        EF_Material_Line_Item__c mli2 = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd2.id
            );
                
        EF_Material_Line_Item__c mli3 = new EF_Material_Line_Item__c(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Material_Line_Item__c', 'Relationship_Line_Item'),
            EF_Relationship__c = rel.id,
            EF_Material__c = prd3.id
            );
        
        List<EF_Material_Line_Item__c> lines = new List<EF_Material_Line_Item__c>();
        
        lines.add(mli);
        lines.add(mli2);
        lines.add(mli3);
        
        try {
            Test.startTest();
                insert lines;            
            Test.stopTest();
            System.assert(false);               
        } catch(System.Exception e) {
            System.assert(e.getMessage().contains('Can\'t select E&F Material not present in the related Contract'));
        }        
    }           
}