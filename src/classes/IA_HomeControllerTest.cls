@isTest
public class IA_HomeControllerTest {
	private static final String TEST_LOGO = 'logo_url';

	@TestSetup
	public static void setup(){
		Account airline1 = TestDataFactory_Accounts.createAirlineAccounts(1).get(0);
		insert airline1;

		Contact portalcontact = TestDataFactory_Contacts.createDefaultContact(airline1.Id, 1).get(0);
		insert portalcontact;

		Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		app.Name = IA_HomeController.APP_NAME;
		app.Application_icon_URL__c = TEST_LOGO;
		insert app;

		Portal_Application_Right__c par = TestDataFactory_PortalApplicationRights.createPortalApplicationRight(app.Id, portalcontact.Id);
		par.Right__c = TestDataFactory_PortalApplicationRights.GRANTED;
		insert par;

		User adminUser = [SELECT Id, UserRoleId FROM User WHERE IsActive = TRUE AND UserRoleId != NULL AND Profile.Name='System Administrator' LIMIT 1];
		System.runAs(adminUser){
			User portalUser = TestDataFactory_Users.createPortalUsers(new list<Contact>{portalcontact}).get(0);
			insert portalUser;
		}
	}

	static TestMethod void testController_NoAccess(){
		Contact portalcontact = [SELECT Id FROM Contact WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0'];
		User portaluser = [SELECT Id, Name, ContactId FROM User WHERE ContactId = :portalcontact.Id];

		Portal_Application_Right__c right = [SELECT Right__c FROM Portal_Application_Right__c WHERE Contact__c = :portalUser.ContactId];
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
		Contact portalcontact = [SELECT Id FROM Contact WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0'];
		User portaluser = [SELECT Id, Name, ContactId FROM User WHERE ContactId = :portalcontact.Id];

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