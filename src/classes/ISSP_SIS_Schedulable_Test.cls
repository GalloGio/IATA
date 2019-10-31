@isTest
private class ISSP_SIS_Schedulable_Test{
    
    @isTest
    static void testInvokeSisModifyUser(){
        Test.startTest();
        System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(new List<Id>{}, 'invokeSisModifyUser'));
        Test.stopTest();
    }

    @isTest
    static void testInvokeSisDeactivateUsers(){
        Test.startTest();
        System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(new List<Id>{}, 'invokeSisDeactivateUsers'));
        Test.stopTest();
    }

    @isTest
    static void testInvokeSisActivateUsers(){
        Test.startTest();
        System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(new List<Id>{}, 'invokeSisActivateUsers'));
        Test.stopTest();
    }

    @isTest
    static void testInvokeCreateAccount(){
        Test.startTest();
        System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(new List<Id>{}, 'invokeCreateAccount'));
        Test.stopTest();
    }

    @isTest
    static void testInvokeUpdateAccount(){
        Test.startTest();
        System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(new List<Id>{}, 'invokeUpdateAccount'));
        Test.stopTest();
    }

    @isTest
    static void testInvokeGiveSISAppToAccountUsers(){
        Test.startTest();
        System.schedule('ScheduledJob ' + String.valueOf(Math.random()), ISSP_SIS_Schedulable.getNextFireTime(), new ISSP_SIS_Schedulable(new List<Id>{}, 'invokeGiveSISAppToAccountUsers'));
        Test.stopTest();
    }
}