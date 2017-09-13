@isTest
private class AutoAssignmentEngineSFTest {

    public static testmethod void test()
    {
    
        SalesforceSupportEmails__c supemails = new SalesforceSupportEmails__c(Name = 'SupUser', Support_Email__c=UserInfo.getUserEmail());
        insert supemails;
        
        System_Settings__c sysset = new System_Settings__c(Name='Europe', Active__c=true, Status__c= 'On', Workload_Weight__c=0.2,Skill_P3_Weighting__c=2.00, Skill_P2_Weighting__c=1.00, Skill_P1_Weighting__c=0.10, Open_Case_Workload_Weighting__c=1.00, In_Progress_Case_Workload_Weighting__c=0.25, Email_on_Error__c = 'test@org.com;test2@org.com');
        insert sysset;
        
        // Turn off all Auto Queues
        Auto_Queue__c[] aQueues=[select id, Active__c from Auto_Queue__c where Active__c=true];
        for (Auto_Queue__c aq:aQueues)
            aq.Active__c=false;
        update  aQueues;
        
        Group g= [select Id, Name from Group where Type = 'Queue' limit 1];
        Auto_Queue__c AQ=new Auto_Queue__c(Active__c=true);
        AQ.Name=g.Name;
        insert AQ;
        Case c=new Case(Subject='test 1', OwnerId=g.Id,Status='Open');
        insert c;
        
        List<Case> casesToAssign = AutoAssignmentEngineSF.getPendingCases();
       // system.assertEquals(casesToAssign.size(), 1);
        test.startTest();
        // 1) Log off all agents
        Agents__c[] aAgent=[select id, Logged_on__c from Agents__c];
        for (Agents__c a:aAgent)
            a.Logged_on__c=false;
        update aAgent;
        
        system.debug('RESULT ====>'+AutoAssignmentEngineSF.assignCase(c.id));
        Case assignCase = [SELECT Id, OwnerId From Case Where Id = :c.id limit 1];
        //No agents available so case should remain in queue
        system.assertEquals(assignCase.OwnerId, g.Id);
        
        // 2) Create an agent with 0 Max Workload
        Agents__c ag=new Agents__c(Logged_on__c =true,Name='Test',Maximum_case_workload__c=0,User__c=UserInfo.getUserId());
        insert ag;
        Case c1=new Case(Subject='test', OwnerId=UserInfo.getUserId(),Status='Open');
        Case c2=new Case(Subject='test', OwnerId=UserInfo.getUserId(),Status='In Progress');
        Case c3=new Case(Subject='', OwnerId=UserInfo.getUserId(),Status='In Progress');
        List<Case> cases = new List<Case>{c1,c2,c3};
        insert cases;
        
        // 3) Create Skills
        Skill_Types__c st=new Skill_Types__c(Name='Subject', Skill_Weight__c=1,Case_Location__c='Subject' );
        insert st;
        Skill__c s1=new Skill__c(Name='test', Skill_Types__c=st.id);
        insert s1;
        Skill__c  s2=new Skill__c(Name='test 1', Skill_Types__c=st.id);
        insert s2;
    
        // 4) Create Skill Assignment
        Skill_Assignment__c sa=new Skill_Assignment__c(Priority__c='1', Skills__c=s1.Id,Agents__c=ag.id); 
        insert sa;
        
        // Assign Case (Test Max workload limit)
        system.debug('RESULT ====>'+AutoAssignmentEngineSF.assignCase(c.id));
        assignCase = [SELECT Id, OwnerId From Case Where Id = :c.id limit 1];
        
        //Available agents are at max workload, so case remains in queue
        system.assertEquals(assignCase.OwnerId, g.Id);
        
        //5) Update agent Max Workload but not skill
        ag.Maximum_case_workload__c=10;
        update ag;
        
        system.debug('RESULT ====>'+AutoAssignmentEngineSF.assignCase(c.id));
        assignCase = [SELECT Id, OwnerId From Case Where Id = :c.id limit 1];
        
        //No agent has skills for this case. Case remains in queue.
        system.assertEquals(assignCase.OwnerId, g.Id);
        
        // Test with skills
        sa=new Skill_Assignment__c(Priority__c='1', Skills__c=s2.Id,Agents__c=ag.id); 
        insert sa;
        
        system.debug('RESULT ====>'+AutoAssignmentEngineSF.assignCase(c.id));
        assignCase = [SELECT Id, OwnerId From Case Where Id = :c.id limit 1];
        
        //Case assigned to user
        system.assertEquals(assignCase.OwnerId, UserInfo.getUserId());
        
        //--------------------
        // 6) Duplicate Case
        //--------------------
        c=new Case(Subject='test 1', OwnerId=g.Id,Status='Open');
        insert c;
        
        system.debug('RESULT ====>'+AutoAssignmentEngineSF.assignCase(c.id));
        assignCase = [SELECT Id, OwnerId From Case Where Id = :c.id limit 1];
        
        //duplicate case also gets assigned
        system.assertEquals(assignCase.OwnerId, UserInfo.getUserId());
        
        
        AutoAssignmentEngineSF batch = new AutoAssignmentEngineSF();
        Database.executeBatch(batch, 1);
        
        string jobId = System.schedule('AutoAssignmentEngineSchedulerTest',
               '0 0 0 15 3 ? 2022', 
        new AutoAssignmentEngineScheduler ());
        
                test.stopTest();

    }
    
}