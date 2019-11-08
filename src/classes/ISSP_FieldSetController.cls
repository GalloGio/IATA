public with sharing class ISSP_FieldSetController {

	public static final string SEPARATOR = ';';

	public string fieldSet{get; set;}
	public string binaryFieldSet {get;set;}

	public List<Field> selectedFields{get; private set;}

	public List<Field> otherFields{get; private set;}

	private string sobjName;

	private Map<string,string> valuesMap;

	private set<string> levelFields;

	private String mandatoryFields;
	private String noBinaryFields;

	private Set<String> binaryJSON;

	public string getLanguage(){
		return Userinfo.getLanguage().toLowerCase().substring(0,2);
	}

	/*
	 * Contstruct and Init the Component controller
	 * @param sobjName: API Name of the sObject to select the fields from
	 * @param fields: string of the chosen fields of the given sObject concatenated with SEPARATOR between them
	 */
	public ISSP_FieldSetController(string mySobjName, string fields){
		setFieldSet(fields);
		sobjName = mySobjName;
		initComponent();
	}

	/*
	 * Contstruct and Init the Component controller
	 * @param sobjName: API Name of the sObject to select the fields from
	 * @param fields: string of the chosen fields of the given sObject concatenated with SEPARATOR between them
	 * @param myLevelFields: set of api name of fields corresponding to Object to bring the fields from specially for jolive
	 */
	public ISSP_FieldSetController(string mySobjName, string fields, set<string> myLevelFields){
		levelFields = myLevelFields;
		setFieldSet(fields);
		sobjName = mySobjName;
		initComponent();
	}

	/*
	 * Contstruct and Init the Component controller
	 * @param myValuesMap: map of all possible values and labels
	 * @param fields: string of the chosen fields of the given sObject concatenated with SEPARATOR between them
	 */
	public ISSP_FieldSetController(Map<string,string> myValuesMap, string fields){
		setFieldSet(fields);
		valuesMap = myValuesMap;
		initComponent();
	}


	/*===With MANDATORY and Binary fields===*/
	/*
	 * Contstruct and Init the Component controller
	 * @param sobjName: API Name of the sObject to select the fields from
	 * @param fields: string of the chosen fields of the given sObject concatenated with SEPARATOR between them
	 * @param myMandatoryFields: string of fields that cannot be un-selected. should be a subset of 'fields' and also concatenated with SEPARATOR between them
	 * @param myNoBinaryFields: string of fields that cannot be selected for input/ouput via the checkbox. should be a subset of 'fields' and also concatenated with SEPARATOR between them
	 */
	public ISSP_FieldSetController(string mySobjName, string fields, string myMandatoryFields, string myNoBinaryFields, Set<String> myBinaryJSON){
		setFieldSet(fields);
		sobjName = mySobjName;
		mandatoryFields = myMandatoryFields;
		noBinaryFields = myNoBinaryFields;
		binaryJSON = myBinaryJSON;
		initComponent();
	}

	/*
	 * Contstruct and Init the Component controller
	 * @param sobjName: API Name of the sObject to select the fields from
	 * @param fields: string of the chosen fields of the given sObject concatenated with SEPARATOR between them
	 * @param myLevelFields: set of api name of fields corresponding to Object to bring the fields from specially for jolive
	 * @param myMandatoryFields: string of fields that cannot be un-selected. should be a subset of 'fields' and also concatenated with SEPARATOR between them
	 * @param myNoBinaryFields: string of fields that cannot be selected for input/ouput via the checkbox. should be a subset of 'fields' and also concatenated with SEPARATOR between them
	 */
	public ISSP_FieldSetController(string mySobjName, string fields, set<string> myLevelFields, string myMandatoryFields, string myNoBinaryFields, Set<String> myBinaryJSON){
		levelFields = myLevelFields;
		setFieldSet(fields);
		sobjName = mySobjName;
		mandatoryFields = myMandatoryFields;
		noBinaryFields = myNoBinaryFields;
		binaryJSON = myBinaryJSON;
		initComponent();
	}

	/*
	 * Contstruct and Init the Component controller
	 * @param myValuesMap: map of all possible values and labels
	 * @param fields: string of the chosen fields of the given sObject concatenated with SEPARATOR between them
	 * @param myMandatoryFields: string of fields that cannot be un-selected. should be a subset of 'fields' and also concatenated with SEPARATOR between them
	 */
	public ISSP_FieldSetController(Map<string,string> myValuesMap, string fields, string myMandatoryFields){
		setFieldSet(fields);
		valuesMap = myValuesMap;
		mandatoryFields = myMandatoryFields;
		initComponent();
	}
	/*===   ===*/

	/*
	 * ReInit the Component controller
	 * Call this function to reInit the component
	 */
	public void initComponent(){
		Map<String, Field> fieldsMap = new Map<String, Field>();
		if(sobjName != null){
			Map<String, Schema.SObjectField> sobjFieldsMap = Schema.getGlobalDescribe().get(sobjName).getDescribe().fields.getMap();

			fieldsMap = initFieldsMap(sobjFieldsMap);
			addLevelFields(sobjFieldsMap, fieldsMap);
		}else{
			fieldsMap = initFieldsMap();
		}
		initFields(fieldsMap);
	}

	private void addLevelFields(Map<String, Schema.SObjectField> sobjFieldsMap, Map<String, Field> fieldsMap){
		for(string fieldStr : levelFields)
			addLevelFields(fieldStr,'', sobjFieldsMap, fieldsMap);
	}

	private void addLevelFields(string chosenField, string previousKey, Map<String, Schema.SObjectField> sobjFieldsMap, Map<String, Field> fieldsMap){
		string fieldName = chosenField, relationshipField, chosenField2;
		if(chosenField.contains('.')){
			relationshipField = chosenField.substring(0,chosenField.indexOf('.'));
			chosenField2 = chosenField.substring(relationshipField.length() + 1);
			if(relationshipField.endsWith('__r'))
				fieldName = relationshipField.substring(0, relationshipField.length() - 1) + 'c';
			else
				fieldName = relationshipField + 'Id';
		}
		Schema.SObjectField SOF = sobjFieldsMap.get(fieldName);
		if(SOF != null){
			Schema.Describefieldresult DFR = SOF.getDescribe();
			List <Schema.sObjectType> sobjTypeList = DFR.getReferenceTo();
			if(sobjTypeList.size() == 1){
				Schema.DescribeSObjectResult DSO = sobjTypeList[0].getDescribe();
				Map<String, Schema.SObjectField> sobj2FieldsMap = DSO.fields.getMap();
				if(chosenField.contains('.')){
					addLevelFields(chosenField2, previousKey + relationshipField + '.', sobj2FieldsMap, fieldsMap);
				}
				else{
					for(string fieldStr2 : sobj2FieldsMap.keySet()){
						if(canAddField(sobj2FieldsMap.get(fieldStr2))){
							string apiName = getKey(previousKey + DFR.getRelationshipName(),sobj2FieldsMap.get(fieldStr2).getDescribe().getName() );
							Field currentField = getField(apiName, DSO.getLabel(),sobj2FieldsMap.get(fieldStr2));
							fieldsMap.put(apiName, currentField);
						}
					}
				}
			}
		}

	}

	private string getKey(string pref, string suf){
		return pref + '.' + suf;
	}

	private void setFieldSet(string fields){
		fieldSet = fields;
		if(fields == null)
			fieldSet = '';
	}

	private Map<String, Field> initFieldsMap(){
		Map<String, Field> fieldMap = new Map<String, Field>();
		for(string fieldStr : valuesMap.keySet()){
			Field currentField = getField(fieldStr, valuesMap.get(fieldStr));
			fieldMap.put(fieldStr, currentField);
		}
		return fieldMap;
	}

	private Map<String, Field> initFieldsMap(Map<String, Schema.SObjectField> sobjFieldsMap){
		Map<String, Field> fieldMap = new Map<String, Field>();
		for(string fieldStr : sobjFieldsMap.keySet()){
			if(canAddField(sobjFieldsMap.get(fieldStr))){
				Field currentField = getField(fieldStr, sobjFieldsMap.get(fieldStr));
				fieldMap.put(fieldStr, currentField);
			}
		}
		return fieldMap;
	}

	private void initFields (map<String, Field> fieldsMap) {
		set<String> mndtryFlds;
		set<String> bnryFlds;

		if (mandatoryFields != null)
			mndtryFlds = new set<String> (mandatoryFields.split (SEPARATOR));
		else
			mndtryFlds = new set<String>();

		if (noBinaryFields != null)
			bnryFlds = new set<String> (noBinaryFields.split (SEPARATOR));
		else
			bnryFlds = new set<String> ();

		selectedFields = new list<Field> ();
		otherFields = new list<Field> ();
		set<string> chosenFields = new set<String> ();

		for (string fieldStr : fieldSet.split(SEPARATOR)) {
			if (! fieldsMap.containsKey (fieldStr))
				continue;

			Field f = fieldsMap.get (fieldStr);

			chosenFields.add (fieldStr);
			selectedFields.add (f);

			if (mndtryFlds.contains (fieldStr))
				f.htmlClass += ' mandatory-option ';

			if(bnryFlds.contains (fieldStr) || fieldStr.contains ('.'))
				f.htmlClass += ' no-binary ';
			else if (binaryJSON != null && binaryJSON.contains (fieldStr))
				f.htmlClass += ' binary-on ';
		}

		// build sorted list
		map<String, Field> m = new map<String, Field> ();
		for (String api : fieldsMap.keySet ()) {
			if (chosenFields.contains (api))
				continue;

			Field f = fieldsMap.get (api);
			m.put (f.label, f);

			if (bnryFlds.contains (api) || api.contains ('.'))
				f.htmlClass += ' no-binary ';
		}

		list<String> labels = new list<String> (m.keySet ());
		labels.sort ();
		for (String label : labels)
			otherFields.add (m.get (label));

	} // initFields (map<String, Field>)

	private Field getField(string fieldKey,Schema.SObjectField sof){
		Field currentField = new Field(sof.getDescribe().getLabel(),fieldKey);
		return currentField;
	}

	private Field getField(string fieldKey,string prefixSof,Schema.SObjectField sof){
		Field currentField = new Field(prefixSof + ' - ' + sof.getDescribe().getLabel(),fieldKey);
		return currentField;
	}


	private Field getField(string fieldKey,string fieldValue){
		Field currentField = new Field(fieldValue,fieldKey);
		return currentField;
	}
	private boolean canAddField(Schema.sobjectfield sof){
		Schema.Describefieldresult DFR = sof.getDescribe();
		if(DFR.isAccessible() && !DFR.isIdLookup() && DFR.getReferenceTo().size() == 0)
			return true;
		return false;
	}

	public string getSeparator(){
		return SEPARATOR;
	}

	// moved to Utils.cls
	public class Field {

		public String label     { get; private set; }
		public String apiName   { get; private set; }
		public String htmlClass { get; private set; }

		public Field (String myLabel, String myApiName) { label = myLabel; apiName = myApiName; htmlClass = ''; }

	}
}
