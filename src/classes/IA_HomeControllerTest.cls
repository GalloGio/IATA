@isTest
public class IA_HomeControllerTest {

	private static final String TEST_LOGO = 'logo_url';

	private static Contact portalcontact;
	private static User portaluser;
	private static Account airline1;

	@TestSetup
	public static void setup(){
		airline1 = TestDataFactory_Accounts.createAirlines(1).get(0);
		insert airline1;

		portalcontact = TestDataFactory_Contacts.createDefaultContact(1).get(0);
		portalcontact.AccountId = airline1.Id;
		insert portalcontact;

		portalUser = TestDataFactory_Users.createPortalUsers(new list<Contact>{portalcontact}).get(0);
		insert portalUser;

		update portalcontact;

		Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		app.Name = IA_HomeController.APP_NAME;
		app.Application_icon_URL__c = TEST_LOGO;
		insert app;

		insert TestDataFactory_PortalApplicationRights.createGrantedPortalApplicationRight(app.Id, portalcontact.Id);
	}

	private static void queryRecords() {
		portalcontact = [SELECT Id FROM Contact WHERE Email = :(TestDataFactory_Contacts.DEFAULTEMAIL+'0')];
		portaluser = [SELECT Id, Name, ContactId FROM User WHERE ContactId = :portalcontact.Id];
	}

	static TestMethod void testController_NoAccess(){
		queryRecords();

		Portal_Application_Right__c right = [Select Right__c from Portal_Application_Right__c where Contact__c = :portalUser.ContactId];
		right.Right__c = TestDataFactory_PortalApplicationRights.DENIED;
		update right;

		Test.startTest();
		System.runAs(portalUser){
			IA_HomeController ctrl = new IA_HomeController();
			PageReference page = ctrl.initActions();
			System.assert(page!=null, 'No page should be returned');
		}
		Test.stopTest();
	}

	static testMethod void testController(){
		queryRecords();

		Test.startTest();
		System.runAs(portalUser){
			IA_HomeController ctrl = new IA_HomeController();

			PageReference page = ctrl.initActions();
			System.assert(page==null);

			System.assertEquals(TEST_LOGO,ctrl.appLogoURL);
			System.assertEquals(true,ctrl.getWithdrawPermission());
			System.assertEquals(true,ctrl.getApprovePermission());
			System.assertEquals(true,ctrl.getRequestPermission());
			System.assertEquals(true,ctrl.getEditContactsPermission());
		}
		Test.stopTest();
	}

}
