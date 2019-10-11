@isTest
private class PortalIftEmployeeRecordsManagementTest {

    @IsTest
    static void addEmployeeTest(){
        portalIftpTestClass.test_config();
        Test.startTest();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];



        System.debug('u1 - ' + u1);

        System.runAs(u1) {
            PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper employeeToAdd_2 = new PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper();
            employeeToAdd_2.code = '';
            employeeToAdd_2.first_name = '';
            employeeToAdd_2.last_name = '';
            employeeToAdd_2.role = '';
            employeeToAdd_2.busEmail = '';
            employeeToAdd_2.personalEmail = '';
            employeeToAdd_2.title = 'Trainee';
            employeeToAdd_2.phone = '';
            employeeToAdd_2.details = 'New employee';
            
            PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper employeeToAdd = new PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper();
            employeeToAdd.code = 'Abc';
            employeeToAdd.first_name = 'Rita1';
            employeeToAdd.last_name = 'Are1';
            employeeToAdd.role = 'ITP Trainee';
            employeeToAdd.busEmail = 'rita.are11@mail.com';
            employeeToAdd.personalEmail = 'rita.are22perconalmail.com';
            employeeToAdd.title = 'Trainee';
            employeeToAdd.phone = '199999999';
            employeeToAdd.details = 'New employee';
             
            PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper employeeToAdd_3 = new PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper();
            employeeToAdd_3.code = 'Abc';
            employeeToAdd_3.first_name = '';
            employeeToAdd_3.last_name = '';
            employeeToAdd_3.role = '';
            employeeToAdd_3.busEmail = '';
            employeeToAdd_3.personalEmail = '';
            employeeToAdd_3.title = 'Trainee';
            employeeToAdd_3.details = 'New employee';

            PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper employeeToAdd_4 = new PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper();
            employeeToAdd_4.code = 'Aaaa';
            employeeToAdd_4.first_name = 'Rita1';
            employeeToAdd_4.last_name = 'Are1';
            employeeToAdd_4.role = 'ITP Trainee';
            employeeToAdd_4.busEmail = '222222222';
            employeeToAdd_4.personalEmail = '11111111';
            employeeToAdd_4.title = 'Trainee';
            employeeToAdd_4.phone = '199999999';
            employeeToAdd_4.details = 'New employee';  

            System.debug('employeeToAdd - ' + employeeToAdd);

            PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd_2);
            PortalIftEmployeeRecordsManagement.ResultWrapper res1 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd);
            PortalIftEmployeeRecordsManagement.ResultWrapper res3 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd_3);
            PortalIftEmployeeRecordsManagement.ResultWrapper res4 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd_4);
            

        }
        Test.stopTest();
        
    }

    @IsTest
    static void inactivateEmployeeTest(){
        portalIftpTestClass.test_config();
        Test.startTest();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

        Id contactToDelete = [SELECT id FROM contact WHERE LastName like 'Student'].id;
        System.debug('contactToDelete '+ contactToDelete);
        Account_Contact_Role__c employeeToInactivate = [SELECT id, Contact__c, name FROM Account_Contact_Role__c WHERE contact__c = :contactToDelete];
        System.debug('employeeToInactivate '+ employeeToInactivate);

        System.debug('u1 - ' + u1);

        System.runAs(u1) {
            
            PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.inactivateEmployee(employeeToInactivate);

        }
        Test.stopTest();
    }

    @IsTest
    static void updateEmployeeTest(){
        portalIftpTestClass.test_config();
        Test.startTest();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

        System.debug('u1 - ' + u1);

        System.runAs(u1) {
            PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper employeeToAdd = new PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper();
            employeeToAdd.code = 'GG11';
            employeeToAdd.first_name = 'Rita1';
            employeeToAdd.last_name = 'Are1';
            employeeToAdd.role = 'ITP Trainee';
            employeeToAdd.busEmail = 'rita.are11@mail.com';
            employeeToAdd.personalEmail = 'rita.are22@perconalmail.com';
            employeeToAdd.title = 'Trainee';
            employeeToAdd.phone = '199999999';
            employeeToAdd.details = 'New employee';

            PortalIftEmployeeRecordsManagement.ResultWrapper res1 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd);

            Id employeeToUpdateAccRolId = res1.accContRoleManaged.id;
            Account_Contact_Role__c employeeToUpdate = [SELECT Id,
                                                               Contact__c,
                                                               Company_Code__c,
                                                               First_Name__c,
                                                               Last_Name__c,
                                                               Title__c,
                                                               Business_Phone__c,
                                                               Details__c 
                                                        FROM Account_Contact_Role__c
                                                        WHERE Id = :employeeToUpdateAccRolId];
            System.debug('employeeToUpdate - ' + employeeToUpdate);


            PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.updateEmployee(employeeToUpdate);

            Contact employeeToUpdateContact_2 = new Contact(Id = employeeToUpdate.Contact__c,
                                                            FirstName = '',
                                                            Title = '',
                                                            Phone = '',
                                                            Email = 'testtest@testmail.com');
            update employeeToUpdateContact_2;
            Account_Contact_Role__c employeeToUpdate_2 = [SELECT Id,
                                                               Contact__c,
                                                               Company_Code__c,
                                                               First_Name__c,
                                                               Last_Name__c,
                                                               Title__c,
                                                               Business_Phone__c,
                                                               Details__c 
                                                        FROM Account_Contact_Role__c
                                                        WHERE Contact__c = :employeeToUpdateContact_2.id];

            System.debug('employeeToUpdate_2 - ' + employeeToUpdate_2);
            
            employeeToUpdate_2.Company_Code__c = '';
            PortalIftEmployeeRecordsManagement.ResultWrapper res3 = PortalIftEmployeeRecordsManagement.updateEmployee(employeeToUpdate_2);
            employeeToUpdate_2.Company_Code__c = 'Abc';
            PortalIftEmployeeRecordsManagement.ResultWrapper res4 = PortalIftEmployeeRecordsManagement.updateEmployee(employeeToUpdate_2);
            employeeToUpdate_2.id = null;
            PortalIftEmployeeRecordsManagement.ResultWrapper res5 = PortalIftEmployeeRecordsManagement.updateEmployee(employeeToUpdate_2);

        }
        Test.stopTest();
    }

    @IsTest
    static void updateEmployeeStationsTest(){
        portalIftpTestClass.test_config();
        Test.startTest();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

        Id employeeAccContRol = [SELECT Id FROM Account_Contact_Role__c WHERE Contact_Role__c = 'ITP Trainee' LIMIT 1].id;
        List<Role_Address__c> employeeStation = [SELECT id, name FROM Role_Address__c WHERE Account_Contact_Role__c = :employeeAccContRol LIMIT 1];

        List<Role_Address__c> employeeStation_2 = [SELECT Account_Contact_Role__c, Address__c, name FROM Role_Address__c WHERE Account_Contact_Role__c = :employeeAccContRol LIMIT 1];

        System.debug('employeeStation - ' + employeeStation);

        System.runAs(u1) {

            PortalIftEmployeeRecordsManagement.ResultWrapper res = PortalIftEmployeeRecordsManagement.updateEmployeeStations(employeeStation, employeeStation);

            PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.updateEmployeeStations(null, employeeStation_2);

        }
        Test.stopTest();
    }

    @IsTest
    static void getITPEmployeesWithStationsInfoTest(){
        portalIftpTestClass.test_config();
        Test.startTest();
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

        //List<Account_Contact_Role__c> empList = [Select Id, Contact__C, Contact__r.accountid from Account_Contact_Role__c];

        //Id accId = empList[0].Contact__r.accountid;

        System.runAs(u1) {
            PortalIftEmployeeRecordsManagement.SearchEmployeeRecordWrapper searchValues = new PortalIftEmployeeRecordsManagement.SearchEmployeeRecordWrapper();

            List<Account_Contact_Role__c> accRoleList3 = PortalIftEmployeeRecordsManagement.getITPEmployeesWithStationsInfo(searchValues, '');

        }
        Test.stopTest();
    }
}