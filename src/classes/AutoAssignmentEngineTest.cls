@isTest
private class AutoAssignmentEngineTest {

	public static testmethod void test1()
	{

		System_Settings__c sysset = new System_Settings__c(Name='Europe', Active__c=true, Status__c= 'On', Workload_Weight__c=0.2,Skill_P3_Weighting__c=2.00, Skill_P2_Weighting__c=1.00, Skill_P1_Weighting__c=0.10, Open_Case_Workload_Weighting__c=1.00, In_Progress_Case_Workload_Weighting__c=0.25, Email_on_Error__c = 'test@org.com;test2@org.com');
		insert sysset;

		//assignCase('50020000005ie2ZAAQ');
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
		AutoAssignmentEngine.getPendingCases();

		// 1) Log off all agents
		Agents__c[] aAgent=[select id, Logged_on__c from Agents__c];
		for (Agents__c a:aAgent)
			a.Logged_on__c=false;
		update aAgent;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		// 2) Create an agent with 0 Max Workload
		Agents__c ag=new Agents__c(Logged_on__c =true,Name='Test',Maximum_case_workload__c=0,User__c=UserInfo.getUserId());
		insert ag;
		Case c1=new Case(Subject='test', OwnerId=UserInfo.getUserId(),Status='Open');
		//insert c1;
		Case c2=new Case(Subject='test', OwnerId=UserInfo.getUserId(),Status='In Progress');
		//insert c2;
		//insert c1;
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
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		//5) Update agent Max Workload but not skill
		ag.Maximum_case_workload__c=10;
		update ag;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		// Test with skills
		sa=new Skill_Assignment__c(Priority__c='1', Skills__c=s2.Id,Agents__c=ag.id);
		insert sa;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		//--------------------
		// 6) Duplicate Case
		//--------------------
		c=new Case(Subject='test 1', OwnerId=g.Id,Status='Open');
		insert c;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

	}
	public static testmethod void test()
	{

		//assignCase('50020000005ie2ZAAQ');
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
		AutoAssignmentEngine.getPendingCases();

		// 1) Log off all agents
		Agents__c[] aAgent=[select id,Region__c, Logged_on__c from Agents__c];
		for (Agents__c a:aAgent)
			a.Logged_on__c=false;
		update aAgent;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		// 2) Create an agent with 0 Max Workload
		Agents__c ag=new Agents__c(Region__c= 'Europe',Logged_on__c =true,Name='Test',Maximum_case_workload__c=0,User__c=UserInfo.getUserId());
		insert ag;
		Case c1=new Case(Subject='test', OwnerId=UserInfo.getUserId(),Status='Open');
		insert c1;
		Case c2=new Case(Subject='test', OwnerId=UserInfo.getUserId(),Status='In Progress');
		insert c2;

		// 3) Create Skills
		Skill_Types__c st=new Skill_Types__c(Region__c='Europe',Name='Subject', Skill_Weight__c=1,Case_Location__c='Subject' );
		insert st;
		Skill__c s1=new Skill__c(Name='test', Skill_Types__c=st.id);
		insert s1;
		Skill__c  s2=new Skill__c(Name='test 1', Skill_Types__c=st.id);
		insert s2;

		// 4) Create Skill Assignment
		Skill_Assignment__c sa=new Skill_Assignment__c(Priority__c='1', Skills__c=s1.Id,Agents__c=ag.id);
		insert sa;

		// Assign Case (Test Max workload limit)
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		//5) Update agent Max Workload but not skill
		ag.Maximum_case_workload__c=10;
		update ag;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		// Test with skills
		sa=new Skill_Assignment__c(Priority__c='1', Skills__c=s2.Id,Agents__c=ag.id);
		insert sa;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		//--------------------
		// 6) Duplicate Case
		//--------------------
		c=new Case(Subject='test 1', OwnerId=g.Id,Status='Open');
		insert c;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		Case c5=new Case(Subject='test 2', OwnerId=g.Id,Status='Escalated');
		insert c5;

	}


	public static testmethod void testAfricaMiddleEast()
	{
		string region = 'Africa & Middle East';

		//assignCase('50020000005ie2ZAAQ');
		// Turn off all Auto Queues
		Auto_Queue__c[] aQueues = [select id, Active__c from Auto_Queue__c where Active__c=true];
		for (Auto_Queue__c aq:aQueues)
			aq.Active__c=false;
		update  aQueues;

		Group g = [select Id, Name from Group where Type = 'Queue' and Name = 'Customer Service - Africa & MENA' limit 1];
		Auto_Queue__c AQ = new Auto_Queue__c(Active__c=true);
		AQ.Name = g.Name;
		AQ.Region__c = region;
		insert AQ;
		Case c=new Case(Subject='test 1', OwnerId=g.Id, Status='Open');
		insert c;
		AutoAssignmentEngine.getPendingCases();

		// 1) Log off all agents
		Agents__c[] aAgent = [select id, Logged_on__c from Agents__c];
		for (Agents__c a:aAgent)
			a.Logged_on__c = false;
		update aAgent;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		// 2) Create an agent with 0 Max Workload
		Agents__c ag = new Agents__c(Logged_on__c = true, Name = 'Test', Maximum_case_workload__c = 0, User__c = UserInfo.getUserId());
		ag.Region__c = region;
		insert ag;
		//Case c1=new Case(Subject='test', OwnerId=UserInfo.getUserId(), Status='Open');
		Case c1=new Case(Subject='test', OwnerId=g.Id, Status='Open');
		insert c1;
		//Case c2=new Case(Subject='test', OwnerId=UserInfo.getUserId(), Status='In Progress');
		Case c2=new Case(Subject='test', OwnerId=g.Id, Status='In Progress');
		insert c2;

		// 3) Create Skills
		Skill_Types__c st = new Skill_Types__c(Name = 'Subject', Skill_Weight__c = 1, Case_Location__c = 'Subject');
		insert st;
		Skill__c s1 = new Skill__c(Name = 'test', Skill_Types__c = st.id);
		insert s1;
		Skill__c s2 = new Skill__c(Name = 'test 1', Skill_Types__c = st.id);
		insert s2;

		// 4) Create Skill Assignment
		Skill_Assignment__c sa = new Skill_Assignment__c(Priority__c = '1', Skills__c = s1.Id, Agents__c = ag.id);
		insert sa;

		// Assign Case (Test Max workload limit)
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		//5) Update agent Max Workload but not skill
		ag.Maximum_case_workload__c = 10;
		update ag;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		// Test with skills
		sa=new Skill_Assignment__c(Priority__c = '1', Skills__c = s2.Id, Agents__c = ag.id);
		insert sa;
		sa=new Skill_Assignment__c(Priority__c = '2', Skills__c = s2.Id, Agents__c = ag.id);
		insert sa;
		system.debug('RESULT ====>'+AutoAssignmentEngine.assignCase(c.id));

		//--------------------
		// 6) Duplicate Case
		//--------------------
		Case dupCase = new Case(Subject = 'test 1', OwnerId = g.Id, Status = 'Open');
		insert dupCase;
		system.debug('RESULT ====>' + AutoAssignmentEngine.assignCase(dupCase.id));

	}
}
