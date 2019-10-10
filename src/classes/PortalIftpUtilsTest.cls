@isTest
public class PortalIftpUtilsTest {
    
    static testMethod void portalIftpUtils_test1() {

        portalIftpTestClass.test_config();

        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];

        Test.startTest();

        System.runAs(u2) {

            String sRoleAddr = 'ITP Trainee';
            List<Account_Contact_Role__c> empList = [Select Id, Contact__C, Contact__r.accountid from Account_Contact_Role__c];
            
            Id empId = empList[0].Id;
            Id accId = empList[0].Contact__r.accountid;

            List<Id> empIdsList = new List<Id>();
            for(Account_Contact_Role__c rec : empList){
                empIdsList.add(rec.Id);
            }
            

            Map<Id, List<Address__c>> addMapList1 = PortalIftpUtils.getEmployeesStations(empIdsList);

            List<Account_Contact_Role__c> accRoleList1 = PortalIftpUtils.getITPEmployees(accId);

            List<Account_Contact_Role__c> accRoleList2 = PortalIftEmployeeRecordsManagement.getAllITPEmployees();

            List<Account_Contact_Role__c> accRoleList3 = PortalIftpUtils.getITPEmployeesWithStationsInfo(accId);

        }
        Test.stopTest();
    }

    
    static testMethod void portalIftpUtils_test1_1() {

        portalIftpTestClass.test_config();

        Test.startTest();
        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
        System.runAs(u2) {

            PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            List<Address__c> addList2 = PortalIftpUtils.getAllStations();

            List<Address__c> addList3 = PortalIftpUtils.getITPStations();


            List<PortalIftpUtils.StationRecordsWrapper> swrap = PortalIftpUtils.getITPStationsForDatatable();

            List<Role_Address__c> roleAddrList = PortalIftpUtils.getITPConnectedToAirlineByStation('PTX');

            List<Role_Address__c> roleAddrList2 = PortalIftpUtils.getITPConnectedToAirlineByStations(new List<String>{'PTX','GVX'});

            List<Certification__c> cert1 = PortalIftpUtils.getCertificationTypes(null);
            List<Certification__c> cert2 = PortalIftpUtils.getCertificationTypes('Aircraft');
            List<IFTP_Certification_DEtail__c> cert3 = PortalIftpUtils.getCertificationTypesWithLevel('Aircraft');
            List<IFTP_Certification_DEtail__c> cert4 = PortalIftpUtils.getCertificationTypesWithLevel('');

        }
        Test.stopTest();
    }

        static testMethod void portalIftpUtils_test1_2() {

        portalIftpTestClass.test_config();

        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];

        Id empItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document'].ContentDocumentId;
        Id empItpId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document2'].ContentDocumentId;
        Id stationItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Station Ins Document'].ContentDocumentId;
        Id ItpOJTId = [SELECT Id FROM Document WHERE name = 'OJT Document'].Id;
        Id add2Id = [Select Id From Address__c where Code__c = 'GVX' limit 1].Id;
        List<Role_Address__c> roleAddrList3 = [Select Id, Description__c, Address__c, Name, Account_Role_Service__c from Role_Address__c];

        Test.startTest();

        System.runAs(u2) {

            Integer i = 0;
            for(Role_Address__c roleAddr : roleAddrList3){
                i++;
                roleAddr.Description__c = 'test upd ' + i;
            }
            PortalIftpUtils.InsertStationWrapper updStationWrapper = PortalIftpUtils.updateStation(roleAddrList3, null);


            Address__c addr = PortalIftpUtils.getITPStationEmployees(add2Id);
            
            List<PortalIftpUtils.ImportResultsWrapper> irw1 = PortalIftpUtils.importStationsCSVFile(stationItpId);

            List<PortalIftpUtils.ImportResultsWrapper> irw2 = PortalIftpUtils.importEmployeesCSVFile(empItpId);
            List<PortalIftpUtils.ImportResultsWrapper> irw3 = PortalIftpUtils.importEmployeesCSVFile(empItpId2);

            
            PortalIftpUtils.manageUploadGlobalOJT(ItpOJTId);

            PortalIftpUtils.manageUploadStationOJT(ItpOJTId, roleAddrList3[0].Id);

        }
        Test.stopTest();
    }


    static testMethod void portalIftpUtils_test2() {

        AccountRole__e are = New AccountRole__e(EventType__c = 'test', RecordId__c = 'test1', RecordType__c = 'test1');
        AccountContactRole__e acre = New AccountContactRole__e(EventType__c = 'test', RecordId__c = 'test1', RecordType__c = 'test1');

        Test.startTest();

        portalIftpTestClass.test_config();

        Database.SaveResult sr1 = EventBus.publish(are);
        Database.SaveResult sr2 = EventBus.publish(acre);

        String RECTYPE_Track_Response = RecordTypeSingleton.getInstance().getRecordTypeId('Integration_Log__c', 'Track_Response');
        Integration_Log__c il1 = new Integration_Log__c();
        il1 = IntegrationLogUtils.createAccountContactRoleIntegrationLog(null, RECTYPE_Track_Response, null);    
        IntegrationLogUtils.insertIntoIntegrationLog(il1);

        Integration_Log__c il3 = new Integration_Log__c();
        il3 = IntegrationLogUtils.createAccountRoleIntegrationLog(null, RECTYPE_Track_Response, null);    
        IntegrationLogUtils.insertIntoIntegrationLog(il3);

        Test.stopTest();
    }

    static testMethod void portalIftpUtils_test3() {
        portalIftpTestClass.test_config();
        
        Test.startTest();
        
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];
        
        Id itpAccouRoleServId = [SELECT id FROM Account_Role_Service__c WHERE Account_Role__r.Account__r.name LIKE 'ITP Account'].id;
        Id addressID = [SELECT id FROM Address__c WHERE Code__c LIKE 'GVX'].id;
        
        System.runAs(u1) {
        
            Role_Address__c roleAddressITP = new Role_Address__c(Account_Role_Service__c = itpAccouRoleServId, Address__c = addressID, Name = 'Role Address ITP 2');

            List<Role_Address__c> toDelete = new List<Role_Address__c>();
            toDelete.add(roleAddressITP);

            PortalIftpUtils.InsertStationWrapper insertStationRes = PortalIftpUtils.insertStation(toDelete);
        }
    
        Test.stopTest();
        
    }

    @IsTest
    static void inactivateEmployeesCSVFileTest(){

        portalIftpTestClass.test_config();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

        Id employeeItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Employees Del Document' LIMIT 1].ContentDocumentId;
        Id employeeItpId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Employees Del Document 2' LIMIT 1].ContentDocumentId;
        
        Test.startTest();
        
        System.runAs(u1) {
            List<PortalIftpUtils.ImportResultsWrapper> irw = PortalIftpUtils.inactivateEmployeesCSVFile(employeeItpId);

            List<PortalIftpUtils.ImportResultsWrapper> irw2 = PortalIftpUtils.inactivateEmployeesCSVFile(employeeItpId2);
        }
        Test.stopTest();
    }

    @IsTest
    static void importEmployeesCSVFileTest(){

        portalIftpTestClass.test_config();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

        Id empItpId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document2'].ContentDocumentId;
        Id empItpId3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document3'].ContentDocumentId;

        
        Test.startTest();
        
        System.runAs(u1) {
            List<PortalIftpUtils.ImportResultsWrapper> irw3 = PortalIftpUtils.importEmployeesCSVFile(empItpId2);
            List<PortalIftpUtils.ImportResultsWrapper> irw4 = PortalIftpUtils.importEmployeesCSVFile(empItpId3);

        }
        Test.stopTest();
    }

    @IsTest
    static void getAirlineITPsByStationTest(){
        portalIftpTestClass.test_config();
        //airlineUser
        User u1 = [select id from user where Email = 'test.cont4@test.com' limit 1];
        
        Test.startTest();
        
        System.runAs(u1) {
            Map<String, List<Role_Address__c>> res = PortalIftpUtils.getAirlineITPsByStation();
        }
        Test.stopTest();

    }
    
}

