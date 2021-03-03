/*
 * @author
 * Description: CW_SearchEngine Tests
 */
 @isTest
private class CW_LandingSearchBarControllerTest {
	@TestSetup
	private static void setup() {
		List<IATA_ISO_Country__c> lstCountries = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		lstCountries.add(country);
		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c (Name = 'France', ISO_Code_Numeric__c = 24, ISO_Code__c = '20');
		lstCountries.add(country2);
		insert lstCountries;

		List<Account> lstAcc = new List<Account>();
		Account acc = new Account(
			Name='Qatar Airways (Test)',
			Account_Type__c='Airline',
			Sector__c='Airline',
			Category__c='General Aviation',
			Payment_Term__c='Z001',
			Reason_for_creation__c='New agent',
			IATA_ISO_Country__c = country2.Id
		);
		lstAcc.add(acc);
		Account acc2 = new Account(
			Name='Adolfo Suarez Barajas',
			Account_Type__c='Airline',
			Sector__c='Airline',
			Category__c='General Aviation',
			Payment_Term__c='Z001',
			Reason_for_creation__c='New agent',
			IATA_ISO_Country__c = country.Id
		);
		lstAcc.add(acc2);
		insert lstAcc;

		List<Airport_Detail__c> lstAirports = new List<Airport_Detail__c>();
		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		lstAirports.add(airport);
		Airport_Detail__c airport2 = CW_TestDataFactory.newAirport(country.Id, acc2.Id);
		airport2.City__c = 'Getafe';
		airport2.Code__c = 'GET';
		lstAirports.add(airport2);
		insert lstAirports;

		
		List<Account_Role__c> lstAR = new List<Account_Role__c>();
		Account_Role__c ar1 = CW_TestDataFactory.testAccountRole(acc.Id, 'Test Account Role');
		lstAR.add(ar1);
		Account_Role__c ar2 = CW_TestDataFactory.testAccountRole(acc2.Id, 'Test2 Account Role');
		lstAR.add(ar2);
		insert lstAR;

		List<ICG_Account_Role_Detail__c> lstARD = new List<ICG_Account_Role_Detail__c>();
				
		ICG_Account_Role_Detail__c accRoleDetail1 = CW_TestDataFactory.testICGAccountRoleDetail(ar1.Id, airport);
		lstARD.add(accRoleDetail1);

		ICG_Account_Role_Detail__c accRoleDetail2 = CW_TestDataFactory.testICGAccountRoleDetail(ar2.Id, airport);
		lstARD.add(accRoleDetail2);

		ICG_Account_Role_Detail__c accRoleDetail3 = CW_TestDataFactory.testICGAccountRoleDetail(ar1.Id, airport2);
		lstARD.add(accRoleDetail3);
		insert lstARD;
		
		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		insert cert;
	}
	/*
	* @author
	* Description: Get locations list
	*/
	@isTest
	private static void getLocationsListTest() {		
		
		Test.startTest();        
		String result = CW_LandingSearchBarController.getLocationsList();            
		Test.stopTest();

		//assertions
		System.assertNotEquals(0, result.length());       

	}
	/*
	* @author
	* Description: Get Certifications list
	*/
	@isTest
	private static void getCertificationsListTest() {		
		
		Test.startTest();        
		String result = CW_LandingSearchBarController.getCertificationsList();            
		Test.stopTest();

		//assertions
		System.assertNotEquals(0, result.length()); 

	}
	/*
	* @author
	* Description: Get Company Names list
	*/
	@isTest
	private static void getCompanyNamesListTest() {		
		
		Test.startTest();        
		String result = CW_LandingSearchBarController.getCompanyNamesList(true);            
		Test.stopTest();

		//assertions
		System.assertNotEquals(0, result.length()); 

	}
	
}