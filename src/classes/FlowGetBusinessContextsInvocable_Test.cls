@isTest
public class FlowGetBusinessContextsInvocable_Test {
    
    @testSetup static void generateTestData(){
        
        //User
        User u = TestDataGenerator.generateUser('System Administrator', true);
        
        System.runAs(u){ // -> preventing mixed dml exception
            
            //permissions
            
            //PermissionSet : must exist in org (Name = 'E_F_Account_Flow_Creation')
            PermissionSet pS = [SELECT Id FROM PermissionSet WHERE Name = 'E_F_Account_Flow_Creation'][0];
            //PermissionSetAssignment
            PermissionSetAssignment pSA = new PermissionSetAssignment(PermissionSetId = pS.Id, AssigneeId = u.Id);
            insert pSA;
            //CustomPermission : must exist in org (MasterLabel = 'E&F Account Flow Creation', DeveloperName = 'E_F_Account_Flow_Creation')
            //SetupEntityAccess : must exist in org (SetupEntityId = c.Id, ParentId = pS.Id)
            
            //metadatas
            
            //Functional_Role__mdt : must exist in org (Label = 'E&F', DeveloperName = 'EAF')
            //Business_Context_Configuration__mdt : must exist in org (Label = 'E&F Account Flow Creation', DeveloperName = 'E_F_Account_Flow_Creation', Account_Create_Permission_Name__c = 'E_F_Account_Flow_Creation')
            //Sales_Area_Mapping__mdt : must exist in org 
            //		(Label = 'E&F Standard', DeveloperName = 'EAF_Standard', Business_Context_Configuration__c = Business_Context_Configuration__mdt.Id)      
            //		(Label = 'E&F India', DeveloperName = 'EAF_India', Business_Context_Configuration__c = Business_Context_Configuration__mdt.Id) 
            		
            //datas
            
            //Account__c
            Account acc = TestDataGenerator.generateAccounts(1, true)[0];
            //Account_Roles__c
            Account_Roles__c accRs = new Account_Roles__c(
                CurrencyIsoCode = 'USD',            
                Name = 'E&F',
                Sector__c = 'Airline'                        
            );
            insert accRs;
            //Account_Role__c
            Account_Role__c accR = new Account_Role__c(
                Account__c = acc.Id,
                Account_Roles__c = accRs.Id,
                CurrencyIsoCode = 'USD',  
                Flow_Status__c = 'Pending' 
            );
            insert accR;
            //Address__c
            Address__c addr = new Address__c(
                Account__c = acc.Id,
                CurrencyIsoCode = 'USD',  
                Postal_Code__c = '51890',
                Street__c = 'rue d\'anger'
            );
            insert addr;
            //Address_Role__c
            Address_Role__c addrR = new Address_Role__c(
                Address__c = addr.Id,
                CurrencyIsoCode = 'USD',  
                Role_Type__c = 'Billing'
            );
            insert addrR;
            //Business_Context__c
            Business_Context__c bC = new Business_Context__c(
                Business_Context__c = 'E&F',
                CurrencyIsoCode = 'USD',  
                Name = 'E&F - E&F Standard',
                Sub_Context__c = 'E&F Standard'
            );
            insert bC;
            //Address_Role_Business_Context__c
            Address_Role_Business_Context__c addrBC = new Address_Role_Business_Context__c(
                Address_Role__c = addrR.Id,
                Business_Context__c = bC.Id
            );
            insert addrBC;
            
        }        
    }
    
    @isTest static void testFlowGetBusinessContextsInvocable(){
        
        List<Account> accs = [SELECT Id FROM Account];
        
        List<FlowGetBusinessContextsInvocable.Request> requests = new List<FlowGetBusinessContextsInvocable.Request>();
        FlowGetBusinessContextsInvocable.Request request = new FlowGetBusinessContextsInvocable.Request();
        request.accountId = accs[0].Id;
        requests.add(request);
        
        List<FlowGetBusinessContextsInvocable.Response> responses = FlowGetBusinessContextsInvocable.execute(requests);
        System.assertEquals(responses[0].businessContextAvailable.contains('E&F'), false); //since accR.Flow_Status__c == 'Pending'
            
    }

}