@isTest
private class BtchGDPReplicateAgencyOwner_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAgencyOwner testData = new TestData.ForReplicateAgencyOwner();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            BtchGDPReplicateAgencyOwner batch = new BtchGDPReplicateAgencyOwner();
            // batch.idRecordTypeGDP = [SELECT Id FROM RecordType WHERE SobjectType = 'GDP_Products_Account_View__c'][0].Id;
            batch.query = 'SELECT id, Name, Owner_ID__c, Percent__c, AIMS_ID__c, Related_Account__r.IATACode__c, Related_Account__r.WebStar_ID__c'
            +' FROM Agency_Owner__c LIMIT 5';
            // try {
                Database.executeBatch(batch, 5);
            // } catch(Exception e) {}
            Test.stopTest(); 
        }
    }
}