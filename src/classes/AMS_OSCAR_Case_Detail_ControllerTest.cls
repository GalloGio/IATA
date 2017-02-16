@isTest
private class AMS_OSCAR_Case_Detail_ControllerTest {
	
	@testSetup static void setup(){
		AMS_OSCAR_TestDataFactory.createOSCARtestData();
		AMS_OSCAR__c oscar = [SELECT Id, Account__c FROM AMS_OSCAR__c limit 1];
		Case c = [SELECT Id FROM Case WHERE Oscar__c = :oscar.Id];

		AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(
			SAAM_Case__c = c.id,
			CASS_Number__c = '123',
			Location_Class__c = 'C',
			IATA_ISO_State__c = [SELECT Id FROM IATA_ISO_State__c LIMIT 1][0].Id,
			Branch_Office_Country__c = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1][0].Id
		);
		insert accre;

		oscar.Process__c = AMS_Utils.AGENCYCHANGES;
		oscar.AMS_Online_Accreditation__c = accre.Id;
		update oscar;
	}
	
	@isTest static void test_OSCARCaseDetail() {
		Case c = [SELECT Id FROM Case WHERE Oscar__c IN (SELECT Id FROM AMS_OSCAR__c WHERE AMS_Online_Accreditation__c != '') LIMIT 1];

		PageReference pg = Page.AMS_OSCAR_GeneralDetailsPage;
		pg.getParameters().put('id', c.Id);
		Test.setCurrentPage(pg);
		
		Test.startTest();

			AMS_OSCAR_Case_Detail_Controller controller = new AMS_OSCAR_Case_Detail_Controller();
			controller.cancel();
			controller.save();

			System.assert(controller.saveAction, 'Error saving');
			System.assert(!controller.hasEditableFields, 'Found editable fields');
			System.assert(controller.getExistOscarInspections(), 'No inspections found');
		Test.stopTest();
	}
	
}