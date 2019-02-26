@isTest
private class ANG_MulticountryAgencyChangesTest {
	
	@testSetup static void setup(){

		Test.startTest();

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
        changeLocationTypeDiffLegalEnt.TC_Location_Type__c = true;
        changeLocationTypeDiffLegalEnt.TCA_Sanity_check__c = 'CDL';
        changeLocationTypeDiffLegalEnt.TCA_Manager_approval__c = 'CDF';
        changeLocationTypeDiffLegalEnt.TCA_Application_withdrawal__c = 'CWD';

        insert new List<ANG_AgencyChangesConfig__c>{changeLocationType, changeLocationTypeDiffLegalEnt};

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

       	insert new List<AMS_ChangeCodes__c>{cadCode, cdlCode, cdfCode, cwdCode};

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspGB = new AMS_Settlement_System__c(
			Name = 'BSP-GB',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		AMS_Settlement_System__c bspFR = new AMS_Settlement_System__c(
			Name = 'BSP-FR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP
		);

		insert new List<AMS_Settlement_System__c>{bspPT, bspGB, bspFR};

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

		insert new List<IATA_ISO_Country__c>{countryPT, countryUK, countryFR};

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
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert accountGE;

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
		accountAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert new List<Account>{accountUkHE, accountFrHE, accountAE, accountAE_2};

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
		accountFrAE_2.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;

		insert new List<Account>{accountUkAE, accountUkAE_2, accountFrAE, accountFrAE_2};

        AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Multicountry Hierarchy');
        insert hierarchy;
        
        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();

        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountFrHE.Id, Child_Account__c = accountFrAE.Id, Is_Newgen_Relation__c = true));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountFrHE.Id, Child_Account__c = accountFrAE_2.Id, Is_Newgen_Relation__c = true));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountUkHE.Id, Child_Account__c = accountUkAE.Id, Is_Newgen_Relation__c = true));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountUkHE.Id, Child_Account__c = accountUkAE_2.Id, Is_Newgen_Relation__c = true));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountFrHE.Id, Is_Newgen_Relation__c = true));
	    rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountUkHE.Id, Is_Newgen_Relation__c = true));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountAE.Id, Is_Newgen_Relation__c = true));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = accountGE.Id, Child_Account__c = accountAE_2.Id, Is_Newgen_Relation__c = true));
        
        insert rels;

		Test.stopTest();

	}

	@isTest static void changeOfLocationTypeAEGESameBSP() {

		Map<String,String> expectedHierarchyByNames = new Map<String, String>{
			'Multicountry GE PT' => 'Multicountry AE PT',
			'Multicountry AE PT 2' => 'Multicountry AE PT',
			'Multicountry HE FR' => 'Multicountry AE PT',
			'Multicountry HE UK' => 'Multicountry AE PT',
			'Multicountry AE FR' => 'Multicountry HE FR',
			'Multicountry AE FR 2' => 'Multicountry HE FR',
			'Multicountry AE UK' => 'Multicountry HE UK',
			'Multicountry AE UK 2' => 'Multicountry HE UK'
		};

		Set<Id> accountsInvolvedSet = new Set<Id>();

		Account acct = 
			[SELECT 
				Id, 
				Name, 
				IATA_ISO_Country__c, 
				Iso_State__c, 
				Location_Class__c, 
				Location_Type__c
			 FROM 
			 	Account 
			 WHERE 
			 	Name = 'Multicountry AE PT'
			 AND
			 	Location_Type__c = :AMS_Utils.AE
			];

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
		update oscar;

		PageReference pg = Page.ANG_AccountHierarchySelection;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_AccountHierarchySelectionController con = new ANG_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

		List<ANG_AccountHierarchySelectionController.HierarchyItem> hierarchyValues = con.hierarchyValues;

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
        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		oscar.ANG_PCI_compliance_expiry_date__c = System.today();

		update oscar;

		Test.stopTest();

		List<Agency_Applied_Change_code__c> appliedChangeCodesLst = new List<Agency_Applied_Change_code__c>(
			[SELECT 
				Id, 
				Account__c, 
				Change_Code__c 
			 FROM 
			 	Agency_Applied_Change_code__c 
			 WHERE 
			 	OSCAR__c = :oscar.Id
			]
		);

		system.assert(appliedChangeCodesLst.size() == 2);

		for(Agency_Applied_Change_code__c aacc : appliedChangeCodesLst){
			system.assert(aacc.Change_Code__c == 'CAD');
			system.assert(accountsInvolvedSet.contains(aacc.Account__c));
		}

		Map<Id, List<AMS_Agencies_relationhip__c>> relationsLst = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscar.Account__c});

		for(AMS_Agencies_relationhip__c rel : relationsLst.get(oscar.Account__c)){
			system.assert(expectedHierarchyByNames.get(rel.Child_Account__r.Name) == rel.Parent_Account__r.Name);
		}

		for(Account acc : [SELECT Id, Name, Parent.Name FROM Account WHERE ParentId != NULL]){
			system.assert(expectedHierarchyByNames.get(acc.Name) == acc.Parent.Name);
		}

	}

	@isTest static void changeOfLocationTypeAEHESameBSP() {



	}
	
}