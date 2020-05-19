@isTest
public class PASS_UserProvisioningRequestHandler_Test {
	@isTest
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

	@isTest
	static void passAddNewUser(){

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c (Name = 'PT', ISO_Code__c = 'PT', Airline_EasyPay_Opt_Out_Date__c = Date.today()-1);
		insert countryPT;
		Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Account acct_hq = new Account(Name = 'PT Airways', Airline_designator__c = 'PT', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', Category__c=AMS_Utils.CATEGORY_PASSENGER_ONLY,
									  Sector__c=AMS_Utils.SECTOR_AIRLINE, RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = countryPT.Id, Membership_status__c = 'Non-IATA member');
		insert acct_hq;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acct_hq.Id;
		con.Email = 'Test@test1122.com';
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalUser(con);
		con.OwnerId = newUser.Id;
		update con;

		Portal_Applications__c pa = new Portal_Applications__c(name = AMS_Utils.passSSOPortalService);
		insert pa;

		Connected_App_Roles__c crole = new Connected_App_Roles__c();
		crole.Name='PASS';
		insert crole;

		
		Portal_Application_Right__c portalAccess = new Portal_Application_Right__c();
		portalAccess.Portal_Application__c = pa.Id;
		portalAccess.Right__c = 'Access Requested';
		portalAccess.Contact__c = con.Id;

		insert portalAccess;

		portalAccess.Right__c = 'Access Granted';
		update portalAccess;

		portalAccess.Right__c = 'Access Denied';
		update portalAccess;

		portalAccess.Right__c = 'Access Granted';
		update portalAccess;

		List<UserProvisioningRequest> userProvs = [SELECT Id FROM UserProvisioningRequest];
		System.assertEquals(3, userProvs.size());

	}


}
