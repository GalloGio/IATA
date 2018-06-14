@isTest
private class FinancialDocumentViewConTest {


    
    
    static testMethod void runTest(){         
   
        Case cse;
        List<ENZ__FTPAttachment__c> testDocs;
       
        Case testCase1 = new Case();
        
        testCase1.CaseArea__c = 'TTBS';
        //testCase1.Tax_Effective_Date__c = Date.valueOf('2011-08-29');
        testCase1.Origin = 'Other';
        testCase1.SuppliedEmail = 'paia@iata.org';
        testCase1.SuppliedPhone = '12456987456';
        testCase1.Type = 'TFC update';
        testCase1.Description = 'Testing...';
        testCase1.Priority = '3';
        testCase1.Subject = 'TTBS Test Case';
         insert testCase1;
        
        ApexPages.StandardController controller   = new ApexPages.StandardController(testCase1); 
        
        FinancialDocumentViewCon a = new FinancialDocumentViewCon(controller) ;  
         
        cse = a.getCse();
        testDocs = a.getDocs();
    
        a.refreshDocs();
        
        String test = a.getLocale();
        
    }

}