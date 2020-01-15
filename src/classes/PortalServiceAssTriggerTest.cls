@isTest
public with sharing class PortalServiceAssTriggerTest {

	public static testmethod void PortalServiceAssTriggerTest() {
		String recordTypeId = Schema.getGlobalDescribe().get('Portal_Service_Assignment__c').getDescribe().getRecordTypeInfosByName().get('Country Assignment').getRecordTypeId();
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Czech Republic';
		country.ISO_Code__c = 'CS';
		country.AIMS_Area_Name__c = 'Czech Republic';
		country.AIMS_Area_ID__c = '1';
		insert country;
		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c();
        country2.Name = 'Galactic Republic';
        country2.ISO_Code__c = 'GR';
        country2.AIMS_Area_Name__c = 'Galactic Republic';
        country2.AIMS_Area_ID__c = '2';
        insert country2;
		Portal_Applications__c app = new Portal_Applications__c(Name = 'Appo', Country_Visibility_Control__c = 'SHOW'); 
		insert app;
		Portal_Service_Assignment__c ass = new Portal_Service_Assignment__c(ANG_Portal_Service__c = app.Id, IATA_ISO_Country__c = country.Id, RecordTypeId = recordTypeId);

		test.startTest();
		insert ass;
		ass.IATA_ISO_Country__c = country2.Id;
		update ass;
		test.stopTest();

		Portal_Applications__c app1 = [SELECT Id, ANG_Country_Coverage__c FROM Portal_Applications__c LIMIT 1];

		System.assertEquals('GR', app1.ANG_Country_Coverage__c);
	}
}
