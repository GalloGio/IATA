/**
 * @description This Class aims to implement a batch that sends a notification about Annual Survey submission deadline for each Airline contact
 *
 *
 * @creation  2019-01-25
 * @author    José Cardoso
 */
global class CurrencyCenter_AnnualSurveyNoticeBatch implements Database.Batchable<sObject>, Schedulable{

	private String emailTemplate {get; set;}
	private Integer noticeOrder {get; set;}

	public CurrencyCenter_AnnualSurveyNoticeBatch(Integer reminderOrder){
		noticeOrder = reminderOrder;
		switch on reminderOrder {
			when 1 {
				emailTemplate = 'Currency_Center_Annual_Survey_Notification';
			}
			when 2 {
				emailTemplate = 'Currency_Center_Annual_Survey_Notification';
			}
			when 3 {
				emailTemplate = 'Currency_Center_Annual_Survey_Notification_Last';
			}
			when else {
				throw new annualSurveyNoticeBatchException('You must specify a reminderOrder between 1-3.');
			}
		}
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(ISSP_CurrencyCenterUtil.batchAirlineQuery);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope){

		String year = String.valueOf(System.now().year()-1);
		List<Currency_Center_Survey__c> existingCcsList = [SELECT Id, Airline__c FROM Currency_Center_Survey__c
															WHERE Survey__c = 'Annual' AND Status__c = 'Draft'
																AND Year_Survey__c =:year AND Airline__c in:scope
																AND RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdAnnualSurvey];

		if(!existingCcsList.isEmpty()){
			ISSP_CurrencyCenterUtil.sendEmailsBatch(existingCcsList,'IATA Noreply',emailTemplate);
		}
	}

	global void finish(Database.BatchableContext BC){

	}

	global void execute(SchedulableContext ctx){
		CurrencyCenter_AnnualSurveyNoticeBatch b = new CurrencyCenter_AnnualSurveyNoticeBatch(noticeOrder);
		database.executeBatch(b);
	}

	private class annualSurveyNoticeBatchException extends Exception{

	}

}