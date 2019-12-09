@isTest
private class PortalIftEmployeeRecordsManagementTest {
	@testSetup static void setup(){
		portalIftpTestClass.test_config();
	}

	@IsTest
	static void addEmployeeTest_1(){

		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		Id contactToDelete = [SELECT id FROM contact WHERE LastName like 'Student'].id;
		Account_Contact_Role__c employeeToInactivate = [SELECT id, Contact__c, name, Company_Code__c, First_Name__c, Last_Name__c  FROM Account_Contact_Role__c WHERE contact__c = :contactToDelete];

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

		PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper employeeToAdd_3 = new PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper();
		employeeToAdd_3.code = 'Abc';
		employeeToAdd_3.first_name = '';
		employeeToAdd_3.last_name = '';
		employeeToAdd_3.role = '';
		employeeToAdd_3.busEmail = '';
		employeeToAdd_3.personalEmail = '';
		employeeToAdd_3.title = 'Trainee';
		employeeToAdd_3.phone = null;
		employeeToAdd_3.details = 'New employee';

		Test.startTest();
		System.runAs(u1) {
			PortalIftEmployeeRecordsManagement.ResultWrapper res0 = PortalIftEmployeeRecordsManagement.inactivateEmployee(employeeToInactivate);
			System.assert(res0.succeeded);

			PortalIftEmployeeRecordsManagement.ResultWrapper res1 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd);
			System.assert(res1.succeeded);

			PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd_2);
			System.assert(!res2.succeeded);

			PortalIftEmployeeRecordsManagement.ResultWrapper res3 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd_3);
			System.assert(!res3.succeeded);

		}
		Test.stopTest();
	}

	@IsTest
	static void addEmployeeTest_2(){
		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];
		PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper employeeToAdd_4 = new PortalIftEmployeeRecordsManagement.EmployeeRecordWrapper();
		employeeToAdd_4.code = 'MS111';
		employeeToAdd_4.first_name = 'Rita1';
		employeeToAdd_4.last_name = 'Are1';
		employeeToAdd_4.role = 'ITP Trainee';
		employeeToAdd_4.busEmail = 'MS111@email.com';
		employeeToAdd_4.personalEmail = 'MS111_2@email.com';
		employeeToAdd_4.title = 'Trainee';
		employeeToAdd_4.phone = '199999999';
		employeeToAdd_4.details = 'New employee';
		Test.startTest();
		System.runAs(u1) {
			PortalIftEmployeeRecordsManagement.ResultWrapper res4 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd_4);
			System.assert(res4.succeeded);
			Account_Contact_Role__c employeeToInactivate2 = [SELECT id, Contact__c, name, Company_Code__c, First_Name__c, Last_Name__c, Status__c
																FROM Account_Contact_Role__c WHERE Company_Code__c = 'MS111'];

			PortalIftEmployeeRecordsManagement.ResultWrapper res0 = PortalIftEmployeeRecordsManagement.inactivateEmployee(employeeToInactivate2);
			System.assert(res0.succeeded);

			Account_Contact_Role__c employeeToInactivate3 = [SELECT id, Contact__c, name, Company_Code__c, First_Name__c, Last_Name__c, Status__c
																FROM Account_Contact_Role__c WHERE Company_Code__c = 'MS111'];

			PortalIftEmployeeRecordsManagement.ResultWrapper res41 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToInactivate3);
			System.assert(!res41.succeeded);

		}
		Test.stopTest();
	}

	@IsTest
	static void inactivateEmployeeTest(){
		User u1 = [select id, ContactId, Contact.AccountId  from user where Email = 'test.cont3@test.com' limit 1];
		Id contactToDelete = [SELECT id FROM contact WHERE LastName like 'Student' LIMIT 1].id;
		Account_Contact_Role__c employeeToInactivate = [SELECT id, Contact__c, name, Company_Code__c, First_Name__c, Last_Name__c, Status__c FROM Account_Contact_Role__c WHERE contact__c = :contactToDelete];

		Test.startTest();

		System.runAs(u1) {

			PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.inactivateEmployee(employeeToInactivate);
			System.assert(res2.succeeded);
			PortalIftEmployeeRecordsManagement.ResultWrapper res42 = PortalIftEmployeeRecordsManagement.updateEmployee(u1.Contact.AccountId, employeeToInactivate, 'reactivate_and_update');
			System.assert(res42.succeeded);

		}
		Test.stopTest();
	}

	@IsTest
	static void updateEmployeeTest(){
		User u1 = [select id, Contact.AccountId from user where Email = 'test.cont3@test.com' limit 1];
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

		Test.startTest();
		System.runAs(u1) {
			PortalIftEmployeeRecordsManagement.ResultWrapper res1 = PortalIftEmployeeRecordsManagement.addNewEmployee(employeeToAdd);
			System.assert(res1.succeeded);
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

			PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.updateEmployee(u1.Contact.AccountId,employeeToUpdate, 'update');
			System.assert(res2.succeeded);

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

			employeeToUpdate_2.Company_Code__c = '';
			PortalIftEmployeeRecordsManagement.ResultWrapper res3 = PortalIftEmployeeRecordsManagement.updateEmployee(u1.Contact.AccountId, employeeToUpdate_2, 'update');
			System.assert(!res3.succeeded);

			employeeToUpdate_2.Company_Code__c = 'Abc';
			PortalIftEmployeeRecordsManagement.ResultWrapper res4 = PortalIftEmployeeRecordsManagement.updateEmployee(u1.Contact.AccountId, employeeToUpdate_2, 'update');
			System.assert(!res4.succeeded);

			employeeToUpdate_2.id = null;
			PortalIftEmployeeRecordsManagement.ResultWrapper res5 = PortalIftEmployeeRecordsManagement.updateEmployee(u1.Contact.AccountId, employeeToUpdate_2, 'update');
			System.assert(!res5.succeeded);
		}
		Test.stopTest();
	}

	@IsTest
	static void updateEmployeeStationsTest(){
		User u1 = [select id, Contact.AccountId from user where Email = 'test.cont3@test.com' limit 1];
		Id employeeAccContRol = [SELECT Id FROM Account_Contact_Role__c WHERE Contact_Role__c = 'ITP Trainee' LIMIT 1].id;
		List<Role_Address__c> employeeStation = [SELECT id, name FROM Role_Address__c WHERE Account_Contact_Role__c = :employeeAccContRol LIMIT 1];
		List<Role_Address__c> employeeStation_2 = [SELECT Account_Contact_Role__c, Address__c, name FROM Role_Address__c WHERE Account_Contact_Role__c = :employeeAccContRol LIMIT 1];
		Test.startTest();
		System.runAs(u1) {

			PortalIftEmployeeRecordsManagement.ResultWrapper res = PortalIftEmployeeRecordsManagement.updateEmployeeStations(employeeStation, employeeStation);
			System.assert(!res.succeeded);

			PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.updateEmployeeStations(null, employeeStation_2);
			System.assert(!res2.succeeded);
		}
		Test.stopTest();
	}

	@IsTest
	static void updateEmployeeStationsTest2(){
		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		Airport_Detail__c Addr1 = [SELECT Id, Code__c FROM Airport_Detail__c WHERE Code__c = 'GVX' LIMIT 1];
		Airport_Detail__c Addr2 = [SELECT Id, Code__c FROM Airport_Detail__c WHERE Code__c = 'PTX' LIMIT 1];
		Airport_Detail__c Addr3 = [SELECT Id, Code__c FROM Airport_Detail__c WHERE Code__c = 'FRX' LIMIT 1];


		Account_Contact_Role__c employee = [SELECT Id, Company_Code__c, First_Name__c, Last_Name__c FROM Account_Contact_Role__c WHERE Company_Code__c = 'Abc' LIMIT 1];

		List<Role_Address__c> newRoleAddressToInsertList = new List<Role_Address__c>();
		List<Role_Address__c> originalEmpStations = [SELECT Id, Name, Address__c, Address__r.Code__c, Account_Contact_Role__c, Account_Contact_Role__r.Company_Code__c, Primary__c
												FROM Role_Address__c WHERE Account_Contact_Role__r.Company_Code__c = 'Abc'];
		for(Role_Address__c rec : originalEmpStations){
			if(rec.Address__r.Code__c.equalsIgnoreCase('GVX')){
				rec.Primary__c = true;
				newRoleAddressToInsertList.add(rec);
			}
		}
		Role_Address__c roleAddressAA112FRX = new Role_Address__c(Account_Contact_Role__c = employee.Id, Address__c = Addr3.Id, Name = 'Role Address AA112 FRX');
		newRoleAddressToInsertList.add(roleAddressAA112FRX);

		Test.startTest();
		System.runAs(u1) {
			PortalIftEmployeeRecordsManagement.ResultWrapper res2 = PortalIftEmployeeRecordsManagement.updateEmployeeStations(originalEmpStations, newRoleAddressToInsertList);
			System.assert(res2.succeeded);
		}
		Test.stopTest();
	}

	@IsTest
	static void getITPEmployeesWithStationsInfoTest(){
		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];
		Test.startTest();
		System.runAs(u1) {
			PortalIftEmployeeRecordsManagement.SearchEmployeeRecordWrapper searchValues = new PortalIftEmployeeRecordsManagement.SearchEmployeeRecordWrapper();
			List<Account_Contact_Role__c> accRoleList3 = PortalIftEmployeeRecordsManagement.getITPEmployeesWithStationsInfo(searchValues, '');
			searchValues.firstName = 'ITP Student';
			searchValues.lastName = 'Student';
			searchValues.employeeCode = 'Abc';
			searchValues.stationCode = 'PTX';
			List<Account_Contact_Role__c> accRoleList4 = PortalIftEmployeeRecordsManagement.getITPEmployeesWithStationsInfo(searchValues, '');
			System.assert(accRoleList3.size() > 0, 'Fail to performe getITPEmployeesWithStationsInfo!');
		}
		Test.stopTest();
	}

	@IsTest
	static void getAllITPEmployeesTest(){
		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];
		Test.startTest();
		System.runAs(u1) {
			List<Account_Contact_Role__c> accRoleList3 = PortalIftEmployeeRecordsManagement.getAllITPEmployees();
			System.assert(accRoleList3.size() > 0, 'Fail to performe getAllITPEmployees!');
		}
		Test.stopTest();
	}

	@IsTest
	static void requestEmployeeTransferTest(){
		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		PortalIftEmployeeRecordsManagement.EmployeeTransferRequestWrapper reqTransferEmp = new PortalIftEmployeeRecordsManagement.EmployeeTransferRequestWrapper();
		reqTransferEmp.firstName = 'Abc';
		reqTransferEmp.formerItpName = 'Old ITP';
		reqTransferEmp.formerStations = 'GVA LHR';
		reqTransferEmp.lastName = 'Emp';
		reqTransferEmp.lmsUsername = '123';
		reqTransferEmp.comments = 'From abroad';

		Test.startTest();
		System.runAs(u1) {
			PortalIftEmployeeRecordsManagement.EmployeeTransferRequestResultWrapper res =  PortalIftEmployeeRecordsManagement.requestEmployeeTransfer(reqTransferEmp);
			System.assert(res.succeeded);
		}
		Test.stopTest();
	}

	@IsTest
	static void resetPasswordTest(){
		// Set the mock response
		Integer code = 200;
		String status = 'ok';
		String body = '{}';
		Map<String, String> responseHeaders = new Map<String,String>();
		responseHeaders.put('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, new ISSP_MockHttpResponseGenerator(code, status, body, responseHeaders));

		Boolean result = PortalIftEmployeeRecordsManagement.resetEmployeePassword('aB40000000000', 'test123');
		System.assert(!result);

	}
}