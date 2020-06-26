public without sharing class CW_FacilityCapabilitiesController {
	final static String MD_CATEGORIES_BY_ACCOUNT_ROLE_DETAIL_RT = 'Categories_By_Account_Role_Detail_Record_Type';
	final static String MD_RTS_BY_SECTION = 'Record_Types_By_Section';
	final static String MD_CATEGORIES_BY_RT = 'Categories_By_Record_Type';
	final static String MD_FIELDS_BY_RT_AND_CATEGORY = 'Fields_By_Record_Type_And_Category';
	final static String MD_GROUPED_FIELDS = 'Grouped_Fields';
	final static String MD_SPECIFIC_PROCESSING = 'Specific_Processing';
	final static String MD_TOOLTIP_FIELDS_BY_FIELD = 'Tooltip_Fields_By_Field';
	final static String MD_CONFIG = 'Config';
	final static String MD_SECTIONS_BY_SUPERCATEGORY = 'Sections_By_Supercategory';
	final static String MD_EDITABLE_RECORDTYPES = 'Editable_RecordTypes';
	final static String SEARCH_ONLY_DATA = 'Data__c';
	final static String SEARCH_WITH_EXTRADATA = 'Extra_Data__c';
	final static String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
	final static String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
	final static String RT_NO_CERTIFICATION_REQUIRED = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'No_Certification_Required');
	final static Map<String, List<String>> ESPECIAL_CATEGORIES = getMapConfig();
	final static Map<String, List<String>> EDITABLE_RECORDTYPES = getMapEditableRecordTypes();

	@auraEnabled(cacheable = true)
	public static Map<String, List<String>> getMapCategoriesByAccountRoleDetailRecordType() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_CATEGORIES_BY_ACCOUNT_ROLE_DETAIL_RT, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	public static List<Map<String, Object>> getMapSectionsBySupercategory() {
		List<Map<String, Object>> output = new List<Map<String, Object>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_SECTIONS_BY_SUPERCATEGORY, SEARCH_ONLY_DATA)) {
			output.add(new Map<String, Object>{ 'order' => currentConfig.Order__c, 'label' => currentConfig.Key__c, 'sections' => (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.split(';') });
		}

		return output;
	}

	public static List<Map<String, Object>> getMapRecordTypesBySection() {
		List<Map<String, Object>> output = new List<Map<String, Object>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_RTS_BY_SECTION, SEARCH_ONLY_DATA)) {
			output.add(new Map<String, Object>{ 'order' => currentConfig.Order__c, 'label' => currentConfig.Key__c, 'rts' => (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.split(';') });
		}

		return output;
	}

	public static Map<String, List<String>> getMapCategoriesByRecordType() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_CATEGORIES_BY_RT, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	public static Map<String, List<String>> getMapFieldsByRecordTypeAndCategory() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_FIELDS_BY_RT_AND_CATEGORY, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	public static Map<String, List<String>> getMapFieldsByExtraDataType() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_FIELDS_BY_RT_AND_CATEGORY, SEARCH_WITH_EXTRADATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Extra_Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	public static Map<String, List<String>> getMapFieldsByGroupField() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_GROUPED_FIELDS, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	public static Map<String, List<String>> getMapEquipmentValuesBySpecificProcessing() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_SPECIFIC_PROCESSING, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	public static Map<String, List<String>> getMapTooltipFieldsByField() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_TOOLTIP_FIELDS_BY_FIELD, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	private static List<ICG_capability_configuration__mdt> getCapabilityConfigurationMetadataByType(String type, String fieldsData) {
		if(fieldsData.equalsIgnoreCase(SEARCH_WITH_EXTRADATA)){
				return [SELECT Key__c, Extra_Data__c, Data__c, Order__c FROM ICG_capability_configuration__mdt WHERE Type__c = :type ORDER BY Order__c ASC, Key__c ASC];
		}
		return [SELECT Key__c, Data__c, Order__c FROM ICG_capability_configuration__mdt WHERE Type__c = :type ORDER BY Order__c ASC, Key__c ASC];	
	}	
	public static Map<String, List<String>> getMapConfig() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_CONFIG)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	public static Map<String, List<String>> getMapEditableRecordTypes() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_EDITABLE_RECORDTYPES)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	public static List<ICG_capability_configuration__mdt> getCapabilityConfigurationMetadataByType(String type) {
		return [SELECT Key__c, Data__c, Order__c FROM ICG_capability_configuration__mdt WHERE Type__c = :type ORDER BY Order__c ASC, Key__c ASC];
	}

	public static Map<String, Id> getRecordTypesIdByCategoryName() {
		Map<String, Id> recordTypesIdByCategoryName = new Map<String, Id>();

		Map<String, Id> recordTypesBySObject = new Map<String, Id>();
		for (RecordType currentRt : RecordTypeSingleton.getInstance().getRecordTypesBySObject('Account_Role_Detail_Capability__c')) {
			recordTypesBySObject.put(currentRt.DeveloperName.toLowerCase(), currentRt.Id);
		}

		Map<String, List<String>> categoriesByRecordType = getMapCategoriesByRecordType();
		for (String currentRt : categoriesByRecordType.keySet()) {
			for (String currentCategory : categoriesByRecordType.get(currentRt)) {
				if (recordTypesBySObject.containsKey(currentRt)) {
					recordTypesIdByCategoryName.put(currentCategory, recordTypesBySObject.get(currentRt));
				}
			}
		}
		return recordTypesIdByCategoryName;
	}

	/**
	 * @description		Get ICG_Account_Role_Capability_Assignment__c filtered by Account Role Detail and Rts
	 * @param			ardId Account Role Detail Id to filter
	 * @param			recordTypesId Account Role Detail Record Type Ids to filter
	 * @param			categoriesToRetrieve Account Role Detail Capability Categories to filter
	 * @param			accountRoleDetailCapabilityFields Fields to retrieve to populate the query
	 * @return			List of <ICG_Account_Role_Capability_Assignment__c>
	 */
	public static List<ICG_Account_Role_Capability_Assignment__c> getAssignmentsByAccountRoleDetailAndRts(Id ardId, List<Id> recordTypesId, List<String> categoriesToRetrieve, List<String> accountRoleDetailCapabilityFields, List<String> capabilitiesIdForConflicts) {
		List<ICG_Account_Role_Capability_Assignment__c> returnValue = new List<ICG_Account_Role_Capability_Assignment__c>();
		if (String.isNotBlank(ardId) && recordTypesId != null && recordTypesId.size() > 0 && accountRoleDetailCapabilityFields != null && accountRoleDetailCapabilityFields.size() > 0) {
			List<String> fieldsToRetrieve = new List<String>();

			final String arDetailR = 'ICG_Account_Role_Detail__r';
			final String ardCapabilityR = 'Account_Role_Detail_Capability__r';
			final String caGroupR = 'ICG_Capability_Assignment_Group__r';
			final String certificationR = 'ICG_Certification__r';

			// Fields related to Account Role Detail
			fieldsToRetrieve.addAll(new List<String>{ arDetailR + '.Id', ardCapabilityR + '.RecordTypeId', caGroupR + '.RecordTypeId', caGroupR + '.RecordType.DeveloperName', arDetailR + '.Name', ardCapabilityR + '.Category__c', ardCapabilityR + '.Photos__c', arDetailR + '.Summary_Detail_Check_JSON__c' });
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

			// Fields related to Certifications
			fieldsToRetrieve.addAll(new List<String>{ caGroupR + '.Id', caGroupR + '.Expiration_Date__c', caGroupR + '.Issue_Date__c', caGroupR + '.' + certificationR + '.Name', caGroupR + '.' + certificationR + '.Image__c', caGroupR + '.' + certificationR + '.Order__c' });

			String optionalFilterConflicts = capabilitiesIdForConflicts == null || capabilitiesIdForConflicts.isEmpty() ? ' AND Is_In_Conflict__c = false' : 'AND ' + ardCapabilityR + '.Id IN (\'' + String.join((capabilitiesIdForConflicts), '\', \'') + '\')';

			String query = 'SELECT Id, ' + String.join(fieldsToRetrieve, ', ') + ' FROM ICG_Account_Role_Capability_Assignment__c ' + ' WHERE Deprecated__c = false ' + optionalFilterConflicts + ' AND ' + caGroupR + '.Expiration_Date__c >= TODAY AND ' + arDetailR + '.Id = \'' + ardId + '\' ' + ' AND ' + ardCapabilityR + '.RecordTypeId IN (\'' + String.join((recordTypesId), '\', \'') + '\')' + ' AND ' + ardCapabilityR + '.Category__c IN (\'' + String.join(categoriesToRetrieve, '\', \'') + '\') ';
			returnValue = (List<ICG_Account_Role_Capability_Assignment__c>) Database.query(query);
		}

		return returnValue;
	}

	@AuraEnabled
	public static Map<String, Object> getCapabilitiesFromAccountRoleDetailId(String id) {
		return getCapabilitiesInternal(id, null);
	}

	@AuraEnabled
	public static Map<String, Object> getCapabilitiesInternal(String id, List<String> capabilitiesIdForConflicts) {
		Map<String, Object> returnValue = new Map<String, Object>{ 'superCategories' => new List<Map<String, Object>>() };

		try {
			Map<String, Object> rawData = new Map<String, Object>{ 'capabilities' => new List<Map<String, Object>>() };

			// Get all record types of Account_Role_Detail_Capability__c configured. If there are no valid record types, we leave.
			Map<String, List<String>> mapCategoriesByRecordTypeDevName = getMapCategoriesByRecordType();
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
			List<String> categoriesToRetrieve = getMapCategoriesByAccountRoleDetailRecordType().get(accountRoleDetailFound.RecordType.DeveloperName.toLowerCase());
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
			Map<String, String> mapRecordTypeIdByCategory = getRecordTypesIdByCategoryName();

			// Get Fields to build the soql query and the tables.
			Map<String, List<String>> mapFieldsByRecordTypeAndCategory = getMapFieldsByRecordTypeAndCategory();
			List<String> fieldsToRetrieve = new List<String>();
			for (List<String> fieldsGroup : mapFieldsByRecordTypeAndCategory.values()) {
				for (String field : fieldsGroup) {
					fieldsToRetrieve.add(field);
				}
			}

			// Get fields to use like a tooltip.
			Map<String, List<String>> mapTooltipFieldsByField = getMapTooltipFieldsByField();
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
			Map<String, List<String>> mapEquipmentValuesBySpecificProcessing = getMapEquipmentValuesBySpecificProcessing();

			// Get grouped fields
			Map<String, List<String>> mapFieldsByGroupField = getMapFieldsByGroupField();

			// Get categoires map
			Map<String, Schema.PicklistEntry> mapCategories = getPicklistEntryMap('Account_Role_Detail_Capability__c', 'Category__c');

			// Get equipments map
			Map<String, Schema.PicklistEntry> mapEquipments = getPicklistEntryMap('Account_Role_Detail_Capability__c', 'Equipment__c');

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
					currentCapatibility.put('isEditableRecordType', EDITABLE_RECORDTYPES.get('Editable_RecordTypes').contains(rtDevNameLC) ? true : false);

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

							((List<Object>) currentCapatibility.get('categories')).add(new Map<String, Object>{ 'value' => mapCategories.get(currentCategory).getValue().toLowerCase(), 'label' => mapCategories.get(currentCategory).getLabel(), 'auxType' => auxType, 'rows' => new List<Map<String, Object>>(), 'hasRows' => false });
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

			Map<Id, List<AsgmtGroupWrapper>> asgmtGroupByCapabilityId = new Map<Id, List<AsgmtGroupWrapper>>();
			SectionsWrapper checksMap;

			// Retrieve all the assignments
			List<ICG_Account_Role_Capability_Assignment__c> assignments = getAssignmentsByAccountRoleDetailAndRts(id, new List<Id>(mapAccountRoleDetailAssignmentRtsById.keySet()), categoriesToRetrieve, validateFieldsOfObject('Account_Role_Detail_Capability__c', fieldsToRetrieve, fieldsMap), capabilitiesIdForConflicts);

			// Loop assignments to get certifications
			for (ICG_Account_Role_Capability_Assignment__c currentAssignment : assignments) {
				if (currentAssignment.ICG_Capability_Assignment_Group__r != null) {
					ICG_Capability_Assignment_Group__c currentGroup = currentAssignment.ICG_Capability_Assignment_Group__r;

					if (!asgmtGroupByCapabilityId.containsKey(currentAssignment.Account_Role_Detail_Capability__c)) {
						asgmtGroupByCapabilityId.put(currentAssignment.Account_Role_Detail_Capability__c, new List<AsgmtGroupWrapper>());
					}
					AsgmtGroupWrapper asgmtGroupToAdd = new AsgmtGroupWrapper();
					asgmtGroupToAdd.id = currentGroup.Id;
					asgmtGroupToAdd.type = currentGroup.RecordType.DeveloperName;
					asgmtGroupToAdd.name = Label.icg_smart_facility_remote_validation;
					asgmtGroupToAdd.expirationDate = currentGroup.Expiration_Date__c;
					asgmtGroupToAdd.issueDate = currentGroup.Issue_Date__c;
					asgmtGroupToAdd.src = '/resource/ICG_Resources/icons/remote_validation_icon.svg';
					if (currentGroup.ICG_Certification__c != null) {
						asgmtGroupToAdd.order = currentGroup.ICG_Certification__r.Order__c;
						asgmtGroupToAdd.name = currentGroup.ICG_Certification__r.Name;
						asgmtGroupToAdd.src = currentGroup.ICG_Certification__r.Image__c;
					}
					if (!currentGroup.RecordTypeId.equals(RT_NO_CERTIFICATION_REQUIRED)) {
						asgmtGroupByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c).add(asgmtGroupToAdd);
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
					Map<String, Object> capabilityFound = (Map<String, Object>) getItemInMap((List<Map<String, Object>>) rawData.get('capabilities'), 'name', rtDevNameLC);
					Map<String, Object> categoryFound = (Map<String, Object>) getItemInMap((List<Map<String, Object>>) capabilityFound.get('categories'), 'value', currentDetail.Category__c);

					capabilityFound.put('rtypeId', currentDetail.RecordTypeId);

					if (currentAssignment.ICG_Account_Role_Detail__r.Summary_Detail_Check_JSON__c != null) {
						checksMap = (SectionsWrapper) JSON.deserialize(currentAssignment.ICG_Account_Role_Detail__r.Summary_Detail_Check_JSON__c, SectionsWrapper.class);
					}

					if ((Boolean) capabilityFound.get('containsData') == false) {
						capabilityFound.put('containsData', true);
					}

					if (capabilityFound != null && !capabilityFound.containsKey('columns')) {
						List<String> columns = mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase());
						if (columns.contains('more_info_document__c')) {
							columns.remove(columns.indexOf('more_info_document__c'));
						}
						// if (columns.contains('crstr_import_export__c')) {
						// 	columns.remove(columns.indexOf('crstr_import_export__c'));
						// }

						if (columns != null && categoryFound != null) {
							categoryFound.put('columns', getColumnsByRtAndGroup(currentDetail, columns, mapFieldsByGroupField));
						}
					}

					if (categoryFound != null && (Boolean) categoryFound.get('hasRows') == false) {
						categoryFound.put('hasRows', true);
					}

					categoryFound.put('isEditableRecordType', EDITABLE_RECORDTYPES.get('Editable_RecordTypes').contains(rtDevNameLC) ? true : false);

					Map<String, Object> currentObject;
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
							Map<String, Object> capabilitySummaryFound = (Map<String, Object>) getItemInMap((List<Map<String, Object>>) capabilityFound.get('summary'), 'value', currentDetail.Equipment__c.toLowerCase());
							if (capabilitySummaryFound != null && (Boolean) capabilitySummaryFound.get('contains') == false) {
								capabilitySummaryFound.put('contains', true);
							}

							currentObject = convertCapabilityAssignmentToObject(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);

							List<String> requiredFields = CW_CapabilitiesManagerController.getRequiredFieldsForCapability(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
							currentObject.put('requiredFields', requiredFields);

							// Set processed info.
							currentObject.put('id', currentDetail.Id);
							currentObject.put('equipment__c', mapEquipments.get(currentDetail.Equipment__c.toLowerCase()).getLabel());
							currentObject.put('equipment_value', currentDetail.Equipment__c);
							if (asgmtGroupByCapabilityId.containsKey(currentDetail.Id)) {
								asgmtGroupByCapabilityId.get(currentDetail.Id).sort();
								currentObject.put('certifications', asgmtGroupByCapabilityId.get(currentDetail.Id));
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
							currentObject.put('isAssigned', true);
							currentObject.put('isNotEditable', true);
							currentObject.put('isAditional', false);

							currentObject.put('isEditableRecordType', EDITABLE_RECORDTYPES.get('Editable_RecordTypes').contains(rtDevNameLC) ? true : false);

							capabilityGroupRowsFound.add(currentObject);
						}
					}
					categoryFound.put('templateFields', currentObject);
				}
			}

			Map<String, List<String>> capabilitiesByRecordTypeNotIncluded = new Map<String, List<String>>();
			for (Map<String, Object> capability : (List<Map<String, Object>>) rawData.get('capabilities')) {

				// if recordtype is editable in private area
				if ((Boolean) capability.get('isEditableRecordType')) {
					capabilitiesByRecordTypeNotIncluded.put((String) capability.get('name'), new List<String>());
					for (Map<String, Object> sum : (List<Map<String, Object>>) capability.get('summary')) {
						if (!(Boolean) sum.get('contains')) {
							capabilitiesByRecordTypeNotIncluded.get((String) capability.get('name')).add((String) sum.get('value'));
						}
					}
				}
			}

			if (capabilitiesByRecordTypeNotIncluded.size() > 0) {
				//Read missing Capabilities by mapRecordTypeIdByCategory
				List<Account_Role_Detail_Capability__c> accountCapabNotInluded = getCapabilitiesNotIncludedDetail(capabilitiesByRecordTypeNotIncluded, mapRecordTypeIdByCategory);

				for (Account_Role_Detail_Capability__c currentDetail : accountCapabNotInluded) {
					listSectionsIncluded.add(mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName);

					String rtDevNameLC = mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName.toLowerCase();
					if (mapCategoriesByRecordTypeDevName.containsKey(rtDevNameLC)) {
						// We look for the Capability, Category to which it belongs
						Map<String, Object> capabilityFound = (Map<String, Object>) getItemInMap((List<Map<String, Object>>) rawData.get('capabilities'), 'name', rtDevNameLC);
						Map<String, Object> categoryFound = (Map<String, Object>) getItemInMap((List<Map<String, Object>>) capabilityFound.get('categories'), 'value', currentDetail.Category__c);

						capabilityFound.put('rtypeId', currentDetail.RecordTypeId);

						if ((Boolean) capabilityFound.get('containsData') == false) {
							capabilityFound.put('containsData', true);
						}

						if (capabilityFound != null && !capabilityFound.containsKey('columns')) {
							List<String> columns = mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase());
							if (columns.contains('more_info_document__c')) {
								columns.remove(columns.indexOf('more_info_document__c'));
							}
							if (columns != null && categoryFound != null) {
								categoryFound.put('columns', getColumnsByRtAndGroup(currentDetail, columns, mapFieldsByGroupField));
							}
						}

						if (categoryFound != null && (Boolean) categoryFound.get('hasRows') == false) {
							categoryFound.put('hasRows', true);
						}

						categoryFound.put('isEditableRecordType', EDITABLE_RECORDTYPES.get('Editable_RecordTypes').contains(rtDevNameLC) ? true : false);

						Map<String, Object> currentObject;
						if (categoryFound != null && categoryFound.containsKey('rows')) {
							List<Object> capabilityGroupRowsFound = (List<Object>) categoryFound.get('rows');

							// Set data for summary
							Map<String, Object> capabilitySummaryFound = (Map<String, Object>) getItemInMap((List<Map<String, Object>>) capabilityFound.get('summary'), 'value', currentDetail.Equipment__c.toLowerCase());
							if (capabilitySummaryFound != null && (Boolean) capabilitySummaryFound.get('contains') == false) {
								capabilitySummaryFound.put('contains', false);
							}

							currentObject = CW_CapabilitiesManagerController.cleanCapabilitiesFieldsToObject(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);

							List<String> requiredFields = CW_CapabilitiesManagerController.getRequiredFieldsForCapability(currentDetail, maPfieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
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

							currentObject.put('isAssigned', false);

							currentObject.put('isNotEditable', true);

							currentObject.put('isAditional', false);

							currentObject.put('isEditableRecordType', EDITABLE_RECORDTYPES.get('Editable_RecordTypes').contains(rtDevNameLC) ? true : false);

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
										capabilityFound.put('show_capability', editModeAux ? editModeAux : checkWrapperAux.summary == true || checkWrapperAux.detail == true);
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
		}

		return returnValue;
	}

	/**
	 * @description	Get List<Account_Role_Detail_Capability__c> with List<Account_Role_Detail_Capability__c>
	 * @param
	 * @return			List<Account_Role_Detail_Capability__c> with las capabilities that are not in the categories of assigments registers
	 */
	private static List<Account_Role_Detail_Capability__c> getCapabilitiesNotIncludedDetail(Map<String, List<String>> mapCapabilitiesNotIncluded, Map<String, String> mapRecordTypeIdByCategory) {
		List<Account_Role_Detail_Capability__c> returnValue = new List<Account_Role_Detail_Capability__c>();

		if (mapCapabilitiesNotIncluded.Size() > 0) {
			for (String capab : mapCapabilitiesNotIncluded.keySet()) {
				for (String equipment : mapCapabilitiesNotIncluded.get(capab)) {
					returnValue.add(new Account_Role_Detail_Capability__c(RecordTypeId = mapRecordTypeIdByCategory.get(capab.toLowerCase()), Category__c = capab, Equipment__c = equipment, Photos__c = ''));
				}
			}
		}
		return returnValue;
	}

	@AuraEnabled
	public static Object setVisibilityPhotos(String id, String photos) {
		Account_Role_Detail_Capability__c dummyUpd = new Account_Role_Detail_Capability__c(Id = (Id) id, Photos__c = photos);

		try {
			update dummyUpd;
			return JSON.deserializeUntyped(dummyUpd.Photos__c);
		} catch (Exception e) {
			return e.getMessage();
		}
	}

	@AuraEnabled(cacheable=true)
	public static Object getComparisonSchema(String accountRoleDetailRT) {
		Map<String, Object> returnValue = new Map<String, Object>();
		List<ComparisonSuperCategoryWrapper> superCategories = new List<ComparisonSuperCategoryWrapper>();

		List<String> allowedCategories = getMapCategoriesByAccountRoleDetailRecordType().get(accountRoleDetailRT.toLowerCase());
		Map<String, List<Map<String, Object>>> equipmentsByCategory = CW_Utilities.getPicklistFieldDependencies('Account_Role_Detail_Capability__c', 'Category__c', 'Equipment__c', true);

		// List<ComparisonSectionWrapper> sections = new List<ComparisonSectionWrapper>();

		Map<String, String> mapRtLabelByDeveloperName = new Map<String, String>();
		for (RecordType currentRt : RecordTypeSingleton.getInstance().getRecordTypesBySObject('Account_Role_Detail_Capability__c')) {
			if (!mapRtLabelByDeveloperName.containsKey(currentRt.DeveloperName)) {
				mapRtLabelByDeveloperName.put(currentRt.DeveloperName, currentRt.Name);
			}
		}

		// List<Map<String, Object>> sectionsBySupercategory = getMapSectionsBySupercategory();
		List<Map<String, Object>> rtBySections = getMapRecordTypesBySection();
		Map<String, List<String>> categoriesByRt = getMapCategoriesByRecordType();
		Map<String, List<String>> fieldsByRecordTypeAndCategory = getMapFieldsByRecordTypeAndCategory();
		Map<String, List<String>> fieldsByGroupField = getMapFieldsByGroupField();

		List<String> fieldsInGroups = new List<String>();
		for (List<String> currentFields : fieldsByGroupField.values()) {
			for (String currentField : currentFields) {
				if (!fieldsInGroups.contains(currentField)) {
					fieldsInGroups.add(currentField);
				}
			}
		}

		// Loop super categories
		for (Map<String, Object> cSuperCategoryMap : getMapSectionsBySupercategory()) {
			ComparisonSuperCategoryWrapper superCategoryToAdd = new ComparisonSuperCategoryWrapper();
			superCategoryToAdd.label = (String) cSuperCategoryMap.get('label');
			superCategoryToAdd.sections = new List<ComparisonSectionWrapper>();

			// Loop Rt and check the section
			for (Map<String, Object> currentRtsBySection : rtBySections) {
				if (((List<String>) cSuperCategoryMap.get('sections')).contains((String) currentRtsBySection.get('label'))) {
					// Create wrapper section
					ComparisonSectionWrapper sectionToAdd = new ComparisonSectionWrapper();
					sectionToAdd.label = (String) currentRtsBySection.get('label');
					sectionToAdd.rts = new List<ComparisonRtWrapper>();

					// Loop record types for the current section
					for (String currentRt : (List<String>) currentRtsBySection.get('rts')) {
						if (categoriesByRt.containsKey(currentRt.toLowerCase())) {
							ComparisonRtWrapper currentRtWrapper = new ComparisonRtWrapper();
							currentRtWrapper.name = currentRt;
							currentRtWrapper.label = mapRtLabelByDeveloperName.get(currentRt);
							currentRtWrapper.categories = new List<ComparisonCategoryWrapper>();
							for (String currentCategory : categoriesByRt.get(currentRt.toLowerCase())) {
								if (allowedCategories.contains(currentCategory)) {
									ComparisonCategoryWrapper currentCategoryWrapper = new ComparisonCategoryWrapper();
									currentCategoryWrapper.value = currentCategory;

									currentCategoryWrapper.columns = new List<ComparisonColumnWrapper>();

									List<List<Map<String, Object>>> columnsByRtAndGroup = getColumnsByRtAndGroup(new Account_Role_Detail_Capability__c(), fieldsByRecordTypeAndCategory.get(currentRt.toLowerCase() + '#' + currentCategory), fieldsByGroupField);

									Map<String, Integer> mapIndexByField = new Map<String, Integer>();
									for (List<Map<String, Object>> currentHeaderColumnsByRtAndGroup : columnsByRtAndGroup) {
										for (Map<String, Object> currentColumnsByRtAndGroup : currentHeaderColumnsByRtAndGroup) {
											ComparisonColumnWrapper currentColumnWrapper = new ComparisonColumnWrapper();
											currentColumnWrapper.name = (String) currentColumnsByRtAndGroup.get('name');
											currentColumnWrapper.label = (String) currentColumnsByRtAndGroup.get('label');
											if (currentColumnWrapper.name == 'equipment__c') {
												currentColumnWrapper.cssClass = 'row-equipment';
											} else if (fieldsInGroups.contains(currentColumnWrapper.name)) {
												currentColumnWrapper.cssClass = 'row-field-group';
											} else {
												currentColumnWrapper.cssClass = 'row-field';
											}
											currentColumnWrapper.cssClassFacility = currentColumnWrapper.cssClass + '-facility';

											if (!mapIndexByField.containsKey((String) currentColumnsByRtAndGroup.get('name'))) {
												mapIndexByField.put((String) currentColumnsByRtAndGroup.get('name'), currentCategoryWrapper.columns.size());
												currentCategoryWrapper.columns.add(currentColumnWrapper);
											} else {
												currentCategoryWrapper.columns[mapIndexByField.get((String) currentColumnsByRtAndGroup.get('name'))] = currentColumnWrapper;
											}

											if (fieldsByGroupField.containsKey((String) currentColumnsByRtAndGroup.get('name'))) {
												for (String currentColumnGroupedField : fieldsByGroupField.get((String) currentColumnsByRtAndGroup.get('name'))) {
													ComparisonColumnWrapper currentColumnGroupedWrapper = new ComparisonColumnWrapper();
													currentColumnGroupedWrapper.name = currentColumnGroupedField;
													mapIndexByField.put(currentColumnGroupedField, currentCategoryWrapper.columns.size());
													currentCategoryWrapper.columns.add(currentColumnGroupedWrapper);
												}
											}
										}
									}

									currentCategoryWrapper.equipments = new List<ComparisonEquipmentWrapper>();
									if (equipmentsByCategory.containsKey(currentCategory)) {
										for (Map<String, Object> currentEquipment : equipmentsByCategory.get(currentCategory)) {
											ComparisonEquipmentWrapper currentEquipmentWrapper = new ComparisonEquipmentWrapper();
											currentEquipmentWrapper.value = (String) currentEquipment.get('value');
											currentEquipmentWrapper.label = (String) currentEquipment.get('label');
											currentCategoryWrapper.equipments.add(currentEquipmentWrapper);
										}
									}
									currentRtWrapper.categories.add(currentCategoryWrapper);
								}
							}

							if (currentRtWrapper.categories.size() > 0) {
								sectionToAdd.rts.add(currentRtWrapper);
							}
						}
					}

					if (sectionToAdd.rts.size() > 0) {
						superCategoryToAdd.sections.add(sectionToAdd);
					}
				}
			}

			if (superCategoryToAdd.sections.size() > 0) {
				supercategories.add(superCategoryToAdd);
			}

			returnValue.put('superCategories', supercategories);
		}
		return returnValue;
	}
	public class ComparisonSectionWrapper {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public List<ComparisonRtWrapper> rts { get; set; }
	}
	public class ComparisonSuperCategoryWrapper {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public List<ComparisonSectionWrapper> sections { get; set; }
	}
	public class ComparisonRtWrapper {
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public List<ComparisonCategoryWrapper> categories { get; set; }
	}
	public class ComparisonCategoryWrapper {
		@AuraEnabled
		public String value { get; set; }
		// @AuraEnabled public String label {set;get;}
		@AuraEnabled
		public List<ComparisonEquipmentWrapper> equipments { get; set; }
		@AuraEnabled
		public List<ComparisonColumnWrapper> columns { get; set; }
	}
	public class ComparisonColumnWrapper {
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String cssClass { get; set; }
		@AuraEnabled
		public String cssClassFacility { get; set; }
	}
	public class ComparisonEquipmentWrapper {
		@AuraEnabled
		public String value { get; set; }
		@AuraEnabled
		public String label { get; set; }
	}

	public static Object getItemInMap(List<Map<String, Object>> data, String key, Object value) {
		try {
			for (Map<String, Object> currentItem : (List<Map<String, Object>>) data) {
				if (currentItem.get(key) == value) {
					return currentItem;
				}
			}
		} catch (Exception e) {
			return null;
		}
		return null;
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
							if (String.isNotBlank(((String) itemToConvert.get(currentField)))) {
								values = ((String) itemToConvert.get(currentField)).split(';');
							}

							convertedItem.put(currentField, values);
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

	//DEPRECATED - USE NON-GENERIC VARIANTS FOR PERFORMANCE
	public static Map<String, Schema.PicklistEntry> getPicklistEntryMap(String objectName, String fieldName) {
		Map<String, Schema.PicklistEntry> values = new Map<String, Schema.PicklistEntry>();
		String[] types = new List<String>{ objectName };
		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);

		for (Schema.DescribeSobjectResult res : results) {
			for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
				if (entry.isActive()) {
					values.put(entry.getValue().toLowerCase(), entry);
				}
			}
		}
		return values;
	}

	public static Map<String, Schema.PicklistEntry> generatePicklistMap(Schema.DescribeFieldResult fieldResult) {
		Map<String, Schema.PicklistEntry> mapObjs = new Map<String, Schema.PicklistEntry>();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple) {
			mapObjs.put(pickListVal.getValue().toLowerCase(), pickListVal);
		}

		return mapObjs;
	}

	public static Map<String, Schema.PicklistEntry> getPicklistEntryMapCapEquipment() {
		Schema.DescribeFieldResult fieldResult = Account_Role_Detail_Capability__c.Equipment__c.getDescribe();
		return generatePicklistMap(fieldResult);
	}

	public static Map<String, Schema.PicklistEntry> getPicklistEntryMapCapCategory() {
		Schema.DescribeFieldResult fieldResult = Account_Role_Detail_Capability__c.Category__c.getDescribe();
		return generatePicklistMap(fieldResult);
	}

	public static List<List<Map<String, Object>>> getColumnsByRtAndGroup(SObject item, List<String> fieldsName, Map<String, List<String>> fieldGroups) {
		List<List<Map<String, Object>>> headers = new List<List<Map<String, Object>>>();

		Boolean includeFirstHeader = false;
		List<Map<String, Object>> firstHeader = new List<Map<String, Object>>();
		List<Map<String, Object>> lastHeader = new List<Map<String, Object>>();

		if (fieldsName == null) {
			fieldsName = new List<String>();
		}

		if (fieldGroups == null) {
			fieldGroups = new Map<String, List<String>>();
		}

		DescribeSObjectResult objDescribe = item.getSObjectType().getDescribe();
		Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

		for (String fieldName : fieldsName) {
			if (fieldMap.containsKey(fieldName)) {
				String currentLabel = fieldMap.get(fieldName).getDescribe().getLabel();

				Boolean foundGroup = false;
				for (String groupLabel : fieldGroups.keySet()) {
					if (fieldGroups.get(groupLabel).contains(fieldName)) {
						Map<String, Object> tmpFound = (Map<String, Object>) getItemInMap(firstHeader, 'name', groupLabel);
						if (tmpFound == null) {
							firstHeader.add(new Map<String, Object>{ 'colspan' => 1, 'name' => groupLabel, 'label' => groupLabel });
						} else {
							tmpFound.put('colspan', ((Integer) tmpFound.get('colspan')) + 1);
						}

						currentLabel = currentLabel.replace(groupLabel, '');
						foundGroup = true;
						includeFirstHeader = true;
					}
				}

				List<Map<String, String>> pickListValuesList = new List<Map<String, String>>();
				if ((fieldMap.get(fieldName).getDescribe().getType().name() == 'PICKLIST' || fieldMap.get(fieldName).getDescribe().getType().name() == 'MULTIPICKLIST') && fieldName != 'equipment__c') {
					for (Schema.PicklistEntry pickListVal : fieldMap.get(fieldName).getDescribe().getPicklistValues()) {
						Map<String, String> mappickListValues = new Map<String, String>();
						mappickListValues.put('label', pickListVal.getLabel());
						mappickListValues.put('value', pickListVal.getValue());
						pickListValuesList.add(mappickListValues);
					}
				}

				lastHeader.add(new Map<String, Object>{ 'colspan' => 1, 'name' => fieldName, 'label' => currentLabel, 'isformula' => fieldMap.get(fieldName).getDescribe().isCalculated(), 'type' => fieldMap.get(fieldName).getDescribe().getType().name(), 'values' => pickListValuesList });

				if (!foundGroup) {
					firstHeader.add(new Map<String, Object>{ 'colspan' => 1, 'name' => fieldName, 'label' => '', 'isformula' => fieldMap.get(fieldName).getDescribe().isCalculated(), 'type' => fieldMap.get(fieldName).getDescribe().getType().name(), 'values' => pickListValuesList });
				}
			}
		}
		if (includeFirstHeader) {
			headers.add(firstHeader);
		}
		headers.add(lastHeader);
		return headers;
	}

	public static List<String> validateFieldsOfObject(String objectName, List<String> fieldsToRetrieve, Map<String, Schema.SObjectField> fieldsMap) {
		List<String> validatedFields = new List<String>();
		for (String currentField : fieldsToRetrieve) {
			if (fieldsMap.containsKey(currentField)) {
				DescribeFieldResult currentFieldDescribe = fieldsMap.get(currentField).getDescribe();
				if (currentFieldDescribe.getName().toLowerCase() != 'Equipment__c' && (currentFieldDescribe.getType() == Schema.DisplayType.PICKLIST || currentFieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST)) {
					validatedFields.add('toLabel(' + currentFieldDescribe.getName() + ')');
				} else {
					validatedFields.add(currentFieldDescribe.getName());
				}
			}
		}

		// Remove duplicates if exists
		return new List<String>(new Set<String>(validatedFields));
	}

	@AuraEnabled
	public static Object setSummaryDetailCheckJSON(String icgAccountRoleDetailId, String jsonData) {
		ICG_Account_Role_Detail__c icgAccountRoleDetail = new ICG_Account_Role_Detail__c(Id = icgAccountRoleDetailId);
		icgAccountRoleDetail.Summary_Detail_Check_JSON__c = jsonData;

		try {
			update icgAccountRoleDetail;
			return true;
		} catch (Exception e) {
			return e.getMessage();
		}
	}

	//For edit some capabilities from recordtypes
	/**
	 * @description		create relationships for new capabilities certifications
	 * @param			ardCertId - Account Role Detail Certi Id
	 * @return			ICG_Capability_Assignment_Group__c Id
	 */
	@AuraEnabled
	public static String createRelationshipsForNewCapabilities(String accRoleDet, List<Object> listAddedRows) {
		ICG_Capability_Assignment_Group__c addCapabAssgmGroup;
		ResponseBody res = new ResponseBody();
		List<Account_Role_Detail_Capability__c> listAccRoleCapabInserted;

		if (!String.isBlank(accRoleDet)) {
			try {
				//creation record capability assigment group
				addCapabAssgmGroup = createCapabAssigmentGroup(accRoleDet);

				//creation records capabilities
				listAccRoleCapabInserted = createCapabilities(listAddedRows);

				//creation records union AccRoleCapabAssigment for Capability
				res.success = assignCapabilityAndGroup(accRoleDet, addCapabAssgmGroup, listAccRoleCapabInserted);

				res.message = addCapabAssgmGroup.Id;
			} catch (Exception e) {
				res.success = false;
				res.message = e.getMessage();
				if (addCapabAssgmGroup != null) {
					delete addCapabAssgmGroup;
				}
			}
		}

		return JSON.serialize(res);
	}

	/**
	 * @description		create new ICG_Capability_Assignment_Group__c
	 * @param
	 * @return			ICG_Capability_Assignment_Group__c Id
	 */
	private static ICG_Capability_Assignment_Group__c createCapabAssigmentGroup(String accRoleDet) {
		ICG_Capability_Assignment_Group__c addCapabAssgmGroup = new ICG_Capability_Assignment_Group__c();

		addCapabAssgmGroup.Expiration_Date__c = Date.today().addYears(3);
		addCapabAssgmGroup.Issue_Date__c = Date.today();
		addCapabAssgmGroup.RecordTypeId = RT_NO_CERTIFICATION_REQUIRED;
		addCapabAssgmGroup.ICG_Account_Role_Detail__c = accRoleDet;

		insert addCapabAssgmGroup;

		return addCapabAssgmGroup;
	}

	/**
	 * @description	Create List<Account_Role_Detail_Capability__c> with the capabilities list passed from param
	 * @param			List<Object(Account_Role_Detail_Capability__c)> capabilitiesList
	 * @return			Boolean with result
	 */
	@AuraEnabled
	public static List<Account_Role_Detail_Capability__c> createCapabilities(List<Object> capabilitiesList) {
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
			sObj.put('RecordTypeId', c.rtypeId);
			sObj.put('Category__c', c.category);
			sObj.put('Equipment__c', c.equipment);

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
		insert listToInsert;

		return listToInsert;
	}

	/**
	 * @description		assign Capability with Group
	 * @param			accRoleDet - Account Role Detail Id, accRoleCapabId - Account Role Capab Id, capabAssigmenGroup - Capab Assigment Group and ardCertId - Account Role Detail Certi Id
	 * @return			Boolean true or false
	 */
	private static Boolean assignCapabilityAndGroup(String accRoleDet, ICG_Capability_Assignment_Group__c capabAssigmenGroup, List<Account_Role_Detail_Capability__c> listAccRoleCapabId) {
		Boolean result = true;
		List<ICG_Account_Role_Capability_Assignment__c> assigment = new List<ICG_Account_Role_Capability_Assignment__c>();

		if (listAccRoleCapabId.size() > 0 && capabAssigmenGroup != null && !String.isBlank(accRoleDet)) {
			for (Account_Role_Detail_Capability__c capabToInsert : listAccRoleCapabId) {
				assigment.add(new ICG_Account_Role_Capability_Assignment__c(Account_Role_Detail_Capability__c = capabToInsert.Id, ICG_Capability_Assignment_Group__c = capabAssigmenGroup.Id, ICG_Account_Role_Detail__c = accRoleDet));
			}

			insert assigment;
		}

		return result;
	}

	/*
	 * @Description: wrapper for sections
	 */
	public class SectionsWrapper {
		@AuraEnabled
		public Map<String, CW_FacilityCapabilitiesController.ChecksWrapper> capabilitiesMap { get; set; }
	}

	/*
	 * @Description: wrapper for summary and detail checks
	 */
	public class ChecksWrapper {
		@AuraEnabled
		public Boolean summary { get; set; }
		@AuraEnabled
		public Boolean detail { get; set; }
	}

	public class CapabilityPhoto {
		@AuraEnabled
		public Boolean visible { get; set; }
		@AuraEnabled
		public String url { get; set; }
		@AuraEnabled
		public String label { get; set; }
	}

	public class CapabilityWrapper {
		public String position;
		public String rtypeId;
		public String category;
		public String equipment;
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

	public class AsgmtGroupWrapper implements Comparable {
		final Double defaultOrder = 9999;
		@AuraEnabled
		public Id id;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public Date expirationDate;
		@AuraEnabled
		public Date issueDate;
		@AuraEnabled
		public String src;
		@AuraEnabled
		public Double order;

		public AsgmtGroupWrapper() {
		}

		public Integer compareTo(Object compareTo) {
			AsgmtGroupWrapper asgmtGroupToCompare = (AsgmtGroupWrapper) compareTo;
			if (order == null) {
				this.order = this.defaultOrder;
			}
			if (asgmtGroupToCompare.order == null) {
				asgmtGroupToCompare.order = this.defaultOrder;
			}

			Integer returnValue = 0;
			if (this.order > asgmtGroupToCompare.order) {
				returnValue = 1;
			} else if (this.order < asgmtGroupToCompare.order) {
				returnValue = -1;
			}
			return returnValue;
		}
	}

	public class ResponseBody {
		public String message { get; set; }
		public Boolean success { get; set; }
	}
}