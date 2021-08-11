@isTest
public with sharing class PortalServiceAssTriggerTest {

	public static testmethod void PortalServiceAssTriggerTest() {
		String recordTypeId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Portal_Service_Assignment__c', 'Country_Assignment');

		List<IATA_ISO_Country__c> countryList = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(2);
		IATA_ISO_Country__c country = countryList.get(0);
		country.Name = 'Czech Republic';
		country.ISO_Code__c = 'CS';
		country.AIMS_Area_Name__c = 'Czech Republic';
		country.AIMS_Area_ID__c = '1';
		IATA_ISO_Country__c country2 = countryList.get(1);
		country2.Name = 'Galactic Republic';
		country2.ISO_Code__c = 'GR';
		country2.AIMS_Area_Name__c = 'Galactic Republic';
		country2.AIMS_Area_ID__c = '2';
		insert countryList;
		Portal_Applications__c app = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		app.Name = 'Appo';
		app.Country_Visibility_Control__c = 'SHOW';
		insert app;
		Portal_Service_Assignment__c portalServiceAssignment = new Portal_Service_Assignment__c(Portal_Service__c = app.Id, IATA_ISO_Country__c = country.Id, RecordTypeId = recordTypeId);

		test.startTest();
		insert portalServiceAssignment;
		portalServiceAssignment.IATA_ISO_Country__c = country2.Id;
		update portalServiceAssignment;
		test.stopTest();

		Portal_Applications__c app1 = [SELECT Id, ANG_Country_Coverage__c FROM Portal_Applications__c LIMIT 1];
		System.assertEquals('GR', app1.ANG_Country_Coverage__c);
	}
}