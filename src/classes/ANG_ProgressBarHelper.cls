public with sharing class ANG_ProgressBarHelper {

	private static final String PROGRESS = 'inProgress';
	private static final String DONE = 'done';
	private static final String NOT_DONE = 'notDone';
	private static final String ERROR = 'error';

	public List<ANG_ProgressNode> progressNodes{get; set;}

	public ANG_ProgressBarHelper(String recordType, Map<String, String> objectsIds) {

		recordType = '%' + recordType + '%';

		List<ANG_ProgressBarSettings__c> settings =	[Select ValueOk__c,
															ValueProgress__c,
															Name,
															Label__c,
															Order__c,
															RecordType__c,
															ValueError__c,
															Label_Translatable__c
													   From ANG_ProgressBarSettings__c
													  Where RecordType__c like : recordType
												      Order by Order__c];

		progressNodes = new List<ANG_ProgressNode>();

		for(ANG_ProgressBarSettings__c setting : settings) {

			List<String> ValuesProgress = new List<String>();
			List<String> ValuesOk = new List<String>();
			List<String> ValuesError = new List<String>();

			if(setting.ValueProgress__c != null)
				ValuesProgress = setting.ValueProgress__c.split('\\|');

			if(setting.ValueOk__c != null)
				ValuesOk = setting.ValueOk__c.split('\\|');

			if(setting.ValueError__c != null)
				ValuesError = setting.ValueError__c.split('\\|');

			Boolean isDone = false;
			Boolean isError = false;
			Boolean isProgress = processValues(ValuesProgress, objectsIds);

			if(!isProgress) {
				isDone = processValues(ValuesOk, objectsIds);
			}

			if(!isProgress && !isDone) {
				isError = processValues(ValuesError, objectsIds);				
			}

			String status;
			if(isProgress) {
				status = PROGRESS;
			} else if(isDone) {
				status = DONE;
			} else if(isError) {
				status = ERROR;
			} else {
				status = NOT_DONE;
			}

			progressNodes.add(new ANG_ProgressNode(setting.Label__c, 
												   setting.Label_Translatable__c,
												   status,
											       setting.Order__c));	
		}
	}

	private Boolean processValues(List<String> values, Map<String, String> objectsIds) {

		List<String> operators = new List<String>();
		for(String aux : values) {

			if (aux.toUpperCase() == 'AND' || aux.toUpperCase() == 'OR') {
				operators.add(aux.toUpperCase());
			} else {

				//Separate the object.field from the value
				List<String> aux2 = aux.split('=');

				// If there is no equal sign then it's always false.
				if(aux2.size() == 1) {
					return false;
				}

				String objField = aux2[0];
				String val = aux2[1];

				//Separate object from field
				List<String> aux3 = objField.split('\\.');

				String obj = aux3[0].toUpperCase();
				String field = aux3[1];

				//Check if the field has the value
				Boolean status = executeSOQLQuery(obj,
											   	  field,
											   	  val,
											   	  objectsIds);

				operators.add(String.valueOf(status));
			}
		}
		return evaluate(operators);
	}

	private Boolean evaluate(List<String> operators) {
		Boolean rc = false;
		Boolean isAnd = false;
		for(String op : operators) {
			if(op == 'AND' || op == 'OR') {
				isAnd = (op == 'AND');
			} else {
				if(isAnd) {
					rc = (rc && Boolean.valueOf(op));
				} else {
					rc = (rc || Boolean.valueOf(op));
				}
			}
		}
		return rc;
	}

	private Boolean executeSOQLQuery(String soqlObject,
								     String soqlField,
									 String value,
									 Map<String, String> objectsIds) {

		if(objectsIds.containsKey(soqlObject)) {

			if(objectsIds.get(soqlObject) != null) {
				Boolean flagNotin = value.contains('<notin>');
				if(flagNotin) {
					value = value.replace('<notin>','');
				}

				Set<String> okSet = new Set<String>(value.split(';'));

				String soqlStr = 'Select ' + soqlField + ' From ' + soqlObject + ' Where id = \'' + objectsIds.get(soqlObject) + '\'';

				List<sObject> sobjList = Database.query(soqlStr);

				if(!sobjList.isEmpty()) {
					SObject so = sobjList[0];
					Object v = so.get(soqlField);

					String testValue;
					Boolean isBoolean = false;
					if(v instanceof Boolean) {
						isBoolean = true;
						testValue = String.valueOf((Boolean)v);
					} else {
						testValue = (String)v;	
					}				

					if(isBoolean) {
						return (okSet.contains(testValue));
					} else {
						return ((!flagNotin && okSet.contains(testValue)) || (flagNotin && !okSet.contains(testValue)));
					}

				}
			}
			return false;
		} else {
			System.debug(LoggingLevel.ERROR, 'Missing id for the sObject : ' + soqlObject);
			return false;
		}
	}
}