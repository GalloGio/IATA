@isTest
private class ams2gdp_Batch_Update_Test {
	
	public static Integer nb = 2;

	@testSetup static void loadData() 
	{
		//ams2gdp_TestDataGenerator testGenerator =  new ams2gdp_TestDataGenerator();
		ams2gdp_TestDataGenerator.generateReferenceTables('LOCCAT',nb, true);
		ams2gdp_TestDataGenerator.generateAccounts(nb, true);
		ams2gdp_TestDataGenerator.generateAMS_Agency_Affiliations(nb, true);
		ams2gdp_TestDataGenerator.generateAccreditationEndorsementOrganisations(nb, true);
		ams2gdp_TestDataGenerator.generateAMS_Addresses(nb, true);
		ams2gdp_TestDataGenerator.generateAMS_AgencyAirports(nb, true);
		ams2gdp_TestDataGenerator.generateAMS_AgencyProfiles(nb, true);
		ams2gdp_TestDataGenerator.generateAMS_AccountRoles(nb, true);
		ams2gdp_TestDataGenerator.generateReferenceTables(nb, true);
		ams2gdp_TestDataGenerator.generateAdjacentAirports(nb,true);
		ams2gdp_TestDataGenerator.generateGDP_Addresses(nb,true);
		ams2gdp_TestDataGenerator.generateGDP_Phones(nb,true);		
		ams2gdp_TestDataGenerator.generateAgencyOwners(nb,true);
		//ams2gdp_TestDataGenerator.generateAccreditations(nb,true);
		//ams2gdp_TestDataGenerator.generateAssocAffiliation(nb,true);
		//ams2gdp_TestDataGenerator.generateGDPProductsView(nb,true);
		ams2gdp_TestDataGenerator.generateAMS_InspectionsOneTime(nb,true);
		ams2gdp_TestDataGenerator.generateAccountsOnetime(nb, true);


	}
	

	@isTest static void test_method_1() {
		// Implement test code
		Test.startTest();
			Database.executeBatch(new ams2gdp_Batch_Update('updateGDPProductsAccountView', null));
		Test.stopTest();
	}
	@isTest static void test_method_2() {
		// Implement test code
		Database.executeBatch(new ams2gdp_Batch_Update('updateAccreditation', null));
	}
	@isTest static void test_method_3() {
		// Implement test code
		Database.executeBatch(new ams2gdp_Batch_Update('updateGDPPhone', null));
	}
	@isTest static void test_method_4() {
		// Implement test code
		Database.executeBatch(new ams2gdp_Batch_Update('updateGDPAddress', null));
	}

	@isTest static void test_method_5() {
		// Implement test code
		Database.executeBatch(new ams2gdp_Batch_Update('updateAgencyOwner', null));
	}
	@isTest static void test_method_6() {
		// Implement test code
		Database.executeBatch(new ams2gdp_Batch_Update('updateAssocAffiliationMembership', null));
	}
	@isTest static void test_method_7() {
		// Implement test code
		Database.executeBatch(new ams2gdp_Batch_Update('updateAdjacentAirport', null));		
	}
	
}