@isTest
private class ISSP_CurrencyCenterUtilTest {
	@isTest static void testCheckIfUserHasAccessToServiceWithoutUser() {
		PageReference result = ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
		System.assertNotEquals(new PageReference('/ISSP_Homepage'),result);
	}

	@isTest static void testStampVisitDateTimeWithoutUser() {
		ISSP_CurrencyCenterUtil.stampVisitDateTime(8);
	}

	@isTest static void testMethodsWithUsers() {
		Test.startTest();

		UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE PortalType = 'None' LIMIT 1];
		Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		
		User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name='System Administrator' LIMIT 1];
		adminUser.UserRoleId = userRole.Id;
		adminUser.IsActive = true;
		update adminUser;

		System.runAs(adminUser){
			Id conRtId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Contact', 'Standard_Contact');

			Set<String> customerUserTypes = new Set<String> {'CSPLiteUser','PowerPartner','PowerCustomerSuccess','CustomerSuccess'};
			Account acc = TestDataFactory_Accounts.createStandardAccounts(1).get(0);

			Contact con = TestDataFactory_Contacts.createDefaultContact(acc.id,1).get(0);
			con.RecordTypeId = conRtId;
			con.User_Portal_Status__c = 'Approved User';
			insert con;

			UserRole partnerUserRole = [SELECT Id, DeveloperName FROM UserRole WHERE PortalType = 'Partner' LIMIT 1];
			Profile p = [SELECT Id, Name FROM Profile WHERE UserType in :customerUserTypes LIMIT 1];
			User newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{con}).get(0);
			newUser.UserRoleId = partnerUserRole.Id;
			newUser.profileId = p.id;
			newUser.IsActive = true;
			insert newUser;

			Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
			app.Application_URL__c='/ISSP_CurrencyCenterHome';
			insert app;

			Portal_Application_Right__c par = new Portal_Application_Right__c(
				Contact__c = newUser.ContactId,
				Right__c = 'Access Granted',
				Portal_Application__c = app.Id
			);
			insert par;
		}

		User newUser = [SELECT Id FROM User WHERE Email = :TestDataFactory_Contacts.DEFAULTEMAIL + '0'];
		System.runAs(newUser){
			ISSP_CurrencyCenterUtil.stampVisitDateTime(8);
			ISSP_CurrencyCenterUtil.checkIfUserHasAccessToService();
			ISSP_CurrencyCenterUtil.getPreviousVisitDateTime();
		}
		Test.stopTest();
	}

	@isTest static void testGetPreviousVisitDateTime() {
		ISSP_CurrencyCenterUtil.getPreviousVisitDateTime();
	}
}