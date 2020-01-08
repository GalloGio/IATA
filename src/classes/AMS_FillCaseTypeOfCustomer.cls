global class AMS_FillCaseTypeOfCustomer implements Process.Plugin{

	global Process.PluginResult invoke(Process.PluginRequest request) {

		String category = (String) request.inputParameters.get('Category_Input');
		String locationType = (String) request.inputParameters.get('LocationType_Input');

		System.debug('Type of Category_Input is ' + category);
		System.debug('Type of LocationType_Input is ' + locationType);

		String typeOfCustomer = AMS_Utils.fetchTypeOfCustomer(locationType,category);


		Map<String,Object> result = new Map<String,Object>();

		result.put('typeOfCustomer',typeOfCustomer);

		return new Process.PluginResult(result);
	}

	// Returns the describe information for the interface
	global Process.PluginDescribeResult describe() {
		Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.Name = 'AMS_FillCaseTypeOfCustomer';
		result.Tag = 'APEX';
		result.inputParameters = new
		   List<Process.PluginDescribeResult.InputParameter>{
			new Process.PluginDescribeResult.InputParameter('Category_Input',
			Process.PluginDescribeResult.ParameterType.STRING, true),
			new Process.PluginDescribeResult.InputParameter('LocationType_Input',
			Process.PluginDescribeResult.ParameterType.STRING, true)
			};
		result.outputParameters = new
		   List<Process.PluginDescribeResult.OutputParameter>{
			 new Process.PluginDescribeResult.OutputParameter('typeOfCustomer',
			   Process.PluginDescribeResult.ParameterType.STRING)
		   };
		return result;
	}


 }
