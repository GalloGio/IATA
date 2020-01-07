global class AMS_SearchAccountByUserData implements Process.Plugin {

		global Process.PluginResult invoke(Process.PluginRequest request) {

				String accountName = (String) request.inputParameters.get('Account_Name_Search_Input');
				String iataCode = (String) request.inputParameters.get('IATA_Code_searchHO');
				String accountSector = (String) request.inputParameters.get('AccountSearchSector');
				String typeOfOscarProcess = (String) request.inputParameters.get('Type_Of_OSCAR_Process');

				System.debug('Type of Account_Name_Search_Input is ' + accountName);
				System.debug('Type of IATA_Code_searchHO is ' + iataCode);
				System.debug('Type of AccountSearchSector is ' + accountSector);
				System.debug('Type of Type_Of_OSCAR_Process is ' + typeOfOscarProcess);

				List<Account> accts = null;

				if(typeOfOscarProcess.equalsIgnoreCase('MAJOR.CHANGES')){
					System.debug('Searching for Accounts in Major Changes process');
					accts = fetchAccountsChanges(accountName,iataCode,accountSector);
				}
				else{
					accts = fetchAccountsBR(accountName,iataCode,accountSector);
					System.debug('Searching for Accounts in HR / BR process');
				}

				Map<String,Object> result = new Map<String,Object>();

				result.put('hasResults',!accts.isEmpty());

				return new Process.PluginResult(result);
		}


		// Returns the describe information for the interface
		global Process.PluginDescribeResult describe() {
				Process.PluginDescribeResult result = new Process.PluginDescribeResult();
				result.Name = 'AMS_SearchAccountByUserData';
				result.Tag = 'APEX';
				result.inputParameters = new
					 List<Process.PluginDescribeResult.InputParameter>{
						new Process.PluginDescribeResult.InputParameter('Account_Name_Search_Input',
						Process.PluginDescribeResult.ParameterType.STRING, true),
						new Process.PluginDescribeResult.InputParameter('IATA_Code_searchHO',
						Process.PluginDescribeResult.ParameterType.STRING, true),
						new Process.PluginDescribeResult.InputParameter('AccountSearchSector',
						Process.PluginDescribeResult.ParameterType.STRING, true),
						new Process.PluginDescribeResult.InputParameter('Type_Of_OSCAR_Process',
						Process.PluginDescribeResult.ParameterType.STRING, true)
						};
				result.outputParameters = new
					 List<Process.PluginDescribeResult.OutputParameter>{
						 new Process.PluginDescribeResult.OutputParameter('hasResults',
							 Process.PluginDescribeResult.ParameterType.BOOLEAN)
					 };
				return result;
		}

		private List<Account> fetchAccountsBR(String accountName, String iataCode, String accountSector){

				if(String.isEmpty(accountName) || String.isBlank(accountName))
					return [SELECT Id, Name from Account where IATACode__c = :iataCode AND Sector__c = :accountSector and Status__c != 'Terminated' and Location_Type__c = 'HO'];
				else
					if(String.isEmpty(iataCode) || String.isBlank(iataCode))
						return [SELECT Id, Name from Account where Name = :accountName  AND Sector__c = :accountSector and Status__c != 'Terminated' and Location_Type__c = 'HO'];
					else
						 return [SELECT Id, Name from Account where IATACode__c = :iataCode AND Name = :accountName AND Sector__c = :accountSector and Status__c != 'Terminated' and Location_Type__c = 'HO'];

		}

		private List<Account> fetchAccountsChanges(String accountName, String iataCode, String accountSector){

				if(String.isEmpty(accountName) || String.isBlank(accountName))
					return [SELECT Id, Name from Account where IATACode__c = :iataCode AND Sector__c = :accountSector and Status__c != 'Terminated'];
				else
					if(String.isEmpty(iataCode) || String.isBlank(iataCode))
						return [SELECT Id, Name from Account where Name = :accountName  AND Sector__c = :accountSector and Status__c != 'Terminated'];
					else
						 return [SELECT Id, Name from Account where IATACode__c = :iataCode AND Name = :accountName AND Sector__c = :accountSector and Status__c != 'Terminated'];


		}

}
