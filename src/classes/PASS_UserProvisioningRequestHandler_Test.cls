@isTest
public class PASS_UserProvisioningRequestHandler_Test {
	@isTest//(SeeAllData = true)
	static void PASS_UserProvisioningRequestHandler_PassUserProv() {

		Test.startTesT();
		UserProvisioningRequest upr = UserProvisioningTestUtils.createUserProvisioningRequest('Pass User Prov', 'Update');
		//UserProvisioningRequest upr2 = UserProvisioningTestUtils.createUserProvisioningRequest('Pass User Prov','Update','Completed');

		UserProvisioningUtils userProvUtils = new UserProvisioningUtils(false);
		userProvUtils.init(upr.Id);

		// Delete the initially created UPA
		UserProvAccount firstUpa = userProvUtils.getLinkedUserProvAccount();
		firstUpa.Status = 'Deleted';
		update firstUpa;

		// Create an active user provisioning account
		UserProvAccount activeUpa = new UserProvAccount(
			salesforceUserId = upr.salesforceUserId,
			connectedAppId = upr.connectedAppId,
			externalUserId = '4321',
			externalUserName = firstUpa.externalUserName,
			externalFirstName = firstUpa.externalFirstName,
			externalLastName = firstUpa.externalLastName,
			linkState = 'Linked',
			status = 'Active'
		);
		insert activeUpa;

		UserProvAccount actualUpa = userProvUtils.getLinkedUserProvAccount();
		Test.stopTest();
	}

	@isTest
	static void testAddPASSPermissionSet() {
		Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
		User user = new User(
			userName = DateTime.now().getTime() +'john.doe@example.org',
			email = 'john.doe@example.org',
			firstName = 'John',
			lastName = 'Doe',
			profileId = p.id,
			alias = 'johndoe',
			TimeZoneSidKey = 'GMT',
			LocaleSidKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			LanguageLocaleKey = 'en_US',
			License_Cost_Center__c = 'ISF005CH01'
		);
		insert user;
		List<Id> idList = new List<Id>();
		idList.add(user.id);
		PASS_UserProvisioningRequestHandler.addPassPrimaryPermissionSet(idList);
	}


}