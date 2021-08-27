public class UserProvisioningUtils {
	public static final String TESTING_NAMED_CREDENTIAL = 'Apex Unit Test Named Credential';
	public static final String PARAM_UPR_ID = 'userProvisioningRequestId';
	public static final String PARAM_STATUS = 'Status';
	public static final String PARAM_DETAILS = 'Details';
	public static final String PARAM_EXTERNAL_USERID = 'ExternalUserId';
	public static final String PARAM_EXTERNAL_USERNAME = 'ExternalUserName';
	public static final String PARAM_EXTERNAL_EMAIL = 'ExternalEmail';
	public static final String PARAM_EXTERNAL_FIRSTNAME = 'ExternalFirstName';
	public static final String PARAM_EXTERNAL_LASTNAME = 'ExternalLastName';
	public static final String PARAM_RECON_OFFSET = 'reconOffset';
	public static final String PARAM_NEXT_RECON_OFFSET = 'nextReconOffset';
	public static final String PARAM_USERPAYLOAD = 'userPayload';
	public static final String PARAM_UPASTATUS = 'UPAStatus';
	public static final String PARAM_CALLPARAMS = 'CallParams';

	public static final String PARAM_ISACTIVE = 'IsActive';

	private static final Integer MAX_LOG_LEN = 1300;

	public static final String PARAM_EXTERNAL_SYSTEM = 'ExternalSystem';

	public static final set<string> AllowedExternalSystems = new set<string>{'IEP', 'GDI', 'PASS', 'FRED+', 'EFAPPS'};

	private UserProvisioningRequest upr;
	private NamedCredential namedCredential;
	private UserProvisioningConfig upc;
	private String uprId;
	private Boolean isDebug;
	private List<String> pendingLogs = new List<String>();

	public UserProvisioningUtils(Boolean isDebug) {
		this.isDebug = isDebug == null ? false : isDebug;
	}

	public void init(String uprId) {
		this.uprId = uprId;
		this.upr = [SELECT connectedAppId, UserProvConfigId, salesforceUserId, UserProvAccountId, Operation, isactive__c FROM UserProvisioningRequest WHERE id = :uprId LIMIT 1];
		if(!Test.isRunningTest()){
			this.upc = [SELECT namedCredentialId, reconFilter FROM UserProvisioningConfig where id = :upr.UserProvConfigId LIMIT 1];
			this.namedCredential = [SELECT developerName FROM NamedCredential where id = :upc.namedCredentialId LIMIT 1];
		}
	}

	public String getNamedCredential() {
		if (Test.isRunningTest())
		{
			// Return a static, known value when the code is under test so that
			// unit tests can mock HTTP calls for plugins where multiple HTTP
			// calls are made during a single invoke(). It is not currently
			// possible to insert a Named Credential during testing (or
			// otherwise).
			return 'callout:' + TESTING_NAMED_CREDENTIAL;
		}
		else
		{
			return 'callout:' + namedCredential.developerName;
		}
	}

	public String getNamedCredential(string ExternalSystem, string DevName) {
		if (Test.isRunningTest()){
			return 'callout:' + TESTING_NAMED_CREDENTIAL;
		}
		else{
			if(AllowedExternalSystems.contains(ExternalSystem)){
				CalloutHelper cHelp = new CalloutHelper();
				return 'callout:' + namedCredential.developerName + cHelp.getResourceFromConfig(DevName);
			}else{
				return 'callout:' + namedCredential.developerName;
			}
		}
	}

	public String getConnectedAppId() {
		return upr.connectedAppId;
	}

	public String getSalesforceUserId() {
		return upr.salesforceUserId;
	}

	public String getReconFilter() {
		if(Test.isRunningTest()){
			return '';
		}else {
			return upc.reconFilter;
		}
	}

	public UserProvAccount getLinkedUserProvAccount() {
		UserProvAccount upa;
		UserProvAccount[] upaList;

		if (upr.UserProvAccountId != null) {
			// forward / future compatibility
			upaList = [
				SELECT name, externalUserId, externalUsername, externalEmail, externalFirstname, externalLastname, linkState, status
				FROM UserProvAccount
				WHERE id = :upr.UserProvAccountId
			];
		} else {
			// implementation as of 1/29/2016
			upaList = [
				SELECT name, externalUserId, externalUsername, externalEmail, externalFirstname, externalLastname, linkState, status
				FROM UserProvAccount
				WHERE salesforceUserId = :upr.salesforceUserId
				AND connectedAppId = :getConnectedAppId()
				AND linkState = 'Linked'
				AND status != 'Deleted'
			];
		}

		if (upaList.size() > 0)
			upa = upaList[0];

		return upa;
	}

	public Boolean areParamsBlank(Map<String, String> paramsMap, Map<String, Object> result) {
		Boolean isBlank = false;
		String paramStr = 'Input parameters: ';
		String logStr = '';
		for (String key: paramsMap.keySet()) {
			String value = paramsMap.get(key);
			if (String.isBlank(value)) {
				isBlank = true;
				logStr += '[' + key + ']';
			}
			if (isDebug) {
				paramStr = paramStr + key + '=[' + value + '],';
			}
		}
		debug(paramStr);
		if (isBlank) {
			String logStr2 = 'These plugin input parameters should not be blank: ' + logStr;
			log(logStr2);
			result.put(UserProvisioningUtils.PARAM_STATUS, 'Failed');
			result.put(UserProvisioningUtils.PARAM_DETAILS, logStr2);
		}
		return isBlank;
	}

	public void debug(Object details) {
		if (isDebug)
			log(details);
	}

	public void log(Object details) {
		String detailsStr = String.valueOf(details);
		System.debug(detailsStr);
		String detailsStr2 = detailsStr.abbreviate(MAX_LOG_LEN);
		pendingLogs.add(detailsStr2);
	}

	public void insertLogs() {
		for (String logStr : pendingLogs) {
			UserProvisioning.UserProvisioningLog.log(uprId, logStr);
		}
	}

	public void handleException(Map<String,Object> result, String s, Exception e) {
		result.put(UserProvisioningUtils.PARAM_STATUS, 'Failed');
		String s1 = 'Exception in plugin:' + e + ', StackTrace:' + e.getStackTraceString();
		result.put(UserProvisioningUtils.PARAM_DETAILS, s1.abbreviate(255));
		String s2 = s + e + ', StackTrace:' + e.getStackTraceString();
		log(s2);
	}

	//Mconde
	public void addExternalResponse(SCIMCreateUserResponse respObj){
		if(uprId != null && respObj != null){

			if(respObj.active != null && respObj.active.equalsIgnoreCase('false')){
				UserProvisioningRequest updUPR = new UserProvisioningRequest();
				updUPR.id = uprId;
				updUPR.isActive__c = false;
				update updUPR;
			}


		}

	}

	public static void CreateUPRs(Set <Id> contactIdPASSAccreditationSet, string ConnecteAppRoleName){
		//WORKAROUND TO TRIGGER THE USER PROVISIONING.
		//IF the user does not have system permission: "Manage Users" AND "view and setup application
		//Then user provisioning is NOT triggered when the permission set is assigned to the user.
		//However, we can create the record in the user provisioning request object
		//And this will kick in the user provisioning flow. 
		list<UserProvisioningRequest> lsUPR = new list<UserProvisioningRequest>();
		if(!string.isBlank(ConnecteAppRoleName) && !contactIdPASSAccreditationSet.isEmpty()){
			Connected_App_Roles__c PASSConnectedApp = [SELECT Connected_App_Provisioning_Name__c, Provisioning_Id__c FROM Connected_App_Roles__c WHERE Name = :ConnecteAppRoleName LIMIT 1];
			if(PASSConnectedApp<>null){
				for(user U: [select id from user where contactId in:contactIdPASSAccreditationSet]){
					lsUPR.add(
						new UserProvisioningRequest(
							AppName = PASSConnectedApp.Connected_App_Provisioning_Name__c
							, ConnectedAppId = PASSConnectedApp.Provisioning_Id__c
							, Operation = 'Create'
							, ApprovalStatus = 'NotRequired'
							, SalesforceUserId = u.Id
							, state = 'New'
						)
					);
				}
			}
		}
		if(!lsUPR.isEmpty())
			insert lsUPR;
	}
}
