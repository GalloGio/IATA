/**
 * @description This Class aims to implement a batch that creates an Annual Survey for each Airline
 *
 *
 * @creation  2019-01-25
 * @author    José Cardoso
 */
global class CurrencyCenter_AnnualSurveyInitBatch implements Database.Batchable<sObject>, Schedulable{

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(ISSP_CurrencyCenterUtil.batchAirlineQuery);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope){

		String yearSurvey = String.valueOf(System.now().year()-1);
		Set<Id> airlinesWithSurvey = getAirlinesWithSurvey(yearSurvey, scope);

		List<Currency_Center_Survey__c> ccsToInsert = new List<Currency_Center_Survey__c>();

		for(Account acc : scope){
			if(!airlinesWithSurvey.contains(acc.Id)){
				System.debug('jmc - CurrencyCenter_AnnualSurveyInitBatch.execute - Create CCS for ' + acc.Name);
				Currency_Center_Survey__c ccs = new Currency_Center_Survey__c();
				ccs.Survey__c = 'Annual';
				ccs.Section__c = 'Survey Record';
				ccs.Airline__c = acc.Id;
				ccs.Year_Survey__c = yearSurvey;
				ccs.Status__c = 'Draft';
				ccs.RecordTypeId = ISSP_CurrencyCenterUtil.rtIdAnnualSurvey;
				ccsToInsert.add(ccs);
			}
		}

		if(!ccsToInsert.isEmpty()){
			insert ccsToInsert;
			ISSP_CurrencyCenterUtil.sendEmailsBatch(ccsToInsert,'IATA Noreply','Currency_Center_Annual_Survey_Initial_Notification');
		}
	}

	global void finish(Database.BatchableContext BC){

	}

	global void execute(SchedulableContext ctx){
		CurrencyCenter_AnnualSurveyInitBatch b = new CurrencyCenter_AnnualSurveyInitBatch();
		Database.executeBatch(b);
	}


	private Set<Id> getAirlinesWithSurvey(String year, List<Account> scope){

		Set<Id> airlinesWithSurvey = new Set<Id>();
		System.debug('CurrencyCenter_AnnualSurveyInitBatch.getAirlinesWithSurvey RecordTypeId: ' + ISSP_CurrencyCenterUtil.rtIdAnnualSurvey);
		List<Currency_Center_Survey__c> existingCcsList = [SELECT Airline__c FROM Currency_Center_Survey__c
															WHERE Survey__c = 'Annual' AND Year_Survey__c =:year AND Airline__c in:scope
																	AND RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdAnnualSurvey];
		System.debug('jmc - CurrencyCenter_AnnualSurveyInitBatch.getAirlinesWithSurvey existingCcsList' + existingCcsList);
		for(Currency_Center_Survey__c ccs:existingCcsList){
			airlinesWithSurvey.add(ccs.Airline__c);
		}
		System.debug('jmc - CurrencyCenter_AnnualSurveyInitBatch.getAirlinesWithSurvey airlinesWithSurvey' + airlinesWithSurvey);
		return airlinesWithSurvey;
	}
}