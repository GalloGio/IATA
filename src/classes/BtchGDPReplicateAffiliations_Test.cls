@isTest
private class BtchGDPReplicateAffiliations_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAffiliations testData = new TestData.ForReplicateAffiliations();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            BtchGDPReplicateAffiliations batch = new BtchGDPReplicateAffiliations();
            batch.query = 'SELECT id, Assoc_Affiliation_ID__c, Assoc_Affiliation_Code__c, AIMS_ID__c, Related_Account__r.IATACode__c, Related_Account__r.WebStar_ID__c'
            +' FROM Assoc_Affiliation_Membership__c LIMIT 5';
            // try {
                Database.executeBatch(batch, 5);
            // } catch(Exception e) {}
            Test.stopTest(); 
        }
    }
}