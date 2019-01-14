@isTest
private class ISSP_ANG_ANNUAL_REVALIDATION_Test {

	private static Id rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
	private static Id rtOscar = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_ANNUAL_REVALIDATION'); 
	private static Id rtCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

	@isTest
	static void test1() {
		try {
			ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();
			System.assert(false);
		} catch (Exception e) {
			System.assert(true);
		}
	}

	@isTest
	static void test2() {
		try {
			Account account = ISSP_ObjectFactory.createNewAccount();
			account.BillingCity = 'test';
			account.Name = 'test';
			account.sector__c = 'Travel Agent';
			account.Location_Type__c = 'HE';
			account.Location_Class__c = 'P';
			account.RecordTypeId = rtAgency ;
			account.IATACode__c = '12345678';

			insert account;

			Case testcase = new Case (
				Account_Concerned__c = account.id,
				AccountId = account.id,
				Reason1__c = 'Bla bla bla bla',
				RecordTypeId = rtCase,
				Type = 'Case',
				Type_of_customer__c = 'IATA Travel Agent'
			);

			insert testcase;

			Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
			System.currentPageReference().getParameters().put('caseId', testcase.id);

			ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();
			System.assert(false);
		} catch (Exception e) {
			System.assert(true);
		}
	}

	@isTest
	static void test3() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', ANG_Enable_NewGen__c = true);
		insert country;

        Account account = ISSP_ObjectFactory.createNewAccount();
        account.BillingCity = 'test';
        account.Name = 'test';
        account.sector__c = Ams_Utils.SECTOR_PASSENGER;
        account.Reason__c = '91-Accredited';
        account.Location_Type__c = AMS_Utils.HE;
        account.RecordTypeId = rtAgency ;
        account.IATACode__c = '12345678';
		account.status__c = Ams_Utils.ACC_S9_APPROVED;
		account.IATA_ISO_Country__c = country.Id;
		account.Location_Class__c = 'P';

		insert account;

		AMS_OSCAR__c oscar = New AMS_OSCAR__c (
			Account__c = account.id,
			Process__c = 'ANG.ANNUAL.REVALIDATION',
			RecordTypeId = rtOscar
		);

		insert oscar;

		Case testcase = new Case (
			Account_Concerned__c = account.id,
			AccountId = account.id,
			OSCAR__c  = oscar.id,
			CaseArea__c = 'Accreditation Process',
			Reason1__c = 'Annual revalidation',
			RecordTypeId = rtCase,
			Subject = 'Annual revalidation - GoStandard - test',
			Type = 'Case',
			Type_of_customer__c = 'IATA Travel Agent'
		);

		insert testcase;

		Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
		System.currentPageReference().getParameters().put('caseId', testcase.id);

		ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();

		oscar.Status__c = 'Closed';

		AMS_ChangeCodes__c config = new AMS_ChangeCodes__c(Name = 'ARV', 
				Bulletin_Memo_Text__c = 'AGENT IS SERVED ADMINISTRATIVE NON-COMPLIANCE DUE TO ANNUAL REVALIDATION NON COMPLIANCE, AGENT IS GIVEN 30 DAYS TO VALIDATE THE AGENCY DETAILS',
				Change_Code__c = 'ARV',
				Published_in_bulletin__c = true,
				Integration_RecId__c = 'C'
		);

		insert config;

		Test.startTest();

		try{
			update oscar;
		}catch(Exception e){
			System.assert(e.getMessage().contains('The case cannot be closed if the sanity check is not passed or failed.'));
		}

		oscar.STEP43__c = AMS_Utils.FAILED;
		oscar.Step6__c = AMS_Utils.PASSED;
		update oscar;
	}


	@isTest
	static void test4() {

		Test.startTest();

		insert new ISSP_CS__c(Name = 'ISSP AMS ALLOWED AGENCY URL', Value__c = '^(http:\\/\\/|https:\\/\\/)?(www.)([a-zA-Z0-9\\-]+)(([.])(([a-zA-Z]{2,3}))([.]){0,1}([a-zA-Z]{2,3}){0,1})');

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', ANG_Enable_NewGen__c = true,
                                    Postal_Code_Format_regEx__c = '\\d{4}([\\-]\\d{3})?');
		insert country;

		AMS_Accreditation_Country_CheckList__c aacc = new AMS_Accreditation_Country_CheckList__c(
     		IATA_ISO_Country__c = country.Id,
     		Operation__c = 'Travel Agent'
     	);

     	insert aacc;

        Account account = ISSP_ObjectFactory.createNewAccount();
        account.BillingCity = 'test';
        account.Name = 'test';
        account.sector__c = Ams_Utils.SECTOR_PASSENGER;
        account.Location_Type__c = AMS_Utils.HE;
        account.RecordTypeId = rtAgency ;
        account.IATACode__c = '12345678';
		account.status__c = Ams_Utils.ACC_S9_APPROVED;
		account.IATA_ISO_Country__c = country.Id;
		account.Location_Class__c = 'P';

		insert account;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test';
        child.Name = 'test child';
        child.sector__c = Ams_Utils.SECTOR_PASSENGER;
        child.Location_Type__c = AMS_Utils.AE;
        child.RecordTypeId = rtAgency ;
        child.IATACode__c = '87654321';
		child.status__c = Ams_Utils.ACC_S9_APPROVED;
		child.parentId = account.id;
		child.Top_Parent__c = account.id;
		child.IATA_ISO_Country__c = country.Id;
		child.Location_Class__c = 'P';

		insert child;

		AMS_Agencies_Hierarchy__c hier = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hier;

		AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account.Id, Child_Account__c = child.Id, HO_Flag__c = 'true', Is_Newgen_Relation__c = true);

		insert rel;

		AMS_OSCAR__c oscar = New AMS_OSCAR__c (
			Account__c = account.id,
			Process__c = 'ANG.ANNUAL.REVALIDATION',
			RecordTypeId = rtOscar
		);

		insert oscar;

		Case testcase = new Case (
			Account_Concerned__c = account.id,
			AccountId = account.id,
			OSCAR__c  = oscar.id,
			Reason1__c = 'Annual revalidation',
			RecordTypeId = rtCase,
			Subject = 'Annual revalidation - GoStandard - test',
			Type = 'Case',
			Type_of_customer__c = 'IATA Travel Agent'
		);

		insert testcase;

		Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
		System.currentPageReference().getParameters().put('caseId', testcase.id);

		ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();


		String mode = ctrl.mode;

		List<SelectOption> countryNameList = ctrl.countryNameList;
		AMS_Accreditation_Country_CheckList__c CountryCheckList = ctrl.CountryCheckList;


		ctrl.currentIataCode = '87654321';
		ctrl.loadIataCode();

		ctrl.updateDetails();

		ctrl.saveDraft();

		ctrl.discardDetails();

		ctrl.updateDetails();

		ctrl.discardDetails();

		ctrl.currentIataCode = '12345678';
		ctrl.loadIataCode();

		ctrl.confirmDetails();

		ctrl.discardDetails();

		ctrl.currentIataCode = '87654321';
		ctrl.loadIataCode();

		ctrl.updateDetails();

		ctrl.cancelUpdate();

		ctrl.updateDetails();

		ctrl.confirmUpdate();

		Test.stopTest();

		ctrl.currentAccount.fw.newForm.Confirm_Legal_Details_are_correct__c = true;
		ctrl.currentAccount.fw.newForm.Confirm_Location_Details_are_correct__c = true;
		ctrl.currentAccount.fw.newForm.Confirm_Ownership_details_are_correct__c = true;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newForm.Confirm_Legal_Details_are_correct__c = false;
		ctrl.currentAccount.fw.newForm.Confirm_Location_Details_are_correct__c = false;
		ctrl.currentAccount.fw.newForm.Confirm_Ownership_details_are_correct__c = false;

		ctrl.currentAccount.fw.newForm.Notify_Change_Legal_Details__c = false;
		ctrl.currentAccount.fw.newForm.Notify_Change_Location__c = false;
		ctrl.currentAccount.fw.newForm.Notify_Change_Ownership__c = false;

		ctrl.confirmUpdate();

		/*ctrl.currentAccount.fw.newform.Local_Physical_Address_Street__c = 'test';
		ctrl.currentAccount.fw.newform.Local_Postal_Address_Street__c = 'test';
		ctrl.currentAccount.fw.newform.Local_Physical_Address_City__c = 'test';
		ctrl.currentAccount.fw.newform.Local_Postal_Address_City__c = 'test';
		ctrl.currentAccount.fw.newform.Local_Physical_Address_Province__c = 'test';
		ctrl.currentAccount.fw.newform.Local_Postal_Address_Province__c = 'test';
		ctrl.currentAccount.fw.newform.Local_Legally_Registered_Name__c = 'test';*/

		ctrl.currentAccount.fw.newForm.Notify_Change_Legal_Details__c = true;
		ctrl.currentAccount.fw.newForm.Notify_Change_Location__c = true;
		ctrl.currentAccount.fw.newForm.Notify_Change_Ownership__c = true;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newForm.Notify_Change_Ownership__c = true;
		ctrl.currentAccount.fw.newform.ISSP_AMS_Legal_Status__c = 'Corporation';
		ctrl.currentAccount.fw.newform.ISSP_AMS_Paidup_capital__c = null;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.ISSP_AMS_Paidup_capital__c = 123;

		ctrl.currentAccount.fw.newForm.Notify_Change_Legal_Details__c = true;
		ctrl.currentAccount.fw.newForm.Notify_Change_Location__c = false;
		ctrl.currentAccount.fw.newForm.Notify_Change_Ownership__c = false;

		ctrl.currentAccount.fw.newform.Account_Name__c = 'new name';

		ctrl.confirmUpdate();

		ISSP_ANG_ANNUAL_REV_UPDATE upd = new ISSP_ANG_ANNUAL_REV_UPDATE();
		upd.ca = ctrl.currentAccount;
		upd.newAgencyContact();
		upd.editAgencyContact();
		AMS_Accreditation_Country_CheckList__c CountryCheckListUpd = upd.CountryCheckList;

		ctrl.newAgencyContact();
		ctrl.contactType = 'Company';

		ctrl.createAgencyContact();

		ctrl.currentAccount.newContact = new AMS_Accreditation_Contact__c();
		ctrl.contactType = 'Company';
		ctrl.iataCode = '2';
		ctrl.companyModalNameOfEmployer = '';

		ctrl.createAgencyContact();

		ctrl.currentAccount.newContact.Registration_number__c = '213';

		ctrl.createAgencyContact();

		ctrl.currentAccount.newContact.Name = '3213';

		ctrl.createAgencyContact();

		ctrl.contactType = 'Current Owner';
		ctrl.currentAccount.newContact.AddressCountry__c = null;
		ctrl.currentAccount.newContact.Agency_owner__c = true;
		ctrl.currentAccount.newContact.Time_devoted_to_Agency_business__c = null;
		ctrl.currentAccount.newContact.Agency_owner__c = false;
		ctrl.currentAccount.newContact.Agency_role__c = false;

		ctrl.currentAccount.newContact.Agency_owner__c = true;
		ctrl.legalStatus = 'sole proprietorship';
		ctrl.currentAccount.newContact.Agency_owner__c = true;
		ctrl.currentAccount.newContact.Financial_interest__c = null;
		ctrl.cntIFAPContacts = 100;
		ctrl.currentAccount.newContact.Financial_Assessment_Contact__c = true;

		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = 'none';

		ctrl.createAgencyContact();

		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = '';
		ctrl.createAgencyContact();

		ctrl.currentAccount.newContact.First_name__c = '╗';
		ctrl.currentAccount.newContact.Last_name__c = '╗';
		ctrl.currentAccount.newContact.AddressStreet__c = '╗';
		ctrl.currentAccount.newContact.AddressCity__c = '╗';
		ctrl.currentAccount.newContact.AddressPostcode__c = '╗';
		ctrl.currentAccount.newContact.Job_title__c = '╗';
		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = 'some';
		ctrl.currentAccount.newContact.Prev_Job1_Employer__c = '╗';
		ctrl.currentAccount.newContact.Prev_Job1_Position__c = '╗';
		ctrl.currentAccount.newContact.Prev_Job1_Address__c = '╗';
		ctrl.currentAccount.newContact.Prev_Job2_Employer__c = '╗';
		ctrl.currentAccount.newContact.Prev_Job2_Position__c = '╗';
		ctrl.currentAccount.newContact.Prev_Job2_Address__c = '╗';

		ctrl.validateCharactersInPersonWindow();

		ctrl.createAgencyContact();
		ctrl.validateCharactersInCompanyWindow();

		ctrl.currentAccount.newContact.Registration_number__c = '╗';
		ctrl.validateCharactersInCompanyWindow();

		ctrl.contactType = 'Company';

		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = 'none';
		ctrl.currentAccount.newContact.First_name__c = 'a';
		ctrl.currentAccount.newContact.Last_name__c = 'a';
		ctrl.currentAccount.newContact.AddressStreet__c = 'a';
		ctrl.currentAccount.newContact.AddressCity__c = 'a';
		ctrl.currentAccount.newContact.AddressPostcode__c = 'a';
		ctrl.currentAccount.newContact.Job_title__c = 'a';
		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = 'some';
		ctrl.currentAccount.newContact.Prev_Job1_Employer__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job1_Position__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job1_Address__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job2_Employer__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job2_Position__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job2_Address__c = 'a';
		ctrl.currentAccount.newContact.Registration_number__c = '321';
		ctrl.currentAccount.newContact.Name = 'aaa';
		ctrl.currentAccount.newContact.Financial_interest__c = 10;

		ctrl.createAgencyContact();

		ctrl.contactType = 'Current Owner';
		ctrl.iatacode = '3421';
		ctrl.currentAccount.newContact.AddressCountry__c = null;
		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = '';
		ctrl.currentAccount.newContact.Agency_owner__c = true;
		ctrl.currentAccount.newContact.Time_devoted_to_Agency_business__c = null;
		ctrl.currentAccount.newContact.Agency_owner__c = false;
		ctrl.currentAccount.newContact.Agency_role__c = false;
		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = 'jlfdçskkdklfj';

		ctrl.createAgencyContact();

		ctrl.contactType = 'Person';

		ctrl.createAgencyContact();


		ctrl.editContactId = null;
		ctrl.editAgencyContact();
		ctrl.cancelAgentUpdate();
		ctrl.deleteAgencyContact();
		ctrl.fetchAgentDetails();
		ctrl.iatacode = '87654321';
		ctrl.fetchAgentDetails();
		ctrl.isAddCompanyModal = true;
		ctrl.iatacode = '22335408';
		ctrl.fetchAgentDetails();
		ctrl.iatacode = '12345678';
		ctrl.fetchAgentDetails();

		ctrl.currentAccount.newContact = new AMS_Accreditation_Contact__c();
		ctrl.contactType = 'Person';

		ctrl.createAgencyContact();

		ctrl.saveDraft();

		ctrl.saveDraftAndLeave();

		ctrl = null;

		Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
		System.currentPageReference().getParameters().put('caseId', testcase.id);

		ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();

		ctrl.goToStep1();

		ctrl.goToStep2();

		ctrl.save();

		ctrl.cancel();

		ctrl.currentAccount.fw.newform.Is_change_legal_name__c = true;
		ctrl.currentAccount.fw.newform.Notify_Change_Legal_Details__c = true;
		ctrl.currentAccount.fw.newform.Account_Name__c = null;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.Notify_Change_Accreditation_Type__c = true;
		ctrl.currentAccount.fw.newform.ANG_Accreditation_Model_to_Change__c = null;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.ANG_Accreditation_Model_to_Change__c = 'Cash';

		ctrl.confirmUpdate();

		ctrl.currentAccount.isocountry.Local_language_Agency_details_required__c = true;
		ctrl.currentAccount.fw.newform.Is_change_legal_name__c = true;
		ctrl.currentAccount.fw.newform.Notify_Change_Legal_Details__c = true;
		ctrl.currentAccount.fw.newform.Local_Legally_Registered_Name__c = null;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.Account_Name__c = '中文';
		ctrl.currentAccount.fw.newform.Trade_Name__c = '中文';
		ctrl.currentAccount.fw.newform.ISSP_AMS_VAT_Number_Input__c = null;
		ctrl.currentAccount.isocountry.Tax_Number_VAT_field_mandatory__c = true;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.ISSP_AMS_VAT_Number_Input__c = '123';
		ctrl.currentAccount.fw.newForm.INVALID_Tax_Number__c = true;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.Branch_Office_City__c = null;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.Is_change_location__c = true;
		ctrl.currentAccount.fw.newform.Notify_Change_Location__c = true;
		ctrl.currentAccount.isocountry.Local_language_Agency_details_required__c = true;
		ctrl.currentAccount.fw.newform.Local_Physical_Address_Street__c = null;
		ctrl.currentAccount.fw.newform.Local_Physical_Address_City__c = null;
		ctrl.currentAccount.fw.newform.Local_Physical_Address_Province__c = null;
		ctrl.currentAccount.fw.newform.Local_Postal_Address_Street__c = null;
		ctrl.currentAccount.fw.newform.Local_Postal_Address_City__c = null;
		ctrl.currentAccount.fw.newform.Local_Postal_Address_Province__c = null;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.Have_any_having_authorization_to_act__c = 'Yes';
		ctrl.currentAccount.fw.newform.Give_details_for_authorization_to_act__c = null;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.Confirm_Legal_Details_are_correct__c = false;
		ctrl.currentAccount.fw.newform.Notify_Change_Legal_Details__c = false;

		ctrl.confirmUpdate();

		ctrl.currentAccount.fw.newform.Will_the_change_of_ownership_cause__c = 'Yes';
		ctrl.currentAccount.fw.newform.Give_details_for_the_change_of_ownership__c = null;

		ctrl.confirmUpdate();

		upd.validateVATNumber();

		aacc.License_required__c = true;
		aacc.Registration_required__c = true;
		update aacc;

		ctrl.confirmUpdate();

		country.IEC_Zip_Postal_Code_required__c = true;
		country.State_Province_Mandatory__c = true;
		update country;

		ctrl.currentAccount.isocountry.State_Province_Mandatory__c = true;
		ctrl.currentAccount.isocountry.IEC_Zip_Postal_Code_required__c = true;

		ctrl.currentAccount.fw.newform.Shipping_Postal_Code__c = null;
		ctrl.currentAccount.fw.newform.Shipping_State__c = null;
		ctrl.currentAccount.fw.newform.Branch_Office_Postal_code__c = null;
		ctrl.currentAccount.fw.newform.State_Province__c = null;
		ctrl.currentAccount.fw.newform.Local_Physical_Address_Postal_Code__c = null;
		ctrl.currentAccount.fw.newform.Local_Postal_Address_Postal_Code__c = null;
		ctrl.currentAccount.fw.newform.Local_Physical_Address_Province__c = null;
		ctrl.currentAccount.fw.newform.Local_Postal_Address_Province__c = null;

		ctrl.confirmUpdate();
	}

	@isTest
	static void test5() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', ANG_Enable_NewGen__c = true );
		insert country;

		AMS_Accreditation_Country_CheckList__c aacc = new AMS_Accreditation_Country_CheckList__c(
     		IATA_ISO_Country__c = country.Id,
     		Operation__c = 'Travel Agent'
     	);

     	insert aacc;

        Account account = ISSP_ObjectFactory.createNewAccount();
        account.BillingCity = 'test';
        account.Name = 'test';
        account.sector__c = Ams_Utils.SECTOR_PASSENGER;
        account.Location_Type__c = AMS_Utils.HE;
        account.RecordTypeId = rtAgency ;
        account.IATACode__c = '12345678';
		account.status__c = Ams_Utils.ACC_S9_APPROVED;
		account.IATA_ISO_Country__c = country.Id;
		account.Location_Class__c = 'P';

		insert account;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test';
        child.Name = 'test child';
        child.sector__c = Ams_Utils.SECTOR_PASSENGER;
        child.Location_Type__c = AMS_Utils.AE;
        child.RecordTypeId = rtAgency ;
        child.IATACode__c = '87654321';
		child.status__c = Ams_Utils.ACC_S9_APPROVED;
		child.parentId = account.id;
		child.Top_Parent__c = account.id;
		child.IATA_ISO_Country__c = country.Id;
		child.Location_Class__c = 'P';

		insert child;

		AMS_Agencies_Hierarchy__c hier = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hier;

		AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account.Id, Child_Account__c = child.Id, HO_Flag__c = 'true', Is_Newgen_Relation__c = true);

		insert rel;

		AMS_OSCAR__c oscar = New AMS_OSCAR__c (
			Account__c = account.id,
			Process__c = 'ANG.ANNUAL.REVALIDATION',
			RecordTypeId = rtOscar,
			OwnerId = UserInfo.getUserId()
		);

		insert oscar;

		Case testcase = new Case (
			Account_Concerned__c = account.id,
			AccountId = account.id,
			OSCAR__c  = oscar.id,
			Reason1__c = 'Annual revalidation',
			RecordTypeId = rtCase,
			Subject = 'Annual revalidation - GoStandard - test',
			Type = 'Case',
			Type_of_customer__c = 'IATA Travel Agent',
			OwnerId = UserInfo.getUserId(),
			Region__c = 'Africa & Middle East'
		);

		insert testcase;
		Id auxId = Ams_Utils.getRegionalQueue(testcase);
        testcase.Region__c = 'Africa & Middle East';
		auxId = Ams_Utils.getRegionalQueue(testcase);
        testcase.Region__c = 'Americas';
		auxId = Ams_Utils.getRegionalQueue(testcase);
        testcase.Region__c = 'Asia & Pacific';
		auxId = Ams_Utils.getRegionalQueue(testcase);
        testcase.Region__c = 'China & North Asia';
		auxId = Ams_Utils.getRegionalQueue(testcase);
        testcase.Region__c = 'Europe';
		auxId = Ams_Utils.getRegionalQueue(testcase);

		Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
		System.currentPageReference().getParameters().put('caseId', testcase.id);

		ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();

		ISSP_ANG_ANNUAL_REVALIDATION.setCaseVisibleInPortal(testcase);

		String aux = ISSP_ANG_ANNUAL_REVALIDATION.CONFIRMED_ICON;
		aux = ctrl.step1GoToNumber;
		aux = ctrl.tree;
		aux = ctrl.caseId;
		aux = ctrl.legalstatusAfterChange;
		Boolean auxFlag = ctrl.isAddCompanyModal;

		ctrl.updateDetails();

		ctrl.currentAccount.fw.newform.Notify_Change_Legal_Details__c = true;
		ctrl.currentAccount.fw.newform.Account_Name__c = 'name';
		ctrl.currentAccount.fw.newform.Trade_Name__c = 'trade name';
		ctrl.currentAccount.fw.newform.Confirm_Location_Details_are_correct__c = true;
		ctrl.currentAccount.fw.newform.Confirm_Ownership_details_are_correct__c = true;
		ctrl.currentAccount.fw.newForm.Have_any_having_authorization_to_act__c = 'No';
		ctrl.currentAccount.fw.newForm.Will_the_change_of_ownership_cause__c = 'No';
		ctrl.currentAccount.fw.newForm.ISSP_AMS_Trade_Reg_No__c = '123';
		ctrl.currentAccount.fw.newForm.ISSP_AMS_Date_Registration_granted__c = system.today();
		ctrl.currentAccount.fw.newForm.ISSP_AMS_License_No__c = '123';
		ctrl.currentAccount.fw.newForm.ISSP_AMS_Date_license_granted__c = system.today();
		ctrl.currentAccount.fw.newForm.Effective_Date_Of_Change__c = system.today();

		ctrl.confirmUpdate();

		ctrl.currentAccount.status = 'UC';

		ctrl.discardDetails();

		ctrl.currentIataCode = '12345678';
		ctrl.loadIataCode();
		ctrl.currentIataCode = '87654321';
		ctrl.loadIataCode();

		ISSP_ANG_ANNUAL_REV_SUBMIT_REPORT_HELPER submitHelper = ctrl.submitHelper;

		String strListNotStarted = submitHelper.strListNotStarted;
		String strListUpdateInProgress = submitHelper.strListUpdateInProgress;
		String strListDetailsConfirmed = submitHelper.strListDetailsConfirmed;
		String strListUpdateCompleted = submitHelper.strListUpdateCompleted;

		ctrl = null;

		Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
		System.currentPageReference().getParameters().put('caseId', testcase.id);
		System.currentPageReference().getParameters().put('step', '2');

		ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();

		Test.startTest();
		ctrl.submitForm();
		Test.stopTest();

		String statusDesc = ctrl.currentAccount.statusDesc;

		ctrl.currentAccount.fw.newForm.status__c = ISSP_ANG_ANNUAL_REVALIDATION.FORM_STATUS_COMPLETED;

		ctrl.setIataCodesOkNotOk(oscar);

		ctrl.iataCodesConfirmed.add('123');

		ctrl.getIcon('123');

		ctrl.iataCodesOk.add('456');
		ctrl.getStatus('456');
		ctrl.getStatus('123');

		ctrl.getMode('dfa');

	}

	@isTest
	static void test6() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', 
                                    Region__c = 'Europe', ANG_Enable_NewGen__c = true, Informatica_Value__c = 'test');
		insert country;

        Account account = ISSP_ObjectFactory.createNewAccount();
        account.BillingCity = 'test';
        account.Name = 'test';
        account.sector__c = Ams_Utils.SECTOR_PASSENGER;
        account.Location_Type__c = AMS_Utils.HE;
        account.RecordTypeId = rtAgency ;
        account.IATACode__c = '12345678';
		account.status__c = Ams_Utils.ACC_S9_APPROVED;
		account.IATA_ISO_Country__c = country.Id;
		account.Location_Class__c = 'P';

		insert account;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test';
        child.Name = 'test child';
        child.sector__c = Ams_Utils.SECTOR_PASSENGER;
        child.Location_Type__c = AMS_Utils.AE;
        child.RecordTypeId = rtAgency ;
        child.IATACode__c = '87654321';
		child.status__c = Ams_Utils.ACC_S9_APPROVED;
		child.parentId = account.id;
		child.Top_Parent__c = account.id;
		child.IATA_ISO_Country__c = country.Id;
		child.Location_Class__c = 'P';

		insert child;

		AMS_Agencies_Hierarchy__c hier = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');

		insert hier;

		AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Hierarchy__c = hier.Id, Parent_Account__c = account.Id, Child_Account__c = child.Id, HO_Flag__c = 'true', Is_Newgen_Relation__c = true);

		insert rel;

		AMS_OSCAR__c oscar = New AMS_OSCAR__c (
			Account__c = account.id,
			Process__c = 'ANG.ANNUAL.REVALIDATION',
			RecordTypeId = rtOscar
		);

		insert oscar;

		Case testcase = new Case (
			Account_Concerned__c = account.id,
			AccountId = account.id,
			OSCAR__c  = oscar.id,
			Reason1__c = 'Annual revalidation',
			RecordTypeId = rtCase,
			Subject = 'Annual revalidation - GoStandard - test',
			Type = 'Case',
			Type_of_customer__c = 'IATA Travel Agent'
		);

		insert testcase;

		Test.startTest();

		Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
		System.currentPageReference().getParameters().put('caseId', testcase.id);

		ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();

		ctrl.contactType = 'Company';

		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = 'none';
		ctrl.currentAccount.newContact.First_name__c = 'a';
		ctrl.currentAccount.newContact.Last_name__c = 'a';
		ctrl.currentAccount.newContact.AddressStreet__c = 'a';
		ctrl.currentAccount.newContact.AddressCity__c = 'a';
		ctrl.currentAccount.newContact.AddressPostcode__c = 'a';
		ctrl.currentAccount.newContact.Job_title__c = 'a';
		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = '2';
		ctrl.currentAccount.newContact.Prev_Job1_Employer__c = null;
		ctrl.currentAccount.newContact.Prev_Job1_Position__c = null;
		ctrl.currentAccount.newContact.Prev_Job1_Address__c = null;
		ctrl.currentAccount.newContact.Prev_Job2_Employer__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job2_Position__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job2_Address__c = 'a';
		ctrl.currentAccount.newContact.Registration_number__c = '321';
		ctrl.currentAccount.newContact.Name = 'aaa';
		ctrl.currentAccount.newContact.Financial_interest__c = 10;
		ctrl.currentAccount.newContact.Prev_Job1_Position__c = '111';
		ctrl.currentAccount.newContact.Prev_Job1_From__c = null;
		ctrl.currentAccount.newContact.Prev_Job1_Address__c = '111';

		ctrl.createAgencyContact();

		ctrl.contactType = 'Company';

		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = 'none';
		ctrl.currentAccount.newContact.First_name__c = 'a';
		ctrl.currentAccount.newContact.Last_name__c = 'a';
		ctrl.currentAccount.newContact.AddressStreet__c = 'a';
		ctrl.currentAccount.newContact.AddressCity__c = 'a';
		ctrl.currentAccount.newContact.AddressPostcode__c = 'a';
		ctrl.currentAccount.newContact.Job_title__c = 'a';
		ctrl.currentAccount.newContact.Agencies_prev_worked_for__c = '2';
		ctrl.currentAccount.newContact.Prev_Job1_Employer__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job1_Position__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job1_Address__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job2_Employer__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job2_Position__c = 'a';
		ctrl.currentAccount.newContact.Prev_Job2_Address__c = 'a';
		ctrl.currentAccount.newContact.Registration_number__c = '321';
		ctrl.currentAccount.newContact.Name = 'aaa';
		ctrl.currentAccount.newContact.Financial_interest__c = 10;
		ctrl.currentAccount.newContact.Prev_Job1_Position__c = '111';
		ctrl.currentAccount.newContact.Prev_Job1_From__c = system.today();
		ctrl.currentAccount.newContact.Prev_Job1_Address__c = '111';

		ctrl.createAgencyContact();

		ctrl.currentAccount.newContact.Prev_Job2_Position__c = null;
		ctrl.currentAccount.newContact.Prev_Job2_Address__c = null;
		ctrl.currentAccount.newContact.Prev_Job2_employer__c = null;

		ctrl.createAgencyContact();

		ctrl.currentAccount.newContact.Prev_Job2_Position__c = '111';
		ctrl.currentAccount.newContact.Prev_Job2_From__c = system.today();
		ctrl.currentAccount.newContact.Prev_Job2_Address__c = '111';
		ctrl.currentAccount.newContact.Prev_Job2_employer__c = '111';

		ctrl.createAgencyContact();

		ISSP_ANG_ANNUAL_REV_UPDATE upd = new ISSP_ANG_ANNUAL_REV_UPDATE();

		System.assert(upd.countryInfoByCountryNameMapString == '\'\'');
		System.assert(upd.countryList.size() > 0);
		System.assert(upd.countryInfoByCountryNameMapString.startsWith('{'));


		Test.stopTest();

	}

}