@isTest
private class SIDRAliteMassEmailBatchTest {

    @isTest
    static void testSchedule() {
        Test.startTest();
        SIDRAliteMassEmailBatch batch = new SIDRAliteMassEmailBatch(new List<Case>(), 'template', 'type');
    	ID batchprocessid = Database.executeBatch(batch,5);
        Test.StopTest();
    }
}
