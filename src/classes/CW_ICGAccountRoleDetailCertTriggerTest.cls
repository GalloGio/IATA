@isTest
public class CW_ICGAccountRoleDetailCertTriggerTest {
	@testSetup
	public static void setupRows() {
		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		Account acc = new Account(Name = 'Account01', IATA_ISO_Country__c = country.Id);
		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		Account_Role__c accRole = new Account_Role__c(Account_Role_Name__c = 'Test', Account__c = acc.Id);
		insert accRole;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert accRoleDetail;

		ICG_Account_Role_Detail_Relationship__c ardr = new ICG_Account_Role_Detail_Relationship__c();
		ardr.ICG_Account_Role_Detail__c = accRoleDetail.Id;
		ardr.Handled_Airline__c = acc.Id;
		insert ardr;

		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		cert.Name = 'CEIV Pharma';
		cert.Certification_Type__c = 'Assessments';
		insert cert;
		ICG_Certification__c newcert = CW_TestDataFactory.newCertification();
		newcert.name = 'CEIV Fresh';
		newcert.certification_type__C = 'Certifications of Excellency';
		insert newcert;
		ICG_Certification__c newcert2 = CW_TestDataFactory.newCertification();
		newcert2.name = 'Smart Facility Operational Capacity';
		newcert2.certification_type__C = 'Certifications of Compliance';
		insert newcert2;

		ICG_Capability_Assignment_Group__c joinrow = new ICG_Capability_Assignment_Group__c();
		joinrow.ICG_Certification__c = cert.Id;
		joinrow.Expiration_Date__c = Date.today().addYears(10);
		joinrow.Issue_Date__c = Date.valueOf('2020-09-09');
		joinrow.ICG_Account_Role_Detail__c = accRoleDetail.Id;
		insert joinrow;
		ICG_Capability_Assignment_Group__c joinrow2 = new ICG_Capability_Assignment_Group__c();
		joinrow2.ICG_Certification__c = newcert.Id;
		joinrow2.Expiration_Date__c = Date.today().addYears(10);
		joinrow2.Issue_Date__c = Date.valueOf('2020-09-09');
		joinrow2.ICG_Account_Role_Detail__c = accRoleDetail.Id;
		insert joinrow2;
		ICG_Capability_Assignment_Group__c joinrow3 = new ICG_Capability_Assignment_Group__c();
		joinrow3.ICG_Certification__c = newcert2.Id;
		joinrow3.Expiration_Date__c = Date.today().addYears(10);
		joinrow3.Issue_Date__c = Date.valueOf('2020-09-09');
		joinrow3.ICG_Account_Role_Detail__c = accRoleDetail.Id;
		joinrow3.SFOC_Scope__c = 'General Cargo;Dangerous Goods;Perishables;Airmail;Live Animals';
		insert joinrow3;
		joinrow3.Issue_Date__c = Date.today();
		update joinrow3;
	}

	@isTest
	public static void assertAlignment() {
		List<ICG_Account_Role_Detail__c> accr = [SELECT id, Pharmaceuticals__c, Live_Animals__c, Perishables__c, General_Cargo__c, Dangerous_Goods__c, Airmail__c FROM ICG_Account_Role_Detail__c LIMIT 1];
		system.assert(!accr.isEmpty());
		if (!accr.isEmpty()) {
			System.assertEquals(true, accr[0].Pharmaceuticals__c);
			System.assertEquals(true, accr[0].Live_Animals__c);
			System.assertEquals(true, accr[0].Perishables__c);
			System.assertEquals(true, accr[0].General_Cargo__c);
			System.assertEquals(true, accr[0].Dangerous_Goods__c);
			System.assertEquals(true, accr[0].Airmail__c);
		}
	}
}