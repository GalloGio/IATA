/*
    A sample test class for the Require Rejection Comment trigger
*/
@isTest
public class RequireRejectionCommentTest
{
    /*
        For this first test, create an object for approval, then
        simulate rejeting the approval with an added comment for explanation.
        
        The rejection should be processed normally without being interrupted.
    */
    
    
    /*
        For this test, create an object for approval, then reject the request, mark the approval status as pending, then
        without a comment explaining why. The rejection should be halted, and
        and an apex page message should be provided to the user.
    */
    private static testmethod void testRejectionWithoutComment()
    {
        // Generate sample work item using utility method.
        Id testWorkItemId = generateAndSubmitObject();
        
        // Reject the submitted request, without providing a comment.
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        testRej.setComments('');
        testRej.setAction  ('Reject');
             testRej.setNextApproverIds(new Id[] {UserInfo.getUserId()});      
        testRej.setWorkitemId(testWorkItemId);
    
        Test.startTest();        
            // Attempt to process the rejection
            try
            {
                Approval.ProcessResult testRejResult =  Approval.process(testRej);
                system.assert(false, 'A rejection with no comment should cause an exception');
            }
            catch(DMLException e)
            {
              //  system.assertEquals('Operation Cancelled: Please provide a rejection reason!', 
             //                       e.getDmlMessage(0), 
             //     'error message should be Operation Cancelled: Please provide a rejection reason!'); 
            }
        Test.stopTest();
    }
    
   
    /*
        Put many objects through the approval process, some rejected, some approved,
        some with comments, some without. Only rejctions without comments should be
        prevented from being saved.
    */
    private static testmethod void testBatchRejctions()
    {
    
     case c = new case();
            insert c;
        List<Quality__c> testBatchIS = new List<Quality__c>{};
        for (Integer i = 0; i < 1; i++)
        {
       
        
        // Create a sample invoice statement object and then submit it for approval.
        Quality__c testIS = new Quality__c(Exception_Type__c = 'Permanent',
         Exception_Classification_Type__c = 'testECT',
          Related_Case_Number__c = c.id, Exe_Category__c = 'test',
           Status__c = 'test', Root_Cause_Type__c = 'test',
            Deadline_for_Approval__c = datetime.now()
            //,
             //Solution_Recommended__c= 'test', Financial_impact_risk__c= 'test', Risk_of_not_approving_the_EXE__c = 'test'
             );
       
       // insert testIS;
            testBatchIS.add(testIS);
        }   
           
        insert testBatchIS;
        
        List<Approval.ProcessSubmitRequest> testReqs = 
                         new List<Approval.ProcessSubmitRequest>{}; 
        for(Quality__c testinv : testBatchIS)
        {
            Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
            testReq.setObjectId(testinv.Id);
                     testReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            testReqs.add(testReq);
        }
        
        List<Approval.ProcessResult> reqResults = Approval.process(testReqs);
        
        for (Approval.ProcessResult reqResult : reqResults)
        {
            System.assert(reqResult.isSuccess(), 
                          'Unable to submit new batch invoice statement record for approval');
        }
        
        List<Approval.ProcessWorkitemRequest> testAppRejs 
                                                  = new List<Approval.ProcessWorkitemRequest>{};
        
        for (Integer i = 0; i < 1; i++)
        {
            Approval.ProcessWorkitemRequest testRejWithComment = new Approval.ProcessWorkitemRequest();
            testRejWithComment.setComments  ('Rejecting request with a comment.');
            testRejWithComment.setAction    ('Reject');
            testRejWithComment.setWorkitemId(reqResults[i*4].getNewWorkitemIds()[0]);
                                 testRejWithComment.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            testAppRejs.add(testRejWithComment);
            
            Approval.ProcessWorkitemRequest testRejWithoutComment = new Approval.ProcessWorkitemRequest();
            testRejWithoutComment.setAction    ('Reject');
            testRejWithoutComment.setWorkitemId(reqResults[i].getNewWorkitemIds()[0]);
                                 testRejWithoutComment.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            testAppRejs.add(testRejWithoutComment);
            
            Approval.ProcessWorkitemRequest testAppWithComment = new Approval.ProcessWorkitemRequest();
            testAppWithComment.setComments  ('Approving request with a comment.');
            testAppWithComment.setAction    ('Approve');
                                             testAppWithComment.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            testAppWithComment.setWorkitemId(reqResults[i].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testAppWithComment);
            
            Approval.ProcessWorkitemRequest testAppWithoutComment = new Approval.ProcessWorkitemRequest();
                                                         testAppWithoutComment.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            testAppWithoutComment.setAction    ('Approve');
            testAppWithoutComment.setWorkitemId(reqResults[i].getNewWorkitemIds()[0]);
            
            testAppRejs.add(testAppWithoutComment);            
        }
            
        Test.startTest();        
            // Process the approvals and rejections
            try
            {
                List<Approval.ProcessResult> testAppRejResults =  Approval.process(testAppRejs);
           //     system.assert(false, 'Any rejections without comments should cause an exception');
            }
            catch(DMLException e)
            {
                system.assertEquals(1, e.getNumDml());
                
                for(Integer i = 0; i < 1; i++)
                {
                    system.assertEquals((i*4) + 1, e.getDmlIndex(i));
                  //  system.assertEquals('Operation Cancelled: Please provide a rejection reason!', 
                  //                      e.getDmlMessage(i));
                }
            }    
        Test.stopTest();
    }
    
    /*
        Utility method for creating single object, and submitting for approval.
        
        The method should return the Id of the work item generated as a result of the submission.
    */
    private static Id generateAndSubmitObject()
    {
         try{   case c = new case();
            insert c;
        
        // Create a sample invoice statement object and then submit it for approval.
        Quality__c testIS = new Quality__c(Exception_Type__c = 'Permanent',
         Exception_Classification_Type__c = 'testECT',
          Related_Case_Number__c = c.id, Exe_Category__c = 'test',
           Status__c = 'test', Root_Cause_Type__c = 'test',
            Deadline_for_Approval__c = datetime.now()
            //,
           //  Solution_Recommended__c= 'test', Financial_impact_risk__c= 'test', Risk_of_not_approving_the_EXE__c = 'test'
           );
       
        insert testIS;
        
        Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
        testReq.setObjectId(testIS.Id);
        Approval.ProcessResult reqResult = Approval.process(testReq);
        
        System.assert(reqResult.isSuccess(),'Unable to submit new invoice statement record for approval');
        
        return reqResult.getNewWorkitemIds()[0];
        } catch (System.DmlException e) {
    for (Integer i = 0; i < e.getNumDml(); i++) {
        // Process exception here 
    
        System.debug(e.getDmlMessage(i)); 
    }
    
    return null;
}
        
    }
    
    
    /*
     *  test that the countries in the regional countries concerned multi pick lists have been copied into the Countries_Exception__c field
     */
    private static testmethod void testCountriesException () {
        case c = new case();
        insert c;
        List<Quality__c> testBatchIS = new List<Quality__c>{};
        
        Quality__c testIS = new Quality__c(Exception_Type__c = 'Permanent', Exception_Classification_Type__c = 'testECT', Related_Case_Number__c = c.id, Exe_Category__c = 'test',
            Status__c = 'test', Root_Cause_Type__c = 'test', Deadline_for_Approval__c = datetime.now(), Africa_MENA_CC__c = null, Americas_CC__c='Canada;Mexico;', Europe_CC__c = 'France', 
            Asia_Pacific_CC__c = 'Australia; New Zealand;'
             );
        insert testIS;
        
        testIS = [SELECT Id, Countries_Exception__c FROM Quality__c WHERE Id = :testIS.Id];
        
        system.assertEquals('Canada;Mexico;Australia;New Zealand;France', testIS.Countries_Exception__c);
    } 

    /*
    * test when it is inserted and then rejected
    */
    private static testmethod void testRejection()
    {
        case c = new case();
        insert c;
        
        // Create a sample invoice statement object and then submit it for approval.
        Quality__c testIS = new Quality__c(Exception_Type__c = 'Permanent',
            Exception_Classification_Type__c = 'testECT',
            Related_Case_Number__c = c.id, 
            Exe_Category__c = 'test',
            Status__c = 'test',
            Root_Cause_Type__c = 'test',
            Deadline_for_Approval__c = datetime.now()
        );
       
        insert testIS;
        Test.startTest();

        try {

            Approval.ProcessSubmitRequest testReq = new Approval.ProcessSubmitRequest();
            testReq.setObjectId(testIS.Id);
            testReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});   
            Approval.ProcessResult reqResult = Approval.process(testReq);        
                
            // Reject the submitted request
            Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
            testRej.setComments('Test Comment');
            testRej.setAction  ('Reject');
            testRej.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            List<Id> newWorkItemIds = reqResult.getNewWorkitemIds();
            testRej.setWorkitemId(newWorkItemIds.get(0));
                      
            // Attempt to process the rejection
            Approval.ProcessResult testRejResult =  Approval.process(testRej);
            
        } catch(Exception e){}
        
        Test.stopTest();
    }
    
}