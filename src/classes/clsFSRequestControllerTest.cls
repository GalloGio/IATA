@isTest
private class clsFSRequestControllerTest{
 

    static testMethod void testMyController() {  
    
        //Use the PageReference Apex class to instantiate a page  
        PageReference pageRef = Page.FinancialSecurityRequest;  
        
        //In this case, the Visualforce page named 'success' is the starting point of this test method.   
        Test.setCurrentPage(pageRef);  
        
        //Instantiate and construct the controller class.     
        clsFinancialSecurityRequestController controller = new clsFinancialSecurityRequestController();  

        
             
          
        // Set some properties  
        date t = date.parse('12/27/2012');
        EmailTemplate__c e = new EmailTemplate__c();
        Insert e;
        
        controller.CaseParameter.EmailTemplate__c = e.Id;
        controller.CaseParameter.Deadline_Date__c = t;
        controller.MassSendEmail();

       
         BatchNumber__c batch = new BatchNumber__c();
         insert batch;
       controller.CaseParameter.BatchNumber__c= batch.Id;
       
       
        
        Apexpages.currentPage().getParameters().put('batchNumber',batch.Id);
        controller.runSearch();
        
                
        controller.SelectAll();
        List<clsFinancialSecurityRequestController.cCase> tmp = Controller.Cases;
        Controller.Cases= tmp;
        

        Apexpages.currentPage().getParameters().put('batchNumber','');
        controller.runSearch();
        controller.SelectAll();
        Apexpages.currentPage().getParameters().put('template',null);
        Apexpages.currentPage().getParameters().put('deadlineDate', ''); 
        controller.MassSendEmail();
        
        
      
        
        Apexpages.currentPage().getParameters().put('batchNumber','%');
        controller.runSearch();
        controller.SelectAll();        
        Apexpages.currentPage().getParameters().put('template',e.Id);
        Apexpages.currentPage().getParameters().put('deadlineDate', '12/27/2012');
        controller.CaseParameter.EmailTemplate__c = e.Id;
        controller.CaseParameter.Deadline_Date__c = t ;  
        controller.SelectAll();             
        controller.MassSendEmail();
        
        
       // Boolean a = controller.FSLetterSent;
       // a = controller.FSValueMissing;
        
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
       List<Case> cases = [Select c.Status,c.EmailTemplate__c, c.Deadline_Date__c From Case c Where c.Id = :  ca.Id];
            
      
        
     Test.startTest();        
        clsFinancialSecurityRequestBatch cBatch = new clsFinancialSecurityRequestBatch();
        cBatch.caseList = cases;
        cBatch.emailTemplate = '' ;
        cBatch.deadLineDate = controller.CaseParameter.Deadline_Date__c ;
       ID batchprocessid = Database.executeBatch(cBatch,5);
    Test.stopTest();     
    
    
    } 

  

  
}