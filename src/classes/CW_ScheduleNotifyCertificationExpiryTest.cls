/**
 * @description		Test class for CW_ScheduleNotifyCertificationExpiry
 *
 * Edit Log:
 * @history			2020/04/29  |  sf-621  |  Creation.
 */
@IsTest
public with sharing class CW_ScheduleNotifyCertificationExpiryTest {
	@TestSetup
	static void setup() {
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
		insert ard;
		ICG_Account_Role_Detail__c ard2 = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert ard2;

		ICG_Certification__c sfocCert = CW_TestDataFactory.newCertification();
		sfocCert.Name = 'SF Operational Capacity';
		insert sfocCert;
		ICG_Certification__c ceivCert = CW_TestDataFactory.newCertification();
		ceivCert.Certification_Type__c = 'Certifications of Excellency';
		insert ceivCert;

		ICG_Capability_Assignment_Group__c ardCert = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard.id, sfocCert.id);
		ardCert.Expiration_Date__c = Date.today().addDays(10);
		insert ardCert;

		ICG_Environment_Variables__c env = new ICG_Environment_Variables__c();
		env.EXPIRING_VALIDATION_DAYS__c = 60;
        insert env;
        
        Contact cto = CW_TestDataFactory.testContact(acc.Id);
        insert cto;
        
        Account_Contact_Role__c accountContactRole = CW_TestDataFactory.testAccountContactRole(accRole.Id, acc.Id, cto.Id);
        insert accountContactRole;
        
        ICG_Contact_Role_Detail__c contactRoleDetail = CW_TestDataFactory.testICGContactRoleDetail(accountContactRole.Id, ard.Id);
        contactRoleDetail.Account_Role__c = accRole.Id;
        insert contactRoleDetail;
	}

	@IsTest
	public static void testSchedule() {
		Test.StartTest();
		CW_ScheduleNotifyCertificationExpiry sh1 = new CW_ScheduleNotifyCertificationExpiry();
		sh1.execute(null);
		Test.stopTest();
		System.assertEquals(1, [SELECT COUNT() FROM ICG_Capability_Assignment_Group__c WHERE Upcoming_Expiration_Notification_Sent__c = true], 'No upcoming emails were sent');
	}
}