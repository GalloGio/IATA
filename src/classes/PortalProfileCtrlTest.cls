@IsTest
public with sharing class PortalProfileCtrlTest {

	public static Account MyAirline;
	public static List<Account> Airlines;
	public static List<Contact> Contacts;
	public static User portalUser;


	@testSetup static void setup() {
		Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		MyAirline = new Account(
				RecordTypeId = rtHQ,
				Name='MyAirline',
				ACLI_Status__c = 'Active Company',
				MITA_Member__c = true,
				BIETA_Member__c = true,
				Airline_designator__c = 'AA',
				IATACode__c = '123',
				Airline_Prefix__c = '456');
		insert MyAirline;

		Contact newCon = ISSP_ObjectFactory.createNewContact();
		newCon.AccountId = MyAirline.Id;
		newCon.Email='testemail1@csp.testclass';
		newCon.User_Portal_Status__c = 'Approved Admin';
		insert newCon;

		User newUser = ISSP_ObjectFactory.createPortalUser(newCon);


		ID_Card__c idc= new ID_Card__c();
		idc.recordtypeid= RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');
		idc.Name_on_ID_Card__c='test card 1';
		idc.related_contact__C=newCon.id;
		idc.ver_number__c='123123';
		idc.Valid_From_Date__c=system.today().addDays(-200);
		idc.valid_to_Date__C=system.today().addDays(200);

		insert idc;

	}

	@IsTest
	static void testProfileInfo(){
		Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		MyAirline = new Account(
			RecordTypeId = rtHQ,
			Name='MyAirline',
			ACLI_Status__c = 'Active Company',
			MITA_Member__c = true,
			BIETA_Member__c = true,
			Airline_designator__c = 'AA',
			IATACode__c = '123',
				Airline_Prefix__c = '456',
				Sector__c = 'Travel Agent',
				Category__c = AMS_Utils.CATEGORY_DOMESTIC_AGENT);
		insert MyAirline;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = MyAirline.Id;
		con.Email='contact@MyAirline.com';
		con.ID_Card_Holder__c=true;
		insert con;

		User portalUser = ISSP_ObjectFactory.createPortalUser(con);


		System.runAs(portalUser){
			Account airline = PortalProfileCtrl.getCompanyInfo(MyAirline.Id);

			Boolean canEdit = PortalProfileCtrl.canEditBasics();

			System.assert (canEdit == false);

			System.assert (airline.Id == MyAirline.Id);

			List<PortalProfileCtrl.CardWrapper> contactWrappers = PortalProfileCtrl.getFieldsMap('MyProfile');
			System.assert (!contactWrappers.isEmpty());

			List<PortalProfileCtrl.CardWrapper> companyWrappers = PortalProfileCtrl.getFieldsMap('CompanyProfile');
			System.assert (!companyWrappers.isEmpty());

			List<PortalProfileCtrl.CardWrapper> contactAccWrappers = PortalProfileCtrl.getFieldsMap('MyProfileAccFields');
			System.assert (!contactAccWrappers.isEmpty());

		}
	}

	@IsTest
	static void testGetFilteredProfileResultsPage(){

		PortalSearchFilterWrapper testPSFW = new PortalSearchFilterWrapper();

		testPSFW.searchText = 'MyAirline';
		testPSFW.profileComponent =  new PortalSearchFilterWrapper.profileComponent();
		testPSFW.profileComponent.show = true;
		testPSFW.profileComponent.loading = false;
		testPSFW.profileComponent.highlight = true;
		testPSFW.profileComponent.profileStatusFilter = '';
		testPSFW.profileComponent.profileTypeFilter = '';
		testPSFW.profileComponent.profileCountryFilter = '';

		System.debug('testPSFW: ' + testPSFW);

		User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		System.runAs(usr){
			String serialized = JSON.serialize(testPSFW);
			CSP_Utils.PagedResult testPagedResult = (CSP_Utils.PagedResult) PortalProfileCtrl.getFilteredProfileResultsPage(serialized);
			System.debug('testPagedResult: ' + testPagedResult);
			System.assert (testPagedResult.recordsString != null);

			String serialized2 = JSON.serialize(testPSFW);
			testPSFW.profileComponent.profileStatusFilter = 'Approved Admin';
			CSP_Utils.PagedResult testPagedResult1 = PortalProfileCtrl.getFilteredProfileResultsPage(serialized2);
			System.assert (testPagedResult1.recordsString != null);

			String serialized3 = JSON.serialize(testPSFW);
			testPSFW.profileComponent.profileTypeFilter = 'Contact';
			CSP_Utils.PagedResult testPagedResult2 = PortalProfileCtrl.getFilteredProfileResultsPage(serialized3);
			System.assert (testPagedResult2.recordsString != null);

			String serialized4 = JSON.serialize(testPSFW);
			testPSFW.profileComponent.profileCountryFilter = 'Portugal';
			CSP_Utils.PagedResult testPagedResult3 = PortalProfileCtrl.getFilteredProfileResultsPage(serialized4);
			System.assert (testPagedResult3.recordsString != null);
		}

	}
	@IsTest
	static void testBranchesAndContactsTabsInfo(){

		User usr = [SELECT Id,ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Contact con = [SELECT Id,AccountId FROM Contact WHERE Id = :usr.ContactId];
		Account acc = [SELECT Id,IsPartner,Name FROM Account WHERE Id = :con.AccountId];
		System.runAs(usr){

			Map<String, List<PortalProfileCtrl.FieldWrapper>> branchFields = PortalProfileCtrl.getBranchesListFields();
			Map<String, List<PortalProfileCtrl.FieldWrapper>> contactFields = PortalProfileCtrl.getContactsListFields();
			List<PortalProfileCtrl.FieldWrapper> createContactFields = PortalProfileCtrl.getContactFieldsToInsert();

			PortalProfileCtrl.CompanyInformationContactsFiltersWrapper cfw = new PortalProfileCtrl.CompanyInformationContactsFiltersWrapper();
			cfw.searchInput = '';
			cfw.firstLetter = 'All';
			cfw.sortField = 'Name';
			cfw.sortDirection = 'ASC';
			CSP_Utils.PagedResult contactsResults = PortalProfileCtrl.searchForCompanyContacts(JSON.serialize(cfw),'0');
			String searchContactesResults = contactsResults.recordsString;
			System.debug('searchContactesResults: ' + searchContactesResults);

			PortalProfileCtrl.CompanyInformationBranchesFiltersWrapper cbfw = new PortalProfileCtrl.CompanyInformationBranchesFiltersWrapper();
			cbfw.searchInput = '';
			cbfw.firstLetter = 'All';
			cbfw.sortField = 'TradeName__c';
			cbfw.sortDirection = 'ASC';
			CSP_Utils.PagedResult branchesResults = PortalProfileCtrl.searchForCompanyBranches(JSON.serialize(cbfw),'0');
			List<sObject> searchBranchesResults = branchesResults.records;

			cbfw.searchInput = acc.Name + '';
			CSP_Utils.PagedResult branchesResultsByName = PortalProfileCtrl.searchForCompanyBranches(JSON.serialize(cbfw),'0');
			List<sObject> searchBranchesResultsByName = branchesResults.records;

		}
	}

	@IsTest
	static void testPortalProfileOtherMethods(){

		User usr = [SELECT Id,ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		Contact con = [SELECT Id,AccountId FROM Contact WHERE Id = :usr.ContactId];
		Account acc = [SELECT Id,IsPartner FROM Account WHERE Id = :con.AccountId];
		
		System.runAs(usr){

			Boolean hasAnnualRevalidation = PortalProfileCtrl.hasAnnualRevalidation();

			Boolean hasRevCases = PortalProfileCtrl.hasRevCases();

			Boolean checkCanEdit = PortalProfileCtrl.checkCanEdit();	

			String goToOldIFAPWithContact = PortalProfileCtrl.goToOldIFAP(true, usr.ContactId, 'TestContact');
			String goToOldIFAPWithoutContact = PortalProfileCtrl.goToOldIFAP(false, null, '');

			Boolean isAdminAndIATAAgencyAcct = PortalProfileCtrl.isAdminAndIATAAgencyAcct();

			String goToPrivacyPortal = PortalProfileCtrl.goToPrivacyPortal();

			List<Account_Domain__c> lstAccountDomains = PortalProfileCtrl.getAccountDomains(con.Id);
			
			Boolean isAccountDomain = PortalProfileCtrl.isAccountDomain();

			List<Account> getMapHierarchyAccountsWithContact = PortalProfileCtrl.getMapHierarchyAccounts(usr.ContactId);
			List<Account> getMapHierarchyAccountsWithoutContact = PortalProfileCtrl.getMapHierarchyAccounts(null);
		
			PortalProfileCtrl.relocateContact(acc,usr.ContactId);


			PortalProfileCtrl.ProfileWrapper portalProfileAux = new PortalProfileCtrl.ProfileWrapper(con.Id, 'ProfileName', 'Active', 'Some Country', 'Contact');
			PortalProfileCtrl.ProfileWrapper portalProfileAux2 = new PortalProfileCtrl.ProfileWrapper(acc.Id, 'ProfileName', 'Active', 'Some Country', 'Account');
			

			List<CSP_Utils.PickListWrapper> lsttypeOfProfilePortalCustomPicklist = PortalProfileCtrl.typeOfProfilePortalCustomPicklist();
			List<CSP_Utils.PickListWrapper> lstuserPortalStatusCustomPicklist = PortalProfileCtrl.userPortalStatusCustomPicklist();

		}
	}

	@IsTest
	static void testUserAccessManagementApprove(){

		User usr = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
		System.runAs(usr){
			PortalProfileCtrl.CompanyInformationContactsFiltersWrapper cfw = new PortalProfileCtrl.CompanyInformationContactsFiltersWrapper();
			cfw.searchInput = '';
			cfw.firstLetter = 'All';
			cfw.sortField = 'Name';
			cfw.sortDirection = 'ASC';
			CSP_Utils.PagedResult contactsResults = PortalProfileCtrl.searchForCompanyContacts(JSON.serialize(cfw),'0');
			String searchContactesResults = contactsResults.recordsString;

			List<PortalProfileCtrl.ContactWrapper> lstContacts = (List<PortalProfileCtrl.ContactWrapper>) JSON.deserialize(searchContactesResults, List<PortalProfileCtrl.ContactWrapper>.class);

			lstContacts[0].selected = true;
			ApexMessageHandling contactsToApprove = PortalProfileCtrl.approve(JSON.serialize(lstContacts), 'Approved Admin');
		}
	}

	@IsTest
	static void testUserAccessManagementInactiveWithApplications(){

		User usr = [SELECT Id,ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Portal_Applications__c serviceTest = new Portal_Applications__c (
			Name = 'serviceTest3',
			requestable__c=true,
			Agency__c = true,
			Hide_on_Homepage__c = false,
			Critical_Service__c = true
		);
		insert serviceTest;

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
			Portal_Application__c = serviceTest.id,
			Right__c = 'Access Granted',
			Contact__c = usr.ContactId
		);
		insert appRight;

		
		System.runAs(usr){
			PortalProfileCtrl.CompanyInformationContactsFiltersWrapper cfw = new PortalProfileCtrl.CompanyInformationContactsFiltersWrapper();
			cfw.searchInput = '';
			cfw.firstLetter = 'All';
			cfw.sortField = 'Name';
			cfw.sortDirection = 'ASC';
			CSP_Utils.PagedResult contactsResults = PortalProfileCtrl.searchForCompanyContacts(JSON.serialize(cfw),'0');
			String searchContactesResults = contactsResults.recordsString;

			List<PortalProfileCtrl.ContactWrapper> lstContacts = (List<PortalProfileCtrl.ContactWrapper>) JSON.deserialize(searchContactesResults, List<PortalProfileCtrl.ContactWrapper>.class);

			lstContacts[0].selected = true;
			ApexMessageHandling contactsToDeactivate = PortalProfileCtrl.inactivate(JSON.serialize(lstContacts), 'Retired');
		}
	}

	@IsTest static void testPortalGlobalSearch() {

		User testUser = [SELECT Id FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];

		Test.startTest();
		System.runAs(testUser) {
			CSP_Utils.PagedResult test = new CSP_Utils.PagedResult();

			PortalGlobalSearchCtrl.GlobalSearchWrapper testGSW = new PortalGlobalSearchCtrl.GlobalSearchWrapper('test','test','test','test','test');

			PortalSearchFilterWrapper.profileComponent profileCmp = new PortalSearchFilterWrapper.profileComponent();
			profileCmp.show = true;
			PortalSearchFilterWrapper filtersWrapper = new PortalSearchFilterWrapper();
			filtersWrapper.searchText = 'Test';
			filtersWrapper.profileComponent = profileCmp;

			test = PortalGlobalSearchCtrl.portalGlobalSearch(JSON.serialize(filtersWrapper), 'Profiles');
		}
		Test.stopTest();
	}
	
	@IsTest
	static void testGetPhotoFromAPI(){
		Amazon_Cred__c amc = new Amazon_Cred__c(Name = 'IdCard', Dev_Configuration__c = 'IdCardDev', Prod_Configuration__c = 'IdCardProd');
		insert amc;

		AWSKey__c awsk_dev = new AWSKey__c(Name = 'IdCardDev', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
		AWSKey__c awsk_prd = new AWSKey__c(Name = 'IdCardProd', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
		insert awsk_dev;
		insert awsk_prd;

		String photoName = 'CA12345.jpg';
		PortalProfileCtrl.getPhotoFromAPI(photoName);
	}

}