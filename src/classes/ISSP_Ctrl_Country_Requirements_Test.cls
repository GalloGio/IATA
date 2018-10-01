@isTest
private class ISSP_Ctrl_Country_Requirements_Test {

	static list<IATA_ISO_Country__c> listCountries;

	public static list<IATA_ISO_Country__c> populateCountries() {
		if(listCountries == null) {
			listCountries = new list<IATA_ISO_Country__c>();
			listCountries.add( new IATA_ISO_Country__c( Name = 'Switzerland', ISO_Code__c = 'CH', ANG_Enable_NewGen__c = true));
			listCountries.add( new IATA_ISO_Country__c( Name = 'Canada', ISO_Code__c = 'CA'));
			listCountries.add( new IATA_ISO_Country__c( Name = 'Portugal', ISO_Code__c = 'PT',ANG_Enable_NewGen__c = true));
			insert listCountries;
		}
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
		listRequirements.add( new AP_Country_Requierment__c(
			Name = 'Req3',
			Country__c = listCountries.get(2).Id,
			Line_of_business__c = 'XPTO')
		);		
		insert listRequirements;

		list<AMS_Accreditation_Country_CheckList__c> ll = new List<AMS_Accreditation_Country_CheckList__c>();
		AMS_Accreditation_Country_CheckList__c cc = new AMS_Accreditation_Country_CheckList__c(
				IATA_ISO_Country__c = listCountries.get(2).id,
				Operation__c = 'Airline'
			);

		AMS_Accreditation_Country_CheckList__c cc2 = new AMS_Accreditation_Country_CheckList__c(
				IATA_ISO_Country__c = listCountries.get(2).id,
				Operation__c = 'Travel Agent'
			);

		AMS_Accreditation_Country_CheckList__c cc3 = new AMS_Accreditation_Country_CheckList__c(
				IATA_ISO_Country__c = listCountries.get(0).id,
				Operation__c = 'Travel Agent'
			);

		ll.add(cc);
		ll.add(cc2);
		ll.add(cc3);

		insert ll;

		List<AMS_Accreditation_Requirement__c> lst = new List<AMS_Accreditation_Requirement__c>();

		lst.add(new AMS_Accreditation_Requirement__c(
				AMS_Accreditation_Country_CheckList__c = cc.id,
				Name = 'Name1',
				Requirement_text__c = 'Text1',
				Location_type__c = 'HO',
				ANG_Accreditation_Model__c = 'Legacy',
				Language__c = 'en_AU'
			));
		lst.add(new AMS_Accreditation_Requirement__c(
				AMS_Accreditation_Country_CheckList__c = cc.id,
				Name = 'Name2',
				Requirement_text__c = 'Text2',
				Location_type__c = 'HO',
				ANG_Accreditation_Model__c = 'Cash',
				Language__c = 'pt_PT'
			));		
		lst.add(new AMS_Accreditation_Requirement__c(
				AMS_Accreditation_Country_CheckList__c = cc.id,
				Name = 'Name3',
				Requirement_text__c = 'Text3',
				Location_type__c = 'HO',
				ANG_Accreditation_Model__c = 'Cashless',
				Language__c = 'de'
			));
		lst.add(new AMS_Accreditation_Requirement__c(
				AMS_Accreditation_Country_CheckList__c = cc2.id,
				Name = 'Name3',
				Requirement_text__c = 'Text3',
				Location_type__c = 'HO',
				ANG_Accreditation_Model__c = 'Legacy',
				Language__c = 'de'
			));		
		lst.add(new AMS_Accreditation_Requirement__c(
				AMS_Accreditation_Country_CheckList__c = cc3.id,
				Name = 'Name3',
				Requirement_text__c = 'Text3',
				Location_type__c = 'HO',
				ANG_Accreditation_Model__c = 'Legacy',
				Language__c = 'de'
			));		

		insert lst;

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
		System.assertEquals(listResult.size(),4);
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
    	list<IATA_ISO_Country__c> listCountries =  populateCountries();

    	populateRequirements();

        User testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();

        Account acc = [Select Sector__c from Account limit 1];
        acc.Sector__c = 'Airline';
        acc.IATACode__c = '1234567890';
        acc.IATA_ISO_Country__c = listCountries.get(2).id;
        update acc;

        PageReference result;
        Test.startTest();

        System.runAs(testUser) {
            ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
            result = controller.checkAccess();
            controller.getNewLayout();
            controller.getCountryRequirementsList();
            controller.getAccreditationTypes();
            controller.refreshRequirementsList();
        }	

        Test.stopTest();

        System.assert(result==null);
    }

    @isTest static void test_checkAccess_True_2() {
    	list<IATA_ISO_Country__c> listCountries =  populateCountries();

        Account topParent = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = listCountries.get(2).id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
                Location_type__c = 'HE',
				Location_Class__c = 'P'
            );

        insert topParent;

        Account a = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = listCountries.get(2).id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
                Location_type__c = 'HE',
                status__c = 'Approved',
                Top_Parent__c = topParent.id,
				Location_Class__c = 'P'
            );

        insert a;

    	populateRequirements();

        User testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();
        
        PageReference result;
        Test.startTest();

        System.runAs(testUser) {
            ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();

            controller.getLanguagesMap();
            controller.getCountryRequirementsList();
        }	

        Test.stopTest();

        System.assert(result==null);
    } 

    @isTest static void test_getCountryRequirementsList() {
    	list<IATA_ISO_Country__c> listCountries =  populateCountries();

    	populateRequirements();

        User testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();

        Account acc = [Select Sector__c from Account limit 1];
        acc.Sector__c = 'Travel Agent';
        acc.IATACode__c = '1234567890';
        acc.Location_type__c = 'HO';
        acc.IATA_ISO_Country__c = listCountries.get(2).id;
        update acc;

        PageReference result;
        Test.startTest();

        System.runAs(testUser) {
            ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
            result = controller.checkAccess();
            controller.getNewLayout();
            controller.getCountryRequirementsList();
            controller.getAccreditationTypes();
            controller.refreshRequirementsList();
        }	

        Test.stopTest();
    }

    @isTest static void test_getCountryRequirementsList2() {
    	list<IATA_ISO_Country__c> listCountries =  populateCountries();

    	populateRequirements();

        User testUser = ISSP_Ctrl_AccountStatements_AcceptTest.createPortalUser();

        Account acc = [Select Sector__c from Account limit 1];
        acc.recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        acc.Sector__c = 'Travel Agent';
        acc.IATACode__c = '1234567890';
        acc.Location_type__c = 'HO';
        acc.Status__c = 'Approved';
        acc.Category__c = AMS_UTILS.CATEGORY_PASSENGER_SALES_AGENT;
        acc.IATA_ISO_Country__c = listCountries.get(0).id;
        update acc;

        PageReference result;
        Test.startTest();

        System.runAs(testUser) {
            ISSP_Ctrl_Country_Requirements controller = new ISSP_Ctrl_Country_Requirements();
            result = controller.checkAccess();
            controller.getNewLayout();
            controller.getCountryRequirementsList();
            controller.getAccreditationTypes();
            controller.refreshRequirementsList();
        }	

        Test.stopTest();
    }
}