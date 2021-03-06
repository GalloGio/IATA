@isTest
private class ISSP_TIP_Home_Controller_Test {

	static User user = new User();
	static Account account;
	static Case newCase;
	static Partner_products__c prod = new Partner_products__c();
	static ISSP_TIP_Home_Controller controller;

	@TestSetup
	static void setRecords() {
		//create isocountry
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
				IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
				IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq', BSP_Country_free_text__c = 'tq',
				IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
		insert country;

		AMS_Settlement_System__c as1 = new AMS_Settlement_System__c(name = 'test1', BSP_Billing__c = 'tq');
		insert as1;

		//create account
		Account parent = ISSP_ObjectFactory.createNewAccount();
		parent.BillingCity = 'test';
		parent.Name = 'test';
		parent.sector__c = 'Travel Agent';
		parent.Location_Type__c = 'HO';
		//parent.RecordTypeId = TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID;
		parent.Account_Role__c = 'Payment Provider';
		parent.IATACode__c = '1000';
		parent.IATA_ISO_Country__c = country.id;
		parent.category__c = TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER;
		parent.Reason_for_creation__c = 'Other';
		parent.Comments_Reason_for_creation__c = 'comments';
		insert parent;

		//create account role
		Account_Role__c ar = new Account_Role__c();
		ar.Provider_Code__c = '1000';
		ar.Account__c = parent.id;
		ar.HQ_Location__c = country.Id;
		ar.recordtypeId=TIP_UTILS.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID;
		insert ar;

		Id externalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact_Roles__c', 'External');
		Contact_Roles__c contactRole = new Contact_Roles__c();
		contactRole.Name = 'Test User';
		contactRole.RecordTypeId = externalRecordTypeId;
		insert contactRole;

		//create partner product
		prod.Name = 'test prod';
		prod.PP_Payment_network__c = 'AX';
		prod.PP_Payment_Product_Code__c = 'aa';
		prod.PP_Form_of_payment__c = 'CC';
		prod.Provider__c = parent.id;
		prod.PP_Category__c = 'CONSUMER';
		prod.PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE';
		prod.PP_Pay_in_model__c = 'PREPAID';
		prod.PP_Accepted_transactions__c = 'PAYMENT';
		prod.PP_VAN_type__c = 'SINGLE_USE_VAN';
		prod.PP_Chargeback_airlines__c = 'N';
		prod.is_PCI_DSS_required__c = 'YES';
		prod.PP_Chargeback_airlines_duration__c = 1;
		prod.PP_Effective_from_Date__c = Date.newInstance(2019, 2, 2);
		prod.RecordTypeid = TIP_Utils.PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID;
		prod.Payment_Provider_Account_Role__c = ar.id;
		TIP_Utils.SyncFromAccountRole = false;
		insert prod;

		system.debug('##Account: ' + parent);
		//insert contact
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = parent.Id;
		con.Email = 'Test@test11.com';
		con.Salutation = 'Mr.';
		con.Title = 'Eng.';
		con.Phone = '213456789';
		insert con;

		Id functionalRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');

		//create account contact role
		Account_Contact_Role__c acr = new Account_Contact_Role__c();
		acr.Account__c = parent.id;
		acr.Account_Role__c = ar.id;
		acr.Contact_Roles__c = contactRole.Id;
		acr.RecordTypeId = functionalRecordTypeId;
		acr.Contact_Role__c = 'Primary Contact';
		acr.Contact__c = con.Id;
		acr.Service_Rendered__c = 'TIP';
		insert acr;

		user = ISSP_ObjectFactory.createPortalUser(con);
		con.OwnerId = user.Id;
		update con;

		System.debug('##newUser Id: ' + user.Id);
		con.OwnerId = user.Id;
		update con;

		system.debug('##HERE: ' + [select id, CaseArea__c, reason1__c, AccountId,RecordTypeid,Status from case]);
		Portal_Applications__c pa = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		pa.Name = TIP_Utils.PORTAL_SERVICE_NAME_TIP;
		insert pa;

		parent.Account_Role__c = 'Payment Provider';
		update parent;

		PortalServiceAccessTriggerHandler.privetTrigger = true;
		PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
		Portal_Application_Right__c appRight = new Portal_Application_Right__c (
			Right__c = 'Access Granted', Contact__c = user.ContactId, Portal_Application__c = pa.id);
		insert appRight;
	}

	private static void loadVars() {
		user = [SELECT Id, ContactId FROM User WHERE Contact.Email = 'Test@test11.com' ORDER BY CreatedDate DESC LIMIT 1];
		account = [
			SELECT Id, Name, IATA_ISO_Country__r.region__c, IATA_ISO_Country__r.Name
			FROM Account ORDER BY CreatedDate DESC LIMIT 1];

		prod = [SELECT Id FROM Partner_products__c ORDER BY CreatedDate DESC LIMIT 1];
		newCase = createCase();
	}

	private static Case createCase() {
		Case newCase = new Case();
		//create case
		newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
		newcase.Reason1__c = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT;
		newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS;
		newcase.Status = 'Open';
		newcase.Subject = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER + ' - ' + account.name;
		newCase.Description = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER;
		newcase.Region__c = account.IATA_ISO_Country__r.region__c;
		newcase.Origin = 'Portal';
		newcase.BSPCountry__c = account.IATA_ISO_Country__r.Name;
		newcase.Country_concerned_by_the_query__c = account.IATA_ISO_Country__r.Name;
		return newCase;
	}

	@isTest
	static void testGetCases() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}

		List<Case> cases = controller.getCases();
		System.assertEquals(1, cases.size());

		List<ISSP_TIP_Home_Controller.productWrapper> products = controller.products;
		System.assertEquals(1, products.size());
		controller.initActions();
		Test.stopTest();
	}

	@isTest
	static void testDraftProduct() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}

		controller.acceptedTransactionVal = new String[] {'Payment'} ;
		controller.paymentGuaranteeVal = new String[] {'COMMERCIAL_DISPUTE'};
		System.runAs(user) {
			controller.NewEditProduct();
			controller.saveDraft();
		}
		Test.stopTest();
	}

	@isTest
	static void testEditProduct() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}

		List<selectOption> t = controller.acceptedTransactionsOptList;
		List<selectOption> tt = controller.paymentGuaranteeOptList;

		System.currentPageReference().getParameters().put('prodId', prod.id);
		controller.NewEditProduct();
		controller.cancelNewEditProd();
		Test.stopTest();
	}

	@isTest
	static void testbinRanges() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}

		controller.NewEditProduct();

		ID prodid = [Select id from Partner_products__c limit 1].id;
		TIP_BIN_Range__c br = new TIP_BIN_Range__c (TIP_Payment_Provider_Product__c = prodid, recordTypeId = TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID, TIP_Status__c = 'Draft',
				TIP_Range_Start__c = '111' , TIP_Range_End__c = '222');

		insert br;

		TIP_BIN_Range__c br1 = new TIP_BIN_Range__c (TIP_Payment_Provider_Product__c = prodid, recordTypeId = TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID, TIP_Status__c = 'Draft',
				TIP_Range_Start__c = '333' , TIP_Range_End__c = '999');
		insert br1;

		controller.binRangeList = new list<ISSP_TIP_Home_Controller.BinRangeRec>();

		//new bin range
		controller.newEditBinRange();
		controller.selectedBinRange.binRange.TIP_Range_Start__c = '111';
		controller.selectedBinRange.binRange.TIP_Range_End__c = '222';
		controller.addUpdateBinRange();

		system.assertEquals(1, controller.binRangeList.size());

		//Edit
		System.currentPageReference().getParameters().put('binRangeRecPos', '0');
		controller.newEditBinRange();

		controller.changePaymentNetwork();

		controller.cancelNewEditProd();

		System.currentPageReference().getParameters().put('binRangeRecPos', '0');
		controller.deleteBinRange();
		system.assertEquals(0, controller.binRangeList.size());
		Test.stopTest();
	}

	@isTest
	static void testCreateNewContact() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
			controller.getISOCountry();
			controller.setContactToEdit();
			controller.newContact.lastName = 'testLastName';
			controller.newContact.Email = 'Test@test11.com';
			controller.createContact();

			system.assertEquals(1, [select id from contact].size()); //fail to create due duplicate email

			controller.newContact.Email = 'test@test1233.com';
			controller.createContact();//create email
			system.assertEquals(2, [select id from contact].size());

		}
		Test.stopTest();
	}

	//------------------------------test for enrolment methods-------------------
	@isTest
	static void testEditContact() {

		loadVars();
	
		Test.startTest();
		System.runAs(user){
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			Apexpages.currentPage().getParameters().put('contactIDToEdit',[select id from contact limit 1].id);
			controller = new ISSP_TIP_Home_Controller();
			controller.startEnrolmentAccount();
			controller.setContactToEdit();
			controller.newContact.lastName = 'testLastName';
			controller.newContact.Email = 'test@test333.com';
			controller.createContact();//create email
			system.assertEquals(1, [select id from contact].size());

		}
		Test.stopTest();
	}

	@isTest
	static void testsaveAccountEnrolmentAsDraft() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
			controller.startEnrolmentAccount();
			controller.saveAccountEnrolmentAsDraft();
			system.assertEquals(2, [select id from case].size());
		}
		Test.stopTest();
	}

	@isTest
	static void testsubmitAccountEnrolmentToIATA() {

		loadVars();

		Test.startTest();
		System.runAs(user){
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();

			controller.startEnrolmentAccount();
			//legal name missing
			controller.account.Name = '';
			controller.submitAccountEnrolmentToIATA();
			controller.account.Name = 'acc1';

			//Office Phone missing
			controller.account.PhoneNational__c = null;
			controller.submitAccountEnrolmentToIATA();
			controller.account.PhoneNational__c = '123123123';

			//Office email missing
			controller.account.Email__c = null;
			controller.submitAccountEnrolmentToIATA();
			controller.account.Email__c = 'asdas@asd.pt';

			//BillingCity missing
			controller.account.BillingStreet = null;
			controller.submitAccountEnrolmentToIATA();
			controller.account.BillingStreet = 'street test';

			//Location of Headquarter missing
			controller.account.BillingCity = null;
			controller.submitAccountEnrolmentToIATA();
			controller.account.BillingCity = 'city test';

			//Location of Headquarter missing
			controller.TheAccountRole.HQ_Location__c = null;
			controller.submitAccountEnrolmentToIATA();
			controller.TheAccountRole.HQ_Location__c = [select id from IATA_ISO_Country__c limit 1].id;

			//Primary contact missing
			controller.submitAccountEnrolmentToIATA();

			Apexpages.currentPage().getParameters().put('contactIDToEdit',controller.contactList.get(0).id);
			controller.updateRadioButtonStatus();

			controller.AccountContactRoleList.get(0).Contact_Role__c = 'Primary Contact';
			controller.submitAccountEnrolmentToIATA();
		}
		Test.stopTest();
	}

	@isTest
	static void testsecurityCheck() {

		loadVars();

		System.runAs(user) {
			Test.startTest();
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			System.currentPageReference().getParameters().put('caseId', newCase.id);
			controller = new ISSP_TIP_Home_Controller();
			controller.updateCase();
			upsert controller.newCase;
			controller.securityCheckForEnrolmentPage();
			Test.stopTest();
		}
	}

	@isTest
	static void testCountryConfigs() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}
		controller.NewEditProduct();

		//new prod config
		controller.newEditCountryConfig();
		controller.selectedProvProdConf.action = 'N';
		controller.selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c = '1';
		controller.selectedProvProdConf.prodConfig.Network_Fee__c = '3';
		controller.selectProvConfigCountriesList = new list<string>();
		system.debug('##list: ' + controller.bspCountrList);
		controller.selectProvConfigCountriesList.add(controller.bspCountrList.get(0).getValue());
		controller.addUpdateCountryConfig();

		system.assertEquals(1, controller.provProdConfList.size());

		//Edit
		System.currentPageReference().getParameters().put('countryConfigPos', '0');
		controller.newEditCountryConfig();

		System.currentPageReference().getParameters().put('countryConfigPos', '0');
		controller.deleteCountryConfig();
		system.assertEquals(0, controller.provProdConfList.size());

		controller.NewEditProduct();

		//new prod config
		System.currentPageReference().getParameters().remove('countryConfigPos');
		controller.newEditCountryConfig();
		controller.selectedProvProdConf.action = 'N';
		controller.selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c = '1';
		controller.selectedProvProdConf.prodConfig.Network_Fee__c = '3';
		controller.selectProvConfigCountriesList = new list<string>();
		controller.selectProvConfigCountriesList.add(controller.bspCountrList.get(0).getValue());
		controller.addUpdateCountryConfig();
		controller.provProdConfList.get(0).isSelected = true;
		system.assertEquals(1, controller.provProdConfList.size());
		controller.deleteMassCountryConfig();
		system.assertEquals(0, controller.provProdConfList.size());

		Test.stopTest();
	}

	@isTest
	static void testsubmitProduct() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}

		TIP_Payment_Network_Config__c paymentNetworkConfig = new TIP_Payment_Network_Config__c(Name = 'Amex Config', Maximum_Length__c = 15,
				Payment_Network__c = 'AX');
		insert paymentNetworkConfig;


		ID prodid = [Select id from Partner_products__c limit 1].id;
		System.currentPageReference().getParameters().put('prodId', prodid);
		controller.NewEditProduct();


		controller.acceptedTransactionVal = new String[] {'Payment'} ;
		controller.paymentGuaranteeVal = new String[] {'COMMERCIAL_DISPUTE'};
		controller.submitProduct();



		system.assertEquals(1, Apexpages.getMessages().size());

		controller.newpp.PP_Settlement_terms__c = '2';
		controller.newpp.is_PCI_DSS_required__c = 'YES';
		controller.newpp.PP_Chargeback_airlines__c = 'N';
		controller.newpp.PP_Pay_in_model__c = 'PREPAID';
		controller.newpp.PP_Category__c = 'CONSUMER';
		controller.newpp.PP_Payment_Product_Network_type__c = 'Open Loop';

		controller.submitProduct();


		//new bin range
		controller.newEditBinRange();
		controller.selectedBinRange.binRange.TIP_Range_Start__c = '111';
		controller.selectedBinRange.binRange.TIP_Range_End__c = '222';
		controller.addUpdateBinRange();

		controller.submitProduct();

		System.currentPageReference().getParameters().put('binRangeRecPos', '0');
		controller.newEditBinRange();
		controller.selectedBinRange.binRange.TIP_Range_Start__c = '111111111111111';
		controller.selectedBinRange.binRange.TIP_Range_End__c = '222222222222222';
		controller.addUpdateBinRange();
		system.debug('##bin ranges: ' + controller.binRangeList);
		controller.submitProduct();

		controller.newEditCountryConfig();
		controller.selectedProvProdConf.action = 'N';
		controller.selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c = '1';
		controller.selectedProvProdConf.prodConfig.Network_Fee__c = '3';
		controller.selectProvConfigCountriesList = new list<string>();
		system.debug('##list: ' + controller.bspCountrList);
		controller.selectProvConfigCountriesList.add(controller.bspCountrList.get(0).getValue());
		controller.addUpdateCountryConfig();
		system.assertEquals(1, controller.provProdConfList.size());

		controller.submitProduct();
		Test.stopTest();
	}

	@isTest
	static void testAcceptTermsAndConditions() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}

		controller.rejectTerms();
		Portal_Application_Right__c ar = [SELECT Terms_Acceptance__c FROM Portal_Application_Right__c LIMIT 1];
		System.assertEquals(ar.Terms_Acceptance__c, false);

		controller.acceptTerms();
		system.assertEquals(1, Apexpages.getMessages().size());

		controller.acceptedTaC = true;
		controller.acceptTerms();
		ar = [SELECT Terms_Acceptance__c FROM Portal_Application_Right__c LIMIT 1];
		System.assertEquals(ar.Terms_Acceptance__c, true);
		Test.stopTest();
	}

	@isTest
	static void testTerminateProduct() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}

		ID prodid = [Select id from Partner_products__c limit 1].id;
		System.currentPageReference().getParameters().put('prodId', prod.id);
		controller.NewEditProduct();
		controller.submitProduct();
		controller.terminateProduct();
		controller.terminationReason = 'Termination Reason';
		controller.terminationDate = string.valueof(Date.today());

		controller.submitProductTerminationRequest();

		System.assertEquals('Product Termination Request - test / test prod', controller.newcase.Subject);
		Test.stopTest();
	}

	@isTest
	static void testSubmitVoluntaryRelinquishment() {

		loadVars();

		Test.startTest();
		System.runAs(user) {
			insert newCase;
			PageReference pageRef = Page.ISSP_TIP_Home;
			Test.setCurrentPage(pageRef);
			controller = new ISSP_TIP_Home_Controller();
		}
		controller.voluntaryReliqReason = 'Retirement';
		controller.voluntaryReliqDate = string.valueof(Date.today());
		controller.submitVoluntaryRelinquishmentReq();

		System.assertEquals('ATM Provide Account Closure - test', controller.newcase.Subject);
		Test.stopTest();
	}

}
