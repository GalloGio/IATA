/*
 * @Description: logic required to be used in advanced search
 */
public with sharing class CW_AdvancedSearch {
	private static SObjectType sObjectTypeRow;
	/*
	* @Description: getStructureFacilities()
	* @Params: 
	* @Returns: String response (list of wrapper serialized)
	*/
	@auraEnabled(cacheable=true)
	public static String getStructureFacilities() {
		try {
			List<Map<String, Object>> rtBySection = CW_FacilityCapabilitiesController.getMapRecordTypesBySection();
			List<Map<String, Object>> sectionsBySupercategory = CW_FacilityCapabilitiesController.getMapSectionsBySupercategory();
			sObjectTypeRow = ((SObject)(Type.forName('Schema.Account_Role_Detail_Capability__c').newInstance())).getSObjectType();
			Map<String, List<Map<String, Object>>> mapEquipByCategory = CW_Utilities.getPicklistFieldDependencies(
				'Account_Role_Detail_Capability__c',
				'Category__c',
				'Equipment__c',
				true
			);
			Map<String, List<String>> mapFieldsByRTypeAndCategory = CW_FacilityCapabilitiesController.getMapFieldsByExtraDataType();
			System.debug(LoggingLevel.FINE,'____[CW_AdvancedSearch - getStructureFacilities] mapFieldsByRTypeAndCategory - ' +JSON.serialize(mapFieldsByRTypeAndCategory));
			System.debug(LoggingLevel.FINE,'____[CW_AdvancedSearch - getStructureFacilities] mapEquipByCategory - ' +JSON.serialize(mapEquipByCategory));

			List<ComparisonSupercategoryWrapper> supercategories = new List<ComparisonSupercategoryWrapper>();
			Map<String, RecordType> mapRecordTypes = new Map<String, RecordType>();
			Map<String, List<String>> mapCategoriesByRecordTypeDevName = CW_FacilityCapabilitiesController.getMapCategoriesByRecordType();
			for (RecordType currentRt : RecordTypeSingleton.getInstance().getRecordTypesBySObject('Account_Role_Detail_Capability__c')) {
				if (mapCategoriesByRecordTypeDevName.containsKey(currentRt.DeveloperName.toLowerCase())) {
					mapRecordTypes.put(currentRt.DeveloperName.toLowerCase(), currentRt);
				}
			}
			System.debug(LoggingLevel.FINE, '____[CW_AdvancedSearch - getStructureFacilities] mapRecordTypes - ' + JSON.serialize(mapRecordTypes));

			for (Map<String, Object> currentSectionsBySupercategory : sectionsBySupercategory) {
				ComparisonSupercategoryWrapper currentSupercategory = new ComparisonSupercategoryWrapper();
				currentSupercategory.label = (String) currentSectionsBySupercategory.get('label');
				currentSupercategory.order = (Decimal) currentSectionsBySupercategory.get('order');
				currentSupercategory.sections = new List<SectionRT>();

				List<String> currentSectionSC = (List<String>) currentSectionsBySupercategory.get(CW_CapabilitiesUtilities.SECTIONS);

				for (Map<String, Object> currentSection : rtBySection) {
					if (currentSectionSC.contains((String) currentSection.get('label'))) {
						System.debug(LoggingLevel.FINE,'____[CW_AdvancedSearch - getStructureFacilities] currentSection - ' + JSON.serialize(currentSection));
						Integer order = Integer.valueOf(currentSection.get('order'));
						String label = String.valueOf(currentSection.get('label'));
						List<String> rtsString = (List<String>) currentSection.get('rts');

						if (!rtsString.isEmpty()) {
							List<CapabilityRT> lstCapaByRT = new List<CapabilityRT>();
							for (String recType : rtsString) {
								String labelRType = mapRecordTypes.containsKey(recType.toLowerCase())
														? mapRecordTypes.get(recType.toLowerCase()).Name
														: recType;
								CapabilityRT capab = getCategoriesSection(
									recType,
									labelRType,
									mapFieldsByRTypeAndCategory,
									mapEquipByCategory,
									mapCategoriesByRecordTypeDevName.get(recType.toLowerCase())
								);
								System.debug(LoggingLevel.FINE,'____[CW_AdvancedSearch - getStructureFacilities] capab - ' + JSON.serialize(capab));
								if (capab != null && capab.name != null) {
									lstCapaByRT.add(capab);
								}
							}
							if (!lstCapaByRT.isEmpty()) {
								currentSupercategory.sections.add(new SectionRT(label, lstCapaByRT, order));
							}
						}
					}
				}
				supercategories.add(currentSupercategory);
			}

			System.debug(LoggingLevel.FINE,'____[CW_AdvancedSearch - getStructureFacilities] supercategories - ' + JSON.serialize(supercategories));
			return JSON.serialize(supercategories);
		} catch (Exception exc) {
			throw new AuraHandledException('exception: ' + exc);
		}
	}
	/*
	 *   @Description:   1.- get capabilities or recordtypes per section
	 *   @Params: String recordTypeInput
	 *   @Returns: CapabilityRT
	 */
	private static CapabilityRT getCategoriesSection(String recordTypeInput, String rtLabel,
													Map<String, List<String>> mapFieldsByRTypeAndCategory,
													Map<String, List<Map<String, Object>>> mapEquipByCategory,
													List<String> lstCategories) {
		CapabilityRT capability;

		if (!mapFieldsByRTypeAndCategory.isEmpty()) {
			List<Equipment> lstEquipments = new List<Equipment>();

			Map<String, Schema.PicklistEntry> mapCategories = CW_FacilityCapabilitiesController.getPicklistEntryMapCapCategory();

			for(String currentCat : lstCategories) {
				for(Map<String, Object> currentEquip : mapEquipByCategory.get(currentCat)) {
					String key = recordTypeInput + '#' + currentCat;
					String categoryLabel = mapCategories.get(currentCat) == null
											? currentCat
											: mapCategories.get(currentCat).getLabel();

					if (mapFieldsByRTypeAndCategory.containsKey(key.toLowerCase())){
						lstEquipments.add(new Equipment(((String) currentEquip.get('value')),
															(String) currentEquip.get('label'),
															getFieldsWrapper(mapFieldsByRTypeAndCategory.get(key.toLowerCase())),
															categoryLabel, currentCat));
					}
				}
			}
			capability = new CapabilityRT(recordTypeInput, rtLabel, lstEquipments);
		}
		System.debug(LoggingLevel.FINE,'____[CW_AdvancedSearch - getCategoriesSection] capability - ' + JSON.serialize(capability));
		return capability;
	}

	/*
	 *   @Description:   1.- get fields
	 *   @Params: 
	 *   @Returns: Field
	 */
	private static List<Field> getFieldsWrapper(List<String> lstApiFields) {
		List<Field> lstFieldWrappers = new List<Field>();
		for(String apiField : lstApiFields) {
			if(apiField.equalsIgnoreCase('Equipment__c')) {
				continue;
			}

			DescribeFieldResult fieldDescribe = sObjectTypeRow.getDescribe()
															.fields
															.getMap()
															.get(apiField)
															.getDescribe();


			Field fieldWrapper = new Field();
			fieldWrapper.name = apiField;

			if(fieldWrapper.name.equalsIgnoreCase('CRSTR_DGR_Dedicated_Formula__c')) {
				fieldDescribe = sObjectTypeRow.getDescribe()
											.fields
											.getMap()
											.get('CRSTR_DGR_Dedicated__c')
											.getDescribe();
				fieldWrapper.name = 'CRSTR_DGR_Dedicated__c';
			}

			if(fieldWrapper.name.equalsIgnoreCase('CRSTR_Pharma_Dedicated_Formula__c')) {
				fieldDescribe = sObjectTypeRow.getDescribe()
											.fields
											.getMap()
											.get('CRSTR_Pharma_Dedicated__c')
											.getDescribe();
				fieldWrapper.name = 'CRSTR_Pharma_Dedicated__c';
			}

			
			fieldWrapper.type = fieldDescribe.getType()
												.name()
												.toLowerCase();

			if(fieldWrapper.name.equalsIgnoreCase('CRSTR_Positions_10ft_ULDs__c')
					|| fieldWrapper.name.equalsIgnoreCase('CRSTR_Positions_20ft_ULDs__c')
					|| fieldWrapper.name.equalsIgnoreCase('CRSTR_Positions_AKE__c')) {
				fieldWrapper.type = 'checkbox';	
			}

			if(fieldWrapper.type.equalsIgnoreCase('integer') || fieldWrapper.type.equalsIgnoreCase('double') 
				|| fieldWrapper.type.equalsIgnoreCase('multipicklist') || fieldWrapper.type.equalsIgnoreCase('string')) {
				continue;
			}

			fieldWrapper.label = fieldDescribe.getLabel();
			fieldWrapper.selected = false;

			if(fieldWrapper.type.equalsIgnoreCase('picklist')) {
				List<Options> lstOptions = new List<Options>();
				List<Schema.PicklistEntry> ple = fieldDescribe.getPicklistValues();
				for(Schema.PicklistEntry row : ple) {
					lstOptions.add(new Options(row));
				}
				fieldWrapper.options = lstOptions;
			}

			lstFieldWrappers.add(fieldWrapper);
		}
		return lstFieldWrappers;
	}


	/**
	 * @description: SectionRT wrapper
	 */
	public class DataSections {
		@AuraEnabled
		public List<SectionRT> sections { get; set; }
		/*
		 * Constructor: params (List<SectionRT> lstSections)
		 */
		public DataSections(List<SectionRT> lstSections) {
			this.sections = lstSections;
		}
	}
	/**
	 * @description: SectionRT wrapper
	 */
	public class SectionRT {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public Integer order { get; set; }
		@AuraEnabled
		public Boolean isVisible { get; set; }
		@AuraEnabled
		public List<CapabilityRT> capabilityRT { get; set; }
		/*
		 * Constructor: params (String label, List<CapabilityRT> lstCapabilitiesPerRT, Integer order)
		 */
		public SectionRT(
			String label,
			List<CapabilityRT> lstCapabilitiesPerRT,
			Integer order
		) {
			this.label = label;
			this.capabilityRT = lstCapabilitiesPerRT;
			this.order = order;
			this.isVisible = true;
		}
	}
	public class ComparisonSupercategoryWrapper {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public Decimal order { get; set; }
		@AuraEnabled
		public List<SectionRT> sections { get; set; }
	}
	/**
	 * @description: CapabilityRT wrapper
	 */
	public class CapabilityRT {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public Boolean isVisible { get; set; }
		@AuraEnabled
		public List<Equipment> categories { get; set; }

		/*
		 * Constructor: params (String name, List<Equipment> lstCategories)
		 */
		public CapabilityRT(
			String name,
			String label,
			List<Equipment> lstCategories
		) {
			this.label = label;
			this.name = name;
			this.categories = lstCategories;
			this.isVisible = true;
		}
	}
	/**
	 * @description: Equipment wrapper
	 */
	public class Equipment {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String category { get; set; }
		@AuraEnabled
		public String categoryDevName { get; set; }
		@AuraEnabled
		public List<Field> fields { get; set; }
		@AuraEnabled
		public Boolean selected { get; set; }
		@AuraEnabled
		public Boolean moreDetails { get; set; }
		/*
		 * Constructor: params (String name, String label, String category)
		 */
		public Equipment(String name, String label, List<Field> lstFields, String category, String categoryDevName) {
			this.label = label;
			this.name = name;
			this.selected = false;
			this.category = category;
			this.fields = lstFields;
			this.moreDetails = false;
			this.categoryDevName = categoryDevName;
		}
	}
	/**
	 * @description: Field wrapper with needed information in client side
	 */
	public class Field {
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String type { get; set; }
		@AuraEnabled
		public Boolean selected { get; set; }
		@AuraEnabled
		public List<Options> options { get; set; }
	}
	/**
	 * @description: Options picklist entry information to be sent to front-side
	 */
	public class Options {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String value { get; set; }
		@AuraEnabled
		public Boolean selected { get; set; }
		/*
		 * Constructor: params (Schema.PicklistEntry ple)
		 */
		public Options (Schema.PicklistEntry ple) {
			this.label = ple.getLabel();
			this.value = ple.getValue();
			this.selected = false;
		}
	}
}