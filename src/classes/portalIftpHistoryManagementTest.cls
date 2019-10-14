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
            System.assertEquals(2, Integer.valueof(ih.Event_Type__c));                                   

            List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();
            IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_at_Station, 
                                                            'Abc', 
                                                            'ITP Student', 
                                                            'Student',
                                                            'PTX',
                                                            'Lisbon'
                                                            );                                    
            System.assertEquals(4, Integer.valueof(ihrec.Event_Type__c));
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
                                    
            System.assertEquals(4, Integer.valueof(ihrec.Event_Type__c));
            IftpHistoryRecordsToBeInserted.add(ihrec2);

            portalIftpHistoryManagement.insertIntoIftpHistory(IftpHistoryRecordsToBeInserted);

        }
        Test.stopTest();
    }

    @IsTest
    static void getProficiencyReportTest(){
        portalIftpTestClass.test_config();
        Test.startTest();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];
        

        System.runAs(u1) {
            portalIftpHistoryManagement.LoggedUserInfoWrapper loggedUserInfo = portalIftpHistoryManagement.getLoggedUserNameStr();
            String ITP_Name = loggedUserInfo.ITP_name;

            List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();
            IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_for_ITP, 
                                                'Abc', 
                                                'ITP Student',
                                                'Student'
                                                );
            System.assertEquals(1, Integer.valueof(ihrec.Event_Type__c));

            IftpHistoryRecordsToBeInserted.add(ihrec);                                                            

            IFTP_History__c ihrec2 = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Receives_Proficiency, 
                                                'Abc', 
                                                'ITP Student', 
                                                'Student',
                                                'PTX',
                                                'Lisbon',
                                                'A320 L2',
                                                'Yes',
                                                'Coordinator, ITP Training'
                                                );
            System.assertEquals(5, Integer.valueof(ihrec2.Event_Type__c));

            IftpHistoryRecordsToBeInserted.add(ihrec2);

            IFTP_History__c ihrec3 = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_for_ITP, 
                                                'Cba', 
                                                'ITP Student2', 
                                                'Student2'
                                                );
            System.assertEquals(1, Integer.valueof(ihrec3.Event_Type__c));
                                             
            IftpHistoryRecordsToBeInserted.add(ihrec3);

            System.assert(IftpHistoryRecordsToBeInserted.size() > 0, 'Fail IftpHistoryRecordsToBeInserted list is empty!'); 
            portalIftpHistoryManagement.insertIntoIftpHistory(IftpHistoryRecordsToBeInserted);

            String monthValue = String.valueOf( Date.Today().month() );
            String yearValue = String.valueOf( Date.Today().year() );            

            List<portalIftpHistoryManagement.ITPReportWrapper> report = new List<portalIftpHistoryManagement.ITPReportWrapper>();
            report = portalIftpHistoryManagement.getProficiencyReport(ITP_Name, monthValue, yearValue);
            System.assert(report.size() > 0, 'Fail getProficiencyReport list is empty!'); 

        }
        Test.stopTest();
    }

}