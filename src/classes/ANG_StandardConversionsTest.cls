@isTest
private class ANG_StandardConversionsTest {

	@testSetup static void setup(){

		Test.startTest();

		Portal_Applications__c par = new Portal_Applications__c (Name = ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE);
		insert par;

		Amazon_Cred__c amazon_Cred =  new Amazon_Cred__c(
			Name = 'IFAP',
			Prod_Configuration__c = 'adevconf',
			Dev_Configuration__c = 'adevconf'
		);

		Amazon_Cred__c genericAttach = new Amazon_Cred__c(
			Name = 'GenericAttach',
			Prod_Configuration__c = 'adevconf',
			Dev_Configuration__c = 'adevconf'
		);

		Amazon_Cred__c recycleBin =  new Amazon_Cred__c(
			Name = 'RecycleBin',
			Prod_Configuration__c = 'adevconf',
			Dev_Configuration__c = 'adevconf'
		);

		insert new List<Amazon_Cred__c>{amazon_Cred, genericAttach, recycleBin};

		List<AWSKey__c> AWS_KEYs = new List<AWSKey__c>{
				new AWSKey__c(
					name = 'adevconf',
					Key__c = 'asd',
					Secret__c = 'asd',
					IAS_configuration_name__c = 'asdas',
					IAS_Access_Point__c = 'asd',
					Bucket__c = 'asd',
					AWS_ENDPOINT_URL__c = 'asd'
				)
		};

		insert AWS_KEYs;

		ANG_AgencyChangesConfig__c convertMulticountryToStandard = new ANG_AgencyChangesConfig__c();
		convertMulticountryToStandard.Name = 'ConvertMulticountryToStandard';
		convertMulticountryToStandard.TCA_Sanity_check__c = 'CNV';
		convertMulticountryToStandard.TCA_Manager_approval__c = 'CVF';
		convertMulticountryToStandard.TCA_Application_withdrawal__c = 'CWD';
		convertMulticountryToStandard.Valid_Accreditation_Models__c='Cash';
		convertMulticountryToStandard.TC_Conversion__c = true;

		insert convertMulticountryToStandard;

		AMS_ChangeCodes__c cnvCode = new AMS_ChangeCodes__c(
			Name = 'CNV',
			Account_status_change__c = '8;9',
			Change_Code__c = 'CNV',
			Reason_Code_Description__c = 'CHANGE IN PROCESS',
			Reason_Code__c = '81',
			Integration_RecId__c = 'C'
		);

		AMS_ChangeCodes__c cvfCode = new AMS_ChangeCodes__c(
			Name = 'CVF',
			Account_status_change__c = '9;8',
			Change_Code__c = 'CVF',
			Reason_Code_Description__c = 'ACCREDITED-MEET-STANDARDS',
			Reason_Code__c = '91',
			Integration_RecId__c = 'C'
		);

		AMS_ChangeCodes__c cwdCode = new AMS_ChangeCodes__c(
			Name = 'CWD',
			Account_status_change__c = '9;8',
			Bulletin_Memo_Text__c = 'ACCREDITED-MEET-STANDARDS',
			Reason_Code__c = '91',
			Change_Code__c = 'CWD',
			Integration_RecId__c = 'C'
		);

		insert new List<AMS_ChangeCodes__c>{cnvCode, cvfCode, cwdCode};

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		AMS_Settlement_System__c bspGB = new AMS_Settlement_System__c(
			Name = 'BSP-GB',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspGB};

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c();

		countryPT.Name = 'Portugal';
		countryPT.ISO_Code__c = 'PT';
		countryPT.ANG_Enable_NewGen__c = true;
		countryPT.AMS_Settlement_System__c = bspPT.Id;
		countryPT.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countryUK = new IATA_ISO_Country__c();

		countryUK.Name = 'United Kingdom';
		countryUK.ISO_Code__c = 'GB';
		countryUK.ANG_Enable_NewGen__c = true;
		countryUK.AMS_Settlement_System__c = bspGB.Id;
		countryUK.Multicountry_Enabled__c = true;

		insert new List<IATA_ISO_Country__c>{countryPT, countryUK};

		Id agencyRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account accountGE = new Account();
		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = countryPT.Id;
		accountGE.RecordTypeId = agencyRecTypeId;
		accountGE.IATACode__c = '12300099';
		accountGE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountGE.Status__c = 'Approved';
		accountGE.Remittance_Frequency__c = 'D';
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert new List<Account>{accountGE};

		Account accountUkHE = new Account();
		accountUkHE.Name = 'Multicountry HE UK';
		accountUkHE.ParentId = accountGE.Id;
		accountUkHE.Location_Type__c = AMS_Utils.HE;
		accountUkHE.Location_Class__c = 'P';
		accountUkHE.IATA_ISO_Country__c = countryUK.Id;
		accountUkHE.RecordTypeId = agencyRecTypeId;
		accountUkHE.IATACode__c = '12300098';
		accountUkHE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountUkHE.Status__c = 'Approved';
		accountUkHE.Remittance_Frequency__c = 'D';
		accountUkHE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountAE = new Account();
		accountAE.Name = 'Multicountry AE PT';
		accountAE.ParentId = accountGE.Id;
		accountAE.Location_Type__c = AMS_Utils.AE;
		accountAE.Location_Class__c = 'P';
		accountAE.IATA_ISO_Country__c = countryPT.Id;
		accountAE.RecordTypeId = agencyRecTypeId;
		accountAE.IATACode__c = '12300097';
		accountAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAE.Status__c = 'Approved';
		accountAE.Remittance_Frequency__c = 'D';
		accountAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountAE_2 = new Account();
		accountAE_2.Name = 'Multicountry AE PT 2';
		accountAE_2.ParentId = accountGE.Id;
		accountAE_2.Location_Type__c = AMS_Utils.AE;
		accountAE_2.Location_Class__c = 'P';
		accountAE_2.IATA_ISO_Country__c = countryPT.Id;
		accountAE_2.RecordTypeId = agencyRecTypeId;
		accountAE_2.IATACode__c = '12300096';
		accountAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAE_2.Status__c = 'Approved';
		accountAE_2.Remittance_Frequency__c = 'D';
		accountAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert new List<Account>{accountUkHE, accountAE, accountAE_2};

		Account accountUkAE = new Account();
		accountUkAE.Name = 'Multicountry AE UK';
		accountUkAE.ParentId = accountUkHE.Id;
		accountUkAE.Location_Type__c = AMS_Utils.AE;
		accountUkAE.Location_Class__c = 'P';
		accountUkAE.IATA_ISO_Country__c = countryUK.Id;
		accountUkAE.RecordTypeId = agencyRecTypeId;
		accountUkAE.IATACode__c = '12300095';
		accountUkAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountUkAE.Status__c = 'Approved';
		accountUkAE.Remittance_Frequency__c = 'D';
		accountUkAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountUkAE_2 = new Account();
		accountUkAE_2.Name = 'Multicountry AE UK 2';
		accountUkAE_2.ParentId = accountUkHE.Id;
		accountUkAE_2.Location_Type__c = AMS_Utils.AE;
		accountUkAE_2.Location_Class__c = 'P';
		accountUkAE_2.IATA_ISO_Country__c = countryUK.Id;
		accountUkAE_2.RecordTypeId = agencyRecTypeId;
		accountUkAE_2.IATACode__c = '12300094';
		accountUkAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountUkAE_2.Status__c = 'Approved';
		accountUkAE_2.Remittance_Frequency__c = 'D';
		accountUkAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert new List<Account>{accountUkAE, accountUkAE_2};

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Multicountry Hierarchy', Main_Account__c = accountGE.Id);

		insert hierarchy;

		List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
		
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountUkHE.Id, Child_Account__c = accountUkAE.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountUkHE.Id, Child_Account__c = accountUkAE_2.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountUkHE.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountAE.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountAE_2.Id, Is_Newgen_Relation__c = true));

		insert rels;

		ANG_RHC_Currencies__c rhcCurrencies = new ANG_RHC_Currencies__c();
		rhcCurrencies.Name = 'EUR';
		rhcCurrencies.CurrencyIsoCode = 'EUR';
		rhcCurrencies.Currency_Name__c  = 'Euro';

		insert rhcCurrencies;

		ANG_RHC_Information__c rhcInfoForGE = new ANG_RHC_Information__c(
			ANG_AccountId__c = accountGE.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0,
			ANG_RHC_Amount_Equals_FS__c = true,
			ANG_RHC_Amount__c = 15,
			ANG_RME_Amount__c = 100
		);

		insert rhcInfoForGE;

		Contact cont = new Contact(
			AccountId = accountGE.id,
			Firstname = 'Richard',
			Lastname = 'Vaughan',
			Phone = '666123456',
			MobilePhone = '911111111',
			Email = 'richard.vaughan@test.com',
			Financial_Assessment_Contact__c = false
		);

		insert cont;

		ANG_AgencyChangesHelper.testRunnningForNonBackup = true;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = accountGE.Id,
			Process__c = AMS_Utils.NGCONVERSIONMCTOST,
			RecordTypeId = AMS_Utils.RECTYPE_NGCONVERSIONTOSTANDARD,
			Status__c = AMS_Utils.OPEN,
			STEP10__c = AMS_Utils.PASSED
		);

		insert oscar;

		Case oscarCase = new Case();
		oscarCase.Oscar__c = oscar.Id;
		oscarCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
		oscarCase.AccountId = accountGE.Id;
		oscarCase.ContactId = cont.Id;
		oscarCase.Reason1__c = 'Accreditation Type';
		insert oscarCase;

		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'Attachment Required',
			Case__c = oscarCase.Id
		);

		insert aFile;

		AMS_Pax_Accreditation_Form__c staging = new AMS_Pax_Accreditation_Form__c();

		staging.RecordTypeId = AMS_Utils.RECTYPE_NEWGEN_CHANGES_PAX;
		staging.Account_Name__c = accountGE.Name;
		staging.ISSP_AMS_Legal_Status__c = 'Association';
		staging.Branch_Office_Country__c = accountGE.IATA_ISO_Country__c;
		staging.Branch_Office_Street_name_number__c = 'sdfsdf';
		staging.Branch_Office_City__c = 'sdfsdfdf';
		staging.IATA_ISO_State__c = accountGE.Iso_State__c;
		staging.Branch_Office_Email__c = 'sdfsdfgdg@f3434.com';
		staging.Branch_Office_Phone__c = '123123123';
		staging.ISSP_AMS_Premises_located_at_airport__c = 'No';
		staging.Abbreviated_name__c = 'Multicountry ';
		staging.Abbreviated_Address__c = 'sdfsdf';
		staging.Remittance_frequency__c = 'M';
		staging.Solicitation_Flag__c = false;
		staging.Location_Class__c = accountGE.Location_Class__c;
		staging.Location_Type__c = accountGE.Location_Type__c;
		staging.SAAM_Case__c = oscarCase.Id;
		staging.ANG_Accreditation_type__c = accountGE.ANG_Accreditation_Model__c;
		staging.ISSP_AMS_GDS_with_signed_contract__c = 'Amadeus';

		insert staging;

		AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c(
			AMS_Pax_Accreditation_Form__c = staging.Id,
			First_name__c = 'Richard',
			Last_name__c = 'Vaughan',
			Agency_owner__c = true,
			Email__c = 'richard.vaughan@test.com',
			PhoneNational__c = '123123123',
			Phone__c = '123123123',
			Contact__c = cont.Id,
			Financial_interest__c = 100,
			RecordTypeId = AMS_Utils.AccreditationContactPersonRT
		);

		insert acontact;

		oscar.AMS_Online_Accreditation__c = staging.Id;
		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;

		update oscar;

		ANG_SplitMcHierarchyIntoStandardBatch myBatchObject = new ANG_SplitMcHierarchyIntoStandardBatch(oscar.Id, accountGE.Id, false);
		Database.executeBatch(myBatchObject);

		Test.stopTest();
	
	}
	
	@isTest static void multicountryToStandardGeConversionSanityCheckTest(){

		Account acct = 
			[SELECT
				Id,
				Name,
				IATACode__c,
				IATA_ISO_Country__c,
				IATA_ISO_Country__r.AMS_Settlement_System__c,
				Iso_State__c,
				Location_Class__c,
				Location_Type__c,
				Top_Parent__c,
				ANG_Accreditation_Model__c,
				(SELECT Id FROM ChildAccounts),
				(SELECT Id, Process__c, STEP6__c FROM OSCARs__r WHERE Process__c = :AMS_Utils.NGCONVERSIONMCTOST)
			 FROM Account
			 WHERE Name = 'Multicountry GE PT'
			 LIMIT 1
			];

		Set<Id> accountsInvolvedSet = new Set<Id>{acct.Id};

		for(Account childAcct : acct.ChildAccounts){
			accountsInvolvedSet.add(childAcct.Id);
		}

		AMS_OSCAR__c oscar = acct.OSCARs__r.get(0);

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Change_effective_as_of__c = System.today();

		try {
			update oscar;
		}
		catch(DMLException e){
			System.assert(e.getMessage().contains(ANG_AgencyChangesHelper.CANNOT_PASS_SANITY_CHECK_ON_GE_CONVERSION));
		}

		List<AMS_OSCAR__c> oscarLst = new List<AMS_OSCAR__c>(
			[SELECT Id, STEP6__c
			 FROM AMS_OSCAR__c
			 WHERE Account__c != :acct.Id
			 AND Process__c = :AMS_Utils.NGCONVERSIONMCTOST]
		);

		for(AMS_OSCAR__c childOscar : oscarLst){
			childOscar.STEP6__c = AMS_Utils.PASSED;
			childOscar.Change_effective_as_of__c = System.today();
		}

		//Skip OSCAR trigger
		AMS_OSCARTriggerHandler.isRunningAgeCalculator = true;
		update oscarLst;
		AMS_OSCARTriggerHandler.isRunningAgeCalculator = false;

		//Force to requery the oscar
		AMS_OSCARTriggerHandler.queriedOscarsMap = null;
		
		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Change_effective_as_of__c = System.today();
		update oscar;

		Test.stopTest();

		assertChangeCodes(oscar.Id, 'CNV', accountsInvolvedSet);

		acct = 
			[SELECT
				Id,
				ANG_HE_RiskStatus__c,
				ANG_HE_CashCondition__c,
				Financial_Review_Result__c,
				Assessment_Performed_Date__c,
				Financial_Assessment_Points__c,
				ANG_HE_RiskHistoryAssessment__c,
				(SELECT Id, ANG_RHC_Amount__c FROM RHC_Informations__r),
				(SELECT 
					Id,
					ANG_HE_RiskStatus__c,
					ANG_HE_CashCondition__c,
					Financial_Review_Result__c,
					Assessment_Performed_Date__c,
					Financial_Assessment_Points__c,
					ANG_HE_RiskHistoryAssessment__c
				 FROM ChildAccounts)
			 FROM Account
			 WHERE Id = :acct.Id
			 LIMIT 1
			];

		System.assert(!acct.ANG_HE_CashCondition__c, 'Cash condition must be false');
		System.assert(String.isBlank(acct.Financial_Review_Result__c), 'Financial Review Result must be reseted');
		System.assert(acct.Assessment_Performed_Date__c == null, 'Assessment Performed Date must be reseted');
		System.assert(acct.Financial_Assessment_Points__c == null, 'Financial Assessment Points must be reseted');
		System.assert(acct.ANG_HE_RiskStatus__c == AMS_Utils.NOT_APPLICABLE, 'Risk Status must be reseted');
		System.assert(acct.ANG_HE_RiskHistoryAssessment__c == AMS_Utils.NOT_APPLICABLE, 'Risk History Assessment must be reseted');

		System.assert(acct.RHC_Informations__r[0].ANG_RHC_Amount__c == null, 'RHC information must be reseted');

		for(Account childAcct : acct.ChildAccounts){
			System.assert(!childAcct.ANG_HE_CashCondition__c, 'Cash condition must be false');
			System.assert(String.isBlank(childAcct.Financial_Review_Result__c), 'Financial Review Result must be reseted');
			System.assert(childAcct.Assessment_Performed_Date__c == null, 'Assessment Performed Date must be reseted');
			System.assert(acct.Financial_Assessment_Points__c == null, 'Financial Assessment Points must be reseted');
			System.assert(childAcct.ANG_HE_RiskStatus__c == AMS_Utils.NOT_APPLICABLE, 'Risk Status must be reseted');
			System.assert(childAcct.ANG_HE_RiskHistoryAssessment__c == AMS_Utils.NOT_APPLICABLE, 'Risk History Assessment must be reseted');
		}

	}

	@isTest static void multicountryToStandardConversionApprovalTest(){

		Account acct = 
			[SELECT
				Id,
				Name,
				IATACode__c,
				IATA_ISO_Country__c,
				IATA_ISO_Country__r.AMS_Settlement_System__c,
				Iso_State__c,
				Location_Class__c,
				Location_Type__c,
				Top_Parent__c,
				ANG_Accreditation_Model__c,
				(SELECT Id FROM ChildAccounts),
				(SELECT Id, Process__c, STEP6__c FROM OSCARs__r WHERE Process__c = :AMS_Utils.NGCONVERSIONMCTOST)
			 FROM Account
			 WHERE Name = 'Multicountry GE PT'
			 LIMIT 1
			];

		Set<Id> accountsInvolvedSet = new Set<Id>{acct.Id};

		for(Account childAcct : acct.ChildAccounts){
			accountsInvolvedSet.add(childAcct.Id);
		}

		AMS_OSCAR__c oscar = acct.OSCARs__r.get(0);

		AMS_OSCARTriggerHandler.isRunningAgeCalculator = true;

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Change_effective_as_of__c = System.today();
		oscar.STEP15__c = AMS_Utils.PASSED;
		update oscar;

		AMS_OSCARTriggerHandler.isRunningAgeCalculator = false;

		Test.startTest();
		
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;

		Test.stopTest();

		assertChangeCodes(oscar.Id, 'CVF', accountsInvolvedSet);

	}

	@isTest static void multicountryToStandardHeConversionSanityCheckTest(){
		Account acct = 
			[SELECT
				Id,
				Name,
				IATACode__c,
				IATA_ISO_Country__c,
				IATA_ISO_Country__r.AMS_Settlement_System__c,
				Iso_State__c,
				Location_Class__c,
				Location_Type__c,
				Top_Parent__c,
				ANG_Accreditation_Model__c,
				(SELECT Id FROM ChildAccounts),
				(SELECT Id, Process__c, STEP6__c FROM OSCARs__r WHERE Process__c = :AMS_Utils.NGCONVERSIONMCTOST)
			 FROM Account
			 WHERE Name = 'Multicountry HE UK'
			 LIMIT 1
			];

		Set<Id> accountsInvolvedSet = new Set<Id>{acct.Id};

		for(Account childAcct : acct.ChildAccounts){
			accountsInvolvedSet.add(childAcct.Id);
		}

		AMS_OSCAR__c oscar = acct.OSCARs__r.get(0);

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Change_effective_as_of__c = System.today();

		update oscar;

		Test.stopTest();

		assertChangeCodes(oscar.Id, 'CNV', accountsInvolvedSet);

		acct = 
			[SELECT
				Id,
				ANG_HE_RiskStatus__c,
				ANG_HE_CashCondition__c,
				Financial_Review_Result__c,
				Assessment_Performed_Date__c,
				Financial_Assessment_Points__c,
				ANG_HE_RiskHistoryAssessment__c,
				(SELECT Id, ANG_RHC_Amount__c FROM RHC_Informations__r),
				(SELECT 
					Id,
					ANG_HE_RiskStatus__c,
					ANG_HE_CashCondition__c,
					Financial_Review_Result__c,
					Assessment_Performed_Date__c,
					Financial_Assessment_Points__c,
					ANG_HE_RiskHistoryAssessment__c
				 FROM ChildAccounts)
			 FROM Account
			 WHERE Id = :acct.Id
			 LIMIT 1
			];

		System.assert(!acct.ANG_HE_CashCondition__c, 'Cash condition must be false');
		System.assert(String.isBlank(acct.Financial_Review_Result__c), 'Financial Review Result must be reseted');
		System.assert(acct.Assessment_Performed_Date__c == null, 'Assessment Performed Date must be reseted');
		System.assert(acct.Financial_Assessment_Points__c == null, 'Financial Assessment Points must be reseted');
		System.assert(acct.ANG_HE_RiskStatus__c == AMS_Utils.NOT_APPLICABLE, 'Risk Status must be reseted');
		System.assert(acct.ANG_HE_RiskHistoryAssessment__c == AMS_Utils.NOT_APPLICABLE, 'Risk History Assessment must be reseted');

		System.assert(acct.RHC_Informations__r[0].ANG_RHC_Amount__c == null, 'RHC information must be reseted');

		for(Account childAcct : acct.ChildAccounts){
			System.assert(!childAcct.ANG_HE_CashCondition__c, 'Cash condition must be false');
			System.assert(String.isBlank(childAcct.Financial_Review_Result__c), 'Financial Review Result must be reseted');
			System.assert(childAcct.Assessment_Performed_Date__c == null, 'Assessment Performed Date must be reseted');
			System.assert(acct.Financial_Assessment_Points__c == null, 'Financial Assessment Points must be reseted');
			System.assert(childAcct.ANG_HE_RiskStatus__c == AMS_Utils.NOT_APPLICABLE, 'Risk Status must be reseted');
			System.assert(childAcct.ANG_HE_RiskHistoryAssessment__c == AMS_Utils.NOT_APPLICABLE, 'Risk History Assessment must be reseted');
		}

	}

	@isTest static void multicountryToStandardConversionWithdrawalTest(){

		Account acct = 
			[SELECT
				Id,
				Name,
				IATACode__c,
				IATA_ISO_Country__c,
				IATA_ISO_Country__r.AMS_Settlement_System__c,
				Iso_State__c,
				Location_Class__c,
				Location_Type__c,
				Top_Parent__c,
				ANG_Accreditation_Model__c,
				(SELECT Id FROM ChildAccounts),
				(SELECT Id, Process__c, STEP6__c FROM OSCARs__r WHERE Process__c = :AMS_Utils.NGCONVERSIONMCTOST)
			 FROM Account
			 WHERE Name = 'Multicountry GE PT'
			 LIMIT 1
			];

		Set<Id> accountsInvolvedSet = new Set<Id>{acct.Id};

		for(Account childAcct : acct.ChildAccounts){
			accountsInvolvedSet.add(childAcct.Id);
		}

		AMS_OSCAR__c oscar = acct.OSCARs__r.get(0);

		AMS_OSCARTriggerHandler.isRunningAgeCalculator = true;

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Change_effective_as_of__c = System.today();
		oscar.STEP15__c = AMS_Utils.PASSED;
		update oscar;

		AMS_OSCARTriggerHandler.isRunningAgeCalculator = false;

		Test.startTest();
		
		oscar.STEP4__c = AMS_Utils.PASSED;
		update oscar;

		Test.stopTest();

		assertChangeCodes(oscar.Id, 'CWD', accountsInvolvedSet);

	}

	private static void assertChangeCodes(Id oscarId, String changeCode, Set<Id> accountsInvolvedSet){

		List<Agency_Applied_Change_code__c> appliedChangeCodesLst = new List<Agency_Applied_Change_code__c>(
			[SELECT
				Id,
				Account__c,
				Change_Code__c
			 FROM Agency_Applied_Change_code__c
			 WHERE
				OSCAR__c = :oscarId
			 AND
				Change_Code__c = :changeCode
			]
		);

		system.assert(appliedChangeCodesLst.size() == accountsInvolvedSet.size());

		for(Agency_Applied_Change_code__c aacc : appliedChangeCodesLst){
			system.assert(aacc.Change_Code__c == changeCode);
			system.assert(accountsInvolvedSet.contains(aacc.Account__c));
		}

	}

}