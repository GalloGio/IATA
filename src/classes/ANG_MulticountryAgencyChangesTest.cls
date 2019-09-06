@isTest
private class ANG_MulticountryAgencyChangesTest {
	
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

		//Agency changes configuration settings
		ANG_AgencyChangesConfig__c changeLocationType = new ANG_AgencyChangesConfig__c();
		changeLocationType.Name = 'ChangeLocationType';
		changeLocationType.TC_Location_Type__c = true;
		changeLocationType.TCA_Sanity_check__c = 'CAD';
		changeLocationType.TCA_Application_withdrawal__c = 'CWD';
		changeLocationType.TCA_Not_Applicable_Steps__c = 'STEP17';

		ANG_AgencyChangesConfig__c changeLocationTypeDiffLegalEnt = new ANG_AgencyChangesConfig__c();
		changeLocationTypeDiffLegalEnt.Name = 'ChangeLocationTypeDifferentLegalEntity';
		changeLocationTypeDiffLegalEnt.TC_Location_type_diff_legal_ent__c = true;
		changeLocationTypeDiffLegalEnt.TCA_Sanity_check__c = 'CDL';
		changeLocationTypeDiffLegalEnt.TCA_Manager_approval__c = 'CDF';
		changeLocationTypeDiffLegalEnt.TCA_Application_withdrawal__c = 'CWD';

		ANG_AgencyChangesConfig__c changeHierarchy = new ANG_AgencyChangesConfig__c();
		changeHierarchy.Name = 'ChangeHierarchy';
		changeHierarchy.TC_Hierarchy__c = true;
		changeHierarchy.TCA_Sanity_check__c = 'CHH';
		changeHierarchy.TCA_Manager_approval__c = 'HCF';
		changeHierarchy.TCA_Application_withdrawal__c = 'CWD';

		insert new List<ANG_AgencyChangesConfig__c>{changeLocationType, changeLocationTypeDiffLegalEnt, changeHierarchy};

		AMS_ChangeCodes__c cadCode = new AMS_ChangeCodes__c(
			Name = 'CAD',
			Bulletin_Memo_Text__c = 'Change of Location Type Finalized',
			Change_Code__c = 'CAD',
			Integration_RecId__c = 'C'
		);

		AMS_ChangeCodes__c cdlCode = new AMS_ChangeCodes__c(
			Name = 'CDL',
			Account_status_change__c = '8;9',
			Billable__c = true,
			Change_Code__c = 'CDL',
			Reason_Code_Description__c = 'CHANGE IN PROCESS',
			Reason_Code__c = '81',
			Integration_RecId__c = 'C',
			Class_Type__c = 'P',
			Billable_Location_Class__c = 'P;D'
		);

		AMS_ChangeCodes__c cdfCode = new AMS_ChangeCodes__c(
			Name = 'CDF',
			Account_status_change__c = '9;8',
			Change_Code__c = 'CDF',
			Reason_Code_Description__c = 'ACCREDITED-MEET-STANDARDS',
			Reason_Code__c = '91',
			Integration_RecId__c = 'C',
			Class_Type__c = 'P'
		);

		AMS_ChangeCodes__c cwdCode = new AMS_ChangeCodes__c(
			Name = 'CWD',
			Account_status_change__c = '9;8',
			Bulletin_Memo_Text__c = 'ACCREDITED-MEET-STANDARDS',
			Reason_Code__c = '91',
			Change_Code__c = 'CWD',
			Integration_RecId__c = 'C',
			Published_in_bulletin__c = true
		);

		AMS_ChangeCodes__c hcfCode = new AMS_ChangeCodes__c(
			Name = 'HCF',
			Account_status_change__c = '9;8',
			Change_Code__c = 'HCF',
			Reason_Code_Description__c = 'ACCREDITED-MEET-STANDARDS',
			Reason_Code__c = '91',
			Integration_RecId__c = 'C',
			Class_Type__c = 'P'
		);

		AMS_ChangeCodes__c chhCode = new AMS_ChangeCodes__c(
			Name = 'CHH',
			Account_status_change__c = '8;9',
			Change_Code__c = 'CHH',
			Reason_Code_Description__c = 'CHANGE IN PROCESS',
			Reason_Code__c = '81',
			Integration_RecId__c = 'C'
		);

		insert new List<AMS_ChangeCodes__c>{cadCode, cdlCode, cdfCode, cwdCode, chhCode, hcfCode};

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

		AMS_Settlement_System__c bspFR = new AMS_Settlement_System__c(
			Name = 'BSP-FR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		AMS_Settlement_System__c bspSG = new AMS_Settlement_System__c(
			Name = 'BSP-SG',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			CurrencyIsoCode = 'EUR'
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspGB, bspFR, bspSG};

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

		IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c();
		
		countryFR.Name = 'France';
		countryFR.ISO_Code__c = 'FR';
		countryFR.ANG_Enable_NewGen__c = true;
		countryFR.AMS_Settlement_System__c = bspFR.Id;
		countryFR.Multicountry_Enabled__c = true;

		IATA_ISO_Country__c countrySG = new IATA_ISO_Country__c();
		
		countrySG.Name = 'Singapore';
		countrySG.ISO_Code__c = 'SG';
		countrySG.ANG_Enable_NewGen__c = true;
		countrySG.AMS_Settlement_System__c = bspSG.Id;
		countrySG.Multicountry_Enabled__c = true;

		insert new List<IATA_ISO_Country__c>{countryPT, countryUK, countryFR, countrySG};

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

		Account accountUkGE_h2 = new Account();
		accountUkGE_h2.Name = 'H2 - Multicountry GE UK';
		accountUkGE_h2.Location_Type__c = AMS_Utils.GE;
		accountUkGE_h2.Location_Class__c = 'P';
		accountUkGE_h2.IATA_ISO_Country__c = countryUK.Id;
		accountUkGE_h2.RecordTypeId = agencyRecTypeId;
		accountUkGE_h2.IATACode__c = '22300099';
		accountUkGE_h2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountUkGE_h2.Status__c = 'Approved';
		accountUkGE_h2.Remittance_Frequency__c = 'D';
		accountUkGE_h2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;		

		insert new List<Account>{accountGE, accountUkGE_h2};

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

		Account accountFrHE = new Account();
		accountFrHE.Name = 'Multicountry HE FR';
		accountFrHE.ParentId = accountGE.Id;
		accountFrHE.Location_Type__c = AMS_Utils.HE;
		accountFrHE.Location_Class__c = 'P';
		accountFrHE.IATA_ISO_Country__c = countryFR.Id;
		accountFrHE.RecordTypeId = agencyRecTypeId;
		accountFrHE.IATACode__c = '12300097';
		accountFrHE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrHE.Status__c = 'Approved';
		accountFrHE.Remittance_Frequency__c = 'D';
		accountFrHE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountAE = new Account();
		accountAE.Name = 'Multicountry AE PT';
		accountAE.ParentId = accountGE.Id;
		accountAE.Location_Type__c = AMS_Utils.AE;
		accountAE.Location_Class__c = 'P';
		accountAE.IATA_ISO_Country__c = countryPT.Id;
		accountAE.RecordTypeId = agencyRecTypeId;
		accountAE.IATACode__c = '12300096';
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
		accountAE_2.IATACode__c = '12300095';
		accountAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAE_2.Status__c = 'Approved';
		accountAE_2.Remittance_Frequency__c = 'D';
		accountAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountAeUk_h2 = new Account();
		accountAeUk_h2.Name = 'H2 - Multicountry AE UK';
		accountAeUk_h2.ParentId = accountUkGE_h2.Id;
		accountAeUk_h2.Location_Type__c = AMS_Utils.AE;
		accountAeUk_h2.Location_Class__c = 'P';
		accountAeUk_h2.IATA_ISO_Country__c = countryUK.Id;
		accountAeUk_h2.RecordTypeId = agencyRecTypeId;
		accountAeUk_h2.IATACode__c = '22300095';
		accountAeUk_h2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAeUk_h2.Status__c = 'Approved';
		accountAeUk_h2.Remittance_Frequency__c = 'D';
		accountAeUk_h2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountHePt_h2 = new Account();
		accountHePt_h2.Name = 'H2 - Multicountry HE PT';
		accountHePt_h2.ParentId = accountUkGE_h2.Id;
		accountHePt_h2.Location_Type__c = AMS_Utils.HE;
		accountHePt_h2.Location_Class__c = 'P';
		accountHePt_h2.IATA_ISO_Country__c = countryPT.Id;
		accountHePt_h2.RecordTypeId = agencyRecTypeId;
		accountHePt_h2.IATACode__c = '32300095';
		accountHePt_h2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountHePt_h2.Status__c = 'Approved';
		accountHePt_h2.Remittance_Frequency__c = 'D';
		accountHePt_h2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountHeSg_h2 = new Account();
		accountHeSg_h2.Name = 'H2 - Multicountry HE SG';
		accountHeSg_h2.ParentId = accountUkGE_h2.Id;
		accountHeSg_h2.Location_Type__c = AMS_Utils.HE;
		accountHeSg_h2.Location_Class__c = 'P';
		accountHeSg_h2.IATA_ISO_Country__c = countrySG.Id;
		accountHeSg_h2.RecordTypeId = agencyRecTypeId;
		accountHeSg_h2.IATACode__c = '42300095';
		accountHeSg_h2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountHeSg_h2.Status__c = 'Approved';
		accountHeSg_h2.Remittance_Frequency__c = 'D';
		accountHeSg_h2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert new List<Account>{accountUkHE, accountFrHE, accountAE, accountAE_2, accountAeUk_h2, accountHePt_h2, accountHeSg_h2};

		Account accountUkAE = new Account();
		accountUkAE.Name = 'Multicountry AE UK';
		accountUkAE.ParentId = accountUkHE.Id;
		accountUkAE.Location_Type__c = AMS_Utils.AE;
		accountUkAE.Location_Class__c = 'P';
		accountUkAE.IATA_ISO_Country__c = countryUK.Id;
		accountUkAE.RecordTypeId = agencyRecTypeId;
		accountUkAE.IATACode__c = '12300094';
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
		accountUkAE_2.IATACode__c = '12300093';
		accountUkAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountUkAE_2.Status__c = 'Approved';
		accountUkAE_2.Remittance_Frequency__c = 'D';
		accountUkAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountFrAE = new Account();
		accountFrAE.Name = 'Multicountry AE FR';
		accountFrAE.ParentId = accountFrHE.Id;
		accountFrAE.Location_Type__c = AMS_Utils.AE;
		accountFrAE.Location_Class__c = 'P';
		accountFrAE.IATA_ISO_Country__c = countryFR.Id;
		accountFrAE.RecordTypeId = agencyRecTypeId;
		accountFrAE.IATACode__c = '12300092';
		accountFrAE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrAE.Status__c = 'Approved';
		accountFrAE.Remittance_Frequency__c = 'D';
		accountFrAE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountFrAE_2 = new Account();
		accountFrAE_2.Name = 'Multicountry AE FR 2';
		accountFrAE_2.ParentId = accountFrHE.Id;
		accountFrAE_2.Location_Type__c = AMS_Utils.AE;
		accountFrAE_2.Location_Class__c = 'P';
		accountFrAE_2.IATA_ISO_Country__c = countryFR.Id;
		accountFrAE_2.RecordTypeId = agencyRecTypeId;
		accountFrAE_2.IATACode__c = '12300091';
		accountFrAE_2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountFrAE_2.Status__c = 'Approved';
		accountFrAE_2.Remittance_Frequency__c = 'D';
		accountFrAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountAePt_h2 = new Account();
		accountAePt_h2.Name = 'H2 - Multicountry AE PT';
		accountAePt_h2.ParentId = accountHePt_h2.Id;
		accountAePt_h2.Location_Type__c = AMS_Utils.AE;
		accountAePt_h2.Location_Class__c = 'P';
		accountAePt_h2.IATA_ISO_Country__c = countryPT.Id;
		accountAePt_h2.RecordTypeId = agencyRecTypeId;
		accountAePt_h2.IATACode__c = '22300091';
		accountAePt_h2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAePt_h2.Status__c = 'Approved';
		accountAePt_h2.Remittance_Frequency__c = 'D';
		accountAePt_h2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		Account accountAeSg_h2 = new Account();
		accountAeSg_h2.Name = 'H2 - Multicountry AE SG';
		accountAeSg_h2.ParentId = accountHeSg_h2.Id;
		accountAeSg_h2.Location_Type__c = AMS_Utils.AE;
		accountAeSg_h2.Location_Class__c = 'P';
		accountAeSg_h2.IATA_ISO_Country__c = countrySG.Id;
		accountAeSg_h2.RecordTypeId = agencyRecTypeId;
		accountAeSg_h2.IATACode__c = '42300091';
		accountAeSg_h2.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountAeSg_h2.Status__c = 'Approved';
		accountAeSg_h2.Remittance_Frequency__c = 'D';
		accountAeSg_h2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert new List<Account>{accountUkAE, accountUkAE_2, accountFrAE, accountFrAE_2, accountAePt_h2, accountAeSg_h2};

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Multicountry Hierarchy');
		AMS_Agencies_Hierarchy__c hierarchy_h2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Multicountry Hierarchy H2');
		
		insert new List<AMS_Agencies_Hierarchy__c>{hierarchy, hierarchy_h2};
		
		List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();

		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountFrHE.Id, Child_Account__c = accountFrAE.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountFrHE.Id, Child_Account__c = accountFrAE_2.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountUkHE.Id, Child_Account__c = accountUkAE.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountUkHE.Id, Child_Account__c = accountUkAE_2.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountFrHE.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountUkHE.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountAE.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountAE_2.Id, Is_Newgen_Relation__c = true));
				
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy_h2.Id, Parent_Account__c = accountUkGE_h2.Id, Child_Account__c = accountAeUk_h2.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy_h2.Id, Parent_Account__c = accountUkGE_h2.Id, Child_Account__c = accountHePt_h2.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy_h2.Id, Parent_Account__c = accountUkGE_h2.Id, Child_Account__c = accountHeSg_h2.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy_h2.Id, Parent_Account__c = accountHePt_h2.Id, Child_Account__c = accountAePt_h2.Id, Is_Newgen_Relation__c = true));
		rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy_h2.Id, Parent_Account__c = accountHeSg_h2.Id, Child_Account__c = accountAeSg_h2.Id, Is_Newgen_Relation__c = true));
		
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

		ANG_RHC_Information__c rhcInfoForGE_h2 = new ANG_RHC_Information__c(
			ANG_AccountId__c = accountUkGE_h2.Id,
			CurrencyIsoCode = 'EUR',
			RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
			ANG_Financial_Security__c = 0,
			ANG_RHC_Amount_Equals_FS__c = true,
			ANG_RHC_Amount__c = 15,
			ANG_RME_Amount__c = 100
		);

		insert new List<ANG_RHC_Information__c>{rhcInfoForGE, rhcInfoForGE_h2};

		Test.stopTest();

		Id rfValuesRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Agency_Risk_Calculation__c', ANG_RiskAssessmentEngine.REMITTANCE_FREQUENCY_VALUES_REC_TYPE_NAME);

		ANG_Agency_Risk_Calculation__c nbrOfRemittancesMonthly = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 12,
			ANG_Remittance_Frequency__c = 'M',
			RecordTypeId = rfValuesRecTypeId
		);

		ANG_Agency_Risk_Calculation__c nbrOfRemittancesFortnightly = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 24,
			ANG_Remittance_Frequency__c = 'F',
			RecordTypeId = rfValuesRecTypeId
		);

		ANG_Agency_Risk_Calculation__c nbrOfRemittances4TimesPerMonth = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 48,
			ANG_Remittance_Frequency__c = 'W',
			RecordTypeId = rfValuesRecTypeId
		);

		ANG_Agency_Risk_Calculation__c nbrOfRemittancesEvery10Days = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 48,
			ANG_Remittance_Frequency__c = 'R',
			RecordTypeId = rfValuesRecTypeId
		);

		ANG_Agency_Risk_Calculation__c nbrOfRemittancesWeekly = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 52,
			ANG_Remittance_Frequency__c = 'V',
			RecordTypeId = rfValuesRecTypeId
		);

		ANG_Agency_Risk_Calculation__c nbrOfRemittancesEvery5Days = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 73,
			ANG_Remittance_Frequency__c = 'S',
			RecordTypeId = rfValuesRecTypeId
		);
		
		ANG_Agency_Risk_Calculation__c nbrOfRemittancesTwiceAWeek = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 96,
			ANG_Remittance_Frequency__c = 'B',
			RecordTypeId = rfValuesRecTypeId
		);

		ANG_Agency_Risk_Calculation__c nbrOfRemittancesEvery3Days = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 105,
			ANG_Remittance_Frequency__c = 'T',
			RecordTypeId = rfValuesRecTypeId
		);

		ANG_Agency_Risk_Calculation__c nbrOfRemittancesDaily = new ANG_Agency_Risk_Calculation__c(
			ANG_Occurrence_Num__c = 122,
			ANG_Remittance_Frequency__c = 'D',
			RecordTypeId = rfValuesRecTypeId
		);

		List<ANG_Agency_Risk_Calculation__c> rfValuesLst = new List<ANG_Agency_Risk_Calculation__c>();

		rfValuesLst.add(nbrOfRemittancesMonthly);
		rfValuesLst.add(nbrOfRemittancesFortnightly);
		rfValuesLst.add(nbrOfRemittances4TimesPerMonth);
		rfValuesLst.add(nbrOfRemittancesEvery10Days);
		rfValuesLst.add(nbrOfRemittancesWeekly);
		rfValuesLst.add(nbrOfRemittancesEvery5Days);
		rfValuesLst.add(nbrOfRemittancesTwiceAWeek);
		rfValuesLst.add(nbrOfRemittancesEvery3Days);
		rfValuesLst.add(nbrOfRemittancesDaily);

		insert rfValuesLst;

	}

	private static AMS_OSCAR__c createNecessaryData(Account acct){

		Contact cont = new Contact(
			AccountId = acct.id, 
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
			Account__c = acct.Id,
			Process__c = AMS_Utils.NGCHANGES, 
			RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES,
			Status__c = 'Open',
			STEP10__c = 'Passed'
		);

		insert oscar;

		Case oscarCase = new Case();
		oscarCase.Oscar__c = oscar.Id;
		oscarCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
		oscarCase.AccountId = acct.Id;
		oscarCase.ContactId = cont.Id;
		insert oscarCase;

		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'Attachment Required',
			Case__c = oscarCase.Id
		);

		insert aFile;

		AMS_Pax_Accreditation_Form__c staging = new AMS_Pax_Accreditation_Form__c();

		staging.RecordTypeId = AMS_Utils.RECTYPE_NEWGEN_CHANGES_PAX;
		staging.Account_Name__c = acct.Name;
		staging.ISSP_AMS_Legal_Status__c = 'Association';
		staging.Branch_Office_Country__c = acct.IATA_ISO_Country__c;
		staging.Branch_Office_Street_name_number__c = 'sdfsdf';
		staging.Branch_Office_City__c = 'sdfsdfdf';
		staging.IATA_ISO_State__c = acct.Iso_State__c;
		staging.Branch_Office_Email__c = 'sdfsdfgdg@f3434.com';
		staging.Branch_Office_Phone__c = '123123123';
		staging.ISSP_AMS_Premises_located_at_airport__c = 'No';
		staging.Abbreviated_name__c = 'Multicountry ';
		staging.Abbreviated_Address__c = 'sdfsdf';
		staging.Remittance_frequency__c = 'M';
		staging.Solicitation_Flag__c = false;
		staging.Location_Class__c = acct.Location_Class__c;
		staging.Location_Type__c = acct.Location_Type__c;
		staging.SAAM_Case__c = oscarCase.Id;
		staging.ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

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

		return oscar;

	} 

	private static void assertAllHierarchy(Map<String,String> expectedHierarchyByIataCode, Account acct){
		
		Map<Id, List<AMS_Agencies_relationhip__c>> relationsLst = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{acct.Id});

		for(AMS_Agencies_relationhip__c rel : relationsLst.get(acct.Id)){
			system.assert(expectedHierarchyByIataCode.get(rel.Child_Account__r.IATACode__c) == rel.Parent_Account__r.IATACode__c);
		}

		for(Account acc : [SELECT Id, Name, IATACode__c, Parent.IATACode__c FROM Account WHERE ParentId != NULL AND Top_Parent__c = :acct.Top_Parent__c]){
			system.assert(expectedHierarchyByIataCode.get(acc.IATACode__c) == acc.Parent.IATACode__c);
		}

	}

	private static void assertChangeCodes(Id oscarId, String changeCode, Set<Id> accountsInvolvedSet){

		List<Agency_Applied_Change_code__c> appliedChangeCodesLst = new List<Agency_Applied_Change_code__c>(
			[SELECT 
				Id, 
				Account__c, 
				Change_Code__c 
			 FROM 
				Agency_Applied_Change_code__c 
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

	/**
	* Change of location type AE<->GE 
	* Same BSP and same legal entity
	*
	*/
	@isTest static void changeOfLocationTypeAEGESameBSP() {

		Account acct = 
			[SELECT 
				Id, 
				Name,
				IATACode__c, 
				IATA_ISO_Country__c, 
				Iso_State__c, 
				Location_Class__c, 
				Location_Type__c,
				Top_Parent__c
			 FROM 
				Account 
			 WHERE 
				Name = 'Multicountry AE PT'
			 AND
				Location_Type__c = :AMS_Utils.AE
			];

		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();

		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			if(item.acc.Location_Type__c == AMS_Utils.GE){
				item.selected = true;
				accountsInvolvedSet.add(item.acc.Id);
				break;
			}
		}

		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION_TYPE;
		con.save();

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.Change_effective_as_of__c = System.today();
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();

		update oscar;

		Test.stopTest();
		
		Map<String,String> expectedHierarchyByIataCodes = new Map<String, String>{
			'12300099' => '12300096',
			'12300095' => '12300096',
			'12300097' => '12300096',
			'12300098' => '12300096',
			'12300092' => '12300097',
			'12300091' => '12300097',
			'12300094' => '12300098',
			'12300093' => '12300098'
		};

		assertChangeCodes(oscar.Id, 'CAD', accountsInvolvedSet);
		assertAllHierarchy(expectedHierarchyByIataCodes, acct);

	}

	/**
	* Change of location type AE<->HE 
	* Same BSP and same legal entity
	*
	*/
	@isTest static void changeOfLocationTypeAEHESameBSP() {

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
				Top_Parent__c
			 FROM 
				Account 
			 WHERE 
				Name = 'Multicountry AE UK'
			 AND
				Location_Type__c = :AMS_Utils.AE
			];

		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();

		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			if(item.acc.Location_Type__c == AMS_Utils.HE && item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c == acct.IATA_ISO_Country__r.AMS_Settlement_System__c){
				item.selected = true;
				accountsInvolvedSet.add(item.acc.Id);
				break;
			}
		}  

		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION_TYPE;
		con.save();

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.Change_effective_as_of__c = System.today();
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();

		update oscar;

		Test.stopTest();
		
		Map<String,String> expectedHierarchyByIataCodes = new Map<String, String>{
			'12300096' => '12300099',
			'12300095' => '12300099',
			'12300097' => '12300099',
			'12300094' => '12300099',
			'12300092' => '12300097',
			'12300091' => '12300097',
			'12300098' => '12300094',
			'12300093' => '12300094'
		};
		
		assertChangeCodes(oscar.Id, 'CAD', accountsInvolvedSet);
		assertAllHierarchy(expectedHierarchyByIataCodes, acct);

	}

	/**
	* Change of location type AE<->GE 
	* Same BSP and different legal entity
	*
	*/
	@isTest static void changeOfLocationTypeAEGESameBSPandDiffLegalEntity() {

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
				Top_Parent__c
			 FROM 
				Account 
			 WHERE 
				Name = 'Multicountry AE PT'
			 AND
				Location_Type__c = :AMS_Utils.AE
			];

		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();
		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			if(item.acc.Location_Type__c == AMS_Utils.GE){
				accountsInvolvedSet.add(item.acc.Id);
				item.selected = true;
				break;
			}
		}

		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY;
		con.save();

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.Change_effective_as_of__c = System.today();
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();

		update oscar;

		assertChangeCodes(oscar.Id, 'CDL', accountsInvolvedSet);

		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;

		Test.stopTest();
		
		Map<String,String> expectedHierarchyByIataCodes = new Map<String, String>{
			'12300099' => '12300096',
			'12300095' => '12300096',
			'12300097' => '12300096',
			'12300098' => '12300096',
			'12300092' => '12300097',
			'12300091' => '12300097',
			'12300094' => '12300098',
			'12300093' => '12300098'
		};
		
		assertChangeCodes(oscar.Id, 'CDF', accountsInvolvedSet);
		assertAllHierarchy(expectedHierarchyByIataCodes, acct);

	}

	/**
	* Change of location type AE<->HE 
	* Same BSP and different legal entity
	*
	*/
	@isTest static void changeOfLocationTypeAEHESameBSPandDiffLegalEntity() {

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
				Top_Parent__c
			 FROM 
				Account 
			 WHERE 
				Name = 'Multicountry AE FR'
			 AND
				Location_Type__c = :AMS_Utils.AE
			];

		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();
		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			if(item.acc.Location_Type__c == AMS_Utils.HE && item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c == acct.IATA_ISO_Country__r.AMS_Settlement_System__c){
								accountsInvolvedSet.add(item.acc.Id);
				item.selected = true;
				break;
			}
		}

		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY;
		con.save();

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.Change_effective_as_of__c = System.today();
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();

		update oscar;

		assertChangeCodes(oscar.Id, 'CDL', accountsInvolvedSet);

		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;

		Test.stopTest();
		
		Map<String,String> expectedHierarchyByIataCodes = new Map<String, String>{
			'12300096' => '12300099',
			'12300095' => '12300099',
			'12300092' => '12300099',
			'12300098' => '12300099',
			'12300097' => '12300092',
			'12300091' => '12300092',
			'12300094' => '12300098',
			'12300093' => '12300098'
		};
		
		assertChangeCodes(oscar.Id, 'CDF', accountsInvolvedSet);
		assertAllHierarchy(expectedHierarchyByIataCodes, acct);

	}

	/**
	* Change of location type AE<->GE 
	* Different BSP and different legal entity
	*
	*/
	@isTest static void changeOfLocationTypeAEGEDiffBSPandDiffLegalEntity() {

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
				Top_Parent__c
			 FROM 
				Account 
			 WHERE 
				Name = 'Multicountry AE UK'
			 AND
				Location_Type__c = :AMS_Utils.AE
			];

		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();
		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			if(item.acc.Location_Type__c == AMS_Utils.GE){
				accountsInvolvedSet.add(item.acc.Id);
				item.selected = true;
				break;
			}
		}

		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY;
		con.save();

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.Change_effective_as_of__c = System.today();
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();

		update oscar;

		assertChangeCodes(oscar.Id, 'CDL', accountsInvolvedSet);

		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;

		Test.stopTest();
		
		Map<String,String> expectedHierarchyByIataCodes = new Map<String, String>{
			'12300099' => '12300094',
			'12300095' => '12300099',
			'12300096' => '12300099',
			'12300097' => '12300094',
			'12300092' => '12300097',
			'12300091' => '12300097',
			'12300098' => '12300094',
			'12300093' => '12300094'
		};
		
		assertChangeCodes(oscar.Id, 'CDF', accountsInvolvedSet);
		assertAllHierarchy(expectedHierarchyByIataCodes, acct);

	}

	/**
	* Change of location type HE<->GE 
	* Different BSP and different legal entity
	*
	*/
	@isTest static void changeOfLocationTypeHEGEDiffBSPandDiffLegalEntity() {

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
				Top_Parent__c
			 FROM 
				Account 
			 WHERE 
				Name = 'Multicountry HE FR'
			 AND
				Location_Type__c = :AMS_Utils.HE
			];

		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();
		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			if(item.acc.Location_Type__c == AMS_Utils.GE){
				accountsInvolvedSet.add(item.acc.Id);
				item.selected = true;
				break;
			}
		}

		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY;
		con.save();

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.Change_effective_as_of__c = System.today();
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();

		update oscar;

		assertChangeCodes(oscar.Id, 'CDL', accountsInvolvedSet);

		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;

		Test.stopTest();
		
		Map<String,String> expectedHierarchyByIataCodes = new Map<String, String>{
			'12300099' => '12300097',
			'12300095' => '12300099',
			'12300096' => '12300099',
			'12300098' => '12300097',
			'12300092' => '12300097',
			'12300091' => '12300097',
			'12300094' => '12300098',
			'12300093' => '12300098'
		};
		
		assertChangeCodes(oscar.Id, 'CDF', accountsInvolvedSet);
		assertAllHierarchy(expectedHierarchyByIataCodes, acct);

	}


	/**
	* Change of Hierarchy test validations 
	* 
	*/
	@isTest
	static void changeOfHierarchyValidationForMulticountry(){

		Id agencyRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

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
				ANG_Accreditation_Model__c
			 FROM 
				Account 
			 WHERE 
				Name = 'Multicountry HE FR'
			 AND
				Location_Type__c = :AMS_Utils.HE
			];


		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();
		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			if(item.acc.Location_Type__c == AMS_Utils.GE){
				item.selected = true;
				break;
			}
		}

		IATA_ISO_Country__c ctry = [SELECT id, name FROM IATA_ISO_Country__c WHERE name = 'Portugal' limit 1];

		//Test Scenario 1
		Test.startTest();

		//Create Standard HE Cash account 
		Account heAccount = new Account();
		heAccount.Name = 'Main HE Account HE';
		heAccount.Sector__c = 'Travel Agent';
		heAccount.IATACode__c = '12345678';
		heAccount.Category__c = 'IATA Passenger Sales Agent';
		heAccount.Location_Class__c = 'P';
		heAccount.Location_Type__c = 'HE';
		heAccount.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASHLESS;
		heAccount.IATA_ISO_Country__c = ctry.Id;
		heAccount.ANG_IEP_HE_AccntNum__c = '1232132323';
		heAccount.ANG_IEP_Status__c = 'Suspended';
		heAccount.ANG_HE_CashCondition__c = true;
		heAccount.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		heAccount.ANG_HE_RiskStatus__c = 'Not Applicable';
		heAccount.RecordTypeId = agencyRecTypeId;

		insert heAccount;

		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		con.oscar.New_parent__c = heAccount.id;
		con.save();

		//Check test scenario 1 
		ApexPages.Message[] pageMessagesScenario1 = ApexPages.getMessages();

		System.assertEquals('You cannot select a Standard or Lite hierarchy as the New Parent.', pageMessagesScenario1[0].getSummary());

		//Test Scenario 3

		//Create Multicountry GE account 
		Account accountGE = new Account();

		accountGE.Name = 'Multicountry GE PT';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = ctry.Id;
		accountGE.RecordTypeId = agencyRecTypeId;
		accountGE.IATACode__c = '12300099';
		accountGE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountGE.Status__c = 'Approved';
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert accountGE;

		//Perform Save
		con.oscar.New_parent__c = accountGE.id;
		con.save();

		
		Boolean checkErrorMessage = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('You cannot leave an AE account alone in a BSP'))
				checkErrorMessage = true;
		}

		System.assert(checkErrorMessage);


		//Test Scenario 4 
		heAccount.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		update heAccount;

		//Perform Save
		con.oscar.New_parent__c = heAccount.id;
		con.save();

		checkErrorMessage = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('You cannot choose an Account as a target for the destination hierarchy which does not have a valid Location type (GE).'))
				checkErrorMessage = true;
		}

		System.assert(checkErrorMessage);
		
		Test.stopTest();
	}

	@isTest static void changeOfEntireMulticountryHierarchyTest(){

		List<Account> acctLst = new List<Account>( 
			[SELECT 
				Id, 
				Name, 
				IATACode__c,
				IATA_ISO_Country__c, 
				IATA_ISO_Country__r.AMS_Settlement_System__c,
				Iso_State__c, 
				Location_Class__c, 
				Location_Type__c,
				Top_Parent__c
			 FROM 
				Account 
			 WHERE
				Location_Type__c = :AMS_Utils.GE
			]
		);

		Account acct0 = acctLst.get(0);
		Account acct1 = acctLst.get(1);

		Account acct = acct0.Name.contains('H2') ? acct0: acct1;
		Account newParentAcct = acct0.Name.contains('H2') ? acct1: acct0;

		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();
		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			accountsInvolvedSet.add(item.acc.Id);
			item.selected = true;			
		}

		con.oscar.New_Parent__c = newParentAcct.Id;
		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		con.save();

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Change_effective_as_of__c = System.today();

		update oscar;

		assertChangeCodes(oscar.Id, 'CHH', accountsInvolvedSet);

		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;

		Test.stopTest();
		
		assertChangeCodes(oscar.Id, 'HCF', accountsInvolvedSet);

		acct = [SELECT Id, IATACode__c, Top_Parent__c FROM Account WHERE Id = :acct.Id];

		Map<String,String> expectedHierarchyByIataCodes = new Map<String, String>{
			'12300095' => '12300099',
			'12300096' => '12300099',
			'12300097' => '12300099',
			'12300092' => '12300097',
			'12300091' => '12300097',
			'12300098' => '12300099',
			'12300094' => '12300098',
			'12300093' => '12300098',
			'22300099' => '12300098',
			'22300095' => '12300098',
			'32300095' => '12300099',
			'22300091' => '12300099',
			'42300095' => '12300099',
			'42300091' => '42300095'
		};
		
		assertAllHierarchy(expectedHierarchyByIataCodes, acct);

	}

	@isTest static void changeOfMulticountryHierarchySplitTest(){
		
		Set<String> iataCodesToSelectSet = new Set<String>{
			'12300097',
			'12300094',
			'12300093',
			'12300092',
			'12300091'
		};

		List<Account> acctLst = new List<Account>( 
			[SELECT 
				Id, 
				Name, 
				IATACode__c,
				IATA_ISO_Country__c, 
				IATA_ISO_Country__r.AMS_Settlement_System__c,
				Iso_State__c, 
				Location_Class__c, 
				Location_Type__c,
				Top_Parent__c
			 FROM 
				Account 
			 WHERE
				IATACode__c IN :iataCodesToSelectSet
			]
		);
	
		Id formOfPaymentRecId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'FormOfPayment');

		Account acct = null;
		
		List<Agency_Authorization__c> authorizationLst = new List<Agency_Authorization__c>();

		for(Account acc : acctLst){

			if(acc.IATACode__c == '12300094'){
				acct = acc;
			}

			Agency_Authorization__c fopCC = new Agency_Authorization__c(
				Account__c = acc.Id, 
				ANG_FormOfPayment_ID__c = 'CC', 
				Status__c = 'Non-Active', 
				RecordTypeId = formOfPaymentRecId
			);	
								
			Agency_Authorization__c fopCA = new Agency_Authorization__c(
				Account__c = acc.Id, 
				ANG_FormOfPayment_ID__c = 'CA', 
				Status__c = 'Non-Active', 
				RecordTypeId = formOfPaymentRecId
			);	
								
			Agency_Authorization__c fopEP = new Agency_Authorization__c(
				Account__c = acc.Id, 
				ANG_FormOfPayment_ID__c = 'EP', 
				Status__c = 'Non-Active', 
				RecordTypeId = formOfPaymentRecId
			);

			authorizationLst.add(fopCC);
			authorizationLst.add(fopCA);
			authorizationLst.add(fopEP);	

		}

		insert authorizationLst;

		AMS_OSCAR__c oscar = createNecessaryData(acct);

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

		Set<Id> accountsInvolvedSet = new Set<Id>();
		accountsInvolvedSet.add(acct.Id);

		for(ANG_AccountHierarchySelectionController.HierarchyItem item : hierarchyValues){
			if(iataCodesToSelectSet.contains(item.acc.IATACode__c)){
				accountsInvolvedSet.add(item.acc.Id);
				item.selected = true;	
			}		
		}

		con.oscar.New_Parent__c = acct.Id;
		con.oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		con.save();

		Test.startTest();

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.Change_effective_as_of__c = System.today();

		update oscar;

		assertChangeCodes(oscar.Id, 'CHH', accountsInvolvedSet);

		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		update oscar;

		Test.stopTest();
		
		assertChangeCodes(oscar.Id, 'HCF', accountsInvolvedSet);

		Map<String,String> expectedHierarchyByIataCodes = new Map<String, String>{
			'12300093' => '12300094',
			'12300097' => '12300094',
			'12300092' => '12300097',
			'12300091' => '12300097'
		};
		
		acct = [SELECT Id, IATACode__c, Top_Parent__c FROM Account WHERE ParentId = :acct.Id][0];

		assertAllHierarchy(expectedHierarchyByIataCodes, acct);

	}

}