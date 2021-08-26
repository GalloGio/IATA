/*************************************************************************************************************
 * @name			MFA_LoginFlowControllerTest
 * @author			Beatriz <beatriz.menendez@adesso.es>
 * @created			17 / 06 / 2021
 * @description		Test class for the MFALoginFlowController class
 *
**************************************************************************************************************/
@isTest
public with sharing class MFA_LoginFlowControllerTest {

	private static final String SECURITY_QUESTION = 'Security question';
	private static final String SECURITY_ANSWER = 'Answer';
	private static final String ASSERT_SECURITY_QUESTION_MSG = 'Wrong security question';
	private static final String ASSERT_SECURITY_ANSWER_MSG = 'Wrong security answer';
	private static final String ASSERT_SAVE_MSG = 'Error on saving security question';
	private static final String ASSERT_REDIRECTIOM_MSG = 'Partner user should be redirected to home page';
	private static final String ASSERT_RETURN_MSG = 'Wrong return value';
	private static final String ASSERT_PERMISSION_SET_MSG = 'Permission not correctly assigned';
	private static final String ASSERT_REGISTER_MSG = 'Register method should return the qr and key';
	private static final String ASSERT_DEREGISTER_MSG = 'Related opt app should be deleted';
	private static final String ASSERT_LINK_MSG = 'Links must be defined on metadata';
	private static final String ASSERT_GUEST_MSG = 'GuestUser is not logged';
	private static final String ASSERT_LANGUAGE_MSG = 'Wrong language';
	private static final String ASSERT_TRANSLATIONS_MSG = 'English translations must be defined in metadata';

	@TestSetup
	static void makeData(){
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ISSP_SSO'];

		User sysAdminUser = [SELECT Id, UserRoleId FROM User Where IsActive = TRUE AND Profile.Name='System Administrator' Limit 1];
		UserRole userRole = [SELECT Id, DeveloperName FROM UserRole Where DeveloperName = 'DirectorGeneral' Limit 1];
		sysAdminUser.UserRoleId = userRole.Id;
		update sysAdminUser;

		User adminUser;
		User guestUser;
		User partnerUser;
		System.runAs(sysAdminUser){
			//Test Account
			Account testAcc = TestDataFactory_Accounts.createDefaultAccounts(1).get(0);
			insert testAcc;

			//get profiles
			Profile partnerProfile = new List<Profile>([SELECT Id FROM Profile WHERE UserLicense.MasterLabel = 'Partner Community' AND Name = 'ISS Portal (Partner)' LIMIT 1]).get(0);
			Profile guestProfile = new List<Profile>([SELECT Id FROM Profile WHERE UserLicense.MasterLabel = 'Guest License' AND Name = 'CS Portal Profile' LIMIT 1]).get(0);
			Profile adminProfile = new List<Profile>([SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]).get(0);

			//Create contact
			List<Contact> contactLst = TestDataFactory_Contacts.createDefaultContact(testAcc.id,1);
			insert contactLst;

			//Create test users
			List<User> testUsers = new List<User>();
			//Partner
			List<User> partnerUserLst = TestDataFactory_Users.createPortalUsers(contactLst);
			partnerUser = partnerUserLst.get(0);
			partnerUser.FirstName = 'MFAPortalUser';
			partnerUser.ProfileId = partnerProfile.Id;
			//Guest
			guestUser = new User(FirstName = 'MFAGuestUser', LastName = 'Guest', email = 'MFATestGuest@iataExample.org', Alias = 'gstMFA',
									UserName = 'MFATestGuest@iataExample.org', ProfileId = guestProfile.Id,
									EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/los_Angeles');
			//Admin
			adminUser = new User(FirstName = 'MFAAdminUser', LastName = 'Guest', email = 'MFATestAdmin@iataExample.org', Alias = 'admMFA',
									UserName = 'MFATestAdmin@iataExample.org', ProfileId = adminProfile.Id, License_Cost_Center__c = 'ISF005CH01',
									EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/los_Angeles');

			testUsers.add(adminUser);
			testUsers.add(guestUser);
			testUsers.add(partnerUser);
			insert testUsers;

			//Set test current page
			PageReference mfaLoginFlowController = Page.MFA_LoginFlowPage;
			mfaLoginFlowController.getParameters().put('retURL', '/csportal/');
			test.setCurrentPage(mfaLoginFlowController);
		}

		System.runAs(adminUser){
			//Permission sets
			List<PermissionSetAssignment> psAssignment = new List<PermissionSetAssignment>();
			psAssignment.add(new PermissionSetAssignment(AssigneeId = partnerUser.id, PermissionSetId = ps.Id));
			psAssignment.add(new PermissionSetAssignment(AssigneeId = guestUser.id, PermissionSetId = ps.Id));
			insert psAssignment;
		}
	}

	@isTest
	static void setFirstSetupParameter(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){

			Test.startTest();
				Pagereference pr = MFA_LoginFlowController.setFirstSetupParameter();
			Test.stopTest();
			System.assertNotEquals(null, pr, ASSERT_REDIRECTIOM_MSG);
		}
	}

	@isTest
	static void redirectToLoginPage(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){
			MFA_LoginFlowController controller = new MFA_LoginFlowController();
			Test.startTest();
				try{
					controller.redirectToLoginPage();
					System.assert(false, ASSERT_REDIRECTIOM_MSG);
				}catch(Exception e){
					System.assert(true, ASSERT_REDIRECTIOM_MSG);
				}
			Test.stopTest();
		}
	}

	@isTest
	static void redirectGuestToLoginPage(){
		User testGuestUser = [SELECT Id FROM User WHERE FirstName = 'MFAGuestUser' LIMIT 1];
		System.runAs(testGuestUser){
			MFA_LoginFlowController controller = new MFA_LoginFlowController();
			Test.startTest();
				try{
					controller.redirectGuestToLoginPage();
					System.assert(false, ASSERT_REDIRECTIOM_MSG);
				}catch(Exception e){
					System.assert(true, ASSERT_REDIRECTIOM_MSG);
				}
			Test.stopTest();
		}
	}

	@isTest
	static void finishFlow(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){

			Test.startTest();
				Pagereference pr = MFA_LoginFlowController.finishLoginFlowHome();
			Test.stopTest();
			System.assertNotEquals(null, pr, ASSERT_REDIRECTIOM_MSG);
		}
	}

	@isTest
	static void setSecurityQuesionForMFA(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){

			Test.startTest();
				Boolean saved;
				if(!MFA_LoginFlowController.hasQuestionAndAnswer){
					saved = MFA_LoginFlowController.saveQuestionAnswer(SECURITY_QUESTION, SECURITY_ANSWER);
				}
			Test.stopTest();

			System.assert(saved, ASSERT_SAVE_MSG);
			User updatedUser = [Select Id, X2FA_Security_Question__c, X2FA_Security_Questions_Answer__c FROM User WHERE id = :testPartnerUser.Id];
			System.assertEquals(SECURITY_QUESTION, updatedUser.X2FA_Security_Question__c, ASSERT_SECURITY_QUESTION_MSG);
			System.assertEquals(SECURITY_ANSWER, updatedUser.X2FA_Security_Questions_Answer__c, ASSERT_SECURITY_ANSWER_MSG);
		}
	}

	@isTest
	static void cleanSecurityQuesionForMFA(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){
			Boolean saved = MFA_LoginFlowController.saveQuestionAnswer(SECURITY_QUESTION, SECURITY_ANSWER);
			System.assert(saved, ASSERT_SAVE_MSG);
			User updatedUser = [Select Id, X2FA_Security_Question__c, X2FA_Security_Questions_Answer__c FROM User WHERE id = :testPartnerUser.Id];
			System.assertEquals(SECURITY_QUESTION, updatedUser.X2FA_Security_Question__c, ASSERT_SECURITY_QUESTION_MSG);
			System.assertEquals(SECURITY_ANSWER, updatedUser.X2FA_Security_Questions_Answer__c, ASSERT_SECURITY_ANSWER_MSG);

			Test.startTest();
				Boolean cleaned = MFA_LoginFlowController.cleanQuestionAnswerCurrentUser();
			Test.stopTest();

			updatedUser = [Select Id, X2FA_Security_Question__c, X2FA_Security_Questions_Answer__c FROM User WHERE id = :testPartnerUser.Id];
			System.assert(cleaned, 'Wrong return value');
			System.assert(String.isBlank(updatedUser.X2FA_Security_Question__c), ASSERT_SECURITY_QUESTION_MSG);
			System.assert(String.isBlank(updatedUser.X2FA_Security_Questions_Answer__c), ASSERT_SECURITY_ANSWER_MSG);

		}
	}

	@isTest
	static void checSecurityQuesionForMFA(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){
			Boolean saved = MFA_LoginFlowController.saveQuestionAnswer(SECURITY_QUESTION, SECURITY_ANSWER);
			System.assert(saved, ASSERT_SAVE_MSG);
			User updatedUser = [Select Id, X2FA_Security_Question__c, X2FA_Security_Questions_Answer__c FROM User WHERE id = :testPartnerUser.Id];
			System.assertEquals(SECURITY_QUESTION, MFA_LoginFlowController.securityQuestion, ASSERT_SECURITY_QUESTION_MSG);
			System.assertEquals(SECURITY_ANSWER, updatedUser.X2FA_Security_Questions_Answer__c, ASSERT_SECURITY_ANSWER_MSG);

			Test.startTest();
				Boolean correct;
				if(MFA_LoginFlowController.hasQuestionAndAnswer){
					correct = MFA_LoginFlowController.checkSecurityAnswerCurrentUser('Answer');
				}
			Test.stopTest();

			System.assert(correct, ASSERT_RETURN_MSG);
		}
	}

	@isTest
	static void addMFAPermission(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){

			Test.startTest();
				MFA_LoginFlowController.addMFAPermissionSet();
			Test.stopTest();

			List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :testPartnerUser.Id AND PermissionSet.Name = 'MFA' LIMIT 1]);
			System.assert(!psa.isEmpty(), ASSERT_PERMISSION_SET_MSG);
		}
	}

	@isTest
	static void removeMFAPermission(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){
			MFA_LoginFlowController.addMFAPermissionSet();

			Test.startTest();
				MFA_LoginFlowController.deleteMFAPermissionSet();
			Test.stopTest();

			List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :testPartnerUser.Id AND PermissionSet.Name = 'MFA' LIMIT 1]);
			System.assert(psa.isEmpty(), ASSERT_PERMISSION_SET_MSG);
		}
	}

	@isTest
	static void registerMFAMethod(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){
			Test.startTest();
			Map<String, Object> registerResult = new Map<String, Object>();
			if(!MFA_LoginFlowController.hasAuthConfigured){
				registerResult = MFA_LoginFlowController.initRegisterTotp();
			}
			Test.stopTest();

			System.assert(!registerResult.isEmpty(), ASSERT_REGISTER_MSG);
		}
	}

	@isTest
	static void verifyMFAMethod(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){

			Map<String, Object> response = new Map<String, Object> { 'registered' => false };
			response.putAll(Auth.SessionManagement.getQrCode());
			String secret = String.valueOf(response.get('secret'));
			insert new TwoFactorInfo(SharedKey = secret, Type = 'TOTP', UserId = testPartnerUser.Id);

			Test.startTest();
				String otp = '1111111';
				Map<String, Object> verification = MFA_LoginFlowController.verifyRegisterTotp(secret, otp);
			Test.stopTest();

			System.assert(!verification.isEmpty(), ASSERT_REGISTER_MSG);
		}
	}

	@isTest
	static void verifyMFAOTP(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){

			Test.startTest();
				String otp = '1111111';
				Boolean verification = MFA_LoginFlowController.verifyVerificationTotp(otp);
			Test.stopTest();

			System.assert(!verification, ASSERT_REGISTER_MSG);
		}
	}

	@isTest
	static void deregisterMFAOTP(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){

			Test.startTest();
				Boolean isDeregistered = MFA_LoginFlowController.deregisterVerificationTotp();
			Test.stopTest();

			System.assert(!isDeregistered, ASSERT_DEREGISTER_MSG);
		}
	}

	@isTest
	static void is2FaOptionalForUser_HasMFAPermissionSetAssignment(){
		// "Partner Community User" Profile needs to have the MFA Enabled custom permission assigned in configuration to fully test functionality
		Profile partnerProfile = new List<Profile>([SELECT Id FROM Profile WHERE UserLicense.MasterLabel = 'Partner Community' AND Name = 'Partner Community User' LIMIT 1]).get(0);
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		testPartnerUser.ProfileId = partnerProfile.Id;
		update testPartnerUser;

		Boolean hadMFAEnabled;
		System.runAs(testPartnerUser){
			hadMFAEnabled = MFA_LoginFlowController.hasMFAEnabled();
			MFA_LoginFlowController.addMFAPermissionSet();
		}
		
		Boolean is2FaOptional;
		System.runAs(testPartnerUser){
			Test.startTest();
			is2FaOptional = MFA_LoginFlowController.is2FaOptionalForUser();
			Test.stopTest();
		}
		if(!hadMFAEnabled){
			System.assertEquals(true, is2FaOptional);
		}
	}

	@isTest
	static void is2FaOptionalForUser_HasMFA_Enabled_NoPS(){
		// "ISS Portal (Portal)" Profile needs to have the MFA Enabled custom permission assigned in configuration to fully test functionality
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		Boolean hasMFAEnabled;
		System.runAs(testPartnerUser){
			hasMFAEnabled = MFA_LoginFlowController.hasMFAEnabled();
		}

		Boolean is2FaOptional;
		System.runAs(testPartnerUser){
			MFA_LoginFlowController.addMFAPermissionSet();
			Test.startTest();
			is2FaOptional = MFA_LoginFlowController.is2FaOptionalForUser();
			Test.stopTest();
		}

		if(hasMFAEnabled){
			System.assertEquals(false, is2FaOptional);
		}
	}

	@isTest
	static void is2FaOptionalForUser_NoPermission(){
		Profile partnerProfile = new List<Profile>([SELECT Id FROM Profile WHERE UserLicense.MasterLabel = 'Partner Community' AND Name = 'Partner Community User' LIMIT 1]).get(0);
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		testPartnerUser.ProfileId = partnerProfile.Id;
		update testPartnerUser;

		Boolean is2FaOptional;
		System.runAs(testPartnerUser){
			Test.startTest();
			is2FaOptional = MFA_LoginFlowController.is2FaOptionalForUser();
			Test.stopTest();
		}
		System.assertEquals(false, is2FaOptional);
	}

	@isTest
	static void getAuthenticatorLinks(){
		User testPartnerUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testPartnerUser){

			Test.startTest();
				List<MFA_LoginFlowController.AuthenticationApp> authLinks = MFA_LoginFlowController.getAuthenticatorLinks();
			Test.stopTest();

			System.assert(!authLinks.isEmpty(), ASSERT_LINK_MSG);
		}
	}

	@isTest
	static void checkGuestUser(){
		User testGuestUser = [SELECT Id FROM User WHERE FirstName = 'MFAGuestUser' LIMIT 1];
		System.runAs(testGuestUser){

			Test.startTest();
				MFA_LoginFlowController controller = new MFA_LoginFlowController();
				System.assert(!controller.isloggedUser, ASSERT_GUEST_MSG);
			Test.stopTest();
		}
	}

	@isTest
	static void getUserLanguage(){
		User testGuestUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testGuestUser){

			Test.startTest();
				String lang = MFA_LoginFlowController.activeLanguage;
			Test.stopTest();
			System.assertEquals('en_US',lang, ASSERT_LANGUAGE_MSG);
		}
	}

	@isTest
	static void getTranslationMetadata(){
		User testGuestUser = [SELECT Id FROM User WHERE FirstName = 'MFAPortalUser' LIMIT 1];
		System.runAs(testGuestUser){
			Map<String, String> translations = new Map<String, String>();
			Test.startTest();
				translations = MFA_LoginFlowController.getMetadataLabelsByLanguage('en_US');
			Test.stopTest();
			System.assert(!translations.isEmpty(), ASSERT_TRANSLATIONS_MSG);
		}
	}

}