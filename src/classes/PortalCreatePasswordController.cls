public without sharing class PortalCreatePasswordController {

	public class returnWrapper{
		@AuraEnabled
		public String registrationParameters {get;set;}
		@AuraEnabled
		public boolean isUserExist {get;set;}
		@AuraEnabled
		public boolean isExpired {get;set;}

	}

	@AuraEnabled
	public static returnWrapper getParameters(String encoded){
		returnWrapper result  = new returnWrapper();
		result.isExpired = false;

		encoded = PortalPasswordHandler.DecryptString(Encodingutil.urlDecode(encoded, 'UTF-8')).replace(PortalPasswordHandler.plusReplacer,'+');

		//get registration information
		PortalRegistrationFirstLevelCtrl.RegistrationParameters params = (PortalRegistrationFirstLevelCtrl.RegistrationParameters) JSON.deserialize(encoded, PortalRegistrationFirstLevelCtrl.RegistrationParameters.class);

		result.isUserExist = isUserExist(params.email, params.contactId);
		result.registrationParameters = JSON.serialize(params);

		result.isExpired = system.now() > datetime.valueOf(params.registrationTime).addHours(8);

		return result;
	}

	@AuraEnabled
	public static boolean isUserExist(String email, String contactId) {
		boolean isExist = false;
		if(contactId == null || contactId == ''){
			List<Contact> contactList = [Select id from contact where email =: email];
			if(!contactList.isEmpty()) isExist = true;
		}

		List<User> userList = [Select id from user where email =: email];
		if(!userList.isEmpty()) isExist = true;
		return isExist;
	}

	@AuraEnabled
	public static PortalRegistrationFirstLevelCtrl.RegistrationResult createUserAndSetPassword(String paramStr, String password, String landingPage, Map<String,String> urlParams){
		PortalRegistrationFirstLevelCtrl.RegistrationParameters params = (PortalRegistrationFirstLevelCtrl.RegistrationParameters) JSON.deserialize(paramStr, PortalRegistrationFirstLevelCtrl.RegistrationParameters.class);
		PortalRegistrationFirstLevelCtrl.RegistrationResult result = PortalRegistrationFirstLevelCtrl.register(params, password);

		if(result.isSuccess == true){
			if(urlParams == null) urlParams = new Map<String,String>();
			urlParams.put('firstLogin', ''+result.isGeneralPublicAccount);

			String startUrl = Label.CSP_PortalPath;
			if(String.isNotBlank(landingPage)){
				startUrl = EncodingUtil.urlDecode(landingPage, 'UTF-8');
			}

			//YAS Reg -
			String lmsParam = params.lms.toLowerCase();
			if(lmsParam.indexOf('yas') != -1){
				urlParams.put('lms', 'yas');
				urlParams.put('lmsCourse', params.lmsCourse);
			}

			//check if the start URL already has parameters
			String s = startUrl.contains('?') ? '&' : '?';
			startUrl += s + CSP_Utils.assembleParams(urlParams);

			try{
				System.PageReference pageRef = Site.login(result.username, password, startUrl);
				result.message = pageRef.getUrl();
			}
			catch(Exception ex){
				result.isSuccess = false;
			}
		}
		return result;
	}

	@AuraEnabled
	public static boolean resendEmail(String paramStr, Map<String, String> urlParams) {
		PortalRegistrationFirstLevelCtrl.RegistrationParameters params = (PortalRegistrationFirstLevelCtrl.RegistrationParameters) JSON.deserialize(paramStr, PortalRegistrationFirstLevelCtrl.RegistrationParameters.class);
		params.registrationTime = string.valueOf(system.now());
		boolean success = PortalRegistrationFirstLevelCtrl.sendConfirmationEmailVF(params, params.language,urlParams);
		return success;
	}

}
