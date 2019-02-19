/*
    Class Name: ISSP_AMC_Location_Identifier_Test.cls
    Related Classes: ISSP_AMC_Location_Identifier.cls, ISSP_AMC_Upload_Files

    Copyright @Right IT Services

    Purpose: Test class for ISSP_AMC_Location_Identifier

    VERSION     AUTHOR                          DATE                DETAIL/CHANGE REFERENCE
    1.0         DAVID BENTO & TIAGO MENDES    31-12-2018              INITIAL DEVELOPMENT
*/
@isTest
private class ISSP_AMC_Location_Identifier_Test {
	/*
        Purpose: Saves an Empty Participation
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testNoParticipation() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Location_Identifier'));
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				String creNameTest= controller.credentialName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = '1';
				controller.saveParticipation();
				/*ID accId = [SELECT Id,AccountId FROM Contact WHERE Id=:portalUser.contactId][0].AccountId;
				Account portalAcc = [SELECT Id FROM Account WHERE ID=:accId];
				portalAcc.SIS_Status__c = 'Terminated';
				update portalAcc;
				controller.saveParticipation();*/


				//ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
			}

			Test.stopTest();

		}
	}

	/*
        Purpose: Saves an Empty Participation with Account SIS_Status__c!= ACtive
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testNoParticipationNoSIS() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetupNoSIS();

			System.runAs(portalUser){

				System.debug('SIS_Status__c '+ISSP_AMC_DAO.getAccountInfo().SIS_Status__c);
				Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Location_Identifier'));
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				String creNameTest= controller.credentialName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = '1';
				controller.saveParticipation();


				//ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Saves a Location participation with the Location type Airport
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationSaveAirport() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Airport', false);
		
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Airport', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				controller.step = '1';
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;

				controller.saveParticipation();


				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);

			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Submits a Location participation with the Location type Airport
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationOnSubmitAirport() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Airport', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Airport', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = 'Submit';
				controller.saveParticipation();
				controller.init();
			}

			Test.stopTest();

		}
	}

		
	/*
        Purpose: Saves a Location participation with the Location type Heliport
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationSaveHeliport() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Heliport', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_HELIPORT, false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				controller.step = '1';
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				//controller.participation = ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Heliport', false);
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Submits a Location participation with the Location type Heliport
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationOnSubmitHeliport() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Heliport', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, ISSP_AMC_Constants.AMC_PAR_LOCATION_TYPE_HELIPORT, false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = 'Submit';
				controller.saveParticipation();
				controller.init();


			}

			Test.stopTest();

		}
	}

	
	/*
        Purpose: Saves a Location participation with the Location type Off-line Point
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationSaveOfflinePoint() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'OfflinePoint', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				controller.step = '1';
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.saveParticipation();
			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Submits a Location participation with the Location type Off-line Point
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationOnSubmitOfflinePoint() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Off-line Point', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = 'Submit';
				controller.saveParticipation();
				controller.init();
			}

			Test.stopTest();

		}
	}

	
	/*
        Purpose: Saves a Location participation with the Location type Railway Station
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationSaveRailwayStation() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'RailwayStation', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Railway Station', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				controller.step = '1';
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				//controller.participation = ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'RailwayStation', false);
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);


			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Submits a Location participation with the Location type Railway Station
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationOnSubmitRailwayStation() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'RailwayStation', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Railway Station', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = 'Submit';
				controller.saveParticipation();
				controller.init();
			}

			Test.stopTest();

		}
	}

	/*
        Purpose: Saves a Location participation with the Location type Bus Station
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationSaveBusStation() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'BusStation', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Bus Station', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				controller.step = '1';
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				//controller.participation = ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'BusStation', false);
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Submits a Location participation with the Location type Bus Station
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationOnSubmitBusStation() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'BusStation', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Bus Station', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = 'Submit';
				controller.saveParticipation();
				controller.init();
			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Saves a Location participation with the Location type Ferry Port
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationSaveFerryPort() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'BusStation', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Ferry Port', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				controller.step = '1';
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Submits a Location participation with the Location type Ferry Port
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationOnSubmitFerryPort() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'BusStation', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Ferry Port', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = 'Submit';
				controller.saveParticipation();
				controller.init();
			}

			Test.stopTest();

		}
	}

	/*
        Purpose: Saves a Location participation with the Location type Metropolitan Area
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationSaveMetropolitanArea() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'MetropolitanArea', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Metropolitan Area', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.step = '1';
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
			}

			Test.stopTest();

		}
	}
	/*
        Purpose: Submits a Location participation with the Location type Metropolitan Area
        Parameters: 
        Returns:
        Throws [Exceptions]: 
    */
	@isTest static void testWithParticipationOnSubmitMetropolitanArea() {

	 	ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);
		//ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'MetropolitanArea', false);
		
		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest(); 
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Metropolitan Area', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = 'Submit';
				controller.saveParticipation();
				controller.init();
			}

			Test.stopTest();

		}
	}


}