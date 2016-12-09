@isTest
private class ISSP_Ctrl_Country_Requirements_Test {

	public static list<IATA_ISO_Country__c> populateCountries() {
		list<IATA_ISO_Country__c> listCountries = new list<IATA_ISO_Country__c>();
		listCountries.add( new IATA_ISO_Country__c( Name = 'Switzerland', ISO_Code__c = 'CH'));
		listCountries.add( new IATA_ISO_Country__c( Name = 'Canada', ISO_Code__c = 'CA'));
		insert listCountries;
		return listCountries;
	}

	public static void populateRequirements() {
		list<IATA_ISO_Country__c> listCountries =  populateCountries();

		list<AP_Country_Requierment__c> listRequirements = new list<AP_Country_Requierment__c>();
		listRequirements.add( new AP_Country_Requierment__c(
			Name = 'Req1',
			Country__c = listCountries.get(0).Id,
			Line_of_business__c = 'BSP')
		);
		listRequirements.add( new AP_Country_Requierment__c(
			Name = 'Req2',
			Country__c = listCountries.get(1).Id,
			Line_of_business__c = 'CASS')
		);
		insert listRequirements;
	}

	@isTest static void test_Controller() {

		Test.startTest();
		ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
		Test.stopTest();

		System.assertEquals(controller.countryRequirement,null);
	}

	@isTest static void test_GetCountries() {
		populateCountries();
		ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();

		Test.startTest();
		List<SelectOption> listResult = controller.getCountries();
		Test.stopTest();

		// 2 elements + null value
		System.assertEquals(listResult.size(),3);
	}

	@isTest static void test_GetParticipationTypes() {
		ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();

		Test.startTest();
		List<SelectOption> listResult = controller.getParticipationTypes();
		Test.stopTest();

		// 2 elements + null value
		System.assertEquals(listResult.size(),3);
	}

	// with type filter, 1 results
	@isTest static void test_ControllerWithTypeFilter() {
		populateRequirements();

		Test.startTest();
		ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
		controller.typeFilter = 'CASS';
		controller.runSearch();
		Test.stopTest();

        System.assert(controller.countryRequirement==null);
	}

	// with country filter, 1 results
	@isTest static void test_ControllerWithCountryFilter() {
		populateRequirements();

		Test.startTest();
		ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
		controller.countryFilter = [Select Id from IATA_ISO_Country__c where Name = 'Canada'].id;
        controller.typeFilter = 'CASS';
		controller.runSearch();
		Test.stopTest();

        System.assert(controller.countryRequirement!=null);
	}

	// with string filter, 1 results
	@isTest static void test_ControllerWithStringFilter() {
		populateRequirements();

		Test.startTest();
		ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
		controller.searchFilter = 'Req1';
		controller.runSearch();
		Test.stopTest();

        System.assert(controller.countryRequirement==null);
	}

    private static User createPortalUser() {
         Account account = ISSP_ObjectFactory.createNewAccount();
         insert account;

         Contact con = ISSP_ObjectFactory.createNewContact();
         con.AccountId= account.Id;
         con.Email = 'Test@test11.com';
         insert con;

         User newUser = ISSP_ObjectFactory.createPortalUser(con);
         System.debug('newUser Id: ' + newUser.Id);
         con.OwnerId = newUser.Id;
         update con;

         newUser = [Select Id, ContactId from User where Id = :newUser.Id];
         return newUser;
     }

    @isTest static void test_checkAccess_False() {
        User testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();

        PageReference result;
        Test.startTest();
        System.runAs(testUser) {
            ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
            result = controller.checkAccess();
        }
        Test.stopTest();

        System.assert(result!=null);
    }

    @isTest static void test_checkAccess_True() {
        User testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();
        Account acc = [Select Sector__c from Account limit 1];
        acc.Sector__c = 'Airline';
        update acc;

        PageReference result;
        Test.startTest();
        System.runAs(testUser) {
            ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
            result = controller.checkAccess();
        }
        Test.stopTest();

        System.assert(result==null);
    }
}