@isTest
public class portalIftpEmployeeCtrlTest {
    
    static testMethod void portalIftpEmployeeCtrl_test1() {

        portalIftpTestClass.test_config();

        Test.startTest();

        User u2 = [select id, profile.name from user where Email = 'test.cont4@test.com' limit 1];

        List<ContentVersion> docs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion]; 

        Id empItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document'].ContentDocumentId;
        Id empItpId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document2'].ContentDocumentId;
        
        Id stationItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Station Ins Document'].ContentDocumentId;
        Id ItpOJTId = [SELECT Id FROM Document WHERE name = 'OJT Document'].Id;
        
        System.runAs(u2) {

            portalIftpEmployeeCtrl.PagedResult pr = portalIftpEmployeeCtrl.searchEmployeeRecords(true);
            System.assert(pr.totalItemCount > 0, 'Fail to searchEmployeeRecords!');

            String sRoleAddr = 'ITP Trainee';
            List<Account_Contact_Role__c> empList = [Select Id, Contact__c, First_Name__c, Contact__r.accountid from Account_Contact_Role__c];
            
            Id empId = empList[0].Id;
            Id accId = empList[0].Contact__r.accountid;
            String sFirstName = empList[0].First_Name__c;

            List<String> searchValues = new List<String>();
            searchValues.add('ITP');
            searchValues.add('Master');
            searchValues.add('test.cont1@test.com');
            searchValues.add('');
            searchValues.add('PTX');
            List<portalIftpEmployeeCtrl.EmployeeRecordsWrapper> empRecsWrapList = new List<portalIftpEmployeeCtrl.EmployeeRecordsWrapper>();
            empRecsWrapList = portalIftpEmployeeCtrl.getEmployeeRecords(searchValues, accId);
            System.assert(empRecsWrapList.isEmpty());


            List<String> searchValues2 = new List<String>();
            searchValues2.add(sFirstName);
            searchValues2.add('');
            searchValues2.add('');
            searchValues2.add('');
            searchValues2.add('');
            List<portalIftpEmployeeCtrl.EmployeeRecordsWrapper> empRecsWrapList2 = new List<portalIftpEmployeeCtrl.EmployeeRecordsWrapper>();
            empRecsWrapList2 = portalIftpEmployeeCtrl.getEmployeeRecords(searchValues2, accId);
            System.assert(empRecsWrapList2.size() > 0, 'Fail to getEmployeeRecords');

            List<Contact_Role_Certification__c> crcs = [Select Id, Proficiency__c from Contact_Role_Certification__c];
            for(Contact_Role_Certification__c crc : crcs ){
                crc.Proficiency__c = 'Level 3';
            }
            Boolean test = portalIftpEmployeeCtrl.updateCertificationProficiency(crcs);
            System.assert(test);

        }
        Test.stopTest();
    }
}