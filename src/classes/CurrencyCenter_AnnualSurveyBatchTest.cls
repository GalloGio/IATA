/**
 * @description This is a test class for classes CurrencyCenter_AnnualSurveyInitBatch and CurrencyCenter_AnnualSurveyNoticeBatch
 *
 *
 * @creation  2019-01-30
 * @author    José Cardoso
 */
@isTest
private  class CurrencyCenter_AnnualSurveyBatchTest {

	// Test CurrencyCenter_AnnualSurveyInitBatch
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

		String year = String.valueOf(System.now().year()-1);

		Currency_Center_Survey__c ccs = new Currency_Center_Survey__c();
		ccs.Survey__c = 'Annual';
		ccs.Section__c = 'Survey Record';
		ccs.Airline__c = acct_hq.Id;
		ccs.Year_Survey__c = year;
		ccs.Status__c = 'Draft';
		ccs.RecordTypeId = ISSP_CurrencyCenterUtil.rtIdAnnualSurvey;
		insert ccs;

		List<Currency_Center_Survey__c> existingCcsList = [SELECT Airline__c FROM Currency_Center_Survey__c
															WHERE Survey__c = 'Annual' AND Year_Survey__c =:year
																AND RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdAnnualSurvey];
		System.assertEquals(1,existingCcsList.size());

		CurrencyCenter_AnnualSurveyInitBatch b = new CurrencyCenter_AnnualSurveyInitBatch();
		database.executeBatch(b);

		Test.stopTest();

		existingCcsList = [SELECT Airline__c FROM Currency_Center_Survey__c
							WHERE Survey__c = 'Annual' AND Year_Survey__c =:year
								AND RecordTypeId=:ISSP_CurrencyCenterUtil.rtIdAnnualSurvey];
		System.assertEquals(2,existingCcsList.size());
	}

	// Test CurrencyCenter_AnnualSurveyInitBatch is Schedulable
	@isTest static void testSchedulableInit(){

		String CRON_EXP = '0 0 0 31 1 ? *';

		Test.startTest();
		String jobId = System.schedule('CurrencyCenter_AnnualSurveyInitBatchTest',  CRON_EXP, new CurrencyCenter_AnnualSurveyInitBatch());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}

	// Test CurrencyCenter_AnnualSurveyNoticeBatch
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
		ccs.Survey__c = 'Annual';
		ccs.Section__c = 'Survey Record';
		ccs.Airline__c = acct_hq.Id;
		ccs.Year_Survey__c = String.valueOf(System.now().year()-1);
		ccs.Status__c = 'Draft';
		ccs.RecordTypeId = ISSP_CurrencyCenterUtil.rtIdAnnualSurvey;
		insert ccs;

		CurrencyCenter_AnnualSurveyNoticeBatch b = new CurrencyCenter_AnnualSurveyNoticeBatch(3);
		database.executeBatch(b);

		Test.stopTest();
	}

	// Test CurrencyCenter_AnnualSurveyNoticeBatch is Schedulable
	@isTest static void testSchedulableNotice(){

		String CRON_EXP = '0 0 0 31 1 ? *';

		Test.startTest();
		String jobId = System.schedule('CurrencyCenter_AnnualSurveyNoticeBatchTest',  CRON_EXP, new CurrencyCenter_AnnualSurveyNoticeBatch(1));
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}
}