/**
 * This class is used to apply the logic that makes a case visible on IATA Portal
 * When a visible case ownership changes to a Recycle Bin queue the case is set always set to invisible
 * Otherwise "Case_Visibility_Rule__mdt" metadata contains the rules, organized by recordType, that make a case visible
 * Author           Date            Description
 * Unknown          Unknown         Initial version
 * C Saramagaio     February'20     1. Add affected rules validation
 *                                  2. Organize rules, criteria and expressions in a proper structure
 *                                      to make validations easier and keep code organized and clear
 *                                  3. Add class documentation
 *                                  4. Fix inline Comments to reduce length of used APEX code
 *                                  5. Format Code / fix indentation
 *                                  6. Handle Boolean type by including two new operators IS_TRUE and IS_FALSE
 */
public without sharing class CaseVisibilityEngine {
	
	private static VisibilityRuleSet ruleSet;
	
	static {
		ruleSet = new VisibilityRuleSet(getRules());
	}
	
	/**
	 * Entry point of Case Visibility Engine
	 * Updates Case Visibility in Portal based on visibility predefined rules
	 * @param oldCases - Map of Cases before update action with previous values
	 *                  null in case of record being inserted
	 * @param newCases - List of inserted or updated cases with current values
	 */
	public static void execute(Map<Id, Case> oldCases, List<Case> newCases) {
		Set<Id> recycleBinIds = getRecycleBinIds();
		
		for (Case record : newCases) {
			Case oldRecord = Trigger.isInsert ? null : oldCases.get(record.Id);
			
			if (record.Visible_on_ISS_Portal__c && recycleBinIds.contains(record.OwnerId)) {
				record.Visible_on_ISS_Portal__c = false;
			} else if (needsRecalulation(oldRecord, record, recycleBinIds)) {
				processVisibilityRules(record);
			}
		}
	}
	
	/**
	 * Evaluates if the Case Visibility needs to be recalculates based on
	 * DML option performed and and affected fields
	 * @param oldRecord - object values before being updated
	 * @param record - object values being updated or inserted
	 * @param recycleBinIds - Set of ids of deleted cases
	 * @return If the record visibility needs to be recalculated
	 */
	public static Boolean needsRecalulation(Case oldRecord, Case record, Set<Id> recycleBinIds) {
		return oldRecord == null || !recycleBinIds.contains(record.OwnerId)
			&& ((record.RecordTypeId != oldRecord.RecordTypeId) || affectedCriteriaFields(record, oldRecord));
	}
	
	/**
	 *  Method that compares each rule with the record values, to be set to true all criterias in a rule must be true
	 *  (it applies AND logic eg.: field1 operator value1 AND field2 operator value2 AND etc..)
	 *  To set visibility to true at least one of the rules must match with record values
	 *  (it applies OR logic eg.: rule1 OR rule2 OR etc...)
	 */
	private static void processVisibilityRules(Case record) {
		if (ruleSet == null) {
			return;
		}
		
		VisibilityRule rule = ruleSet.getRulesByRecordType(record.RecordTypeId);
		if (rule == null) {
			return;
		}
		
		record.Visible_on_ISS_Portal__c = false;

		for (VisibilityRuleCriteria criteria : rule.criteriaList) {
			Boolean result = true;
			
			// if this flag is set to true then it means we this record type should be always visible so no need to process any rule
			if (criteria.allwaysVisible) {
				record.Visible_on_ISS_Portal__c = true;
				break;
			}
			
			for (VisibilityRuleExpression expression : criteria.expressionList) {
				result &= expression.evaluateRecord(record);
			}
			
			// if the record matches one rule (criteria) we can break the loop and set the visibility to true
			if (result) {
				record.Visible_on_ISS_Portal__c = true;
				break;
			}
		}
	}
	
	/**
	 * Validates if any rule has been affected
	 * @param record - record state after update
	 * @param oldRecord - record state before update
	 * @return If any field defined in an applicable rule for the current
	 * record is being chaged in the current tansaction
	 */
	private static Boolean affectedCriteriaFields(Case record, Case oldRecord) {
		Boolean result = false;
		
		if (oldRecord != null) {
			for (String field : ruleSet.getRulesByRecordType(record.RecordTypeId).ruleFields) {
				result |= record.get(field) != oldRecord.get(field);
			}
		} else {
			result = true;
		}
				
		return result;
	}
	
	/**
	 * If the field filter references a standard field
	 * then we need to append the '__c' to match with metadata field
	 * @param caseField - field API name in Case object
	 * @return field API name in rule metadata
	 */
	private static String getMetadataField(String caseField) {
		return caseField.endsWith('__c') ? caseField : caseField + '__c';
	}
	
	/**
	 *  Method used to apply comparison on Date fields
	 */
	@TestVisible
	private static Boolean compareDates(Date caseDt, Date metadataDt, String operator) {
		if (operator == '>=') {
			return caseDt >= metadataDt;
		} else if (operator == '<=') {
			return caseDt <= metadataDt;
		} else if (operator == '>') {
			return caseDt > metadataDt;
		} else if (operator == '<') {
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
		if (operator == '>=') {
			return caseDt >= metadataDt;
		} else if (operator == '<=') {
			return caseDt <= metadataDt;
		} else if (operator == '>') {
			return caseDt > metadataDt;
		} else if (operator == '<') {
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
		if (operator == '>=') {
			return caseI >= metadataI;
		} else if (operator == '<=') {
			return caseI <= metadataI;
		} else if (operator == '>') {
			return caseI > metadataI;
		} else if (operator == '<') {
			return caseI < metadataI;
		} else {
			return false;
		}
	}
	
	/**
	 *  Method that retrives all recycle bin queues ids, those ids are set on a custom setting
	 */
	private static Set<Id> getRecycleBinIds() {
		Set<Id> recycleBinIds;
		UtilityCS__c recycleBinsCS = UtilityCS__c.getValues('CaseRecycleBinIds');
		if (recycleBinsCS != null && String.isNotBlank(recycleBinsCS.Value__c)) {
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
	private static List<Case_Visibility_Rule__mdt> getRules() {
		Map<String, Schema.SObjectField> fieldMap = Case_Visibility_Rule__mdt.sObjectType.getDescribe().fields.getMap();
		List<String> fields = new List<String>(fieldMap.keySet());
		String queryMetadata = 'SELECT ' + String.join(fields, ', ') + ' FROM Case_Visibility_Rule__mdt ORDER BY Always_Visible__c DESC';
		return (List<Case_Visibility_Rule__mdt>) Database.query(queryMetadata);
	}
	
	/**
	 * Aggregates all the Visibility Rules indexed by Record Type
	 * It allows to retrieve a Visibility Rule by specifying the Record Type
	 */
	public class VisibilityRuleSet {
		private Map<String, VisibilityRule> rules;
		
		public VisibilityRuleSet() {
			this.rules = new Map<String, VisibilityRule>();
		}
		
		public VisibilityRuleSet(List<Case_Visibility_Rule__mdt> ruleDefinitions) {
			this();
			for (Case_Visibility_Rule__mdt ruleDefinition : ruleDefinitions) {
				VisibilityRule rule = this.rules.get(ruleDefinition.RecordTypeId__c);
				if (rule == null) {
					rule = new VisibilityRule(ruleDefinition.RecordTypeId__c);
					this.rules.put(ruleDefinition.RecordTypeId__c, rule);
				}
				rule.addCriteria(ruleDefinition);
			}
		}
		
		/**
		 * Returns a Visibility Rule by a given Record Type
		 * @param recordTypeId - The record type to be evaluated
		 * @return Proper VisibilityRule
		 */
		public VisibilityRule getRulesByRecordType(String recordTypeId) {
			return this.rules.get(recordTypeId);
		}
		
	}
	
	/**
	 * Represents a list of Visibility Criteria which can contain multiple
	 * evaluation expressions
	 * Each is linked to a specific Record Type
	 */
	public class VisibilityRule {
		public String recordType;
		public List<VisibilityRuleCriteria> criteriaList;
		public Set<String> ruleFields;
		
		public VisibilityRule() {
			this.criteriaList = new List<VisibilityRuleCriteria>();
			this.ruleFields = new Set<String>();
		}
		
		public VisibilityRule(String recordTypeId) {
			this();
			this.recordType = recordTypeId;
		}
		
		/**
		 * Adds a Visibility Criteria to the current rule
		 * @param rule - Custom metadata definition of the Visibility Criteria
		 */
		public void addCriteria(Case_Visibility_Rule__mdt rule) {
			VisibilityRuleCriteria criteria = new VisibilityRuleCriteria(rule);
			this.criteriaList.add(criteria);
			this.ruleFields.addAll(criteria.criteriaFields);
		}
	}
	
	/**
	 * Represents the Visibility Criteria aggregating a list of expressions
	 * It also sotres a list of fields used in all expressions
	 */
	public class VisibilityRuleCriteria {
		public Boolean allwaysVisible;
		public List<VisibilityRuleExpression> expressionList;
		public Set<String> criteriaFields;
		
		public VisibilityRuleCriteria() {
			this.expressionList = new List<VisibilityRuleExpression>();
			this.criteriaFields = new Set<String>();
		}
		
		public VisibilityRuleCriteria(Case_Visibility_Rule__mdt rule) {
			this();
			this.allwaysVisible = rule.Always_Visible__c;
			if (!this.allwaysVisible) {
				List<String> filters = rule.Field_Filter__c.trim().split(',');
				for (String filter : filters) {
					List<String> expr = filter.trim().split(' ');
					String objectField = expr[0];
					String ruleField = getMetadataField(objectField);
					String operator = expr[1];
					this.criteriaFields.add(objectField);
					Object ruleValue;
					try {
						ruleValue = rule.get(ruleField);
					} catch (SObjectException e) {
						ruleValue = null;
					}
					this.expressionList.add(new VisibilityRuleExpression(objectField, operator, ruleValue));
				}
			}
		}
	}
	
	/**
	 * Represents an Expression in a complex Visibility Rule Criteria
	 * The Expression stores the field API name when going to evaluate
	 * as well as the operator and the value we comparing to the field
	 */
	public class VisibilityRuleExpression {
		private String objectField;
		private String operator;
		private Object ruleValue;
		private Set<String> valueSet;
		
		public VisibilityRuleExpression(String objectField, String operator, Object ruleValue) {
			this.objectField = objectField;
			this.operator = operator;
			this.ruleValue = ruleValue;
			
			if (this.operator == 'IN' || this.operator == 'NOT_IN') {
				this.loadValueSet();
			}
		}
		
		/**
		 *  Method to parse data from custom metadata field and transform it's values in a Set
		 */
		private void loadValueSet() {
			this.valueSet = new Set<String>();
			for (String value : String.valueOf(this.ruleValue).split('\n')) {
				this.valueSet.add(value.trim());
			}
		}
		
		/**
		 * Evaluates one record against a criteria expression
		 * @param record - The record being evaluated
		 * @return If the record is according to the expression
		 */
		public Boolean evaluateRecord(Case record) {
			Boolean result;
			if (this.operator == '=') {
				result = record.get(this.objectField) == this.ruleValue;
			} else if (this.operator == '!=') {
				result = record.get(this.objectField) != this.ruleValue;
			} else if (this.operator == 'IN') {
				result = this.valueSet.contains(String.valueOf(record.get(this.objectField)));
			} else if (this.operator == 'NOT_IN') {
				result = !this.valueSet.contains(String.valueOf(record.get(this.objectField)));
			} else if (this.operator == 'NULL') {
				// this operator doesn't require create a field in metadata
				result = record.get(this.objectField) == null;
			} else if (this.operator == 'NOT_NULL') {
				// this operator doesn't require create a field in metadata
				result = record.get(this.objectField) != null;
			} else if (this.operator == 'IS_TRUE') {
				// this operator doesn't require create a field in metadata
				result = Boolean.valueOf(record.get(this.objectField));
			} else if (this.operator == 'IS_FALSE') {
				// this operator doesn't require create a field in metadata
				result = !Boolean.valueOf(record.get(this.objectField));
			} else {
				result = compareNonStringValues(record);
			}
			return result;
		}
		
		/**
		 * Method that check field type and execute the proper auxiliary method
		 * Compares the object field with a value defined in custom metadata
		 * according to the defined operator
		 * @return The comparision result
		 */
		private Boolean compareNonStringValues(Case record) {
			if (this.ruleValue instanceof Date) {
				return compareDates(Date.valueOf(record.get(this.objectField)), Date.valueOf(this.ruleValue), this.operator);
			} else if (this.ruleValue instanceof Datetime) {
				return compareDatetimes(Datetime.valueOf(record.get(this.objectField)), Datetime.valueOf(this.ruleValue), this.operator);
			} else if (this.ruleValue instanceof Integer) {
				return compareIntegers(Integer.valueOf(record.get(this.objectField)), Integer.valueOf(this.ruleValue), this.operator);
			} else {
				return false;
			}
		}
	}
}