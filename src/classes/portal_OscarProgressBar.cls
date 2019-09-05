public with sharing class portal_OscarProgressBar {

    private static final String PROGRESS = 'inProgress';
	private static final String DONE = 'done';
	private static final String NOT_DONE = 'notDone';
	private static final String ERROR = 'error';

    @AuraEnabled
    public static List<ANG_ProgressNode> getOscarProgress(String caseId){
        Case newCase = [SELECT id, OSCAR__c, Oscar__r.Process__c, Reason1__c FROM CASE WHERE id = :caseId];

        Map<String, String> objectsIds = new Map<String, String>();
        objectsIds.put('AMS_OSCAR__C', newCase.OSCAR__c);
        objectsIds.put('CASE', newCase.id);

        // If the process is null the use the reason on the casop.
        String process = '';
        if(newCase.Oscar__r.Process__c == null || (newCase.Oscar__r.Process__c != null && newCase.Oscar__r.Process__c == '')) {
            process = newCase.Reason1__c;
        } else {
            process = newCase.Oscar__r.Process__c;
        }

        return new List<ANG_ProgressNode>(portal_OscarProgressBar(process, objectsIds));
    }

    @AuraEnabled
	public static List<ANG_ProgressNode> portal_OscarProgressBar(String recordType, Map<String, String> objectsIds) {

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

		List<ANG_ProgressNode> progressNodes = new List<ANG_ProgressNode>();

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

        return progressNodes;
	}

	private static Boolean processValues(List<String> values, Map<String, String> objectsIds) {

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

	private static Boolean evaluate(List<String> operators) {
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

	private static Boolean executeSOQLQuery(String soqlObject,
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

    public class ANG_ProgressNode {
        @AuraEnabled
        public String title {get; set;}

        @AuraEnabled
        public String titleTranslatable {get; set;}

        @AuraEnabled
        public String status {get; set;}

        @AuraEnabled
        public Decimal nodeNumber {get; set;}

        @AuraEnabled
        public Boolean isInProgress {get; set;}

        @AuraEnabled
        public Boolean isDone {get; set;}

        @AuraEnabled
        public Boolean isNotDone {get; set;}

        @AuraEnabled
        public Boolean isError {get; set;}

		@AuraEnabled
        public Boolean isLastStatus {get; set;}

        public ANG_ProgressNode(String title, String titleTranslatable, String status, Decimal nodeNumber) {
            this.title = title;
            this.titleTranslatable = titleTranslatable;
            this.status = status;
            this.nodeNumber = nodeNumber;
            this.isInProgress = (status == PROGRESS ? true : false);
            this.isDone = (status == DONE ? true : false);
            this.isNotDone = (status == NOT_DONE ? true : false);
            this.isError = (status == ERROR ? true : false);
			this.isLastStatus = (title == 'Application Approved' ? true : false);
	    }
    }

}
