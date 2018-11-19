@isTest
private class ISSP_RegistrationTest {

	public static testMethod void isspRegistration_test1() {

		ISSP_RegistrationTest.createTestData();
		
		ISSP_Registration.fakemethod();

		Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
    	con.AccountId = acc.Id;
    	con.LastName = 'test';
    	con.Email = 'test.issp.registration@testisspregistration.com';
    	con.RecordTypeId = rtId;
		insert con;

       	User newUser = new User(alias = 'dsfsdfds',
                                email = con.email,
                                emailencodingkey = 'UTF-8',
                                firstname = con.firstName,
                                lastname = con.lastname,
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                contactId = con.Id,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'test.issp.registration.testisspregistration.com@partner.iata.org',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = true);
        insert newUser;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();
	}

	public static testMethod void isspRegistration_test2() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        insert acc;

		ApexPages.currentPage().getParameters().put('subject','test');
		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Airline';
		ctrl.selectType();
		ctrl.toSearchDesignatorCodeString = 'Yes';
		ctrl.checkSearchDesignatorCode();
		ctrl.searchCountryAirline = ISO_Country.Id;
		ctrl.searchDesignatorCode = 'TP';
		ctrl.searchAccount();
		ctrl.searchDesignatorCode = 'TT';
		ctrl.searchAccount();
		ctrl.searchIATACodeAirline = '10';
		ctrl.searchAccount();
		ctrl.searchIATACodeAirline = '101';
		ctrl.searchAccount();
		ctrl.searchIATACodeAirline = '100';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test3() {

		ISSP_RegistrationTest.createTestData();

		Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
    	con.AccountId = acc.Id;
    	con.LastName = 'test';
    	con.Email = 'test.issp.registration@testisspregistration.com';
    	con.RecordTypeId = rtId;
		insert con;

		User newUser = new User(alias = 'dsfsdfds',
                                email = con.email,
                                emailencodingkey = 'UTF-8',
                                firstname = con.firstName,
                                lastname = con.lastname,
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                contactId = con.Id,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'test.issp.registration.testisspregistration.com@partner.iata.org',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = false);
        insert newUser;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = true;
		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.submitUser();
		ISSP_Registration.sendEmail(newUser.Id, con.Id);
	}

	public static testMethod void isspRegistration_test4() {

		User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		system.runAs(myUser){

			ISSP_RegistrationTest.createTestData();

			Account acc = ISSP_ObjectFactory.createNewAccount();
			insert acc;

			Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
			Contact con = ISSP_ObjectFactory.createNewContact();
	    	con.AccountId = acc.Id;
	    	con.LastName = 'test';
	    	con.Email = 'test.issp.registration@testisspregistration.com';
	    	con.RecordTypeId = rtId;
			insert con;

			User newUser = new User(alias = 'dsfsdfds',
	                                email = con.email,
	                                emailencodingkey = 'UTF-8',
	                                firstname = con.firstName,
	                                lastname = con.lastname,
	                                languagelocalekey = 'en_US',
	                                localesidkey = 'en_US',
	                                contactId = con.Id,
	                                timezonesidkey = 'Asia/Dubai',
	                                Username = 'test.issp.registration.testisspregistration.com@partner.iata.org',
	                                PortalRole = 'Manager',
	                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
	                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
	                                Portal_User_Frozen_Checkbox__c = true,
	                                IsActive = false);
	        insert newUser;
	        ISSP_Registration.permissionNewAgency(newUser.Id);
		}

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = true;
		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();
	}

	public static testMethod void isspRegistration_test5() {

		ISSP_RegistrationTest.createTestData();

		Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
    	con.AccountId = acc.Id;
    	con.LastName = 'test';
    	con.Email = 'test.issp.registration@testisspregistration.com';
    	con.RecordTypeId = rtId;
		insert con;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = true;
		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();
	}

	public static testMethod void isspRegistration_test6() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        acc.Name = 'TestAccount';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Airline';
		ctrl.selectType();
		ctrl.toSearchDesignatorCodeString = 'No';
		ctrl.checkSearchDesignatorCode();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'bla';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test7() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        acc.Name = 'TestAccount';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Airline';
		ctrl.selectType();
		ctrl.toSearchDesignatorCodeString = 'No';
		ctrl.checkSearchDesignatorCode();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'Test';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test8() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;
        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c='TP',Name='test2');
        insert ISO_Country2;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '100';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Airline_designator__c = 'TT';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Airline';
		ctrl.selectType();
		ctrl.toSearchDesignatorCodeString = 'Yes';
		ctrl.checkSearchDesignatorCode();
		ctrl.searchCountryAirline = ISO_Country2.Id;
		ctrl.searchDesignatorCode = 'TT';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test9() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.IATACode__c = '12345678912';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Agency';
		ctrl.selectType();
		ctrl.cargoTravel = 'Cargo';
		ctrl.checkAgencyType();
		ctrl.toSearchIataCodeString = 'Yes';
		ctrl.checkSearchIataCode();
		ctrl.searchIATACode = 'asdf';
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchAccount();
		ctrl.searchIATACode = '1234567891';
		ctrl.searchAccount();
		ctrl.searchIATACode = '12345678911';
		ctrl.searchAccount();
		ctrl.searchIATACode = '12345678912';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test10() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.IATACode__c = '12345678';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Agency';
		ctrl.selectType();
		ctrl.cargoTravel = 'Travel';
		ctrl.checkAgencyType();
		ctrl.toSearchIataCodeString = 'Yes';
		ctrl.checkSearchIataCode();
		ctrl.searchIATACode = 'asdf';
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchAccount();
		ctrl.searchIATACode = '1234567';
		ctrl.searchAccount();
		ctrl.searchIATACode = '12345679';
		ctrl.searchAccount();
		ctrl.searchIATACode = '12345678';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test11() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Name = 'TestAccount';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'OtherCompany';
		ctrl.selectType();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'bla';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test12() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Name = 'TestAccount';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'OtherCompany';
		ctrl.selectType();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'Test';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test13() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.IATACode__c = '12345678';
        insert acc;

        Portal_Applications__c newApp = new Portal_Applications__c();
		newApp.Name = 'TEST';
		insert newApp;

        String appId = String.valueOf(newApp.Id);
        ISSP_Portal_Service_Ids__c theIds = new ISSP_Portal_Service_Ids__c();
		theIds.AgencyAccreditation__c = appId.left(15);
		insert theIds;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Agency';
		ctrl.selectType();
		ctrl.cargoTravel = 'Travel';
		ctrl.checkAgencyType();
		ctrl.toSearchIataCodeString = 'No';
		ctrl.checkSearchIataCode();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'bla';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test14() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.IATACode__c = '12345678';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Agency';
		ctrl.selectType();
		ctrl.cargoTravel = 'Travel';
		ctrl.checkAgencyType();
		ctrl.toSearchIataCodeString = 'No';
		ctrl.checkSearchIataCode();
		ctrl.searchIATACode = 'asdf';
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'Test';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test15() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.IATACode__c = '12345678';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Agency';
		ctrl.selectType();
		ctrl.cargoTravel = 'Cargo';
		ctrl.checkAgencyType();
		ctrl.toSearchIataCodeString = 'No';
		ctrl.checkSearchIataCode();
		ctrl.searchIATACode = 'asdf';
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'bla';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test16() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.IATACode__c = '12345678';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.backToContactPage();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();
		ctrl.selectedCustomerType = 'Agency';
		ctrl.selectType();
		ctrl.cargoTravel = 'Cargo';
		ctrl.checkAgencyType();
		ctrl.toSearchIataCodeString = 'No';
		ctrl.checkSearchIataCode();
		ctrl.searchIATACode = 'asdf';
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'Test';
		ctrl.searchAccount();
		ctrl.register();
	}

	public static testMethod void isspRegistration_test17() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;
        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c='TP',Name='test2');
        insert ISO_Country2;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Sector__c = 'General Public';
        insert acc;

		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.backToContactPage();
		ctrl.accept = false;
		ctrl.submitUser();

		ctrl.accept = true;
		ctrl.con.email = '';
		ctrl.submitUser();

		ctrl.con.email = 'test.issp.registration@testisspregistration.com';
		ctrl.con.lastname = 'test';
		ctrl.submitUser();

		ctrl.submitContact();

		ctrl.getISOCountry();
		ctrl.getCustomerTypeList();
		ctrl.getCargoTravelOptions();
		ctrl.getIataCodeQuestion();

		ctrl.selectedCustomerType = 'NonIATAAgent';
		ctrl.selectType();
		ctrl.selectedCustomerType = 'GloballSalesAgent';
		ctrl.selectType();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'Test';
		ctrl.searchAccount();

		ctrl.selectedCustomerType = 'TIESS';
		ctrl.selectType();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'Test';
		ctrl.searchAccount();

		ctrl.selectedCustomerType = 'GloballSalesAgent';
		ctrl.selectType();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchCompanyName = 'Test';
		ctrl.searchAccount();

		ctrl.selectedCustomerType = 'GeneralPublic';
		ctrl.selectType();
		ctrl.searchCountry = ISO_Country2.Id;
		ctrl.searchAccount();
		ctrl.searchCountry = ISO_Country.Id;
		ctrl.searchAccount();
		ctrl.nextAsGP();

	}

	public static testMethod void isspRegistration_test18() {

		ISSP_RegistrationTest.createTestData();

		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='TT',Name='test');
        insert ISO_Country;
        IATA_ISO_Country__c ISO_Country2 = new IATA_ISO_Country__c(ISO_Code__c='TP',Name='United States');
        insert ISO_Country2;

        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Name = 'TestAgency';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.RecordTypeId = recordTypeId;
        acc.Sector__c = 'General Public';
        acc.billingstate = 'fakeState';
        acc.shippingstate = 'fakeState';
        insert acc;

        ApexPages.currentPage().getParameters().put('subject','testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttes');
		ISSP_Registration ctrl = new ISSP_Registration();
		ctrl.selectedCustomerType = 'Airline';
		ctrl.searchIATACode = '123';
		ctrl.caseDescription = 'test';
		ctrl.passwordReset = true;
		ctrl.submitCase();
		ISSP_Registration.generatePassword();
		ctrl.findLocation();
		ApexPages.currentPage().getParameters().put('CommunityName','CNS');
		String s = ctrl.commParam;
		PageReference pr = ctrl.checkSearchDesignatorCode();
		pr = ctrl.register();
		Boolean b = ctrl.checkCaptcha();

	}

	public static void createTestData(){

		List<ISSP_CS__c> csList = new List<ISSP_CS__c>();

		ISSP_CS__c cs1 = new ISSP_CS__c();
		cs1.Name = 'DefaultNewAccountOwnerId';
		cs1.Value__c = UserInfo.getUserId();
		csList.add(cs1);
		ISSP_CS__c cs2 = new ISSP_CS__c();
		cs2.Name = 'Host';
		cs2.Value__c = 'test';
		csList.add(cs2);
		ISSP_CS__c cs3 = new ISSP_CS__c();
		cs3.Name = 'ipinfo_token';
		cs3.Value__c = 'test';
		csList.add(cs3);

		List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name LIKE 'ISS%'];
		for (Profile thisProfile : profileList){
			ISSP_CS__c newCS = new ISSP_CS__c();
			newCS.Value__c = thisProfile.Id;
			if (thisProfile.Name == 'ISS Portal (Partner)'){
				newCS.Name = 'ISS_Portal';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Agency Delegated Admin User'){
				newCS.Name = 'ISS_Portal_Agency_Delegated_Admin';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Agency User (Partner)'){
				newCS.Name = 'ISS_Portal_Agency_User';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Airline Delegated Admin User'){
				newCS.Name = 'ISS_Portal_Airline_Delegated_Admin';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Airline User (Partner)'){
				newCS.Name = 'ISS_Portal_Airline_User';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal Delegated Admin User'){
				newCS.Name = 'ISS_Portal_Delegated_Admin';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal GSA Delegated Admin User'){
				newCS.Name = 'ISS_Portal_GSA_Delegated_Admin';
				csList.add(newCS);
			}
			else if (thisProfile.Name == 'ISS Portal GSA User (Partner)'){
				newCS.Name = 'ISS_Portal_GSA_User';
				csList.add(newCS);
			}
		}
		insert csList;
	}
}