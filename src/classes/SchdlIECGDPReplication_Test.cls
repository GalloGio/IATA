@isTest
private class SchdlIECGDPReplication_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAgencyProfiles testData = new TestData.ForReplicateAgencyProfiles();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            System.schedule('testBasicScheduledApex', CRON_EXP, new SchdlIECGDPReplication());
            Test.stopTest(); 
        }
    }
}