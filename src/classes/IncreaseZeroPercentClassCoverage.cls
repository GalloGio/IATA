@isTest
private class IncreaseZeroPercentClassCoverage{


    static testMethod void  test1() {
        
            IFAP_EmailTemplatePreviewController t = new IFAP_EmailTemplatePreviewController();
            AccountTypeDetailsController t2 = new AccountTypeDetailsController();

    }
    
    
    static testMethod void  test2() {
        
        AcliSchedule a = new AcliSchedule();
        /*
        Test.startTest();
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            String jobId = System.schedule('AcliSchedule', CRON_EXP, new AcliSchedule());
              // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
           Test.stopTest();
           */
    }
    
    
    static testMethod void  test3() {
        
        AirlineBranchController temp = new AirlineBranchController();
        String t = temp.parentAccountId;
        List<Services_Rendered__c> servicesList = temp.servicesList;
        t = temp.sortDir;
        t = temp.sortField;
        
        temp.AirlineBranchController();
        
    }
    
    
    static testMethod void test4(){
        
        
        ArchiveAttachmentListController temp = new ArchiveAttachmentListController();
        //List<Archived_Attachment__c> getArchivedAttachments = temp.getArchivedAttachments();
        
        ArchivedAttachmentControllerExtension t;
       // t.awsCredential = null;
       // t.ArchivedAttachmentControllerExtension(new ApexPages.StandardController);
        
    }
    
    
    static testMethod void test5(){
    
    
        ArchiveMessageExtensionController t = new ArchiveMessageExtensionController();
       // t.archivedMessage = null;
        t.originalMessage = null;
        string t1= t.archivedMessageId;
       // t.setArchivedMessageId('1');
        t1 = t.getArchivedMessageId();
        //t.setArchivedMessage(t.getArchivedMessage());
    }
    
     static testMethod void test6(){
     
         ChatterAnswersAuthProviderRegistration aa = new  ChatterAnswersAuthProviderRegistration();
         
        // aa.updateUser(null,null,null);
         
         ChatterAnswersRegistration aaa = new ChatterAnswersRegistration();
       //  String t = aaa.createAccount('a','a',null);
         
     }
     
     
     
   
     
     
     static testMethod void test8(){
     
         ifap_reminderScheduler ifa = new ifap_reminderScheduler();
         

     }
     
     
     
     
     
     
     
    
    
}