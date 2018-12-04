@isTest
private class ISSP_Financial_Institutions_Test {
	
	@testSetup
	static void setup() {
		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (Name = 'Portugal', 
																ISO_Code__c = 'PT',
																ANG_Enable_NewGen__c = true,
																ANG_GDI_Enabled__c = true);

		IATA_ISO_Country__c spain = new IATA_ISO_Country__c (Name = 'Spain', 
															 ISO_Code__c = 'ES',
															 ANG_Enable_NewGen__c = true,
															 ANG_GDI_Enabled__c = false);

		countries.add(portugal);
		countries.add(spain);
		insert countries;

		List<Account> agencies = new List<Account>();

		Account travelAgencyPortugal = new Account(Name = 'Travel Agency Portugal',
		        						   		   Status__c = AMS_Utils.ACC_S9_APPROVED,
		        						   		   Location_Type__c = 'HE',
	        							   		   RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
	        							   		   IATA_ISO_Country__c = portugal.Id,
	        							   		   Location_Class__c = 'P',
	        							   		   Category__c = 'IATA Passenger Sales Agent');

		Account travelAgencySpain = new Account(Name = 'Travel Agency Spain',
		        						   		Status__c = AMS_Utils.ACC_S9_APPROVED,
		        						   		Location_Type__c = 'HE',
	        							   		RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
	        							   		IATA_ISO_Country__c = spain.Id,
	        							   		Location_Class__c = 'P',
	        							   		Category__c = 'IATA Passenger Sales Agent');

		agencies.add(travelAgencyPortugal);
		agencies.add(travelAgencySpain);
		insert agencies;

		List<Contact> contacts = new List<Contact>();

		Contact portuguese = ISSP_ObjectFactory.createNewContact();
        portuguese.AccountId = travelAgencyPortugal.Id;
        portuguese.Email = 'pt@pt.com';

        Contact spanish = ISSP_ObjectFactory.createNewContact();
        spanish.AccountId = travelAgencySpain.Id;
        spanish.Email = 'es@es.com';

        contacts.add(portuguese);
        contacts.add(spanish);
        insert contacts;

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Agency Delegated Admin User'];

        List<User> users = new List<User>();

        User ptUser = new User (Alias = 'ptptpt', 
            					Email='pt@pt.com', 
				                EmailEncodingKey='UTF-8', 
				                LastName='ptptpt', 
				                LanguageLocaleKey='en_US', 
				                ContactId = portuguese.id,            
				                LocaleSidKey='en_US',
				                ProfileId = p.Id, 
				                TimeZoneSidKey='America/Los_Angeles', 
				                UserName='pt@pt.com',
				                Mgmt_Report_Team__c = true);

        User esUser = new User (Alias = 'eseses', 
            					Email='es@es.com', 
				                EmailEncodingKey='UTF-8', 
				                LastName='eseses', 
				                LanguageLocaleKey='en_US', 
				                ContactId = spanish.id,            
				                LocaleSidKey='en_US',
				                ProfileId = p.Id, 
				                TimeZoneSidKey='America/Los_Angeles', 
				                UserName='es@es.com',
				                Mgmt_Report_Team__c = true);

        users.add(ptUser);
        users.add(esUser);
        insert users;

        portuguese.OwnerId = ptUser.Id;
        update portuguese;

        spanish.OwnerId = esUser.Id;
        update spanish;

        Portal_Applications__c portalApp = new Portal_Applications__c(Name = ISSP_Financial_Institutions.GDI_PORTAL_SERVICE,
        															  ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                													  ANG_Accredited_Agents_Only__c = false,
                													  Agency__c = true);
        insert portalApp;

        List<Financial_Institution__c> financialInstitutions = new List<Financial_Institution__c>();

        Financial_Institution__c exampleOne = new Financial_Institution__c(Name = 'One',
        																   Institution_Status__c = 'Active',
        																   Financial_Security_Country_Coverage__c = 'PT',
        																   Country__c = 'Portugal',
        																   Region__c = 'Europe');

        Financial_Institution__c exampleGDI = new Financial_Institution__c(Name = 'GDI - Euler Hermes',
        																   Institution_Status__c = 'Active',
        																   Financial_Security_Country_Coverage__c = 'PT',
        																   Country__c = 'Portugal',
        																   Region__c = 'Europe');

        financialInstitutions.add(exampleOne);
        financialInstitutions.add(exampleGDI);
        insert financialInstitutions;

        Connected_App_Roles__c gdiCar = new Connected_App_Roles__c(Name = ISSP_Financial_Institutions.GDI_PORTAL_SERVICE,
																   Connected_App__c = ISSP_Financial_Institutions.GDI_PORTAL_SERVICE,
																   Permission_set_SSO__c = 'GDI_SSO',
																   Min_Users_With_Role__c = 0);
        insert gdiCar;
	}

	@isTest static void noFinancialInstitutionsListedTest() {
		User esUser = [SELECT Id FROM User WHERE Email = 'es@es.com'];

		Test.startTest();

        System.runAs(esUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(0, controller.financialInstitutionList.size());
        	System.assertEquals(false, controller.financialInstitutionsFound);
        }

        Test.stopTest();
	}

	@isTest static void noGDIFinancialInstitutionsListedTest() {
		User ptUser = [SELECT Id FROM User WHERE Email = 'pt@pt.com'];
		
		IATA_ISO_Country__c pt = [SELECT Id FROM IATA_ISO_Country__c WHERE Name = 'Portugal'];
		pt.ANG_GDI_Enabled__c = false;
		update pt;

		Test.startTest();

        System.runAs(ptUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(1, controller.financialInstitutionList.size());
        	System.assertEquals(true, controller.financialInstitutionsFound);
        }

        Test.stopTest();
	}

	@isTest static void financialInstitutionsListedTest() {
		User ptUser = [SELECT Id FROM User WHERE Email = 'pt@pt.com'];

		Test.startTest();

        System.runAs(ptUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(2, controller.financialInstitutionList.size());
        	System.assertEquals(true, controller.financialInstitutionsFound);
        }

        Test.stopTest();
	}

	@isTest static void requestGDIAccessWithSuccessTest() {
		User ptUser = [SELECT Id FROM User WHERE Email = 'pt@pt.com'];

		Test.startTest();

        System.runAs(ptUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(2, controller.financialInstitutionList.size());
        	System.assertEquals(true, controller.financialInstitutionsFound);

        	List<SelectOption> paginationSizeOptions = controller.paginationSizeOptions;

        	controller.next();
        	controller.previous();
        	controller.last();
        	controller.first();
        	controller.refreshPageSize();
        	Boolean hasPrevious = controller.hasPrevious;
        	Boolean hasNext = controller.hasNext;

        	controller.termsAndConditions = true;
        	controller.startGDIPortalAppRightCreation();
        	controller.createPortalAppRight();

        	controller.pollingStatus();

        	PermissionSet gdiSSOPermSet = [SELECT Id FROM PermissionSet WHERE Name = :controller.gdiPermSetSSO];
			insert new PermissionSetAssignment(AssigneeId = ptUser.Id, PermissionSetId = gdiSSOPermSet.Id);

			controller.pollingStatus();
        }

        Test.stopTest();
	}

	@isTest static void requestGDIAccessWithFailureTest() {
		User ptUser = [SELECT Id FROM User WHERE Email = 'pt@pt.com'];

		Test.startTest();

        System.runAs(ptUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(2, controller.financialInstitutionList.size());
        	System.assertEquals(true, controller.financialInstitutionsFound);

        	List<SelectOption> paginationSizeOptions = controller.paginationSizeOptions;

        	controller.next();
        	controller.previous();
        	controller.last();
        	controller.first();
        	controller.refreshPageSize();
        	Boolean hasPrevious = controller.hasPrevious;
        	Boolean hasNext = controller.hasNext;

        	controller.termsAndConditions = true;
        	controller.startGDIPortalAppRightCreation();
        	controller.createPortalAppRight();

        	controller.pollingStatus();

			insert new UserProvisioningRequest(SalesforceUserId = ptUser.Id, State = 'Failed', Operation = 'Create', ApprovalStatus = 'Denied');

			controller.pollingStatus();
        }

        Test.stopTest();
	}

	@isTest static void requestGDIAccessWithoutTermsAcceptedTest() {
		User ptUser = [SELECT Id FROM User WHERE Email = 'pt@pt.com'];

		Test.startTest();

        System.runAs(ptUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(2, controller.financialInstitutionList.size());

        	controller.termsAndConditions = false;
        	controller.startGDIPortalAppRightCreation();

        	System.assertEquals(System.Label.ISSP_Accept_Terms_Warning, controller.currentErrorMessage);
        }

        Test.stopTest();
	}

	@isTest static void requestedGDIAccessTest() {
		User ptUser = [SELECT Id, ContactId FROM User WHERE Email = 'pt@pt.com'];
		Portal_Applications__c portalApp = [SELECT Id FROM Portal_Applications__c WHERE Name = :ISSP_Financial_Institutions.GDI_PORTAL_SERVICE];

		Portal_Application_Right__c gdiPar = new Portal_Application_Right__c(Contact__c = ptUser.ContactId,
							                     							 Portal_Application__c = portalApp.Id,
							                     							 Right__c = 'Access Requested');
		insert gdiPar;

		Test.startTest();

        System.runAs(ptUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(2, controller.financialInstitutionList.size());
        	System.assertEquals(true, controller.gdiAppRightRequested);
        	System.assertEquals(false, controller.gdiAppRightGranted);
        	System.assertEquals(false, controller.gdiAppRightDenied);
        }

        Test.stopTest();
	}

	@isTest static void grantedGDIAccessTest() {
		User ptUser = [SELECT Id, ContactId FROM User WHERE Email = 'pt@pt.com'];
		Portal_Applications__c portalApp = [SELECT Id FROM Portal_Applications__c WHERE Name = :ISSP_Financial_Institutions.GDI_PORTAL_SERVICE];

		Portal_Application_Right__c gdiPar = new Portal_Application_Right__c(Contact__c = ptUser.ContactId,
							                     							 Portal_Application__c = portalApp.Id,
							                     							 Right__c = 'Access Granted');
		insert gdiPar;

		Test.startTest();

        System.runAs(ptUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(2, controller.financialInstitutionList.size());
        	System.assertEquals(false, controller.gdiAppRightRequested);
        	System.assertEquals(true, controller.gdiAppRightGranted);
        	System.assertEquals(false, controller.gdiAppRightDenied);
        }

        Test.stopTest();
	}

	@isTest static void deniedGDIAccessTest() {
		User ptUser = [SELECT Id, ContactId FROM User WHERE Email = 'pt@pt.com'];
		Portal_Applications__c portalApp = [SELECT Id FROM Portal_Applications__c WHERE Name = :ISSP_Financial_Institutions.GDI_PORTAL_SERVICE];

		Portal_Application_Right__c gdiPar = new Portal_Application_Right__c(Contact__c = ptUser.ContactId,
							                     							 Portal_Application__c = portalApp.Id,
							                     							 Right__c = 'Access Denied');
		insert gdiPar;

		Test.startTest();

        System.runAs(ptUser) {
        	ISSP_Financial_Institutions controller = new ISSP_Financial_Institutions();

        	Test.setCurrentPageReference(new PageReference('Page.ISSP_Financial_Institutions'));

        	System.assertEquals(2, controller.financialInstitutionList.size());
        	System.assertEquals(false, controller.gdiAppRightRequested);
        	System.assertEquals(false, controller.gdiAppRightGranted);
        	System.assertEquals(true, controller.gdiAppRightDenied);
        }

        Test.stopTest();
	}
}