global class SCIMDeleteUserPlugin extends UserProvisioning.UserProvisioningPlugin {

    private static String PARAM_EMAIL = 'email';

    global override Process.PluginDescribeResult buildDescribeCall() { 
        Process.PluginDescribeResult describeResult = new Process.PluginDescribeResult();
        // A Group for the Plugins
        describeResult.tag = 'SCIM';
        // The specific operation
        describeResult.Name = 'SCIM: Delete User';

        describeResult.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter(UserProvisioningUtils.PARAM_CALLPARAMS, Process.PluginDescribeResult.ParameterType.STRING, false)
        };
        
        return describeResult;
    } 
    
    global override Process.PluginResult invoke(Process.PluginRequest request) {
    
        Map<String,Object> result = new Map<String,Object>();
        result.put(UserProvisioningUtils.PARAM_STATUS, 'Failed'); // set default

        String uprId = (String)request.inputParameters.get(UserProvisioningUtils.PARAM_UPR_ID);

        //Is Debug
        Boolean isDebug = SCIMUsersUtility.isDebug();
        UserProvisioningUtils userProvUtils = new UserProvisioningUtils(isDebug);
        userProvUtils.debug('Inside SCIMDeleteUserPlugin invoke()');

        try {
            userProvUtils.init(uprId);
            SCIMUsersUtility.endPoint = userProvUtils.getNamedCredential();

            UserProvAccount upa = userProvUtils.getLinkedUserProvAccount();

            //userProvUtils.debug('UPA DELETE ---->' + upa);

            if (upa != null && !String.isBlank(upa.externalUserId)) {

                String params = (String)request.inputParameters.get(UserProvisioningUtils.PARAM_CALLPARAMS);
                if(params != null) SCIMUsersUtility.deleteParams = (Map<String,String>)JSON.deserialize(params, Map<String, String>.class);

                System.debug(loggingLevel.FINEST, '____ [cls SCIMDeleteUserPlugin - invoke] params - ' + params);
                System.debug(loggingLevel.FINEST, '____ [cls SCIMDeleteUserPlugin - invoke] deleteParams - ' + SCIMUsersUtility.deleteParams);

                Map<String, Object> callResult = SCIMUsersUtility.deleteUser(upa.externalUserId);
                userProvUtils.debug('HTTP call result was ' + callResult);

                Boolean isSuccess = (Boolean)callResult.get('isSuccess');
                if (isSuccess) {
                    result.put(UserProvisioningUtils.PARAM_STATUS, 'Completed');
		    //Set status to 'Deactivated' for systems that do not support hard delete
                    result.put(UserProvisioningUtils.PARAM_UPASTATUS, 'Deleted');
                    result.put(UserProvisioningUtils.PARAM_DETAILS, 'User deactivated successfully with ' + upa);
                    userProvUtils.debug('User deactivated successfully with ' + upa);            
                }

                delete upa;
                    
            } else {
                userProvUtils.debug('Could not find user to delete from UserProvAccount where linkState = Linked and salesforceUserId = ' + userProvUtils.getSalesforceUserId());
                result.put(UserProvisioningUtils.PARAM_STATUS, 'Failed');
            }
        } catch(Exception e) {
            userProvUtils.handleException(result, 'Exception found when calling service: ', e);
        } finally {
            userProvUtils.insertLogs();
        }

        return new Process.PluginResult(result);
    }
}