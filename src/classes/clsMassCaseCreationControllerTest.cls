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
private class clsMassCaseCreationControllerTest {

    
    static testMethod void CreatecContactTest() {
        clsMassCaseCreationController.cContact c = new clsMassCaseCreationController.cContact(New Contact());
    }
    
    
    static testMethod void testMyController() {  

        //Use the PageReference Apex class to instantiate a page  
        PageReference pageRef = Page.Mass_Case_Creation_Page;  
        //In this case, the Visualforce page named 'success' is the starting point of this test method.   
        Test.setCurrentPage(pageRef);  
        //Instantiate and construct the controller class.     
        clsMassCaseCreationController controller = new clsMassCaseCreationController();  

        String OutputStr = controller.debugSoql;
        
        OutputStr = controller.ProcessOutput;

        OutputStr = controller.Warning;
        
        OutputStr = controller.sortDir; 
        OutputStr = controller.sortField; 

        List<selectOption> FinancialReviewTypes = controller.lstFinReviewType;
        
          
        // Set some properties  
        controller.CaseParameter.Subject = 'hi';
        controller.CaseParameter.Financial_Review_Type__c = 'Annual';
        
        System.assertEquals(controller.CaseParameter.Financial_Review_Type__c, 'Annual');
        
        // 
        
        controller.MassCaseCreateSendEmail();

        Apexpages.currentPage().getParameters().put('agenttype','');
        Apexpages.currentPage().getParameters().put('agentstatus','');
        Apexpages.currentPage().getParameters().put('email','');
        Apexpages.currentPage().getParameters().put('country','');
        controller.runSearch();
        
        Apexpages.currentPage().getParameters().put('country','Canada');
        Apexpages.currentPage().getParameters().put('yearend','February');
        controller.runSearch();
        
        Apexpages.currentPage().getParameters().put('country','Canada');
        Apexpages.currentPage().getParameters().put('yearend','');
        Apexpages.currentPage().getParameters().put('agenttype','IATA Cargo Agent-IATA Passenger Sales Agent');
        Apexpages.currentPage().getParameters().put('agentstatus','Approved-Listed-Changes processed-Under review-Cash basis/with commission');
        controller.runSearch();
                
        controller.SelectAll();
        List<clsMassCaseCreationController.cContact> tmp = Controller.Contacts;
        Controller.Contacts = tmp;
        
        controller.CaseParameter.Subject = 'Test Case Unit Testing';
        controller.CaseParameter.Financial_Review_Type__c = 'Annual';

        controller.MassCaseCreate();
        
        
        //controller.first();
        //controller.last();
        //controller.previous();
        //controller.next();
        
        Boolean o = controller.openCase;
        Boolean num = controller.isNbrRecordsDisplayed;
        Integer num2 = controller.nbrSelectedRecords; 
        Integer num3 = controller.nbrFoundRecords;
        controller.nbrFoundRecords = num3;
        //Integer num4 = controller.currentPage;
        //controller.currentPage = num4;
        
        controller.updateNbrSelectedRecords();
        
        
        
        //Boolean boo = controller.hasNext;
        //boo = controller.hasPrevious;
        
        Integer nbPages = controller.pageNumber; 
        
        Apexpages.currentPage().getParameters().put('email','1');
        Apexpages.currentPage().getParameters().put('agenttype','IATA Passenger Sales Agent');
        Apexpages.currentPage().getParameters().put('agentstatus','Approved');
        controller.runSearch();
        
        Apexpages.currentPage().getParameters().put('email','2');
        controller.runSearch();
        
        Apexpages.currentPage().getParameters().put('email','1');
        Apexpages.currentPage().getParameters().put('agenttype','IATA Passenger Sales Agent');
        Apexpages.currentPage().getParameters().put('agentstatus','Listed');
        controller.runSearch();
        
        controller.toggleSort();
        //controller.first();
        //controller.last();
        //controller.previous();
        //controller.next();
        controller.openEmailTemplatePreview();
    } 

    static testMethod void testStuff() {
        
        //Instantiate and construct the controller class.     
        clsMassCaseCreationController controller = new clsMassCaseCreationController();  
        
        EmailTemplate__c bob = controller.EmailParameter;
        
        //List<selectOption> l = controller.lstLanguage;
        
        List<selectOption> l2 = controller.lstFinancialMonth;
        
        controller.toggleSort();
        
        controller.runQuery();
        
        PageReference pr = controller.MassCaseCreate();
        
        PageReference pr2 = controller.SelectAll();
        
        //controller.ValidateContacts();
        
        boolean b1 = controller.hasFirst;
        
        boolean b2 = controller.hasLast;
        
        boolean b3 = controller.hasNext;
        
        boolean b4 = controller.hasPrevious;
        
        Integer i = controller.pageNumber;
        
        /*controller.first();
        controller.last();
        controller.previous();
        controller.next();*/
        
        Boolean b5 = controller.isNbrRecordsDisplayed;
        
        controller.updateNbrSelectedRecords();
        
        Integer i2 = controller.nbrFoundRecords;
        
        Integer i3 = controller.currentPage;
        
        Integer i4 = controller.totalPage;
    }
    
    
    static testMethod void testReinstatedAccountShouldBeExcluded() {  
        //the runsearch() method should exclude all the contacts related to accounts having Reinstated_Date__c in the last 6 months.
        
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Bahamas', ISO_Code__c = 'BS');
        insert isoc;
        
        String isocountryid = [select id from IATA_ISO_Country__c where Name = 'Bahamas'].id;
        
        Account a1 = new Account(Name='Account NOT reinstated',
                                 IATACode__c = '11111111',
                                 BillingCountry = 'Bahamas',
                                 Status__c = 'Approved',
                                 IATA_ISO_Country__c = isocountryid,
                                 Type = 'IATA Passenger Sales Agent',
                                 Fin_statements_submission_deadline__c = 'January',
                                 Location_Type__c = 'AO',
                                 Has_Financial_Review_Open_Cases__c = true
        );
        Account a2 = new Account(Name='Account reinstated in last 6 months',
                                 IATACode__c = '22222222',
                                 BillingCountry = 'Bahamas',
                                 Status__c = 'Approved',
                                 IATA_ISO_Country__c = isocountryid,
                                 Type = 'IATA Passenger Sales Agent',
                                 Fin_statements_submission_deadline__c = 'January',
                                 Location_Type__c = 'AO',
                                 Has_Financial_Review_Open_Cases__c = true,
                                 Reinstated_Date__c = date.today().addMonths(-3)
        );
        Account a3 = new Account(Name='Account reinstated 1 year ago',
                                 IATACode__c = '33333333',
                                 BillingCountry = 'Bahamas',
                                 Status__c = 'Approved',
                                 IATA_ISO_Country__c = isocountryid,
                                 Type = 'IATA Passenger Sales Agent',
                                 Fin_statements_submission_deadline__c = 'January',
                                 Location_Type__c = 'AO',
                                 Has_Financial_Review_Open_Cases__c = true,
                                 Reinstated_Date__c = date.today().addMonths(-12)
        );
        insert new List<Account>{a1,a2,a3};
        
        
            
        Contact c1 = new Contact(FirstName = 'Name', LastName='Contact 1 OK', Email='cont1@test.com',  Financial_Assessment_Contact__c = true, AccountId=a1.id);
        Contact c2 = new Contact(FirstName = 'Name', LastName='Contact 2 NO', Email='cont2@test.com',  Financial_Assessment_Contact__c = true, AccountId=a2.id);
        Contact c3 = new Contact(FirstName = 'Name', LastName='Contact 3 OK', Email='cont3@test.com',  Financial_Assessment_Contact__c = true, AccountId=a3.id);
        insert new List<Contact>{c1,c2,c3};

     
        test.startTest();
        
        
        

        PageReference pageRef = Page.Mass_Case_Creation_Page;    
        Test.setCurrentPage(pageRef);    
        clsMassCaseCreationController controller = new clsMassCaseCreationController();  

        
        List<selectOption> FinancialReviewTypes = controller.lstFinReviewType;
        
          
        controller.CaseParameter.Subject = 'hi';
        controller.CaseParameter.Financial_Review_Type__c = 'Annual';
        controller.aISOCountry.IATA_ISO_Country__c = [select id from IATA_ISO_Country__c where Name = 'Bahamas'].id;
        
        //Apexpages.currentPage().getParameters().put('country','Bahamas');
        Apexpages.currentPage().getParameters().put('agenttype','IATA Cargo Agent-IATA Passenger Sales Agent');
        Apexpages.currentPage().getParameters().put('targetFinancialYear','2015');
        Apexpages.currentPage().getParameters().put('email','1');
        Apexpages.currentPage().getParameters().put('exclClosedCases', 'false');
        Apexpages.currentPage().getParameters().put('agentstatus','');
        Apexpages.currentPage().getParameters().put('yearend','--All--');
        Apexpages.currentPage().getParameters().put('exclOpenCases','false');

        controller.runSearch();
        
        system.assertEquals(2, controller.Contacts.size());
       
    } 
    
    
    static testMethod void testMassCaseSendTrackedEmail() {  
        //the runsearch() method should exclude all the contacts related to accounts having Reinstated_Date__c in the last 6 months.
        
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Bahamas', ISO_Code__c = 'BS', AIMS_Area_ID__c = 'A', AIMS_Area_Name__c = 'A');
        insert isoc;
        
        Account a1 = new Account(Name='Account NOT reinstated',
                                 IATACode__c = '11111111',
                                 BillingCountry = 'Bahamas',
                                 Status__c = 'Approved',
                                 IATA_ISO_Country__c = isoc.Id,
                                 Type = 'IATA Passenger Sales Agent',
                                 Fin_statements_submission_deadline__c = 'January',
                                 Location_Type__c = 'AO',
                                 Has_Financial_Review_Open_Cases__c = true
        );
        Account a2 = new Account(Name='Account reinstated in last 6 months',
                                 IATACode__c = '22222222',
                                 BillingCountry = 'Bahamas',
                                 Status__c = 'Approved',
                                 IATA_ISO_Country__c = isoc.Id,
                                 Type = 'IATA Passenger Sales Agent',
                                 Fin_statements_submission_deadline__c = 'January',
                                 Location_Type__c = 'AO',
                                 Has_Financial_Review_Open_Cases__c = true,
                                 Reinstated_Date__c = date.today().addMonths(-3)
        );
        Account a3 = new Account(Name='Account reinstated 1 year ago',
                                 IATACode__c = '33333333',
                                 BillingCountry = 'Bahamas',
                                 Status__c = 'Approved',
                                 IATA_ISO_Country__c = isoc.Id,
                                 Type = 'IATA Passenger Sales Agent',
                                 Fin_statements_submission_deadline__c = 'January',
                                 Location_Type__c = 'AO',
                                 Has_Financial_Review_Open_Cases__c = true,
                                 Reinstated_Date__c = date.today().addMonths(-12)
        );
        insert new List<Account>{a1,a2,a3};

        Contact c1 = new Contact(FirstName='Name', LastName='Contact 1 OK', Email='cont1@test.com',  Financial_Assessment_Contact__c = true, AccountId=a1.id);
        Contact c2 = new Contact(FirstName='Name', LastName='Contact 2 NO', Email='cont2@test.com',  Financial_Assessment_Contact__c = true, AccountId=a2.id);
        Contact c3 = new Contact(FirstName='Name', LastName='Contact 3 OK', Email='cont3@test.com',  Financial_Assessment_Contact__c = true, AccountId=a3.id);
        insert new List<Contact>{c1,c2,c3};
     
		Signaturit_Events_WS__c ws = new Signaturit_Events_WS__c(name = 'test', events_url__c = 'http://test.com', oauth_url__c = 'test');
		insert ws;
     
        PageReference pageRef = Page.Mass_Case_Creation_Page;    
        Test.setCurrentPage(pageRef);    
        clsMassCaseCreationController controller = new clsMassCaseCreationController();  
        
        List<selectOption> FinancialReviewTypes = controller.lstFinReviewType;
          
        controller.CaseParameter.Subject = 'hi';
        controller.CaseParameter.Financial_Review_Type__c = 'Annual';
        
        Apexpages.currentPage().getParameters().put('agenttype','IATA Cargo Agent-IATA Passenger Sales Agent');
        Apexpages.currentPage().getParameters().put('targetFinancialYear','2015');
        Apexpages.currentPage().getParameters().put('email','1');
        Apexpages.currentPage().getParameters().put('exclClosedCases', 'false');
        Apexpages.currentPage().getParameters().put('agentstatus','');
        Apexpages.currentPage().getParameters().put('yearend','--All--');
        Apexpages.currentPage().getParameters().put('exclOpenCases','false');
        
        EmailTemplate__c emailTemplate = new EmailTemplate__c(IATA_ISO_Country__c = isoc.Id);
        insert emailTemplate;
        
        controller.IFAP_CanCreateWhileClosedCase = false;
        
        controller.CaseParameter.EmailTemplate__c = emailTemplate.Id;
        controller.aISOCountry.IATA_ISO_Country__c = isoc.Id;
        controller.CaseParameter.Deadline_Date__c = Date.today().addMonths(2);
        controller.runSearch();
        
        for(clsMassCaseCreationController.cContact ccontact : controller.Contacts){
            ccontact.selected = true;
        }

		EmailTemplate ifapTemplate = [select ID from EmailTemplate where DeveloperName = 'IFAP'][0];

		Attachment att = new Attachment(
			Name='Attachment 1',
			Body = Blob.valueOf('Attachment 1 body'),
			ParentId = ifapTemplate.Id
		);
        
        insert att;

        test.startTest();
                
        controller.MassCaseCreateSendTrackedEmail();
        
        List<SelectOption> ISOCountryName = controller.getISOCountryName();
        String FinancialReviewType = controller.FinancialReviewType;
        List<SelectOption> lstLanguage = controller.lstLanguage;
        
        Apexpages.currentPage().getParameters().put('agentstatus','test-test');
        Apexpages.currentPage().getParameters().put('email','2');
        Apexpages.currentPage().getParameters().put('yearend','2017');
        Apexpages.currentPage().getParameters().put('exclOpenCases','true');
        
        Boolean agentWithClosedCaseSelected = controller.agentWithClosedCaseSelected;
        
        controller.runSearch();
        
        controller.first();
        controller.last();
        controller.next();
        controller.previous();
        
       Test.stopTest();
    }   
}