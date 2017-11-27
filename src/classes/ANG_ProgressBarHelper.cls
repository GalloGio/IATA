public with sharing class ANG_ProgressBarHelper {

	private static final String DONE = 'done';
	private static final String NOT_DONE = 'notDone';
	private static final String ERROR = 'error';

	public List<ANG_ProgressNode> progressNodes{get; set;}

	public ANG_ProgressBarHelper(String recordType, Map<String, String> objectsIds) {

		List<ANG_ProgressBarSettings__c> settings =	[Select ValueOk__c,
															Object__c,
															Name,
															Field__c,
															Order__c,
															RecordType__c,
															Label__c,
															ValueError__c,
															Label_Translatable__c
													   From ANG_ProgressBarSettings__c
													  Where RecordType__c =: recordType
												      Order by Order__c];

		progressNodes = new List<ANG_ProgressNode>();

		for(ANG_ProgressBarSettings__c setting : settings) {

			progressNodes.add(new ANG_ProgressNode(setting.Label__c, 
												   setting.Label_Translatable__c,
											       executeSOQLQuery(setting.Object__c.toUpperCase(),
											   					    setting.Field__c,
											   					    setting.ValueOk__c,
											   					    setting.ValueError__c,
											   					    objectsIds),
											       setting.Order__c));
	
		}
	}

	private String executeSOQLQuery(String soqlObject,
								    String soqlField,
									String valueOk,
									String valueError,
									Map<String, String> objectsIds) {

		if(objectsIds.containsKey(soqlObject)) {

			Boolean flagNotinOk = valueOk.contains('<notin>');
			if(flagNotinOk) {
				valueOk = valueOk.replace('<notin>','');
			}

			Boolean flagNotinError = valueError.contains('<notin>');
			if(flagNotinError) {
				valueError = valueError.replace('<notin>','');
			}

			Set<String> okSet = new Set<String>(valueOk.split(';'));
			Set<String> errorSet = new Set<String>(valueError.split(';'));

			String soqlStr = 'Select ' + soqlField + ' From ' + soqlObject + ' Where id = \'' + objectsIds.get(soqlObject) + '\'';

			List<sObject> sobjList = Database.query(soqlStr);

			if(!sobjList.isEmpty()) {
				SObject so = sobjList[0];
				String testValue = (String)so.get(soqlField);

				if( (!flagNotinOk && okSet.contains(testValue)) || (flagNotinOk && !okSet.contains(testValue)) ) {
					return DONE;
				} else if( (!flagNotinError && errorSet.contains(testValue)) || (flagNotinError && !errorSet.contains(testValue)) ) {
					return ERROR;
				} else {
					return NOT_DONE;
				}
			}		
			return NOT_DONE;
		} else {
			System.debug(LoggingLevel.ERROR, 'Missing id for the sObject : ' + soqlObject);
			return NOT_DONE;
		}
	}	
}