global class clsFinancialSecurityRequestBatch implements Database.Batchable<sObject>{

    global List<Case> caseList = new List<Case>();
    global String emailTemplate;
    global Date deadLineDate;
   
   
    global List<Case> start(Database.BatchableContext BC){
        return caseList;
    }
    
    //changes case status to Financial Security requested
    global void execute(Database.BatchableContext BC, List<Case> scope){
       
     try{   
         for(Case c : scope)
              {
                c.Status = 'Financial Security Requested'; 
                c.FS_EmailTemplate__c = emailTemplate;
                c.FS_Deadline_Date__c = deadLineDate;
                c.FS_Request_Mass__c = true;
                
               Update c; 
              }
     }
     catch(Exception e){}
         
    }
 
    global void finish(Database.BatchableContext BC){            
    }
     
}