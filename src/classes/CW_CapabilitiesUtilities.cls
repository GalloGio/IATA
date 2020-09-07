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
    
    public final static String RT_REMOTE_VALIDATION = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Remote_Validation');

    /**
     * @description		Generate a map containing record type information
     * @param			mapCategoriesByRecordTypeDevName <Categories by record type dev name>
     * @return			Map containing record type information
     */
    public static Map<Id, RecordType> generateMapAccountRoleDetailAssignmentRtsById(Map<String, List<String>> mapCategoriesByRecordTypeDevName){
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
    public static String generateCertificationId(String ardCertId){
        ICG_Capability_Assignment_Group__c ardCertCurrent = new ICG_Capability_Assignment_Group__c();
        String certificationId;
        if(ardCertId != null){
            ardCertCurrent = [SELECT ICG_Certification__c FROM ICG_Capability_Assignment_Group__c WHERE id = :ardCertId];
            certificationId = ardCertCurrent.ICG_Certification__c;
        }

        return certificationId;
    }

    
    private static Map<String, List<String>> generateMapCategoriesByRecordTypeDevNameTmp(
        Map<String, List<String>> mapCategoriesByRecordTypeDevName, 
        List<String> categoriesToRetrieve
    ){
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
    public static List<String> generateFieldsToRetrieve(Map<String, List<String>> mapFieldsByRecordTypeAndCategory, Map<String, List<String>> mapTooltipFieldsByField){
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
    public static Map<String, Object> generateRawData(
        Map<String, List<String>> mapCategoriesByRecordTypeDevName, 
        Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById,
        List<String> categoriesToRetrieve
    ){

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
                Map<String, Object> currentCapatibility = generateCurrentCapability(
                    rtDevNameLC,
                    mapCategoriesByRecordTypeDevName, 
                    mapCategories,
                    categoriesToRetrieve,
                    mapEquipmentValuesBySpecificProcessing,
                    equipmentsByCategory,
                    currentRecordType
                );
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
    public static Map<String, Object> generateReturnValue(
        String id,
        Map<String, Object> generatedData
    ){

        Set<String> listSectionsIncluded = (Set<String>) generatedData.get(CW_CapabilitiesUtilities.LIST_SECTIONS_INCLUDED);
        CW_FacilityCapabilitiesController.SectionsWrapper checksMap = (CW_FacilityCapabilitiesController.SectionsWrapper) generatedData.get(CW_CapabilitiesUtilities.CHECKS_MAP);
        Map<String, Object> rawData = (Map<String, Object>) generatedData.get(CW_CapabilitiesUtilities.RAW_DATA);

        String userRoleAux = CW_Utilities.getUserRole(id);
        Boolean editModeAux = userRoleAux == 'Company Admin' || userRoleAux == 'Facility Manager';

        // Reorganice data in Super Categories and Sections
        List<Map<String, Object>> superCategories = new List<Map<String, Object>>();

        for (Map<String, Object> currentSuperCategory : CW_FacilityCapabilitiesController.getMapSectionsBySupercategory()) {
            Map<String, Object> currentSuperCategoryMap = new Map<String, Object>{ 'label' => currentSuperCategory.get('label'), 'order' => currentSuperCategory.get('order'), CW_CapabilitiesUtilities.SECTIONS => new List<Object>(), CW_CapabilitiesUtilities.CATEGORIES_AVAILABLE => 0, CW_CapabilitiesUtilities.CONTAINS_DATA => false };
            List<String> sectionsInCurrentSuperCategory = (List<String>) currentSuperCategory.get(CW_CapabilitiesUtilities.SECTIONS);
            Boolean containDataSuperCategory = false;

            // Order capabilities by section
            List<Map<String, Object>> currentSections = new List<Map<String, Object>>();
            List<Map<String, Object>> mapRecordTypesBySection = CW_FacilityCapabilitiesController.getMapRecordTypesBySection();
            for (Map<String, Object> cSection : mapRecordTypesBySection) {
                Boolean includeSection = sectionsInCurrentSuperCategory.contains((String) cSection.get('label'));

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
                                    capabilityFound.put('show_capability', editModeAux ? editModeAux : checkWrapperAux.summary == true || checkWrapperAux.detail == true);
                                }
                            }

                            Map<String, Object> currentSectionObject = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap(currentSections, 'label', (String) cSection.get('label'));
                            if (currentSectionObject == null) {
                                currentSectionObject = new Map<String, Object>{ 'label' => (String) cSection.get('label'), CW_CapabilitiesUtilities.CAPABILITIES => new List<Map<String, Object>>(), CW_CapabilitiesUtilities.CONTAINS_DATA => false };
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
                        currentSections.get(currentSections.indexOf((Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap(currentSections, 'label', (String) cSection.get('label')))).put(CW_CapabilitiesUtilities.CONTAINS_DATA, true);
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
    private static Map<String, String> generateTooltips(
        Map<String, List<String>> mapTooltipFieldsByField,
        Account_Role_Detail_Capability__c currentDetail,
        Map<String, Object> currentObject
    ){
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
        return (tooltips.size() > 0) ? tooltips : null;
    }

    /**
     * @description		Check whether a capability is already added
     * @param			capabilityGroupRowsFound
     * @param			currentDetailId <id of current detail>
     * @return			Boolean value whether capability is already added
     */
    public static Boolean isCapabilityAdded(List<Object> capabilityGroupRowsFound, String currentDetailId){
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
    public static Map<String, Object> prepareCapabilityData(String id){
        // Get all record types of Account_Role_Detail_Capability__c configured. If there are no valid record types, we leave.
        Map<String, List<String>> mapCategoriesByRecordTypeDevName = CW_FacilityCapabilitiesController.getMapCategoriesByRecordType();
        Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById = CW_CapabilitiesUtilities.generateMapAccountRoleDetailAssignmentRtsById(mapCategoriesByRecordTypeDevName);


        // Get account role detail to determine which categories need to show. If there are no categories, we leave.
        ICG_Account_Role_Detail__c accountRoleDetailFound = [SELECT Id, RecordType.DeveloperName,Summary_Detail_Check_JSON__c FROM ICG_Account_Role_Detail__c WHERE Id = :id];
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

    private static Map<String, Object> generateCurrentCapability(
        String rtDevNameLC,
        Map<String, List<String>> mapCategoriesByRecordTypeDevName, 
        Map<String, Schema.PicklistEntry> mapCategories,
        List<String> categoriesToRetrieve,
        Map<String, List<String>> mapEquipmentValuesBySpecificProcessing,
        Map<String, List<Map<String, Object>>> equipmentsByCategory,
        RecordType currentRecordType
    ){



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
        if(CW_FacilityCapabilitiesController.EDITABLE_RECORDTYPES != null){
            currentCapatibility.put('isEditableRecordType', CW_FacilityCapabilitiesController.EDITABLE_RECORDTYPES.get('Editable_RecordTypes').contains(rtDevNameLC));
        }

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
    public static Map<String, Object> generateCapabilityFound(Map<String, Object> capabilityFound, Account_Role_Detail_Capability__c currentDetail){
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
    public static Map<String, Object> generateCategoryFound(
		Map<String, Object> categoryFound,
		Map<String, Object> capabilityFound,
		Map<String, List<String>> mapFieldsByRecordTypeAndCategory,
		String rtDevNameLC,
		Account_Role_Detail_Capability__c currentDetail,
        Map<String, List<String>> mapFieldsByGroupField,
        Map<String, String> columnsToHandle,
		Boolean isMultiRecordCapabilities
	){
		if (capabilityFound != null && !capabilityFound.containsKey(CW_CapabilitiesUtilities.COLUMNS)) {
            List<String> columns = mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase());

            for(String key : columnsToHandle.keySet()){
                if(columns.contains(key)){
                    columns.remove(columns.indexOf(key));

                    if(columnsToHandle.get(key) != null){
                        columns.add(columnsToHandle.get(key));
                    }
                }
            }

            if (columns != null && categoryFound != null) {
                categoryFound.put(CW_CapabilitiesUtilities.COLUMNS, CW_FacilityCapabilitiesController.getColumnsByRtAndGroup(currentDetail, columns, mapFieldsByGroupField));
            }
        }

        if (categoryFound != null && (Boolean) categoryFound.get(CW_CapabilitiesUtilities.HAS_ROWS) == false) {
            categoryFound.put(CW_CapabilitiesUtilities.HAS_ROWS, true);
        }

        categoryFound.put('isMultirecord', isMultiRecordCapabilities);        
        categoryFound.put('isEditableRecordType', CW_FacilityCapabilitiesController.EDITABLE_RECORDTYPES.get('Editable_RecordTypes').contains(rtDevNameLC));

		return categoryFound;
    }
    
    public static Map<String, Object> generateCurrentObject(
		Map<String, Object> currentObject, 
		String currentDetailId, 
		Account_Role_Detail_Capability__c currentDetail,
		List<Object> certifications, 
		String currentAssignmentRT,
		Map<String, Object> capabilityFound,
		Map<String, List<String>> mapFieldsByRecordTypeAndCategory,
		String rtDevNameLC,
		Map<String, Schema.PicklistEntry> mapEquipments,
		Map<String, List<String>> mapTooltipFieldsByField,
        Map<String, Schema.SObjectField> fieldsMap,
        Boolean isMultiRecordCapabilities,
        Boolean isAssigned,
        Boolean contains
	){
		// Set data for summary
		Map<String, Object> capabilitySummaryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get('summary'), 'value', currentDetail.Equipment__c.toLowerCase());
		if (capabilitySummaryFound != null && (Boolean) capabilitySummaryFound.get('contains') == false) {
			capabilitySummaryFound.put('contains', contains);
		}

		List<String> requiredFields = CW_CapabilitiesManagerController.getRequiredFieldsForCapability(currentDetail, mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
		currentObject.put('requiredFields', requiredFields);

		// Set processed info.
		currentObject.put('id', currentDetailId);
		currentObject.put('equipment__c', mapEquipments.get(currentDetail.Equipment__c.toLowerCase()).getLabel());
		currentObject.put('equipment_value', currentDetail.Equipment__c);
		currentObject.put('certifications', certifications);
		currentObject.put('isPeviouslyCertified', !certifications.isEmpty());

		// Set tooltips
		Map<String, String> tooltips = CW_CapabilitiesUtilities.generateTooltips(mapTooltipFieldsByField, currentDetail, currentObject);
		currentObject.put('tooltips', tooltips);

		if (String.isBlank(currentDetail.Photos__c)) {
			currentDetail.Photos__c = JSON.serialize(new List<Map<String, Object>>());
		}
		try {
			currentObject.put('photos', JSON.deserializeUntyped(currentDetail.Photos__c));
		} catch (Exception e_photos) {
			currentDetail.Photos__c = JSON.serialize(new List<Map<String, Object>>());
			currentObject.put('photos', JSON.deserializeUntyped(currentDetail.Photos__c));
		}
		currentObject.put('remotevalidation', currentAssignmentRT == RT_REMOTE_VALIDATION);
		currentObject.put('photosAvailable', ((String) currentDetail.Photos__c).remove(' ').toLowerCase().countMatches('"visible":true') > 0);
		currentObject.put('customClass', '');
		currentObject.put('isAssigned', isAssigned);
		currentObject.put('isNotEditable', true);
		currentObject.put('isAditional', false);
        currentObject.put('isMultirecord', isMultiRecordCapabilities);
        currentObject.put('isEditableRecordType', CW_FacilityCapabilitiesController.EDITABLE_RECORDTYPES.get('Editable_RecordTypes').contains(rtDevNameLC));
		return currentObject;
	}

}
