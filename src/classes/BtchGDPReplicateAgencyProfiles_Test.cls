@isTest
private class BtchGDPReplicateAgencyProfiles_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAgencyProfiles testData = new TestData.ForReplicateAgencyProfiles();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            BtchGDPReplicateAgencyProfiles batch = new BtchGDPReplicateAgencyProfiles();
            // batch.idRecordTypeGDP = [SELECT Id FROM RecordType WHERE SobjectType = 'GDP_Products_Account_View__c'][0].Id;
            batch.query = 'SELECT id, Main_Activity__c, Main_Destination_Specialization__c, Main_Market_Specialization__c, Market_Focus_Corporate__c, Market_Focus_Leisure__c, Sales_Accomodation__c, Sales_Air__c, AIMS_ID__c, Related_Account__r.IATACode__c, Related_Account__r.WebStar_ID__c'
            + ', Sales_Land__c, Sales_Sea__c, Sales_Tour__c, Sales_Volume__c, Secondary_Destination_Specialization__c, Secondary_Market_Specialization__c, Tertiary_Destination_Specialization__c, Tertiary_Market_Specialization__c'
            +' FROM GDP_Agency_Profile_Specialization__c LIMIT 5';
            // try {
                Database.executeBatch(batch, 5);
            // } catch(Exception e) {}
            Test.stopTest(); 
        }
    }
}