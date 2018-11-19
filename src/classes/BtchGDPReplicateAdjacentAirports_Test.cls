@isTest
private class BtchGDPReplicateAdjacentAirports_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAdjacentAirports testData = new TestData.ForReplicateAdjacentAirports();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            BtchGDPReplicateAdjacentAirports batch = new BtchGDPReplicateAdjacentAirports();
            batch.query = 'SELECT id, Airport_ID__c, AirportCode__c, AIMS_ID__c, Related_Account__r.IATACode__c, Related_Account__r.WebStar_ID__c'
            +' FROM Adjacent_Airport__c LIMIT 5';
            // try {
                Database.executeBatch(batch, 5);
            // } catch(Exception e) {}
            Test.stopTest(); 
        }
    }
}