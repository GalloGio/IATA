@isTest
private class clsMassEmailReminderTest{
    
    
    static testMethod void testMyController() {  
        RecordType IFAPcaseRecordType = [Select r.Id, r.Name from RecordType r where r.Name = 'IATA Financial Review' limit 1];
        
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
        
        //Use the PageReference Apex class to instantiate a page  
        PageReference pageRef = Page.MassEmailReminder;  
        
        //In this case, the Visualforce page named 'success' is the starting point of this test method.   
        Test.setCurrentPage(pageRef);  
        
        //Instantiate and construct the controller class.     
        clsMassEmailReminderController controller = new clsMassEmailReminderController();  
        
        
        
        BatchNumber__c batch = new BatchNumber__c();
        insert batch;
        controller.CaseParameter.BatchNumber__c= batch.Id;
        
        
        // Set some properties  
        EmailTemplate__c e = new EmailTemplate__c();
        //e.recordType.Name = 'IFAP';
        controller.CaseParameter.EmailTemplate__c = e.Id;
        controller.MassSendEmail();
        
        Apexpages.currentPage().getParameters().put('batchNumber','');
        controller.runSearch();
        
        
        Apexpages.currentPage().getParameters().put('batchNumber','B-0000000275');
        controller.runSearch();
        
        
        controller.SelectAll();
        List<clsMassEmailReminderController.cCase> tmp = Controller.Cases;
        Controller.Cases= tmp;
        
        
        
        controller.CaseParameter.EmailTemplate__c = e.Id;
        
        controller.MassSendEmail();
        
        
        controller.SelectAll();
        controller.first();
        controller.last();
        controller.previous();
        controller.next();
        
        
        
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
        
        
        controller.toggleSort();        
        
        
        
        Case ca = new Case();
        
        Insert ca;
        List<Case> cases = [Select c.Mass_Email_Send__c,c.EmailTemplate__c,c.FS_Reminder_EmailTemplate__c,c.Reminder_EmailTemplate__c,c.FS_Mass_Email_Send__c From Case c Where c.Id=: ca.Id];     
        
        clsMassEmailReminderController.cCase acas = new clsMassEmailReminderController.cCase(ca);
        System.runAs(new User(Id = System.UserInfo.getUserId())) {
            String emailTemplateId = '';
            if (TestClass_SetupVariables.emailTemplateTest != null)
            {            
                emailTemplateId = TestClass_SetupVariables.emailTemplateTest.Id;
            }
            
            Test.startTest();        
            clsMassEmailReminderBatch cBatch = new clsMassEmailReminderBatch();
            cBatch.caseList = cases;
            cBatch.type = 'FA Reminder';
            cBatch.emailTemplate = emailTemplateId;
            ID batchprocessid = Database.executeBatch(cBatch,5);
            
            clsMassEmailReminderBatch cBatch2 = new clsMassEmailReminderBatch();
            cBatch2.caseList = cases;
            cBatch2.type = 'FA - Financial Assessment';
            cBatch2.emailTemplate = emailTemplateId;
            ID batchprocessid2 = Database.executeBatch(cBatch2,5);
            Boolean boolea = controller.FALetterSent;
                Test.stopTest(); 
        }
        
    } 
    
    

  
}