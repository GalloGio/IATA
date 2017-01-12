public class AMS_AgencyChangesConfigHelper{

	private static Map<String, Boolean> tempMapper = new Map<String, Boolean>{
                'Ownership to non-IATA Agent' => true,
                'Ownership to IATA Agent' => true,
                'Legal status' => true,
                'Location' => false,
                'Location with inspection' => false,
                'Major Shareholding' => true,
                'VMFR' => true,
                'Location type' => false,
                'Name' => true,
                'Minor Shareholding' => true,
            	'CNS - Removal of trade name' => true};

	public static List<Map<String, String>> getAgencyChangesConfigData() {

		List<Map<String, String>> combMap = new List<Map<String, String>>();
		Map<String, String> apiNametoLabel = new Map<String, String>();

		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> fieldMap = schemaMap.get('AMS_AgencyChangesConfig__c').getDescribe().fields.getMap();

		List<String> typeofChangeFields = new List<String>();

		for (String fieldApiName : fieldMap.keySet()) {

			//fields starting with TC are the type of change fields
			if (fieldApiName.startsWithIgnoreCase('TC')) {
				typeofChangeFields.add(fieldApiName);
				apiNametoLabel.put(fieldApiName, fieldMap.get(fieldApiName).getDescribe().getLabel());
			}
		}

		List<AMS_AgencyChangesConfig__c> configs = AMS_AgencyChangesConfig__c.getall().values();

		//for each record in the change type config table define a map of a valid combination
		for (AMS_AgencyChangesConfig__c config : configs) {
			Map<String, String> fieldValueMapping = new Map<String, String>();


			fieldValueMapping.put('RecName', String.valueOf(config.get('Name')));
			for (String toc : typeofChangeFields) {
				
				if (toc.startsWithIgnoreCase('TCA'))
					fieldValueMapping.put(apiNametoLabel.get(toc), String.valueOf(config.get(toc)));
				else
					fieldValueMapping.put('B_' + apiNametoLabel.get(toc), String.valueOf(config.get(toc)));
			}
			combMap.add(fieldValueMapping);
			System.debug('type of change combination: ' + fieldValueMapping);
		}
		return combMap;
	}

	public static Boolean isSelectedTypeOfChangeValid(String typesOfChange, Map<String, String> config) {
		Set<String> tocList = new Set<String>();
		system.debug(LoggingLevel.ERROR,'LF: typesOfChange = '+typesOfChange);
		if(typesOfChange!=null)
			tocList.addAll(typesOfChange.split(';'));
system.debug(LoggingLevel.ERROR,'LF: config.keySet() = '+config.keySet());
		for (String toc : config.keySet()) {
			system.debug(LoggingLevel.ERROR,'LF: toc = '+toc);
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

		if(oscar.Process__c == 'BANK.ACCOUNT.CHANGES')
			return null;

		//List<Map<String, String>> configs = AMS_AgencyChangesConfigHelper.getAgencyChangesConfigData();
		Boolean foundValidCombination = false;
		System.debug('TYPE OF CHANGE: ' + oscar.Type_of_change__c);
		for (Map<String, String> config : configs) {
			Boolean isValid = AMS_AgencyChangesConfigHelper.isSelectedTypeOfChangeValid(oscar.Type_of_change__c, config);
			if (isValid) {
				foundValidCombination = true;
				typeOfChangeConfig = config;
				break;
			}
		}
		if (!foundValidCombination)
			oscar.addError('Type of Change contains an invalid combination of values.');

		return new AMS_Utils.AgChangesConfig(oscar.Type_of_change__c, typeOfChangeConfig);
	}

	public static AMS_Utils.AgChangesConfig getTypeOfChangeCombinationConfig(String typesOfChange, AMS_OSCAR__c oscar, List<Map<String, String>> configs) {
		Map<String, String> typeOfChangeConfig;

		//List<Map<String, String>> configs = AMS_AgencyChangesConfigHelper.getAgencyChangesConfigData();
		Boolean foundValidCombination = false;
		System.debug('TYPE OF CHANGE: ' + typesOfChange);
		for (Map<String, String> config : configs) {
			Boolean isValid = AMS_AgencyChangesConfigHelper.isSelectedTypeOfChangeValid(typesOfChange, config);
			if (isValid) {
				foundValidCombination = true;
				typeOfChangeConfig = config;
				break;
			}
		}
		if (!foundValidCombination)
			oscar.addError('The following combination of types of change does not have a match in the configuration table: '+ typesOfChange);


		return new AMS_Utils.AgChangesConfig(typesOfChange, typeOfChangeConfig);
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
	public static Set<String> getFieldsToMigrate(AMS_OSCAR__c oscar, List<Map<String, String>> configs) {

		Set<String> fieldsToMigrate = new Set<String>();

		//get the groups of fields to be migrated from the config table
		AMS_Utils.AgChangesConfig config = getSelectedTypeOfChangeCombinationConfig(oscar, configs);

		if(config == null)
			return fieldsToMigrate;

		List<String> fieldSetsToMigrate = getFieldSetsToMigrate(config.config);

		if(fieldSetsToMigrate != null){
			for(String fs: fieldSetsToMigrate){
				Schema.FieldSet fieldSet = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.fieldSets.getMap().get(fs);
				if(fieldSet!=null)
					fieldsToMigrate.addAll(getFieldSetFieldsApiName(fieldSet));
			}
		}

		System.debug('Fields to migrate: '+ fieldsToMigrate);

		return fieldsToMigrate;

	}

	//return the apiname of all the fields to be migrated
	public static Set<String> getFieldsToMigrate(String typesOfChange) {

		Set<String> fieldsToMigrate = new Set<String>();

		List<String> tocs = typesOfChange.split(';');

		for(String toc: tocs){
			String matchingFieldSet = 'AMS_'+ (toc.toLowerCase()).replaceAll('[ -]', '');
			Schema.FieldSet fieldSet = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.fieldSets.getMap().get(matchingFieldSet);
			System.debug('AGENCY CHANGES: field set for migration: ' + fieldSet.getName());
			if(fieldSet!=null)
				fieldsToMigrate.addAll(getFieldSetFieldsApiName(fieldSet));
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

	public static String getPropagatableTypesOfChange(String typesOfChange){
		String result = '';

		Set<String> tocList = new Set<String>();

		tocList.addAll(typesOfChange.split(';'));

		for(String toc: tocList){
			if(tempMapper.get(toc) == true)
				result += toc+';';
		}

		return result;
	}

	public static String getNonPropagatableTypesOfChange(String typesOfChange){
		String result = '';

		Set<String> tocList = new Set<String>();

		tocList.addAll(typesOfChange.split(';'));

		for(String toc: tocList){
			if(tempMapper.get(toc) == false)
				result += toc + ';';
		}

		return result;
	}

}