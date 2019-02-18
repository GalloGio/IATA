public class ANG_AgencyChangesConfigHelper{

	public class ChangesConfig {
		public ANG_AgencyChangesConfig__c config;
		public Set<String> changeCombination;

		private ChangesConfig(ANG_AgencyChangesConfig__c c){
			this.config = c;
			changeCombination = new Set<String>();
		}
	}

	public static List<ChangesConfig> agencyChangesConfigData {
		get{
			if(agencyChangesConfigData == null){
				agencyChangesConfigData = new List<ChangesConfig>();

				for (ANG_AgencyChangesConfig__c c : ANG_AgencyChangesConfig__c.getall().values()) {
					ChangesConfig config = new ChangesConfig(c);

					for (Schema.SObjectField field : Schema.SObjectType.ANG_AgencyChangesConfig__c.fields.getMap().values()) {

						Schema.DescribeFieldResult fd = field.getDescribe();
						if (fd.getName().startsWithIgnoreCase('TC_') && Boolean.valueOf(c.get(fd.getName()))) config.changeCombination.add(fd.getLabel());
					}

					agencyChangesConfigData.add(config);
				}
			}

			return agencyChangesConfigData;
		}
	}

	public static Boolean isSelectedTypeOfChangeValid(String typesOfChange, ChangesConfig config) {
		Set<String> tocList = new Set<String>();
		if(typesOfChange != null) tocList.addAll(typesOfChange.split(';'));

		return tocList.equals(config.changeCombination);
	}

	public static ChangesConfig getConfig(AMS_OSCAR__c oscar) {

		if(oscar.Process__c == 'BANK.ACCOUNT.CHANGES') return null;
		else{
			ChangesConfig c = getConfig(oscar.ANG_Type_Of_Change__c);

			if(c == null) oscar.addError('Type of Change contains an invalid combination of values.');

			return c;
		}
	}

	public static ChangesConfig getConfig(String typesOfChange) {

		System.debug(loggingLevel.FINE, '____ [cls AMS_AgencyChangesConfigHelper - getConfig] oscar.Type_of_change__c - ' + typesOfChange);
		for (ChangesConfig config : agencyChangesConfigData) {
			if (isSelectedTypeOfChangeValid(typesOfChange, config)) return config;
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

	public static void setNotApplicableSteps(ANG_AgencyChangesConfig__c config, AMS_OSCAR__c oscar) {
		if(config == null || config.TCA_Not_Applicable_Steps__c == null) return;
		
		for (String step : config.TCA_Not_Applicable_Steps__c.split(';')){
			oscar.put(step + '__c', 'Not Applicable');
		}
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
}