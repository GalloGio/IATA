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

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];


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
				Test.StartTest();
				controller.saveParticipation();


				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
				Test.stopTest();

			}



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

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

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
				Test.StartTest();
				controller.saveParticipation();
				controller.init();
				Test.stopTest();
			}

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

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];


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
				Test.StartTest();
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
				Test.stopTest();
			}



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

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

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
				Test.StartTest();
				controller.saveParticipation();
				controller.init();
				Test.stopTest();


			}

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

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

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
				Test.StartTest();
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
				Test.stopTest();


			}

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
	@isTest static void testUploadsOnLocS() {
		insert new Apex_Setting__c(Name='RT valid to reopen attachment trigger', Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
                                           +  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application');
		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];


			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.StartTest();
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Bus Station', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				ISSP_AMC_ParticipationFactory.testUploads(controller);
				Test.stopTest();
			}



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

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

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
				Test.StartTest();
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
				Test.stopTest();
			}

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

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

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
				Test.StartTest();
				controller.saveParticipation();

				ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
				Test.stopTest();
			}

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

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];


			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipation('ParName', true, 'Metropolitan Area', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				Test.StartTest();
					controller.step = '1';
					controller.saveParticipation();
					ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
				Test.stopTest();
			}



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

	/*
		Purpose: Saves an Empty Participation with Account SIS_Status__c!= ACtive
		Parameters:
		Returns:
		Throws [Exceptions]:
	*/
	@isTest static void testNoParticipationNoSISSpecialToo() {

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetupNoSIS();

			Account acc = [SELECT id, Name,
									Airline_Code__c,
									Baggage_Tag_Range_Code__c,
									Airline_designator__c,
									IATACode__c,
									Airline_Prefix__c,
									AOC_Expiry_Date__c,
									Legal_name__c,
									TradeName__c,
									Sector__c,
									Category__c,
									IATA_ISO_Country__r.Name,
									Region_formula__c,
									Phone,
									Email__c,
									Website,
									ShippingStreet,
									ShippingAddress,
									ShippingCity,
									ShippingState,
									ShippingPostalCode,
									ShippingCountry,
									IATA_ISO_Country__c,
									SIS_Status__c
							FROM account

							LIMIT 1];
				acc.SIS_Status__c = 'Terminated';
				update acc;

			System.runAs(portalUser){

				System.debug('SIS_Status__c '+ISSP_AMC_DAO.getAccountInfo().SIS_Status__c);
				Test.setCurrentPageReference(new PageReference('Page.ISSP_AMC_Location_Identifier'));
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				controller.init();
				controller.Participation.Location_Type__c = 'Airport';
				controller.CalculateWhichComponentsToShow();
				controller.step = '1';
				Test.StartTest();
				controller.saveParticipation();
				Test.stopTest();

				//ISSP_AMC_ParticipationFactory.testLocationUploadFiles(controller);
			}

		}
	}

	/*
		Purpose: Submits a Location participation with the Location type Metropolitan Area
		Parameters:
		Returns:
		Throws [Exceptions]:
	*/
	@isTest static void testWithParticipationOnSubmitMetropolitanAreaNoDate() {

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

		Test.StartTest();
			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipationELSES('ParName', true, 'Metropolitan Area', false).Id);
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
		Purpose: Submits a Location participation with the Location type Metropolitan Area
		Parameters:
		Returns:
		Throws [Exceptions]:
	*/
	@isTest static void testWithParticipationOnSubmitAirportNoDate() {

		ISSP_AMC_ParticipationFactory.createcustomSetting(true);
		ISSP_AMC_ParticipationFactory.createLocationIdentifierRequirements(true);

		User myUser = [select Id from User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];

			System.runAs(myUser){

			User portalUser = ISSP_AMC_ParticipationFactory.portalSetup();

			System.runAs(portalUser){

				PageReference pageRef = Page.ISSP_AMC_Location_Identifier;
				Test.setCurrentPageReference(pageRef);
				pageRef.getParameters().put('participationId',ISSP_AMC_ParticipationFactory.createLocationIdentifierParticipationELSES('ParName', true, 'Airport', false).Id);
				ISSP_AMC_Location_Identifier controller = new ISSP_AMC_Location_Identifier();
				String testLanguage = controller.displayLanguage;
				String testComName = controller.communityName;
				List <SelectOption> testCountry = controller.countryList;
				List <SelectOption> testSalutation = controller.salutationList;
				controller.step = 'Submit';
				Test.StartTest();
				controller.saveParticipation();
				controller.init();
				Test.stopTest();
			}

		}
	}

}
