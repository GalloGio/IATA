@isTest
private class clMassCaseCreationNonComplianceTest {


    static testMethod void CreatecContactTest() {
        clsMassCaseCreationNonComplianceCtrlr.cCase c = new clsMassCaseCreationNonComplianceCtrlr.cCase(New Case());
    }


    @testSetup static void initData() {
        BatchNumber__c batch = new BatchNumber__c();
        insert batch;

        IATA_ISO_Country__c ic = new IATA_ISO_Country__c(Name = 'Canada',
                ISO_Code__c = 'CA',
                Case_BSP_Country__c = 'Canada',
                Region__c = 'Americas',
                AIMS_Area_Name__c = 'Canada');
        insert ic;

        Account account1 = new Account(IATACode__c = '1234567');    // 7 digits
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Type = 'IATA Passenger Sales Agent';
        account1.Location_Type__c = 'HO';
        insert account1;

        Contact con = new Contact();
        con.FirstName = 'Dummy';
        con.LastName = 'Contact';
        con.Type_of_Contact__c = 'IFAP Contact';
        con.AccountId = account1.Id;
        con.Email = 'some@email.org';
        con.Financial_Assessment_Contact__c = true;
        insert con;

        ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

        Case aCase = new Case();
        aCase.ContactId = con.Id;
        aCase.AccountId = con.accountId;
        aCase.Origin = 'Agent Financial Review Notification';
        aCase.BatchNumber__c = batch.Id;
        aCase.Status = 'Financial Security Requested';
        aCase.Subject = 'subject';
        //aCase.RecordTypeId = IFAPcaseRecordTypeID;
        aCase.Description = 'description';
        aCase.Financial_Review_Type__c =  'Adhoc';
        aCase.New_IFAP_Deadline_date__c = Date.today();
        aCase.FS_Deadline_Date__c = Date.today();

        Insert aCase;
    }


    static testMethod void testMyController() {

        List<Case> cList = new List<Case>();


        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.MassCaseCreationNonCompliance;
        //In this case, the Visualforce page named 'success' is the starting point of this test method.
        Test.setCurrentPage(pageRef);
        //Instantiate and construct the controller class.
        clsMassCaseCreationNonComplianceCtrlr controller = new clsMassCaseCreationNonComplianceCtrlr();

        String OutputStr = controller.debugSoql;
        

        OutputStr = controller.sortDir;
        OutputStr = controller.sortField;

        //Boolean a = controller.SelAllIsChecked;
        //controller.SelAllIsChecked = a;
        controller.SelAllIsChecked = true;

        Integer b = controller.pageNumber;
        controller.pageNumber = b;

        Integer c = controller.noOfPages;
        controller.noOfPages = c;

        Boolean d = controller.isNbrRecordsDisplayed;
        controller.isNbrRecordsDisplayed = d;


        String caseStatus = controller.getcaseStatus();
        controller.setcaseStatus(caseStatus);




        List<selectOption> FinancialReviewTypes = controller.getcaseStatusItems();
        List<clsMassCaseCreationNonComplianceCtrlr.cCase> cases = controller.Cases;
    

        // Set some properties
        controller.CaseParameter.Subject = 'hi';
        controller.CaseParameter.Financial_Review_Type__c = 'Annual';




        controller.CaseParameter.BatchNumber__c = null;
        controller.CaseParameter.Deadline_Date__c = null;
        controller.setcaseStatus('');
        controller.runSearch();


        // create test BatchNumber
        BatchNumber__c batch = [Select id from BatchNumber__c];
        Case aCase = [Select c.CaseNumber, c.ID, c.Status, Account.Name, c.AccountID, c.ContactID, c.Account.BillingCountry, Account.IATACode__c, Contact.Name, c.Account.Type,
                 Contact.Email, c.firstFSnonComplianceDate__c , c.firstFAnonComplianceDate__c, c.secondFSnonComplianceDate__c, c.secondFAnonComplianceDate__c, c.SCF_Reason_IFAP__c, c.FS_Deadline_Date__c
                 From Case c where c.BatchNumber__c =: batch.id ];

        cList.add(aCase);
        
     

        controller.CaseParameter.BatchNumber__c = batch.id;

        controller.CaseParameter.Deadline_Date__c = Date.Today();
        controller.setcaseStatus('Financial Security Requested');
        controller.runSearch();


        controller.SelectAll();

        controller.first();
        controller.last();
        controller.previous();
        

        controller.toggleSort();
        controller.CaseParameter.New_IFAP_Deadline_date__c = Date.today();
        controller.CaseParameter.Deadline_Date__c = Date.today();
        //controller.runQuery();
        controller.createCases();
        //controller.next();
        
        Boolean hasFirst = controller.hasFirst;
        Boolean hasLast = controller.hasLast;


        //Boolean o = controller.openCase;
        Boolean num = controller.isNbrRecordsDisplayed;
        Integer num2 = controller.nbrSelectedRecords;
        Integer num3 = controller.nbrFoundRecords;
        controller.nbrFoundRecords = num3;
        Integer num4 = controller.currentPage;
        controller.currentPage = num4;

        controller.updateNbrSelectedRecords();



        Boolean boo = controller.hasNext;
        boo = controller.hasPrevious;

        Integer nbPages = controller.pageNumber;

        Apexpages.currentPage().getParameters().put('email', '1');
        Apexpages.currentPage().getParameters().put('agenttype', 'IATA Passenger Sales Agent');
        Apexpages.currentPage().getParameters().put('agentstatus', 'Approved');
        controller.runSearch();

        Apexpages.currentPage().getParameters().put('email', '2');
        controller.runSearch();

        controller.toggleSort();



        //test batch
       /* System.debug('***** STARTING BATCH ' ) ;
        Test.startTest();
        clsMassCaseCreationNonComplianceBatch cBatch = new clsMassCaseCreationNonComplianceBatch();
        cBatch.caseList = cList;
        cBatch.Subject = 'Subject';
        cBatch.Description = 'Description';
        ID batchprocessid = Database.executeBatch(cBatch, 5);
        Test.stopTest();*/



    }    
}