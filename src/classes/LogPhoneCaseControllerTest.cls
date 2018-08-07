/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class LogPhoneCaseControllerTest {

    static testMethod void TestFromContact() {
        // CREATE TEST DATA
        
        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;
        
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_fr.Id);
        insert acct_hq;
        
        // Create a new Contact for the Account
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test_LogPhoneCaseController@test.com', AccountId = acct_hq.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // FINISHED CREATING TEST DATA
        
        test.startTest();
            PageReference pageRef = Page.LogPhoneCase;
            pageRef.getParameters().put('ContactId', c.Id);
            Test.setCurrentPage(pageRef);
            
            LogPhoneCaseController controller = new LogPhoneCaseController();
            controller.getCaseLanguageOptions();
            controller.getlstRecordTypes();
            controller.newcase.CaseArea__c = 'Airline Management';
            controller.newcase.Reason1__c = 'Airline data changes';
            controller.newcase.Type_of_customer__c = 'Airline Passenger';
            controller.newcase.BSPCountry__c = 'France';
            controller.SaveAndClose();
          
        test.stopTest(); 
         
            // Test that the case has been created and closed
            list<Case> cases = [SELECT Id, Status FROM Case];
            System.AssertEquals(1, cases.size());
            System.AssertEquals('Closed', cases[0].status);
            
            // empty the cases
            delete cases[0];
            cases = [SELECT Id, Status FROM Case];
            System.AssertEquals(true, cases.isempty());
            
       
    }
    
    static testMethod void TestFromContact2() {
        // CREATE TEST DATA
        
        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;
        
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_fr.Id);
        insert acct_hq;
        
        // Create a new Contact for the Account
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test_LogPhoneCaseController@test.com', AccountId = acct_hq.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // FINISHED CREATING TEST DATA
        
        Test.startTest();
            // test again, log another case and don't close it this time
            PageReference pageRef = Page.LogPhoneCase;
            pageRef.getParameters().put('ContactId', c.Id);
            Test.setCurrentPage(pageRef);
 
            LogPhoneCaseController controller = new LogPhoneCaseController();
            controller.getCaseLanguageOptions();
            controller.getlstRecordTypes();
            controller.getlstCaseTypes();
            controller = new LogPhoneCaseController();
            controller.newcase.CaseArea__c = 'Airline Management';
            controller.newcase.Reason1__c = 'Airline data changes';
            controller.newcase.Type_of_customer__c = 'Airline Passenger';
            controller.newcase.BSPCountry__c = 'France';
            controller.Save();
        Test.stopTest();
            
        // Test that the case has been created and not closed
        list<Case> cases = [SELECT Id, Status FROM Case];
        System.AssertEquals(1, cases.size());
        System.AssertEquals('Open', cases[0].status);
        
        
    }
    
    static testMethod void TestFromCase() {
        // CREATE TEST DATA
        
        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;
        
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_fr.Id);
        insert acct_hq;
        
        // Create a new Contact for the Account
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test_LogPhoneCaseController@test.com', AccountId = acct_hq.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        // create a query case for the account & contact
        Id RT_CasesEurope_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
        Case cs = new Case(RecordTypeId = RT_CasesEurope_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'IATA General Information', Status = 'Open',
                        ContactId = c.Id, AccountId = acct_hq.Id, Reason1__c = 'General information');  
        insert cs;
        
        // FINISHED CREATING TEST DATA
        
        test.startTest();
            PageReference pageRef = Page.LogPhoneCase;
            pageRef.getParameters().put('CaseId', cs.Id);
            Test.setCurrentPage(pageRef);
            
            LogPhoneCaseController controller = new LogPhoneCaseController();
            controller.newcase.CaseArea__c = 'Airline Management';
            controller.newcase.Reason1__c = 'Airline data changes';
            controller.newcase.Type_of_customer__c = 'Airline Passenger';
            controller.newcase.BSPCountry__c = 'France';
            controller.SaveAndClose();
            
            // Test that the case has been created and closed
            list<Case> cases = [SELECT Id, Status, ParentId FROM Case ORDER BY Id DESC];
            System.AssertEquals(2, cases.size());
            System.AssertEquals('Closed', cases[0].status);
            System.AssertEquals(cs.Id, cases[0].ParentId);
            
            list<Task> tasks = [SELECT Id FROM Task];
            System.AssertEquals(true, tasks.isempty());
            
            // test again, log another case and also create a task this time
            pageRef = Page.LogPhoneCase;
            pageRef.getParameters().put('CaseId', cs.Id);
            Test.setCurrentPage(pageRef);
            
            controller = new LogPhoneCaseController();
            controller.newcase.CaseArea__c = 'Airline Management';
            controller.newcase.Reason1__c = 'Airline data changes';
            controller.newcase.Type_of_customer__c = 'Airline Passenger';
            controller.newcase.BSPCountry__c = 'France';
            
            controller.isNewTaskRequested = true;
            
            controller.Save();
            controller.cancel();
            
            // Test that the case has been created and not closed
            cases = [SELECT Id, Status FROM Case ORDER BY Id DESC];
            System.AssertEquals(3, cases.size());
            System.AssertEquals('Open', cases[0].status);
            
            // Tets that the task has been created
            tasks = [SELECT Id FROM Task];
            System.AssertEquals(1, tasks.size());
            
        test.stopTest();
        
    }
}