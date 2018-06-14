public class ANG_AgencyChangesConfigHelper{

	public static List<Map<String, String>> getAgencyChangesConfigData() {

		List<Map<String, String>> combMap = new List<Map<String, String>>();
		Map<String, String> apiNametoLabel = new Map<String, String>();

		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> fieldMap = schemaMap.get('ANG_AgencyChangesConfig__c').getDescribe().fields.getMap();

		List<String> typeofChangeFields = new List<String>();

		for (String fieldApiName : fieldMap.keySet()) {

			//fields starting with TC are the type of change fields
			if (fieldApiName.startsWithIgnoreCase('TC')) {
				typeofChangeFields.add(fieldApiName);
				apiNametoLabel.put(fieldApiName, fieldMap.get(fieldApiName).getDescribe().getLabel());
			}
		}

		List<ANG_AgencyChangesConfig__c> configs = ANG_AgencyChangesConfig__c.getall().values();

		//for each record in the change type config table define a map of a valid combination
		for (ANG_AgencyChangesConfig__c config : configs) {
			Map<String, String> fieldValueMapping = new Map<String, String>();


			fieldValueMapping.put('RecName', String.valueOf(config.get('Name')));
			for (String toc : typeofChangeFields) {
				
				if (toc.startsWithIgnoreCase('TCA'))
					fieldValueMapping.put(apiNametoLabel.get(toc), String.valueOf(config.get(toc)));
				else
					fieldValueMapping.put('B_' + apiNametoLabel.get(toc).toLowerCase(), String.valueOf(config.get(toc)));
			}
			combMap.add(fieldValueMapping);
			//System.debug('ANG_AgencyChangesConfigHelper: type of change combination: ' + fieldValueMapping);
		}
		return combMap;
	}

	public static Boolean isSelectedTypeOfChangeValid(String typesOfChange, Map<String, String> config) {
		Set<String> tocList = new Set<String>();
		if(typesOfChange!=null)
			tocList.addAll(typesOfChange.toLowerCase().split(';'));

		for (String toc : config.keySet()) {
			if (toc.startsWith('B_'))
				if (tocList.contains(toc.substringAfter('_'))) {
					if (Boolean.valueOf(config.get(toc)) == false)
						return false;
				} else if (Boolean.valueOf(config.get(toc)) == true) {
					return false;
				}
		}
		
		system.debug('Selected types of changes match the row in the configuration table with name: ' + config.get('RecName'));
		return true;
	}

	public static AMS_Utils.AgChangesConfig getSelectedTypeOfChangeCombinationConfig(AMS_OSCAR__c oscar, List<Map<String, String>> configs) {
		Map<String, String> typeOfChangeConfig;

		Boolean foundValidCombination = false;
		System.debug('TYPE OF CHANGE: ' + oscar.ANG_Type_Of_Change__c);
		for (Map<String, String> config : configs) {
			Boolean isValid = isSelectedTypeOfChangeValid(oscar.ANG_Type_Of_Change__c, config);
			if (isValid) {
				foundValidCombination = true;
				typeOfChangeConfig = config;
				break;
			}
		}
		if (!foundValidCombination)
			oscar.addError('Type of Change contains an invalid combination of values.');

		return new AMS_Utils.AgChangesConfig(oscar.ANG_Type_Of_Change__c, typeOfChangeConfig);
	}

	public static List<String> getNotApplicableSteps(Map<String, String> config) {

		if (config.get('Not Applicable Steps') != null) {
			return config.get('Not Applicable Steps').split(';');
		}

		return null;
	}

	public static List<String> getFieldSetsToMigrate(Map<String, String> config) {

		if (config.get('Fields to Migrate') != null) {
			system.debug('FieldSetsToMigrate: ' + config.get('Fields to Migrate').split(';'));
			return config.get('Fields to Migrate').split(';');
		}

		return null;

	}

	public static void setNotApplicableSteps(List<String> notApplicableSteps, List<String> steps, AMS_OSCAR__c oscar) {

		for (String step : notApplicableSteps)
			oscar.put(step + '__c', 'Not Applicable');

	}

	//return the apiname of all the fields to be migrated
	public static Set<String> getFieldsToMigrate(String typesOfChange) {

		Set<String> fieldsToMigrate = new Set<String>();

		List<String> tocs = typesOfChange.split(';');

		for(String toc: tocs){
			String matchingFieldSet = 'ANG_'+ (toc.toLowerCase()).replaceAll('[ -]', '');

			//System.debug('[ANG_AgencyChangesConfigHelper] - matchingFieldSet:'+matchingFieldSet);
			//System.debug('[ANG_AgencyChangesConfigHelper] - field set:' + Schema.SObjectType.AMS_Pax_Accreditation_Form__c.fieldSets.getMap());
			Schema.FieldSet fieldSet = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.fieldSets.getMap().get(matchingFieldSet);
			if(fieldSet!=null){
				//System.debug('AGENCY CHANGES: field set for migration: ' + fieldSet.getName());
				fieldsToMigrate.addAll(getFieldSetFieldsApiName(fieldSet));
			}
		}

		return fieldsToMigrate;

	}

	public static Set<String> getFieldSetFieldsApiName(Schema.FieldSet fieldSet) {

		Set<String> fieldApiNames = new Set<String>();

		for (Schema.FieldSetMember f : fieldSet.getFields())
			fieldApiNames.add(f.getFieldPath());

		return fieldApiNames;

	}

	public static String getSanityCheckChangeCode(Map<String, String> config){
		String changeCode;

		if (config.get('Sanity check') != null)
			changeCode = config.get('Sanity check');

		system.debug('sanity check change code: ' + changeCode);

		return changeCode;
	}

	public static String getManagerApprovalChangeCode(Map<String, String> config){
		String changeCode;

		if (config.get('Manager approval') != null)
			changeCode = config.get('Manager approval');

		system.debug('Manager approval change code: ' + changeCode);

		return changeCode;
	}

	public static String getManagerDisapprovalChangeCode(Map<String, String> config){
		String changeCode;

		if (config.get('Manager disapproval') != null)
			changeCode = config.get('Manager disapproval');

		system.debug('Manager disapproval change code: ' + changeCode);

		return changeCode;
	}

	public static String getWithdrawalChangeCode(Map<String, String> config){
		String changeCode;

		if (config.get('Application withdrawal') != null)
			changeCode = config.get('Application withdrawal');

		system.debug('Application withdrawal change code: ' + changeCode);

		return changeCode;
	}

}