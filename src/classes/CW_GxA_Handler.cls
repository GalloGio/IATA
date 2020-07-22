global without sharing class CW_GxA_Handler {
	final static String INTEGRATION_MAPPING_VERSION = 'V4_19.05';

	global final static String GXA_STATUS_IN_PROGRESS = 'InProgress';
	global final static String GXA_STATUS_DONE = 'Done';
	global final static String GXA_STATUS_FAILED = 'Failed';

	public static Map<String, Object> convertAnswersJsonToData(List<String> answerFilesContent) {
		ICG_Account_Role_Detail__c stationConverted = new ICG_Account_Role_Detail__c();
		Map<String, List<Account_Role_Detail_Capability__c>> capabilitiesConverted = new Map<String, List<Account_Role_Detail_Capability__c>>();
		List<CW_GxA_Wrappers.SurveyAnswers> answersNotMapped = new List<CW_GxA_Wrappers.SurveyAnswers>();

		Map<String, Object> convertedData = new Map<String, Object>{ 'ICG_Account_Role_Detail__c' => stationConverted, 'Account_Role_Detail_Capability__c' => capabilitiesConverted, 'answersNotMapped' => answersNotMapped };

		Map<String, ICG_GxA_Integration_Mapping__c> integrationMapping = getIntegrationMapping();
		Map<String, Boolean> picturesVisibility = new Map<String, Boolean>();

		// Generate Map that contains Category by Equipment and Recordtype by category(removing duplicated categories)
		Map<String, String> categoriesByEquipment = getCategoriesByEquipment();
		Map<String, Id> recordTypesIdByCategory = CW_FacilityCapabilitiesController.getRecordTypesIdByCategoryName();
		Map<String, Map<String, Schema.SObjectField>> objectsFieldsDescribe = new Map<String, Map<String, Schema.SObjectField>>();
		objectsFieldsDescribe.put('ICG_Account_Role_Detail__c', Schema.SObjectType.ICG_Account_Role_Detail__c.fields.getMap());
		objectsFieldsDescribe.put('Account_Role_Detail_Capability__c', Schema.SObjectType.Account_Role_Detail_Capability__c.fields.getMap());

		// Get all answers
		for (String answerFileContent : answerFilesContent) {
			CW_GxA_Wrappers.Survey currentItem = CW_GxA_Wrappers.parseSurvey(answerFileContent);
			List<CW_GxA_Wrappers.SurveyAnswers> answers = new List<CW_GxA_Wrappers.SurveyAnswers>();
			// First loop required to get: correct mappings, visibility pictures, ...
			for (CW_GxA_Wrappers.SurveyAnswers currentAnswer : currentItem.SurveyAnswers) {
				ICG_GxA_Integration_Mapping__c mapFound = integrationMapping.get(currentAnswer.QuestionID);
				if (mapFound == null) {
					answersNotMapped.add(currentAnswer);
				} else if (mapFound.SF_Is_Mapping_Ok__c) {
					if (mapFound.SF_Specific_Processing__c == 'Fileupload.Json.Visible' && integrationMapping.containsKey(mapFound.GxA_Question_Parent_Id__c)) {
						picturesVisibility.put(mapFound.GxA_Question_Parent_Id__c, ('yes' == currentAnswer.Response.toLowerCase()));
					} else if (mapFound.SF_Specific_Processing__c == 'Fileupload.Json.Visible') {
						picturesVisibility.put(mapFound.SF_Equipment__c, ('yes' == currentAnswer.Response.toLowerCase()));
					} else {
						answers.add(currentAnswer);
					}
				}
			}

			for (CW_GxA_Wrappers.SurveyAnswers currentAnswer : answers) {
				if (integrationMapping.containsKey(currentAnswer.QuestionID) && integrationMapping.get(currentAnswer.QuestionID).SF_Process_Question__c.toLowerCase() == 'yes') {
					ICG_GxA_Integration_Mapping__c surveyMapping = integrationMapping.get(currentAnswer.QuestionID);
					switch on surveyMapping.SF_Target_Object__c {
						when 'ICG_Account_Role_Detail__c' {
							if (String.isBlank(surveyMapping.SF_Specific_Processing__c)) {
								stationConverted.put(surveyMapping.SF_Target_Field__c, convertAnswerResponse(objectsFieldsDescribe, surveyMapping.SF_Target_Object__c, surveyMapping.SF_Target_Field__c, currentAnswer.Response));
							} else {
								specificProcessing(stationConverted, currentAnswer.Response, surveyMapping, objectsFieldsDescribe);
							}
						}
						when 'Account_Role_Detail_Capability__c' {
							if (!capabilitiesConverted.containsKey(surveyMapping.SF_Equipment__c)) {
								capabilitiesConverted.put(surveyMapping.SF_Equipment__c, new List<Account_Role_Detail_Capability__c>());
							}

							if (currentAnswer.SubSurvey.size() == 0) {
								if (capabilitiesConverted.get(surveyMapping.SF_Equipment__c).size() == 0) {
									capabilitiesConverted.get(surveyMapping.SF_Equipment__c).add(new Account_Role_Detail_Capability__c(RecordTypeId = recordTypesIdByCategory.get(categoriesByEquipment.get(surveyMapping.SF_Equipment__c).toLowerCase()), Category__c = categoriesByEquipment.get(surveyMapping.SF_Equipment__c), Equipment__c = surveyMapping.SF_Equipment__c));
								}

								if (String.isBlank(surveyMapping.SF_Specific_Processing__c)) {
									capabilitiesConverted.get(surveyMapping.SF_Equipment__c)[0].put(surveyMapping.SF_Target_Field__c, convertAnswerResponse(objectsFieldsDescribe, surveyMapping.SF_Target_Object__c, surveyMapping.SF_Target_Field__c, currentAnswer.Response));
								} else {
									if (surveyMapping.SF_Specific_Processing__c == 'Fileupload.Json.Url') {
										currentAnswer.Response = String.valueOf(getDefaultPictureVisibility(picturesVisibility, currentAnswer.QuestionID, surveyMapping.SF_Equipment__c)) + ':' + currentAnswer.Response;
									}
									specificProcessing(capabilitiesConverted.get(surveyMapping.SF_Equipment__c)[0], currentAnswer.Response, surveyMapping, objectsFieldsDescribe);
								}
							} else {
								Map<String, Account_Role_Detail_Capability__c> subSurveysMap = new Map<String, Account_Role_Detail_Capability__c>();

								// Loop SubSurvey
								for (CW_GxA_Wrappers.SubSurvey currentSubSurvey : currentAnswer.SubSurvey) {
									if (!subSurveysMap.containsKey(currentSubSurvey.SubSurveySessionId)) {
										subSurveysMap.put(currentSubSurvey.SubSurveySessionId, new Account_Role_Detail_Capability__c(RecordTypeId = recordTypesIdByCategory.get(categoriesByEquipment.get(surveyMapping.SF_Equipment__c).toLowerCase()), Category__c = categoriesByEquipment.get(surveyMapping.SF_Equipment__c), Equipment__c = surveyMapping.SF_Equipment__c));
									}

									if (integrationMapping.containsKey(currentSubSurvey.QuestionID) && integrationMapping.get(currentSubSurvey.QuestionID).SF_Process_Question__c.toLowerCase() == 'yes') {
										ICG_GxA_Integration_Mapping__c subSurveyMapping = integrationMapping.get(currentSubSurvey.QuestionID);
										if (String.isBlank(subSurveyMapping.SF_Specific_Processing__c)) {
											subSurveysMap.get(currentSubSurvey.SubSurveySessionId).put(subSurveyMapping.SF_Target_Field__c, convertAnswerResponse(objectsFieldsDescribe, subSurveyMapping.SF_Target_Object__c, subSurveyMapping.SF_Target_Field__c, currentSubSurvey.Response));
										} else {
											if (subSurveyMapping.SF_Specific_Processing__c == 'Fileupload.Json.Url') {
												currentSubSurvey.Response = String.valueOf(getDefaultPictureVisibility(picturesVisibility, currentSubSurvey.QuestionID, surveyMapping.SF_Equipment__c)) + ':' + currentSubSurvey.Response;
											}
											specificProcessing(subSurveysMap.get(currentSubSurvey.SubSurveySessionId), currentSubSurvey.Response, subSurveyMapping, objectsFieldsDescribe);
										}
									}
								}
								capabilitiesConverted.get(surveyMapping.SF_Equipment__c).addAll(subSurveysMap.values());
							}
						}
						when else {
							System.debug(LoggingLevel.ERROR, 'SF_Target_Object__c - ' + surveyMapping.SF_Target_Object__c + ' - NOT SUPPORTED!!!');
						}
					}
				}
			}
		}

		return convertedData;
	}

	public static List<Id> getOrdersIdWithLastIntegrationFailed(Date startAt, Date endAt) {
		List<Id> failedOrderIds = new List<Id>();

		if (startAt == null) {
			startAt = Date.today().toStartOfMonth();
		}
		if (endAt == null) {
			endAt = startAt.addMonths(1).addDays(-1);
		}

		// Get the orders between dates that last retry was failed
		Id remoteValidationRtId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
		Map<Id, String> lastStatusByOrder = new Map<Id, String>();
		for (ICG_Capability_Assignment_Group__c currentAsgmtGroup : [SELECT Id, CreatedDate, RecordType.DeveloperName, Order_Product__r.OrderId, GxA_Integration_Status__c FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId = :remoteValidationRtId AND CreatedDate >= :startAt AND CreatedDate <= :endAt ORDER BY CreatedDate DESC]) {
			if (!lastStatusByOrder.containsKey(currentAsgmtGroup.Order_Product__r.OrderId)) {
				lastStatusByOrder.put(currentAsgmtGroup.Order_Product__r.OrderId, currentAsgmtGroup.GxA_Integration_Status__c);
			}
		}

		for (Id orderId : lastStatusByOrder.keySet()) {
			if (lastStatusByOrder.get(orderId) == CW_GxA_Handler.GXA_STATUS_FAILED) {
				failedOrderIds.add(orderId);
			}
		}

		return failedOrderIds;
	}

	private static Boolean getDefaultPictureVisibility(Map<String, Boolean> picturesVisibility, String questionId, String equipment) {
		Boolean defaultVisibility = false;
		if (picturesVisibility.containsKey(questionId)) {
			defaultVisibility = picturesVisibility.containsKey(questionId);
		} else if (picturesVisibility.containsKey(equipment)) {
			defaultVisibility = picturesVisibility.containsKey(equipment);
		}

		return defaultVisibility;
	}
	private static void specificProcessing(SObject inputObject, String inputValue, ICG_GxA_Integration_Mapping__c mappingData, Map<String, Map<String, Schema.SObjectField>> objectsFieldsDescribe) {
		switch on mappingData.SF_Specific_Processing__c {
			when 'Availability', 'Fileupload.Json.Visible', 'SubSurvey' {
				// do nothing, processed in other block
			}
			when 'Fileupload' {
				String separator = '\n\n';
				String previousStoredData = (String) inputObject.get(mappingData.SF_Target_Field__c);
				if (String.isBlank(previousStoredData)) {
					previousStoredData = '';
				} else {
					previousStoredData = separator;
				}

				inputObject.put(mappingData.SF_Target_Field__c, convertAnswerResponse(objectsFieldsDescribe, mappingData.SF_Target_Object__c, mappingData.SF_Target_Field__c, previousStoredData + inputValue.replace(',', separator)));
			}
			when 'Fileupload.Json.Url' {
				List<CW_FacilityCapabilitiesController.CapabilityPhoto> photos;
				if (String.isBlank((String) inputObject.get(mappingData.SF_Target_Field__c))) {
					photos = new List<CW_FacilityCapabilitiesController.CapabilityPhoto>();
				} else {
					photos = (List<CW_FacilityCapabilitiesController.CapabilityPhoto>) JSON.deserialize((String) inputObject.get(mappingData.SF_Target_Field__c), List<CW_FacilityCapabilitiesController.CapabilityPhoto>.class);
				}

				Boolean isPublic = Boolean.valueOf(inputValue.split(':', 2)[0]);
				inputValue = inputValue.split(':', 2)[1];
				for (String currentUrl : inputValue.split(',')) {
					CW_FacilityCapabilitiesController.CapabilityPhoto currentPhoto = new CW_FacilityCapabilitiesController.CapabilityPhoto();
					currentPhoto.visible = isPublic;
					currentPhoto.url = currentUrl;
					currentPhoto.label = mappingData.SF_Data_Extra__c;
					photos.add(currentPhoto);
				}
				inputObject.put(mappingData.SF_Target_Field__c, convertAnswerResponse(objectsFieldsDescribe, mappingData.SF_Target_Object__c, mappingData.SF_Target_Field__c, JSON.serialize(photos)));
			}
			when 'Options.Mapping' {
				List<String> gxaOptions = new List<String>();
				List<String> sfOptions = new List<String>();
				List<String> values = new List<String>();

				if (String.isNotBlank(mappingData.GxA_Options__c)) {
					gxaOptions.addAll(mappingData.GxA_Options__c.trim().toLowerCase().split(','));
				}
				if (String.isNotBlank(mappingData.SF_Options_Mapping__c)) {
					sfOptions.addAll(mappingData.SF_Options_Mapping__c.trim().split(','));
				}

				for (String currentInputValue : inputValue.trim().split(',')) {
					if (gxaOptions.size() > 0 && gxaOptions.size() == sfOptions.size()) {
						for (Integer z = 0; z < gxaOptions.size(); z++) {
							if (currentInputValue.toLowerCase() == gxaOptions[z]) {
								currentInputValue = sfOptions[z];
							}
						}
					}
					values.add(currentInputValue);
				}

				inputObject.put(mappingData.SF_Target_Field__c, convertAnswerResponse(objectsFieldsDescribe, mappingData.SF_Target_Object__c, mappingData.SF_Target_Field__c, String.join(values, ';')));
			}
			when 'Temperature.Range.From', 'Temperature.Range.To' {
				String currentTemperature = (String) inputObject.get(mappingData.SF_Target_Field__c);
				if (String.isBlank(currentTemperature)) {
					currentTemperature = '{0}ºC to {1}ºC';
				}
				if ('Temperature.Range.From' == mappingData.SF_Specific_Processing__c) {
					currentTemperature = currentTemperature.replace('{0}', inputValue);
				} else if ('Temperature.Range.To' == mappingData.SF_Specific_Processing__c) {
					currentTemperature = currentTemperature.replace('{1}', inputValue);
				}
				inputObject.put(mappingData.SF_Target_Field__c, currentTemperature);
			}
			when 'UldCompatibility' {
				// SF_Target_Field__c => GSE_ULD_Compatibility_Type_AKE__c;GSE_ULD_Compatibility_Type_F10__c;GSE_ULD_Compatibility_Type_F20__c
				// Expected Response => AKE;10ft ULD;20ft ULD

				// Set values to false
				for (String currentTargetField : mappingData.SF_Target_Field__c.split(';')) {
					inputObject.put(currentTargetField, convertAnswerResponse(objectsFieldsDescribe, mappingData.SF_Target_Object__c, currentTargetField, 'false'));
				}
				for (String responseValue : inputValue.split(',')) {
					for (String currentTargetField : mappingData.SF_Target_Field__c.split(';')) {
						if (currentTargetField.containsIgnoreCase(responseValue.left(2))) {
							inputObject.put(currentTargetField, convertAnswerResponse(objectsFieldsDescribe, mappingData.SF_Target_Object__c, currentTargetField, 'true'));
						}
					}
				}
			}
			when else {
				System.debug(LoggingLevel.WARN, 'Specific processing TO-DO: ' + mappingData.SF_Specific_Processing__c + ' => ' + inputValue);
			}
		}
	}
	private static Map<String, ICG_GxA_Integration_Mapping__c> getIntegrationMapping() {
		Map<String, ICG_GxA_Integration_Mapping__c> integrationMap = new Map<String, ICG_GxA_Integration_Mapping__c>();
		for (ICG_GxA_Integration_Mapping__c currentMapping : [SELECT GxA_Is_Mandatory__c, GxA_Question_Id__c, GxA_Question_Parent_Id__c, GxA_Question_Type_Id__c, GxA_Sub_Survey_Id__c, GxA_Question_Text__c, GxA_Validation__c, SF_Equipment__c, SF_Data_Extra__c, SF_Target_Field__c, SF_Specific_Processing__c, SF_Options_Mapping__c, GxA_Options__c, SF_Target_Object__c, SF_Is_Mapping_Ok__c, SF_Process_Question__c FROM ICG_GxA_Integration_Mapping__c WHERE Version__c = :INTEGRATION_MAPPING_VERSION ORDER BY GxA_Question_Id__c]) {
			integrationMap.put(currentMapping.GxA_Question_Id__c, currentMapping);
		}
		return integrationMap;
	}
	private static Map<String, String> getCategoriesByEquipment() {
		Map<String, String> categoriesByEquipment = new Map<String, String>();

		Map<String, List<Map<String, Object>>> picklistDependencies = CW_Utilities.getPicklistFieldDependencies('Account_Role_Detail_Capability__c', 'Category__c', 'Equipment__c', false);
		for (String currentCategory : picklistDependencies.keySet()) {
			for (Map<String, Object> currentEquipment : picklistDependencies.get(currentCategory)) {
				categoriesByEquipment.put(String.valueOf(currentEquipment.get('value')), currentCategory);
			}
		}

		return categoriesByEquipment;
	}
	private static Object convertAnswerResponse(Map<String, Map<String, Schema.SObjectField>> objectsFieldsDescribe, String objectName, String fieldName, String response) {
		if (!objectsFieldsDescribe.containsKey(objectName) || !objectsFieldsDescribe.get(objectName).containsKey(fieldName)) {
			return response;
		}
		switch on objectsFieldsDescribe.get(objectName).get(fieldName).getDescribe().getType().name().toLowerCase() {
			when 'double' {
				return Integer.valueOf(response);
			}
			when 'boolean' {
				response = response.toLowerCase().trim();
				if (response != 'true' || response == 'false') {
					response = response == 'yes' ? 'true' : 'false';
				}

				return Boolean.valueOf(response);
			}
			when 'multipicklist', 'picklist', 'string', 'textarea', 'url' {
				return response;
			}
			when 'date' {
				try {
					return ((Datetime) JSON.deserialize('"' + response + '"', Datetime.class)).date();
				} catch (Exception e) {
					return null;
				}
			}
			when 'datetime' {
				try {
					return JSON.deserialize('"' + response + '"', Datetime.class);
				} catch (Exception e) {
					return null;
				}
			}
			when else {
				System.debug(LoggingLevel.WARN, 'type name to add in convertAnswerResponse: ' + objectsFieldsDescribe.get(objectName).get(fieldName).getDescribe().getType().name().toLowerCase() + ' (' + fieldName + ' => ' + response + ')');
				return null;
			}
		}
	}
}