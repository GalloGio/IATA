@isTest
private class ISSP_AmazonS3_Test {

	static testMethod void unitTest_1() {

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
									IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
									IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
									IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
		insert country;
		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
		insert country2;

		IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (Name = 'Portugal_test',
																ISO_Code__c = 'PT',
																ANG_Enable_NewGen__c = true,
																Region__c = 'Europe');
		insert portugal;

		AMS_Accreditation_Country_CheckList__c cc1 = new AMS_Accreditation_Country_CheckList__c(IATA_ISO_Country__c = portugal.Id,
																							Operation__c = 'Travel Agent');
		insert cc1;

		AMS_Accreditation_Requirement__c ac1 = new AMS_Accreditation_Requirement__c(AMS_Accreditation_Country_CheckList__c = cc1.Id,
																					Name = 'Name1',
																					Requirement_text__c = 'Text1',
																					Language__c = 'English',
																					Type_Of_Agent__c = 'IATA Travel Agent',
																					RecordTypeId = AMS_Utils.RECTYPE_IEP_MODEL_A,
																					File_to_Upload__c = 'Optional',
																					File_Identifier2__c = 'REG_CERT');

		insert ac1;

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account parent = ISSP_ObjectFactory.createNewAccount();
		parent.BillingCity = 'test';
		parent.Name = 'test';
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr;
		parent.IATACode__c = '100';
		insert parent;

		Account child = ISSP_ObjectFactory.createNewAccount();
		child.BillingCity = 'test2';
		child.Name = 'test2';
		child.Site = 'headSite';
		child.sector__c = 'airline';
		child.Top_Parent__c = null;
		child.IATA_ISO_Country__c = country.Id;
		child.RecordTypeId = rtIdBr;
		insert child;

		Account a1 = new Account (Name = 'Travel Portugal',
								RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
								IATA_ISO_Country__c = portugal.Id,
								Region__c = portugal.Region__c,
								Sector__c = Ams_Utils.SECTOR_PASSENGER,
								Status__c = Ams_Utils.ACC_S9_APPROVED,
								Location_type__c = AMS_Utils.HE,
								Location_Class__c = 'P',
								ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
								OwnerId = UserInfo.getUserId(),
								IATACode__c = '12345678');
		insert a1;

		Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'IATA EasyPay (EDENRED)');
		insert portalApp;

		Contact con1 = ISSP_ObjectFactory.createNewContact();
		con1.AccountId = a1.Id;
		insert con1;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= child.Id;
		con.Email = 'ABCDEF123123@xyz.com';
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalUser(con);
		con.OwnerId = newUser.Id;
		update con;

		Portal_Application_Right__c par1 = new Portal_Application_Right__c(Contact__c = con1.Id,
																		Portal_Application__c = portalApp.Id,
																		Right__c = 'Access Granted',
																		ANG_Portal_Service_Role__c = 'IEP Admin');
		insert par1;		

		System.runAs(newUser)
		{

			Case testCase = ISSP_ObjectFactory.createNewCase();
			testCase.BSPCountry__c = 'Hong Kong (SAR), China';
			testCase.Reason1__c = 'Cargo';
			testCase.Customer_recovery__c = false;
			//testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
			testCase.BounceEmailCounter__c = 0.0;
			testCase.Case_Language__c = 'English';
			testCase.Subject = 'Test 006';
			testCase.Reopened_case__c = 0.0;
			//testCase.Continous_Feed_SAF__c = true;
			testCase.Account_Concerned__c = child.Id;
			testCase.IFAP_Country_ISO__c = 'tq';
			insert testCase;

			AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
			newForm.IsGSA__c = 'No';
			newForm.CurrencyIsoCode = country.CurrencyIsoCode;
			newForm.SAAM_Case__c = testCase.Id;
			insert newForm;

			UtilityCS__c newCS = new UtilityCS__c();
			newCS.Name = 'Emails';
			newCS.value__c = 'test@test.test';
			insert newCS;

			ISSP_CS__c cs1 = new ISSP_CS__c();
			cs1.Name = 'ISSP AMS AMAZON S3 MAX FILE SIZE';
			cs1.Value__c = '100';
			insert cs1;

			ISSP_CS__c cs2 = new ISSP_CS__c();
			cs2.Name = 'ISSP AMS AMAZON S3 ALLOWED EXTS';
			cs2.Value__c = 'pdf';
			insert cs2;

			Amazon_Cred__c cred = new Amazon_Cred__c();
			cred.Name = 'GenericAttach';
			cred.Dev_Configuration__c = 'GenericDev';
			cred.Prod_Configuration__c = 'GenericProd';
			insert cred;

			AWSKey__c key = new AWSKey__c();
			key.AWS_ENDPOINT_URL__c = 'test';
			key.Bucket__c = 'test';
			key.IAS_Configation_name__c = 'test';
			key.IAS_configuration_name__c = 'test';
			key.Key__c = 'test';
			key.Name = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? cred.Prod_Configuration__c : cred.Dev_Configuration__c ;
			key.Secret__c = 'test';
			insert key;
			
			Test.startTest();
			ISSP_AmazonS3_Ctrl ctrlId = new ISSP_AmazonS3_Ctrl();

			ApexPages.currentPage().getParameters().put('caseId',testCase.Id);

			ISSP_AmazonS3_Ctrl ctrl = new ISSP_AmazonS3_Ctrl();
			//ctrl.filenameupload = 'test';
			//ctrl.filetypeupload = 'test';
			//ctrl.sendFileInfo();

			if (ctrl.canUploadAndDelete){
				Boolean thisTest = true;
			}

			//ISSP_AmazonS3_Ctrl.createUploadFile(c.Id, 'test', 'pdf', 'test', '500');
			//ISSP_AmazonS3_Ctrl.createUploadFile(c.Id, 'test', 'pdf', 'test', '10');
			//ISSP_AmazonS3_Ctrl.createUploadFile(c.Id, 'test.pdf', 'pdf', 'test', '10');
			String testExpiringLink = ISSP_AmazonS3_Ctrl.getExpiringLinkIfap('test.pdf');

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

			AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'test name',
			Case__c = testCase.Id,
			isPublic__c = true,
			File_Identifier__c = 'Test uploadedFileIdentifier',
			Review_Status__c = 'Rejected'
			);
			insert aFile;

			ctrl.uploadedFileName = 'filename';
			ctrl.uploadedFileSize = 10;
			ctrl.uploadedFileIdentifier = 'filename';
			ctrl.createAmazonFileObject();

			String caseStatus = ctrl.getCaseStatus();

			ISSP_AmazonS3_Ctrl.AmazonFileAMS afAMS = new ISSP_AmazonS3_Ctrl.AmazonFileAMS(aFile);

			String test = afAMS.getName();
			test = afAMS.getFullName();
			test = afAMS.getStatus();

			ctrl.currentFileName = 'test';

			map<String, List<ISSP_AmazonS3_Ctrl.AmazonFileAMS>> mapTest = ctrl.refreshAmazonFileMap();

			ctrl.deleteThisFile();

			ctrl.refreshAfterDelete();

			ctrl.getUniqueFileNames();

			ctrl.getStorageFolder();
			
			/*ctrl.getCaseOwnerNewgenPCI(); Test is failing because the users don't have visibility on Owner.name field due to Salesforce Summer release 2020
			ctrl.getCaseOwnerModelA();*/

			ISSP_AmazonS3_Ctrl ctrl2 = new ISSP_AmazonS3_Ctrl(new Apexpages.Standardcontroller(testCase));

			ISSP_AMS_Accreditation amsCtrl = new ISSP_AMS_Accreditation();
			amsCtrl.newCase = testCase;

			ISSP_AmazonS3_Ctrl ctrl3 = new ISSP_AmazonS3_Ctrl(amsCtrl);

			ISSP_AddAttachment attCtrl = new ISSP_AddAttachment();

			ISSP_AmazonS3_Ctrl ctrl4 = new ISSP_AmazonS3_Ctrl(attCtrl);



		}
		Map<Id, Account> accountMap = new Map<Id, Account>();
		accountMap.put(a1.Id, a1);
		ANG_OscarProcessHelper.createIEPAccountOscar(accountMap, 'A');
		Case modelACase = [SELECT Id FROM Case WHERE Account_Concerned__c = :a1.Id LIMIT 1];
		//Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
		System.currentPageReference().getParameters().put('caseId', modelACase.Id);

		ISSP_ModelA_Onboarding modelACtrl = new ISSP_ModelA_Onboarding();
		ISSP_AmazonS3_Ctrl ctrl5 = new ISSP_AmazonS3_Ctrl(modelACtrl);

		Test.stopTest();

	}

	static testMethod void unitTest_2() {
		Amazon_Cred__c cred = new Amazon_Cred__c();
		cred.Name = 'GenericAttach';
		cred.Dev_Configuration__c = 'GenericDev';
		cred.Prod_Configuration__c = 'GenericProd';
		insert cred;

		AWSKey__c key = new AWSKey__c();
		key.AWS_ENDPOINT_URL__c = 'test';
		key.Bucket__c = 'test';
		key.IAS_Configation_name__c = 'test';
		key.IAS_configuration_name__c = 'test';
		key.Key__c = 'test';
		key.Name = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? cred.Prod_Configuration__c : cred.Dev_Configuration__c ;
		key.Secret__c = 'test';
		insert key;

		Case cse = new Case();
		insert cse;

		Test.startTest();
		ISSP_AmazonS3_Ctrl.createAmazonFileObject(null, null, null, null, null, null, null, null, null, null);
		ISSP_AmazonS3_Ctrl.createAmazonFileObject(cse.Id, 'filename', 'none', 10, 'filename', 'teste', 'teste', '1/15/2040', '1/15/2040', 'teste');
		ISSP_AmazonS3_Ctrl.isFileNameUnique(cse.Id, 'filename', 'none');
		Test.stopTest();
	}

	static testMethod void unitTest_3() {
		Amazon_Cred__c cred = new Amazon_Cred__c();
		cred.Name = 'GenericAttach';
		cred.Dev_Configuration__c = 'GenericDev';
		cred.Prod_Configuration__c = 'GenericProd';
		insert cred;

		AWSKey__c key = new AWSKey__c();
		key.AWS_ENDPOINT_URL__c = 'test';
		key.Bucket__c = 'test';
		key.IAS_Configation_name__c = 'test';
		key.IAS_configuration_name__c = 'test';
		key.Key__c = 'test';
		key.Name = UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? cred.Prod_Configuration__c : cred.Dev_Configuration__c ;
		key.Secret__c = 'test';
		insert key;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Czech Republic';
		country.ISO_Code__c = 'Cs';
		country.AIMS_Area_Name__c = 'Czech Republic';
		country.AIMS_Area_ID__c = '1';
		insert country;

		Account acc = new Account();
		acc.Name = 'Test account';
		acc.BillingCity = 'Montreal';
		acc.BillingCountry = 'Canada';
		acc.BillingStreet = 'some street';
		acc.IATA_ISO_Country__c = country.Id;
		acc.Location_Type__c = 'HO';
		acc.IATACode__c = '1234567';
		acc.Type = 'IATA Cargo Agent';
		acc.Status__c = 'Approved';
		acc.Location_Class__c = 'C';
		insert acc;

		AMS_Agency_Regulation__c certificate1 = new AMS_Agency_Regulation__c(
													Last_Name__c = 'test1', 
													Account__c = acc.Id, 
													Type_of_Certificate__c = 'DGR', 
													Is_your_firm_handling_Dangerous_Goods__c = 'No',
													First_Name__c = 'test1', 
													Issued_on__c = Date.parse('1/15/2040'), 
													Expiry_Date__c = Date.parse('1/15/2040')
													);
		insert certificate1;

		String test0 = ISSP_AmazonS3_Ctrl.isFileInTheSameAccountHierarchy(acc.Id, 'test1', 'test1', '1/15/2040', '1/15/2040');
		System.assertEquals('fields', test0);
	}

	static testMethod void unitTest_4() {
		//insert access configuration
		Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred;
		Amazon_Cred__c Amazon_Cred2 =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred2;

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

		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Czech Republic';
		country.ISO_Code__c = 'Cs';
		country.AIMS_Area_Name__c = 'Czech Republic';
		country.AIMS_Area_ID__c = '1';
		insert country;

		
		IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
		insert country2;

		//Create Accounts
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account parent = ISSP_ObjectFactory.createNewAccount();
			parent.BillingCity = 'test';
			parent.Name = 'test';
			parent.sector__c = 'Travel Agent';
			parent.Location_Type__c = 'BR';
			parent.RecordTypeId = rtIdBr ;
			parent.IATACode__c = '100';
		insert parent;

		Account child = ISSP_ObjectFactory.createNewAccount();
			child.BillingCity = 'test2';
			child.Name = 'test2';
			child.Site = 'headSite';
			child.sector__c = 'Travel Agent';
			child.Top_Parent__c = parent.Id;
			child.IATA_ISO_Country__c = country.Id;
			child.RecordTypeId = rtIdBr ;
			child.IATACode__c = '101';
		insert child;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= child.Id;
		con.Email = 'Test@test11.com';
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalUser(con);
		con.OwnerId = newUser.Id;
		update con;

		parent.OwnerId = newUser.Id;
		update parent;

		AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
		AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
		AMS_Acc_Checklist.Operation__c = 'Travel Agent';
		AMS_Acc_Checklist.License_required__c = false ;
		AMS_Acc_Checklist.Registration_required__c = false ;
		AMS_Acc_Checklist.Statement_of_International_Sales__c = false ;
		insert AMS_Acc_Checklist;

		AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
		ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
		ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
		ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO';
		ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
		ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
		ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
		ISSP_AMS_Accreditation_Acc_Req.File_Identifier2__c = 'PCI_COMPLIANCE';
		ISSP_AMS_Accreditation_Acc_Req.File_to_Upload__c = 'Mandatory';
		insert ISSP_AMS_Accreditation_Acc_Req;

		Account acc = new Account();
		acc.Name = 'Test account';
		acc.BillingCity = 'Montreal';
		acc.BillingCountry = 'Canada';
		acc.BillingStreet = 'some street';
		acc.IATA_ISO_Country__c = country.Id;
		acc.Location_Type__c = 'HO';
		acc.IATACode__c = '1234567';
		acc.Type = 'IATA Cargo Agent';
		acc.Status__c = 'Approved';
		acc.Location_Class__c = 'C';
		insert acc;
		ISSP_CS__c csc1 = new ISSP_CS__c();
		csc1.Name = 'ISSP AMS AMAZON S3 MAX FILE SIZE';
		csc1.Value__c = '100';
		insert csc1;

		ISSP_CS__c cs2 = new ISSP_CS__c();
		cs2.Name = 'ISSP AMS AMAZON S3 ALLOWED EXTS';
		cs2.Value__c = 'pdf';
		insert cs2;
		ID AirlineCodingRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');
		Case cs1 = new Case(recordtypeID = AirlineCodingRTId,
								Region__c = 'China & North Asia',
								BSPCountry__c = 'China',
								Status = 'Open',
								Origin = 'asd',
								CaseArea__c = 'Accreditation',
								Reason1__c = '3 Digit Form',
								AccountId = acc.id,
								Coding_Application_ID__c = null,
								Coding_Application_Status__c = null,
								Coding_Application_Reception_Date__c = null,
								Subject = 'cs1');
		insert cs1;

		AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(
			SAAM_Case__c = cs1.id,
			Location_Class__c = 'C',
			Branch_Office_Country__c = country.Id
		);
		insert accre;

		AMS_Accreditation_Contact__c accContact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accre.id,
																					First_name__c = 'test1', Last_name__c = 'test1',
																					Job_title__c = 'ABC', Mobile__c = '+4112345678',
																					Phone__c = '3424322343', Email__c = 'unique@email.com',
																					Certificate_Issued_on__c = Date.parse('1/15/2040'),
																					Valid_until__c = Date.parse('1/15/2040')
																					);
		insert accContact;

		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'test name',
			isPublic__c = true,
			Case__c = cs1.Id,
			Form__c = accre.Id,
			File_Identifier__c = 'Test uploadedFileIdentifier',
			Review_Status__c = 'Rejected'
			);
		insert aFile;

		String test = ISSP_AmazonS3_Ctrl.isFileInTheSameAccountHierarchy(acc.Id, 'test1', 'test1', '1/15/2040', '1/15/2040');
		System.assertEquals('fields', test);
		String test2 = ISSP_AmazonS3_Ctrl.isFileInTheSameAccountHierarchy(acc.Id, 'test1', 'test1', '1/15/2019', '1/15/2019');
		System.assertEquals('Date', test2);

		System.runAs(newUser){

			Case testCase = ISSP_ObjectFactory.createNewCase();
				testCase.BSPCountry__c = 'South Africa';
				testCase.Reason1__c = 'Travel Agent';
				testCase.Customer_recovery__c = false;
				testCase.BounceEmailCounter__c = 0.0;
				testCase.Case_Language__c = 'English';
				testCase.Subject = 'Test 006';
				testCase.Reopened_case__c = 0.0;
				testCase.Account_Concerned__c = null;
				testCase.IFAP_Country_ISO__c = 'tq';
				testCase.Status = 'Action Needed';
				testCase.Region__c = 'Africa & Middle East';
				testCase.Account_Concerned__c = child.Id;
			insert testCase;

			AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
				newForm.IsGSA__c = 'No';
				newForm.CurrencyIsoCode = country.CurrencyIsoCode;
				newForm.SAAM_Case__c = testCase.Id;
				newForm.HO_Account__c = parent.Id;
				newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
			insert newForm ;

			ISSP_ANG_PCI pci = new ISSP_ANG_PCI();

			ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
			ISSP_AmazonS3_Ctrl ctrl = new ISSP_AmazonS3_Ctrl(pci);
			ApexPages.currentPage().getParameters().put('formId' ,accre.Id );
			ISSP_AmazonS3_Ctrl ctrl2 = new ISSP_AmazonS3_Ctrl();
			ctrl2.formId = accre.Id;
			ctrl2.currentIdentifier = 'Test uploadedFileIdentifier';
		}
	}
}