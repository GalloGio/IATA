@isTest
private class BtchGDPReplicateAddress_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAddress testData = new TestData.ForReplicateAddress();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            BtchGDPReplicateAddress batch = new BtchGDPReplicateAddress();
            // batch.idRecordTypeGDP = [SELECT Id FROM RecordType WHERE SobjectType = 'GDP_Products_Account_View__c'][0].Id;
            batch.query = 'SELECT id, Address_City__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Postal_Code__c, Address_Type__c, GDP_Geo_Detail__c, IATA_ISO_Country__c, IATA_ISO_State__c, Related_Account__r.AIMS_ID__c, Related_Account__r.IATACode__c, Related_Account__r.WebStar_ID__c, AIMS_ID__c'
            +' FROM GDP_Address__c LIMIT 5';
            // try {
                Database.executeBatch(batch, 5);
            // } catch(Exception e) {}
            Test.stopTest(); 
        }
    }
}