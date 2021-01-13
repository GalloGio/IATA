global with sharing class CurrencyCenter_CountryManagerReminder implements Database.Batchable<sObject>, Schedulable{

	private static final String TEMPLATE_NAME = 'Currency_Center_Country_Manager_Reminder';
	private static final String OWA_NAME = 'IATA Noreply';

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, Country_Name__r.Country_Manager__c '
			+ ' FROM Country_Profile__c'
			+ ' WHERE Listed_In__c IN (\'Blocked Funds\',\'Watch List\')'
			+ ' AND Country_Name__r.Country_Manager__c != null AND Country_Name__r.Country_Manager__r.IsActive = true';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Country_Profile__c> scope){
		sendEmails(scope);
	}

	global void finish(Database.BatchableContext BC){
	}

	global void execute(SchedulableContext ctx){
		Database.executeBatch(this);
	}

	public void sendEmails(List<Country_Profile__c> listCountryProfile) {
		EmailTemplate template = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = :TEMPLATE_NAME LIMIT 1];
		OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :OWA_NAME LIMIT 1];
		Integer numUsers = [
			SELECT count()
			FROM Portal_Application_Right__c
			WHERE Right__c = 'Access Granted'
			AND Application_Start_URL__c = '/ISSP_CurrencyCenterHome'];

		System.debug('CurrencyCenter_CountryManagerReminder.sendEmails template: ' + template);
		System.debug('CurrencyCenter_CountryManagerReminder.sendEmails org wide email address: ' + owa);
		System.debug('CurrencyCenter_CountryManagerReminder.sendEmails: found ' + listCountryProfile.size() + ' country profiles');
		System.debug('CurrencyCenter_CountryManagerReminder.sendEmails numUsers: ' + numUsers);

		if(template==null || owa==null) return;

		list<Messaging.Email> listEmails = new list<Messaging.Email>();
		for(Country_Profile__c countryProfile: listCountryProfile) {
			Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.Id, countryProfile.Country_Name__r.Country_Manager__c, countryProfile.Id);
			String emailSubject = email.getSubject();
			String emailTextBody = email.getPlainTextBody();
			emailTextBody = emailTextBody.replace('[Number of users]',String.valueOf(numUsers));
			String emailHtmlBody = email.getHTMLBody();
			emailHtmlBody = emailHtmlBody.replace('[Number of users]',String.valueOf(numUsers));
			email.setOrgWideEmailAddressId(owa.Id);
			email.setTargetObjectId(countryProfile.Country_Name__r.Country_Manager__c);
			email.setSubject(emailSubject);
			email.setPlainTextBody(emailTextBody);
			email.setHTMLBody(emailHtmlBody);
			email.setSaveAsActivity(false);
			listEmails.add(email);

			System.debug('CurrencyCenter_CountryManagerReminder.sendEmails countryProfile: ' + countryProfile);
			System.debug('CurrencyCenter_CountryManagerReminder.sendEmails email: ' + email);
		}

		if(!listEmails.isEmpty()){
			try {
				List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(listEmails);
				for(Messaging.SendEmailResult ser: sendEmailResults){
					if(!ser.isSuccess()){
						System.debug('CurrencyCenter_CountryManagerReminder.sendEmails errorMessage: ' + ser.getErrors()[0].getMessage() + ' - TargetObjectId:' + ser.getErrors()[0].getTargetObjectId());
					}
				}
			} catch (Exception ex){
				System.debug('CurrencyCenter_CountryManagerReminder.sendEmails error: ' + ex.getMessage());
			}
		}
	}
}
