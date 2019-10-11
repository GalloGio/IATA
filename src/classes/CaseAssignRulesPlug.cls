global class CaseAssignRulesPlug implements Process.Plugin{

    global Process.PluginResult invoke(Process.PluginRequest request) {
    	String caseId = (String) request.inputParameters.get('CaseId');

    	System.debug('The Case Id is ' + caseId);
    	ClaimEU261Helper.updateCaseOwner(caseId);
    	
    	Map<String,Object> result = new Map<String,Object>();

        return new Process.PluginResult(result);
    }

    global Process.PluginDescribeResult describe() {
    	Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'Case Assignment Rules';
        result.Tag = 'APEX';
        result.inputParameters = new
                List<Process.PluginDescribeResult.InputParameter>{
                new Process.PluginDescribeResult.InputParameter('CaseId',Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        return result;
    }
}