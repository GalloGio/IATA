/**
 *  This class is used to apply the logic that makes a case visible on IATA Portal
 *  When a visible case ownership changes to a Recycle Bin queue the case is set always set to invisible
 *  Otherwise "Case_Visibility_Rule__mdt" metadata contains the rules, organized by recordType, that make a case visible
 */
public without sharing class CaseVisibilityEngine {

	//Map the rules per RecordTypeId
	private static Map<Id,List<Case_Visibility_Rule__mdt>> mapRules = null;

	public static void execute(List<Case> cases) {
		getRulesByRecordTypeId();
		Set<Id> recycleBinIds = getRecycleBinIds();

		for(Case record : cases) {
			if(record.Visible_on_ISS_Portal__c && recycleBinIds.contains(record.OwnerId)) {
				record.Visible_on_ISS_Portal__c = false;
			} else if(!record.Visible_on_ISS_Portal__c && !recycleBinIds.contains(record.OwnerId)) {
				processVisibilityRules(mapRules.get(record.RecordTypeId), record);
			}
		}
	}

	/**
	 *  Method that compares each rule with the record values, to be set to true all criterias in a rule must be true
	 *  (it applies AND logic eg.: field1 operator value1 AND field2 operator value2 AND etc..)
	 *  To set visibility to true at least one of the rules must match with record values
	 *  (it applies OR logic eg.: rule1 OR rule2 OR etc...)
	 */
	private static void processVisibilityRules(List<Case_Visibility_Rule__mdt> rules, Case record) {
		if(rules == null) {
			return;
		}

		for(Case_Visibility_Rule__mdt rule : rules) {
			Boolean result = true;

			//if this flag is set to true then it means we this record type should be always visible so no need to process any rule
			if(rule.Always_Visible__c) {
				record.Visible_on_ISS_Portal__c = true;
				break;
			}

			List<String> filters = rule.Field_Filter__c.trim().split(',');
			for(String filter : filters) {
				List<String> expr = filter.trim().split(' ');
				String caseField = expr[0];
				//If the field filter references a standard field, then we need to append the '__c' to match with metadata field
				String metadataField = caseField.endsWith('__c') ? caseField : caseField + '__c';
				String operator = expr[1];

				if(operator == '=') {
					result &= record.get(caseField) == rule.get(metadataField);
				} else if(operator == '!=') {
					result &= record.get(caseField) != rule.get(metadataField);
				} else if(operator == 'IN') {
					Set<String> setValues = getSetOfValues(String.valueOf(rule.get(metadataField)));
					result &= setValues.contains(String.valueOf(record.get(caseField)));
				} else if(operator == 'NOT_IN') {
					Set<String> setValues = getSetOfValues(String.valueOf(rule.get(metadataField)));
					result &= !setValues.contains(String.valueOf(record.get(caseField)));
				} else if(operator == 'NULL') { //this operator doesn't require create a field in metadata
					result &= record.get(caseField) == null;
				} else if(operator == 'NOT_NULL') { //this operator doesn't require create a field in metadata
					result &= record.get(caseField) != null;
				} else {
					result &= compareNonStringValues(caseField, metadataField, record, rule, operator);
				}
			}

			//if the record matches one rule we can break the loop and set the visibility to true
			if(result) {
				record.Visible_on_ISS_Portal__c = true;
				break;
			}
		}
	}

	/**
	 *  Method that check field type and execute the proper auxiliary method
	 */
	private static Boolean compareNonStringValues(String caseField, String metadataField, Case record, Case_Visibility_Rule__mdt rule, String operator) {
		if(rule.get(metadataField) instanceof Date) {
			return compareDates(Date.valueOf(record.get(caseField)), Date.valueOf(rule.get(metadataField)), operator);
		} else if(rule.get(metadataField) instanceof Datetime) {
			return compareDatetimes(Datetime.valueOf(record.get(caseField)), Datetime.valueOf(rule.get(metadataField)), operator);
		} else if(rule.get(metadataField) instanceof Integer) {
			 return compareIntegers(Integer.valueOf(record.get(caseField)), Integer.valueOf(rule.get(metadataField)), operator);
		} else {
			return false;
		}
	}

	/**
	 *  Method used to apply comparison on Date fields
	 */
	@TestVisible
	private static Boolean compareDates(Date caseDt, Date metadataDt, String operator) {
		if(operator == '>=') {
			return caseDt >= metadataDt;
		} else if(operator == '<=') {
			return caseDt <= metadataDt;
		} else if(operator == '>') {
			return caseDt > metadataDt;
		} else if(operator == '<') {
			return caseDt < metadataDt;
		} else {
			return false;
		}
	}

	/**
	 *  Method used to apply comparison on Datetime fields
	 */
	@TestVisible
	private static Boolean compareDatetimes(Datetime caseDt, Datetime metadataDt, String operator) {
		if(operator == '>=') {
			return caseDt >= metadataDt;
		} else if(operator == '<=') {
			return caseDt <= metadataDt;
		} else if(operator == '>') {
			return caseDt > metadataDt;
		} else if(operator == '<') {
			return caseDt < metadataDt;
		} else {
			return false;
		}
	}

	/**
	 *  Method used to apply comparison on Integer fields
	 */
	@TestVisible
	private static Boolean compareIntegers(Integer caseI, Integer metadataI, String operator) {
		if(operator == '>=') {
			return caseI >= metadataI;
		} else if(operator == '<=') {
			return caseI <= metadataI;
		} else if(operator == '>') {
			return caseI > metadataI;
		} else if(operator == '<') {
			return caseI < metadataI;
		} else {
			return false;
		}
	}

	/**
	 *  Method to parse custom metadata field and transform it's values in a Set
	 */
	private static Set<String> getSetOfValues(String metadataValues) {
		List<String> listValues = metadataValues.split('\n');
		Set<String> setValues = new Set<String>();
		for(String value : listValues) {
			setValues.add(value.trim());
		}

		return setValues;
	}

	/**
	 *  Method that retrives all recycle bin queues ids, those ids are set on a custom setting
	 */
	private static Set<Id> getRecycleBinIds() {
		Set<Id> recycleBinIds;
		UtilityCS__c recycleBinsCS = UtilityCS__c.getValues('CaseRecycleBinIds');
		if(recycleBinsCS != null && String.isNotBlank(recycleBinsCS.Value__c)) {
			recycleBinIds = new Set<Id>((List<Id>) recycleBinsCS.Value__c.split(','));
		} else {
			recycleBinIds = new Set<Id>();
		}

		return recycleBinIds;
	}

	/**
	 *  Method to retrieve all rules by RecordTypeId, this method only executes once per transaction to avoid SOQL limits,
	 *  since queries to a custom metadata including long text fields count to limits
	 */
	private static Map<Id,List<Case_Visibility_Rule__mdt>> getRulesByRecordTypeId() {
		if(mapRules != null) {
			return mapRules;
		}

		mapRules = new Map<Id,List<Case_Visibility_Rule__mdt>>();

		Map<String, Schema.SObjectField> fieldMap = Case_Visibility_Rule__mdt.sObjectType.getDescribe().fields.getMap();
		List<String> fields = new List<String>(fieldMap.keySet());

		String queryMetadata = 'SELECT ' + String.join(fields, ', ') + ' FROM Case_Visibility_Rule__mdt ORDER BY Always_Visible__c DESC';
		for(Case_Visibility_Rule__mdt rule : Database.query(queryMetadata)) {
			List<Case_Visibility_Rule__mdt> listRules = mapRules.get(rule.RecordTypeId__c);
			if(listRules == null) {
				listRules = new List<Case_Visibility_Rule__mdt>();
				mapRules.put(rule.RecordTypeId__c, listRules);
			}
			listRules.add(rule);
		}

		return mapRules;
	}
}
