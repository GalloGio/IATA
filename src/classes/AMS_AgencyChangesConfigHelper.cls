public class AMS_AgencyChangesConfigHelper{

	public class ChangesConfig {
		public AMS_AgencyChangesConfig__c config;
		public Set<String> changeCombination;

		private ChangesConfig(AMS_AgencyChangesConfig__c c){
			this.config = c;
			changeCombination = new Set<String>();
		}
	}

	public static List<ChangesConfig> agencyChangesConfigData {
		get{
			if(agencyChangesConfigData == null){
				agencyChangesConfigData = new List<ChangesConfig>();

				for (AMS_AgencyChangesConfig__c c : AMS_AgencyChangesConfig__c.getall().values()) {
					ChangesConfig config = new ChangesConfig(c);

					for (Schema.SObjectField field : Schema.SObjectType.AMS_AgencyChangesConfig__c.fields.getMap().values()) {

						Schema.DescribeFieldResult fd = field.getDescribe();
						if (fd.getName().startsWithIgnoreCase('TC_') && Boolean.valueOf(c.get(fd.getName()))) config.changeCombination.add(fd.getLabel());
					}

					agencyChangesConfigData.add(config);
				}
			}

			return agencyChangesConfigData;
		}
	}

	public static Boolean isSelectedTypeOfChangeValid(String typesOfChange, String process, ChangesConfig config) {
		Set<String> tocList = new Set<String>();
		if(typesOfChange != null) tocList.addAll(typesOfChange.split(';'));

		if(process != config.config.Process__c) return false;
		else return tocList.equals(config.changeCombination);
	}

	public static ChangesConfig getConfig(AMS_OSCAR__c oscar) {

		if(oscar.Process__c == 'BANK.ACCOUNT.CHANGES') return null;
		else{
			ChangesConfig c = getConfig(oscar.Type_of_change__c, oscar.Business_Process__c);

			if(c == null) oscar.addError('Type of Change contains an invalid combination of values.');

			return c;
		}
	}

	public static ChangesConfig getConfig(String typesOfChange, String process) {

		System.debug(loggingLevel.FINE, '____ [cls AMS_AgencyChangesConfigHelper - getConfig] oscar.Type_of_change__c - ' + typesOfChange);
		for (ChangesConfig config : agencyChangesConfigData) {
			if (isSelectedTypeOfChangeValid(typesOfChange, process, config)) return config;
		}
		return null;
	}

	public static void setNotApplicableSteps(AMS_AgencyChangesConfig__c config, AMS_OSCAR__c oscar) {
		if(config == null || config.TCA_Not_Applicable_Steps__c == null) return;
		
		for (String step : config.TCA_Not_Applicable_Steps__c.split(';')){
			oscar.put(step + '__c', 'Not Applicable');
		}
	}

	//return the apiname of all the fields to be migrated
	public static Set<String> getFieldsToMigrate(AMS_OSCAR__c oscar) {

		Set<String> fieldsToMigrate = new Set<String>();

		ChangesConfig config = getConfig(oscar);

		if(config == null || config.config.TCA_Fields_to_Migrate__c == null) return fieldsToMigrate;
		
		Map<String, Schema.FieldSet> fieldSets = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.fieldSets.getMap();
		for(String fs: config.config.TCA_Fields_to_Migrate__c.split(';')){
			if(fieldSets.containsKey(fs)) fieldsToMigrate.addAll(getFieldSetFieldsApiName(fieldSets.get(fs)));
		}

		System.debug(loggingLevel.FINE, '____ [cls AMS_AgencyChangesConfigHelper - getFieldsToMigrate] fieldsToMigrate - ' + fieldsToMigrate);

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

	private static Map<String, Boolean> propagatableMap = new Map<String, Boolean>{
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
		'CNS - Removal of trade name' => true
	};

	public static String getPropagatableTypesOfChange(String typesOfChange, Boolean propagatable){
		String result = '';

		for(String toc: typesOfChange.split(';')){
			if(propagatableMap.get(toc) == propagatable)
				result += toc+';';
		}

		return result;
	}

}