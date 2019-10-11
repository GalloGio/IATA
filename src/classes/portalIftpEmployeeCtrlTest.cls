@isTest
public class portalIftpEmployeeCtrlTest {
    
    static testMethod void portalIftpEmployeeCtrl_test1() {

        portalIftpTestClass.test_config();

        Test.startTest();

        User u2 = [select id, profile.name from user where Email = 'test.cont4@test.com' limit 1];

        System.debug('u2 - ' + u2);

        // List<Document> docs = [SELECT Id,name FROM Document]; 
        List<ContentVersion> docs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion]; 
        System.debug('docs: ' + docs);

        Id empItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document'].ContentDocumentId;
        Id empItpId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document2'].ContentDocumentId;
        
        Id stationItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Station Ins Document'].ContentDocumentId;
        Id ItpOJTId = [SELECT Id FROM Document WHERE name = 'OJT Document'].Id;
        
        System.runAs(u2) {

            portalIftpEmployeeCtrl.PagedResult pr = portalIftpEmployeeCtrl.searchEmployeeRecords(true);

            String sRoleAddr = 'ITP Trainee';
            List<Account_Contact_Role__c> empList = [Select Id, Contact__c, First_Name__c, Contact__r.accountid from Account_Contact_Role__c];
            System.debug('empList: ' + empList);
            
            Id empId = empList[0].Id;
            Id accId = empList[0].Contact__r.accountid;
            String sFirstName = empList[0].First_Name__c;

            System.debug('accId: ' + accId);
            System.debug('sFirstName: ' + sFirstName);

            // auxSearchValues = [
            // this.firstNameValue,
            // this.lastNameValue,   
            // this.emailValue,
            // this.employeeCodeValue,
            // this.stationValue
            // ];
            List<String> searchValues = new List<String>();
            searchValues.add('ITP');
            searchValues.add('Master');
            searchValues.add('test.cont1@test.com');
            searchValues.add('');
            searchValues.add('PTX');
            
            List<portalIftpEmployeeCtrl.EmployeeRecordsWrapper> empRecsWrapList = portalIftpEmployeeCtrl.getEmployeeRecords(searchValues, accId);

            List<String> searchValues2 = new List<String>();
            searchValues2.add(sFirstName);
            searchValues2.add('');
            searchValues2.add('');
            searchValues2.add('');
            searchValues2.add('');

            List<portalIftpEmployeeCtrl.EmployeeRecordsWrapper> empRecsWrapList2 = portalIftpEmployeeCtrl.getEmployeeRecords(searchValues2, accId);

            //dataToSave.push({ Id: auxData[el].certificationId, Proficiency__c: auxData[el].setProficiency });
            //public static Boolean updateCertificationProficiency(List<Object> dataToSave){
            List<Contact_Role_Certification__c> crcs = [Select Id, Proficiency__c from Contact_Role_Certification__c];
            for(Contact_Role_Certification__c crc : crcs ){
                crc.Proficiency__c = 'Level 3';
            }
            Boolean test = portalIftpEmployeeCtrl.updateCertificationProficiency(crcs);
        }
    }
}