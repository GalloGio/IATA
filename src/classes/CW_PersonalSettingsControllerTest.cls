/**
 * @description	tests class of CW_PersonalSettingsController
 */
@isTest
public class CW_PersonalSettingsControllerTest {
	/**
	 * @description		Test Setup: to insert two users, one of them as community user
	 */
	@testSetup
	public static void setup() {
		Profile pf = [SELECT Id FROM profile WHERE Name LIKE '%ISS Portal (Partner)%' LIMIT 1];
		Profile pf2 = [SELECT Id FROM profile WHERE Name LIKE '%Guest%' LIMIT 1];
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
		Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
		String uniqueName = orgId + RandomId;

		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		Account acc = CW_TestDataFactory.testAccount(country.Id);
		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		Contact con1 = CW_TestDataFactory.testContact(acc.Id);
		insert con1;

		Account_Contact_Role__c acr = CW_TestDataFactory.testAccountContactRole(accRole.Id, acc.Id, con1.Id);
		insert acr;

		User uu = new User(firstname = 'IATAICGABCUnique2', lastName = 'IATAICGXYZUnique2', email = uniqueName + 'kobe@test.org', Username = uniqueName + 'kobe@test.org', EmailEncodingKey = 'ISO-8859-1', Alias = 'kbryant', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = pf.Id, contactId = con1.id);
		insert uu;

		User u2 = new User(firstname = 'IATAICGABCUnique22', lastName = 'IATAICGXYZUnique22', email = uniqueName + 'blackmamba@test.org', Username = uniqueName + 'blackmamba@test.org', EmailEncodingKey = 'ISO-8859-1', Alias = 'bmguest', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = pf2.Id);
		insert u2;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert accRoleDetail;

		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		insert cert;

		ICG_Capability_Assignment_Group__c joinrow = new ICG_Capability_Assignment_Group__c();
		joinrow.ICG_Certification__c = cert.Id;
		joinrow.Expiration_Date__c = Date.valueOf('2025-09-16');
		joinrow.Issue_Date__c = Date.valueOf('2020-09-09');
		joinrow.ICG_Account_Role_Detail__c = accRoleDetail.Id;
		insert joinrow;
	}

	/**
	 * @description		RunAs identit1 user but without be linked to the community == Guest User
	 */
	@isTest
	public static void testCase01Guest() {
		User us = [SELECT Id, Name FROM User WHERE Alias = 'bmguest' LIMIT 1];

		Test.startTest();

		System.runAs(us) {
			String response = CW_PersonalSettingsController.getUserSettingsInfo();
			CW_PersonalSettingsController.UserWrapper info = (CW_PersonalSettingsController.UserWrapper) JSON.deserialize(response, CW_PersonalSettingsController.UserWrapper.class);
			System.assertEquals(info.userRole, 'Guest', 'Guest path NOT followed');
		}
		Test.stopTest();
	}
	/**
	 * @description		RunAs identit1 user
	 */
	@isTest
	public static void testCase02Identity() {
		User us = [SELECT Id, Name FROM User WHERE Alias = 'kbryant' LIMIT 1];

		Test.startTest();

		System.runAs(us) {
			String response = CW_PersonalSettingsController.getUserSettingsInfo();
			CW_PersonalSettingsController.UserWrapper info = (CW_PersonalSettingsController.UserWrapper) JSON.deserialize(response, CW_PersonalSettingsController.UserWrapper.class);
			System.assertEquals(info.userRole, UserInfo.getUserType(), 'Community path NOT followed');
		}
		Test.stopTest();
	}
}