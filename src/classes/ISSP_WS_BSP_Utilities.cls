global class ISSP_WS_BSP_Utilities {

	global class ResponseOne {
		WebService Boolean isSuccess;
		WebService String responseErrorCode;
		WebService String responseErrorMessage;
	}

	global class EnvironmentData {
		WebService String validationKey;
		WebService String currentEnvironment;
	}

	WebService static ResponseOne changeEnvironment (EnvironmentData inputData) {

		String validationKey = inputData.validationKey;
		String currentEnvironment = inputData.currentEnvironment;

		// Get request IP
		List <LoginHistory> loginList;
		if(Test.isRunningTest()){
			loginList = [SELECT Id, SourceIp FROM LoginHistory
										WHERE UserId = :UserInfo.getUserId()
										ORDER BY LoginTime DESC
										Limit 1000];
		}else{
			loginList = [SELECT Id, SourceIp FROM LoginHistory
										WHERE UserId = :UserInfo.getUserId()
										ORDER BY LoginTime DESC];
		}

		// Create log object record
		ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
		newLog.Success__c = true;
		newLog.Web_Service__c = 'ISSP_WS_BSP_Utilities';
		newLog.Method__c = 'changeEnvironment';
		newLog.System__c = 'BSPLink';
		if (!loginList.isEmpty()){
			newLog.Login_Ip__c = loginList[0].SourceIp;
		}
		String errorCode = '';
		String errorMessage = '';
		// log inputs
		String fulldescription = 'Change Environment: ' + currentEnvironment;
		newLog.Input_Description__c = fulldescription;

		// Build the Return Struture
		ResponseOne retResponseOne = new ResponseOne();
		retResponseOne.isSuccess = true;
		retResponseOne.responseErrorCode = '';
		retResponseOne.responseErrorMessage = '';

		if (validationKey != 'BSP_Change_Env_ABC1234'){
			//wrong validation key
			errorCode = '016';
			errorMessage = ISSP_Int_Error__c.getValues('016').Error_Message__c;
			retResponseOne.isSuccess = false;
			retResponseOne.responseErrorCode = errorCode;
			retResponseOne.responseErrorMessage = errorMessage;

			//insert log record
			newLog.Success__c = false;
			newLog.Error_Code__c = errorCode;
			newLog.Error_Message__c = errorMessage;
			newLog.Finished__c = system.now();
			insert newLog;

			return retResponseOne;
		}
		else{
			if (currentEnvironment != 'A' && currentEnvironment != 'B'){
				//wrong environment value
				errorCode = '017';
				errorMessage = ISSP_Int_Error__c.getValues('017').Error_Message__c;
				retResponseOne.isSuccess = false;
				retResponseOne.responseErrorCode = errorCode;
				retResponseOne.responseErrorMessage = errorMessage;

				//insert log record
				newLog.Success__c = false;
				newLog.Error_Code__c = errorCode;
				newLog.Error_Message__c = errorMessage;
				newLog.Finished__c = system.now();
				insert newLog;

				return retResponseOne;
			}
			else{
				String url = '';
				ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
				String appId = serviceIdInstance.BSPLink__c;
				List <Portal_Applications__c> appList = [SELECT Id, Application_URL__c FROM
														Portal_Applications__c WHERE Id = :appId];
				if (appList.isEmpty()){
					//wrong environment value
					errorCode = '017';
					errorMessage = ISSP_Int_Error__c.getValues('017').Error_Message__c;
					retResponseOne.isSuccess = false;
					retResponseOne.responseErrorCode = errorCode;
					retResponseOne.responseErrorMessage = errorMessage;

					//insert log record
					newLog.Success__c = false;
					newLog.Error_Code__c = errorCode;
					newLog.Error_Message__c = errorMessage;
					newLog.Finished__c = system.now();
					insert newLog;

					return retResponseOne;
				}
				else{
					if (currentEnvironment == 'A'){
						url = String.ValueOF(ISSP_CS__c.getValues('BSPLink URL A').value__c);
					}
					else if (currentEnvironment == 'B'){
						url = String.ValueOF(ISSP_CS__c.getValues('BSPLink URL B').value__c);
					}
					appList[0].Application_URL__c = url;
					update appList[0];
				}
			}
		}

		newLog.Finished__c = system.now();
		insert newLog;
		return retResponseOne;
	}

	global class ResponseTwo {
		WebService Boolean isSuccess;
		WebService String responseErrorCode;
		WebService String responseErrorMessage;
		WebService String lastLoginDate;
	}

	global class UserInputData {
		WebService String FederationID;
	}

	WebService static ResponseTwo getLastLoginDate (UserInputData inputData) {

		String fedId = inputData.FederationID;

		// Get request IP
		List <LoginHistory> loginList = [SELECT Id, SourceIp FROM LoginHistory
										WHERE UserId = :UserInfo.getUserId()
										ORDER BY LoginTime DESC limit 5000 ];

		// Create log object record
		ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
		newLog.Success__c = true;
		newLog.Web_Service__c = 'ISSP_WS_BSP_Utilities';
		newLog.Method__c = 'changeEnvironment';
		newLog.System__c = 'BSPLink';
		if (!loginList.isEmpty()){
			newLog.Login_Ip__c = loginList[0].SourceIp;
		}
		String errorCode = '';
		String errorMessage = '';
		// log inputs
		String fulldescription = 'FederationID: ' + fedId;
		newLog.Input_Description__c = fulldescription;

		// Build the Return Struture
		ResponseTwo retResponseTwo = new ResponseTwo();
		retResponseTwo.isSuccess = true;
		retResponseTwo.responseErrorCode = '';
		retResponseTwo.responseErrorMessage = '';
		retResponseTwo.lastLoginDate = '';

		if (fedId == '' || fedId == null){
			//federation id cannot be null
			errorCode = '012';
			errorMessage = ISSP_Int_Error__c.getValues('012').Error_Message__c;
			retResponseTwo.isSuccess = false;
			retResponseTwo.responseErrorCode = errorCode;
			retResponseTwo.responseErrorMessage = errorMessage;

			//insert log record
			newLog.Success__c = false;
			newLog.Error_Code__c = errorCode;
			newLog.Error_Message__c = errorMessage;
			newLog.Finished__c = system.now();
			insert newLog;

			return retResponseTwo;
		}
		else{
			List <User> userList = [SELECT Id, LastLoginDate FROM User WHERE FederationIdentifier = :fedId];
			if (userList.isEmpty()){
				//user not found
				errorCode = '011';
				errorMessage = ISSP_Int_Error__c.getValues('011').Error_Message__c;
				retResponseTwo.isSuccess = false;
				retResponseTwo.responseErrorCode = errorCode;
				retResponseTwo.responseErrorMessage = errorMessage;

				//insert log record
				newLog.Success__c = false;
				newLog.Error_Code__c = errorCode;
				newLog.Error_Message__c = errorMessage;
				newLog.Finished__c = system.now();
				insert newLog;

				return retResponseTwo;
			}
			else{
				retResponseTwo.lastLoginDate = String.valueOf(userList[0].LastLoginDate);
			}
		}

		newLog.Finished__c = system.now();
		insert newLog;
		return retResponseTwo;
	}

}
