/**
 * @description This Class aims to implement a batch that sends a notification about Monthly Survey submission deadline for each Airline contact
 *
 *
 * @creation  2019-01-29
 * @author    José Cardoso
 */
global class CurrencyCenter_MonthlySurveyNoticeBatch implements Database.Batchable<sObject>, Schedulable{

	private String emailTemplate {get; set;}
	private Integer noticeOrder {get; set;}

	public CurrencyCenter_MonthlySurveyNoticeBatch(Integer reminderOrder){
		noticeOrder = reminderOrder;
		switch on reminderOrder {
			when 1 {
				emailTemplate = 'Currency_Center_Monthly_Survey_Notification_First';
			}
			when 2 {
				emailTemplate = 'Currency_Center_Monthly_Survey_Notification';
			}
			when 3 {
				emailTemplate = 'Currency_Center_Monthly_Survey_Notification_Last';
			}
			when else {
				throw new monthlySurveyNoticeBatchException('You must specify a reminderOrder between 1-3.');
			}
		}
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(ISSP_CurrencyCenterUtil.batchAirlineQuery);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope){

		String year = String.valueOf(System.now().addMonths(-1).year());
		String month = String.valueOf(System.now().addMonths(-1).month());
		List<Currency_Center_Survey__c> existingCcsList = [SELECT Id, Airline__c FROM Currency_Center_Survey__c
															WHERE Survey__c = 'Monthly' AND Status__c = 'Draft'
																AND Year_Survey__c =:year AND Month_Survey__c =:month AND Airline__c in:scope
																AND RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdMonthlySurvey];

		if(!existingCcsList.isEmpty()){
			ISSP_CurrencyCenterUtil.sendEmailsBatch(existingCcsList,'IATA Noreply',emailTemplate);
		}
	}

	global void finish(Database.BatchableContext BC){

	}

	global void execute(SchedulableContext ctx){
		CurrencyCenter_MonthlySurveyNoticeBatch b = new CurrencyCenter_MonthlySurveyNoticeBatch(noticeOrder);
		database.executeBatch(b);
	}

	private class monthlySurveyNoticeBatchException extends Exception{

	}

}