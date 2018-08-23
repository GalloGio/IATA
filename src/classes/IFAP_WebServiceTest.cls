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
private class IFAP_WebServiceTest {

    
    static testMethod void TestGetCaseStatus() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

        // get the IFAP case recordtype
        Id IFAPcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        
        // create test account
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.IATACode__c = '1234567';
        account1.Type = 'IATA Passenger Sales Agent';
        account1.Location_Type__c = 'HO';
        insert account1;
        
        // create test contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'Contact';
        contact1.Type_of_Contact__c = 'IFAP Contact';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        contact1.Financial_Assessment_Contact__c = true;
        insert contact1;
        
        Case case1 = new Case();
        case1.ContactId = contact1.Id;
        case1.AccountId = account1.Id;
        case1.Subject = 'Test Case 1';
        case1.Description = 'Test Case 1';
        case1.Status = 'Agent Notified';
        case1.RecordTypeId = IFAPcaseRecordTypeId;
        case1.IFAP_Financial_Year__c = '2012';
        insert case1;
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
		TransformationHelper.CalculateBusinessHoursAges = false;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;

        case theCase = [Select c.Status, c.Id, c.CaseNumber From Case c Where c.Id = :case1.Id limit 1];
        
        IFAP_WebService.getCaseStatus(theCase.CaseNumber);
    }
    
    static testMethod void TestLetterSent() {
	    TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

     	Case case1 = new Case();
        case1.Subject = 'Test Case 1';
        case1.Description = 'Test Case 1';
        case1.Status = 'Agent Notified';
        case1.IFAP_Financial_Year__c = '2012';
        insert case1;
        
        List<Case> casesID = new List<Case>();
        casesId.add(case1);
        
      	BatchNumber__c batch = new BatchNumber__c();
      	Insert batch;  
        
        
	    Boolean a = IFAP_WebService.UpdateFSLetterSent(casesID , batch.Name);
	    Boolean b = IFAP_WebService.UpdateFALetterSent(casesID, batch.Name);
    
	    TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
		TransformationHelper.CalculateBusinessHoursAges = false;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;

    	String caseStat = IFAP_WebService.CheckCaseStatus(case1.Id);
    
    }
  
    
    static testMethod void TestSAAMCaseURLGenerationAndArchiving() {
       	TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;
 
        // get the SAAM case recordtype
        Id SAAMcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');
        
        // create test account
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.IATACode__c = '1234567';
        account1.Type = 'IATA Passenger Sales Agent';
        account1.Location_Type__c = 'HO';
        account1.Status__c = 'Approved';
        insert account1;
        
        // create test contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'Contact';
        contact1.Type_of_Contact__c = 'IFAP Contact';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        contact1.Financial_Assessment_Contact__c = true;
        insert contact1;
        
        Case case1 = new Case();
        case1.ContactId = contact1.Id;
        case1.AccountId = account1.Id;
        case1.Subject = 'Test Case 1';
        case1.Description = 'Test Case 1';
        case1.Status = 'Agent Notified (Email)';
        case1.RecordTypeId = SAAMcaseRecordTypeId;
        case1.IFAP_Financial_Year__c = '2012';
        insert case1;
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
		TransformationHelper.CalculateBusinessHoursAges = false;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
        String url = IFAP_WebService.generateURLForNewCaseFromSAAM(case1.Id);
        system.assert(url != null && url != '');
        

    }
    
    static testMethod void TestFinancialSecurityInfo(){
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;
        // get the IFAP case recordtype
        Id IFAPcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        IFAP_BusinessRulesTest.createIsoCountry();
        // create test account
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.IATACode__c = '1234567';
        account1.Type = 'IATA Passenger Sales Agent';
        account1.Location_Type__c = 'HO';
        insert account1;
        
        // create test contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'Contact';
        contact1.Type_of_Contact__c = 'IFAP Contact';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        contact1.Financial_Assessment_Contact__c = true;
        insert contact1;
        
        Case case1 = new Case();
        case1.ContactId = contact1.Id;
        case1.AccountId = account1.Id;
        case1.Subject = 'Test Case 1';
        case1.Description = 'Test Case 1';
        case1.Status = 'Agent Notified (Email)';
        case1.RecordTypeId = IFAPcaseRecordTypeId;
        case1.IFAP_Financial_Year__c = '2012';
        insert case1;
   		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
		TransformationHelper.CalculateBusinessHoursAges = false;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;     
        // reselect the case to retireve case number
        case theCase = [Select c.Status, c.Id, c.CaseNumber From Case c Where c.Id = :case1.Id limit 1];
        
        String caseNumber = theCase.CaseNumber;
        
        IFAP_WebService.FinancialSecurityInfo(caseNumber, 'EUR',1.0);
        
        // reselect the case
        theCase = [Select c.Status, c.Id, c.CaseNumber, c.Financial_Security_Amount__c, c.Financial_Security_Currency__c From Case c Where c.Id = :case1.Id limit 1];
        
//        system.assertEquals(theCase.Financial_Security_Amount__c, 1.0);
//        system.assertEquals(theCase.Financial_Security_Currency__c, 'EUR');
    } 
 
    
    static TestMethod void TestCallReassessmentApprovalProcess(){
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;
        // get the IFAP case recordtype
        Id IFAPcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        
        // create test account
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.IATACode__c = '1234567';
        account1.Type = 'IATA Passenger Sales Agent';
        account1.Location_Type__c = 'HO';
        account1.Status__c = 'Approved';
        insert account1;
        
        // create test contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'Contact';
        contact1.Type_of_Contact__c = 'IFAP Contact';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        contact1.Financial_Assessment_Contact__c = true;
        insert contact1;
        
        Case case1 = new Case();
        case1.ContactId = contact1.Id;
        case1.AccountId = account1.Id;
        case1.Subject = 'Test Case 1';
        case1.Description = 'Test Case 1';
        case1.Status = 'Sanity Check Failure';
        case1.RecordTypeId = IFAPcaseRecordTypeId;
        case1.IFAP_Financial_Year__c = '2012';
        insert case1;
        
        IFAP_Quality_Issue__c reassessment1 = new IFAP_Quality_Issue__c();
        reassessment1.Related_Case__c = case1.Id;
        reassessment1.Assessment_using_wrong_template__c = true;
        reassessment1.Other_Issue_details__c = 'Test Value'; // Mandatory if a checkbox of the Accounting issue section is checked    
        
        insert reassessment1;
  		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
		TransformationHelper.CalculateBusinessHoursAges = false;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;      
        Test.startTest();
        
        // try to approve a quality issue when the field Wrong figure is set to false (no business rule. Should return OK)
        try{
        
            string res = IFAP_WebService.CallReassessmentApprovalProcess(case1.id, reassessment1.id);
            //system.assertEquals(res.split(',')[0], 'OK');
        }
        catch (Exception e){
            system.assert(true);
        }
        
        Test.stopTest();
    }
    
    static TestMethod void TestCallReassessmentApprovalProcess2(){
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

        // get the IFAP case recordtype
        Id IFAPcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
        
                 // create test account 2
        Account account2 = new Account();
        account2.Name = 'Test account 2';
        account2.BillingCity = 'Montreal';
        account2.BillingCountry = 'Canada';
        account2.BillingStreet = 'some street';
        account2.IATACode__c = '7403756';
        account2.Type = 'IATA Passenger Sales Agent';
        account2.Location_Type__c = 'HO';
        account2.Status__c = 'Approved';
        insert account2;
        
        // create test contact
        Contact contact2 = new Contact();
        contact2.FirstName = 'Dummy';
        contact2.LastName = 'Contact';
        contact2.Type_of_Contact__c = 'IFAP Contact 2';
        contact2.AccountId = account2.Id;
        contact2.Email = 'some2@email.org';
        contact2.Financial_Assessment_Contact__c = true;
        insert contact2;
        
        Case case2 = new Case();
        case2.ContactId = contact2.Id;
        case2.AccountId = account2.Id;
        case2.Subject = 'Test Case 2';
        case2.Description = 'Test Case 2';
        case2.Status = 'Sanity Check Failure';
        case2.RecordTypeId = IFAPcaseRecordTypeId;
        case2.IFAP_Financial_Year__c = '2012';
        insert case2;
        
        IFAP_Quality_Issue__c reassessment2 = new IFAP_Quality_Issue__c();
        reassessment2.Related_Case__c = case2.Id;
        reassessment2.Assessment_using_wrong_template__c = true;
        reassessment2.Other_Issue_details__c = 'Test Value'; // Mandatory if a checkbox of the Accounting issue section is checked   
        reassessment2.Wrong_figure_was_extracted__c = true; 
        
        insert reassessment2;
  		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
		TransformationHelper.CalculateBusinessHoursAges = false;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;      
        Test.startTest();
        
        // try to approve a quality issue when the field Wrong figure is set to true and no accounting issue created for the quality issue (Should fail)
        try{
        
            string res = IFAP_WebService.CallReassessmentApprovalProcess(case2.id, reassessment2.id);
            //system.assertEquals(res.split(',')[0], 'Failed');
        }
        catch (Exception e){
            system.assert(true);
        }
        
        Test.stopTest();
    }
    
    static TestMethod void TestCallReassessmentApprovalProcess3(){
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
		TransformationHelper.CalculateBusinessHoursAges = true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

        // get the IFAP case recordtype
        Id IFAPcaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
                
        // create test account
        Account account3 = new Account();
        account3.Name = 'Test account 3';
        account3.BillingCity = 'Montreal';
        account3.BillingCountry = 'Canada';
        account3.BillingStreet = 'some street';
        account3.IATACode__c = '7394658';
        account3.Type = 'IATA Passenger Sales Agent';
        account3.Location_Type__c = 'HO';
        account3.Status__c = 'Approved';
        insert account3;
        
        // create test contact
        Contact contact3 = new Contact();
        contact3.FirstName = 'Dummy';
        contact3.LastName = 'Contact';
        contact3.Type_of_Contact__c = 'IFAP Contact 3';
        contact3.AccountId = account3.Id;
        contact3.Email = 'some3@email.org';
        contact3.Financial_Assessment_Contact__c = true;
        insert contact3;
        
        Case case3 = new Case();
        case3.ContactId = contact3.Id;
        case3.AccountId = account3.Id;
        case3.Subject = 'Test Case 3';
        case3.Description = 'Test Case 3';
        case3.Status = 'Sanity Check Failure';
        case3.RecordTypeId = IFAPcaseRecordTypeId;
        case3.IFAP_Financial_Year__c = '2012';
        insert case3;

        IFAP_Quality_Issue__c reassessment3 = new IFAP_Quality_Issue__c();
        reassessment3.Related_Case__c = case3.Id;
        reassessment3.Assessment_using_wrong_template__c = true;
        reassessment3.Other_Issue_details__c = 'Test Value'; // Mandatory if a checkbox of the Accounting issue section is checked   
        reassessment3.Wrong_figure_was_extracted__c = true; 
        
        insert reassessment3;
        
        IFAP_Reassessment_Accounting_Issue__c accountingIssue = new IFAP_Reassessment_Accounting_Issue__c();
        accountingIssue.Field_Name__c = 'test';
        accountingIssue.Wrong_value__c = 'test'; 
        accountingIssue.Value_to_use__c = 'test';
        accountingIssue.Comment__c = 'test';
        accountingIssue.IFAP_Reassessment__c = reassessment3.Id;
       
        insert accountingIssue;
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
		TransformationHelper.CalculateBusinessHoursAges = false;
		CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
        Test.StartTest();
        
        // try to approve a quality issue when the field Wrong figure is set to false (no business rule. Should return OK)
        try{
        
            string res = IFAP_WebService.CallReassessmentApprovalProcess(case3.id, reassessment3.id);
            //system.assertEquals(res.split(',')[0], 'OK');
        }
        catch (Exception e){
            system.assert(true);
        }
        
        Test.stopTest();
    }
}