@isTest
/**
 * @description		Test class for CW_CertificationManagerController
 *
 * Edit Log:
 * @history			2020/01/28  |  sf-414  |  Creation.
 */
public with sharing class CW_CertificationsManagerControllerTest {
	private static final Boolean TRACEIT = true;
	private static final string PREFIX = 'CW_CertificationsManagerController:: ';
	@TestSetup
	static void makeData() {
		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;

		List<RecordType> recTypes = CW_TestDataFactory.getRecTypes('Account');

		Account acc = CW_TestDataFactory.TestAccount(isoCode.Id);
		acc.RecordTypeId = recTypes[Integer.valueof((Math.random() * 1))].Id;
		acc.Name = 'TEST Airline HQ/operator';
		acc.Airline_designator__c = 'AA';
		acc.ICAO_designator__c = 'SSV';
		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
		insert airport;

		string rectypeId = recTypes[Integer.valueof((Math.random() * 1))].Id;
		List<Account> airlines = new List<Account>();
		Account acc1 = CW_TestDataFactory.createAirline(isoCode.Id, rectypeId, 'Air Canada', 'AB', 'SSV');
		airlines.add(acc1);

		Account acc2 = CW_TestDataFactory.createAirline(isoCode.Id, rectypeId, 'Iberia', 'AC', 'SSV');
		airlines.add(acc2);

		Account acc3 = CW_TestDataFactory.createAirline(isoCode.Id, rectypeId, 'Alitalia', 'AD', 'SSV');
		airlines.add(acc3);

		insert airlines;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		ICG_Account_Role_Detail__c ard = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		ard.Name = 'Generic Test';
		insert ard;
		ICG_Account_Role_Detail__c ard2 = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert ard2;

		Group g1 = new Group(Name = 'TheTestQueue', type = 'Queue');
		insert g1;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			GroupMember member = new GroupMember();
			member.UserOrGroupId = UserInfo.getUserId();
			member.GroupId = g1.Id;
			insert member;
		}

		ICG_Certification__c sfocCert = CW_TestDataFactory.newCertification();
		sfocCert.Name = 'smart_facility_operational_capacity';
		sfocCert.Applicable_to__c = 'Cargo_Handling_Facility;Airline';
		sfocCert.Department__c = g1.Name;
		insert sfocCert;
		
		ICG_Certification__c ceivFresh = CW_TestDataFactory.newCertification();
		ceivFresh.Name = 'ceiv_fresh';
		ceivFresh.Certification_Type__c = 'Certifications of Excellency';
		ceivFresh.Applicable_to__c = 'Cargo_Handling_Facility;Airline';
		ceivFresh.Department__c = g1.Name;
		insert ceivFresh;
		
		ICG_Certification__c ceivPharma = CW_TestDataFactory.newCertification();
		ceivPharma.Name = 'ceiv_pharma';
		ceivPharma.Certification_Type__c = 'Certifications of Excellency';
		ceivPharma.Applicable_to__c = 'Cargo_Handling_Facility;Airline';
		ceivPharma.Department__c = g1.Name;
		insert ceivPharma;
		
		ICG_Certification__c ienva = CW_TestDataFactory.newCertification();
		ienva.Name = 'ienva_stage_1';
		ienva.Certification_Type__c = 'Certifications of Excellency';
		ienva.Applicable_to__c = 'Cargo_Handling_Facility;Airline';
		ienva.Department__c = g1.Name;
		insert ienva;
		
		ICG_Certification__c animals = CW_TestDataFactory.newCertification();
		animals.Name = 'ceiv_live_animals';
		animals.Certification_Type__c = 'Certifications of Excellency';
		animals.Applicable_to__c = 'Cargo_Handling_Facility;Airline';
		animals.Department__c = g1.Name;
		insert animals;
		
		ICG_Certification__c remoteValidation = CW_TestDataFactory.newCertification();
		remoteValidation.name = 'Smart Facility Remote Validation';
		remoteValidation.certification_type__C = 'Certifications of Compliance';
		insert remoteValidation;

		ICG_Capability_Assignment_Group__c icgGroupA = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard.id, sfocCert.id);
		icgGroupA.Certification_Id__c = 'TESTABCD1234';
		insert icgGroupA;
		
		ICG_Capability_Assignment_Group__c icgGroupA2 = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard.id, animals.id);
		icgGroupA2.Issue_Date__c = Date.today().addDays(2);
		icgGroupA2.Expiration_Date__c = Date.today().addDays(3);
		icgGroupA2.Certification_Id__c = 'TESTABCD1234';
		insert icgGroupA2;
		
		ICG_Capability_Assignment_Group__c icgGroupA3 = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard.id, ienva.id);
		icgGroupA3.Issue_Date__c = Date.today().addDays(-1);
		icgGroupA3.Expiration_Date__c = Date.today().addDays(-1);
		icgGroupA3.Certification_Id__c = 'TESTABCD1234';
		insert icgGroupA3;
		
		ICG_Capability_Assignment_Group__c icgGroupUp = new ICG_Capability_Assignment_Group__c();
		icgGroupUp.ICG_Account_Role_Detail__c = ard.id;
		icgGroupUp.Issue_Date__c = Date.today().addDays(2);
		icgGroupUp.Expiration_Date__c = Date.today().addDays(3);
		icgGroupUp.ICG_Certification__c = ceivFresh.id;
		icgGroupUp.Certification_Id__c = 'TESTABCD1234';
		insert icgGroupUp;
		
		ICG_Capability_Assignment_Group__c icgGroupEx = new ICG_Capability_Assignment_Group__c();
		icgGroupEx.ICG_Account_Role_Detail__c = ard.id;
		icgGroupEx.Issue_Date__c = Date.today().addDays(-1);
		icgGroupEx.Expiration_Date__c = Date.today().addDays(-1);
		icgGroupEx.ICG_Certification__c = ceivPharma.id;
		icgGroupEx.Certification_Id__c = 'TESTABCD1234';
		insert icgGroupEx;
	}
	@isTest
	static void testGetFacilityCertifications() {
		ICG_Account_Role_Detail__c ard = [SELECT id FROM ICG_Account_Role_Detail__c WHERE Name = 'Generic Test' LIMIT 1];
		test.startTest();
		string jsonCertifications = CW_CertificationsManagerController.refreshFacilityCertifications(ard.id,'Airline','IATA');
		List<ICG_Capability_Assignment_Group__c> lstCertifications = (List<ICG_Capability_Assignment_Group__c>) JSON.deserialize(jsonCertifications, List<ICG_Capability_Assignment_Group__c>.class);
		System.assertNotEquals(null, lstCertificationS, 'Information not retrieved properly lstDepts');
		test.stopTest();
	}
	@isTest
	static void testGetAllCertifications() {
		test.startTest();
		string jsonCertifications = CW_CertificationsManagerController.getAllCertifications('smart_facility_operational_capacity','IATA');
		List<ICG_Certification__c> lstCertifications = (List<ICG_Certification__c>) JSON.deserialize(jsonCertifications, List<ICG_Certification__c>.class);
		System.assertNotEquals(null, lstCertifications, 'Information not retrieved properly');
		test.stopTest();
	}
	@isTest
	static void testRenewSFOCCertification() {
		ICG_Capability_Assignment_Group__c ardCert = [SELECT id, ICG_Account_Role_Detail__c, ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'smart_facility_operational_capacity' LIMIT 1];
		test.startTest();
		String newId = CW_CertificationsManagerController.renewCertification(ardCert.id, '2019-12-12', '2020-12-12', 'testCertId', 'Pharmaceuticals');
		System.assertNotEquals(true, String.isBlank(newId), 'Certification not inserted');

		test.stopTest();
	}
	@isTest
	static void testRenewCEIVCertification() {
		ICG_Capability_Assignment_Group__c ardCert = [SELECT id, ICG_Account_Role_Detail__c, ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Certification_Type__c = 'Certifications of Excellency' LIMIT 1];
		test.startTest();
		String newId = CW_CertificationsManagerController.renewCertification(ardCert.id, '2019-12-12', '2020-12-12', 'testCertId', '');
		System.assertNotEquals(true, String.isBlank(newId), 'Certification not inserted');

		test.stopTest();
	}
	@isTest
	static void testCreateCertification() {
		ICG_Account_Role_Detail__c ard = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1];
		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c WHERE ValidationPrograms__c = 'IATA' LIMIT 1];
		ICG_Capability_Assignment_Group__c ardCert = new ICG_Capability_Assignment_Group__c();
		ardCert.id = null;
		ardCert.ICG_Account_Role_Detail__c = ard.id;
		ardCert.ICG_Certification__c = cert.id;
		ardCert.Certification_Id__c = 'testABC12345';
		ardCert.Issue_Date__c = Date.valueOf('2019-12-12');
		ardCert.Expiration_Date__c = Date.valueOf('2020-12-12');
		string jsonCertificationToAdd = JSON.serialize(ardCert);
		test.startTest();
		
		ICG_Capability_Assignment_Group__c certId = CW_CertificationsManagerController.createCertification(jsonCertificationToAdd);
		System.assertNotEquals(null, certId.id, 'Certification not inserted');
		
		test.stopTest();
	}
	@isTest
	static void testExceptions() {
		test.startTest();
		String newId = CW_CertificationsManagerController.renewCertification(null, null, null, null, null);
		System.assertEquals(false, String.isBlank(newId), 'Certification not inserted');
		
		ICG_Capability_Assignment_Group__c certId = CW_CertificationsManagerController.createCertification(null);
		System.assertEquals(null, certId, 'Exception not thrown');
		
		test.stopTest();
	}
	
	@isTest
	static void getScopeByCertificationAndStation() {
		
		test.startTest();
		String result = CW_CertificationsManagerController.getScopeByCertificationAndStation();
		System.assertNotEquals(result, '');

		test.stopTest();
	}
	
	@isTest
	static void getNextCertificationID() {
		ICG_Account_Role_Detail__c acc = [SELECT id FROM ICG_Account_Role_Detail__c WHERE Name = 'Generic Test' LIMIT 1];
		
		ICG_Certification__c newcert = [SELECT Id FROM ICG_Certification__c WHERE Name = 'smart_facility_operational_capacity' AND ValidationPrograms__c = 'IATA'];
		ICG_Certification__c newcert1 = [SELECT Id FROM ICG_Certification__c WHERE Name = 'ceiv_fresh' AND ValidationPrograms__c = 'IATA'];
		ICG_Certification__c newcert2 = [SELECT Id FROM ICG_Certification__c WHERE Name = 'ceiv_pharma' AND ValidationPrograms__c = 'IATA'];
		ICG_Certification__c newcert3 = [SELECT Id FROM ICG_Certification__c WHERE Name = 'Smart Facility Remote Validation' AND ValidationPrograms__c = 'IATA'];
		ICG_Certification__c newcert4 = [SELECT Id FROM ICG_Certification__c WHERE Name = 'ienva_stage_1' AND ValidationPrograms__c = 'IATA'];
		ICG_Certification__c newcert5 = [SELECT Id FROM ICG_Certification__c WHERE Name = 'ceiv_live_animals' AND ValidationPrograms__c = 'IATA'];
		
		test.startTest();
		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c LIMIT 1];
		String result = CW_CertificationsManagerController.getNextCertificationID(cert.id,acc.Id);
		System.assertNotEquals(result, '');

		result = CW_CertificationsManagerController.getNextCertificationID(newcert.Id,acc.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');
		
		result = CW_CertificationsManagerController.getNextCertificationID(newcert1.Id,acc.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');
		
		result = CW_CertificationsManagerController.getNextCertificationID(newcert2.Id,acc.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');
		
		result = CW_CertificationsManagerController.getNextCertificationID(newcert3.Id,acc.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');
		
		result = CW_CertificationsManagerController.getNextCertificationID(newcert4.Id,acc.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');
		
		result = CW_CertificationsManagerController.getNextCertificationID(newcert5.Id,acc.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');

		test.stopTest();
	}
	
	@isTest
	static void getFacilityNotActiveCertifications() {
		ICG_Capability_Assignment_Group__c ardCert = [SELECT id, ICG_Account_Role_Detail__c, ICG_Certification__c, Is_Active__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'smart_facility_operational_capacity' LIMIT 1];
		
		test.startTest();
		String result = CW_CertificationsManagerController.getFacilityNotActiveCertifications(ardCert.ICG_Account_Role_Detail__c, ardCert.ICG_Certification__c, ardCert.id, '\'Upcoming\'', 'smart_facility_operational_capacity', 'IATA');
		System.assertNotEquals(result, '');

		test.stopTest();
	}
	
	@isTest
	static void updateFieldEdited() {
		ICG_Capability_Assignment_Group__c ardCert = [SELECT id, ICG_Account_Role_Detail__c, ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'smart_facility_operational_capacity' LIMIT 1];
		String jsonValue = JSON.serialize(ardCert);
		List<String> jsonGroup = new List<String>{jsonValue};
		test.startTest();
		Boolean result = CW_CertificationsManagerController.updateFieldEdited(jsonGroup);
		System.assertEquals(result, true);
		
		result = CW_CertificationsManagerController.updateFieldEdited(null);
		System.assertEquals(result, false);

		test.stopTest();
	}
	
	@isTest
	static void getCertificationWithoutCapabilities() {
		ICG_Capability_Assignment_Group__c ardCert = [SELECT id, ICG_Account_Role_Detail__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'smart_facility_operational_capacity' LIMIT 1];
		
		test.startTest();
		List<ICG_Certification__c> result = CW_CertificationsManagerController.getCertificationWithoutCapabilities(ardCert.ICG_Account_Role_Detail__c,'IATA');
		System.assertNotEquals(result, null);

		test.stopTest();
	}
}