@isTest
public class PortalIftpUtilsTest {
	@testSetup static void setup(){
		portalIftpTestClass.test_config();
	}

	static testMethod void portalIftpUtils_test1() {

		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];

		Test.startTest();

		System.runAs(u2) {

			String sRoleAddr = 'ITP Trainee';
			List<Account_Contact_Role__c> empList = [Select Id, Contact__C, Contact__r.accountid from Account_Contact_Role__c ORDER BY Id];

			Id empId = empList[0].Id;
			Id accId = empList[0].Contact__r.accountid;

			List<Id> empIdsList = new List<Id>();
			for(Account_Contact_Role__c rec : empList){
				empIdsList.add(rec.Id);
			}


			Map<Id, List<Airport_Detail__c>> addMapList1 = PortalIftpUtils.getEmployeesStations(empIdsList);
			System.assertEquals(addMapList1.keySet().size(), 1);

			List<Account_Contact_Role__c> accRoleList1 = PortalIftpUtils.getITPEmployees(accId);
			System.assert(accRoleList1.size() > 0, 'Fail to getITPEmployees!');

			List<Account_Contact_Role__c> accRoleList2 = PortalIftEmployeeRecordsManagement.getAllITPEmployees();
			System.assert(accRoleList2.size() > 0, 'Fail to getAllITPEmployees!');

			List<Account_Contact_Role__c> accRoleList3 = PortalIftpUtils.getITPEmployeesWithStationsInfo(accId);
			System.assert(accRoleList3.size() > 0, 'Fail to getITPEmployeesWithStationsInfo!');


		}
		Test.stopTest();
	}


	static testMethod void portalIftpUtils_test1_1() {

		Test.startTest();
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		System.runAs(u2) {

			PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
			System.assertEquals(ui.id, u2.id);

			List<Airport_Detail__c> addList2 = PortalIftpUtils.getAllStations();
			System.assert(addList2.size() > 0, 'Fail to getAllStations!');

			List<Airport_Detail__c> addList22 = PortalIftpUtils.getUserStations();
			System.assert(addList22.size() > 0, 'Fail to getUserStations!');

			List<Airport_Detail__c> addList3 = PortalIftpUtils.getITPStations();
			System.assert(addList3.size() > 0, 'Fail to getITPStations!');

			List<PortalIftpUtils.StationRecordsWrapper> swrap = PortalIftpUtils.getITPStationsForDatatable();
			System.assert(swrap.size() > 0, 'Fail to getITPStationsForDatatable!');

			List<Role_Address__c> roleAddrList = PortalIftpUtils.getITPConnectedToAirlineByStation('PTX');
			System.assertEquals(roleAddrList.size(), 0);

			List<Role_Address__c> roleAddrList2 = PortalIftpUtils.getITPConnectedToAirlineByStations(new List<String>{'PTX','GVX'});
			System.assertEquals(roleAddrList2.size(), 0);

			List<Certification__c> cert1 = PortalIftpUtils.getCertificationTypes(null);
			System.assert(cert1.size() > 0, 'Fail to getCertificationTypes!');

			List<Certification__c> cert2 = PortalIftpUtils.getCertificationTypes('Aircraft');
			System.assert(cert2.size() > 0, 'Fail to getCertificationTypes!');

			List<IFTP_Certification_DEtail__c> cert3 = PortalIftpUtils.getCertificationTypesWithLevel('Aircraft');
			System.assert(cert3.size() > 0, 'Fail to getCertificationTypesWithLevel!');

			List<IFTP_Certification_DEtail__c> cert4 = PortalIftpUtils.getCertificationTypesWithLevel('');
			System.assert(cert4.size() > 0, 'Fail to getCertificationTypesWithLevel!');
		}
		Test.stopTest();
	}

	static testMethod void portalIftpUtils_test1_2() {

		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];

		Id empItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document'].ContentDocumentId;
		Id empItpId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document2'].ContentDocumentId;
		Id stationItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Station Ins Document'].ContentDocumentId;
		Id ItpOJTId = [SELECT Id FROM Document WHERE name = 'OJT Document'].Id;
		Id add2Id = [Select Id From Airport_Detail__c where Code__c = 'GVX' limit 1].Id;
		List<Role_Address__c> roleAddrList3 = [Select Id, Description__c, Address__c, Name, Account_Role_Service__c from Role_Address__c];

		Test.startTest();

		System.runAs(u2) {

			Integer i = 0;
			for(Role_Address__c roleAddr : roleAddrList3){
				i++;
				roleAddr.Description__c = 'test upd ' + i;
			}
			PortalIftpUtils.InsertStationWrapper updStationWrapper = PortalIftpUtils.updateStation(roleAddrList3, null);
			System.assert(updStationWrapper.succeeded);

			Airport_Detail__c addr = PortalIftpUtils.getITPStationEmployees(add2Id);
			System.assertEquals(addr.Code__c, 'GVX');

			List<PortalIftpUtils.ImportResultsWrapper> irw1 = PortalIftpUtils.importStationsCSVFile(stationItpId);
			System.assert(irw1.size() > 0, 'Fail to performe importStationsCSVFile!');

			List<PortalIftpUtils.ImportResultsWrapper> irw2 = PortalIftpUtils.importEmployeesCSVFile(empItpId);
			System.assert(irw2.size() > 0, 'Fail to performe importStationsCSVFile!');

			List<PortalIftpUtils.ImportResultsWrapper> irw3 = PortalIftpUtils.importEmployeesCSVFile(empItpId2);
			System.assert(irw3.size() > 0, 'Fail to performe importStationsCSVFile!');
		}
		Test.stopTest();
	}

	@IsTest
	static void manageUploadGlobalOJTTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		Id ItpOJTId = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'OJT Document'].ContentDocumentId;
		Test.startTest();

		System.runAs(u2) {
			Boolean res = PortalIftpUtils.manageUploadGlobalOJT(ItpOJTId);
			System.assertEquals(res, true);
		}
		Test.stopTest();

	}

	@IsTest
	static void manageUploadStationOJTTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		Id ItpOJTId = [SELECT ContentDocumentId FROM ContentVersion WHERE title = 'OJT Document'].ContentDocumentId;
		List<Role_Address__c> roleAddrList3 = [Select Id, Description__c, Address__c, Name, Account_Role_Service__c from Role_Address__c];
		Test.startTest();

		System.runAs(u2) {
		   Boolean res =  PortalIftpUtils.manageUploadStationOJT(ItpOJTId, roleAddrList3[0].Id, 'PTX - Airport');
		   System.assertEquals(res, true);
		}
		Test.stopTest();

	}

	@IsTest
	static void getITPConnectedToAirlineTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		Test.startTest();

		System.runAs(u2) {
			List<Account_Role_Relationship__c> res = PortalIftpUtils.getITPConnectedToAirline();
			System.assertEquals(res.size(), 0);
		}
		Test.stopTest();

	}

	@IsTest
	static void isCommunityTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		Test.startTest();

		System.runAs(u2) {
			Boolean res = PortalIftpUtils.isCommunity();
			System.assertEquals(res, false);
		}
		Test.stopTest();

	}


	static testMethod void integrationLogUtils_Test() {

		AccountRole__e are = New AccountRole__e(EventType__c = 'test', RecordId__c = 'test1', RecordType__c = 'test1');
		AccountContactRole__e acre = New AccountContactRole__e(EventType__c = 'test', RecordId__c = 'test1', RecordType__c = 'test1');

		Test.startTest();

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

		Test.startTest();

		User u1 = [select id, Contact.AccountId from user where Email = 'test.cont3@test.com' limit 1];

		Id itpAccouRoleServId = [SELECT id FROM Account_Role_Service__c WHERE Account_Role__r.Account__r.name LIKE 'ITP Account'].id;
		Id addressID = [SELECT id FROM Airport_Detail__c WHERE Code__c LIKE 'GVX'].id;

		System.runAs(u1) {

			Role_Address__c roleAddressITP = new Role_Address__c(Account_Role_Service__c = itpAccouRoleServId, Address__c = addressID, Name = 'Role Address ITP 2');

			List<Role_Address__c> toDelete = new List<Role_Address__c>();
			toDelete.add(roleAddressITP);

			PortalIftpUtils.InsertStationWrapper insertStationRes = PortalIftpUtils.insertStation(u1.Contact.AccountId, toDelete);
			System.assert(insertStationRes.succeeded);
		}

		Test.stopTest();

	}

	@IsTest
	static void inactivateEmployeesCSVFileTest(){
		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		Id employeeItpId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Employees Del Document' LIMIT 1].ContentDocumentId;
		Id employeeItpId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Employees Del Document 2' LIMIT 1].ContentDocumentId;

		Test.startTest();

		System.runAs(u1) {
			List<PortalIftpUtils.ImportResultsWrapper> irw = PortalIftpUtils.inactivateEmployeesCSVFile(employeeItpId);
			System.assert(irw.size() > 0, 'Fail to performe inactivateEmployeesCSVFile!');

			List<PortalIftpUtils.ImportResultsWrapper> irw2 = PortalIftpUtils.inactivateEmployeesCSVFile(employeeItpId2);
			System.assert(irw2.size() > 0, 'Fail to performe inactivateEmployeesCSVFile!');
		}
		Test.stopTest();
	}

	@IsTest
	static void importEmployeesCSVFileTest(){
		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		Id empItpId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document2'].ContentDocumentId;
		Id empItpId3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document3'].ContentDocumentId;


		Test.startTest();

		System.runAs(u1) {
			List<PortalIftpUtils.ImportResultsWrapper> irw3 = PortalIftpUtils.importEmployeesCSVFile(empItpId2);
			List<PortalIftpUtils.ImportResultsWrapper> irw4 = PortalIftpUtils.importEmployeesCSVFile(empItpId3);
			System.assert(irw3.size() > 0, 'Fail to performe importEmployeesCSVFile!');
			System.assert(irw4.size() > 0, 'Fail to performe importEmployeesCSVFile!');

		}
		Test.stopTest();
	}

	@IsTest
	static void getAirlineITPsByStationTest(){
		//airlineUser
		User u1 = [select id from user where Email = 'test.cont4@test.com' limit 1];

		Test.startTest();

		System.runAs(u1) {
			Map<String, List<Role_Address__c>> res = PortalIftpUtils.getAirlineITPsByStation();
			System.assert(res.keySet().size() > 0, 'Fail to performe getAirlineITPsByStation!');
		}
		Test.stopTest();

	}

	@IsTest
	static void getAllITPTest(){
		//airlineUser
		User u1 = [select id from user where Email = 'test.cont4@test.com' limit 1];

		Test.startTest();

		System.runAs(u1) {
			List<Account>  res = PortalIftpUtils.getAllITP();
			System.assertEquals(res.size(), 0);
		}
		Test.stopTest();

	}

	@IsTest
	static void removeProficiencyTest(){
		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];
		Id rolAddrId = [SELECT Id FROM Role_Address__c WHERE Contact_Role_Certification__r.Name = 'Certification Plane 1A'].Id;

		Test.startTest();

		System.runAs(u1) {
			Boolean res = PortalIftpUtils.removeProficiency(rolAddrId);
			System.assert(res);
		}
		Test.stopTest();

	}

}

