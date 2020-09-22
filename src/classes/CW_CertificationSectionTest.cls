/*
 * Description: CW_CertificationSection Tests
 *	Modified testSetup method to implemente CW_TestDataFactory.newCertification(),
 *	and to bulkify the insert
 */

@isTest
public class CW_CertificationSectionTest {
	@testSetup
	static void testSetup() {
		// Create the certification
		List<ICG_Certification__c> certs = new List<ICG_Certification__c>();

		ICG_Certification__c cert1 = CW_TestDataFactory.newCertification();
		cert1.Name = 'Test Cert 1';
		cert1.is_visible__C = true;
		certs.add(cert1);

		ICG_Certification__c cert2 = CW_TestDataFactory.newCertification();
		cert2.Name = 'Test Cert 2';
		cert2.is_visible__C = true;
		cert2.Certification_Type__c = 'Certifications of Excellency';
		certs.add(cert2);

		insert certs;

		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account acc = new Account(Name = 'Account01', IATA_ISO_Country__c = country.Id);
		acc.RecordTypeId = agencyRT;
		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		Account_Role__c accRole = new Account_Role__c(Account_Role_Name__c = 'Test', Account__c = acc.Id);
		insert accRole;

		ICG_Account_Role_Detail__c ard = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert ard;
		
		ICG_Account_Role_Detail__c ard2 =  new ICG_Account_Role_Detail__c(Account_Role__c = accRole.Id, IATA_ISO_Country__c = airport.IATA_ISO_Country__c, Nearest_Airport__c = airport.Id, Status__c = 'Approved', Name = 'Test', Available_Languages__c = 'ESP;GER', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Cargo_Handling_Facility'));
		insert ard2;

		ICG_Capability_Assignment_Group__c joinrow = new ICG_Capability_Assignment_Group__c();
		joinrow.ICG_Certification__c = certs[0].Id;
		joinrow.Expiration_Date__c = Date.valueOf('2025-09-16');
		joinrow.Issue_Date__c = Date.valueOf('2020-09-09');
		joinrow.ICG_Account_Role_Detail__c = ard.Id;
		insert joinrow;

		ICG_Capability_Assignment_Group__c joinrow2 = new ICG_Capability_Assignment_Group__c();
		joinrow2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
		joinrow2.ICG_Certification__c = cert1.Id;
		joinrow2.Expiration_Date__c = Date.valueOf('2025-09-16');
		joinrow2.Issue_Date__c = Date.valueOf('2020-09-09');
		joinrow2.ICG_Account_Role_Detail__c = ard2.Id;
		insert joinrow2;
	}

	@isTest
	static void testGetCertificationsWithoutParameters() {
		test.startTest();
		// Without parameters
		List<ICG_Certification__c> certList = CW_CertificationSection.getCertifications('', '');
		System.assertEquals(2, certList.size());
		test.stopTest();
	}

	@isTest
	static void testGetCertificationsNameParameter() {
		test.startTest();
		// With Name parameter
		List<ICG_Certification__c> certList = CW_CertificationSection.getCertifications('', 'Test Cert 1');
		System.assertEquals(1, certList.size());
		System.assertEquals('Test Cert 1', certList[0].Name);
		test.stopTest();
	}

	@isTest
	static void testGetCertificationsTypeParameter() {
		test.startTest();
		// With Type parameter
		List<ICG_Certification__c> certList = CW_CertificationSection.getCertifications('Assessments', '');
		System.assertEquals(1, certList.size());
		System.assertEquals('Assessments', certList[0].Certification_Type__c);
		test.stopTest();
	}

	@isTest
	static void testGetCertificationsBothParameters() {
		test.startTest();
		// With both parameters
		List<ICG_Certification__c> certList = CW_CertificationSection.getCertifications('Certifications of Excellency', 'Test Cert 2');
		System.assertEquals(1, certList.size());
		System.assertEquals('Certifications of Excellency', certList[0].Certification_Type__c);
		System.assertEquals('Test Cert 2', certList[0].Name);
		test.stopTest();
	}

	@isTest
	static void testGetLatestAccountCertifications() {
		test.startTest();
		List<ICG_Capability_Assignment_Group__c> latestAccountCert = CW_CertificationSection.getLatestAccountCertifications();
		System.assertEquals(1, latestAccountCert.size());
		test.stopTest();
	}
}