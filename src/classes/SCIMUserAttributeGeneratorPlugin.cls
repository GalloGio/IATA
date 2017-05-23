global class SCIMUserAttributeGeneratorPlugin extends UserProvisioning.UserProvisioningPlugin {

    global override Process.PluginDescribeResult buildDescribeCall() { 
        Process.PluginDescribeResult describeResult = new Process.PluginDescribeResult();
        // A Group for the Plugins
        describeResult.tag = 'SCIM';
        // The specific operation
        describeResult.Name = 'SCIM: Generate User Attributes';
        describeResult.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
			new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_USERNAME, Process.PluginDescribeResult.ParameterType.STRING, false),
			new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_LASTNAME, Process.PluginDescribeResult.ParameterType.STRING, false),
			new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_FIRSTNAME, Process.PluginDescribeResult.ParameterType.STRING, false),
			new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_EXTERNALID, Process.PluginDescribeResult.ParameterType.STRING, false),
			new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_EMAIL, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_ENTITLEMENT, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_PROPERTIES, Process.PluginDescribeResult.ParameterType.STRING, false),

            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_ID, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_DISPLAYNAME, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_NICKNAME, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_USERTYPE, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_PREFERREDLANGUAGE, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_LOCALE, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_TITLE, Process.PluginDescribeResult.ParameterType.STRING, false),
            new Process.PluginDescribeResult.InputParameter(SCIMUserAttributeGenerator.PARAM_ACTIVE, Process.PluginDescribeResult.ParameterType.BOOLEAN, false)
        }; 

        describeResult.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
           new Process.PluginDescribeResult.OutputParameter(UserProvisioningUtils.PARAM_USERPAYLOAD, Process.PluginDescribeResult.ParameterType.STRING)
        };

        return describeResult;
    }
    
    global override Process.PluginResult invoke(Process.PluginRequest request) {    
        // Attribute generation & serialization
        SCIMUserAttributeGenerator generator = new SCIMUserAttributeGenerator();
        SCIMUser user = generator.getMappedAttributes(request);
        String payload = generator.getSerializedAttributes(user);

        Map<String, Object> result = new Map<String, Object>();
        result.put(UserProvisioningUtils.PARAM_USERPAYLOAD, payload);

        return new Process.PluginResult(result);
    }
}
