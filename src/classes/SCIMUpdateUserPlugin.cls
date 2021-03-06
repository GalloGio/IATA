global class SCIMUpdateUserPlugin extends UserProvisioning.UserProvisioningPlugin {

	private static String PARAM_FAMILY_NAME = 'familyName';
	private static String PARAM_GIVEN_NAME = 'givenName';
	private static String PARAM_NICK_NAME = 'nickName';
	private static String PARAM_EMAIL = 'email';
	private static String PARAM_ENTITLEMENT = 'entitlement';

	global override Process.PluginDescribeResult buildDescribeCall() {
		Process.PluginDescribeResult describeResult = new Process.PluginDescribeResult();
		// A Group for the Plugins
		describeResult.tag = 'SCIM';
		// The specific operation
		describeResult.Name = 'SCIM: Update User';

		describeResult.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
			new Process.PluginDescribeResult.InputParameter(UserProvisioningUtils.PARAM_USERPAYLOAD, Process.PluginDescribeResult.ParameterType.STRING, true),
			new Process.PluginDescribeResult.InputParameter(UserProvisioningUtils.PARAM_CALLPARAMS, Process.PluginDescribeResult.ParameterType.STRING, false),
			new Process.PluginDescribeResult.InputParameter(UserProvisioningUtils.PARAM_EXTERNAL_SYSTEM, Process.PluginDescribeResult.ParameterType.STRING, false)
		};

		return describeResult;
	}

	global override Process.PluginResult invoke(Process.PluginRequest request) {

		Map<String,Object> result = new Map<String,Object>();
		result.put(UserProvisioningUtils.PARAM_STATUS, 'Failed'); // set default

		String uprId = (String)request.inputParameters.get(UserProvisioningUtils.PARAM_UPR_ID);
		String userPayload = (String)request.inputParameters.get(UserProvisioningUtils.PARAM_USERPAYLOAD);

		//Is Debug
		Boolean isDebug = SCIMUsersUtility.isDebug();
		UserProvisioningUtils userProvUtils = new UserProvisioningUtils(isDebug);
		userProvUtils.debug('Inside SCIMUpdateUserPlugin invoke()');

		// input validation
		Map<String,String> inputParamValues = new Map<String,String>();
		inputParamValues.put(UserProvisioningUtils.PARAM_USERPAYLOAD, userPayload);
		if (userProvUtils.areParamsBlank(inputParamValues, result)) {
			return new Process.PluginResult(result);
		}

		try {
			userProvUtils.init(uprId);
			SCIMUsersUtility.endPoint = userProvUtils.getNamedCredential((String)request.inputParameters.get(UserProvisioningUtils.PARAM_EXTERNAL_SYSTEM), 'UserProvisioning_Update');

			UserProvAccount upa = userProvUtils.getLinkedUserProvAccount();
			if (upa != null && !String.isBlank(upa.externalUserId)) {

				String params = (String)request.inputParameters.get(UserProvisioningUtils.PARAM_CALLPARAMS);
				if(params != null) SCIMUsersUtility.updateParams = (Map<String,String>)JSON.deserialize(params, Map<String, String>.class);

				System.debug(loggingLevel.FINEST, '____ [cls SCIMDeleteUserPlugin - invoke] params - ' + params);
				System.debug(loggingLevel.FINEST, '____ [cls SCIMDeleteUserPlugin - invoke] updateParams - ' + SCIMUsersUtility.updateParams);

				Map<String, Object> callResult = SCIMUsersUtility.updateUser(upa.externalUserId, userPayload);
				userProvUtils.debug('HTTP call result was ' + callResult);

				Boolean isSuccess = (Boolean)callResult.get('isSuccess');
				if (isSuccess) {
					result.put(UserProvisioningUtils.PARAM_STATUS, 'Completed');
					result.put(UserProvisioningUtils.PARAM_DETAILS,'User updated with ExternalUserId=' + result.get(UserProvisioningUtils.PARAM_EXTERNAL_USERID) + ', and ExternalUsername=' + result.get(UserProvisioningUtils.PARAM_EXTERNAL_USERNAME));
				}
			} else {
				userProvUtils.debug('Could not find user to update for UserProvAccount where linkState = Linked and salesforceUserId = ' + userProvUtils.getSalesforceUserId());
			}
		} catch(Exception e) {
			userProvUtils.handleException(result, 'Exception found when calling service: ', e);
		} finally {
			userProvUtils.insertLogs();
		}

		return new Process.PluginResult(result);
	}

}
