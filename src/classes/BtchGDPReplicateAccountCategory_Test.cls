@isTest
private class BtchGDPReplicateAccountCategory_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAccountCategory testData = new TestData.ForReplicateAccountCategory();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            BtchGDPReplicateAccountCategory batch = new BtchGDPReplicateAccountCategory();
            // batch.idRecordTypeGDP = [SELECT Id FROM RecordType WHERE SobjectType = 'GDP_Products_Account_View__c'][0].Id;
            batch.query = 'SELECT id, Category_ID__c, Category_Code__c, AIMS_ID__c, Related_Account__r.IATACode__c, WebStar_ID__c'
            +' FROM Account_Category__c LIMIT 5';
            // try {
                Database.executeBatch(batch, 5);
            // } catch(Exception e) {}
            Test.stopTest(); 
        }
    }
}