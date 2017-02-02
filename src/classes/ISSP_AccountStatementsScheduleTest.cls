@isTest
private class ISSP_AccountStatementsScheduleTest {

    private static void loadData() {
        Notification_template__c nt = new Notification_template__c(
            Subject__c = 'Test 001',
            Type__c = 'Action',
            Admins_Users__c = 'User',
            Message__c = 'test {0}',
            Notification_color__c = '#007FFF'
        );
        insert nt;

        ISSP_Notifications_Trigger__c ntr = new ISSP_Notifications_Trigger__c(
            Name = 'Account Statements',
            Notification_Template_Id__c = nt.Id
        );
        insert ntr;
    }

    static testMethod void testSchedule1() {
        loadData();

        // run schedule
        Test.StartTest();
        ISSP_AccountStatementsSchedule schedule = new ISSP_AccountStatementsSchedule();
    	String sch = '20 30 8 10 2 ?';
    	String jobID = system.schedule('test job', sch, schedule);
        Test.StopTest();
    }

    static testMethod void testSchedule2() {
        loadData();

        // run schedule
        Test.StartTest();
        ISSP_AccountStatementsSchedule schedule = new ISSP_AccountStatementsSchedule('Americas',1);
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('test job', sch, schedule);
        Test.StopTest();
    }

 }
