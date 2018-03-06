@isTest
private class IEC_ZuoraPricing2SAP_Scheduler_Test
{
    //****************************************************************************************************
    //  Cover code of class "IEC_ZuoraPricing2SAP_Scheduler"
    //****************************************************************************************************


    @isTest static void testAllMethod()
    {
        String strQueryJob = 'select count() from AsyncApexJob where ApexClass.Name = \'IEC_ZuoraPricing2SAP_Scheduler\'';
        String strQueryJobQueued = strQueryJob + ' and Status = \'Queued\'';
        Integer countJob = Database.countQuery(strQueryJob);
        Integer countQueuedJob = Database.countQuery(strQueryJobQueued);
        Test.startTest();
            IEC_ZuoraPricing2SAP_Scheduler.scheduleNextJob();
        Test.stopTest();
        system.assertEquals(Database.countQuery(strQueryJob), countJob + 2, 'Should have 2 more jobs');
        system.assertEquals(Database.countQuery(strQueryJobQueued), countQueuedJob + 1, 'Should have 1 more queued job');
    }
}