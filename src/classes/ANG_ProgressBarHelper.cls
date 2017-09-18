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
											       executeSOQLQuery(setting.Object__c,
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
			String soqlStr = 'Select ' + soqlField + ' From ' + soqlObject + ' Where id = \'' + objectsIds.get(soqlObject) + '\'';

			List<sObject> sobjList = Database.query(soqlStr);

			if(!sobjList.isEmpty()) {
				SObject so = sobjList[0];
				Object testValue = so.get(soqlField);
				if(testValue == valueOk) {
					return DONE;
				} else if(testValue == valueError) {
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