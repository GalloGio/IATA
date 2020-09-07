public without sharing class CW_CapabilitiesManagerController {
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

	private static Map<Id, List<Map<String, Object>>> generateCertificationsByCapabilityId(List<ICG_Account_Role_Capability_Assignment__c> assignments){
		Map<Id, List<Map<String, Object>>> certificationsByCapabilityId = new Map<Id, List<Map<String, Object>>>();

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

		return certificationsByCapabilityId;
	}

	private static Map<String, String> generateColumnsToHandle(Boolean isMultiRecordCapabilities){
		Map<String, String> columnsToHandle = new Map<String, String>();
		columnsToHandle.put('crstr_dgr_dedicated_formula__c', 'crstr_dgr_dedicated__c');
		columnsToHandle.put('crstr_pharma_dedicated_formula__c', 'crstr_pharma_dedicated__c');
		if(isMultiRecordCapabilities){
			columnsToHandle.put('number__c', null);
		}
		return columnsToHandle;
	}

	private static Map<String, Object> generateData(
		String id, 
		List<String> categoriesToRetrieve,
		Map<String, List<String>> mapCategoriesByRecordTypeDevName,
		Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById,
		String certificationId,
		ICG_Account_Role_Detail__c accountRoleDetailFound
	){
		Set<String> listSectionsIncluded = new Set<String>();
		CW_FacilityCapabilitiesController.SectionsWrapper checksMap;

		//Get recordtypes id for category
		Map<String, String> mapRecordTypeIdByCategory = CW_FacilityCapabilitiesController.getRecordTypesIdByCategoryName();

		// Get Fields to build the soql query and the tables.
		Map<String, List<String>> mapFieldsByRecordTypeAndCategory = CW_FacilityCapabilitiesController.getMapFieldsByRecordTypeAndCategory();
		Map<String, List<String>> mapTooltipFieldsByField = CW_FacilityCapabilitiesController.getMapTooltipFieldsByField();
		List<String> fieldsToRetrieve = CW_CapabilitiesUtilities.generateFieldsToRetrieve(mapFieldsByRecordTypeAndCategory, mapTooltipFieldsByField);

		Map<String, Object> rawData = CW_CapabilitiesUtilities.generateRawData(mapCategoriesByRecordTypeDevName, mapAccountRoleDetailAssignmentRtsById, categoriesToRetrieve);

		// Get grouped fields
		Map<String, List<String>> mapFieldsByGroupField = CW_FacilityCapabilitiesController.getMapFieldsByGroupField();

		// Get equipments map
		Map<String, Schema.PicklistEntry> mapEquipments = CW_FacilityCapabilitiesController.getPicklistEntryMapCapEquipment();

		// Schemas to validity fields
		Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Account_Role_Detail_Capability__c.fields.getMap();

		List<ICG_Account_Role_Capability_Assignment__c> assignments = getAssignmentsByAccountRoleDetailAndRts(id, new List<Id>(mapAccountRoleDetailAssignmentRtsById.keySet()), categoriesToRetrieve, CW_FacilityCapabilitiesController.validateFieldsOfObject('Account_Role_Detail_Capability__c', fieldsToRetrieve, fieldsMap), certificationId);
		Map<Id, List<Map<String, Object>>> certificationsByCapabilityId = generateCertificationsByCapabilityId(assignments);

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
				Boolean isMultiRecordCapabilities = ESPECIAL_CATEGORIES.get('Multi_Record_Capabilities').contains(currentDetail.Category__c.toLowerCase());
				categoryFound = CW_CapabilitiesUtilities.generateCategoryFound(categoryFound, capabilityFound, mapFieldsByRecordTypeAndCategory, rtDevNameLC, currentDetail, mapFieldsByGroupField, generateColumnsToHandle(isMultiRecordCapabilities), isMultiRecordCapabilities);

				if (currentAssignment.ICG_Account_Role_Detail__r.Summary_Detail_Check_JSON__c != null) {
					checksMap = (CW_FacilityCapabilitiesController.SectionsWrapper) JSON.deserialize(currentAssignment.ICG_Account_Role_Detail__r.Summary_Detail_Check_JSON__c, CW_FacilityCapabilitiesController.SectionsWrapper.class);
				}

				if (categoryFound != null && categoryFound.containsKey(CW_CapabilitiesUtilities.ROWS)) {
					List<Object> capabilityGroupRowsFound = (List<Object>) categoryFound.get(CW_CapabilitiesUtilities.ROWS);

					if (!CW_CapabilitiesUtilities.isCapabilityAdded(capabilityGroupRowsFound, currentDetail.Id)) {
						Map<String, Object> currentObject = convertCapabilityAssignmentToObject(currentDetail, mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
						List<Map<String,Object>> certifications = certificationsByCapabilityId.containsKey(currentDetail.Id) ? certificationsByCapabilityId.get(currentDetail.Id) : new List<Map<String,Object>>();
						currentObject = CW_CapabilitiesUtilities.generateCurrentObject(
							currentObject, 
							currentDetail.Id, 
							currentDetail, 
							certifications, 
							currentAssignment.ICG_Capability_Assignment_Group__r.RecordTypeId, 
							capabilityFound, 
							mapFieldsByRecordTypeAndCategory, 
							rtDevNameLC, 
							mapEquipments, 
							mapTooltipFieldsByField, 
							fieldsMap,
							isMultiRecordCapabilities, 
							false,
							true
						);
						capabilityGroupRowsFound.add(currentObject);
					}
				}
			}
		}
		
		if(certificationId != null ){
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
					Map<String, Object> capabilityFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) rawData.get(CW_CapabilitiesUtilities.CAPABILITIES), 'name', rtDevNameLC);
					capabilityFound = CW_CapabilitiesUtilities.generateCapabilityFound(capabilityFound, currentDetail);
					Map<String, Object> categoryFound = (Map<String, Object>) CW_FacilityCapabilitiesController.getItemInMap((List<Map<String, Object>>) capabilityFound.get(CW_CapabilitiesUtilities.CATEGORIES), 'value', currentDetail.Category__c);
					Boolean isMultiRecordCapabilities = ESPECIAL_CATEGORIES.get('Multi_Record_Capabilities').contains(currentDetail.Category__c.toLowerCase());
					categoryFound = CW_CapabilitiesUtilities.generateCategoryFound(categoryFound, capabilityFound, mapFieldsByRecordTypeAndCategory, rtDevNameLC, currentDetail, mapFieldsByGroupField, generateColumnsToHandle(isMultiRecordCapabilities), isMultiRecordCapabilities);

					if(!String.isBlank(accountRoleDetailFound.Summary_Detail_Check_JSON__c)){
						checksMap = (CW_FacilityCapabilitiesController.SectionsWrapper) JSON.deserialize(accountRoleDetailFound.Summary_Detail_Check_JSON__c, CW_FacilityCapabilitiesController.SectionsWrapper.class);
					}

					Map<String, Object> currentObject;
					if (categoryFound != null && categoryFound.containsKey(CW_CapabilitiesUtilities.ROWS)) {
						List<Object> capabilityGroupRowsFound = (List<Object>) categoryFound.get(CW_CapabilitiesUtilities.ROWS);
						currentObject = cleanCapabilitiesFieldsToObject(currentDetail, mapFieldsByRecordTypeAndCategory.get(rtDevNameLC + '#' + currentDetail.Category__c.toLowerCase()), fieldsMap);
						currentObject = CW_CapabilitiesUtilities.generateCurrentObject(
							currentObject, 
							'', 
							currentDetail, 
							new List<Map<String, Object>>(), 
							'', 
							capabilityFound, 
							mapFieldsByRecordTypeAndCategory, 
							rtDevNameLC, 
							mapEquipments, 
							mapTooltipFieldsByField, 
							fieldsMap,
							isMultiRecordCapabilities, 
							false,
							false
						);
						capabilityGroupRowsFound.add(currentObject);
					}
					categoryFound.put('templateFields', currentObject);
				}
			}
		}

		Map<String, Object> returnValue = new Map<String, Object>();
		returnValue.put(CW_CapabilitiesUtilities.LIST_SECTIONS_INCLUDED, listSectionsIncluded);
		returnValue.put(CW_CapabilitiesUtilities.CHECKS_MAP, checksMap);
		returnValue.put(CW_CapabilitiesUtilities.RAW_DATA, rawData);
		return returnValue;
	}

	/**
	 * @description	Get Map<String, Object> with Capabilities filtered by account role detail Id and account role detail certification
	 * @param			id - Account Role Detail and ardCertId - Account Role Detail Certification Id to filter
	 * @return			Map<String, Object> with custom estructure that contains information on all capabilities
	 */
	@AuraEnabled
	public static Map<String, Object> getCapabilitiesForFacilityCertificationId(String id, String ardCertId) { 
		Map<String, Object> returnValue = new Map<String, Object>{ CW_CapabilitiesUtilities.SUPERCATEGORIES => new List<Map<String, Object>>() };

		try {
			String certificationId = CW_CapabilitiesUtilities.generateCertificationId(ardCertId);
			Map<String, Object> prepareCapabilitiesData = CW_CapabilitiesUtilities.prepareCapabilityData(id);
			Map<String, List<String>> mapCategoriesByRecordTypeDevName = (Map<String, List<String>>) prepareCapabilitiesData.get(CW_CapabilitiesUtilities.MAP_CATEGORIES_BY_RECORDTYPE_DEVNAME);
			Map<Id, RecordType> mapAccountRoleDetailAssignmentRtsById = (Map<Id, RecordType>) prepareCapabilitiesData.get(CW_CapabilitiesUtilities.MAP_ARD_ASSIGNMENT_RTS_BY_ID);
			ICG_Account_Role_Detail__c accountRoleDetailFound = (ICG_Account_Role_Detail__c) prepareCapabilitiesData.get(CW_CapabilitiesUtilities.ARD_FOUND);
			List<String> categoriesToRetrieve = (List<String>) prepareCapabilitiesData.get(CW_CapabilitiesUtilities.CATEGORIES_TO_RETRIEVE);

			if (mapAccountRoleDetailAssignmentRtsById.isEmpty() || categoriesToRetrieve == null) {
				return returnValue;
			}

			Map<String, Object> generatedData = generateData(
				id,
				categoriesToRetrieve,
				mapCategoriesByRecordTypeDevName,
				mapAccountRoleDetailAssignmentRtsById,
				certificationId,
				accountRoleDetailFound
			);
			return CW_CapabilitiesUtilities.generateReturnValue(id, generatedData);
		} catch (Exception e) {
			returnValue.put('e_getMessage', e.getMessage());
			returnValue.put('e_getStackTraceString', e.getStackTraceString());
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
	public static List<ICG_Account_Role_Capability_Assignment__c> getAssignmentsByAccountRoleDetailAndRts(Id ardId, List<Id> recordTypesId, List<String> categoriesToRetrieve, List<String> accountRoleDetailCapabilityFields, String certificationId) {
		List<ICG_Account_Role_Capability_Assignment__c> returnValue = new List<ICG_Account_Role_Capability_Assignment__c>();
		if (String.isNotBlank(ardId) && recordTypesId != null && recordTypesId.size() > 0 && accountRoleDetailCapabilityFields != null && accountRoleDetailCapabilityFields.size() > 0) {
			List<String> fieldsToRetrieve = new List<String>();
			List<ICG_Certification_Capability_Assignment__c> certiListCapabAssigment = new List<ICG_Certification_Capability_Assignment__c>();
			if(certificationId != null){
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
			
			// Fields related to Certifications
			fieldsToRetrieve.addAll(new List<String>{ caGroupR + '.Id', caGroupR + '.Expiration_Date__c', caGroupR + '.Issue_Date__c', caGroupR + '.' + certificationR + '.Name', caGroupR + '.' + certificationR + '.Image__c', caGroupR + '.' + certificationR + '.Order__c' });
			String query;
			if(certificationId != null){
                query = 'SELECT Id, ' + String.join(fieldsToRetrieve, ', ') + ' FROM ICG_Account_Role_Capability_Assignment__c ' + 'WHERE ' + caGroupR +  '.Is_Deprecated__c = false AND '  + caGroupR + '.Expiration_Date__c >= TODAY AND ' + arDetailR + '.Id =\'' + ardId + '\' AND ' + ardCapabilityR + '.RecordTypeId IN (\'' + String.join((recordTypesId), '\', \'') + '\')' + ' AND ' + ardCapabilityR + '.Category__c IN (' + categories + ')' + ' AND ' + ardCapabilityR + '.Equipment__c IN (' + equipments + ') order by ICG_Capability_Assignment_Group__r.ICG_Certification__r.Order__c';
			}
			else{//if read all capabilities from station
				query = 'SELECT Id, ' + String.join(fieldsToRetrieve, ', ') + ' FROM ICG_Account_Role_Capability_Assignment__c ' + ' WHERE ' + caGroupR +  '.Is_Deprecated__c = false AND ' + caGroupR + '.Expiration_Date__c >= TODAY AND ' + arDetailR + '.Id = \'' + ardId + '\' ' + ' AND ' + ardCapabilityR + '.RecordTypeId IN (\'' + String.join((recordTypesId), '\', \'') + '\')' + ' AND ' + ardCapabilityR + '.Category__c IN (\'' + String.join(categoriesToRetrieve, '\', \'') + '\') order by ICG_Capability_Assignment_Group__r.ICG_Certification__r.Order__c';
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
	public static String updateCapabilitiesEdited(String accRoleDet, String ardCertId,List<Object> listAddedRows) {
		ResponseBody res = new ResponseBody();
		List<Account_Role_Detail_Capability__c> listAccRoleCapabInserted;
			try {
				//creation records capabilities
				listAccRoleCapabInserted = createCapabilities(listAddedRows, true);

				// Modify depreciation flow to allow editing and creation of new assignments
				// res.success = assignCapabilityAndGroup(accRoleDet, ardCertId, listAccRoleCapabInserted);
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
				if(String.isNotBlank(c.id) && String.isNotEmpty(c.id)){
					sObj.put('Id', c.id);
				}				
			}
			
			sObj.put('RecordTypeId', c.rtypeId);
			sObj.put('Category__c', c.category);
			sObj.put('Equipment__c', c.equipment_value);						

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
		
		upsert listToInsert;

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