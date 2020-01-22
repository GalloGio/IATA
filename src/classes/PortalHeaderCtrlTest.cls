@isTest
private class PortalHeaderCtrlTest {

	@TestSetup
	static void testSetup(){

		String IATA_AGENCY_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account newAcc = new Account(Name='Account Test CSP Utils', RecordTypeId = IATA_AGENCY_RT, SIS_ID__c = '12345');
		insert newAcc;

		Contact newCon1 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
		Contact newCon2 = new Contact(AccountId = newAcc.Id, FirstName = 'CSP', LastName = 'Tester', Email = System.today().dayOfYear() + 'testemail2@csp.testclass', User_Portal_Status__c = 'Pending Approval');
		insert new List<Contact>{newCon1, newCon2};

		User newUser = ISSP_ObjectFactory.createPortalUser(newCon1);

		Portal_Applications__c pa1 = new Portal_Applications__c(Name = 'Portal Service 1', Cannot_be_managed_by_portal_admin__c = false);
		Portal_Applications__c pa2 = new Portal_Applications__c(Name = 'Portal Service 2', Cannot_be_managed_by_portal_admin__c = true);
		insert new List<Portal_Applications__c>{pa1, pa2};

		Portal_Application_Right__c par1 = new Portal_Application_Right__c(Contact__c = newCon2.Id, Portal_Application__c = pa1.Id, Right__c = 'Access Requested');
		Portal_Application_Right__c par2 = new Portal_Application_Right__c(Contact__c = newCon2.Id, Portal_Application__c = pa2.Id, Right__c = 'Access Requested');
		insert new List<Portal_Application_Right__c>{par1, par2};

		Notification__c not1 = new Notification__c(Archive__c = false, Contact__c = newCon1.Id, Message__c = 'Test Notification - Archive False', Number_of_views__c = 0);
		Notification__c not2 = new Notification__c(Archive__c = true, Contact__c = newCon1.Id, Message__c = 'Test Notification - Archive True', Number_of_views__c = 0);
		Notification__c not3 = new Notification__c(Archive__c = true, Contact__c = newCon1.Id, Message__c = 'Test Notification - More views', Number_of_views__c = 3);
		insert new List<Notification__c>{not1,not2,not3};

		//Invoice
		Customer_Invoice__c newInv = new Customer_Invoice__c(Invoice_ID__c = 'id-123', Billed_Member_Id__c = '12345',
															 Billing_Member_IS_Sub_Status__c = 'E&F AIRPORT', Invoice_Status__c = 'Unpaid Invoice');
		insert newInv;
	}

	@IsTest
	static void testGetNotifications(){
		User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Notification__c notification = [SELECT Id FROM Notification__c WHERE Archive__c = false LIMIT 1];

		System.runAs(usr){
			Test.startTest();
			List<PortalHeaderCtrl.NotificationItem> notItemList = PortalHeaderCtrl.getNotifications();
			PortalHeaderCtrl.increaseNotificationView(notification.Id);
			Test.stopTest();

			System.assertEquals( 3 , notItemList.size() );
		}
	}

	@IsTest
	static void testredirectToChangePasswordPage(){
		string url =PortalHeaderCtrl.goToOldChangePassword();
		system.assertEquals(url!=null,true);

	}

	@IsTest
	static void testCheckExpiredPassword(){
		ISSP_CS__c cs= new ISSP_CS__c();
		cs.name='PasswordResetPeriod';
		cs.value__c='1';
		insert cs;

		User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		System.runAs(usr){
			Test.startTest();
			string url =PortalHeaderCtrl.redirectChangePassword();
			Test.stopTest();
		}

	}

}
