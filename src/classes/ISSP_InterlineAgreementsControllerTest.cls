@isTest
public class ISSP_InterlineAgreementsControllerTest {

	private static Id RT_AIRLINE = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

	private static Contact portalcontact;
	private static User portaluser;
	private static Account airline1;

	@TestSetup
	public static void setup(){
		airline1 = new Account(
			RecordTypeId = RT_AIRLINE,
			Name='MyAirline1',
			ACLI_Status__c = 'Active Company',
			MITA_Member__c = true,
			BIETA_Member__c = true,
			Airline_designator__c = 'AA',
			IATACode__c = '111',
			Airline_Prefix__c = '111',
			MITA_IATA_Interline_Passenger__c = Date.today(),
			MITA_IATA_Interline_Cargo__c = Date.today(),
			MITA_One_way_Pass_Issuing_Airline__c = Date.today(),
			MITA_One_way_Pass_Participating__c = Date.today(),
			BIETA_Bilateral_Date__c = Date.today(),
			BIETA_One_way_Electronic_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Electronic_Participating__c = Date.today(),
			BIETA_One_way_Intermodal_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Intermodal_Participating__c = Date.today()
		);
		insert airline1;

		portalcontact = new Contact(
			FirstName = 'Name',
			LastName='My Contact',
			AccountId=airline1.Id,
			Email='contact@MyAirline.com',
			Status__c = 'Active'
		);
		insert portalcontact;

		Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Airline User (Partner)'];
		portalUser = new User(
			Alias = 'standt',
			Email=DateTime.now().getTime()+'standarduser@testorg.com',
			EmailEncodingKey='UTF-8',
			LastName='Testing',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			ProfileId = p.Id,
			ContactId = portalcontact.Id,
			IsActive = true,
			TimeZoneSidKey='America/Los_Angeles',
			UserName='standarduser@testorg.com'
		);
		insert portalUser;

		portalcontact.User_Portal_Status__c = 'Approved Admin';
		portalcontact.Community__c = 'Community__c';
		update portalcontact;

		Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		app.Name = ISSP_InterlineAgreementsController.APP_NAME;
		app.Application_icon_URL__c = 'logo_url';
		insert app;

		Portal_Application_Right__c right = new Portal_Application_Right__c(
			Portal_Application__c = app.Id,
			Right__c = 'Access Granted',
			Contact__c = portalcontact.Id
		);
		insert right;

	}

	private static void queryRecords() {
		portalcontact = [SELECT Id FROM Contact WHERE Email = 'contact@MyAirline.com'];
		portaluser = [SELECT Id, Name, ContactId FROM User WHERE ContactId = :portalcontact.Id];
	}

	static TestMethod void testController_NoAccess(){
		queryRecords();

		Portal_Application_Right__c right = [Select Right__c from Portal_Application_Right__c where Contact__c = :portalUser.ContactId];
		right.Right__c = 'Access Denied';
		update right;

		Test.startTest();
		System.runAs(portalUser){
			ISSP_InterlineAgreementsController ctrl = new ISSP_InterlineAgreementsController();
			PageReference page = ctrl.initActions();
			System.assert(page!=null, 'No page should be returned');
		}
		Test.stopTest();
	}

	static TestMethod void testController(){
		queryRecords();

		Test.startTest();
		System.runAs(portalUser){
			ISSP_InterlineAgreementsController ctrl = new ISSP_InterlineAgreementsController();

			PageReference page = ctrl.initActions();
			System.assert(page==null);

			System.assertEquals('logo_url',ctrl.appLogoURL);
			System.assertEquals(true,ctrl.getWithdrawPermission());
			System.assertEquals(true,ctrl.getApprovePermission());
			System.assertEquals(true,ctrl.getRequestPermission());
			System.assertEquals(true,ctrl.getEditContactsPermission());
		}
		Test.stopTest();
	}

}
