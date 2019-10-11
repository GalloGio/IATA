@isTest
private class CW_LandingSearchBarControllerTest {
    @TestSetup
	private static void setup(){
		Account acc = new Account(
            Name='Qatar Airways (Test)',
            Account_Type__c='Airline',
            Sector__c='Airline',
            Category__c='General Aviation',
            Payment_Term__c='Z001'
        );
        insert acc;
        
        Account_Role__c ar = new Account_Role__c();
        ar.Account__c = acc.Id;
        ar.Account_Role_Name__c = 'Test Account Role';
        insert ar;
        
        ICG_Account_Role_Detail__c ard = new ICG_Account_Role_Detail__c();
        ard.City__c = 'Madrid';
        ard.Country__c = 'Spain & Andorra';
        ard.Nearest_Airport__c = 'MAD';
        ard.Account_Role__c = ar.Id;
        insert ard;
        
        ICG_Certification__c cer = new ICG_Certification__c();
        cer.Name = 'Test certification';
        cer.Certification_Type__c = 'Assessments';
        insert cer;

	}

    @isTest
	private static void getLocationsListTest() {		
		
		Test.startTest();        
        String result = CW_LandingSearchBarController.getLocationsList();            
        Test.stopTest();

		//assertions
		System.assertNotEquals(0, result.length());       

	}
    
    @isTest
    private static void getCertificationsListTest() {		
		
		Test.startTest();        
        String result = CW_LandingSearchBarController.getCertificationsList();            
        Test.stopTest();

		//assertions
		System.assertNotEquals(0, result.length()); 

	}
    
    @isTest
    private static void getCompanyNamesListTest() {		
		
		Test.startTest();        
        String result = CW_LandingSearchBarController.getCompanyNamesList();            
        Test.stopTest();

		//assertions
		System.assertNotEquals(0, result.length()); 

	}
    
}