public with sharing class PortalLoginCtrl {

	public class LoginConfig{
		@AuraEnabled public Boolean isUsernamePasswordEnabled{get;set;}
		@AuraEnabled public Boolean isSelfRegistrationEnabled{get;set;}
		@AuraEnabled public String selfRegistrationUrl{get;set;}
		@AuraEnabled public String forgotPasswordUrl{get;set;}
		@AuraEnabled public String troubleShootingUrl{get;set;}
	}

	public class LoginResult{
		@AuraEnabled public Boolean isSuccess{get;set;}
		@AuraEnabled public String errorMessage{get;set;}
		@AuraEnabled public String sessionUrl{get;set;}
		@AuraEnabled public Boolean userIsFrozen{get;set;}
	}

	public static Set<String> oldPortalRedirectSet {
		get{
			if(oldPortalRedirectSet==null){
				oldPortalRedirectSet = new Set<String>{'ISS Portal DPC','ISS Portal DPC Admin','ISS Portal PwC2'};
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

	private class LoginException extends Exception {}

	@AuraEnabled
	public static LoginResult login(String username, String password, String landingPage, Map<String,String> params) {

		LoginResult result = new LoginResult();
		result.isSuccess = false;
		result.userIsFrozen = false;

		//Errors validation
		if (String.isBlank(username) || String.isBlank(password)){
			result.errorMessage = Label.OneId_Password_ErrorBlank;
			return result;
		}

		username = username.trim();

		try{

			List<User> userList = getUserListByNameOrEmail(username);

			// If no user is found return generic message
			if(userList.isEmpty()) throw new LoginException('User not found');

			User oneUser = userList[0];
			PermissionSetAssignment [] psa = [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =:oneUser.id AND PermissionSetId IN
			(SELECT Id FROM PermissionSet WHERE Name = 'Identity_Portal_User')];

			if(psa.size()==0){
				LightningRegistrationProcess.assignIdentityPermissionSet(oneUser.Id);
			}

			if (oneUser.Portal_User_Frozen_Checkbox__c){
				result.userIsFrozen = true;
				reactivateUser(oneUser, params);
				return result;
			}

			String startUrl = Label.CSP_PortalPath;

			//overrides to old portal
			if(oneUser.CNS_Account_or_Agency__c){
				startUrl = OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_Homepage?communityName=CNS');
			}else if(oldPortalRedirectSet.contains(oneUser.profile.Name)){
				startUrl = OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_Homepage');
			}else if(String.isNotBlank(landingPage)){
				startUrl = EncodingUtil.urlDecode(landingPage, 'UTF-8');
			}

			System.debug(loggingLevel.FINE, '____ [cls PortalLoginCtrl - login] params - ' + params);
			if(params != null & !params.isEmpty()){

				//check if the start URL already has parameters
				String s = startUrl.contains('?') ? '&' : '?';
				startUrl += s + CSP_Utils.assembleParams(params);
			}

			System.debug(loggingLevel.FINE, '____ [cls PortalLoginCtrl - login] startUrl - ' + startUrl);
			if(oneUser.ANG_Sector__c == 'Travel Agent'
			&& oneUser.ANG_Category__c == 'IATA Passenger Sales Agent'
			&& oneUser.Customer_type__c == 'Agency'
			&& oneUser.ANG_Is_Accredited_Agent__c == true
			&& oneUser.ANG_Customer_Country_ISO__c == 'IL'
			&& (oneUser.Contact.User_Portal_Status__c == 'Approved User' || oneUser.Contact.User_Portal_Status__c == 'Approved Admin'))	{
				

				LightningRegistrationProcess.insertDeductionNoticeApp(String.valueOf(oneUser.Id));
			}			

			System.PageReference pageRef = Site.login(oneUser.Username, password, startUrl);

			result.isSuccess = true;
			result.sessionUrl = pageRef.getUrl();

			System.debug(loggingLevel.FINE, '____ [cls PortalLoginCtrl - login] result.sessionUrl - ' + result.sessionUrl);

			try{
				PortalFAQsSharingCtrl.validateUserFAQsPermissions(oneUser.Id);
			}catch(Exception e){
				// If it fails user is still allowed to log in, error is reported silently
				System.debug(loggingLevel.ERROR, '____ [cls PortalLoginCtrl - login] FAQ Permissions Failed - ' + e.getMessage());
			}

		}
		catch (Exception ex) {
			//return serror message String in case of any errors
			System.debug(loggingLevel.ERROR, '____ [cls PortalLoginCtrl - login] Login failed - ' + ex.getMessage() + '\n' + ex.getStackTraceString());
			result.errorMessage = Label.OneId_LoginFail;
		}

		return result;
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

	public static void reactivateUser(User usr, Map<String,String> params){
		PortalPasswordHandler.resultWrapper result = PortalPasswordHandler.handleResetPassword(usr.email);
		if(result.success == true){
			String link				  = PortalPasswordHandler.generateUrl(result.user, result.password, 'resetPassword', params);
			Map<String, String> emailMap = PortalPasswordHandler.forgotPasswordEmailMap(result.user, link);
			result.success			   = PortalPasswordHandler.sendEmail(result.user.id, 'CSP_Forgot_Password_Email_VF', emailMap);
		}
	}

}
