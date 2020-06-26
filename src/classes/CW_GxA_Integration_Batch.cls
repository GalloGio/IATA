global class CW_GxA_Integration_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	final global static String GXA_STATUS_IN_PROGRESS = 'InProgress';
	final global static String GXA_STATUS_DONE = 'Done';
	final global static String GXA_STATUS_FAILED = 'Failed';

	global List<Id> assignmentsGroupIdsToProcess;

	global CW_GxA_Integration_Batch(List<Id> assignmentGroupIds) {
		assignmentsGroupIdsToProcess = assignmentGroupIds;
	}

	global Database.QueryLocator start(Database.BatchableContext bc) {
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		if (assignmentsGroupIdsToProcess == null) {
			assignmentsGroupIdsToProcess = new List<Id>();
		}
		return Database.getQueryLocator([SELECT Id, Order_Product__r.Station__c, GxA_Error_Message__c, GxA_Error_StackTrace__c, GxA_Result_Json__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId = :remoteValidationRtId AND Id IN :assignmentsGroupIdsToProcess]);
	}

	global void execute(Database.BatchableContext bc, List<sObject> scope) {
		if (scope.size() == 0) {
			return;
		} else if (scope.size() > 1) {
			throw new CW_GxA_Integration_Batch_Exception('The batch size for CW_GxA_Integration_Batch_Exception must be 1');
		}

		ICG_Capability_Assignment_Group__c currentScope = (ICG_Capability_Assignment_Group__c) scope[0];

		CW_GxA_Amazon_S3__c cfgAwsGxA = CW_GxA_Amazon_S3__c.getOrgDefaults();

		List<String> errorMessage = new List<String>();
		List<String> errorStackTrace = new List<String>();

		// Search the station
		CW_GxA_Wrappers.Index indexWrapper = CW_GxA_Wrappers.parseIndex(currentScope.GxA_Result_Json__c);

		if (currentScope.Order_Product__r.Station__c == null) {
			currentScope.GxA_Error_Message__c = 'Station linked to ' + indexWrapper.SalesforceCaseNumber + ' (SalesforceCaseNumber property in Result.json) not found';
			update currentScope;
			return;
		}

		// Download answers files and log errors if exists
		List<String> answersJsonContent = new List<String>();
		for (CW_GxA_Wrappers.Files answerFile : indexWrapper.Files) {
			Boolean needRetry = false;
			if (answerFile.File.endsWithIgnoreCase('.json')) {
				String objectKey = CW_AmazonS3Connector.convertUrlResourceToS3ObjectKey(answerFile.File, cfgAwsGxA.bucket__c);
				HttpResponse response;
				try {
					response = CW_AmazonS3Connector.awsS3GetObject(objectKey, cfgAwsGxA.Named_Credential__c);
					if (response.getStatusCode() == 200) {
						answersJsonContent.add(JSON.serialize(CW_GxA_Wrappers.parseSurvey(response.getBody())));
					} else {
						needRetry = true;
						CW_AmazonS3Wrappers.ErrorResponse s3Error = CW_AmazonS3Wrappers.parseError(new XmlStreamReader(response.getBody()));
						errorMessage.add('\n  ' + objectKey);
						errorMessage.add(String.format('     - S3 Error: {0} => {1}', new List<String>{ s3Error.Code, s3Error.Message }));
					}
				} catch (Exception e) {
					needRetry = true;
					errorMessage.add('\n  ' + objectKey);
					errorMessage.add('     - SF Exception.getMessage:' + e.getMessage());

					errorStackTrace.add('\n  ' + objectKey);
					errorStackTrace.add('     - SF Exception.getMessage:' + e.getMessage());
					errorStackTrace.add('     - SF Exception.getStackTraceString: ' + e.getStackTraceString());
				}
			}
		}

		if (errorMessage.size() > 0) {
			currentScope.GxA_Integration_Status__c = GXA_STATUS_FAILED;
			if (errorMessage.size() > 0) {
				errorMessage.add(0, 'At ' + Datetime.now().formatLong());
				errorMessage.add(1, '----------------------------------------------------------------------------');
				currentScope.GxA_Error_Message__c = String.join(errorMessage, '\n');
			}

			if (errorStackTrace.size() > 0) {
				errorStackTrace.add(0, 'At ' + Datetime.now().formatLong());
				errorStackTrace.add(1, '----------------------------------------------------------------------------');
				currentScope.GxA_Error_StackTrace__c = String.join(errorStackTrace, '\n');
			}

			update currentScope;
			return;
		}

		// Get new data from Answers
		Map<String, Object> dataFromQuestions = CW_GxA_Handler.convertAnswersJsonToData(answersJsonContent);
		ICG_Account_Role_Detail__c stationDataToUpdate = (ICG_Account_Role_Detail__c) dataFromQuestions.get('ICG_Account_Role_Detail__c');
		List<Account_Role_Detail_Capability__c> capabilitiesToAdd = new List<Account_Role_Detail_Capability__c>();
		List<ICG_Account_Role_Capability_Assignment__c> assignmentsToAdd = new List<ICG_Account_Role_Capability_Assignment__c>();

		for (List<Account_Role_Detail_Capability__c> currentCapabilitiesByEquipment : ((Map<String, List<Account_Role_Detail_Capability__c>>) dataFromQuestions.get('Account_Role_Detail_Capability__c')).values()) {
			capabilitiesToAdd.addAll(currentCapabilitiesByEquipment);
		}

		// ------------------------------------------------------------------
		// Update/Create Station, Capabilities and current scope
		// ------------------------------------------------------------------
		Savepoint sp;
		try {
			sp = Database.setSavepoint();

			// Set id for the station
			stationDataToUpdate.Id = currentScope.Order_Product__r.Station__c;
			Database.update(stationDataToUpdate);

			Database.insert(capabilitiesToAdd);
			for (Account_Role_Detail_Capability__c currentCapability : capabilitiesToAdd) {
				assignmentsToAdd.add(new ICG_Account_Role_Capability_Assignment__c(ICG_Account_Role_Detail__c = currentScope.Order_Product__r.Station__c, ICG_Capability_Assignment_Group__c = currentScope.Id, Account_Role_Detail_Capability__c = currentCapability.Id, Deprecated__c = false));
			}
			Database.insert(assignmentsToAdd);

			currentScope.GxA_Integration_Status__c = GXA_STATUS_DONE;
		} catch (Exception e) {
			Database.rollback(sp);

			currentScope.GxA_Integration_Status__c = GXA_STATUS_FAILED;
			currentScope.GxA_Error_Message__c = e.getMessage();
			currentScope.GxA_Error_StackTrace__c = e.getStackTraceString();
		} finally {
			currentScope.GxA_Answers_Not_Mapped_Json__c = JSON.serialize((List<CW_GxA_Wrappers.SurveyAnswers>) dataFromQuestions.get('answersNotMapped'));
		}
		Database.update(currentScope);
	}

	global void finish(Database.BatchableContext bc) {
	}

	private class CW_GxA_Integration_Batch_Exception extends Exception {
	}
}