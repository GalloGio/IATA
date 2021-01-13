@isTest
private class clsBounceEmailBatchTest{
 
 static testMethod void testMybatch() {  
    
      Case ca = new Case();
        ca.BounceEmailSubject__c = 'Test';
        ca.BounceEmailCounter__c = 0;
        ca.Status = 'Action Needed';
       Insert ca;
       
       EmailMessage em = new EmailMessage();
       em.ParentId = ca.Id;
       em.ToAddress = 'im.remon@gmail.com';
       em.CcAddress = 'im.remon@gmail.com';
       em.TextBody = 'hello';
       em.Subject= 'Test';      
       em.MessageDate = datetime.now();
       Insert em;
	   
	   //EM: Added to increase coverage on EmailTrigger
	   update em;
       
     
       Case ca1 = new Case();
        ca1.BounceEmailSubject__c = 'Test';
        ca1.BounceEmailCounter__c = 0;
        ca1.Status = 'Action Needed';
       Insert ca1;
       
       EmailMessage em1 = new EmailMessage();
       em1.ParentId = ca1.Id;
       em1.ToAddress = 'im.remon@gmail.com';
       em1.CcAddress = 'im.remon@gmail.com';
       em1.TextBody = 'hello';
       em1.Subject= 'Test';
       em1.MessageDate = datetime.now().addHours(-8);
       Insert em1;
       
       Case ca2 = new Case();
        ca2.BounceEmailSubject__c = 'Test';
        ca2.BounceEmailCounter__c = 3;
        ca2.Status = 'Action Needed';
       Insert ca2;
       
       EmailMessage em2 = new EmailMessage();
       em2.ParentId = ca2.Id;
       em2.ToAddress = 'im.remon@gmail.com';
       em2.CcAddress = 'im.remon@gmail.com';
       em2.TextBody = 'hello';
       em2.Subject= 'Test';
       em2.MessageDate = datetime.now().addHours(-8);
       Insert em2;
       
       
       
       Case ca3 = new Case();
        ca3.BounceEmailSubject__c = 'Test';
        ca3.BounceEmailCounter__c = 3;
        ca3.Status = 'Action Needed';
       Insert ca3;
       
       EmailMessage em3 = new EmailMessage();
       em3.ParentId = ca3.Id;
       em3.ToAddress = 'im.remon@gmail.com';
       em3.CcAddress = 'im.remon@gmail.com';
       em3.TextBody = 'hello';
       em3.Subject= 'Test';
       em3.MessageDate = datetime.now();
       Insert em3;
       
       
       //List<Case> cases = [Select c.Status,c.EmailTemplate__c, c.Deadline_Date__c, c.BounceEmailSubject__c , c.BounceEmailCounter__c From Case c Where c.Id = :  ca.Id];
       List<Case> cases = new List<Case>();
       cases.add(ca);
       cases.add(ca1);
       cases.add(ca2);
       cases.add(ca3);
            
            
 
     Test.startTest();        
        clsBounceEmailBatch cBatch = new clsBounceEmailBatch();
        cBatch.caseList = cases;
       ID batchprocessid = Database.executeBatch(cBatch,5);
    Test.stopTest();     
    }
    
    
   static testMethod void testScheduler() {  
     
    
     Test.startTest();

      String jobId = System.schedule('IFAPBounceEmailScheduler',
      IFAPBounceEmailScheduler.CRON_EXP, 
         new IFAPBounceEmailScheduler());
  
   Test.stopTest();
    
    
    }

}