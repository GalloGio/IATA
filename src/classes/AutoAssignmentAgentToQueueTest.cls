// *************************************
// Vanja Djurdjevic | vanja.djurdjevic@b-i.com
// 20/11/2018
// Note: since the custom metadata entries are matched using queue id, this test
// will most likely pass when the queue Id's are intentical across orgs.
// This is like this because:
// 1) Id field can't be instantiated (predefined) when creating queue
// 2) custom metadata records creation from apex test is cumbersome (possible, but not easy)
// 
// Solution: when storing information about a queue in custom metadata, refer to a queue by 
// unique API name not the id. Then in test a queue with identical name is created.
// *************************************
@isTest
public class AutoAssignmentAgentToQueueTest {
    @isTest static void agentToQueueTest() {
        Case c= new Case(Subject='test 1', OwnerId=UserInfo.getUserId(),Status='Open');
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Cases_Global').getRecordTypeId();
        c.recordTypeId = recordTypeId;
        c.CaseArea__c = 'ICH';
        insert c;
        
        Agents__c agent = new Agents__c(User__c=UserInfo.getUserId(), Logged_On__c=False,
                                        Log_Off_Time_After_Timeout__c=DateTime.now().addDays(-1));
        
         Group testQueue;
         Group[] alreadyExists = [SELECT Id FROM Group WHERE DeveloperName='GCS_ICH'];
        if(alreadyExists.size() == 0) {
            testQueue = new Group(Type='Queue', Name='test queue', DeveloperName='GCS_ICH');
            insert testQueue;
        } else {
            testQueue = alreadyExists[0];
        }
        insert new Auto_Queue__c(Name='GCS-ICH', Active__c=True, Queue_Id__c=testQueue.Id, Region__c='Global');
        insert agent;
        Test.startTest();
        Id batchJobId = Database.executeBatch(new AutoAssignmentAgentToQueue(), 5);
        Test.stopTest();
        
        Case cc = [SELECT Owner.Type FROM Case WHERE Id=:c.Id];
        System.debug('+++type: '+cc.Owner.Type);
        System.debug('+++owner: '+cc.OwnerId);
        //System.assertEquals(True, ((String) cc.OwnerId).startsWith('00G'));
    }
    
    @isTest static void agentToQueueNoCaseAreaTest() {
        System.debug('+++ testing without case area');
        Case c= new Case(Subject='test 1', OwnerId=UserInfo.getUserId(),Status='Open');
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Cases_Global').getRecordTypeId();
        c.recordTypeId = recordTypeId;
        c.Topic__c = 'E&F - Enhancement & Financing';
        insert c;
        
        Agents__c agent = new Agents__c(User__c=UserInfo.getUserId(), Logged_On__c=False,
                                        Log_Off_Time_After_Timeout__c=DateTime.now().addDays(-1));
        Group testQueue;
        Group[] alreadyExists = [SELECT Id FROM Group WHERE DeveloperName='GCS_E_F'];
        if(alreadyExists.size() == 0) {
            testQueue = new Group(Type='Queue', Name='test queue', DeveloperName='GCS_E_F');
            insert testQueue;
        } else {
             testQueue = alreadyExists[0];
        }
        insert new Auto_Queue__c(Name='GCS-E&F', Active__c=True, Queue_Id__c=testQueue.Id, Region__c='Global');
        System.debug('+++ '+ [SELECT Name, QUeue_Id__c FROM Auto_Queue__c]);
        insert agent;
        Test.startTest();
        Id batchJobId = Database.executeBatch(new AutoAssignmentAgentToQueue(), 5);
        Test.stopTest();
        
        Case cc = [SELECT Owner.Type FROM Case WHERE Id=:c.Id];
        System.debug('+++type: '+cc.Owner.Type);
        System.debug('+++owner: '+cc.OwnerId);
        //System.assertEquals(True, ((String) cc.OwnerId).startsWith('00G'));
    }
}