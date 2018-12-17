@isTest
public class AutoAssignmentEngineSFSchedulerTest {
    static testMethod void testMethod1() {
        
        Test.startTest();
        
        AutoAssignmentEngineSFScheduler bScheduler = new AutoAssignmentEngineSFScheduler();
        String sch = '20 30 8 10 2 ?';
        system.schedule('Test AutoAssignmentEngineSFScheduler', sch, bScheduler);
        
        Test.stopTest();
        
    }
}