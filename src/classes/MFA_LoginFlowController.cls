/*************************************************************************************************************
 * @name			MFA_LoginFlowController
 * @author			Beatriz <beatriz.menendez@next-link.ch>
 * @created			19 / 05 / 2021
 * @description		Controller of the 2FA login process, manages the functionallity for the
 * 					MFA_LoginFlowPage and the 2FA related functionality in the CS Portal Settings page.
**************************************************************************************************************/
public without sharing class MFA_LoginFlowController{
	private static String loginURL = getRetURL();
	public static String retURL = Label.CSP_PortalPath;

	//Checks the user that access the page.
	public Boolean isloggedUser{get{
									return UserInfo.getUserType() != 'Guest';
								}set;}

	public static User currentUser;

	public static User currentUserInfo{get{
											return getCurrentUser();
										}set;}

	public static Boolean hasMFAEnabled{get{
											if(hasMFAEnabled == null){
												hasMFAEnabled = hasMFAEnabled();
											}
											return hasMFAEnabled;
										}set;}

	public static Boolean hasQuestionAndAnswer{get{
												if(hasQuestionAndAnswer == null){
													hasQuestionAndAnswer = hasSecurityQuestionAndAnswer();
												}
												return hasQuestionAndAnswer;
												}set;}

	public static Boolean hasAuthConfigured{get{
												if(hasAuthConfigured == null){
													hasAuthConfigured = hasCurrentUserMFAMethod();
												}
												return hasAuthConfigured;
											}set;}

	public static String securityQuestion{get{
												return getCurrentUser().X2FA_Security_Question__c;
											}set;}

	public static String activeLanguage{get{
												return activeLanguage();
											}set;}

	public MFA_LoginFlowController(){
		if(!hasMFAEnabled){
			finishLoginFlowHome();
		}
	}

   //-------------------------------VISUALFORCE METHODS START-----------------------------------------------------------
	/*********************************************************************************************************
	 * @name			redirectGuestToLoginPage
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			24 / 05 / 2021
	 * @description		Redirects to the current site logging page
	 * @param			-
	 * @return			Pagereference: current site login page or stay in the current page in case the user is
	 * 					a logged one.
	**********************************************************************************************************/
	public Pagereference redirectGuestToLoginPage(){
		PageReference pr = new PageReference(Network.getLoginUrl(Network.getNetworkId()));
		pr.setRedirect(true);
		return !isloggedUser ? pr : null;
	}

	/*********************************************************************************************************
	 * @name			redirectToLoginPage
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			24 / 05 / 2021
	 * @description		Logs the user out and redirects to the current site logging page
	 * @param			-
	 * @return			Pagereference: current site login page
	**********************************************************************************************************/
	public Pagereference redirectToLoginPage(){
		delete [Select Id from AuthSession WHERE UsersId =: UserInfo.getUserId() AND SessionType = 'ChatterNetworks'];
		PageReference pr = new PageReference(Network.getLoginUrl(Network.getNetworkId()));
		pr.setRedirect(true);
		return pr;
	}

	/*********************************************************************************************************
	 * @name			setFirstSetupParameter
	 * @author			Jorge <jorge.corral@next-link.ch>
	 * @created			24 / 06 / 2021
	 * @description		Add the first2FAActivated parameter to current url.
	 * @param			-
	 * @return			Pagereference: current site home page.
	**********************************************************************************************************/
	public static Pagereference setFirstSetupParameter(){
		String portalHomePage = loginURL + '&first2FAActivated=\'true\'';
		PageReference pr = Test.isRunningTest() ? apexpages.currentpage() : Auth.SessionManagement.finishLoginFlow(portalHomePage);
		return pr;
	}

	/*********************************************************************************************************
	 * @name			finishLoginFlowHome
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			20 / 05 / 2021
	 * @description		Finishes the login flow and sends you to the default homepage.
	 * @param			-
	 * @return			Pagereference: current site home page (finish login flow)
	**********************************************************************************************************/
	public static PageReference finishLoginFlowHome(){
		String portalHomePage = loginURL;
		PageReference pr = Test.isRunningTest() ? apexpages.currentpage() : Auth.SessionManagement.finishLoginFlow(portalHomePage);
		return pr;
	}

	public static String activeLanguage(){
		String language =  apexpages.currentpage().getparameters().get('language') != null ? apexpages.currentpage().getparameters().get('language') : UserInfo.getLanguage();
		return language;
	}

   //-------------------------------REGISTER/VALIDATE METHODS START-------------------------------------------------------
	/*********************************************************************************************************
	 * @name			initRegisterTotp
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			07 / 06 / 2021
	 * @description		First method to start registering a TOTP method to the user. Creates the secret and the QR code
	 * 					to scan by the third party app.
	 * @param			-
	 * @return			Map<String, Object> : registered -> correctly registrered
	 * 										  qrCodeUrl  -> Current user QR Code generated
	 * 										  secret	 -> Current user secret related to the QR / alternative key
	**********************************************************************************************************/
	@RemoteAction
	@AuraEnabled
	public static Map<String, Object> initRegisterTotp() {
		TwoFactorMethodsInfo info = new Repository().getTwoFactorInfo(UserInfo.getUserId());
		Map<String, Object> response = new Map<String, Object> { 'registered' => false };

		if (info != null && info.HasTotp) {
			response.put('registered', true);
		}else{
			response.putAll(Auth.SessionManagement.getQrCode());
		}

		return response;
	}

	/*********************************************************************************************************
	 * @name			verifyRegisterTotp
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			07 / 06 / 2021
	 * @description		Verifies the first time the TOTP app has scanned the QR, that the created code by the
	 * 					TOTP app is valid, finally links the TOTP app to the current user.
	 * 					(App Registration: One-Time Password Authenticator user field).
	 * @param			String secret : Secret generated on the initRegisterTotp method (Related to the user's QR Code)
	 * 					String otp : Code generated by the TOTP app
	 * @return			Map<String, Object> : isValid -> Correct code and secret inserted
	**********************************************************************************************************/
	@RemoteAction
	@AuraEnabled
	public static Map<String, Object> verifyRegisterTotp(String secret, String otp){
		try{
			TwoFactorMethodsInfo info = new Repository().getTwoFactorInfo(UserInfo.getUserId());
			Boolean isFirstLogin = false;

			if(info != null && info.HasTotp){
				throw new AuraHandledException('Invalid 2FA registration, user already has a TOTP auth app.');
			}
			
			Boolean is_valid;
			try {
				is_valid= Auth.SessionManagement.validateTotpTokenForKey(secret, otp, 'Register a new TOTP');	
			} catch (SecurityException exc) {
				return new Map<String, Object> {'error' => exc.getMessage()};
			}
			
			if(is_valid){
				isFirstLogin = true;
				//sets the hasTOTP field automatically to true in the TwoFactorMethod Object for the current user
				insert new TwoFactorInfo(SharedKey = secret, Type = 'TOTP', UserId = UserInfo.getUserId());
			}

			return new Map<String, Object> {'isValid' => is_valid, 'firstLogin' => isFirstLogin};

		}catch(Exception e){
			return new Map<String, Object> {'error' => e.getMessage()};
		}
	}

	/*********************************************************************************************************
	 * @name			verifyVerificationTotp
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			07 / 06 / 2021
	 * @description		Once the user has an otp app linked, this method validates the code generated by the app
	 * @param			String otp : Code generated by the linked TOTP app
	 * @return			Map<String, Object> : result -> Boolean that verifies that the inserted code is valid
	**********************************************************************************************************/
	@RemoteAction
	public static Boolean verifyVerificationTotp(String otp){
		TwoFactorMethodsInfo info = new Repository().getTwoFactorInfo(currentUserInfo.Id);
		Auth.VerificationMethod method = Auth.VerificationMethod.TOTP;

		Boolean result = false;
		if(info!= null && info.HasTotp){
			result = System.UserManagement.verifyVerificationMethod(null, otp, method).success;
		}

		return result;
	}

	/*********************************************************************************************************
	 * @name			deregisterVerificationTotp
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			07 / 06 / 2021
	 * @description		Deregisters the user's totp app if any
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@RemoteAction
	@AuraEnabled
	public static Boolean deregisterVerificationTotp(){
		Boolean isDeregistered = false;
		TwoFactorMethodsInfo info = new Repository().getTwoFactorInfo(UserInfo.getUserId());

		if(info != null && info.HasTotp){
			System.UserManagement.deregisterVerificationMethod(UserInfo.getUserId(), Auth.VerificationMethod.TOTP);
			isDeregistered = true;
		}

		return isDeregistered;
	}

   //-------------------------------PROCESS LOGIC METHODS START----------------------------------------------------------
	/*********************************************************************************************************
	 * @name			saveQuestionAnswer
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			24 / 05 / 2021
	 * @description		Saves the security question and answer set on the login flow or the settings.
	 * @param			String question: New question to be saved
	 * 					String answer: New answer to be saved
	 * @return			Boolean: true if user question or anwer are successfully updated
	**********************************************************************************************************/
	@RemoteAction
	@AuraEnabled
	public static Boolean saveQuestionAnswer(String question, String answer){
		Boolean isSaved = false;
		User currentLoggedUser = getCurrentUser();

		if(currentLoggedUser?.X2FA_Security_Question__c != question || currentLoggedUser?.X2FA_Security_Questions_Answer__c != answer){
			currentLoggedUser.X2FA_Security_Question__c = question;
			currentLoggedUser.X2FA_Security_Questions_Answer__c = answer;
			if(Schema.sObjectType.User.isUpdateable()){
				try{
					Database.SaveResult updatedUserSR = Database.update(currentLoggedUser, true);
					isSaved = updatedUserSR.isSuccess();
					//Force current user to query values again if they have changed
					if(isSaved){
						currentUser = null;
						hasQuestionAndAnswer = true;
					}
				}catch(DmlException ex){
					isSaved = false;
					System.debug('____ [MFA_LoginFlowController - saveQuestionAnswer] Error on saving data for User - ' + currentLoggedUSer + '  error: ' + ex.getMessage());
				}
			}
		}

		return isSaved;
	}

	/*********************************************************************************************************
	 * @name			cleanQuestionAnswerCurrentUser
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 05 / 2021
	 * @description		Cleans the security question and answer for the current user
	 * @param			-
	 * @return			Boolean: true if user question and anwer are successfully deleted
	**********************************************************************************************************/
	@RemoteAction
	@AuraEnabled
	public static Boolean cleanQuestionAnswerCurrentUser(){
		Boolean isDeleted = false;
		User currentLoggedUser = getCurrentUser();

		if(String.isNotBlank(currentLoggedUser?.X2FA_Security_Question__c) || String.isNotBlank(currentLoggedUser?.X2FA_Security_Questions_Answer__c)){
			currentLoggedUser.X2FA_Security_Question__c = '';
			currentLoggedUser.X2FA_Security_Questions_Answer__c = '';
			if(Schema.sObjectType.User.isUpdateable()){
				try{
					Database.SaveResult updatedUserSR = Database.update(currentLoggedUser, true);
					isDeleted = updatedUserSR.isSuccess();
					//Force current user to query values again if they have changed
					if(isDeleted){
						currentUser = null;
						hasQuestionAndAnswer = true;
					}
				}catch(DmlException ex){
					isDeleted = false;
					System.debug('____ [MFA_LoginFlowController - cleanQuestionAnswerCurrentUser] Error on cleaning data for User - ' + currentLoggedUSer + '  error: ' + ex.getMessage());
				}
			}
		}

		return isDeleted;
	}

	/*********************************************************************************************************
	 * @name			checkSecurityAnswerCurrentUser
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 05 / 2021
	 * @description		Checks that the received question is the same saved in the system for the current user
	 * @param			-
	 * @return			Boolean: true if user answer is correct
	**********************************************************************************************************/
	@RemoteAction
	@AuraEnabled
	public static Boolean checkSecurityAnswerCurrentUser(String answer){
		User currentLoggedUser = getCurrentUser();
		String systemAnswer = currentLoggedUser?.X2FA_Security_Questions_Answer__c;

		return (String.isNotBlank(systemAnswer) && String.isNotBlank(answer) && systemAnswer == answer);
	}

	/*********************************************************************************************************
	 * @name			addMFAPermissionSet
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 06 / 2021
	 * @description		Assign the MFA permission set to the user (from settings page)
	**********************************************************************************************************/
	@AuraEnabled
	public static void addMFAPermissionSet(){
		Id userId = getCurrentUser().Id;
		PermissionSet mfaPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'MFA' LIMIT 1];
		List<PermissionSetAssignment> mfaPermissionSetAsignments = new List<PermissionSetAssignment>([SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId = :mfaPermissionSet.Id AND AssigneeId = :userId LIMIT 1]);

		if(mfaPermissionSetAsignments.isEmpty() && !hasMFAEnabled()){
			PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = mfaPermissionSet.Id, AssigneeId = userId);
			insert psa;
		}
	}

	/*********************************************************************************************************
	 * @name			deleteMFAPermissionSet
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			10 / 06 / 2021
	 * @description		Deletes the MFA permission set if assined to the user
	 * @param			String param : Explanation
	 * @return			Explanation of the return value
	**********************************************************************************************************/
	@AuraEnabled
	public static void deleteMFAPermissionSet(){
		List<PermissionSetAssignment> mfaPermissionSetAssignment = new List<PermissionSetAssignment>([SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :getCurrentUser().Id AND PermissionSet.Name = 'MFA' LIMIT 1]);

		if(!mfaPermissionSetAssignment.isEmpty()){
			delete mfaPermissionSetAssignment;
		}
	}

	/*********************************************************************************************************
	 * @name			hasSecurityQuestionAndAnswer
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			26 / 05 / 2021
	 * @description		Checks if current user has question and answer set
	 * @param			-
	 * @return			Boolean: True if the user has the question AND the answer already set.
	**********************************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static Boolean hasSecurityQuestionAndAnswer(){
		User currentLoggedUser = getCurrentUser();
		return String.isNotBlank(currentLoggedUser?.X2FA_Security_Question__c) && String.isNotBlank(currentLoggedUser?.X2FA_Security_Questions_Answer__c);
	}

	/*********************************************************************************************************
	 * @name			hasMFAEnabled
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			26 / 05 / 2021
	 * @description		Checks if the user is forced to use MFA (by the related service or voluntary)
	 * 					User is forced to use MFA with the custom permission MFA_Enabled
	 * @param			-
	 * @return			Boolean: True if the user has enabled the MFA
	**********************************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static Boolean hasMFAEnabled(){
		return FeatureManagement.checkPermission('MFA_Enabled');
	}

	/*********************************************************************************************************
	 * @name			hasCurrentUserMFAMethod
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			31 / 05 / 2021
	 * @description		Checks if the current user has any MFA Method related
	 * @param			-
	 * @return			Boolean hasMFAMethodRegistered : True if hasTotp, HasU2F, or HasSalesforceAuthenticator
	 * 													 are true
	**********************************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static Boolean hasCurrentUserMFAMethod(){
		List<TwoFactorMethodsInfo> methods = new List<TwoFactorMethodsInfo>([SELECT Id, userid, HasU2F, HasSalesforceAuthenticator, HasTotp
											  FROM TwoFactorMethodsInfo WHERE userid=:UserInfo.getUserId()]);

		TwoFactorMethodsInfo currentMethod = !methods.isEmpty() ? methods.get(0): null;
		Boolean hasMFAMethodRegistered = false;
		if(currentMethod != null){
			hasMFAMethodRegistered = (currentMethod.HasTotp || currentMethod.HasU2F || currentMethod.HasSalesforceAuthenticator);
		}
		return hasMFAMethodRegistered;
	}

	/*********************************************************************************************************
	 * @name			is2FaOptionalForUser
	 * @author			Jorge <jorge.corral@next-link.ch>
	 * @created			29 / 07 / 2021
	 * @description		Checks if the user has the 2FA setup optionally or not.
	 * @param			-
	 * @return			Boolean is2FaOptionalForUser : False if user has the MFA Enabled custom permission but
	 * 												  they do not have the MFA permission set assigned.
	**********************************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static Boolean is2FaOptionalForUser(){
		Boolean hasMFAEnabled = hasMFAEnabled();
		List<PermissionSetAssignment> mfaPermissionSetAssignment = new List<PermissionSetAssignment>([SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :getCurrentUser().Id AND PermissionSet.Name = 'MFA' LIMIT 1]);
		if(hasMFAEnabled && !mfaPermissionSetAssignment.isEmpty()){
			return true;
		}else{
			return false;
		}
	}

	/*********************************************************************************************************
	 * @name			getAuthenticatorLinks
	 * @author			Jorge <jorge.corral@next-link.ch>
	 * @created			2 / 06 / 2021
	 * @description		List the available authentication apps that are in the system
	 * @param			-
	 * @return			List<AuthenticationApp>: List all the available apps that are eligible for 2FA
	**********************************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static List<AuthenticationApp> getAuthenticatorLinks(){
		List<AuthenticationApp> authenticatorApps = new List<AuthenticationApp>();
		for(Portal_MFA_Setting__mdt metadataRecord: [SELECT Label, Value__c FROM Portal_MFA_Setting__mdt WHERE DeveloperName LIKE '%Authenticator%' ORDER BY Label]){
			authenticatorApps.add(new AuthenticationApp(metadataRecord));
		}
		return authenticatorApps;
	}

	//-------------------------------UTIL METHODS START------------------------------------------------------------------
	/*********************************************************************************************************
	 * @name			getCurrentUser
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			24 / 05 / 2021
	 * @description		Returns current user (UserInfo) required data
	 * @param			-
	 * @return			Logged User: Id, X2FA_Security_Question__c, X2FA_Security_Questions_Answer__c
	**********************************************************************************************************/
	public static User getCurrentUser(){
		if(currentUser == null){
			currentUser = [SELECT Id, X2FA_Security_Question__c, X2FA_Security_Questions_Answer__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		}
		return currentUser;
	}

	/*********************************************************************************************************
	 * @name			getStartURL
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			24 / 05 / 2021
	 * @description		Gets the retURL of the MFA LoginFlow VF Page
	 * @param			-
	 * @return			Current page RetURL
	**********************************************************************************************************/
	public static String getRetURL(){
		if(Apexpages.currentPage()?.getParameters()?.get('retURL') != null){
			retURL = Apexpages.currentPage().getParameters().get('retURL');
		}
		return retURL;
	}

	/*********************************************************************************************************
	 * @name			getMetadataLabelsByLanguage
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			25 / 06 / 2021
	 * @description		Gets all the requested custom metadata label translations from metadata by language.
	 * 					Simulates label translation used to avoid lightining out preventing custom labels to be translated.
	 * 					If language is empty, get the User's language from Sf. If language not available en_US returned.
	 * @param			String lan : Selected language to obtain all the available labels (Locale format, ex en_US)
	 * @return			Map containing all the available labels and the translation in the selected language
	 * 					Map<LabelAPIName, TranslatedValue>
	**********************************************************************************************************/
	@AuraEnabled(cacheable=true)
	public static Map<String, String> getMetadataLabelsByLanguage(String lang){
		Map<String, String> valuesByLabel = new Map<String, String>();
		Map<String, String> labelsByLan = new Map<String, String>();
		Set<String> languages = new Set<String>{'en_US'};
		languages.add(lang != null ? lang : UserInfo.getLanguage());

		List<Custom_metadata_label_translation__mdt> metadataLst = new List<Custom_metadata_label_translation__mdt>([SELECT Custom_metadata_label__r.DeveloperName, Language__c, Value__c FROM Custom_metadata_label_translation__mdt WHERE Language__c IN :languages]);

		for(Custom_metadata_label_translation__mdt mtdTranslation : metadataLst){
			labelsByLan.put(mtdTranslation.Custom_metadata_label__r.DeveloperName + mtdTranslation.Language__c, mtdTranslation.Value__c);
		}

		for(Custom_metadata_label_translation__mdt mtdTranslation : metadataLst){
			String lanKey = mtdTranslation.Custom_metadata_label__r.DeveloperName + lang;
			String enKey = mtdTranslation.Custom_metadata_label__r.DeveloperName + 'en_US';

			if(labelsByLan.containsKey(lanKey)){
				valuesByLabel.put(mtdTranslation.Custom_metadata_label__r.DeveloperName, labelsByLan.get(lanKey));
			}else{//if not available in the requested language return value in english
				valuesByLabel.put(mtdTranslation.Custom_metadata_label__r.DeveloperName, labelsByLan.get(enKey));
			}
		}

		return valuesByLabel;
	}

	/*************************************************************************************************************
	 * @name			Repository
	 * @author			Beatriz <beatriz.menendez@next-link.ch>
	 * @created			24 / 05 / 2021
	 * @description		Inner class to save the users MFA related data, two factor info and current user
	**************************************************************************************************************/
	public without sharing class Repository {

		public TwoFactorMethodsInfo getTwoFactorInfo(Id user_id) {
			TwoFactorMethodsInfo[] verified_info = [SELECT HasUserVerifiedEmailAddress, HasUserVerifiedMobileNumber,
														HasVerifiedMobileNumber, HasSalesforceAuthenticator, HasTotp, HasU2F
												  FROM TwoFactorMethodsInfo WHERE UserId = :user_id LIMIT 1 ];
			return (verified_info != null && verified_info.size() == 1) ? verified_info[0] : null;
		}
	}

	//-------------------------------APEX CLASSES START------------------------------------------------------------------

	/*********************************************************************************************************
	 * @description		Apex class representing each of the authentication apps that can exist in
	 * 					the 2FA process.
	**********************************************************************************************************/

	public class AuthenticationApp {
		@AuraEnabled public Id id {get;set;}
		@AuraEnabled public String label {get;set;}
		@AuraEnabled public String androidLink {get;set;}
		@AuraEnabled public String appleLink {get;set;}
		@AuraEnabled public String explorerLink {get;set;}

		AuthenticationApp(Portal_MFA_Setting__mdt portalConfigMetadata){
			this.label = portalConfigMetadata.Label;
			List<String> links = portalConfigMetadata.Value__c.split(';');
			if(!links.isEmpty()){
				if(links.size() > 1){
					this.appleLink = links.get(1);
				}
				if(links.size() > 2){
					this.explorerLink = links.get(2);
				}
				this.androidLink = links.get(0);
			}
		}
	}
	//-------------------------------APEX CLASSES END------------------------------------------------------------------
}