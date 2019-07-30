@isTest
public class AutoAssignmentEngineSFSchedulerTest {
    static testMethod void testMethod1() {

        SalesforceSupportEmails__c supemails = new SalesforceSupportEmails__c(Name = 'SupUser', Support_Email__c=UserInfo.getUserEmail());
        insert supemails;
        
        System_Settings__c sysset = new System_Settings__c(Name='Europe', Active__c=true, Status__c= 'On', Workload_Weight__c=0.2,Skill_P3_Weighting__c=2.00, Skill_P2_Weighting__c=1.00, Skill_P1_Weighting__c=0.10, Open_Case_Workload_Weighting__c=1.00, In_Progress_Case_Workload_Weighting__c=0.25, Email_on_Error__c = 'test@org.com;test2@org.com');
        insert sysset;

        Group g = [select Id, Name from Group where Type = 'Queue' limit 1];
        Auto_Queue__c AQ = new Auto_Queue__c(Active__c=true);
        AQ.Name = g.Name;
        insert AQ;
        
        Case c = new Case(Subject='test 1', OwnerId=g.Id,Status='Open');
        insert c;        
       
        test.startTest();
        AutoAssignmentEngineSFScheduler bScheduler = new AutoAssignmentEngineSFScheduler();
        String sch = '20 30 8 10 2 ?';
        system.schedule('Test AutoAssignmentEngineSFScheduler', sch, bScheduler);        
        test.stopTest();
        
    }
}