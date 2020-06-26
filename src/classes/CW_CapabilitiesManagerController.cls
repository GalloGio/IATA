public without sharing class CW_CapabilitiesManagerController {
	final static String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
	final static String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
	final static Map<String, List<String>> ESPECIAL_CATEGORIES = CW_FacilityCapabilitiesController.getMapConfig();

	/**
	 * @description	Get JSON with ICG_Certification_Capability_Assignment__c filtered by certification Id
	 * @param			certificationId Certification Id to filter
	 * @return			JSON with List of <ICG_Account_Role_Capability_Assignment__c>
	 */
	@AuraEnabled
	public static List<ICG_Certification_Capability_Assignment__c> getCertificationCapabilities(string certificationId) {
		return [SELECT id, Category__c, Equipment__c FROM ICG_Certification_Capability_Assignment__c WHERE ICG_Certification__c = :certificationId];
	}

	/**
	 * @description	Get Map<String, Object> with Capabilities filtered by account role detail Id and account role detail certification
	 * @param			id - Account Role Detail and ardCertId - Account Role Detail Certification Id to filter
	 * @return			Map<String, Object> with custom estructure that contains information on all capabilities
	 */
	@AuraEnabled
	public static Map<String, Object> getCapabilitiesForFacilityCertificationId(String id, String ardCertId, Boolean isCapabCertiMode) {
		Map<String, Object> returnValue = new Map<String, Object>{ 'superCategories' => new List<Map<String, Object>>() };

		try {
			Map<String, Object> rawData = new Map<String, Object>{ 'capabilities' => new List<Map<String, Object>>() };
			ICG_Capability_Assignment_Group__c ardCertCurrent = new ICG_Capability_Assignment_Group__c();
			String certificationId;
			if(ardCertId != null){
			ardCertCurrent = [SELECT id, ICG_Certification__c, ICG_Certification__r.Name, Expiration_Date__c, Issue_Date__c, ICG_Certification__r.Image__c FROM ICG_Capability_Assignment_Group__c WHERE id = :ardCertId];
			certificationId = ardCertCurrent.ICG_Certification__c;
			}
			// Get all record types of Account_Role_Detail_Capability__c configured. If there are no valid record types, we leave.
			Map<String, List<String>> mapCategoriesByRecordTypeDevName = CW_FacilityCapabilitiesController.getMapCategoriesByRecordType();
			Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById = new Map<Id, RecordType>();
			for (RecordType currentRt : RecordTypeSingleton.getInstance().getRecordTypesBySObject('Account_Role_Detail_Capability__c')) {
				if (mapCategoriesByRecordTypeDevName.containsKey(currentRt.DeveloperName.toLowerCase())) {
					mapAccountRoleDetailAssignmentRtsById.put(currentRt.Id, currentRt);
				}
			}
			if (mapAccountRoleDetailAssignmentRtsById.size() == 0) {
				return returnValue;
			}

			// Get account role detail to determine which categories need to show. If there are no categories, we leave.
			ICG_Account_Role_Detail__c accountRoleDetailFound = [SELECT Id, RecordType.DeveloperName FROM ICG_Account_Role_Detail__c WHERE Id = :id];
			List<String> categoriesToRetrieve = CW_FacilityCapabilitiesController.getMapCategoriesByAccountRoleDetailRecordType().get(accountRoleDetailFound.RecordType.DeveloperName.toLowerCase());
			if (categoriesToRetrieve == null) {
				return returnValue;
			} else {
				Map<String, List<String>> mapCategoriesByRecordTypeDevNameTmp = new Map<String, List<String>>();
				for (String currentKey : mapCategoriesByRecordTypeDevName.keySet()) {
					List<String> foundCategories = new List<String>();
					for (String currentCategory : mapCategoriesByRecordTypeDevName.get(currentKey)) {
						if (categoriesToRetrieve.contains(currentCategory)) {
							foundCategories.add(currentCategory);
						}
					}
					if (foundCategories.size() > 0) {
						mapCategoriesByRecordTypeDevNameTmp.put(currentKey, foundCategories);
					}
				}
				mapCategoriesByRecordTypeDevName = mapCategoriesByRecordTypeDevNameTmp;
			}

			//Get recordtypes id for category
			Map<String, String> mapRecordTypeIdByCategory = CW_FacilityCapabilitiesController.getRecordTypesIdByCategoryName();

			// Get Fields to build the soql query and the tables.
			Map<String, List<String>> mapFieldsByRecordTypeAndCategory = CW_FacilityCapabilitiesController.getMapFieldsByRecordTypeAndCategory();
			List<String> fieldsToRetrieve = new List<String>();
			for (List<String> fieldsGroup : mapFieldsByRecordTypeAndCategory.values()) {
				for (String field : fieldsGroup) {
					fieldsToRetrieve.add(field);
				}
			}

			// Get fields to use like a tooltip.
			Map<String, List<String>> mapTooltipFieldsByField = CW_FacilityCapabilitiesController.getMapTooltipFieldsByField();
			for (List<String> fieldsGroup : mapTooltipFieldsByField.values()) {
				for (String field : fieldsGroup) {
					if (!fieldsToRetrieve.contains(field)) {
						fieldsToRetrieve.add(field);
					}
				}
			}

			// Get equipments defined by category
			Map<String, List<Map<String, Object>>> equipmentsByCategory = CW_Utilities.getPicklistFieldDependencies('Account_Role_Detail_Capability__c', 'Category__c', 'Equipment__c', true);

			// Get fields for specific processing
			Map<String, List<String>> mapEquipmentValuesBySpecificProcessing = CW_FacilityCapabilitiesController.getMapEquipmentValuesBySpecificProcessing();

			// Get grouped fields
			Map<String, List<String>> mapFieldsByGroupField = CW_FacilityCapabilitiesController.getMapFieldsByGroupField();

			// Get categoires map
			Map<String, Schema.PicklistEntry> mapCategories = CW_FacilityCapabilitiesController.getPicklistEntryMapCapCategory();

			// Get equipments map
			Map<String, Schema.PicklistEntry> mapEquipments = CW_FacilityCapabilitiesController.getPicklistEntryMapCapEquipment();

			// Loop the record types to build the output data model
			for (RecordType currentRecordType : mapAccountRoleDetailAssignmentRtsById.values()) {
				String rtDevNameLC = currentRecordType.DeveloperName.toLowerCase();

				if (mapCategoriesByRecordTypeDevName.containsKey(rtDevNameLC)) {
					Map<String, Object> currentCapatibility = new Map<String, Object>();
					currentCapatibility.put('name', rtDevNameLC);
					currentCapatibility.put('label', currentRecordType.Name);
					currentCapatibility.put('check_summary', true);
					currentCapatibility.put('check_detail', true);
					currentCapatibility.put('show_summary', true);
					currentCapatibility.put('show_detail', true);
					currentCapatibility.put('first_load_check', true);
					currentCapatibility.put('show_capability', true);
					currentCapatibility.put('categories', new List<Map<String, Object>>());
					currentCapatibility.put('summary', new List<Map<String, Object>>());
					currentCapatibility.put('containsData', false);

					// Categories
					for (String currentCategory : mapCategoriesByRecordTypeDevName.get(rtDevNameLC)) {
						if (mapCategories.containsKey(currentCategory.toLowerCase()) && categoriesToRetrieve.contains(currentCategory.toLowerCase())) {
							// Check if the current category needs a specific processing
							String auxType = '';
							for (String currentKey : mapEquipmentValuesBySpecificProcessing.keySet()) {
								if (String.isBlank(auxType) && mapEquipmentValuesBySpecificProcessing.get(currentKey).contains(mapCategories.get(currentCategory.toLowerCase()).getValue().toLowerCase())) {
									auxType = currentKey.toLowerCase();
								}
							}

							((List<Object>) currentCapatibility.get('categories')).add(new Map<String, Object>{ 'value' => mapCategories.get(currentCategory).getValue(), 'label' => mapCategories.get(currentCategory).getLabel(), 'auxType' => auxType, 'rows' => new List<Map<String, Object>>(), 'hasRows' => false });
						}
					}

					// Summary fields
					for (String currentCategory : mapCategoriesByRecordTypeDevName.get(rtDevNameLC)) {
						if (categoriesToRetrieve.contains(currentCategory)) {
							if (equipmentsByCategory.containsKey(currentCategory.toLowerCase())) {
								for (Map<String, Object> currentEquipment : equipmentsByCategory.get(currentCategory.toLowerCase())) {
									((List<Map<String, Object>>) currentCapatibility.get('summary')).add(new Map<String, Object>{ 'value' => ((String) currentEquipment.get('value')).toLowerCase(), 'label' => currentEquipment.get('label'), 'contains' => false });
								}
							}
						}
					}

					((List<Object>) rawData.get('capabilities')).add(currentCapatibility);
				}
			}

			//List Categories includes
			Set<String> listSectionsIncluded = new Set<String>();

			// Schemas to validity fields
			Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Account_Role_Detail_Capability__c.fields.getMap();

			Map<Id, List<Map<String, Object>>> certificationsByCapabilityId = new Map<Id, List<Map<String, Object>>>();
			CW_FacilityCapabilitiesController.SectionsWrapper checksMap;

			// Retrieve all the assignments
			List<ICG_Account_Role_Capability_Assignment__c> assignments = getAssignmentsByAccountRoleDetailAndRts(accountRoleDetailFound.Id, new List<Id>(mapAccountRoleDetailAssignmentRtsById.keySet()), categoriesToRetrieve, CW_FacilityCapabilitiesController.validateFieldsOfObject('Account_Role_Detail_Capability__c', fieldsToRetrieve, fieldsMap), certificationId, isCapabCertiMode);

			// Loop assignments to get certifications
			for (ICG_Account_Role_Capability_Assignment__c currentAssignment : assignments) {
				if (currentAssignment.ICG_Capability_Assignment_Group__r != null) {
					ICG_Capability_Assignment_Group__c currentGroup = currentAssignment.ICG_Capability_Assignment_Group__r;

					if (!certificationsByCapabilityId.containsKey(currentAssignment.Account_Role_Detail_Capability__c)) {
						certificationsByCapabilityId.put(currentAssignment.Account_Role_Detail_Capability__c, new List<Map<String, Object>>());
					}

					Map<String, Object> certToAdd = new Map<String, Object>{ 'id' => currentGroup.Id, 'name' => 'Remote Validation', 'expirationDate' => currentGroup.Expiration_Date__c, 'issueDate' => currentGroup.Issue_Date__c, 'src' => '/resource/ICG_Resources/icons/remote_validation_icon.svg', 'order' => 99 };
					if (currentGroup.ICG_Certification__c != null) {
						certToAdd.put('order', currentGroup.ICG_Certification__r.Order__c);
						certToAdd.put('name', currentGroup.ICG_Certification__r.Name);
						certToAdd.put('src', currentGroup.ICG_Certification__r.Image__c);
					}

					if (certificationsByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c).size() > 0) {
						integer size = certificationsByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c).size();
						integer i = 0;
						integer position = 0;

						for (Map<String, Object> elem : certificationsByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c)) {
							if ((Decimal) certToAdd.get('order') < (Decimal) elem.get('order')) {
								position = i;
								break;
							}
							i++;
						}

						List<Map<String, Object>> auxList = new List<Map<String, Object>>();
						for (integer j = position; j < size; j++) {
							auxList.add(certificationsByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c).remove(j));
						}
						certificationsByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c).add(certToAdd);

						for (Map<String, Object> aux : auxList) {
							certificationsByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c).add(aux);
						}
					} else {
						certificationsByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c).add(certToAdd);
					}
				}
			}

			// Loop assignments and fill the output data model
			for (ICG_Account_Role_Capability_Assignment__c currentAssignment : assignments) {
				// Populate data for Account_Role_Detail_Capability__c
				Account_Role_Detail_Capability__c currentDetail = currentAssignment.Account_Role_Detail_Capability__r;

				listSectionsIncluded.add(mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName);

				String rtDevNameLC = mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName.toLowerCase();
				if (mapCategoriesByRecordTypeDevName.containsKey(rtDevNameLC)) {
					// We look for the Capability, Category to which it belongs
					Map<String, Object> capabilityFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) rawData.get('capabilities'), 'name', rtDevNameLC);
					Map<String, Object> categoryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get('categories'), 'value', currentDetail.Category__c);

					Boolean isMultiRecordCapabilities = ESPECIAL_CATEGORIES.get('Multi_Record_Capabilities').contains(currentDetail.Category__c.toLowerCase()) ? true : false;

					capabilityFound.put('rtypeId', currentDetail.RecordTypeId);

					if (currentAssignment.ICG_Account_Role_Detail__r.Summary_Detail_Check_JSON__c != null) {
						checksMap = (CW_FacilityCapabilitiesController.SectionsWrapper) JSON.deserialize(currentAssignment.ICG_Account_Role_Detail__r.Summary_Detail_Check_JSON__c, CW_FacilityCapabilitiesController.SectionsWrapper.class);
					}

					if ((Boolean) capabilityFound.get('containsData') == false) {
						capabilityFound.put('containsData', true);
					}

					if (capabilityFound != null && !capabilityFound.containsKey('columns')) {
						List<String> columns = mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase());

						if (columns.contains('number__c') && isMultiRecordCapabilities) {
							columns.remove(columns.indexOf('number__c'));
						}

						if (columns != null && categoryFound != null) {
							categoryFound.put('columns', CW_FacilityCapabilitiesController.getColumnsByRtAndGroup(currentDetail, columns, mapFieldsByGroupField));
						}
					}

					if (categoryFound != null && (Boolean) categoryFound.get('hasRows') == false) {
						categoryFound.put('hasRows', true);
					}

					categoryFound.put('isMultirecord', isMultiRecordCapabilities);

					if (categoryFound != null && categoryFound.containsKey('rows')) {
						List<Object> capabilityGroupRowsFound = (List<Object>) categoryFound.get('rows');

						Boolean capabilityAdded = false;
						for (Map<String, Object> currentCapabilityGroupRow : (List<Map<String, Object>>) capabilityGroupRowsFound) {
							if (!capabilityAdded && currentCapabilityGroupRow.get('id') == currentDetail.Id) {
								capabilityAdded = true;
							}
						}
						if (!capabilityAdded) {
							// Set data for summary
							Map<String, Object> capabilitySummaryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get('summary'), 'value', currentDetail.Equipment__c.toLowerCase());
							if (capabilitySummaryFound != null && (Boolean) capabilitySummaryFound.get('contains') == false) {
								capabilitySummaryFound.put('contains', true);
							}

							Map<String, Object> currentObject = convertCapabilityAssignmentToObject(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);

							List<String> requiredFields = getRequiredFieldsForCapability(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
							currentObject.put('requiredFields', requiredFields);

							// Set processed info.
							currentObject.put('id', currentDetail.Id);
							currentObject.put('equipment__c', mapEquipments.get(currentDetail.Equipment__c.toLowerCase()).getLabel());
							currentObject.put('equipment_value', currentDetail.Equipment__c);
							if (certificationsByCapabilityId.containsKey(currentDetail.Id)) {
								currentObject.put('certifications', certificationsByCapabilityId.get(currentDetail.Id));

								currentObject.put('isPeviouslyCertified', true);
							}

							// Set tooltips
							Map<String, String> tooltips = new Map<String, String>();
							for (String tooltipFieldKey : mapTooltipFieldsByField.keySet()) {
								tooltipFieldKey = tooltipFieldKey.toLowerCase();
								if (currentObject.containsKey(tooltipFieldKey)) {
									String tooltip = '';
									for (String tooltipField : mapTooltipFieldsByField.get(tooltipFieldKey)) {
										tooltip += currentDetail.get(tooltipField);
									}
									tooltips.put(tooltipFieldKey, tooltip);
								}
							}
							currentObject.put('tooltips', (tooltips.size() > 0) ? tooltips : null);

							if (String.isBlank(currentDetail.Photos__c)) {
								currentDetail.Photos__c = JSON.serialize(new List<Map<String, Object>>());
							}
							try {
								currentObject.put('photos', JSON.deserializeUntyped(currentDetail.Photos__c));
							} catch (Exception e_photos) {
								currentDetail.Photos__c = JSON.serialize(new List<Map<String, Object>>());
								currentObject.put('photos', JSON.deserializeUntyped(currentDetail.Photos__c));
							}
							if (currentAssignment.ICG_Capability_Assignment_Group__r.RecordTypeId == RT_REMOTE_VALIDATION) {
								currentObject.put('remotevalidation', true);
							} else {
								currentObject.put('remotevalidation', false);
							}
							currentObject.put('photosAvailable', ((String) currentDetail.Photos__c).remove(' ').toLowerCase().countMatches('"visible":true') > 0);

							currentObject.put('customClass', '');

							currentObject.put('isAssigned', false);

							currentObject.put('isNotEditable', true);

							currentObject.put('isAditional', false);

							currentObject.put('isMultirecord', isMultiRecordCapabilities);

							capabilityGroupRowsFound.add(currentObject);
						}
					}
				}
			}

			if(certificationId != null && !isCapabCertiMode){
			//Read Certification Capabilities by certification id filtering by AccountRoleAssigment
			List<ICG_Certification_Capability_Assignment__c> capabAssigment = getCapabilitiesAssigmentForAccountRoleCapabAssigment(id, assignments, certificationId);

			//Read Account Capabilities by Certification Capabilities
			List<Account_Role_Detail_Capability__c> accountCapabCerti = getSchemaCapabilitiesForMetadataCapabilities(capabAssigment, mapFieldsByRecordTypeAndCategory, mapRecordTypeIdByCategory);

			//Loop for all Account Capabilities previous
			for (Account_Role_Detail_Capability__c currentDetail : accountCapabCerti) {
				listSectionsIncluded.add(mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName);

				String rtDevNameLC = mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName.toLowerCase();
				if (mapCategoriesByRecordTypeDevName.containsKey(rtDevNameLC)) {
					// We look for the Capability, Category to which it belongs
					Map<String, Object> capabilityFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) rawData.get('capabilities'), 'name', rtDevNameLC);
					Map<String, Object> categoryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get('categories'), 'value', currentDetail.Category__c);

					Boolean isMultiRecordCapabilities = ESPECIAL_CATEGORIES.get('Multi_Record_Capabilities').contains(currentDetail.Category__c.toLowerCase()) ? true : false;

					capabilityFound.put('rtypeId', currentDetail.RecordTypeId);

					if ((Boolean) capabilityFound.get('containsData') == false) {
						capabilityFound.put('containsData', true);
					}

					if (capabilityFound != null && !capabilityFound.containsKey('columns')) {
						List<String> columns = mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase());

						if (columns.contains('tcha_temperature_range__c')) {
							columns.remove(columns.indexOf('tcha_temperature_range__c'));
						}

						if (columns.contains('number__c') && isMultiRecordCapabilities) {
							columns.remove(columns.indexOf('number__c'));
						}

						if (columns != null && categoryFound != null) {
							categoryFound.put('columns', CW_FacilityCapabilitiesController.getColumnsByRtAndGroup(currentDetail, columns, mapFieldsByGroupField));
						}
					}

					if (categoryFound != null && (Boolean) categoryFound.get('hasRows') == false) {
						categoryFound.put('hasRows', true);
					}

					categoryFound.put('isMultirecord', isMultiRecordCapabilities);

					Map<String, Object> currentObject;
					if (categoryFound != null && categoryFound.containsKey('rows')) {
						List<Object> capabilityGroupRowsFound = (List<Object>) categoryFound.get('rows');

						// Set data for summary
						Map<String, Object> capabilitySummaryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get('summary'), 'value', currentDetail.Equipment__c.toLowerCase());
						if (capabilitySummaryFound != null && (Boolean) capabilitySummaryFound.get('contains') == false) {
							capabilitySummaryFound.put('contains', true);
						}

						//Map<String, Object> currentObject = CW_FacilityCapabilitiesController.convertCapabilityAssignmentToObject(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
						currentObject = cleanCapabilitiesFieldsToObject(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);

						List<String> requiredFields = getRequiredFieldsForCapability(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
						currentObject.put('requiredFields', requiredFields);

						// Set processed info.
						currentObject.put('id', '');
						currentObject.put('equipment__c', mapEquipments.get(currentDetail.Equipment__c.toLowerCase()).getLabel());
						currentObject.put('equipment_value', currentDetail.Equipment__c);
						currentObject.put('certifications', new List<Map<String, Object>>());
						currentObject.put('isPeviouslyCertified', false);

						// Set tooltips
						Map<String, String> tooltips = new Map<String, String>();
						for (String tooltipFieldKey : mapTooltipFieldsByField.keySet()) {
							tooltipFieldKey = tooltipFieldKey.toLowerCase();
							if (currentObject.containsKey(tooltipFieldKey)) {
								String tooltip = '';
								for (String tooltipField : mapTooltipFieldsByField.get(tooltipFieldKey)) {
									tooltip += currentDetail.get(tooltipField);
								}
								tooltips.put(tooltipFieldKey, tooltip);
							}
						}
						currentObject.put('tooltips', (tooltips.size() > 0) ? tooltips : null);

						if (String.isBlank(currentDetail.Photos__c)) {
							currentDetail.Photos__c = JSON.serialize(new List<Map<String, Object>>());
						}
						try {
							currentObject.put('photos', JSON.deserializeUntyped(currentDetail.Photos__c));
						} catch (Exception e_photos) {
							currentDetail.Photos__c = JSON.serialize(new List<Map<String, Object>>());
							currentObject.put('photos', JSON.deserializeUntyped(currentDetail.Photos__c));
						}

						currentObject.put('remotevalidation', false);

						currentObject.put('photosAvailable', ((String) currentDetail.Photos__c).remove(' ').toLowerCase().countMatches('"visible":true') > 0);

						currentObject.put('customClass', '');

						currentObject.put('isAssigned', false);

						currentObject.put('isNotEditable', true);

						currentObject.put('isAditional', false);

						currentObject.put('isMultirecord', isMultiRecordCapabilities);

						capabilityGroupRowsFound.add(currentObject);
					}
					categoryFound.put('templateFields', currentObject);
				}
			}

			}
			String userRoleAux = CW_Utilities.getUserRole(id);
			Boolean editModeAux = userRoleAux == 'Company Admin' || userRoleAux == 'Facility Manager';

			// Reorganice data in Super Categories and Sections
			List<Map<String, Object>> superCategories = (List<Map<String, Object>>) returnValue.get('superCategories');

			for (Map<String, Object> currentSuperCategory : CW_FacilityCapabilitiesController.getMapSectionsBySupercategory()) {
				Map<String, Object> currentSuperCategoryMap = new Map<String, Object>{ 'label' => currentSuperCategory.get('label'), 'order' => currentSuperCategory.get('order'), 'sections' => new List<Object>(), 'categoriesAvailables' => 0, 'containsData' => false };
				List<String> sectionsInCurrentSuperCategory = (List<String>) currentSuperCategory.get('sections');
				Boolean containDataSuperCategory = false;

				// Order capabilities by section
				List<Map<String, Object>> currentSections = new List<Map<String, Object>>();
				List<Map<String, Object>> mapRecordTypesBySection = CW_FacilityCapabilitiesController.getMapRecordTypesBySection();
				for (Map<String, Object> cSection : mapRecordTypesBySection) {
					Boolean includeSection = sectionsInCurrentSuperCategory.contains((String) cSection.get('label'));

					if (includeSection) {
						Boolean containDataSection = false;
						for (String currentRecordType : (List<String>) cSection.get('rts')) {
							Map<String, Object> capabilityFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) rawData.get('capabilities'), 'name', currentRecordType.toLowerCase());
							if (capabilityFound != null) {
								if (checksMap != null) {
									String nameAux = (String) capabilityFound.get('name');
									CW_FacilityCapabilitiesController.ChecksWrapper checkWrapperAux = checksMap.capabilitiesMap.get(nameAux);
									if (checkWrapperAux != null) {
										capabilityFound.put('check_summary', checkWrapperAux.summary);
										capabilityFound.put('check_detail', checkWrapperAux.detail);
										capabilityFound.put('show_summary', editModeAux ? editModeAux : checkWrapperAux.summary);
										capabilityFound.put('show_detail', editModeAux ? editModeAux : checkWrapperAux.detail);
										capabilityFound.put('show_capability', editModeAux ? editModeAux : checkWrapperAux.summary || checkWrapperAux.detail);
									}
								}

								Map<String, Object> currentSectionObject = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap(currentSections, 'label', (String) cSection.get('label'));
								if (currentSectionObject == null) {
									currentSectionObject = new Map<String, Object>{ 'label' => (String) cSection.get('label'), 'capabilities' => new List<Map<String, Object>>(), 'containsData' => false };
									currentSections.add(currentSectionObject);
								}
								if (listSectionsIncluded.contains(currentRecordType)) {
									containDataSection = true;
									containDataSuperCategory = true;
								}

								((List<Map<String, Object>>) currentSectionObject.get('capabilities')).add(capabilityFound);

								currentSuperCategoryMap.put('categoriesAvailables', ((Integer) currentSuperCategoryMap.get('categoriesAvailables') + ((List<Object>) capabilityFound.get('categories')).size()));
							}
						}
						//If it contains any sections from a capability
						if (containDataSection) {
							currentSections.get(currentSections.indexOf((Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap(currentSections, 'label', (String) cSection.get('label')))).put('containsData', true);
						}
					}
				}
				if (((Integer) currentSuperCategoryMap.get('categoriesAvailables')) > 0) {
					if (containDataSuperCategory) {
						currentSuperCategoryMap.put('containsData', true);
					}
					currentSuperCategoryMap.put('sections', currentSections);
					superCategories.add(currentSuperCategoryMap);
				}
			}
		} catch (Exception e) {
			returnValue.put('e_getMessage', e.getMessage());
			returnValue.put('e_getStackTraceString', e.getStackTraceString());
			//system.debug('ERROR:'+e.getMessage());
		}

		return returnValue;
	}

	public static Map<String, Object> convertCapabilityAssignmentToObject(Account_Role_Detail_Capability__c itemToConvert, List<String> fieldsToGet, Map<String, Schema.SObjectField> fieldsMap) {
		Map<String, Object> convertedItem = new Map<String, Object>();
		if (fieldsToGet != null) {
			for (String currentField : fieldsToGet) {
				try {
					DescribeFieldResult fieldDescribe = fieldsMap.get(currentField).getDescribe();
					switch on fieldDescribe.getType().name() {
						when 'MULTIPICKLIST' {
                            List<String> values = new List<String>();
                            List<String> valuesParsed = new List<String>();
                            if (String.isNotBlank(((String) itemToConvert.get(currentField)))) {
                                values = ((String) itemToConvert.get(currentField)).split(';');
                                
                                for(String val : values){
                                    for( Schema.PicklistEntry pickListVal : fieldDescribe.getPicklistValues()){
                                        if(pickListVal.getLabel().equals(val)){
                                            valuesParsed.add(pickListVal.getValue());
                                        }
                                    }
                                    
                                }
                                
                            }
							convertedItem.put(currentField, valuesParsed);
						}
                        when 'PICKLIST' {
                            for( Schema.PicklistEntry pickListVal : fieldDescribe.getPicklistValues()){
                                if(pickListVal.getLabel().equals(itemToConvert.get(currentField))){
                                    convertedItem.put(currentField, pickListVal.getValue());
                                }
							}
						}
						when else {
							convertedItem.put(currentField, itemToConvert.get(currentField));
						}
					}
				} catch (Exception e) {
					convertedItem.put(currentField, 'NOT EXIST');
				}
			}
		}
		return convertedItem;
	}

	/**
	 * @description	Clean field to Account_Role_Detail_Capability__c pass from param
	 * @param			Account_Role_Detail_Capability__c itemToConvert, List<String> fieldsToGet, Map<String, Schema.SObjectField> fieldsMap
	 * @return			Map<String, Object> with the fields empty to the account role detail capab pass from param
	 */
	public static Map<String, Object> cleanCapabilitiesFieldsToObject(Account_Role_Detail_Capability__c itemToConvert, List<String> fieldsToGet, Map<String, Schema.SObjectField> fieldsMap) {
		Map<String, Object> convertedItem = new Map<String, Object>();
		if (fieldsToGet != null) {
			for (String currentField : fieldsToGet) {
				try {
					DescribeFieldResult fieldDescribe = fieldsMap.get(currentField).getDescribe();
					Schema.DisplayType fldType = fieldDescribe.getType();

					if (fldType == Schema.DisplayType.BOOLEAN) {
						convertedItem.put(currentField, false);
					} else if (fldType == Schema.DisplayType.INTEGER || fldType == Schema.DisplayType.DOUBLE) {
						convertedItem.put(currentField, 0);
					} else {
						convertedItem.put(currentField, null);
					}
				} catch (Exception e) {
					convertedItem.put(currentField, 'NOT EXIST');
				}
			}
		}
		return convertedItem;
	}

	/**
	 * @description	Get required fields to Account_Role_Detail_Capability__c pass from param
	 * @param			Account_Role_Detail_Capability__c itemToConvert, List<String> fieldsToGet, Map<String, Schema.SObjectField> fieldsMap
	 * @return			List<String> with the required fields to the account role detail capab pass from param
	 */
	public static List<String> getRequiredFieldsForCapability(Account_Role_Detail_Capability__c itemToConvert, List<String> fieldsToGet, Map<String, Schema.SObjectField> fieldsMap) {
		List<String> requiredList = new List<String>();
		if (fieldsToGet != null) {
			for (String currentField : fieldsToGet) {
				DescribeFieldResult fieldDescribe = fieldsMap.get(currentField).getDescribe();
				Schema.DisplayType fldType = fieldDescribe.getType();

				if (fldType != Schema.DisplayType.BOOLEAN) {
					requiredList.add(currentField);
				}
			}
		}
		return requiredList;
	}

	/**
	 * @description	Get List<ICG_Account_Role_Capability_Assignment__c> with ICG_Account_Role_Capability_Assignment__c filtered by account role detail Id, Rtype list, Category list, AccountRoleDetailCapabilities fields and certification id
	 * @param			id - Account Role Detail, recordTypesId - record types list, categoriesToRetrieve - categories list, accountRoleDetailCapabilityFields - fields list, certificationId - id certification
	 * @return			List<ICG_Account_Role_Capability_Assignment__c> with the result of param filtered
	 */
	public static List<ICG_Account_Role_Capability_Assignment__c> getAssignmentsByAccountRoleDetailAndRts(Id ardId, List<Id> recordTypesId, List<String> categoriesToRetrieve, List<String> accountRoleDetailCapabilityFields, String certificationId, Boolean isCapabCertiMode) {
		List<ICG_Account_Role_Capability_Assignment__c> returnValue = new List<ICG_Account_Role_Capability_Assignment__c>();
		if (String.isNotBlank(ardId) && recordTypesId != null && recordTypesId.size() > 0 && accountRoleDetailCapabilityFields != null && accountRoleDetailCapabilityFields.size() > 0) {
			List<String> fieldsToRetrieve = new List<String>();
			List<ICG_Certification_Capability_Assignment__c> certiListCapabAssigment = new List<ICG_Certification_Capability_Assignment__c>();
			if(certificationId != null && !isCapabCertiMode){
				certiListCapabAssigment = getCertificationCapabilities(certificationId);
			}			

			final String arDetailR = 'ICG_Account_Role_Detail__r';
			final String ardCapabilityR = 'Account_Role_Detail_Capability__r';
			final String caGroupR = 'ICG_Capability_Assignment_Group__r';
			final String certificationR = 'ICG_Certification__r';

			// Fields related to Account Role Detail
			fieldsToRetrieve.addAll(new List<String>{ arDetailR + '.Id', ardCapabilityR + '.RecordTypeId', caGroupR + '.RecordTypeId', arDetailR + '.Name', ardCapabilityR + '.Category__c', ardCapabilityR + '.Photos__c', arDetailR + '.Summary_Detail_Check_JSON__c' });
			for (String currentField : accountRoleDetailCapabilityFields) {
				Boolean includesToLabel = currentField.toLowerCase().startsWith('tolabel(');
				if (includesToLabel) {
					currentField = currentField.replace('toLabel(', '').replace(')', '');
				}
				String fullCurrentField = ardCapabilityR + '.' + currentField;
				if (includesToLabel) {
					fullCurrentField = 'toLabel(' + fullCurrentField + ')';
				}

				if (!fieldsToRetrieve.contains(fullCurrentField)) {
					fieldsToRetrieve.add(fullCurrentField);
				}
			}

			Set<String> categoriesInput = new Set<String>();
			Set<String> equipmentsInput = new Set<String>();
			String categories = '\'\'';
			String equipments = '\'\'';

			if (certiListCapabAssigment.Size() > 0) {
				categories = '';
				equipments = '';

				//Categories and Equipment related to Certification
				for (ICG_Certification_Capability_Assignment__c certicassgm : certiListCapabAssigment) {
					categoriesInput.add(certicassgm.Category__c);
					equipmentsInput.add(certicassgm.Equipment__c);
				}

				for (String c : categoriesInput) {
					categories += '\'' + c + '\'' + ',';
				}
				categories = categories.substring(0, (categories.length() - 1));

				for (String e : equipmentsInput) {
					equipments += '\'' + e + '\'' + ',';
				}
				equipments = equipments.substring(0, (equipments.length() - 1));
			}

			String filterByCertificationOnly;
			if(isCapabCertiMode){
				filterByCertificationOnly = caGroupR + '.' + certificationR +'.Id =\'' + certificationId + '\' AND ';
			}
			
			// Fields related to Certifications
			fieldsToRetrieve.addAll(new List<String>{ caGroupR + '.Id', caGroupR + '.Expiration_Date__c', caGroupR + '.Issue_Date__c', caGroupR + '.' + certificationR + '.Name', caGroupR + '.' + certificationR + '.Image__c', caGroupR + '.' + certificationR + '.Order__c' });
			String query;
			if(certificationId != null){
                //if read only the capabilities from certi 
                if(isCapabCertiMode){
                    	query = 'SELECT Id, ' + String.join(fieldsToRetrieve, ', ') + ' FROM ICG_Account_Role_Capability_Assignment__c ' + ' WHERE Deprecated__c = false AND ' + filterByCertificationOnly + caGroupR + '.Expiration_Date__c >= TODAY AND ' + arDetailR + '.Id = \'' + ardId + '\' ' + ' AND ' + ardCapabilityR + '.RecordTypeId IN (\'' + String.join((recordTypesId), '\', \'') + '\')' + ' AND ' + ardCapabilityR + '.Category__c IN (\'' + String.join(categoriesToRetrieve, '\', \'') + '\') order by ICG_Capability_Assignment_Group__r.ICG_Certification__r.Order__c';
                }//if read capab depend of object certification capab assigment
                else{
                    query = 'SELECT Id, ' + String.join(fieldsToRetrieve, ', ') + ' FROM ICG_Account_Role_Capability_Assignment__c ' + 'WHERE Deprecated__c = false AND '  + caGroupR + '.Expiration_Date__c >= TODAY AND ' + arDetailR + '.Id =\'' + ardId + '\' AND ' + ardCapabilityR + '.RecordTypeId IN (\'' + String.join((recordTypesId), '\', \'') + '\')' + ' AND ' + ardCapabilityR + '.Category__c IN (' + categories + ')' + ' AND ' + ardCapabilityR + '.Equipment__c IN (' + equipments + ') order by ICG_Capability_Assignment_Group__r.ICG_Certification__r.Order__c';
                }
			}
			else{//if read all capabilities from station
				query = 'SELECT Id, ' + String.join(fieldsToRetrieve, ', ') + ' FROM ICG_Account_Role_Capability_Assignment__c ' + ' WHERE Deprecated__c = false AND ' + caGroupR + '.Expiration_Date__c >= TODAY AND ' + arDetailR + '.Id = \'' + ardId + '\' ' + ' AND ' + ardCapabilityR + '.RecordTypeId IN (\'' + String.join((recordTypesId), '\', \'') + '\')' + ' AND ' + ardCapabilityR + '.Category__c IN (\'' + String.join(categoriesToRetrieve, '\', \'') + '\') order by ICG_Capability_Assignment_Group__r.ICG_Certification__r.Order__c';
			}
			returnValue = (List<ICG_Account_Role_Capability_Assignment__c>) Database.query(query);
		}

		return returnValue;
	}

	/**
	 * @description	Get List<ICG_Certification_Capability_Assignment__c> with List<ICG_Certification_Capability_Assignment__c> filtered by account role detail Id, List<ICG_Account_Role_Capability_Assignment__c> and certification id
	 * @param			id - Account Role Detail,assigments- List<ICG_Account_Role_Capability_Assignment__c> and certificationId - id certification
	 * @return			List<ICG_Certification_Capability_Assignment__c> with the result of param filtered
	 */
	private static List<ICG_Certification_Capability_Assignment__c> getCapabilitiesAssigmentForAccountRoleCapabAssigment(Id ardId, List<ICG_Account_Role_Capability_Assignment__c> assigments, String certificationId) {
		Set<String> equipment = new Set<String>();

		if (assigments.Size() > 0) {
			for (ICG_Account_Role_Capability_Assignment__c arcassgm : assigments) {
				if (!ESPECIAL_CATEGORIES.get('Multi_Record_Capabilities').contains(arcassgm.Account_Role_Detail_Capability__r.Category__c.toLowerCase())) {
					equipment.add(arcassgm.Account_Role_Detail_Capability__r.Equipment__c);
				}
			}
		}

		List<ICG_Certification_Capability_Assignment__c> returnList = [SELECT id, Category__c, Equipment__c, ICG_Certification__r.Name, ICG_Certification__r.Image__c FROM ICG_Certification_Capability_Assignment__c WHERE ICG_Certification__c = :certificationId AND Equipment__c NOT IN :equipment];
		return returnList;
	}

	/**
	 * @description	Get List<Account_Role_Detail_Capability__c> with List<Account_Role_Detail_Capability__c>
	 * @param
	 * @return			List<Account_Role_Detail_Capability__c> with las capabilities that are not in the categories of assigments registers
	 */
	private static List<Account_Role_Detail_Capability__c> getSchemaCapabilitiesForMetadataCapabilities(List<ICG_Certification_Capability_Assignment__c> certicapabassigment, Map<String, List<String>> mapFieldsByRecordTypeAndCategory, Map<String, String> mapRecordTypeIdByCategory) {
		Set<String> categoriesInput = new Set<String>();
		Set<String> equipmentsInput = new Set<String>();
		List<String> fieldsToRetrieve = new List<String>();
		List<String> fieldsAccCapabToRetrieve = new List<String>{ 'RecordTypeId', 'Category__c', 'Photos__c' };
		List<Account_Role_Detail_Capability__c> returnValue = new List<Account_Role_Detail_Capability__c>();

		if (certicapabassigment.Size() > 0) {
			for (ICG_Certification_Capability_Assignment__c certicassgm : certicapabassigment) {
				categoriesInput.add(certicassgm.Category__c);
				equipmentsInput.add(certicassgm.Equipment__c);

				returnValue.add(new Account_Role_Detail_Capability__c(RecordTypeId = mapRecordTypeIdByCategory.get(certicassgm.Category__c.toLowerCase()), Category__c = certicassgm.Category__c, Equipment__c = certicassgm.Equipment__c, Photos__c = ''));
			}
		}
		return returnValue;
	}

	/**
	 * @description		update capabilities list
	 * @param			listAddeRows - Acc Role Det Capab
	 * @return			json - result (success,message)
	 */
	@AuraEnabled
	public static String updateCapabilitiesEdited(List<Object> listAddedRows) {
		ResponseBody res = new ResponseBody();
			try {
				//creation records capabilities
				createCapabilities(listAddedRows, true);
				res.success = true;
			} catch (Exception e) {
				res.success = false;
				res.message = e.getMessage();
			}

		return JSON.serialize(res);
	}

	/**
	 * @description		create relationships for new capabilities certifications
	 * @param			ardCertId - Account Role Detail Certi Id
	 * @return			ICG_Capability_Assignment_Group__c Id
	 */
	@AuraEnabled
	public static String createRelationshipsForNewCapabilities(String accRoleDet, String ardCertId, List<Object> listAddedRows) {
		ResponseBody res = new ResponseBody();
		List<Account_Role_Detail_Capability__c> listAccRoleCapabInserted;

		if (!String.isBlank(ardCertId)) {
			try {
				//creation records capabilities
				listAccRoleCapabInserted = createCapabilities(listAddedRows,false);

				//creation records union AccRoleCapabAssigment for Capability
				res.success = assignCapabilityAndGroup(accRoleDet, ardCertId, listAccRoleCapabInserted);

				res.message = ardCertId;
			} catch (Exception e) {
				res.success = false;
				res.message = e.getMessage();
			}
		}

		return JSON.serialize(res);
	}

	/**
	 * @description	Create List<Account_Role_Detail_Capability__c> with the capabilities list passed from param, Boolean if update or not
	 * @param			List<Object(Account_Role_Detail_Capability__c)> capabilitiesList
	 * @return			Boolean with result
	 */
	@AuraEnabled
	public static List<Account_Role_Detail_Capability__c> createCapabilities(List<Object> capabilitiesList, Boolean isUpdate) {
		Map<String, Schema.SObjectField> fieldMapCap = Schema.getGlobalDescribe().get('Account_Role_Detail_Capability__c').getDescribe().fields.getMap();
		List<CapabilityWrapper> listCapWrapper = new List<CapabilityWrapper>();
		List<Account_Role_Detail_Capability__c> listToInsert = new List<Account_Role_Detail_Capability__c>();

		//Extract all capabilities from input
		for (Object capability : capabilitiesList) {
			CapabilityWrapper c = (CapabilityWrapper) JSON.deserialize(JSON.serializePretty(capability), CapabilityWrapper.class);
			listCapWrapper.add(c);
		}

		//Read all capabilities wrapper
		for (CapabilityWrapper c : listCapWrapper) {
			SObject sObj = new Account_Role_Detail_Capability__c();
			if(isUpdate){
				sObj.put('Id', c.id);
			}
			else{
				sObj.put('RecordTypeId', c.rtypeId);
				sObj.put('Category__c', c.category);
				sObj.put('Equipment__c', c.equipment_value);
			}			

			for (CapabilityFieldsWrapper capfield : c.fields) {
				if (!capfield.field.equals('equipment__c')) {
					if (fieldMapCap.containsKey(capfield.field)) {
						Schema.SObjectField fieldSObject = fieldMapCap.get(capfield.field);
						Schema.DisplayType fldType = fieldSObject.getDescribe().getType();

						if (!fieldSObject.getDescribe().isCalculated()) {
							if (fldType == Schema.DisplayType.DATE) {
								if (capfield.value != '') {
									Date dateField = Date.valueOf(capfield.value);
									sObj.put(capfield.field, dateField);
								} else {
									sObj.put(capfield.field, null);
								}
							} else if (fldType == Schema.DisplayType.DOUBLE) {
								if (capfield.value != '') {
									Double decimalFiel = Double.valueOf(capfield.value);
									sObj.put(capfield.field, decimalFiel);
								} else {
									sObj.put(capfield.field, null);
								}
							} else if (fldType == Schema.DisplayType.BOOLEAN) {
								Boolean booleanField = Boolean.valueOf(capfield.value);
								sObj.put(capfield.field, booleanField);
							} else {
								sObj.put(capfield.field, capfield.value);
							}
						}
					}
				}
			}
			Account_Role_Detail_Capability__c parseCapability = (Account_Role_Detail_Capability__c) sObj;
			listToInsert.add(parseCapability);
		}
		if(isUpdate){
			update listToInsert;
		}
		else{
			insert listToInsert;
		}	

		return listToInsert;
	}

	/**
	 * @description		assign Capability with Group
	 * @param			accRoleDet - Account Role Detail Id, accRoleCapabId - Account Role Capab Id, capabAssigmenGroup - Capab Assigment Group and ardCertId - Account Role Detail Certi Id
	 * @return			Boolean true or false
	 */
	private static Boolean assignCapabilityAndGroup(String accRoleDet, String capabAssigmenGroup, List<Account_Role_Detail_Capability__c> listAccRoleCapabId) {
		Boolean result = true;
		List<ICG_Account_Role_Capability_Assignment__c> assigment = new List<ICG_Account_Role_Capability_Assignment__c>();

		if (listAccRoleCapabId.size() > 0 && capabAssigmenGroup != null){
			for (Account_Role_Detail_Capability__c capabToInsert : listAccRoleCapabId) {
				assigment.add(new ICG_Account_Role_Capability_Assignment__c(Account_Role_Detail_Capability__c = capabToInsert.Id, ICG_Capability_Assignment_Group__c = capabAssigmenGroup, ICG_Account_Role_Detail__c = accRoleDet));
			}

			insert assigment;
		}

		return result;
	}

	/**
	 * @description		create public links for photos uploaded
	 * @param			listPhoto - List photos uploaded
	 * @return			JSON result (success, message)
	 */
	@AuraEnabled
	public static String getPublicLinkToFiles(List<Object> listPhoto) {
		ResponseBody res = new ResponseBody();
		List<CapabilityPhoto> capabWraperList = new List<CapabilityPhoto>();
		Set<Id> listContentDocumentId = new Set<Id>();
		List<ContentDocumentLink> listContentDocumentLink;
		List<ContentVersion> listContentVersion;
		List<ContentDistribution> listContentDistribution = new List<ContentDistribution>();

		if (listPhoto.size() > 0) {
			try {
				for (Object capabObj : listPhoto) {
					capabWraperList.add((CapabilityPhoto) JSON.deserialize(JSON.serializePretty(capabObj), CapabilityPhoto.class));
				}

				for (CapabilityPhoto c : capabWraperList) {
					listContentDocumentId.add(c.id); //id contains ContentDocumentId
				}

				//Change Visibility
				listContentDocumentLink = [SELECT Id, ContentDocumentId, Visibility FROM ContentDocumentLink WHERE ContentDocumentId IN :listContentDocumentId];
				for (ContentDocumentLink cLink : listContentDocumentLink) {
					cLink.Visibility = 'AllUsers';
				}
				update listContentDocumentLink;

				//Read ContentVersion
				listContentVersion = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentVersion WHERE ContentDocumentId IN :listContentDocumentId];

				//key = ContentVersion, value = ContentDocumentId
				Map<String, String> mapContentVersionAndDocument = new Map<String, String>();
				for (ContentVersion cv : listContentVersion) {
					listContentDistribution.add(new ContentDistribution(Name = cv.ContentDocument.Title, ContentVersionId = cv.Id, PreferencesAllowViewInBrowser = true, PreferencesLinkLatestVersion = true, PreferencesNotifyOnVisit = false, PreferencesPasswordRequired = false, PreferencesAllowOriginalDownload = true));
					mapContentVersionAndDocument.put(cv.Id, cv.ContentDocumentId);
				}
				insert listContentDistribution;

				List<Id> contentDistributionIds = new List<Id>();
				for (ContentDistribution c : listContentDistribution) {
					contentDistributionIds.add(c.Id);
				}

				List<ContentDistribution> contentDistributionInserted = [SELECT Id, ContentVersionId, DistributionPublicUrl, ContentDownloadURL FROM ContentDistribution WHERE Id IN :contentDistributionIds];

				//key = ContentDocumentId, value = PublicUrl
				Map<String, String> mapContentDocumentAndUrlPublic = new Map<String, String>();
				for (ContentDistribution cd : contentDistributionInserted) {
					mapContentDocumentAndUrlPublic.put(mapContentVersionAndDocument.get(cd.ContentVersionId), cd.ContentDownloadURL);
				}

				//Read DistributionPublicUrl
				for (CapabilityPhoto c : capabWraperList) {
					c.url = mapContentDocumentAndUrlPublic.get(c.id);
				}
				res.success = true;
				res.message = JSON.serialize(capabWraperList);
			} catch (Exception e) {
				res.success = false;
				res.message = e.getMessage();
			}
		}

		return JSON.serialize(res);
	}

	public class CapabilityWrapper {
		public String id;
		public String position;
		public String rtypeId;
		public String category;
		public String equipment_value;
		public String equipment_label;
		public List<CapabilityFieldsWrapper> fields;

		public CapabilityWrapper() {
		}
	}

	public class CapabilityFieldsWrapper {
		public String field;
		public String value;
		public Boolean required;

		public CapabilityFieldsWrapper() {
		}
	}

	public class CapabilityPhoto {
		@AuraEnabled
		public Boolean visible { get; set; }
		@AuraEnabled
		public String url { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String id { get; set; }
	}

	public class ResponseBody {
		public String message { get; set; }
		public Boolean success { get; set; }
	}
}