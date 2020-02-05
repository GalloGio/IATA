@isTest
private class ANG_AccountHierarchySelectionTest {

	private static void loadCredentials() {
		EF_AttachmentListController.runningForEF = false;

				Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
				Amazon_Cred__c GenericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
				Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
				List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
				creds.add(Amazon_Cred);
				creds.add(GenericAttach);
				creds.add(recycleBin);
				insert creds;


				list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
						new AWSKey__c(
								name = 'adevconf',
								Key__c = 'asd',
								Secret__c = 'asd',
								IAS_configuration_name__c = 'asdas',
								IAS_Access_Point__c = 'asd',
								Bucket__c = 'asd',
								AWS_ENDPOINT_URL__c = 'asd')
				};
				insert AWS_KEYs;
		}

	@testSetup static void createData() {
		// call data creating classes and other setup
		// data created here must be queried in order
		// to be accessed on test methods

		IATA_ISO_Country__c ctry 	  = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c chinaCtry = new IATA_ISO_Country__c (Name='	China (People\'s Republic of)',ISO_Code__c='CN', ANG_Enable_NewGen__c = true, Enable_NewGen_Pilot__c = true);

		insert new List<IATA_ISO_Country__c>{ctry, chinaCtry};

		IATA_ISO_State__c stt 	   = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
		IATA_ISO_State__c anhuiStt = new IATA_ISO_State__c(Name= 'ANHUI PROVINCE', ISO_Code__c = 'CN12', IATA_ISO_Country__c = chinaCtry.Id);

		insert new List<IATA_ISO_State__c>{stt, anhuiStt};

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account HE = new Account();
		HE.Name = 'Main HE Account HE';
		HE.Sector__c = 'Travel Agent';
		HE.IATACode__c = '12345678';
		HE.Category__c = 'IATA Passenger Sales Agent';
		HE.Location_Class__c = 'P';
		HE.Location_Type__c = AMS_Utils.HE;
		HE.ANG_Accreditation_Model__c = 'Cashless';
		HE.IATA_ISO_Country__c = ctry.Id;
		HE.ANG_IEP_HE_AccntNum__c = '1232132323';
		HE.ANG_IEP_Status__c = 'Suspended' ;
		HE.ANG_HE_CashCondition__c = true;
		HE.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		HE.ANG_HE_RiskStatus__c = 'Not Applicable';
		HE.RecordTypeId = accountAgencyRT;

		Account chinaHE = new Account();

		chinaHE.Name = 'Main China HE Account';
		chinaHE.Sector__c = 'Travel Agent';
		chinaHE.IATACode__c = '00981111';
		chinaHE.Category__c = 'IATA Passenger Sales Agent';
		chinaHE.Location_Class__c = 'D';
		chinaHE.Location_Type__c = AMS_Utils.HE;
		chinaHE.ANG_Accreditation_Model__c = 'Cashless';
		chinaHE.IATA_ISO_Country__c = chinaCtry.Id;
		chinaHE.ANG_IEP_HE_AccntNum__c = '1232132323';
		chinaHE.ANG_IEP_Status__c = 'Suspended' ;
		chinaHE.ANG_HE_CashCondition__c = true;
		chinaHE.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		chinaHE.ANG_HE_RiskStatus__c = 'Not Applicable';
		chinaHE.RecordTypeId = accountAgencyRT;

		insert new List<Account>{HE, chinaHE};

		Account AE = new Account(IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' ,RecordTypeId = accountAgencyRT, IATACode__c='12345671',Name='Account AE1 H1',Short_Name__c='Account AE1 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = HE.Id, Status__c = AMS_Utils.ACC_S9_APPROVED);

		Account chinaAE = new Account();
		chinaAE.IATA_ISO_Country__c = chinaCtry.id;
		chinaAE.ANG_IEP_Status__c = null;
		chinaAE.ANG_Accreditation_Model__c = 'Cashless';
		chinaAE.RecordTypeId = accountAgencyRT;
		chinaAE.IATACode__c='12345671';
		chinaAE.Name='Account China AE1 H1';
		chinaAE.Short_Name__c='Account China AE1 H1';
		chinaAE.Category__c = 'IATA Passenger Sales Agent';
		chinaAE.Location_Class__c = 'P';
		chinaAE.Location_Type__c = 'AE';
		chinaAE.ParentId = chinaHE.Id;

		Account chinaAE2 = new Account();
		chinaAE2.IATA_ISO_Country__c = chinaCtry.id;
		chinaAE2.ANG_IEP_Status__c = null;
		chinaAE2.ANG_Accreditation_Model__c = 'Cashless';
		chinaAE2.RecordTypeId = accountAgencyRT;
		chinaAE2.IATACode__c='12345674';
		chinaAE2.Name='Account China AE2 H1';
		chinaAE2.Short_Name__c='Account China AE2 H1';
		chinaAE2.Category__c = 'IATA Passenger Sales Agent';
		chinaAE2.Location_Class__c = 'D';
		chinaAE2.Location_Type__c = 'AE';
		chinaAE2.ParentId = chinaHE.Id;

		insert new List<Account>{AE, chinaAE, chinaAE2};

		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy (old)');
		AMS_Agencies_Hierarchy__c chinaNHC = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'China Newgen Hierarchy');

		insert new List<AMS_Agencies_Hierarchy__c>{h, chinaNHC};

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = AE.Id , Parent_Account__c = HE.Id, Hierarchy__c = h.Id);

		AMS_Agencies_relationhip__c aRelChinaAe1 = new AMS_Agencies_relationhip__c();

		aRelChinaAe1.Is_Newgen_Relation__c = true;
		aRelChinaAe1.Child_Account__c = chinaAE2.Id;
		aRelChinaAe1.Parent_Account__c = chinaHE.Id;
		aRelChinaAe1.Hierarchy__c = chinaNHC.Id;

		AMS_Agencies_relationhip__c aRelChinaAe2 = new AMS_Agencies_relationhip__c();

		aRelChinaAe2.Is_Newgen_Relation__c = true;
		aRelChinaAe2.Child_Account__c = chinaAE.Id;
		aRelChinaAe2.Parent_Account__c = chinaHE.Id;
		aRelChinaAe2.Hierarchy__c = chinaNHC.Id;

		insert new List<AMS_Agencies_relationhip__c>{r1, aRelChinaAe1, aRelChinaAe2};

		Contact co1 = new Contact(AccountId = AE.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);

		Contact contactChina = new Contact();
		contactChina.AccountId = chinaHE.Id;
		contactChina.Firstname = 'Bob';
		contactChina.Lastname = 'Yung';
		contactChina.Phone = '921111333';
		contactChina.MobilePhone = '911111331';
		contactChina.Email = 'test@china.com';

		insert new List<Contact>{co1, contactChina};

		//Agency changes configuration settings
		List<ANG_AgencyChangesConfig__c> customsettings = new List<ANG_AgencyChangesConfig__c>();
		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeName', TC_Location_type__c = false,
							 TC_Legal_status__c = false, TC_Location__c = false,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = true, TC_Ownership__c = false, TC_Hierarchy__c = false,
							 TC_Major_Shareholding__c = false,  TC_VMFR__c = false,
							 TCA_Sanity_check__c = 'CON', TCA_Application_withdrawal__c = 'CWD',Valid_Accreditation_Models__c='ALL'));
		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeLocationType', TC_Location_type__c = true,
							 TC_Legal_status__c = false, TC_Location__c = false,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
							 TC_Major_Shareholding__c = false, TC_VMFR__c = false,
							 TCA_Sanity_check__c = 'CAD', TCA_Application_withdrawal__c = 'CWD',Valid_Accreditation_Models__c='ALL'));
		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeLocation', TC_Location_type__c = false,
							 TC_Legal_status__c = false, TC_Location__c = true,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
							 TC_Major_Shareholding__c = false, TC_VMFR__c = false,
							 TCA_Sanity_check__c = 'CHL', TCA_Application_withdrawal__c = 'CWD',Valid_Accreditation_Models__c='ALL'));
		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeOwnership', TC_Location_type__c = false,
							 TC_Legal_status__c = false, TC_Location__c = false,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = true, TC_Hierarchy__c = false,
							 TC_Major_Shareholding__c = false, TC_VMFR__c = false,
							 TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CWD',Valid_Accreditation_Models__c='ALL'));
		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeLegal', TC_Location_type__c = false,
							 TC_Legal_status__c = true, TC_Location__c = false,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
							 TC_Major_Shareholding__c = false, TC_VMFR__c = false,
							 TCA_Sanity_check__c = 'CHS', TCA_Application_withdrawal__c = 'CWD',Valid_Accreditation_Models__c='ALL'));
		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeOwnershipNonIATA', TC_Location_type__c = false,
							 TC_Legal_status__c = false, TC_Location__c = false,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
							 TC_Major_Shareholding__c = false, TC_VMFR__c = false,
							 TCA_Sanity_check__c = 'CHO', TCA_Application_withdrawal__c = 'CWD',Valid_Accreditation_Models__c='ALL'));
		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeMajorShareholding', TC_Location_type__c = false,
							 TC_Legal_status__c = false, TC_Location__c = false,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
							 TC_Major_Shareholding__c = true, TC_VMFR__c = false,
							 TCA_Sanity_check__c = 'CHC', TCA_Application_withdrawal__c = 'CWD',Valid_Accreditation_Models__c='ALL'));

		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeMix', TC_Location_type__c = false,
							 TC_Legal_status__c = false, TC_Location__c = true,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = true, TC_Ownership__c = false,
							 TC_Major_Shareholding__c = false, TC_VMFR__c = false,
							 TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF',Valid_Accreditation_Models__c='ALL'));

		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeMixAll', TC_Location_type__c = true,
							 TC_Legal_status__c = false, TC_Location__c = true, TC_Accreditation_Type__c = false,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false,
							 TC_Major_Shareholding__c = false, TC_VMFR__c = true,
							 TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF',TC_Hierarchy__c = true,Valid_Accreditation_Models__c='ALL'));

		insert customsettings;

		AE.ANG_Accreditation_Model__c = 'Cash';
		HE.ANG_Accreditation_Model__c = 'Cashless';

		Id oscarRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes');


		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = AE.id, New_parent__c = AE.id, recordTypeId = oscarRT, Process__c = 'ANG.MAJOR.CHANGES.1.0' );

		Id chinaConversionsRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes_China');

		AMS_OSCAR__c chinaConversionOscar = new AMS_OSCAR__c();

		chinaConversionOscar.Account__c = chinaHE.id;
		chinaConversionOscar.New_parent__c = chinaHE.id;
		chinaConversionOscar.RecordTypeId = chinaConversionsRT;
		chinaConversionOscar.Process__c = AMS_Utils.NGCHINACONVERSION;
		chinaConversionOscar.ANG_Type_Of_Change__c = AMS_Utils.CONVERTTOLEGACY;

		AMS_OSCAR__c chinaPendingOscar = new AMS_OSCAR__c();

		chinaPendingOscar.Account__c = chinaAE.id;
		chinaPendingOscar.New_parent__c = chinaAE.id;
		chinaPendingOscar.RecordTypeId = oscarRT;
		chinaPendingOscar.Process__c = 'ANG.MAJOR.CHANGES.1.0';
		chinaPendingOscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION;

		insert new List<AMS_OSCAR__c>{oscar, chinaConversionOscar, chinaPendingOscar};

		ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

		List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();

		agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = HE.Id));

		insert agenciesinvolved;

		String OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
		oscarCase.AccountId = AE.Id;
		oscarCase.ContactId = co1.Id;
		oscarCase.Reason = 'Product Inquiry';
		oscarCase.Type = 'Case';
		oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
		oscarCase.CaseArea__c = 'Accreditation Process';
		oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = HE.Id;
		oscarCase.Region__c = 'Europe';

		Case chinaOscarCase = new Case(Oscar__c = chinaConversionOscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
		chinaOscarCase.AccountId = chinaHE.Id;
		chinaOscarCase.ContactId = contactChina.Id;
		chinaOscarCase.Reason = 'Product Inquiry';
		chinaOscarCase.Type = 'Case';
		chinaOscarCase.Subject = 'Conversion to Domestic with Cash - Main China HE Account';
		chinaOscarCase.CaseArea__c = 'Accreditation Process';
		chinaOscarCase.Reason1__c = AMS_Utils.CONVERTTOLEGACY;
		chinaOscarCase.Type_of_customer__c = 'IATA Travel Agent';
		chinaOscarCase.Account_Concerned__c = chinaHE.Id;
		chinaOscarCase.Region__c = 'China & North Asia';

		Case chinaPendingOscarCase = new Case(Oscar__c = chinaPendingOscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
		chinaPendingOscarCase.AccountId = chinaAE.Id;
		chinaPendingOscarCase.ContactId = contactChina.Id;
		chinaPendingOscarCase.Reason = 'Product Inquiry';
		chinaPendingOscarCase.Type = 'Case';
		chinaPendingOscarCase.Subject = 'Changes China AE Account';
		chinaPendingOscarCase.CaseArea__c = 'Accreditation Process';
		chinaPendingOscarCase.Reason1__c = 'Changes';
		chinaPendingOscarCase.Type_of_customer__c = 'IATA Travel Agent';
		chinaPendingOscarCase.Account_Concerned__c = chinaAE.Id;
		chinaPendingOscarCase.Region__c = 'China & North Asia';

		insert new List<Case>{oscarCase, chinaOscarCase, chinaPendingOscarCase};

		// let's start !!

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		// Create the Staging area for the Account
		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
			RecordTypeId = rtChangesStagingId,
			IATAcode__c = AE.IATAcode__c,
			Branch_Office_Country__c = AE.IATA_ISO_Country__c,
			Location_Class__c = AE.Location_Class__c,
			Location_Type__c = AE.Location_Type__c,
			SAAM_Case__c = oscarCase.Id,
			Account_Name__c = 'Lisbon Travel Gods',
			ISSP_AMS_Legal_Status__c = 'Association',
			Short_Name__c = 'Lisbon Travel Gods',
			TradeName__c = 'Lisbon Travel Gods',
			Trade_Name__c = 'Lisbon Travel Gods',
			ISSP_AMS_License_No__c = '111222333',
			ISSP_AMS_VAT_Number_Input__c = '111222333',
			Branch_Office_Email__c = 'ltg23@fefff2.com',
			Website__c = 'wwww.asdasidsss12233.pt',
			Branch_Office_Phone__c = '123456780',
			Branch_Office_Phone_National__c = '123456780',
			Branch_Office_FAX__c = '123456780',
			Branch_Office_Fax_National__c = '123456780',
			Abbreviated_name__c = 'Lisbon Travel Gods',
			VAT_Number_2__c = '111222333',
			ANG_Accreditation_type__c = 'Cashless'
		);

		AMS_Pax_Accreditation_Form__c stagingAreaCN = new  AMS_Pax_Accreditation_Form__c(
			RecordTypeId = rtChangesStagingId,
			IATAcode__c = chinaAE.IATAcode__c,
			Branch_Office_Country__c = chinaAE.IATA_ISO_Country__c,
			Location_Class__c = chinaAE.Location_Class__c,
			Location_Type__c = chinaAE.Location_Type__c,
			SAAM_Case__c = chinaPendingOscarCase.Id,
			Account_Name__c = 'China Travel Gods',
			ISSP_AMS_Legal_Status__c = 'Association',
			Short_Name__c = 'China Travel Gods',
			TradeName__c = 'China Travel Gods',
			Trade_Name__c = 'China Travel Gods',
			ISSP_AMS_License_No__c = '111222333',
			ISSP_AMS_VAT_Number_Input__c = '111222333',
			Branch_Office_Email__c = 'china@fefff2.com',
			Website__c = 'wwww.china123.pt',
			Branch_Office_Phone__c = '123456780',
			Branch_Office_Phone_National__c = '123456780',
			Branch_Office_FAX__c = '123456780',
			Branch_Office_Fax_National__c = '123456780',
			Abbreviated_name__c = 'China Travel Gods',
			VAT_Number_2__c = '111222333',
			ANG_Accreditation_type__c = 'Cashless'
		);

		insert new List<AMS_Pax_Accreditation_Form__c>{stagingArea, stagingAreaCN};

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION+';'+AMS_Utils.LOCATION_TYPE+';'+AMS_Utils.ANG_HIERARCHY+';'+AMS_Utils.ANG_VMFR;

		chinaPendingOscar.AMS_Online_Accreditation__c = stagingAreaCN.Id;

		update new List<AMS_OSCAR__c>{oscar, chinaPendingOscar};

		insert new AMS_Accreditation_Contact__c(Agency_Owner__c = true, Financial_interest__c = 100,
			AMS_Pax_Accreditation_Form__c = stagingArea.Id, Company__c = HE.Id, First_name__c='NameToUse1', Last_name__c='Last1',
			Job_title__c='ABC1', Mobile__c='+4112345671', Phone__c='3424322341', Email__c='unique@email1.com',
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'));
	}

	@isTest
	static void test_controller() {

		Account HE = [SELECT Id FROM Account WHERE Name = 'Main HE Account HE'];
		AMS_OSCAR__c oscar = [SELECT Account__c, ANG_Type_Of_Change__c, New_parent__c, Change_of_location_type_behavior__c, STEP6__c, Process__c, RecordTypeId, Account__r.ANG_Accreditation_Model__c
		FROM AMS_OSCAR__c WHERE ANG_Type_Of_Change__c <> :AMS_Utils.CONVERTTOLEGACY LIMIT 1];

		Test.startTest();

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		//getter verification
		boolean showTargetAgency = con.showTargetAgency;
		boolean showTopPanel = con.showTopPanel;
		boolean editable = con.editable;
		boolean closeTab = con.closeTab;
		boolean selectAll = con.selectAll;
		Account newP = con.newParent;
		List<String> notesSet = con.noteList;
		List<String> oscarFieldList = con.oscarFieldList;
		List<String> accountFieldList = con.accountFieldList;
		Map<Id, ANG_AccountHierarchySelectionController.HierarchyItem> hierarchy = con.hierarchy;
		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;
		Integer pageInteger = con.currentPage;
		pageInteger = con.totalPages;

		con.selectAll = true;
		con.doSelectAll();
		con.getDisablePrevious();
		con.selectMain();
		con.FetchNewParent();
		con.Beginning();
		con.Previous();
		con.Next();
		con.End();
		con.isMovingTopLocationTypeAccount();
		con.isSingleDestinationHierarchy(HE.Id);
		con.isAllHierarchySelected();
		con.hasTopLocationType(HE.Id);
		con.isTerminatedAccount(HE.Id);
		con.newParentIncluded(HE.Id);
		con.isJustOneAgencySelected();
		con.getDisableNext();
		con.updateRelatedRecords();
		con.save();

		Test.stopTest();
	}

	@isTest
	static void hierarchySelectionForChinaConversionNOKTest(){

		Test.startTest();

		AMS_OSCAR__c oscar =
			[SELECT
				Id,
				STEP6__c,
				Account__c,
				Process__c,
				RecordTypeId,
				New_parent__c,
				ANG_Type_Of_Change__c,
				Change_of_location_type_behavior__c,
				Account__r.ANG_Accreditation_Model__c
			 FROM AMS_OSCAR__c
			 WHERE
			 	ANG_Type_Of_Change__c = :AMS_Utils.CONVERTTOLEGACY
			 LIMIT 1
			];

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		System.assert(con.isChinaConversion, 'Must be identified as a china conversion');

		Map<Id, ANG_AccountHierarchySelectionController.HierarchyItem> hierarchy = con.hierarchy;
		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		System.assert(con.showOnGoingOscarWarning, 'Must show the OSCAR warning');

		con.save();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();

		System.assertEquals(2, pageMessages.size());

		Boolean messageFound = false;

		for(ApexPages.Message message : pageMessages) {

			system.debug('MESSAGE DETAIL: ' + message.getDetail());

			if(message.getDetail().contains('The conversion must be applied to a hierarchy of Domestic agents. Please proceed with a change of location type before processing the conversion.')){
				messageFound = true;
				break;
			}

		}

		System.assert(messageFound, 'The error \'The conversion must be applied to a hierarchy of Domestic agents. Please proceed with a change of location type before processing the conversion.\' must be thrown.');

		Test.stopTest();

	}

	@isTest
	static void hierarchySelectionForChinaConversionOKTest(){

		delete [SELECT Id, Subject FROM Case WHERE SUbject like '%Account China AE1 H1%' LIMIT 1];

		Account acct = [SELECT Id, Location_Class__c FROM Account WHERE Name = 'Account China AE1 H1' LIMIT 1];

		acct.Location_Class__c = 'D';
		update acct;

		AMS_OSCAR__c oscar =
			[SELECT
				Id,
				STEP6__c,
				Account__c,
				Process__c,
				RecordTypeId,
				New_parent__c,
				ANG_Type_Of_Change__c,
				Change_of_location_type_behavior__c,
				Account__r.ANG_Accreditation_Model__c
			 FROM AMS_OSCAR__c
			 WHERE
			 	ANG_Type_Of_Change__c = :AMS_Utils.CONVERTTOLEGACY
			 LIMIT 1
			];

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		System.assert(!con.showOnGoingOscarWarning, 'Must not show the OSCAR warning');

		Map<Id, ANG_AccountHierarchySelectionController.HierarchyItem> hierarchy = con.hierarchy;
		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Test.startTest();
			con.save();
		Test.stopTest();

		ApexPages.Message[] pageMessages = ApexPages.getMessages();

		system.debug(pageMessages);

		System.assertEquals(0, pageMessages.size());

	}


	@isTest
	static void hierarchySelectionForMulticountryChanges(){

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			ANG_RHC_Amount_Equals_FS__c = true
		);

		AMS_Settlement_System__c bspES = new AMS_Settlement_System__c(
			Name = 'BSP-ES',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			ANG_RHC_Amount_Equals_FS__c = true
		);

		AMS_Settlement_System__c bspDK = new AMS_Settlement_System__c(
			Name = 'BSP-DK',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			ANG_RHC_Amount_Equals_FS__c = true
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspES, bspDK};

		IATA_ISO_Country__c ctryPT = new IATA_ISO_Country__c (Name='PT',ISO_Code__c='PT', ANG_Enable_NewGen__c = true, Multicountry_Enabled__c = true, AMS_Settlement_System__c = bspPT.id);
		IATA_ISO_Country__c ctryES = new IATA_ISO_Country__c (Name='ES',ISO_Code__c='ES', ANG_Enable_NewGen__c = true, Multicountry_Enabled__c = true, AMS_Settlement_System__c = bspES.id);
		IATA_ISO_Country__c ctryDK = new IATA_ISO_Country__c (Name='DK',ISO_Code__c='DK', ANG_Enable_NewGen__c = true, Multicountry_Enabled__c = true, AMS_Settlement_System__c = bspDK.id);
		//IATA_ISO_Country__c ctryFR = new IATA_ISO_Country__c (Name='FR',ISO_Code__c='FR', ANG_Enable_NewGen__c = true, Multicountry_Enabled__c = true);
		insert new List<IATA_ISO_Country__c>{ctryPT, ctryES, ctryDK};//, ctryFR};

		IATA_ISO_State__c sttPT = new IATA_ISO_State__c(Name= 'Portugal', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctryPT.Id);
		IATA_ISO_State__c sttES = new IATA_ISO_State__c(Name= 'Spain', ISO_Code__c = 'ES', IATA_ISO_Country__c = ctryES.Id);
		IATA_ISO_State__c sttDK = new IATA_ISO_State__c(Name= 'Denmark', ISO_Code__c = 'DK', IATA_ISO_Country__c = ctryDK.Id);
		//IATA_ISO_State__c sttFR = new IATA_ISO_State__c(Name= 'France', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctryPT.Id);

		insert new List<IATA_ISO_State__c>{sttPT, sttES, sttDK};//, sttFR};

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account GE1 = new Account();
		GE1.Name = 'Main GE1 PT Account';
		GE1.Sector__c = 'Travel Agent';
		GE1.IATACode__c = '12345678';
		GE1.Category__c = 'IATA Passenger Sales Agent';
		GE1.Location_Class__c = 'P';
		GE1.Location_Type__c = AMS_Utils.GE;
		GE1.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		GE1.IATA_ISO_Country__c = ctryPT.Id;
		GE1.ANG_IEP_HE_AccntNum__c = '1232132323';
		GE1.ANG_IEP_Status__c = 'Suspended' ;
		GE1.ANG_HE_CashCondition__c = true;
		GE1.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		GE1.ANG_HE_RiskStatus__c = 'Not Applicable';
		GE1.RecordTypeId = accountAgencyRT;


		Account GE2 = new Account();
		GE2.Name = 'Main GE2 PT Account';
		GE2.Sector__c = 'Travel Agent';
		GE2.IATACode__c = '12345678';
		GE2.Category__c = 'IATA Passenger Sales Agent';
		GE2.Location_Class__c = 'P';
		GE2.Location_Type__c = AMS_Utils.GE;
		GE2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		GE2.IATA_ISO_Country__c = ctryPT.Id;
		GE2.ANG_IEP_HE_AccntNum__c = '1232132323';
		GE2.ANG_IEP_Status__c = 'Suspended' ;
		GE2.ANG_HE_CashCondition__c = true;
		GE2.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		GE2.ANG_HE_RiskStatus__c = 'Not Applicable';
		GE2.RecordTypeId = accountAgencyRT;

		insert new list<Account>{GE1, GE2};

		Account HE1 = new Account(
			IATA_ISO_Country__c = ctryES.id,
			ANG_IEP_Status__c = null,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			RecordTypeId = accountAgencyRT,
			IATACode__c='12345679',
			Name='Account HE1 GE1',
			Short_Name__c='Account HE1 GE1',
			Category__c = 'IATA Passenger Sales Agent',
			Location_Class__c = 'P',
			Location_Type__c = AMS_Utils.HE,
			ParentId = GE1.Id,
			Top_Parent__c = GE1.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED
		);

		Account HE2 = new Account(
			IATA_ISO_Country__c = ctryDK.id,
			ANG_IEP_Status__c = null,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			RecordTypeId = accountAgencyRT,
			IATACode__c='12345679',
			Name='Account HE2 GE2',
			Short_Name__c='Account HE2 GE2',
			Category__c = 'IATA Passenger Sales Agent',
			Location_Class__c = 'P',
			Location_Type__c = AMS_Utils.HE,
			ParentId = GE2.Id,
			Top_Parent__c = GE2.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED
		);
		insert new list<Account>{HE1, HE2};

		Account AE1 = new Account(
			IATA_ISO_Country__c = ctryPT.id,
			ANG_IEP_Status__c = null,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			RecordTypeId = accountAgencyRT,
			IATACode__c='12345679',
			Name='Account AE1 GE1',
			Short_Name__c='Account AE1 GE1',
			Category__c = 'IATA Passenger Sales Agent',
			Location_Class__c = 'P',
			Location_Type__c = AMS_Utils.AE,
			ParentId = GE1.Id,
			Top_Parent__c = GE1.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED
		);

		Account AE2 = new Account(
			IATA_ISO_Country__c = ctryES.id,
			ANG_IEP_Status__c = null,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			RecordTypeId = accountAgencyRT,
			IATACode__c='12345679',
			Name='Account AE2 GE1',
			Short_Name__c='Account AE2 GE1',
			Category__c = 'IATA Passenger Sales Agent',
			Location_Class__c = 'P',
			Location_Type__c = AMS_Utils.AE,
			ParentId = HE1.Id,
			Top_Parent__c = GE1.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED
		);

		Account AE3 = new Account(
			IATA_ISO_Country__c = ctryPT.id,
			ANG_IEP_Status__c = null,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			RecordTypeId = accountAgencyRT,
			IATACode__c='12345679',
			Name='Account AE3 GE2',
			Short_Name__c='Account AE3 GE2',
			Category__c = 'IATA Passenger Sales Agent',
			Location_Class__c = 'P',
			Location_Type__c = AMS_Utils.AE,
			ParentId = GE2.Id,
			Top_Parent__c = GE2.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED
		);

		Account AE4 = new Account(
			IATA_ISO_Country__c = ctryDK.id,
			ANG_IEP_Status__c = null,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			RecordTypeId = accountAgencyRT,
			IATACode__c='12345679',
			Name='Account AE4 GE2',
			Short_Name__c='Account AE4 GE2',
			Category__c = 'IATA Passenger Sales Agent',
			Location_Class__c = 'P',
			Location_Type__c = AMS_Utils.AE,
			ParentId = HE2.Id,
			Top_Parent__c = GE2.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED
		);

		Account AE5 = new Account(
			IATA_ISO_Country__c = ctryDK.id,
			ANG_IEP_Status__c = null,
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY,
			RecordTypeId = accountAgencyRT,
			IATACode__c='123452679',
			Name='Account AE5 GE2',
			Short_Name__c='Account AE5 GE2',
			Category__c = 'IATA Passenger Sales Agent',
			Location_Class__c = 'P',
			Location_Type__c = AMS_Utils.AE,
			ParentId = HE2.Id,
			Top_Parent__c = GE2.Id,
			Status__c = AMS_Utils.ACC_S9_APPROVED
		);

		insert new list<Account>{AE1, AE2, AE4, AE5};

		AMS_Agencies_Hierarchy__c hierarchyGE1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy GE1');
		AMS_Agencies_Hierarchy__c hierarchyGE2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy GE2');
		insert new List<AMS_Agencies_Hierarchy__c>{hierarchyGE1, hierarchyGE2};

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true,
			Child_Account__c = HE1.Id ,
			Parent_Account__c = GE1.Id,
			Hierarchy__c = hierarchyGE1.Id
		);


		AMS_Agencies_relationhip__c r2 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true,
			Child_Account__c = AE1.Id ,
			Parent_Account__c = GE1.Id,
			Hierarchy__c = hierarchyGE1.Id
		);


		AMS_Agencies_relationhip__c r3 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true,
			Child_Account__c = AE2.Id ,
			Parent_Account__c = HE1.Id,
			Hierarchy__c = hierarchyGE1.Id
		);

		AMS_Agencies_relationhip__c r4 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true,
			Child_Account__c = HE2.Id ,
			Parent_Account__c = GE2.Id,
			Hierarchy__c = hierarchyGE2.Id
		);

		AMS_Agencies_relationhip__c r5 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true,
			Child_Account__c = AE3.Id ,
			Parent_Account__c = GE2.Id,
			Hierarchy__c = hierarchyGE2.Id
		);

		AMS_Agencies_relationhip__c r6 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true,
			Child_Account__c = AE4.Id ,
			Parent_Account__c = HE2.Id,
			Hierarchy__c = hierarchyGE2.Id
		);

		AMS_Agencies_relationhip__c r7 = new AMS_Agencies_relationhip__c(
			Is_Newgen_Relation__c = true,
			Child_Account__c = AE5.Id ,
			Parent_Account__c = HE2.Id,
			Hierarchy__c = hierarchyGE2.Id
		);

		insert new List<AMS_Agencies_relationhip__c>{r1, r2, r3, r4, r6, r7};

		Test.startTest();

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = GE2.id,
		 New_parent__c = GE1.id,
		 recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c','ANG_Agency_Changes'),
		 Process__c = 'ANG.MAJOR.CHANGES.1.0' );
		insert oscar;


		Contact contactGE2 = new Contact(AccountId = GE2.id,
		 Firstname = 'teste2', Lastname='test2', Phone = '911111111', MobilePhone = '911111111', Email = 'testGE2@test.com', Financial_Assessment_Contact__c = false);
		insert contactGE2;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
		oscarCase.AccountId = GE2.Id;
		oscarCase.ContactId = contactGE2.Id;
		oscarCase.Reason = 'Product Inquiry';
		oscarCase.Type = 'Case';
		oscarCase.subject = 'Changes - WEBER VOYAGES SARL';
		oscarCase.CaseArea__c = 'Accreditation Process';
		oscarCase.Reason1__c = 'Changes';
		oscarCase.Type_of_customer__c = 'IATA Travel Agent';
		oscarCase.BSPCountry__c = 'US';
		oscarCase.Account_Concerned__c = GE1.Id;
		oscarCase.Region__c = 'Europe';
		insert oscarCase;

		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes'),
			IATAcode__c = GE2.IATAcode__c,
			Branch_Office_Country__c = GE2.IATA_ISO_Country__c,
			Location_Class__c = GE2.Location_Class__c,
			Location_Type__c = GE2.Location_Type__c,
			SAAM_Case__c = oscarCase.Id,
			/*Account_Name__c = 'Lisbon Travel Gods',
			ISSP_AMS_Legal_Status__c = 'Association',
			Short_Name__c = 'Lisbon Travel Gods',
			TradeName__c = 'Lisbon Travel Gods',
			Trade_Name__c = 'Lisbon Travel Gods',
			ISSP_AMS_License_No__c = '111222333',
			ISSP_AMS_VAT_Number_Input__c = '111222333',
			Branch_Office_Email__c = 'ltg23@fefff2.com',
			Website__c = 'wwww.asdasidsss12233.pt',
			Branch_Office_Phone__c = '123456780',
			Branch_Office_Phone_National__c = '123456780',
			Branch_Office_FAX__c = '123456780',
			Branch_Office_Fax_National__c = '123456780',
			Abbreviated_name__c = 'Lisbon Travel Gods',
			VAT_Number_2__c = '111222333',*/
			ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
		);
		insert stagingArea;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		update oscar;

		//finish preparing the data
		system.debug('##ARD PT: ' + bspPT.id);
		system.debug('##ARD ES: ' + bspES.id);
		system.debug('##ARD DK: ' + bspDK.id);

		ANG_AccountHierarchySelectionController controller = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));
		for (ANG_AccountHierarchySelectionController.HierarchyItem i : controller.hierarchy.values()){
			if (i.acc.IATA_ISO_Country__c == ctryDK.id && i.acc.Location_type__c == AMS_Utils.AE ) i.selected = true;
		}
		controller.handleSelection();
		system.debug('##ARD hesPerBSPs: ' + controller.hesPerBSPs);

		system.debug('##ARD controller.showBSPPanel: ' + controller.showBSPPanel);


		//just one, DK
		//controller.hesPerBSPs.values().get(0).p.ParentId = AE4.id;
		//system.debug('##ARD controller.hesPerBSPs.get(0).ParentId: ' + controller.hesPerBSPs.values().get(0).p.ParentId);

		controller.save();
		//aqui deve conter o erro

		for (ANG_AccountHierarchySelectionController.HierarchyItem i : controller.hierarchy.values()){
			if (i.acc.IATA_ISO_Country__c == ctryDK.id && i.acc.Location_type__c == AMS_Utils.HE ) i.selected = true;
		}
		controller.handleSelection();
		//deve setar automaticamente o HE como api
		controller.save();

		AMS_OSCAR__c osc =  [SELECT HE_per_BSP_Mapping__c FROM AMS_OSCAR__C WHERE ID = :oscar.id];

		system.debug('##ARD FINAL result to assert: ' + osc.HE_per_BSP_Mapping__c);
		Test.stopTest();
	}
}
