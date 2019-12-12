/**
 * Created by ukaya01 on 02/07/2019.
 */

public with sharing class PortalLoginCtrl {

	public class LoginConfig{
		@AuraEnabled
		public Boolean isUsernamePasswordEnabled{get;set;}
		@AuraEnabled
		public Boolean isSelfRegistrationEnabled{get;set;}
		@AuraEnabled
		public String selfRegistrationUrl{get;set;}
		@AuraEnabled
		public String forgotPasswordUrl{get;set;}
		@AuraEnabled
		public String troubleShootingUrl{get;set;}
	}

	public class LoginResult{
		@AuraEnabled
		public boolean isSuccess{get;set;}
		@AuraEnabled
		public string errorMessage{get;set;}
		@AuraEnabled
		public string sessionUrl{get;set;}
		@AuraEnabled
		public boolean userIsFrozen{get;set;}
	}

	public static set<string> oldPortalRedirectSet {
		get{
			if(oldPortalRedirectSet==null){
				oldPortalRedirectSet = new set<string>{'ISS Portal DPC','ISS Portal DPC Admin','ISS Portal PwC2'};
			}
			return oldPortalRedirectSet;
		} set;
	}

	@AuraEnabled(cacheable=true)
	public static LoginConfig getInitialConfig(){
		LoginConfig config = new LoginConfig();
		Auth.AuthConfiguration authConfig = getAuthConfig();
		config.isUsernamePasswordEnabled = authConfig.getUsernamePasswordEnabled();
		config.isSelfRegistrationEnabled = authConfig.getSelfRegistrationEnabled();
		config.selfRegistrationUrl = authConfig.getSelfRegistrationUrl();
		config.forgotPasswordUrl = authConfig.getForgotPasswordUrl();
		config.troubleShootingUrl = Label.CSP_PortalPath + 'faq-article?language=en_US&q=troubleshooting';
		ISSP_CS__c cs = ISSP_CS__c.getInstance('TroubleShootingArticleId');
		if(cs != null){
			config.troubleShootingUrl = config.troubleShootingUrl + '&id1=' + cs.value__c;
		}
		return config;
	}

	@AuraEnabled
	public static LoginResult login(String username, String password, string landingPage, string relayState) {
		LoginResult result = new LoginResult();
		result.userIsFrozen = false;
		string startUrl = '';

		if(string.isNotBlank(landingPage)){
			landingPage = EncodingUtil.urlDecode(landingPage, 'UTF-8');
			if(landingPage.contains(Label.CSP_PortalPath) || string.isNotBlank(relayState)){
				startUrl = landingPage;
			}else{
				startUrl = Label.CSP_PortalPath + landingPage;
			}
		}else{
			startUrl = Label.CSP_PortalPath;
		}

		User oneUser;
		username = (null != username) ? username.trim() : username;

		try{

			list<User> userList = getUserListByNameOrEmail(username);

			//Errors validation
			if (username == '' || password == ''){
				result.isSuccess = false;
				result.errorMessage = Label.OneId_Password_ErrorBlank;
				return result;
			}

			if(ISSP_Utilities.isNotEmpty(userList)) {
				oneUser = userList[0];
				PermissionSetAssignment [] psa = [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =:oneUser.id AND PermissionSetId IN
				(SELECT Id FROM PermissionSet WHERE Name = 'Identity_Portal_User')];

				if(psa.size()==0){
					LightningRegistrationProcess.assignIdentityPermissionSet(oneUser.Id);
				}

				//Assign GDPR Permission set when user logs in. No matter the service
				LightningRegistrationProcess.assignGDPRPermissionSet(oneUser.Id);
			}
			//to developer Testing user frozen reactivate user reset password and send password email  - uncoment line below
			//oneUser.Portal_User_Frozen_Checkbox__c=true;

			if (oneUser.Portal_User_Frozen_Checkbox__c){
				result.isSuccess = false;
				result.userIsFrozen = true;
				reactivateUser(oneUser);
				return result;
			}

			//overrides to old portal
			if(oldPortalRedirectSet.contains(oneUser.profile.Name)){
				startUrl = OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_Homepage');
			}

			if(oneUser.CNS_Account_or_Agency__c){
				startUrl = OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_Homepage?communityName=CNS');
			}

			
			LightningRegistrationProcess.insertDeductionNoticeApp(string.valueOf(oneUser.Id));

			username=null != oneUser ? oneUser.Username : username;

			if(string.isNotBlank(relayState)){
				startUrl = OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, startUrl);
			}

			System.PageReference pageRef = Site.login(username, password, startUrl);

			result.isSuccess = true;
			result.sessionUrl = pageRef.getUrl();

			if(result.isSuccess == true){
				try{
					PortalFAQsSharingCtrl.validateUserFAQsPermissions(oneUser.Id);
				}catch(Exception e){
					return result;
				}
			}

			return result;
		}
		catch (Exception ex) {
			//return serror message string in case of any errors
			result.isSuccess = false;
			result.errorMessage = Label.OneId_LoginFail;
			result.sessionUrl = '';
			return result;
		}
	}

	public static list<User> getUserListByNameOrEmail(String nameOrEmail) {
		return
		[SELECT Id, Username, ContactId, Email, Portal_User_Frozen__c,
				IsActive, Portal_User_Frozen_Checkbox__c, Contact.Community__c,
				Profile.Name, CNS_Account_or_Agency__c,
				ANG_Sector__c, ANG_Category__c, Customer_Type__c, ANG_Is_Accredited_Agent__c,
				ANG_Customer_Country_ISO__c, Contact.User_Portal_Status__c
		FROM User
		WHERE (Username=: nameOrEmail
		OR email =: nameOrEmail)
		AND (IsActive = true OR Portal_User_Frozen_Checkbox__c = true)
		AND ContactId != ''
		limit 1];
	}

	@TestVisible
	public static Auth.AuthConfiguration getAuthConfig(){
		Id networkId = Network.getNetworkId();
		Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
		return authConfig;
	}

	public static void reactivateUser(User usr){
		PortalPasswordHandler.resultWrapper result = PortalPasswordHandler.handleResetPassword(usr.email);
		if(result.success == true){
			String link				  = PortalPasswordHandler.generateUrl(result.user, result.password, 'resetPassword');
			Map<String, String> emailMap = PortalPasswordHandler.forgotPasswordEmailMap(result.user, link);
			result.success			   = PortalPasswordHandler.sendEmail(result.user.id, 'CSP_Forgot_Password_Email_VF', emailMap);
		}
	}

}