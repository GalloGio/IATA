/*
 * @author
 * Description: CW_PrivateAreaController Tests
 */
@isTest
public class CW_PrivateAreaControllerTest {
	/*
	Test Setup: 
	*/
	@testSetup
	public static void setup() {
		Profile pf = [SELECT Id FROM profile WHERE Name LIKE '%ISS Portal (Partner)%' LIMIT 1];
		String orgId = UserInfo.getOrganizationId();
		String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
		Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
		String uniqueName = orgId + RandomId;

		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		Account acc = CW_TestDataFactory.testAccount(country.Id);
		Id auxRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others');
		acc.RecordTypeId = auxRecordTypeId;
		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		Contact con1 = CW_TestDataFactory.testContact(acc.Id);
		insert con1;

		Account_Contact_Role__c acr = CW_TestDataFactory.testAccountContactRole(accRole.Id, acc.Id, con1.Id);
		insert acr;

		User uu = new User(firstname = 'IATAICGABCUnique2', lastName = 'IATAICGXYZUnique2', email = uniqueName + '@test.org', Username = uniqueName + '@test.org', EmailEncodingKey = 'ISO-8859-1', Alias = uniqueName.substring(18, 23), TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', ProfileId = pf.Id, contactId = con1.id);

		insert uu;

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

	/*
	 * @author
	 * Description: get User Facilities
	 */
	@isTest
	public static void getUserFacilitiesTest() {
		User usr = [SELECT id FROM User WHERE firstname = 'IATAICGABCUnique2' AND lastname = 'IATAICGXYZUnique2' AND username LIKE '%test.org%' LIMIT 1];
		System.runAs(usr) {
			Test.startTest();
			final String response = CW_PrivateAreaController.getUserFacilities(null);
			Map<String, OpsHierarchyDataWrapper> resultList = (Map<String, OpsHierarchyDataWrapper>) System.JSON.deserialize(response, Map<String, OpsHierarchyDataWrapper>.class);
			System.assertNotEquals(response, '', 'User has no belonging facilities');
			System.assertNotEquals(null, resultList, 'Returned value is null');
			System.assertNotEquals(0, resultList.size(), 'User has no belonging facilites');
			Test.stopTest();
		}
	}

	/*
	 * @author
	 * Description: get User Company Info
	 */
	@isTest
	public static void getUserCompanyInfoTest() {
		User usr = [SELECT id FROM User WHERE firstname = 'IATAICGABCUnique2' AND lastname = 'IATAICGXYZUnique2' AND username LIKE '%test.org%' LIMIT 1];
		System.runAs(usr) {
			Test.startTest();
			final String response = CW_PrivateAreaController.getUserCompanyInfo(null);
			Account acc = (Account) System.JSON.deserialize(response, Account.class);
			System.assertNotEquals(response, '', 'User has no belonging company info');
			System.assertNotEquals(null, acc, 'Returned account is null');
			System.assertEquals('Spain', acc.IATA_ISO_Country__r.Name, 'Returned information is not correct');
			Test.stopTest();
		}

	}

	@isTest
	public static void getOrganizationTest() {
		Test.startTest();
		Boolean response = CW_PrivateAreaController.isProductionEnvironment();
		Boolean checkTest = UserInfo.getOrganizationId().substring(0, 15) == '00D2000000008TF' ? true : false;
		Test.stopTest();

		System.assertEquals(checkTest, response, 'Invalid response');
	}

	@isTest
	public static void getUserInfoTest() {
		List<User> usrs = [SELECT id FROM User WHERE firstname = 'IATAICGABCUnique2' AND Lastname = 'IATAICGXYZUnique2'];

		System.runAs(usrs[0]) {
			String response;
			Test.startTest();
			response = CW_PrivateAreaController.getUserInfo();
			Test.stopTest();

			System.assertNotEquals(response, '', 'Result value is empty');
			System.assertEquals(((User) JSON.deserialize(response, User.class)).Id, usrs[0].Id, 'Found User');
		}
	}

	/*
	 * @author
	 * Description: get User Info
	 */
	@isTest
	public static void getActiveCertificationsTest() {
		Test.startTest();
		String response = CW_PrivateAreaController.getActiveCertifications();
		List<ICG_Certification__c> resultList = (List<ICG_Certification__c>) System.JSON.deserialize(response, List<ICG_Certification__c>.class);
		Test.stopTest();

		System.assertNotEquals(response, '', 'Result value is empty');
		System.assert(resultList.size() > 0, 'List of certifications is empty');

		for (ICG_Certification__c cert : resultList) {
			System.assert(cert.Is_Visible__c, 'A certification with is_visible = false was returned');
			System.assertEquals('Assessments', cert.Certification_Type__c, 'The certification does not have the right type');
		}
	}

	public class OpsHierarchyDataWrapper {
		public Boolean isCompanyAdmin { get; set; }
		public Boolean isPendingCompanyAdmin { get; set; }
		public List<CompanyWrapper> companyList { get; set; }
		public OpsHierarchyDataWrapper(Boolean isCompanyAdmin, Boolean isPendingCompanyAdmin, List<CompanyWrapper> cwrap) {
			this.isCompanyAdmin = isCompanyAdmin;
			this.isPendingCompanyAdmin = isPendingCompanyAdmin;
			this.companyList = cwrap;
		}
	}
	public class CompanyWrapper {
		public Account accountInfo { get; set; }
		public List<ICG_Account_Role_Detail__c> stations { get; set; }
		public CompanyWrapper(Account acc, List<ICG_Account_Role_Detail__c> stations) {
			this.accountInfo = acc;
			this.stations = stations;
		}
	}

	@isTest
	public static void testGetGxaSSOUrl() {
		Test.startTest();
		CW_PrivateAreaController.GroupDataWrapper groupData = new CW_PrivateAreaController.GroupDataWrapper('id', null, 'status', true, true);
		CW_PrivateAreaController.OpsHierarchyDataWrapper ops = new CW_PrivateAreaController.OpsHierarchyDataWrapper(groupData, null);
		CW_PrivateAreaController.getGxaSSOUrl();
		Test.stopTest();
	}
}