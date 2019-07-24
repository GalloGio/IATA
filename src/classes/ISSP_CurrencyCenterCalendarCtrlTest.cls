/**
 * @description This is a test class for class ISSP_CurrencyCenterCalendarController
 *
 *
 * @creation  2019-02-07
 * @author    José Cardoso
 */
@isTest
private class ISSP_CurrencyCenterCalendarCtrlTest {

	@isTest
	static void test01(){

		//ISO Country
		IATA_ISO_Country__c isoC = new IATA_ISO_Country__c();
		isoC.name = 'Portugal';
		isoC.ISO_Code__c = 'PT';
		isoC.Case_BSP_Country__c = 'Portugal';
		isoC.Region__c = 'Europe';
		isoC.LVA_CountryLanguage__c = 'pt';
		insert isoC;
		System.debug('ISSP_CurrencyCenterCalendarCtrlTest IATA_ISO_Country__c: ' + isoC);

		//Country Profile
		Country_Profile__c cp = new Country_Profile__c(Name=isoC.Name, IATA_ISO_Country__c = isoC.Id);
		insert cp;
		System.debug('ISSP_CurrencyCenterCalendarCtrlTest Country_Profile__c: ' + cp);

		Id rtIdHq = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

		Account headQuarter = ISSP_ObjectFactory.createNewAccount();
		headQuarter.BillingCity = 'test2';
		headQuarter.Name = 'test2';
		headQuarter.RecordTypeId = rtIdHq;
		headQuarter.Site = 'headSite';
		headQuarter.IATA_ISO_Country__r = isoC;
		insert headQuarter;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.Email = 'testxxaasddasdasda@test.com';
		con.AccountId= headQuarter.Id;
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalUser(con);

		System.runAs(newUser){

			// Event
			Event ev = new Event(Subject ='Test event',StartDateTime =System.now(),EndDateTime =System.now().addHours(4),WhatId = cp.Id);
			insert ev;
			System.debug('ISSP_CurrencyCenterCalendarCtrlTest Event: ' + ev);

			ISSP_CurrencyCenterCalendarController ctrl = new ISSP_CurrencyCenterCalendarController();

			System.debug('ISSP_CurrencyCenterCalendarCtrlTest ctrl.user: ' + ctrl.user);
			System.debug('ISSP_CurrencyCenterCalendarCtrlTest ctrl.contact: ' + ctrl.contact);
			System.debug('ISSP_CurrencyCenterCalendarCtrlTest ctrl.account: ' + ctrl.account);
			System.debug('ISSP_CurrencyCenterCalendarCtrlTest ctrl.account.IATA_ISO_Country__c: ' + ctrl.account.IATA_ISO_Country__c);

			String getListEventsJSON = ctrl.getListEventsJSON();
			String getListEventsJSONGrouped = ctrl.getListEventsJSONGrouped();
		}
	}
}