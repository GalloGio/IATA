/**
 * @description This Class aims to implement a batch that creates Monthly Survey for each Airline
 *
 *
 * @creation  2019-01-29
 * @author    José Cardoso
 */
global class CurrencyCenter_MonthlySurveyInitBatch implements Database.Batchable<sObject>, Schedulable {

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(ISSP_CurrencyCenterUtil.batchAirlineQuery);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope){

		String yearSurvey = String.valueOf(System.now().addMonths(-1).year());
		String monthSurvey = String.valueOf(System.now().addMonths(-1).month());
		Set<Id> airlinesWithSurvey = getAirlinesWithSurvey(yearSurvey, monthSurvey, scope);

		List<Currency_Center_Survey__c> ccsToInsert = new List<Currency_Center_Survey__c>();

		for(Account acc : scope){
			if(!airlinesWithSurvey.contains(acc.Id)){
				System.debug('jmc - CurrencyCenter_MonthlySurveyInitBatch.execute - Create CCS for ' + acc.Name);
				Currency_Center_Survey__c ccs = new Currency_Center_Survey__c();
				ccs.Survey__c = 'Monthly';
				ccs.Section__c = 'Survey Record';
				ccs.Airline__c = acc.Id;
				ccs.Year_Survey__c = yearSurvey;
				ccs.Month_Survey__c = monthSurvey;
				ccs.Status__c = 'Draft';
				ccs.RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlySurvey;
				ccsToInsert.add(ccs);
			}
		}

		if(!ccsToInsert.isEmpty()){
			insert ccsToInsert;
			ISSP_CurrencyCenterUtil.sendEmailsBatch(ccsToInsert,'IATA Noreply','Currency_Center_Monthly_Survey_Initial_Notification');
		}
	}

	global void finish(Database.BatchableContext BC){

	}

	global void execute(SchedulableContext ctx){
		CurrencyCenter_MonthlySurveyInitBatch b = new CurrencyCenter_MonthlySurveyInitBatch();
		Database.executeBatch(b);
	}


	private Set<Id> getAirlinesWithSurvey(String year, String month, List<Account> scope){

		Set<Id> airlinesWithSurvey = new Set<Id>();
		List<Currency_Center_Survey__c> existingCcsList = [SELECT Airline__c FROM Currency_Center_Survey__c
				WHERE Survey__c = 'Monthly' AND Year_Survey__c =:year AND Month_Survey__c =:month AND Airline__c in:scope
						AND RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdMonthlySurvey];
		System.debug('jmc - CurrencyCenter_MonthlySurveyInitBatch.getAirlinesWithSurvey existingCcsList' + existingCcsList);
		for(Currency_Center_Survey__c ccs:existingCcsList){
			airlinesWithSurvey.add(ccs.Airline__c);
		}
		System.debug('jmc - CurrencyCenter_MonthlySurveyInitBatch.getAirlinesWithSurvey airlinesWithSurvey' + airlinesWithSurvey);
		return airlinesWithSurvey;
	}

}