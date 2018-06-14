@isTest
private class BtchGDPReplicateAccreditation_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAccreditation testData = new TestData.ForReplicateAccreditation();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            BtchGDPReplicateAccreditation batch = new BtchGDPReplicateAccreditation();
            batch.query = 'SELECT id, Related_Account__c, Related_Account__r.IATACode__c, Accreditation_ID__c, Class__c, Last_change_date__c, Last_re_inspection_date__c'
            +', Original_approval_date__c, Status__c, Date__c, AIMS_ID__c, WebStar_ID__c, Related_Account__r.AIMS_ID__c FROM Accreditation__c LIMIT 5';
            // try {
                Database.executeBatch(batch, 5);
            // } catch(Exception e) {}
            Test.stopTest(); 
        }
    }
}