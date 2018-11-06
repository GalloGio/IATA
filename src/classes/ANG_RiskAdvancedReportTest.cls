@isTest
private class ANG_RiskAdvancedReportTest {
	
	@testSetup static void setup() {

		IATA_ISO_Country__c ISOCountry = new IATA_ISO_Country__c(name = 'FR', 
			ISO_Code__c = 'FR', 
			BSP_Country_free_text__c = 'FR',
			ISO_Code_Numeric__c = 123,
			Region__c = 'Europe');
		insert ISOCountry;

		Account parent = new Account(Name = 'Parent Account', 
			IATA_ISO_Country__c = ISOCountry.id, 
			Location_Type__c = 'HE',
			Location_Class__c = 'P', 
			Sector__c = 'Cargo Agent',
			Category__c = 'Airport',
			Remittance_frequency__c = 'Weekly');
		insert parent;

		Account chield = new Account(Name = 'Chield Account', 
			top_parent__c = parent.id,
			IATA_ISO_Country__c = ISOCountry.id, 
			Location_Type__c = 'AE',
			Location_Class__c = 'P', 
			Sector__c = 'Cargo Agent',
			Category__c = 'Airport',
			Remittance_frequency__c = 'Weekly');
		insert chield;

		Contact con = new Contact(LastName = 'ttt', Accountid = parent.id);
		insert con;

		AMS_Settlement_System__c iss = new AMS_Settlement_System__c(Name = 'BSP-FR');
		insert iss;

		operational_Calendar__c op = new operational_Calendar__c( ISS_Operation__c = iss.id, 
			First_Day__c = Date.today(), 
			Last_Day__c = Date.today(), 
			Frequency_code__c = 'W', 
			Remittance_Day__c = Date.today() );
		insert op;

		ANG_Risk_Alert__c ra = new ANG_Risk_Alert__c(ANG_Account__c = chield.id,
			ANG_Severity__c = 'Red',
			Recordtypeid = Schema.ANG_Risk_Alert__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Risk Alert RTS').getRecordTypeId() );
		insert ra;
	}

	@isTest static void test_method_one() {
		// Implement test code
		ANG_RiskAdvancedReport controller = new ANG_RiskAdvancedReport();
		controller.getselectOptionTimeFrame();
		controller.getSelectOptionRegion();
		controller.runReport();
		//System.assertEquals (controller.lsWrapperResult.size(),1);

	}
}