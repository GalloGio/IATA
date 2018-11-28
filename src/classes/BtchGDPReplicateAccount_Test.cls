@isTest
private class BtchGDPReplicateAccount_Test {
    static testMethod void test_AllMethod() {
        TestData.ForReplicateAccount testData = new TestData.ForReplicateAccount();
        System.runAs(testData.user) {
            TestUtilities.createIECGDPReplicationSetting(true);
            Test.startTest();
            BtchGDPReplicateAccount batch = new BtchGDPReplicateAccount();
            batch.idRecordTypeGDP = RecordTypeSingleton.getInstance().getRecordTypeId('GDP_Products_Account_View__c', 'GDP');
            batch.query = 'SELECT id, IATACode__c, CASS_Number__c, CASS_Number_Xref__c, GDP_Location_Type__c, Airline_Code__c, Email__c, Website, Name, TradeName__c, Parent.WebStar_ID__c'
            + ', TTY__c, Passenger_And_Cargo__c, Incorporation_Type__c, GDP_Opt_In__c, Tax_ID_1__c, Tax_ID_2__c, BSP_CASS_Code__c, License_Number__c, AIMS_ID__c, ParentId'
            + ', Preferred_Language__c, Ticketing_Agent_Last_Name__c, Ticketing_Agent_First_Name__c, Manager_Last_Name__c, Manager_First_Name__c, Short_Name__c'
            +' FROM Account LIMIT 5';
            // try {
                Database.executeBatch(batch, 5);
            // } catch(Exception e) {}
            Test.stopTest(); 
        }
    }
}