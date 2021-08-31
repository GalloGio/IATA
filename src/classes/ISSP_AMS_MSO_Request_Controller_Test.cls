@isTest
private class ISSP_AMS_MSO_Request_Controller_Test {

	@isTest static void test_method() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		User newUser;
		IATA_ISO_State__c isos;
		IATA_ISO_Country__c isoc;

		System.runAs(thisUser){
			Id  programRT = RecordTypeSelector.selectIdBySObjectAndDeveloperName('AMS_Segment__c', 'IATA_Code_Programs');
			Id  codeRangeRT = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Code_Range__c', 'IATA_Code');

			AMS_Segment__c p1 = new AMS_Segment__c (label__c='M',RecordTypeId=programRT );
			insert p1;

			isoc = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(1).get(0);
			isoc.ISO_Code__c = 'FR';
			isoc.Case_BSP_Country__c = 'Test';
			insert isoc;

			isos = new IATA_ISO_State__c(Name='Test_state', IATA_ISO_Country__c = isoc.Id, ISO_Code__c='FR');
			insert isos;

			Code_Range__c r1 = new Code_Range__c (Name ='FR1',Area__c=1, Area_Code__c=2, Prefix__c='10', IATA_ISO_Country__c=isoc.Id,
			IATA_ISO_State__c=isos.Id, Max_Range__c=9999, Min_Range__c=1, ProgramCode__c = 'M', program__c=p1.id, RecordTypeId=codeRangeRT);
			insert r1;

			Account acc = TestDataFactory_Accounts.createAirlineAccounts(1).get(0);
			acc.Name = 'Airline HQ';
			acc.IATACode__c = '012';
			acc.Airline_designator__c = 'HQ';
			acc.IATA_ISO_Country__c = isoc.Id;
			insert acc;

			Contact con = TestDataFactory_Contacts.createDefaultContact(1).get(0);
			con.AccountId = acc.Id;
			con.User_Portal_Status__c = 'Approved User';
			insert con;

			Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' LIMIT 1];

			newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{con}).get(0);
			insert newUser;
		}

		System.runAs(newUser){
			Test.setCurrentPage(Page.ISSP_AMS_MSO_Request);
			ISSP_AMS_MSO_Request_Controller ctrl = new ISSP_AMS_MSO_Request_Controller();

			system.assertEquals('/ISSP_AMS_MSO', ctrl.cancel().getUrl());
			system.assertEquals('/ISSP_Homepage', ctrl.securityCheck().getUrl());

			ctrl.accreditationForm.Branch_Office_Street_name_number__c = 'streetname';
			ctrl.accreditationForm.Branch_Office_City__c = 'cityname';
			ctrl.accreditationForm.Branch_Office_Postal_code__c = '12345';

			// failing because no country & state selected
			system.assertEquals(null, ctrl.save());

			system.assertNotEquals(0, ctrl.countryISOCodeList.size());
			ctrl.countrySelected = isoc.Id;
			ctrl.refreshStates();
			ctrl.billingState = isos.Id;

			Test.startTest();
			ctrl.submitAndApproveCase();
			ISSP_AMS_MSO_Request_Controller.closeOscar(null);
			Test.stopTest();
		}
	}

	@isTest static void test_method2() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		User newUser;
		IATA_ISO_State__c isos;
		IATA_ISO_Country__c isoc;

		System.runAs(thisUser){
			isoc = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(1).get(0);
			isoc.ISO_Code__c = 'FR';
			isoc.Case_BSP_Country__c = 'Test';
			insert isoc;

			isos = new IATA_ISO_State__c(Name='Test_state', IATA_ISO_Country__c = isoc.Id, ISO_Code__c='FR', Valid_for_address__c = true);
			insert isos;

			Account acc = TestDataFactory_Accounts.createAirlineAccounts(1).get(0);
			acc.IATACode__c = '012';
			acc.Airline_designator__c = 'HQ';
			acc.IATA_ISO_Country__c = isoc.Id;
			insert acc;

			Contact con = TestDataFactory_Contacts.createDefaultContact(1).get(0);
			con.AccountId = acc.id;
			con.User_Portal_Status__c = 'Approved User';
			insert con;

			Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' LIMIT 1];
			
			newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{con}).get(0);
			newUser.profileId = p.id;
			insert newUser;
		}

		System.runAs(newUser){
			Test.setCurrentPage(Page.ISSP_AMS_MSO_Request);
			ISSP_AMS_MSO_Request_Controller ctrl = new ISSP_AMS_MSO_Request_Controller();

			ctrl.accreditationForm.Branch_Office_Street_name_number__c = 'streetname';
			ctrl.accreditationForm.Branch_Office_City__c = 'cityname';
			ctrl.accreditationForm.Branch_Office_Postal_code__c = '12345';
			ctrl.countrySelected = isoc.Id;
			ctrl.refreshStates();
			ctrl.billingState = isos.Id;
			ctrl.refreshCities();
			String cities = ISSP_AMS_MSO_Request_Controller.billingCityListStr;
			Test.startTest();
			ctrl.accreditationForm.Branch_Office_Email__c = 'a';
			ctrl.accreditationForm.Branch_Office_Street_name_number__c = '';
			ctrl.accreditationForm.Branch_Office_Postal_code__c = '';
			ctrl.accreditationForm.Branch_Office_City__c = '';
			ctrl.save();

			ctrl.accreditationForm.Branch_Office_Email__c = '';
			ctrl.accreditationForm.Branch_Office_Street_name_number__c = 'streetname';
			ctrl.accreditationForm.Branch_Office_City__c = 'cityname';
			ctrl.accreditationForm.Branch_Office_Postal_code__c = '12345';
			ctrl.save();
			ctrl.save();

			ctrl.goBackToForm();
			Test.setCurrentPage(new PageReference('/apex/ISSP_AMS_MSO_Request?caseId=' + ctrl.oscarCase.Id));
			ctrl.cancelRequest();

			ISSP_AMS_MSO_Request_Controller.updateCaseContact(null, null);
			Test.stopTest();

			system.assertEquals('', ctrl.commParam);
			system.assertEquals('', ctrl.commParamFirst);
		}
	}

	@isTest static void test_increase_coverage() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		User newUser;
		IATA_ISO_State__c isos;
		IATA_ISO_Country__c isoc;

		System.runAs(thisUser){
			Id accRtId = RecordTypeSelector.selectIdBySObjectAndDeveloperName('Account', 'IATA_Airline');

			isoc = TestDataFactory_IATAISOCountries.createDefaultIATAISOCountries(1).get(0);
			isoc.ISO_Code__c = 'FR';
			isoc.Case_BSP_Country__c='Test';
			insert isoc;

			isos = new IATA_ISO_State__c(Name='Test_state', IATA_ISO_Country__c = isoc.Id, ISO_Code__c='FR');
			insert isos;

			Account acc = TestDataFactory_Accounts.createAirlineAccounts(1).get(0);
			acc.IATACode__c = '012';
			acc.Airline_designator__c = 'HQ';
			acc.IATA_ISO_Country__c = isoc.Id;
			insert acc;

			Contact con = TestDataFactory_Contacts.createDefaultContact(1).get(0);
			con.AccountId = acc.id;
			con.User_Portal_Status__c = 'Approved User';
			insert con;

			Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' LIMIT 1];

			newUser = TestDataFactory_Users.createPortalUsers(new List<Contact>{con}).get(0);
			newUser.profileId = p.id;
			insert newUser;
		}

		System.runAs(newUser){
			Test.setCurrentPage(Page.ISSP_AMS_MSO_Request);
			ISSP_AMS_MSO_Request_Controller ctrl = new ISSP_AMS_MSO_Request_Controller();

			ctrl.applyLanguage = 'es';
			system.assertNotEquals(0, ctrl.countryISOCodeList.size());

			ctrl.applyLanguage = 'fr';
			system.assertNotEquals(0, ctrl.countryISOCodeList.size());
		}

		isoc.IATA_Country_SP__c = 'spanishname';
		isoc.IATA_Country_FR__c = 'frenchname';
		update isoc;

		System.runAs(newUser){
			Test.setCurrentPage(Page.ISSP_AMS_MSO_Request);
			ISSP_AMS_MSO_Request_Controller ctrl = new ISSP_AMS_MSO_Request_Controller();

			ctrl.applyLanguage = 'es';
			system.assertNotEquals(0, ctrl.countryISOCodeList.size());

			ctrl.applyLanguage = 'fr';
			system.assertNotEquals(0, ctrl.countryISOCodeList.size());
		}
	}
}