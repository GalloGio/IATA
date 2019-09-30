@IsTest
private class portalIftpHistoryManagementTest {

    @IsTest
    static void InsertIftpHistoryRecordsTest(){
        portalIftpTestClass.test_config();
        Test.startTest();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];
        

        System.runAs(u1) {
            IFTP_History__c ih = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_for_ITP, 
                                                                                'Abc', 
                                                                                'ITP Student', 
                                                                                'Student');
            portalIftpHistoryManagement.insertIntoIftpHistory(ih);

            List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();
            IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_at_Station, 
                                                            'Abc', 
                                                            'ITP Student', 
                                                            'Student',
                                                            'PTX',
                                                            'Lisbon'
                                                            );
            IftpHistoryRecordsToBeInserted.add(ihrec);

            IFTP_History__c ihrec2 = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Loose_Proficiency, 
                                                'Abc', 
                                                'ITP Student', 
                                                'Student',
                                                'PTX',
                                                'Lisbon',
                                                'A320 L2',
                                                'Yes',
                                                'Coordinator, ITP Training'
                                                );
            IftpHistoryRecordsToBeInserted.add(ihrec2);

            portalIftpHistoryManagement.insertIntoIftpHistory(IftpHistoryRecordsToBeInserted);

        }
        Test.stopTest();
    }

}