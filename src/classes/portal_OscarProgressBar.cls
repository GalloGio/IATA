public with sharing class portal_OscarProgressBar {

	private static final String PROGRESS = 'inProgress';
	private static final String DONE = 'done';
	private static final String NOT_DONE = 'notDone';
	private static final String ERROR = 'error';

	private static Map<String,String> labelMap = new Map<String, String>();

	@AuraEnabled
	public static List<ANG_ProgressNode> progressNodes{get; set;}

	@AuraEnabled
	public static List<ANG_ProgressNode> getOscarProgress(String caseId){
		Case newCase = [SELECT id, OSCAR__c, Oscar__r.Process__c, Reason1__c, RecordType.DeveloperName FROM CASE WHERE id = :caseId];
		getLabels();
		ANG_ProgressBarHelper(newCase);

		return progressNodes;
	}

	@AuraEnabled
	public static void ANG_ProgressBarHelper(Case cse) {
		progressNodes = new List<ANG_ProgressNode>();

		ANG_ProgressBarSetting__mdt setting = getProgressBarSetting(cse);
		if (setting==null) {
			System.debug('ANG_ProgressBarHelper: No valid ANG_ProgressBarSetting__mdt found.');
			return;
		}

		System.debug('ANG_ProgressBarHelper: Using setting ' + setting);
		list<ANG_ProgressBarStep__mdt > listSteps = [
			SELECT MasterLabel,
				   Description__c,
				   ValueProgress__c,
				   ValueOk__c,
				   ValueError__c,
				   IconProgress__c,
				   IconOk__c,
				   IconError__c,
				   IconNotDone__c,
				   Is_Visible__c,
				   Order__c
			FROM ANG_ProgressBarStep__mdt
			WHERE Parent__c = :setting.Id
			ORDER BY Order__c ASC];

		Integer count = 1;
		Boolean isLast = false;
		for(ANG_ProgressBarStep__mdt step : listSteps) {
			System.debug('ANG_ProgressBarHelper: Processing step ' + step);

			if(step.Is_Visible__c==null || processStatus(step.Is_Visible__c, cse.Id)) {

				Boolean isDone = false;
				Boolean isError = false;
				Boolean isProgress = processStatus(step.ValueProgress__c, cse.Id);

				if(!isProgress) {
					isDone = processStatus(step.ValueOk__c, cse.Id);
				}

				if(!isProgress && !isDone) {
					isError = processStatus(step.ValueError__c, cse.Id);
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

				if ( count >= listSteps.size() ) {
					isLast = true;
				}

				count++;

				ANG_ProgressNode node =
					new ANG_ProgressNode(step, status, isLast);
				progressNodes.add(node);
			}
		}
	}

	/**
		Finds the Progress bar setting matching the input case, if exists
	**/
	private static ANG_ProgressBarSetting__mdt getProgressBarSetting(Case cse) {
		list<ANG_ProgressBarSetting__mdt> listSetting =[
			SELECT Id, Condition__c
			FROM ANG_ProgressBarSetting__mdt
			WHERE RecordType__c = :cse.RecordType.DeveloperName];

		for (ANG_ProgressBarSetting__mdt setting: listSetting) {
			String query = 'SELECT Id FROM Case WHERE Id=\'' + cse.Id + '\'';
			if (setting.Condition__c!=null) {
				query+= ' AND ' + setting.Condition__c;
			}
			System.debug('Test Setting ' + setting + ' with query: ' + query);
			List<sObject> listResult = Database.query(query);
			if (!listResult.isEmpty()) return setting;
		}
		return null;
	}

	/**
	Executes a condition for a specific step
	**/
	private static Boolean processStatus(String condition, Id sobjectId) {
		String query = 'SELECT Id'
		+ ' FROM ' + sobjectId.getSobjectType()
		+ ' WHERE Id = \'' + sobjectId + '\'';
		if (!String.isEmpty(condition)) {
			query += ' AND (' + condition + ')';
		}

		try {
			List<sObject> listResult = Database.query(query);
			return !listResult.isEmpty();
		} catch (Exception e) {
			System.debug('processStatus returned false because there was an error in the query: ' + query);
			return false;
		}
	}

	/**
	Get Label Values for the Setps
	**/
	private static void getLabels() {
		labelMap.put('ISSP_IDFS_Title_01', System.Label.ISSP_IDFS_Title_01);
		labelMap.put('ISSP_IDFS_Title_02', System.Label.ISSP_IDFS_Title_02);
		labelMap.put('ISSP_IDFS_Title_03', System.Label.ISSP_IDFS_Title_03);
		labelMap.put('ISSP_IDFS_Title_04', System.Label.ISSP_IDFS_Title_04);
		labelMap.put('ISSP_IDFS_Title_05', System.Label.ISSP_IDFS_Title_05);
		labelMap.put('ISSP_IDFS_Title_06', System.Label.ISSP_IDFS_Title_06);
		labelMap.put('ISSP_IDFS_Title_07', System.Label.ISSP_IDFS_Title_07);
		labelMap.put('ISSP_IDFS_Title_08', System.Label.ISSP_IDFS_Title_08);
		labelMap.put('ISSP_IDFS_Title_09', System.Label.ISSP_IDFS_Title_09);
		labelMap.put('ISSP_IDFS_Title_10', System.Label.ISSP_IDFS_Title_10);

		labelMap.put('ISSP_ProgressBar_Agreement', System.Label.ISSP_ProgressBar_Agreement);
		labelMap.put('ISSP_ProgressBar_ApplicationProcessing', System.Label.ISSP_ProgressBar_ApplicationProcessing);
		labelMap.put('ISSP_ProgressBar_Application_Approved', System.Label.ISSP_ProgressBar_Application_Approved);
		labelMap.put('ISSP_ProgressBar_Application_Review', System.Label.ISSP_ProgressBar_Application_Review);
		labelMap.put('ISSP_ProgressBar_ChangeProcessing', System.Label.ISSP_ProgressBar_ChangeProcessing);
		labelMap.put('ISSP_ProgressBar_FinalValidation', System.Label.ISSP_ProgressBar_FinalValidation);
		labelMap.put('ISSP_ProgressBar_Financial_Security', System.Label.ISSP_ProgressBar_Financial_Security);
		labelMap.put('ISSP_ProgressBar_Payment', System.Label.ISSP_ProgressBar_Payment);
		labelMap.put('ISSP_ProgressBar_SanityCheck', System.Label.ISSP_ProgressBar_SanityCheck);
		labelMap.put('ISSP_ProgressBar_Submitted', System.Label.ISSP_ProgressBar_Submitted);


		labelMap.put('NEW_HO_SanityCheck', System.Label.NEW_HO_SanityCheck);
		labelMap.put('NEW_HO_Submitted', System.Label.NEW_HO_Submitted);
	}


	public class ANG_ProgressNode {
		@AuraEnabled
		public String title {get; set;}

		@AuraEnabled
		public String description {get; set;}

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

		public ANG_ProgressNode(ANG_ProgressBarStep__mdt step, String status, Boolean isLast) {
			this.title = labelMap.get(step.MasterLabel);
			this.description = step.Description__c;
			this.status = status;
			this.nodeNumber = Integer.ValueOf(step.Order__c);
			this.isInProgress = (status == PROGRESS ? true : false);
			this.isDone = (status == DONE ? true : false);
			this.isNotDone = (status == NOT_DONE ? true : false);
			this.isError = (status == ERROR ? true : false);
			this.isLastStatus = isLast;
		}
	}

}
