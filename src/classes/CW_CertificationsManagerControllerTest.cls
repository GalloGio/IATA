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
		handleTrace(PREFIX + 'IATA_ISO_Country__c insert');

		List<RecordType> recTypes = CW_TestDataFactory.getRecTypes('Account');
		handleTrace(PREFIX + 'recTypes => ' + recTypes);

		Account acc = CW_TestDataFactory.TestAccount(isoCode.Id);
		acc.RecordTypeId = recTypes[Integer.valueof((Math.random() * 1))].Id;
		acc.Name = 'TEST Airline HQ/operator';
		acc.Airline_designator__c = 'AA';
		acc.ICAO_designator__c = 'SSV';
		insert acc;
		handleTrace(PREFIX + 'HQ/operator insert');

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
		handleTrace(PREFIX + 'Airlines insert');

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;
		handleTrace(PREFIX + 'Account_Role__c insert');

		ICG_Account_Role_Detail__c ard = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert ard;
		ICG_Account_Role_Detail__c ard2 = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert ard2;
		handleTrace(PREFIX + 'ICG_Account_Role_Detail__c insert');

		Group g1 = new Group(Name = 'TheTestQueue', type = 'Queue');
		insert g1;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			GroupMember member = new GroupMember();
			member.UserOrGroupId = UserInfo.getUserId();
			member.GroupId = g1.Id;
			insert member;
		}

		ICG_Certification__c sfocCert = CW_TestDataFactory.newCertification();
		sfocCert.Name = 'SF Operational Capacity';
		sfocCert.Department__c = g1.Name;
		insert sfocCert;
		ICG_Certification__c ceivCert = CW_TestDataFactory.newCertification();
		ceivCert.Certification_Type__c = 'Certifications of Excellency';
		sfocCert.Department__c = g1.Name;
		insert ceivCert;
		handleTrace(PREFIX + 'ICG_Certification__c insert');

		ICG_Capability_Assignment_Group__c ardCert = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard.id, sfocCert.id);
		insert ardCert;
		ICG_Capability_Assignment_Group__c ardCert2 = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard2.id, ceivCert.id);
		insert ardCert2;
		handleTrace(PREFIX + 'ICG_Capability_Assignment_Group__c insert');
	}
	@isTest
	static void testGetFacilityCertifications() {
		ICG_Account_Role_Detail__c ard = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1];
		test.startTest();
		string jsonCertifications = CW_CertificationsManagerController.refreshFacilityCertifications(ard.id);
		List<ICG_Capability_Assignment_Group__c> lstCertifications = (List<ICG_Capability_Assignment_Group__c>) JSON.deserialize(jsonCertifications, List<ICG_Capability_Assignment_Group__c>.class);
		System.assertNotEquals(null, lstCertifications[0].id, 'Information not retrieved properly');
		test.stopTest();
	}
	@isTest
	static void testGetAllCertifications() {
		test.startTest();
		string jsonCertifications = CW_CertificationsManagerController.getAllCertifications();
		List<ICG_Certification__c> lstCertifications = (List<ICG_Certification__c>) JSON.deserialize(jsonCertifications, List<ICG_Certification__c>.class);
		System.assertNotEquals(null, lstCertifications[0].id, 'Information not retrieved properly');
		test.stopTest();
	}
	@isTest
	static void testRenewSFOCCertification() {
		ICG_Capability_Assignment_Group__c ardCert = [SELECT id, ICG_Account_Role_Detail__c, ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'SF Operational Capacity' LIMIT 1];
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
		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c LIMIT 1];
		ICG_Capability_Assignment_Group__c ardCert = new ICG_Capability_Assignment_Group__c();
		ardCert.id = null;
		ardCert.ICG_Account_Role_Detail__c = ard.id;
		ardCert.ICG_Certification__c = cert.id;
		ardCert.Certification_Id__c = 'testABC12345';
		ardCert.Issue_Date__c = Date.valueOf('2019-12-12');
		ardCert.Expiration_Date__c = Date.valueOf('2020-12-12');
		string jsonCertificationToAdd = JSON.serialize(ardCert);
		test.startTest();
		
		string certId = CW_CertificationsManagerController.createCertification(jsonCertificationToAdd);
		System.assertNotEquals(null, certId, 'Certification not inserted');
		
		test.stopTest();
	}
	@isTest
	static void testExceptions() {
		test.startTest();
		String newId = CW_CertificationsManagerController.renewCertification(null, null, null, null, null);
		System.assertEquals(false, String.isBlank(newId), 'Certification not inserted');
		
		string certId = CW_CertificationsManagerController.createCertification(null);
		System.assertEquals(null, certId, 'Exception not thrown');
		
		test.stopTest();
	}
	private static void handleTrace(String traceMsg) {
		if (TRACEIT) {
			system.debug(logginglevel.FINEST, traceMsg);
		}
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
		
		ICG_Certification__c newcert = CW_TestDataFactory.newCertification();
		newcert.name = 'CEIV Fresh';
		newcert.certification_type__C = 'Certifications of Excellency';
		insert newcert;
		ICG_Certification__c newcert1 = CW_TestDataFactory.newCertification();
		newcert1.Name = 'CEIV Pharma';
		newcert1.Certification_Type__c = 'Assessments';
		insert newcert1;
		ICG_Certification__c newcert2 = CW_TestDataFactory.newCertification();
		newcert2.name = 'Smart Facility Operational Capacity';
		newcert2.certification_type__C = 'Certifications of Compliance';
		insert newcert2;
		ICG_Certification__c newcert3 = CW_TestDataFactory.newCertification();
		newcert3.name = 'Smart Facility Remote Validation';
		newcert3.certification_type__C = 'Certifications of Compliance';
		insert newcert3;
		
		test.startTest();
		ICG_Certification__c cert = [SELECT id FROM ICG_Certification__c LIMIT 1];
		String result = CW_CertificationsManagerController.getNextCertificationID(cert.id);
		System.assertNotEquals(result, '');

		result = CW_CertificationsManagerController.getNextCertificationID(newcert.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');
		
		result = CW_CertificationsManagerController.getNextCertificationID(newcert1.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');
		
		result = CW_CertificationsManagerController.getNextCertificationID(newcert2.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');
		
		result = CW_CertificationsManagerController.getNextCertificationID(newcert3.Id);
		System.assertNotEquals(result, '', 'Information not retrieved properly');

		test.stopTest();
	}
	
	@isTest
	static void getFacilityDeprecatedCertifications() {
		ICG_Capability_Assignment_Group__c ardCert = [SELECT id, ICG_Account_Role_Detail__c, ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'SF Operational Capacity' LIMIT 1];
		
		test.startTest();
		String result = CW_CertificationsManagerController.getFacilityDeprecatedCertifications(ardCert.ICG_Account_Role_Detail__c, ardCert.ICG_Certification__c);
		System.assertNotEquals(result, '');

		test.stopTest();
	}
	
	@isTest
	static void updateFieldEdited() {
		ICG_Capability_Assignment_Group__c ardCert = [SELECT id, ICG_Account_Role_Detail__c, ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE ICG_Certification__r.Name = 'SF Operational Capacity' LIMIT 1];
		String jsonValue = JSON.serialize(ardCert);
		
		test.startTest();
		Boolean result = CW_CertificationsManagerController.updateFieldEdited(jsonValue);
		System.assertEquals(result, true);
		
		result = CW_CertificationsManagerController.updateFieldEdited(null);
		System.assertEquals(result, false);

		test.stopTest();
	}
}