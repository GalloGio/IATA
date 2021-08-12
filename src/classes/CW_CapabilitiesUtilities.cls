/**
 * @description		Utilities class for handling shared capabilities functionality
 *
 * Edit Log:
 * @history			2020/07/10  |  sf-844  |  Creation.
 */
public with sharing class CW_CapabilitiesUtilities {
	public static final String MAP_CATEGORIES_BY_RECORDTYPE_DEVNAME = 'mapCategoriesByRecordTypeDevName';
	public static final String MAP_ARD_ASSIGNMENT_RTS_BY_ID = 'mapAccountRoleDetailAssignmentRtsById';
	public static final String ARD_FOUND = 'accountRoleDetailFound';
	public static final String CATEGORIES_TO_RETRIEVE = 'categoriesToRetrieve';
	public static final String SUPERCATEGORIES = 'superCategories';
	public static final String CAPABILITIES = 'capabilities';
	public static final String RAW_DATA = 'rawData';
	public static final String SECTIONS = 'sections';
	public static final String CATEGORIES_AVAILABLE = 'categoriesAvailables';
	public static final String CATEGORIES = 'categories';
	public static final String LIST_SECTIONS_INCLUDED = 'listSectionsIncluded';
	public static final String CHECKS_MAP = 'checksMap';
	public static final String COLUMNS = 'columns';
	public static final String ROWS = 'rows';
	public static final String HAS_ROWS = 'hasRows';
	public static final String CONTAINS_DATA = 'containsData';
	public static final String ACTIVE = 'Active';
	public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
	public static final String SMART_FACILITY_REMOTE_VALIDATION = 'Smart Facility Remote Validation';
	public static final String SFRV_MANAGERS = 'SFRV_MANAGERS';

	public final static String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');
	public final static String RT_NO_CERTIFICATION_REQUIRED = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'No_Certification_Required');

	public static Map<String, Schema.PicklistEntry> MAPEquipments;
	public static Map<String, Schema.SObjectField> MAPfields;
	public static Map<String, List<String>> MAPFieldsByGroupField;
	public static Map<String, List<String>> MAPTooltipFieldsByField;
	public static Map<String, List<String>> MAPFieldsByRecordTypeAndCategory;
	public static Map<String, String> MAPRecordTypeIdByCategory;

	/**
	 * @description		Generate a map containing record type information
	 * @param			mapCategoriesByRecordTypeDevName <Categories by record type dev name>
	 * @return			Map containing record type information
	 */
	public static Map<Id, RecordType> generateMapAccountRoleDetailAssignmentRtsById(Map<String, List<String>> mapCategoriesByRecordTypeDevName) {
		Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById = new Map<Id, RecordType>();
		for (RecordType currentRt : RecordTypeSingleton.getInstance().getRecordTypesBySObject('Account_Role_Detail_Capability__c')) {
			if (mapCategoriesByRecordTypeDevName.containsKey(currentRt.DeveloperName.toLowerCase())) {
				mapAccountRoleDetailAssignmentRtsById.put(currentRt.Id, currentRt);
			}
		}
		return mapAccountRoleDetailAssignmentRtsById;
	}

	/**
	 * @description		Generate a certification id based on
	 * @param			ardCertId <Account Role Detail Certification Id to filter>
	 * @return			Generated certification id
	 */
	public static String generateCertificationId(String ardCertId) {
		ICG_Capability_Assignment_Group__c ardCertCurrent = new ICG_Capability_Assignment_Group__c();
		String certificationId;
		if (ardCertId != null) {
			ardCertCurrent = [SELECT ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE id = :ardCertId];
			certificationId = ardCertCurrent.ICG_Certification__c;
		}

		return certificationId;
	}

	/**
	 * @description		Generate categories by developer name
	 * @param			mapCategoriesByRecordTypeDevName <Map with information of fields by record type>
	 * @param			categoriesToRetrieve <List of categories to be filtered>
	 * @return			Map of categories
	 */
	private static Map<String, List<String>> generateMapCategoriesByRecordTypeDevNameTmp(Map<String, List<String>> mapCategoriesByRecordTypeDevName, List<String> categoriesToRetrieve) {
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
		return mapCategoriesByRecordTypeDevNameTmp;
	}

	/**
	 * @description		Generate fields to retrieve from database
	 * @param			mapFieldsByRecordTypeAndCategory <Map with information of fields by record type and category>
	 * @param           mapTooltipFieldsByField <Map with information about fields for tooltips>
	 * @return			List containing fields to retrieve from database
	 */
	public static List<String> generateFieldsToRetrieve(Map<String, List<String>> mapFieldsByRecordTypeAndCategory, Map<String, List<String>> mapTooltipFieldsByField) {
		List<String> fieldsToRetrieve = new List<String>();
		for (List<String> fieldsGroup : mapFieldsByRecordTypeAndCategory.values()) {
			for (String field : fieldsGroup) {
				fieldsToRetrieve.add(field);
			}
		}

		// Get fields to use like a tooltip.
		for (List<String> fieldsGroup : mapTooltipFieldsByField.values()) {
			for (String field : fieldsGroup) {
				if (!fieldsToRetrieve.contains(field)) {
					fieldsToRetrieve.add(field);
				}
			}
		}

		return fieldsToRetrieve;
	}

	/**
	 * @description		Generate Map containing info about capabilities
	 * @param			mapCategoriesByRecordTypeDevName <Categories by record type dev name>
	 * @param			mapAccountRoleDetailAssignmentRtsById <Account role detail assignments record types by id>
	 * @param			categoriesToRetrieve <List of categories to retrieve>
	 * @return			Generated map with info about capabilities
	 */
	public static Map<String, Object> generateRawData(Map<String, List<String>> mapCategoriesByRecordTypeDevName, Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById, List<String> categoriesToRetrieve) {
		// Get equipments defined by category
		Map<String, List<Map<String, Object>>> equipmentsByCategory = CW_Utilities.getPicklistFieldDependencies('Account_Role_Detail_Capability__c', 'Category__c', 'Equipment__c', true);

		// Get fields for specific processing
		Map<String, List<String>> mapEquipmentValuesBySpecificProcessing = CW_FacilityCapabilitiesController.getMapEquipmentValuesBySpecificProcessing();

		// Get categoires map
		Map<String, Schema.PicklistEntry> mapCategories = CW_FacilityCapabilitiesController.getPicklistEntryMapCapCategory();

		Map<String, Object> rawData = new Map<String, Object>{ CW_CapabilitiesUtilities.CAPABILITIES => new List<Map<String, Object>>() };

		// Loop the record types to build the output data model
		for (RecordType currentRecordType : mapAccountRoleDetailAssignmentRtsById.values()) {
			String rtDevNameLC = currentRecordType.DeveloperName.toLowerCase();

			if (mapCategoriesByRecordTypeDevName.containsKey(rtDevNameLC)) {
				Map<String, Object> currentCapatibility = generateCurrentCapability(rtDevNameLC, mapCategoriesByRecordTypeDevName, mapCategories, categoriesToRetrieve, mapEquipmentValuesBySpecificProcessing, equipmentsByCategory, currentRecordType);
				((List<Object>) rawData.get(CW_CapabilitiesUtilities.CAPABILITIES)).add(currentCapatibility);
			}
		}
		return rawData;
	}

	/**
	 * @description		Generate the full value to return and be used by the front end to render the capabilities tables
	 * @param			id <The id to filter the account role detail>
	 * @param			generatedData <Map containing info about the generated data>
	 * @return			The full value to return and be used by the front end to render the capabilities tables
	 */
	public static Map<String, Object> generateReturnValue(String id, Map<String, Object> generatedData, Boolean isCapabilityManager) {
		Set<String> listSectionsIncluded = (Set<String>) generatedData.get(CW_CapabilitiesUtilities.LIST_SECTIONS_INCLUDED);
		CW_FacilityCapabilitiesController.SectionsWrapper checksMap = (CW_FacilityCapabilitiesController.SectionsWrapper) generatedData.get(CW_CapabilitiesUtilities.CHECKS_MAP);
		Map<String, Object> rawData = (Map<String, Object>) generatedData.get(CW_CapabilitiesUtilities.RAW_DATA);

		String userRoleAux = CW_Utilities.getUserRole(id);
		Boolean editModeAux = userRoleAux == 'Company Admin' || userRoleAux == 'Facility Manager';

		// Reorganice data in Super Categories and Sections
		List<Map<String, Object>> superCategories = new List<Map<String, Object>>();

		Map<String, List<String>> tooltipsBySuperCategory = CW_FacilityCapabilitiesController.getMapTooltipBySuperCategory();
		Map<String, List<String>> tooltipsBySection = CW_FacilityCapabilitiesController.getMapTooltipBySection();

		for (Map<String, Object> currentSuperCategory : CW_FacilityCapabilitiesController.getMapSectionsBySupercategory()) {
			Map<String, Object> currentSuperCategoryMap = new Map<String, Object>{ 'label' => currentSuperCategory.get('label'), 'order' => currentSuperCategory.get('order'), CW_CapabilitiesUtilities.SECTIONS => new List<Object>(), CW_CapabilitiesUtilities.CATEGORIES_AVAILABLE => 0, CW_CapabilitiesUtilities.CONTAINS_DATA => false };
			if (tooltipsBySuperCategory.containsKey(((String)currentSuperCategory.get('label')).toLowerCase())) {
				currentSuperCategoryMap.put('iconPath', tooltipsBySuperCategory.get(((String)currentSuperCategory.get('label')).toLowerCase())[0]);
				currentSuperCategoryMap.put('iconTooltip', tooltipsBySuperCategory.get(((String)currentSuperCategory.get('label')).toLowerCase())[1]);
			}
			List<String> sectionsInCurrentSuperCategory = (List<String>) currentSuperCategory.get(CW_CapabilitiesUtilities.SECTIONS);
			Boolean containDataSuperCategory = false;

			// Order capabilities by section
			List<Map<String, Object>> currentSections = new List<Map<String, Object>>();
			List<Map<String, Object>> mapRecordTypesBySection = CW_FacilityCapabilitiesController.getMapRecordTypesBySection();
			for (Map<String, Object> cSection : mapRecordTypesBySection) {
				String cSectionLabel = (String) cSection.get('label');
				Boolean includeSection = sectionsInCurrentSuperCategory.contains(cSectionLabel);

				if (includeSection) {
					Boolean containDataSection = false;
					for (String currentRecordType : (List<String>) cSection.get('rts')) {
						Map<String, Object> capabilityFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) rawData.get(CW_CapabilitiesUtilities.CAPABILITIES), 'name', currentRecordType.toLowerCase());
						if (capabilityFound != null) {
							if (checksMap != null) {
								String nameAux = (String) capabilityFound.get('name');
								CW_FacilityCapabilitiesController.ChecksWrapper checkWrapperAux = checksMap.capabilitiesMap.get(nameAux);
								if (checkWrapperAux != null) {
									capabilityFound.put('check_summary', checkWrapperAux.summary);
									capabilityFound.put('check_detail', checkWrapperAux.detail);
									capabilityFound.put('show_summary', editModeAux ? editModeAux : checkWrapperAux.summary);
									capabilityFound.put('show_detail', editModeAux ? editModeAux : checkWrapperAux.detail);
									capabilityFound.put('show_capability', editModeAux ? editModeAux : (checkWrapperAux.summary == true || checkWrapperAux.detail == true) || isCapabilityManager);
								}
							}

							Map<String, Object> currentSectionObject = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap(currentSections, 'label', cSectionLabel);
							if (currentSectionObject == null) {
								currentSectionObject = new Map<String, Object>{ 'label' => cSectionLabel, CW_CapabilitiesUtilities.CAPABILITIES => new List<Map<String, Object>>(), CW_CapabilitiesUtilities.CONTAINS_DATA => false };
								if (tooltipsBySection.containsKey(cSectionLabel.toLowerCase())) {
									currentSectionObject.put('iconPath', tooltipsBySection.get(cSectionLabel.toLowerCase())[0]);
									currentSectionObject.put('iconTooltip', tooltipsBySection.get(cSectionLabel.toLowerCase())[1]);
								}
								currentSections.add(currentSectionObject);
							}
							if (listSectionsIncluded.contains(currentRecordType)) {
								containDataSection = true;
								containDataSuperCategory = true;
							}

							((List<Map<String, Object>>) currentSectionObject.get(CW_CapabilitiesUtilities.CAPABILITIES)).add(capabilityFound);

							currentSuperCategoryMap.put(CW_CapabilitiesUtilities.CATEGORIES_AVAILABLE, ((Integer) currentSuperCategoryMap.get(CW_CapabilitiesUtilities.CATEGORIES_AVAILABLE) + ((List<Object>) capabilityFound.get(CW_CapabilitiesUtilities.CATEGORIES)).size()));
						}
					}
					//If it contains any sections from a capability
					if (containDataSection) {
						currentSections.get(currentSections.indexOf((Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap(currentSections, 'label', cSectionLabel))).put(CW_CapabilitiesUtilities.CONTAINS_DATA, true);
					}
				}
			}
			if (((Integer) currentSuperCategoryMap.get(CW_CapabilitiesUtilities.CATEGORIES_AVAILABLE)) > 0) {
				if (containDataSuperCategory) {
					currentSuperCategoryMap.put(CW_CapabilitiesUtilities.CONTAINS_DATA, true);
				}
				currentSuperCategoryMap.put(CW_CapabilitiesUtilities.SECTIONS, currentSections);
				superCategories.add(currentSuperCategoryMap);
			}
		}

		return new Map<String, Object>{ CW_CapabilitiesUtilities.SUPERCATEGORIES => superCategories };
	}

	/**
	 * @description		Generate tooltip map
	 * @param			mapTooltipFieldsByField <Map with information about fields for tooltips>
	 * @param			currentDetail <Current capability>
	 * @param			currentObject <Current object>
	 * @return			Generated tooltip map
	 */
	private static Map<String, String> generateTooltips(Map<String, List<String>> mapTooltipFieldsByField, SObject currentDetail, Map<String, Object> currentObject) {        
        Map<String, String> tooltips = new Map<String, String>();
		Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get(currentDetail.getSObjectType().getDescribe().getName()).getDescribe().fields.getMap();
		for (String tooltipFieldKey : mapTooltipFieldsByField.keySet()) {
			String tooltipKey = tooltipFieldKey;
			String tooltipValue;

			// The tooltip must have field and value
			if (tooltipFieldKey.contains('#')) {
				tooltipKey = tooltipFieldKey.split('#')[0];
				tooltipValue = tooltipFieldKey.split('#')[1];
			}
			if (currentObject.containsKey(tooltipKey)) {
				String tooltip = '';
				for (String tooltipField : mapTooltipFieldsByField.get(tooltipFieldKey)) {
					if (mfields.containsKey(tooltipField)) {
						if ((tooltipValue == null || ((String)currentDetail.get(tooltipField)).toLowerCase() == tooltipValue.toLowerCase())) {
							// Get the value from other field
							tooltip += currentDetail.get(tooltipField);
						}
					} else{
						// Set text defined in metadata
						tooltip += tooltipField;
					}
				}
				tooltips.put(tooltipFieldKey.toLowerCase(), tooltip);
			}
		}
		return (tooltips.size() > 0) ? tooltips : null;
	}

	/**
	 * @description		Check whether a capability is already added
	 * @param			capabilityGroupRowsFound
	 * @param			currentDetailId <id of current detail>
	 * @return			Boolean value whether capability is already added
	 */
	public static Boolean isCapabilityAdded(List<Object> capabilityGroupRowsFound, String currentDetailId) {
		Boolean capabilityAdded = false;
		for (Map<String, Object> currentCapabilityGroupRow : (List<Map<String, Object>>) capabilityGroupRowsFound) {
			if (!capabilityAdded && currentCapabilityGroupRow.get('id') == currentDetailId) {
				capabilityAdded = true;
			}
		}
		return capabilityAdded;
	}

	/**
	 * @description		Prepare capability data
	 * @param			id <ARD id>
	 * @return			Prepared capability data
	 */
	public static Map<String, Object> prepareCapabilityData(String id) {
		// Get all record types of Account_Role_Detail_Capability__c configured. If there are no valid record types, we leave.
		Map<String, List<String>> mapCategoriesByRecordTypeDevName = CW_FacilityCapabilitiesController.getMapCategoriesByRecordType();
		Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById = CW_CapabilitiesUtilities.generateMapAccountRoleDetailAssignmentRtsById(mapCategoriesByRecordTypeDevName);

		// Get account role detail to determine which categories need to show. If there are no categories, we leave.
		ICG_Account_Role_Detail__c accountRoleDetailFound = [SELECT Id, RecordType.DeveloperName, Summary_Detail_Check_JSON__c FROM ICG_Account_Role_Detail__c WHERE Id = :id];
		List<String> categoriesToRetrieve = CW_FacilityCapabilitiesController.getMapCategoriesByAccountRoleDetailRecordType().get(accountRoleDetailFound.RecordType.DeveloperName.toLowerCase());
		if (categoriesToRetrieve != null) {
			mapCategoriesByRecordTypeDevName = CW_CapabilitiesUtilities.generateMapCategoriesByRecordTypeDevNameTmp(mapCategoriesByRecordTypeDevName, categoriesToRetrieve);
		}

		Map<String, Object> returnValue = new Map<String, Object>();
		returnValue.put(CW_CapabilitiesUtilities.MAP_CATEGORIES_BY_RECORDTYPE_DEVNAME, mapCategoriesByRecordTypeDevName);
		returnValue.put(CW_CapabilitiesUtilities.MAP_ARD_ASSIGNMENT_RTS_BY_ID, mapAccountRoleDetailAssignmentRtsById);
		returnValue.put(CW_CapabilitiesUtilities.ARD_FOUND, accountRoleDetailFound);
		returnValue.put(CW_CapabilitiesUtilities.CATEGORIES_TO_RETRIEVE, categoriesToRetrieve);
		return returnValue;
	}

		/**
	 * @description		Generate capabilities properties
	 * @param			rtDevNameLC Account Role Detail Assignment Rt  
	 * @param			mapCategoriesByRecordTypeDevName <Categories by record type dev name>
	 * @param			mapCategories <Map of categories>
	 * @param			categoriesToRetrieve <List of categories to retrieve>
	 * @param			equipmentsByCategory,  
	 * @param			currentRecordType RecordType 
	 * @return			Map based on capability properties
	 */
	private static Map<String, Object> generateCurrentCapability(String rtDevNameLC, Map<String, List<String>> mapCategoriesByRecordTypeDevName, Map<String, Schema.PicklistEntry> mapCategories, List<String> categoriesToRetrieve, Map<String, List<String>> mapEquipmentValuesBySpecificProcessing, Map<String, List<Map<String, Object>>> equipmentsByCategory, RecordType currentRecordType) {
		Map<String, Object> currentCapatibility = new Map<String, Object>();
		currentCapatibility.put('name', rtDevNameLC);
		currentCapatibility.put('label', currentRecordType.Name);
		currentCapatibility.put('check_summary', true);
		currentCapatibility.put('check_detail', true);
		currentCapatibility.put('show_summary', true);
		currentCapatibility.put('show_detail', true);
		currentCapatibility.put('first_load_check', true);
		currentCapatibility.put('show_capability', true);
		currentCapatibility.put(CW_CapabilitiesUtilities.CATEGORIES, new List<Map<String, Object>>());
		currentCapatibility.put('summary', new List<Map<String, Object>>());
		currentCapatibility.put(CW_CapabilitiesUtilities.CONTAINS_DATA, false);
		currentCapatibility.put('isEditableRecordType', CW_FacilityCapabilitiesController.EDITABLE_RECORDTYPES.containsKey(rtDevNameLC));

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

				((List<Object>) currentCapatibility.get(CW_CapabilitiesUtilities.CATEGORIES)).add(new Map<String, Object>{ 'value' => mapCategories.get(currentCategory).getValue().toLowerCase(), 'label' => mapCategories.get(currentCategory).getLabel(), 'auxType' => auxType, CW_CapabilitiesUtilities.ROWS => new List<Map<String, Object>>(), CW_CapabilitiesUtilities.HAS_ROWS => false });
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

		return currentCapatibility;
	}

	/**
	 * @description		Generate capability found
	 * @param			capabilityFound <Original values to the capability>
	 * @param           currentDetail <The current detail>
	 * @return			Generated capability found
	 */
	public static Map<String, Object> generateCapabilityFound(Map<String, Object> capabilityFound, Account_Role_Detail_Capability__c currentDetail) {
		capabilityFound.put('rtypeId', currentDetail.RecordTypeId);

		if ((Boolean) capabilityFound.get(CW_CapabilitiesUtilities.CONTAINS_DATA) == false) {
			capabilityFound.put(CW_CapabilitiesUtilities.CONTAINS_DATA, true);
		}

		return capabilityFound;
	}

	/**
	 * @description		Generate category found
	 * @param			categoryFound
	 * @param			capabilityFound
	 * @param			mapFieldsByRecordTypeAndCategory
	 * @param			rtDevNameLC
	 * @param			currentDetail
	 * @param			mapFieldsByGroupField
	 * @param			columnsToHandle
	 * @param			isMultiRecordCapabilities
	 *
	 * @return			Generated category found
	 */
	public static Map<String, Object> generateCategoryFound(Map<String, Object> categoryFound, Map<String, Object> capabilityFound, Map<String, List<String>> mapFieldsByRecordTypeAndCategory, String rtDevNameLC, Account_Role_Detail_Capability__c currentDetail, Map<String, List<String>> mapFieldsByGroupField, Map<String, String> columnsToHandle, Boolean isMultiRecordCapabilities) {
		if (capabilityFound != null && !capabilityFound.containsKey(CW_CapabilitiesUtilities.COLUMNS)) {
			List<String> columns = mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase());

			for (String key : columnsToHandle.keySet()) {
				if (columns.contains(key)) {
					columns.remove(columns.indexOf(key));

					if (columnsToHandle.get(key) != null) {
						columns.add(columnsToHandle.get(key));
					}
				}
			}

			if (columns != null && categoryFound != null) {
				categoryFound.put(CW_CapabilitiesUtilities.COLUMNS, CW_FacilityCapabilitiesController.getColumnsByRtAndGroup(currentDetail, columns, mapFieldsByGroupField));
			}
		}

		if (categoryFound != null) {
			if ((Boolean) categoryFound.get(CW_CapabilitiesUtilities.HAS_ROWS) == false) {
				categoryFound.put(CW_CapabilitiesUtilities.HAS_ROWS, true);
			}

			categoryFound.put('isMultirecord', isMultiRecordCapabilities);
			categoryFound.put('isEditableRecordType', CW_FacilityCapabilitiesController.EDITABLE_RECORDTYPES.containsKey(rtDevNameLC));
		}

		return categoryFound;
	}
	/*********************************************************************************************************
	 * @name			generateCurrentObject
	 * @author			
	 * @created			01 / 09 / 2020
	 * @description		Updates a capability assigment group object with the given data in the attributes.
	 * Note: 			Suggestion for a future refactor: 
	 * 					These fields of CW_CapabilitiesUtilities (MAPEquipments, MAPfields, MAPFieldsByGroupField, MAPTooltipFieldsByField, MAPFieldsByRecordTypeAndCategory, MAPRecordTypeIdByCategory)
	 * 					could be used to reduce the amount of parameters in this method. They must be previusly loaded before the call. (e.g. getCapabilitiesByRecordTypeNotIncluded) 				
	 * @param			Map<String, Object> currentObject: Capability assigment objects by capability field
	 * 					String currentDetailId: ICG_Account_Role_Capability_Assignment__r.Account_Role_Detail_Capability__r.Id
	 *					Account_Role_Detail_Capability__c currentDetail: ICG_Account_Role_Capability_Assignment__r.Account_Role_Detail_Capability__c
	 *					List<Object> certifications: current ICG_Account_Role_Capability_Assignment__c List with its CW_Utilities.AsgmtGroupWrapper
	 *					String currentAssignmentRT: ICG_Account_Role_Capability_Assignment__c.ICG_Capability_Assignment_Group__r.RecordTypeId
	 *					Map<String, Object> capabilityFound: currentDetail RT and capability found boolean
	 *					Map<String, List<String>> mapFieldsByRecordTypeAndCategory: Assignment fields by RT And Category
	 *					String rtDevNameLC: Account Role Detail Assignment Rt  
	 *					Map<String, Schema.PicklistEntry> mapEquipments: Account_Role_Detail_Capability__c.Equipment__c picklist values
	 *					Map<String, List<String>> mapTooltipFieldsByField: ICG_capability_configuration__mdt data by key
	 *					Map<String, Schema.SObjectField> fieldsMap: Schema.SObjectType.Account_Role_Detail_Capability__c.fields
	 *					Boolean isMultiRecordCapabilities: is currentDetail.Category__c Multi_Record_Capabilities
	 *					Boolean isAssigned:
	 *					Boolean contains:
	 *					String stationRT: ICG_Account_Role_Detail__c
	 *					List<String> CERTIFICATIONS_ALLOWED_USER: Certification allowed by station
	 *					Boolean userHasPermissionToEdit: Has user profile One_Source_Backend_Admin permission set
	 * @return			Updated Capability object.
	**********************************************************************************************************/
	public static Map<String, Object> generateCurrentObject(Map<String, Object> currentObject, String currentDetailId,
	 Account_Role_Detail_Capability__c currentDetail, List<Object> certifications, String currentAssignmentRT, 
	 Map<String, Object> capabilityFound, Map<String, List<String>> mapFieldsByRecordTypeAndCategory, String rtDevNameLC,
	  Map<String, Schema.PicklistEntry> mapEquipments, Map<String, List<String>> mapTooltipFieldsByField,
	   Map<String, Schema.SObjectField> fieldsMap, Boolean isMultiRecordCapabilities, Boolean isAssigned, Boolean contains,String stationRT,
	   List<String> CERTIFICATIONS_ALLOWED_USER, Boolean userHasPermissionToEdit) {

		// Set data for summary
		Boolean emptyPhotos = false;
		Boolean emptyDocuments = false;
		Map<String, Object> capabilitySummaryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get('summary'), 'value', currentDetail.Equipment__c.toLowerCase());
		if (capabilitySummaryFound != null && (Boolean) capabilitySummaryFound.get('contains') == false) {
			capabilitySummaryFound.put('contains', contains);
		}

		List<String> requiredFields = CW_CapabilitiesManagerController.getRequiredFieldsForCapability(currentDetail, mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
		currentObject.put('requiredFields', requiredFields);

		Boolean isEditableRecordType = CW_FacilityCapabilitiesController.EDITABLE_RECORDTYPES.containsKey(rtDevNameLC);

		// Set processed info.
		currentObject.put('id', currentDetailId);
		if (mapEquipments.get(currentDetail.Equipment__c.toLowerCase()) != null) {
			currentObject.put('equipment__c', mapEquipments.get(currentDetail.Equipment__c.toLowerCase()).getLabel());
		} else {
			currentObject.put('equipment__c', currentDetail.Equipment__c);
		}
		currentObject.put('equipment', currentDetail.Equipment__c);
		currentObject.put('certifications', certifications);
		currentObject.put('isPeviouslyCertified', !certifications.isEmpty() || isEditableRecordType);

		// Set tooltips
		Map<String, String> tooltips = CW_CapabilitiesUtilities.generateTooltips(mapTooltipFieldsByField, currentDetail, currentObject);
		currentObject.put('tooltips', tooltips);

		if (String.isBlank(currentDetail.Photos__c)) {
			emptyPhotos = true;
			currentDetail.Photos__c = JSON.serialize(new List<CW_FacilityCapabilitiesController.CapabilityPhoto>());
		}
		try {
			currentObject.put('photos', JSON.deserialize(currentDetail.Photos__c, List<CW_FacilityCapabilitiesController.CapabilityPhoto>.class));
		} catch (Exception e_photos) {
			currentDetail.Photos__c = JSON.serialize(new List<CW_FacilityCapabilitiesController.CapabilityPhoto>());
			currentObject.put('photos', JSON.deserialize(currentDetail.Photos__c, List<CW_FacilityCapabilitiesController.CapabilityPhoto>.class));
		}

		
		if (String.isBlank(currentDetail.More_Info_Document__c)) {
			emptyDocuments = true;
			currentDetail.More_Info_Document__c = JSON.serialize(new List<CW_FacilityCapabilitiesController.CapabilityPhoto>());
		}
		try {
			currentObject.put('documents', JSON.deserialize(currentDetail.More_Info_Document__c, List<CW_FacilityCapabilitiesController.CapabilityPhoto>.class));
		} catch (Exception e_photos) {
			currentDetail.More_Info_Document__c = JSON.serialize(new List<CW_FacilityCapabilitiesController.CapabilityPhoto>());
			currentObject.put('documents', JSON.deserialize(currentDetail.More_Info_Document__c, List<CW_FacilityCapabilitiesController.CapabilityPhoto>.class));
		}
		

		currentObject.put('remotevalidation', currentAssignmentRT == RT_REMOTE_VALIDATION);
		currentObject.put('photosAvailable', ((String) currentDetail.Photos__c).remove(' ').toLowerCase().countMatches('"visible":true') > 0);
		currentObject.put('photosAvailableEdit', !emptyPhotos);
		currentObject.put('documentsAvailable', ((String) currentDetail.More_Info_Document__c).remove(' ').toLowerCase().countMatches('"visible":true') > 0);
		currentObject.put('documentsAvailableEdit', !emptyDocuments);
		currentObject.put('customClass', '');
		currentObject.put('isAssigned', isAssigned);
		currentObject.put('isNotEditable', true);
		currentObject.put('isAditional', false);
		currentObject.put('isMultirecord', isMultiRecordCapabilities);
		currentObject.put('isEditableRecordType', isEditableRecordType);
		currentObject.put('isNotCertiRequired', currentAssignmentRT == RT_NO_CERTIFICATION_REQUIRED);

		Boolean isValidationWithoutCertification=false;
		for(CW_Utilities.AsgmtGroupWrapper cert : (List<CW_Utilities.AsgmtGroupWrapper>)certifications){
			if(String.isNotBlank(cert.validationProgram) && !cert.validationProgram.toLowerCase().contains('iata')){
				isValidationWithoutCertification=true;
			}
			if(CERTIFICATIONS_ALLOWED_USER.contains(cert.name)){
				userHasPermissionToEdit=true;
				break;
			}
		}
		currentObject.put('isPermissionByDepartment',userHasPermissionToEdit);
		currentObject.put('isValidationWithoutCertification', isValidationWithoutCertification);

		return currentObject;
	}

	/**
	 * @description		Get a list of certification (List<ICG_Certification__c.Name>) filtered by ICG_Account_Role_Detail__c recordType
	 * @param			stationRT <ICG_Account_Role_Detail__c record type>
	 * @return			List of certifications
	 */
	public static List<String> getCertificationsAllowedByDepartments(String stationRT, String validationPrograms) {

		List<String> lstDepts = new List<String>();
		List<String> lstCertiAllowed = new List<String>();
		List<ICG_Certification__c> lstCerti;
		List<String> listValidationPrograms = new List<String>();
		if (String.isBlank(validationPrograms)){
			validationPrograms = 'NONE';
		}
		if(String.isNotBlank(validationPrograms)){
			listValidationPrograms = validationPrograms.split(',');
		}

		if (CW_Utilities.hasSpecialPermissionsToEdit()) {
			lstCerti = [SELECT Name, Label__c FROM ICG_Certification__c WHERE Applicable_to__c INCLUDES (:stationRT) AND ValidationPrograms__c IN :listValidationPrograms];
			lstCerti.add(new ICG_Certification__c(Name = SMART_FACILITY_REMOTE_VALIDATION, Label__c = SMART_FACILITY_REMOTE_VALIDATION));
		} else {
			List<Group> lstGroup = [SELECT Name, DeveloperName FROM Group WHERE Id IN (SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId())];
			Boolean existSFRM = false;
			for (Group g : lstGroup) {
				lstDepts.add(g.DeveloperName);
				if (g.DeveloperName == SFRV_MANAGERS) {
					existSFRM = true;
				}
			}
			lstCerti = [SELECT Name FROM ICG_Certification__c WHERE Department__c IN :lstDepts AND ValidationPrograms__c IN :listValidationPrograms];
			if (existSFRM) {
				lstCerti.add(new ICG_Certification__c(Name = SMART_FACILITY_REMOTE_VALIDATION, Label__c = SMART_FACILITY_REMOTE_VALIDATION));
			}
		}

		for (ICG_Certification__c c : lstCerti) {
			lstCertiAllowed.add(c.Name);
		}
		return lstCertiAllowed;
	}

	/**
	 * @description		Get a list of document filtered by accRoleDetail.Id
	 * @param			recordId <ICG_Account_Role_Detail__c.Id>
	 * @return			List of files (CW_AccountDetailCarousel.Carousel)
	 */
	public static List<CW_AccountDetailCarousel.Carousel> getCapabilitiesPhotosFromStation(String recordId) {
		List<String> acceptFormats = new List<String>{ 'pdf' };
		Map<String, CW_FacilityCapabilitiesController.CapabilityPhoto> photosCapab = new Map<String, CW_FacilityCapabilitiesController.CapabilityPhoto>();
		List<CW_AccountDetailCarousel.Carousel> photosCarousel = new List<CW_AccountDetailCarousel.Carousel>();

		for (ICG_Account_Role_Capability_Assignment__c assigment : [SELECT Account_Role_Detail_Capability__r.Photos__c,Account_Role_Detail_Capability__r.More_Info_Document__c,ICG_Capability_Assignment_Group__r.RecordTypeId FROM ICG_Account_Role_Capability_Assignment__c WHERE ICG_Account_Role_Detail__c = :recordId AND ICG_Capability_Assignment_Group__r.Status__c = :CW_CapabilitiesUtilities.ACTIVE]) {
			if (String.isNotEmpty(assigment.Account_Role_Detail_Capability__r.Photos__c)) {
				List<CW_FacilityCapabilitiesController.CapabilityPhoto> photoList = (List<CW_FacilityCapabilitiesController.CapabilityPhoto>) JSON.deserialize(assigment.Account_Role_Detail_Capability__r.Photos__c, List<CW_FacilityCapabilitiesController.CapabilityPhoto>.class);
				for (CW_FacilityCapabilitiesController.CapabilityPhoto photo : photoList) {
					if(assigment.ICG_Capability_Assignment_Group__r.RecordTypeId == RT_NO_CERTIFICATION_REQUIRED){
						photo.visible = false;
					}
					
					if (!photosCapab.containsKey(photo.id)) {
						photosCapab.put(photo.id, photo);
					}
				}
			}
			if (String.isNotEmpty(assigment.Account_Role_Detail_Capability__r.More_Info_Document__c)) {
				List<CW_FacilityCapabilitiesController.CapabilityPhoto> docList = (List<CW_FacilityCapabilitiesController.CapabilityPhoto>) JSON.deserialize(assigment.Account_Role_Detail_Capability__r.More_Info_Document__c, List<CW_FacilityCapabilitiesController.CapabilityPhoto>.class);
				for (CW_FacilityCapabilitiesController.CapabilityPhoto doc : docList) {
					if(assigment.ICG_Capability_Assignment_Group__r.RecordTypeId == RT_NO_CERTIFICATION_REQUIRED){
						doc.visible = false;
					}
					
					if (!photosCapab.containsKey(doc.id)) {
						photosCapab.put(doc.id, doc);
					}
				}
			}
		}

		Integer index = 0;
		for (CW_FacilityCapabilitiesController.CapabilityPhoto photoParse : photosCapab.values()) {
			CW_AccountDetailCarousel.Carousel car = new CW_AccountDetailCarousel.Carousel();
			car.id = photoParse.id;
			car.name = photoParse.label;
			car.tabindex = index == 0 ? '0' : '-1';
			car.position = 'slds-carousel__panels translate-x' + String.valueOf(index) + '00';
			car.hidden = index == 0 ? true : false;
			String indicatorClass = 'slds-carousel__indicator-action';
			indicatorClass = index == 0 ? indicatorClass + ' slds-is-active' : indicatorClass;
			car.indicatorClass = indicatorClass;
			String panelClass = 'slds-carousel__panel carousel-size';
			panelClass = index == 0 ? panelClass + ' panelSelected' : panelClass;
			car.panelClass = panelClass;
			String fileExtension = photoParse.extension;
			car.fileExtension = fileExtension;
			car.urlImage = photoParse.url;
			car.isInternal = false;
			car.isDocument = acceptFormats.contains(fileExtension);
			car.visible = photoParse.visible;
			photosCarousel.add(car);
			index++;
		}

		return photosCarousel;
	}

	/*********************************************************************************************************
	 * @name			getCapabilitiesByRecordTypeNotIncluded
	 * @author			
	 * @created			21 / 01 / 2021
	 * @description		Returns the mandatory capabilities (mandatory in the view side) that was not previously certified
	 * 					or assigned
	 * @param			CapabilityNotIncludedDTO dto
	 * @return			Set<String> not certified capabilities that must be shown
	**********************************************************************************************************/
		public static Set<String> getCapabilitiesByRecordTypeNotIncluded(CapabilityNotIncludedDTO dto){

		Set<String> listSectionsIncluded = new Set<String>();
		CW_FacilityCapabilitiesController.SectionsWrapper checksMap;
		Map<String, List<String>> capabilitiesByRecordTypeNotIncluded = new Map<String, List<String>>();

		for (Map<String, Object> capability : (List<Map<String, Object>>) dto.rawData.get(CAPABILITIES)) {
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
			List<Account_Role_Detail_Capability__c> accountCapabNotInluded = CW_FacilityCapabilitiesController.getCapabilitiesNotIncludedDetail(capabilitiesByRecordTypeNotIncluded, MAPRecordTypeIdByCategory);
			accountCapabNotInluded.sort();
			for (Account_Role_Detail_Capability__c currentDetail : accountCapabNotInluded) {
				listSectionsIncluded.add(dto.mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName);
				
				String rtDevNameLC = dto.mapAccountRoleDetailAssignmentRtsById.get(currentDetail.RecordTypeId).DeveloperName.toLowerCase();
				if (dto.mapCategoriesByRecordTypeDevName.containsKey(rtDevNameLC)) {
					// We look for the Capability, Category to which it belongs
					Map<String, Object> capabilityFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) dto.rawData.get(CAPABILITIES), 'name', rtDevNameLC);
					capabilityFound = generateCapabilityFound(capabilityFound, currentDetail);
					Map<String, Object> categoryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get(CATEGORIES), 'value', currentDetail.Category__c);
					categoryFound = generateCategoryFound(categoryFound, capabilityFound, MAPFieldsByRecordTypeAndCategory, rtDevNameLC, currentDetail, MAPFieldsByGroupField, dto.columnsToHandle, false);

					if (!String.isBlank(dto.accountRoleDetailFound.Summary_Detail_Check_JSON__c)) {
						checksMap = (CW_FacilityCapabilitiesController.SectionsWrapper) JSON.deserialize(dto.accountRoleDetailFound.Summary_Detail_Check_JSON__c, CW_FacilityCapabilitiesController.SectionsWrapper.class);
					}

					Map<String, Object> currentObject;
					if (categoryFound != null && categoryFound.containsKey(ROWS)) {
						List<Object> capabilityGroupRowsFound = (List<Object>) categoryFound.get(ROWS);
						currentObject = CW_CapabilitiesManagerController.cleanCapabilitiesFieldsToObject(currentDetail, MAPFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), MAPfields);
						currentObject = generateCurrentObject(currentObject, '', currentDetail, new List<CW_Utilities.AsgmtGroupWrapper>(), '', capabilityFound, MAPFieldsByRecordTypeAndCategory, rtDevNameLC,
						MAPEquipments, MAPTooltipFieldsByField, MAPfields, false, false, false, dto.stationRT, dto.certificationsAllowedUser, dto.userHasPermissionToEdit);
						capabilityGroupRowsFound.add(currentObject);
					}
					categoryFound.put('templateFields', currentObject);
				}
			}
		}
		return listSectionsIncluded;
	}
	
	/*********************************************************************************************************
	* Map<String, Object> rawData: Capability objects by field (name, label, check_summary ...)
	* ICG_Account_Role_Detail__c accountRoleDetailFound: Capability account role detail
	* Map<String, List<String>> mapFieldsByRecordTypeAndCategory: ICG_capability_configuration__mdt data by key
	* Map<String, String> mapRecordTypeIdByCategory: List of categories by record type
	* Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById: Account role detail assignment record types by ids
	* Map<String, List<String>> mapCategoriesByRecordTypeDevName: Category record types by developer name
	* Map<String, List<String>> mapFieldsByGroupField: ICG_capability_configuration__mdt data by key 
	* Map<String, String> columnsToHandle: Colums to generate category found
	* Map<String, Schema.PicklistEntry> mapEquipments: Account_Role_Detail_Capability__c.Equipment__c picklist values
	* Map<String, List<String>> mapTooltipFieldsByField: ICG_capability_configuration__mdt data by key
	* Map<String, Schema.SObjectField> fieldsMap: Schema.SObjectType.Account_Role_Detail_Capability__c.fields
	* String stationRT: Certification station record type
	* List<String> certificationsAllowedUser: Certification allowed by station
	* Boolean userHasPermissionToEdit: Has user profile One_Source_Backend_Admin permission set
	**********************************************************************************************************/
	public class CapabilityNotIncludedDTO {
		public Map<String, Object> rawData;
		public ICG_Account_Role_Detail__c accountRoleDetailFound;
		public Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById;
		public Map<String, List<String>> mapCategoriesByRecordTypeDevName;
		public Map<String, String> columnsToHandle;
		public String stationRT;
		public List<String> certificationsAllowedUser;
		public Boolean userHasPermissionToEdit;
		
		public CapabilityNotIncludedDTO(Map<String, Object> rawData, ICG_Account_Role_Detail__c accountRoleDetailFound, 
										Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById, Map<String, List<String>> mapCategoriesByRecordTypeDevName, 
										Map<String, String> columnsToHandle, String stationRT, 
										List<String> certificationsAllowedUser, Boolean userHasPermissionToEdit){
			this.rawData = rawData;
			this.accountRoleDetailFound = accountRoleDetailFound;
			this.mapAccountRoleDetailAssignmentRtsById = mapAccountRoleDetailAssignmentRtsById;
			this.mapCategoriesByRecordTypeDevName = mapCategoriesByRecordTypeDevName;
			this.columnsToHandle = columnsToHandle;
			this.stationRT = stationRT;
			this.certificationsAllowedUser = certificationsAllowedUser;
			this.userHasPermissionToEdit = userHasPermissionToEdit;
		}
	}
}