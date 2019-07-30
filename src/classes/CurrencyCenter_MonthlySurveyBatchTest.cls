/**
 * @description This is a test class for classes CurrencyCenter_MonthlySurveyInitBatch and CurrencyCenter_MonthlySurveyNoticeBatch
 *
 *
 * @creation  2019-01-30
 * @author    José Cardoso
 */
@isTest
private class CurrencyCenter_MonthlySurveyBatchTest {


	// Test CurrencyCenter_MonthlySurveyInitBatch
	@isTest static void testBatchInit(){
		Test.startTest();

		Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
				RecordTypeId = AirlineHQ_RT_Id, Membership_status__c = 'Non-IATA member');
		insert acct_hq;

		Account acct_hq2 = new Account(Name = 'Owner Airways', Airline_designator__c = 'OR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
				RecordTypeId = AirlineHQ_RT_Id, Membership_status__c = 'Non-IATA member');
		insert acct_hq2;

		Contact airlineContact = new Contact();
		airlineContact.FirstName = 'John';
		airlineContact.LastName = 'Doe';
		airlineContact.AccountId = acct_hq.Id;
		airlineContact.Email = 'john.doe@airline.com';
		insert airlineContact;

		Portal_Applications__c papp = new Portal_Applications__c();
		papp.Application_URL__c = '/ISSP_CurrencyCenterHome';
		insert papp;

		Portal_Application_Right__c par = new Portal_Application_Right__c();
		par.Contact__c = airlineContact.Id;
		par.Right__c = 'Access Granted';
		par.Portal_Application__c = papp.Id;
		insert par;

		String year = String.valueOf(System.now().addMonths(-1).year());
		String month =String.valueOf(System.now().addMonths(-1).month());

		Currency_Center_Survey__c ccs = new Currency_Center_Survey__c();
		ccs.Survey__c = 'Monthly';
		ccs.Section__c = 'Survey Record';
		ccs.Airline__c = acct_hq.Id;
		ccs.Year_Survey__c = year;
		ccs.Month_Survey__c = month;
		ccs.Status__c = 'Draft';
		ccs.RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlySurvey;
		insert ccs;

		List<Currency_Center_Survey__c> existingCcsList = [SELECT Airline__c FROM Currency_Center_Survey__c
															WHERE Survey__c = 'Monthly' AND Year_Survey__c =:year AND Month_Survey__c =:month
																AND RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdMonthlySurvey];
		System.assertEquals(1,existingCcsList.size());

		CurrencyCenter_MonthlySurveyInitBatch b = new CurrencyCenter_MonthlySurveyInitBatch();
		database.executeBatch(b);

		Test.stopTest();

		existingCcsList = [SELECT Airline__c FROM Currency_Center_Survey__c
							WHERE Survey__c = 'Monthly' AND Year_Survey__c =:year AND Month_Survey__c =:month
								AND RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdMonthlySurvey];
		System.assertEquals(2,existingCcsList.size());
	}

	// Test CurrencyCenter_MonthlySurveyInitBatch is Schedulable
	@isTest static void testSchedulableInit(){

		String CRON_EXP = '0 0 0 31 1 ? *';

		Test.startTest();
		String jobId = System.schedule('CurrencyCenter_MonthlySurveyInitBatchTest',  CRON_EXP, new CurrencyCenter_MonthlySurveyInitBatch());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}

	// Test CurrencyCenter_MonthlySurveyNoticeBatch
	@isTest static void testBatchNotice(){
		Test.startTest();

		Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
				RecordTypeId = AirlineHQ_RT_Id, Membership_status__c = 'Non-IATA member');
		insert acct_hq;

		Contact airlineContact = new Contact();
		airlineContact.FirstName = 'John';
		airlineContact.LastName = 'Doe';
		airlineContact.AccountId = acct_hq.Id;
		airlineContact.Email = 'john.doe@airline.com';
		insert airlineContact;

		Portal_Applications__c papp = new Portal_Applications__c();
		papp.Application_URL__c = '/ISSP_CurrencyCenterHome';
		insert papp;

		Portal_Application_Right__c par = new Portal_Application_Right__c();
		par.Contact__c = airlineContact.Id;
		par.Right__c = 'Access Granted';
		par.Portal_Application__c = papp.Id;
		insert par;

		Currency_Center_Survey__c ccs = new Currency_Center_Survey__c();
		ccs.Survey__c = 'Monthly';
		ccs.Section__c = 'Survey Record';
		ccs.Airline__c = acct_hq.Id;
		ccs.Year_Survey__c = String.valueOf(System.now().addMonths(-1).year());
		ccs.Month_Survey__c = String.valueOf(System.now().addMonths(-1).month());
		ccs.Status__c = 'Draft';
		ccs.RecordTypeId = ISSP_CurrencyCenterUtil.rtIdMonthlySurvey;
		insert ccs;

		CurrencyCenter_MonthlySurveyNoticeBatch b = new CurrencyCenter_MonthlySurveyNoticeBatch(2);
		database.executeBatch(b);

		Test.stopTest();
	}

	// Test CurrencyCenter_MonthlySurveyNoticeBatch is Schedulable
	@isTest static void testSchedulableNotice(){

		String CRON_EXP = '0 0 0 31 1 ? *';

		Test.startTest();
			String jobId = System.schedule('CurrencyCenter_MonthlySurveyNoticeBatchTest',  CRON_EXP, new CurrencyCenter_MonthlySurveyNoticeBatch(1));
			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
			System.assertEquals(CRON_EXP, ct.CronExpression);
			System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}
}