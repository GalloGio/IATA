public without sharing class CW_FacilityCapabilitiesController {
	final static String MD_CATEGORIES_BY_ACCOUNT_ROLE_DETAIL_RT = 'Categories_By_Account_Role_Detail_Record_Type';
	final static String MD_RTS_BY_SECTION = 'Record_Types_By_Section';
	final static String MD_CATEGORIES_BY_RT = 'Categories_By_Record_Type';
	final static String MD_FIELDS_BY_RT_AND_CATEGORY = 'Fields_By_Record_Type_And_Category';
	final static String MD_GROUPED_FIELDS = 'Grouped_Fields';
	final static String MD_SPECIFIC_PROCESSING = 'Specific_Processing';
	final static String MD_TOOLTIP_BY_SUPERCATEGORY = 'Tooltip_By_SuperCategory';
	final static String MD_TOOLTIP_BY_SECTION = 'Tooltip_By_Section';
	final static String MD_TOOLTIP_FIELDS_BY_FIELD = 'Tooltip_Fields_By_Field';
	final static String MD_CONFIG = 'Config';
	final static String MD_SECTIONS_BY_SUPERCATEGORY = 'Sections_By_Supercategory';
	final static String MD_EDITABLE_RECORDTYPES = 'Editable_RecordTypes';
	final static String SEARCH_ONLY_DATA = 'Data__c';
	final static String SEARCH_WITH_EXTRADATA = 'Extra_Data__c';
	final static String RT_CERTIFICATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');
	final static String RT_NO_CERTIFICATION_REQUIRED = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'No_Certification_Required');
	final static Map<String, List<String>> ESPECIAL_CATEGORIES = getMapConfig();
	public final static Map<String, List<String>> EDITABLE_RECORDTYPES = getMapEditableRecordTypes();
	public final static List<Id> EDITABLE_RECORDTYPES_ID = getListEditableRecordTypesID();

	//This validation program is used to check if you have permissions to manage capabilities.
	final static String validationPrograms = CW_Utilities.VALIDATION_PROGRAMS;

	/*
	 * @description		Generate a cvs based on this structure :  StationType_DeveloperName,StationType_Name,Category_Value,Category_Label,Equipment,Equipment_Label
	 * @return			Csv content
	 */
	public static String generateCapabilitiesStructureCsv() {
		List<String> output = new List<String>();
		output.add('StationType_DeveloperName,StationType_Name,Category_Value,Category_Label,Equipment,Equipment_Label');

		Map<String, RecordType> rtObjectByRtDevName = new Map<String, RecordType>();
		for (RecordType currentRt : RecordTypeSingleton.getInstance().getRecordTypesBySObject('ICG_Account_Role_Detail__c')) {
			rtObjectByRtDevName.put(currentRt.DeveloperName.toLowerCase(), currentRt);
		}

		Map<String, List<String>> categoriesByAccountRoleDetailRecordType = getMapCategoriesByAccountRoleDetailRecordType();
		Map<String, List<String>> categoriesByRecordType = getMapCategoriesByRecordType();
		Map<String, Schema.PicklistEntry> mapCategories = CW_FacilityCapabilitiesController.getPicklistEntryMapCapCategory();
		Map<String, List<Map<String, Object>>> equipmentsByCategory = CW_Utilities.getPicklistFieldDependencies('Account_Role_Detail_Capability__c', 'Category__c', 'Equipment__c', true);

		for (String currentAccountRoleDetailRtDevName : categoriesByAccountRoleDetailRecordType.keySet()) {
			if (rtObjectByRtDevName.containsKey(currentAccountRoleDetailRtDevName)) {
				for (String currentCategoryValue : categoriesByAccountRoleDetailRecordType.get(currentAccountRoleDetailRtDevName)) {
					if (mapCategories.containsKey(currentCategoryValue) && equipmentsByCategory.containsKey(currentCategoryValue)) {
						for (Map<String, Object> currentEquipment : equipmentsByCategory.get(currentCategoryValue)) {
							// Add csv line
							output.add(String.format('"{0}","{1}","{2}","{3}","{4}","{5}"', new List<String>{ rtObjectByRtDevName.get(currentAccountRoleDetailRtDevName).DeveloperName, rtObjectByRtDevName.get(currentAccountRoleDetailRtDevName).Name, mapCategories.get(currentCategoryValue).value, mapCategories.get(currentCategoryValue).label, (String) currentEquipment.get('value'), (String) currentEquipment.get('label') }));
						}
					}
				}
			}
		}

		return String.join(output, '\n');
	}

	/*
	 * @description		Generate a cvs based on this structure :  StationType_DeveloperName,StationType_Name,Category_Value,Category_Label,Equipment,Equipment_Label
	 * @return			Csv content
	 */
	@auraEnabled(cacheable=true)
	public static Map<String, List<String>> getMapCategoriesByAccountRoleDetailRecordType() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_CATEGORIES_BY_ACCOUNT_ROLE_DETAIL_RT, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Sections_By_Supercategory' or 'Data__c' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static List<Map<String, Object>> getMapSectionsBySupercategory() {
		List<Map<String, Object>> output = new List<Map<String, Object>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_SECTIONS_BY_SUPERCATEGORY, SEARCH_ONLY_DATA)) {
			output.add(new Map<String, Object>{ 'order' => currentConfig.Order__c, 'label' => currentConfig.Key__c, CW_CapabilitiesUtilities.SECTIONS => (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.split(';') });
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Record_Types_By_Section' or 'Data__c' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static List<Map<String, Object>> getMapRecordTypesBySection() {
		List<Map<String, Object>> output = new List<Map<String, Object>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_RTS_BY_SECTION, SEARCH_ONLY_DATA)) {
			output.add(new Map<String, Object>{ 'order' => currentConfig.Order__c, 'label' => currentConfig.Key__c, 'rts' => (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.split(';') });
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Categories_By_Record_Type' or 'Data__c' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static Map<String, List<String>> getMapCategoriesByRecordType() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_CATEGORIES_BY_RT, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Fields_By_Record_Type_And_Category' or 'Data__c' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static Map<String, List<String>> getMapFieldsByRecordTypeAndCategory() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_FIELDS_BY_RT_AND_CATEGORY, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Fields_By_Record_Type_And_Category' or 'Extra_Data__c' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static Map<String, List<String>> getMapFieldsByExtraDataType() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_FIELDS_BY_RT_AND_CATEGORY, SEARCH_WITH_EXTRADATA)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Extra_Data__c)) ? new List<String>() : currentConfig.Extra_Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Grouped_Fields' or 'Data__c' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static Map<String, List<String>> getMapFieldsByGroupField() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_GROUPED_FIELDS, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Specific_Processing' or 'Data__c' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static Map<String, List<String>> getMapEquipmentValuesBySpecificProcessing() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_SPECIFIC_PROCESSING, SEARCH_ONLY_DATA)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Tooltip_By_SuperCategory'
	 * @return			Map<String, List<String>> => key => Section | string[0] => icon path, string[1] => tooltip
	 */
	public static Map<String, List<String>> getMapTooltipBySuperCategory() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_TOOLTIP_BY_SUPERCATEGORY, SEARCH_WITH_EXTRADATA)) {
			output.put(
				currentConfig.Key__c.toLowerCase(), 
				new List<String> {
					(String.isBlank(currentConfig.Data__c)) ? '' : currentConfig.Data__c, 
					(String.isBlank(currentConfig.Extra_Data__c)) ? '' : currentConfig.Extra_Data__c
				}
			);
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Tooltip_By_Section'
	 * @return			Map<String, List<String>> => key => Section | string[0] => icon path, string[1] => tooltip
	 */
	public static Map<String, List<String>> getMapTooltipBySection() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_TOOLTIP_BY_SECTION, SEARCH_WITH_EXTRADATA)) {
			output.put(
				currentConfig.Key__c.toLowerCase(), 
				new List<String> {
					(String.isBlank(currentConfig.Data__c)) ? '' : currentConfig.Data__c, 
					(String.isBlank(currentConfig.Extra_Data__c)) ? '' : currentConfig.Extra_Data__c
				}
			);
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Tooltip_Fields_By_Field' or 'Data__c' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static Map<String, List<String>> getMapTooltipFieldsByField() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_TOOLTIP_FIELDS_BY_FIELD, SEARCH_WITH_EXTRADATA)) {
			if (string.isBlank(currentConfig.Extra_Data__c)){
				output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.split(';'));
			}
			else{
				output.put(currentConfig.Key__c.toLowerCase(), currentConfig.Extra_Data__c.split(';'));
			}
		}

		return output;
	}

	@AuraEnabled
	public static String getDateExtraData(String capabilityId){
		Account_Role_Detail_Capability__c capConfig = [SELECT Id, Security_Equipment_Date__c, Quality_Control_Compliance_Date__c, Screeners_Performance_Date__c, System_Assurance_Date__c, Contract_Management_Date__c FROM Account_Role_Detail_Capability__c WHERE Id =: capabilityId LIMIT 1];
		DateExtraData result = new DateExtraData(capConfig);
		return JSON.serialize(result);
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by type and data
	 * @param			type: ICG_capability_configuration__mdt.Type__c
	 * @param			type: condition that compares the value as 'Extra_Data__c' and if it is positive, brings a Extra_Data__c field as value
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static List<ICG_capability_configuration__mdt> getCapabilityConfigurationMetadataByType(String type, String fieldsData) {
		if (fieldsData.equalsIgnoreCase(SEARCH_WITH_EXTRADATA)) {
			return [SELECT Key__c, Extra_Data__c, Data__c, Order__c FROM ICG_capability_configuration__mdt WHERE Type__c = :type ORDER BY Order__c ASC, Key__c ASC];
		}
		return [SELECT Key__c, Data__c, Order__c FROM ICG_capability_configuration__mdt WHERE Type__c = :type ORDER BY Order__c ASC, Key__c ASC];
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Config' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static Map<String, List<String>> getMapConfig() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_CONFIG)) {
			output.put(currentConfig.Key__c, (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	/*
	 * @description		Retrieves metadata related to Capability filtered by 'Editable_RecordTypes' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static Map<String, List<String>> getMapEditableRecordTypes() {
		Map<String, List<String>> output = new Map<String, List<String>>();
		for (ICG_capability_configuration__mdt currentConfig : getCapabilityConfigurationMetadataByType(MD_EDITABLE_RECORDTYPES)) {
			output.put(currentConfig.Key__c.toLowerCase(), (String.isBlank(currentConfig.Data__c)) ? new List<String>() : currentConfig.Data__c.toLowerCase().split(';'));
		}

		return output;
	}

	/*
	 * @description		Retrieves record type ids related to Capability's metadata filtered by 'Editable_RecordTypes' record type
	 * @return			List of strings splitted by ',' from ICG_capability_configuration__mdt.Data__c)
	 */
	public static List<Id> getListEditableRecordTypesID() {
		List<Id> output = new List<Id>();
		Map<String, List<String>> editableRecordTypes = getMapEditableRecordTypes();

		Map<String, String> recordTypes = RecordTypeSingleton.getInstance().getMapRecordTypesBySObject('Account_Role_Detail_Capability__c');        
		for(String key : recordTypes.keySet()){
			if (editableRecordTypes.containsKey(key.replaceAll(' ', '_').toLowerCase())){
				output.add(Id.valueOf(recordTypes.get(key)));
			}
		}

		return output;
	}
	
	/*
	 * @description		Retrieves metadata related to Capability filtered by type
	 * @param			type: ICG_capability_configuration__mdt.Type__c
	 * @return			List of ICG_capability_configuration__mdt
	 */
	public static List<ICG_capability_configuration__mdt> getCapabilityConfigurationMetadataByType(String type) {
		return [SELECT Key__c, Data__c, Extra_Data__c, Order__c FROM ICG_capability_configuration__mdt WHERE Type__c = :type ORDER BY Order__c ASC, Key__c ASC];
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
	private static List<ICG_Account_Role_Capability_Assignment__c> getAssignmentsByAccountRoleDetailAndRts(Id ardId, List<Id> recordTypesId, List<String> categoriesToRetrieve, List<String> accountRoleDetailCapabilityFields, List<String> capabilitiesIdForConflicts) {
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
			fieldsToRetrieve.addAll(new List<String>{ caGroupR + '.Id', caGroupR + '.Expiration_Date__c', caGroupR + '.Issue_Date__c', caGroupR + '.' + certificationR + '.Name', caGroupR + '.' + certificationR + '.Label__c', caGroupR + '.' + certificationR + '.Image__c', caGroupR + '.' + certificationR + '.Order__c', caGroupR + '.' + certificationR + '.ValidationPrograms__c' });

			String optionalFilterConflicts = capabilitiesIdForConflicts == null || capabilitiesIdForConflicts.isEmpty() ? ' AND Is_In_Conflict__c = false' : 'AND ' + ardCapabilityR + '.Id IN (\'' + String.join((capabilitiesIdForConflicts), '\', \'') + '\')';

			String query = 'SELECT Id, ' + String.join(fieldsToRetrieve, ', ') + ' FROM ICG_Account_Role_Capability_Assignment__c ' + ' WHERE ' + caGroupR + '.Is_Active__c = true ' + optionalFilterConflicts + ' AND ' + caGroupR + '.Expiration_Date__c >= TODAY AND ' + arDetailR + '.Id = \'' + ardId + '\' ' + ' AND ' + ardCapabilityR + '.RecordTypeId IN (\'' + String.join((recordTypesId), '\', \'') + '\')' + ' AND ' + ardCapabilityR + '.Category__c IN (\'' + String.join(categoriesToRetrieve, '\', \'') + '\') order by CreatedDate ';
			returnValue = (List<ICG_Account_Role_Capability_Assignment__c>) Database.query(query);
		}

		return returnValue;
	}

	/**
	 * @description		Generate the CW_Utilities.AsgmtGroupWrapper in memory based on List<ICG_Account_Role_Capability_Assignment__c> received by parameter
	 * @param			assignments List<ICG_Account_Role_Capability_Assignment__c>
	 * @return			Wrap the List<ICG_Account_Role_Capability_Assignment__c> to List<CW_Utilities.AsgmtGroupWrapper>
	 */
	private static Map<Id, List<CW_Utilities.AsgmtGroupWrapper>> generateAsgmtGroupByCapabilityId(List<ICG_Account_Role_Capability_Assignment__c> assignments) {
		Map<Id, List<CW_Utilities.AsgmtGroupWrapper>> asgmtGroupByCapabilityId = new Map<Id, List<CW_Utilities.AsgmtGroupWrapper>>();

		// Loop assignments to get certifications
		for (ICG_Account_Role_Capability_Assignment__c currentAssignment : assignments) {
			if (currentAssignment.ICG_Capability_Assignment_Group__r != null) {
				ICG_Capability_Assignment_Group__c currentGroup = currentAssignment.ICG_Capability_Assignment_Group__r;

				if (!asgmtGroupByCapabilityId.containsKey(currentAssignment.Account_Role_Detail_Capability__c)) {
					asgmtGroupByCapabilityId.put(currentAssignment.Account_Role_Detail_Capability__c, new List<CW_Utilities.AsgmtGroupWrapper>());
				}
				CW_Utilities.AsgmtGroupWrapper asgmtGroupToAdd = new CW_Utilities.AsgmtGroupWrapper();
				asgmtGroupToAdd.id = currentGroup.Id;
				asgmtGroupToAdd.type = currentGroup.RecordType.DeveloperName;
				asgmtGroupToAdd.name = Label.icg_smart_facility_remote_validation;
				asgmtGroupToAdd.label = Label.icg_smart_facility_remote_validation;
				asgmtGroupToAdd.expirationDate = currentGroup.Expiration_Date__c;
				asgmtGroupToAdd.issueDate = currentGroup.Issue_Date__c;
				asgmtGroupToAdd.src = '/resource/ICG_Resources/icons/remote_validation_icon.svg';
				if (currentGroup.ICG_Certification__c != null) {
					asgmtGroupToAdd.order = currentGroup.ICG_Certification__r.Order__c;
					asgmtGroupToAdd.name = currentGroup.ICG_Certification__r.Name;
					asgmtGroupToAdd.label = currentGroup.ICG_Certification__r.Label__c;
					asgmtGroupToAdd.src = currentGroup.ICG_Certification__r.Image__c;
					asgmtGroupToAdd.validationProgram = currentGroup.ICG_Certification__r.ValidationPrograms__c;
				}
				if (!currentGroup.RecordTypeId.equals(RT_NO_CERTIFICATION_REQUIRED)) {
					asgmtGroupByCapabilityId.get(currentAssignment.Account_Role_Detail_Capability__c).add(asgmtGroupToAdd);
				}
			}
		}

		return asgmtGroupByCapabilityId;
	}

	/**
	 * @description		Generate a object with 3 different properties: 
	 * listSectionsIncluded: Developer name list of ICG_Account_Role_Capability_Assignment__c, 
	 * checksMap: CW_FacilityCapabilitiesController.SectionsWrapper
	 * rawData: Generated map with info about capabilities
	 * @param			id ICG_Account_Role_Detail__c Id
	 * @param	        categoriesToRetrieve List<ICG_Account_Role_Capability_Assignment__c>
	 * @param	 		mapCategoriesByRecordTypeDevName list of record type dev names
	 * @param	 		mapAccountRoleDetailAssignmentRtsById List<ICG_Account_Role_Capability_Assignment__c>
	 * @param	 		capabilitiesIdForConflicts Id List of capabilities with conflicts
	 * @param	 		accountRoleDetailFound ICG_Account_Role_Detail__c
	 * @return			Map<String, Object> with these properties: listSectionsIncluded, checksMap and rawData
	 */
	private static Map<String, Object> generateData(String id, List<String> categoriesToRetrieve, 
													Map<String, List<String>> mapCategoriesByRecordTypeDevName, 
													Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById,
													List<String> capabilitiesIdForConflicts, 
													ICG_Account_Role_Detail__c accountRoleDetailFound,
													String validationPrograms) {
		Set<String> listSectionsIncluded = new Set<String>();
		CW_FacilityCapabilitiesController.SectionsWrapper checksMap;

		//Get certifications allowed for user
		String stationRT = [SELECT RecordType.DeveloperName FROM ICG_Account_Role_Detail__c WHERE Id =: id].RecordType.DeveloperName;
		List<String> CERTIFICATIONS_ALLOWED_USER =  CW_CapabilitiesUtilities.getCertificationsAllowedByDepartments(stationRT,validationPrograms);
		Boolean userHasPermissionToEdit = CW_Utilities.hasSpecialPermissionsToEdit() || CW_Utilities.getPermissionToEdit();

		//Get recordtypes id for category
		Map<String, String> mapRecordTypeIdByCategory = CW_FacilityCapabilitiesController.getRecordTypesIdByCategoryName();

		// Get Fields to build the soql query and the tables.
		Map<String, List<String>> mapFieldsByRecordTypeAndCategory = CW_FacilityCapabilitiesController.getMapFieldsByRecordTypeAndCategory();
		Map<String, List<String>> mapTooltipFieldsByField = CW_FacilityCapabilitiesController.getMapTooltipFieldsByField();
		List<String> fieldsToRetrieve = CW_CapabilitiesUtilities.generateFieldsToRetrieve(mapFieldsByRecordTypeAndCategory, mapTooltipFieldsByField);

		// Get grouped fields
		Map<String, List<String>> mapFieldsByGroupField = CW_FacilityCapabilitiesController.getMapFieldsByGroupField();

		// Get equipments map
		Map<String, Schema.PicklistEntry> mapEquipments = CW_FacilityCapabilitiesController.getPicklistEntryMapCapEquipment();

		Map<String, Object> rawData = CW_CapabilitiesUtilities.generateRawData(mapCategoriesByRecordTypeDevName, mapAccountRoleDetailAssignmentRtsById, categoriesToRetrieve);

		// Schemas to validity fields
		Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Account_Role_Detail_Capability__c.fields.getMap();

		List<ICG_Account_Role_Capability_Assignment__c> assignments = getAssignmentsByAccountRoleDetailAndRts(id, new List<Id>(mapAccountRoleDetailAssignmentRtsById.keySet()), categoriesToRetrieve, validateFieldsOfObject('Account_Role_Detail_Capability__c', fieldsToRetrieve, fieldsMap), capabilitiesIdForConflicts);
		Map<Id, List<CW_Utilities.AsgmtGroupWrapper>> asgmtGroupByCapabilityId = generateAsgmtGroupByCapabilityId(assignments);

		Map<String, String> columnsToHandle = new Map<String, String>();
		
		// Load static fields to reduce the parameters in CapabilityNotIncludedDTO and future refactores
		CW_CapabilitiesUtilities.MAPEquipments = mapEquipments;
		CW_CapabilitiesUtilities.MAPfields = fieldsMap;
		CW_CapabilitiesUtilities.MAPFieldsByGroupField = mapFieldsByGroupField;
		CW_CapabilitiesUtilities.MAPTooltipFieldsByField = mapTooltipFieldsByField;
		CW_CapabilitiesUtilities.MAPFieldsByRecordTypeAndCategory = mapFieldsByRecordTypeAndCategory;
		CW_CapabilitiesUtilities.MAPRecordTypeIdByCategory = mapRecordTypeIdByCategory;

		// Loop assignments and fill the output data model
		for (ICG_Account_Role_Capability_Assignment__c currentAssignment : assignments) {
			// Populate data for Account_Role_Detail_Capability__c
			Account_Role_Detail_Capability__c currentDetail = currentAssignment.Account_Role_Detail_Capability__r;

			listSectionsIncluded.add(mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName);

			String rtDevNameLC = mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName.toLowerCase();
			if (mapCategoriesByRecordTypeDevName.containsKey(rtDevNameLC)) {
				// We look for the Capability, Category to which it belongs
				Map<String, Object> capabilityFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) rawData.get(CW_CapabilitiesUtilities.CAPABILITIES), 'name', rtDevNameLC);
				capabilityFound = CW_CapabilitiesUtilities.generateCapabilityFound(capabilityFound, currentDetail);
				Map<String, Object> categoryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get(CW_CapabilitiesUtilities.CATEGORIES), 'value', currentDetail.Category__c);
				categoryFound = CW_CapabilitiesUtilities.generateCategoryFound(categoryFound, capabilityFound, mapFieldsByRecordTypeAndCategory, rtDevNameLC, currentDetail, mapFieldsByGroupField, columnsToHandle, false);

				if (currentAssignment.ICG_Account_Role_Detail__r.Summary_Detail_Check_JSON__c != null) {
					checksMap = (CW_FacilityCapabilitiesController.SectionsWrapper) JSON.deserialize(currentAssignment.ICG_Account_Role_Detail__r.Summary_Detail_Check_JSON__c, CW_FacilityCapabilitiesController.SectionsWrapper.class);
				}

				Map<String, Object> currentObject;
				if (!categoryFound.isEmpty() && categoryFound.containsKey(CW_CapabilitiesUtilities.ROWS)) {
					List<Object> capabilityGroupRowsFound = (List<Object>) categoryFound.get(CW_CapabilitiesUtilities.ROWS);

					if (!CW_CapabilitiesUtilities.isCapabilityAdded(capabilityGroupRowsFound, currentDetail.Id)) {
						currentObject = convertCapabilityAssignmentToObject(currentDetail, mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
						List<CW_Utilities.AsgmtGroupWrapper> certifications = asgmtGroupByCapabilityId.containsKey(currentDetail.Id) ? asgmtGroupByCapabilityId.get(currentDetail.Id) : new List<CW_Utilities.AsgmtGroupWrapper>();
						certifications.sort();
						
						currentObject = CW_CapabilitiesUtilities.generateCurrentObject(
							currentObject, currentDetail.Id, currentDetail, certifications,
							 currentAssignment.ICG_Capability_Assignment_Group__r.RecordTypeId,
							  capabilityFound, mapFieldsByRecordTypeAndCategory, rtDevNameLC, mapEquipments,
							   mapTooltipFieldsByField, fieldsMap, false, true, true,stationRT,
							   CERTIFICATIONS_ALLOWED_USER,userHasPermissionToEdit);
						capabilityGroupRowsFound.add(currentObject);
					}
				}
				categoryFound.put('templateFields', currentObject);
			}
		}
		// if recordtype is editable
		CW_CapabilitiesUtilities.CapabilityNotIncludedDTO capNotIncluded = new CW_CapabilitiesUtilities.CapabilityNotIncludedDTO(rawData, accountRoleDetailFound, 
			mapAccountRoleDetailAssignmentRtsById, mapCategoriesByRecordTypeDevName, 
			columnsToHandle, stationRT, 
			CERTIFICATIONS_ALLOWED_USER, userHasPermissionToEdit);

		listSectionsIncluded.addAll(CW_CapabilitiesUtilities.getCapabilitiesByRecordTypeNotIncluded(capNotIncluded));

		Map<String, Object> returnValue = new Map<String, Object>();
		returnValue.put(CW_CapabilitiesUtilities.LIST_SECTIONS_INCLUDED, listSectionsIncluded);
		returnValue.put(CW_CapabilitiesUtilities.CHECKS_MAP, checksMap);
		returnValue.put(CW_CapabilitiesUtilities.RAW_DATA, rawData);
		return returnValue;
	}

	/**
	 * @description		Generate the full value to return and be used by the front end to render the capabilities tables
	 * @param			id <The id to filter the account role detail>
	 * @return			The full value to return and be used by the front end to render the capabilities tables
	 */
	@AuraEnabled
	public static Map<String, Object> getCapabilitiesFromAccountRoleDetailId(String id) {
		return getCapabilitiesInternal(id, null);
	}

	/**
	 * @description		Generate the full value to return and be used by the front end to render the capabilities tables
	 * @param			id <The id to filter the account role detail>
	 * @param			capabilitiesIdForConflicts Id List of capabilities with conflicts
	 * @return			The full value to return and be used by the front end to render the capabilities tables
	 */
	@AuraEnabled
	public static Map<String, Object> getCapabilitiesInternal(String id, List<String> capabilitiesIdForConflicts) {
		Map<String, Object> returnValue = new Map<String, Object>{ CW_CapabilitiesUtilities.SUPERCATEGORIES => new List<Map<String, Object>>() };

		try {
			Map<String, Object> prepareCapabilitiesData = CW_CapabilitiesUtilities.prepareCapabilityData(id);
			Map<String, List<String>> mapCategoriesByRecordTypeDevName = (Map<String, List<String>>) prepareCapabilitiesData.get(CW_CapabilitiesUtilities.MAP_CATEGORIES_BY_RECORDTYPE_DEVNAME);
			Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById = (Map<Id, RecordType>) prepareCapabilitiesData.get(CW_CapabilitiesUtilities.MAP_ARD_ASSIGNMENT_RTS_BY_ID);
			ICG_Account_Role_Detail__c accountRoleDetailFound = (ICG_Account_Role_Detail__c) prepareCapabilitiesData.get(CW_CapabilitiesUtilities.ARD_FOUND);
			List<String> categoriesToRetrieve = (List<String>) prepareCapabilitiesData.get(CW_CapabilitiesUtilities.CATEGORIES_TO_RETRIEVE);

			if (mapAccountRoleDetailAssignmentRtsById.isEmpty() || categoriesToRetrieve == null) {
				return returnValue;
			}

			Map<String, Object> generatedData = generateData(id, categoriesToRetrieve, mapCategoriesByRecordTypeDevName, mapAccountRoleDetailAssignmentRtsById, capabilitiesIdForConflicts, accountRoleDetailFound,validationPrograms);

			return CW_CapabilitiesUtilities.generateReturnValue(id, generatedData,false);
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
	public static List<Account_Role_Detail_Capability__c> getCapabilitiesNotIncludedDetail(Map<String, List<String>> mapCapabilitiesNotIncluded, Map<String, String> mapRecordTypeIdByCategory) {
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

	/**
	 * @description	Set the visibility of the files
	 * @param			id Account_Role_Detail_Capability__c Id
	 * @param			field field of Account_Role_Detail_Capability__c
	 * @param			content value of the field of Account_Role_Detail_Capability__c
	 * @return			Object that the value referes to Account_Role_Detail_Capability__c
	 */
	@AuraEnabled
	public static Object setVisibilityPhotos(String id,String field, String content) {		
		SObject sObj = new Account_Role_Detail_Capability__c();
		sObj.put('Id', id);
		sObj.put(field, content);

		try {
			Account_Role_Detail_Capability__c parseCapability = (Account_Role_Detail_Capability__c) sObj;
			update parseCapability;
			return JSON.deserializeUntyped((String)parseCapability.get(field));
		} catch (Exception e) {
			return e.getMessage();
		}
	}

	/**
	 * @description	    Compare Capabilities
	 * @param			accountRoleDetailRT Record Type related to Account_Role_Detail_Capability__c
	 * @return			Map superCategories: ComparisonSuperCategoryWrapper
	 */
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
				if (((List<String>) cSuperCategoryMap.get(CW_CapabilitiesUtilities.SECTIONS)).contains((String) currentRtsBySection.get('label'))) {
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

									List<List<Map<String, Object>>> columnsByRtAndGroup = CW_FacilityCapabilitiesController.getColumnsByRtAndGroup(new Account_Role_Detail_Capability__c(), fieldsByRecordTypeAndCategory.get(currentRt.toLowerCase() + '#' + currentCategory), fieldsByGroupField);

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

			returnValue.put(CW_CapabilitiesUtilities.SUPERCATEGORIES, supercategories);
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

	/**
	 * @description	    Map Item
	 * @param			data list of a map item
	 * @param			key field name
	 * @param			value value of the field name
	 * @return			Map<String, Object> with the new values
	 */
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

	/**
	 * @description	    Convert Account_Role_Detail_Capability__c to Map<String, Object>
	 * @param			itemToConvert Account_Role_Detail_Capability__c
	 * @param			fieldsToGet field to retrieve
	 * @param			fieldsMap mapped fields
	 * @return			Converted object
	 */
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

	/**
	 * @description		Generate picklist value from Schema.DescribeFieldResult
	 * @param			fieldResult - Schema.DescribeFieldResult 
	 * @return			Map<String, Schema.PicklistEntry>
	 */
	public static Map<String, Schema.PicklistEntry> generatePicklistMap(Schema.DescribeFieldResult fieldResult) {
		Map<String, Schema.PicklistEntry> mapObjs = new Map<String, Schema.PicklistEntry>();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for (Schema.PicklistEntry pickListVal : ple) {
			mapObjs.put(pickListVal.getValue().toLowerCase(), pickListVal);
		}

		return mapObjs;
	}

	/**
	 * @description		Generate picklist value from Schema.DescribeFieldResult based on Account_Role_Detail_Capability__c.Equipment__c
	 * @param			fieldResult - Schema.DescribeFieldResult 
	 * @return			Map<String, Schema.PicklistEntry>
	 */
	public static Map<String, Schema.PicklistEntry> getPicklistEntryMapCapEquipment() {
		Schema.DescribeFieldResult fieldResult = Account_Role_Detail_Capability__c.Equipment__c.getDescribe();
		return generatePicklistMap(fieldResult);
	}

	/**
	 * @description		Generate picklist value from Schema.DescribeFieldResult based on Account_Role_Detail_Capability__c.Category__c
	 * @param			fieldResult - Schema.DescribeFieldResult 
	 * @return			Map<String, Schema.PicklistEntry>
	 */
	public static Map<String, Schema.PicklistEntry> getPicklistEntryMapCapCategory() {
		Schema.DescribeFieldResult fieldResult = Account_Role_Detail_Capability__c.Category__c.getDescribe();
		return generatePicklistMap(fieldResult);
	}

	/**
	 * @description		Convert object to List<List<Map<String, Object>>>
	 * @param			item - object 
	 * @param			fieldsName - list of fields that will be cover
	 * @param			fieldGroups - list of map fields
	 * @return			List<List<Map<String, Object>>> with related fieds: 'colspan', 'name', 'label', 'isformula', 'type', 'values', 'isfileupload'
	 */
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

				lastHeader.add(new Map<String, Object>{ 
					'colspan' => 1, 'name' => fieldName, 'label' => currentLabel,
					 'isformula' => fieldMap.get(fieldName).getDescribe().isCalculated(),
					  'type' => fieldMap.get(fieldName).getDescribe().getType().name(), 
					  'values' => pickListValuesList,
					  'isfileupload' => (fieldName == 'more_info_document__c'),
					  'isManufacturerField' => (fieldName == 'sc_manufacturer__c'),
					  'isurlfield' => fieldMap.get(fieldName).getDescribe().getType().name() == 'URL'
					 });

				if (!foundGroup) {
					firstHeader.add(new Map<String, Object>{
						 'colspan' => 1, 'name' => fieldName, 'label' => '', 
						 'isformula' => fieldMap.get(fieldName).getDescribe().isCalculated(),
						  'type' => fieldMap.get(fieldName).getDescribe().getType().name(),
						   'values' => pickListValuesList,
						   'isfileupload' => (fieldName == 'more_info_document__c'),
						   'isManufacturerField' => (fieldName == 'sc_manufacturer__c'),
					  	   'isurlfield' => fieldMap.get(fieldName).getDescribe().getType().name() == 'URL'
						 });
				}
			}
		}
		if (includeFirstHeader) {
			headers.add(firstHeader);
		}
		headers.add(lastHeader);
		return headers;
	}

	/**
	 * @description		Auto map and fill an object
	 * @param			objectName - object name
	 * @param			fieldsToRetrieve - list of fields to retrive
	 * @param			fieldsMap - list of map fields
	 * @return			List of strings with the fields of the object received by parameters
	 */
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

	/**
	 * @description		Update the summary json in the ICG_Account_Role_Detail__c
	 * @param			icgAccountRoleDetailId - AICG_Account_Role_Detail__c Id
	 * @param			jsonData -Summary_Detail_Check_JSON__c
	 * @return			ICG_Account_Role_Detail__c
	 */
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
		CW_Utilities.ResponseBody res = new CW_Utilities.ResponseBody();
		List<Account_Role_Detail_Capability__c> listAccRoleCapabInserted;

		if (!String.isBlank(accRoleDet)) {
			try {
				//delete files to sf backend
				res.success = deleteFileAssigmentPrevious(accRoleDet, listAddedRows);

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
	public static ICG_Capability_Assignment_Group__c createCapabAssigmentGroup(String accRoleDet) {
		ICG_Capability_Assignment_Group__c addCapabAssgmGroup = new ICG_Capability_Assignment_Group__c();

		List<ICG_Capability_Assignment_Group__c> groupNC = [SELECT Id FROM ICG_Capability_Assignment_Group__c WHERE RecordTypeId =:RT_NO_CERTIFICATION_REQUIRED
		 AND ICG_Account_Role_Detail__c =:accRoleDet];

		 if(groupNC.size()>0){
			delete groupNC;
		 }
		 
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
		List<CW_Utilities.CapabilityWrapper> listCapWrapper = new List<CW_Utilities.CapabilityWrapper>();
		List<Account_Role_Detail_Capability__c> listToInsert = new List<Account_Role_Detail_Capability__c>();

		//Extract all capabilities from input
		for (Object capability : capabilitiesList) {
			CW_Utilities.CapabilityWrapper c = (CW_Utilities.CapabilityWrapper) JSON.deserialize(JSON.serializePretty(capability), CW_Utilities.CapabilityWrapper.class);
			listCapWrapper.add(c);
		}

		//Read all capabilities wrapper
		for (CW_Utilities.CapabilityWrapper c : listCapWrapper) {
			SObject sObj = new Account_Role_Detail_Capability__c();

			if(String.isNotBlank(c.id) && String.isNotEmpty(c.id)){
				sObj.put('Id', c.id);
			}

			sObj.put('RecordTypeId', c.rtypeId);
			sObj.put('Category__c', c.category);
			sObj.put('Equipment__c', c.equipment);

			for (CW_Utilities.CapabilityFieldsWrapper capfield : c.fields) {
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
		upsert listToInsert;

		return listToInsert;
	}

	/**
	 * @description		assign Capability with Group
	 * @param			accRoleDet - Account Role Detail Id, accRoleCapabId - Account Role Capab Id, capabAssigmenGroup - Capab Assigment Group and ardCertId - Account Role Detail Certi Id
	 * @return			Boolean true or false
	 */
	public static Boolean assignCapabilityAndGroup(String accRoleDet, ICG_Capability_Assignment_Group__c capabAssigmenGroup, List<Account_Role_Detail_Capability__c> listAccRoleCapabId) {
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

	/**
	 * @description		delete assigment previous of the group
	 * @param			accRoleDet - Account Role Detail Id, capabAssigmenGroup - Capab Assigment Group
	 * @return			Boolean true or false
	 */
	public static Boolean deleteFileAssigmentPrevious(String accRoleDet, List<Object> capabilitiesList) {
		Boolean result = true;
		Map<String, Schema.SObjectField> fieldMapCap = Schema.getGlobalDescribe().get('Account_Role_Detail_Capability__c').getDescribe().fields.getMap();
		List<CW_Utilities.CapabilityWrapper> listCapWrapper = new List<CW_Utilities.CapabilityWrapper>();
		Set<Id> currentListId = new Set<Id>();
		Set<Id> currentFilesId = new Set<Id>();

		//Extract all capabilities from input
		for (Object capability : capabilitiesList) {
			CW_Utilities.CapabilityWrapper c = (CW_Utilities.CapabilityWrapper) JSON.deserialize(JSON.serializePretty(capability), CW_Utilities.CapabilityWrapper.class);
			if(String.isNotBlank(c.id) && String.isNotEmpty(c.id)){
				currentListId.add(c.id);

				//Read all file Id in photos__c field input
				for(CW_Utilities.CapabilityFieldsWrapper capfield : c.fields){
					if (capfield.field.equals('photos__c') || capfield.field.equals('more_info_document__c')){
						if(String.isNotEmpty(capfield.value)){
							List<CapabilityPhoto> photoList = (List<CapabilityPhoto>) JSON.deserialize(capfield.value, List<CapabilityPhoto>.class);
							for(CapabilityPhoto photo : photoList){
								currentFilesId.add(photo.id);
							}
						}
					}
				}
			}	
		}
		
		try {
			List<ICG_Account_Role_Capability_Assignment__c> assigmentList = [SELECT Account_Role_Detail_Capability__r.Photos__c, Account_Role_Detail_Capability__r.More_Info_Document__c 
				FROM ICG_Account_Role_Capability_Assignment__c 
				WHERE ICG_Account_Role_Detail__c =: accRoleDet ];

			List<ICG_Account_Role_Capability_Assignment__c> assigmentListDissociated = new List<ICG_Account_Role_Capability_Assignment__c>();
			List<ICG_Account_Role_Capability_Assignment__c> assigmentListAssociated = new List<ICG_Account_Role_Capability_Assignment__c>();
			
			for(ICG_Account_Role_Capability_Assignment__c assigment : assigmentList){
				if (assigment.Account_Role_Detail_Capability__c != null && currentListId.contains(assigment.Account_Role_Detail_Capability__c)){
					assigmentListAssociated.add(assigment);
				}
				else{
					assigmentListDissociated.add(assigment);
				}
			}

			List<Id> filesToDeleteId = new List<Id>();
			
			//Read files to capabilities removed
			filesToDeleteId.addAll(deleteFileDissociatedFromCapabilities(assigmentListDissociated, accRoleDet));
			//Read files deleted in process
			filesToDeleteId.addAll(deleteFileFromCapabilities(assigmentListAssociated, accRoleDet, currentFilesId));

			if(filesToDeleteId.size()>0){
				Database.delete(filesToDeleteId, false);
			}
		} catch (Exception e) {
			result = false;
		}

		return result;
	}

	/**
	 * @description		Delete files that there is no relation with capabilities
	 * @param			accRoleDet - Account Role Detail Id, capabAssigmenGroup - Capab Assigment Group
	 * @return			Boolean true or false
	 */
	public static Set<Id> deleteFileDissociatedFromCapabilities(List<ICG_Account_Role_Capability_Assignment__c> assigmentList, String accRoleDet) {
		Set<Id> filesToDeleteId = new Set<Id>();

		if(assigmentList.size() > 0){
			for(ICG_Account_Role_Capability_Assignment__c assigment : assigmentList){
				if(String.isNotEmpty(assigment.Account_Role_Detail_Capability__r.Photos__c)){
					List<CapabilityPhoto> photoList = (List<CapabilityPhoto>) JSON.deserialize(assigment.Account_Role_Detail_Capability__r.Photos__c, List<CapabilityPhoto>.class);
					for(CapabilityPhoto photo : photoList){
						filesToDeleteId.add(photo.id);
					}
				}
				if(String.isNotEmpty(assigment.Account_Role_Detail_Capability__r.More_Info_Document__c)){
					List<CapabilityPhoto> docList = (List<CapabilityPhoto>) JSON.deserialize(assigment.Account_Role_Detail_Capability__r.More_Info_Document__c, List<CapabilityPhoto>.class);
					for(CapabilityPhoto doc : docList){
						filesToDeleteId.add(doc.id);
					}
				}
			}
		}
		
		return filesToDeleteId;
	}

	/**
	 * @description		Read files deleted in process
	 * @param			accRoleDet - Account Role Detail Id, capabAssigmenGroup - Capab Assigment Group
	 * @param			currentFilesId - Id list of files
	 * @return			Boolean true or false
	 */
	public static Set<Id> deleteFileFromCapabilities(List<ICG_Account_Role_Capability_Assignment__c> assigmentList, String accRoleDet, Set<Id> currentFilesId) {
		Set<Id> filesToDeleteId = new Set<Id>();

		if(assigmentList.size() > 0){
			for(ICG_Account_Role_Capability_Assignment__c assigment : assigmentList){
				if(String.isNotEmpty(assigment.Account_Role_Detail_Capability__r.Photos__c)){
					List<CapabilityPhoto> photoList = (List<CapabilityPhoto>) JSON.deserialize(assigment.Account_Role_Detail_Capability__r.Photos__c, List<CapabilityPhoto>.class);
					for(CapabilityPhoto photo : photoList){
						if(!currentFilesId.contains(photo.id)){
							filesToDeleteId.add(photo.id);
						}
					}
				}
			}
		}
		
		return filesToDeleteId;
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
		public String internalExtension { get; set; }
		@AuraEnabled
		public String extension{
			get {
				if(String.isNotBlank(internalExtension)){
					return internalExtension;
				}
				else if(url.indexOf('.') > -1 && url.substringAfterLast('.').length() < 5){
					return url.substringAfterLast('.');
				}
				else if(label.indexOf('.') > -1){
					return label.substringAfterLast('.');
				}
				else{
					return null;
				}
			}
		}
		@AuraEnabled
		public Boolean visible { get; set; }
		@AuraEnabled
		public String url { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String id { get; set; }
	}

	public class DateExtraData {
		public DateExtraData(Account_Role_Detail_Capability__c cap){
			if (cap.Security_Equipment_Date__c != null)
				this.Security_Equipment_Date = cap.Security_Equipment_Date__c.day() + '/' + cap.Security_Equipment_Date__c.month() + '/' + cap.Security_Equipment_Date__c.year();
		
			if (cap.Quality_Control_Compliance_Date__c != null)
				this.Quality_Control_Compliance_Date = cap.Quality_Control_Compliance_Date__c.day() + '/' + cap.Quality_Control_Compliance_Date__c.month() + '/' + cap.Quality_Control_Compliance_Date__c.year();

			if (cap.Screeners_Performance_Date__c != null)
				this.Screeners_Performance_Date = cap.Screeners_Performance_Date__c.day() + '/' + cap.Screeners_Performance_Date__c.month() + '/' + cap.Screeners_Performance_Date__c.year();

			if (cap.System_Assurance_Date__c != null)
				this.System_Assurance_Date = cap.System_Assurance_Date__c.day() + '/' + cap.System_Assurance_Date__c.month() + '/' + cap.System_Assurance_Date__c.year();

			if (cap.Contract_Management_Date__c != null)
				this.Contract_Management_Date = cap.Contract_Management_Date__c.day() + '/' + cap.Contract_Management_Date__c.month() + '/' + cap.Contract_Management_Date__c.year();

		}
		public String Security_Equipment_Date {get;set;}
		public String Quality_Control_Compliance_Date {get;set;}
		public String Screeners_Performance_Date {get;set;}
		public String System_Assurance_Date {get;set;}
		public String Contract_Management_Date {get;set;}
	}
}