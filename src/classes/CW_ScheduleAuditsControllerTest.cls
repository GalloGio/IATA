@isTest
public class CW_ScheduleAuditsControllerTest {
	@testSetup
	public static void setupRows() {
		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		IATA_ISO_State__c state = new IATA_ISO_State__c(IEC_Valid_SAP__c = true, IATA_ISO_Country__c = country.Id, Name = 'Ontario', ISO_Code__c = 'CA-ON');
		insert state;

		IATA_ISO_City__c city = new IATA_ISO_City__c(Name = 'Madrid', IATA_ISO_State__c = state.id, Status__c = 'Verified', GeonameName__c = 'Madrid');
		insert city;

		Account acc = new Account(Name = 'Account01', IATA_ISO_Country__c = country.Id);
		acc.Business_City__c = city.Id;
		acc.Business_Geo_Coordinates__Latitude__s = 37;
		acc.Business_Geo_Coordinates__Longitude__s = 20;

		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		accRoleDetail.Customer_Service_Email__c = 'custom@emai.es';
		accRoleDetail.Customer_Service_Phone_Number__c = '234123432';
		accRoleDetail.Is_On_Airport__c = true;
		accRoleDetail.Is_Direct_Ramp_Access__c = true;
		accRoleDetail.General_Cargo__c = true;
		accRoleDetail.Website__c = 'website.es';
		accRoleDetail.Online_Booking_System_Link__c = 'dummyvalue';
		insert accRoleDetail;

		List<ICG_Certification__c> lstCertis = new List<ICG_Certification__c>();
		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		cert.Department__c = 'TheTestQueue';
		lstCertis.add(cert);
		ICG_Certification__c newcert = CW_TestDataFactory.newCertification();
		newcert.name = 'AnotherName';
		newcert.certification_type__C = 'Certifications of Excellency';
		newcert.Department__c = 'TheTestQueue';
		lstCertis.add(newcert);

		insert lstCertis;

		Group g1 = new Group(Name = 'TheTestQueue', type = 'Queue');
		insert g1;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'ICG_Notification__c');
			insert q1;
			GroupMember member = new GroupMember();
			member.UserOrGroupId = UserInfo.getUserId();
			member.GroupId = g1.Id;
			insert member;
		}

	}

	@isTest
	public static void insertIcgNotifications() {
		List<ICG_Certification__c> cert = [SELECT id, name FROM ICG_Certification__c];
		Id stationId = [SELECT id FROM ICG_Account_Role_Detail__c LIMIT 1].id;
		Test.startTest();
		List<CW_ScheduleAuditsController.CertData> crtdatalist = new List<CW_ScheduleAuditsController.CertData>();
		CW_ScheduleAuditsController.CertData crtdata = new CW_ScheduleAuditsController.CertData();
		crtdata.id = cert[0].id;
		crtdata.name = cert[0].name;
		crtdatalist.add(crtdata);
		ICG_Notification__c icgn = new ICG_Notification__c();
		icgn.Preferable_Audit_Date__c = Date.today();
		icgn.Station__c = stationId;
		CW_ScheduleAuditsController.saveAudit(JSON.serialize(icgn), JSON.serialize(crtdatalist));
		List<ICG_Notification__c> notificationsGet = (List<ICG_Notification__c>) JSON.deserialize(CW_ScheduleAuditsController.getUserRequestedAudits(new List<String>{ stationId }), List<ICG_Notification__c>.class);
		system.assertEquals(1, notificationsGet.size());
		Test.stopTest();
		system.assertEquals(1, [SELECT id FROM ICG_Notification__c].size());
	}
}