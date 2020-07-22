/**
 * @description		Test class for CW_BatchRemoveOldNotifications
 *
 * Edit Log:
 * @history			2020/04/29  |  sf-621  |  Creation.
 */
@IsTest
public with sharing class CW_BatchRemoveOldNotificationsTest {
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
		ICG_Capability_Assignment_Group__c ardCert2 = CW_TestDataFactory.createIcgCapabilityAssignmentGroupCertification(ard2.id, ceivCert.id);
		ardCert2.Expiration_Date__c = Date.today();
		insert ardCert2;

		String RT_NOTIFICATION_PRIVATE_AREA = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Notification__c', 'PrivateArea');
		ICG_Notification__c notification = new ICG_Notification__c(RecordTypeId = RT_NOTIFICATION_PRIVATE_AREA, Read__c = true, CreatedDate = Date.today() - 32);
		insert notification;
	}

	@IsTest
	public static void testBatch() {
		Test.startTest();
		CW_BatchRemoveOldNotifications batchNotif = new CW_BatchRemoveOldNotifications();
		Id batchId = Database.executeBatch(batchNotif);
		Test.stopTest();
		System.assertEquals(0, [SELECT COUNT() FROM ICG_Notification__c WHERE Read__c = true]);
		System.abortJob(batchId);
	}
}