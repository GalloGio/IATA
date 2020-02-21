@isTest
private class ANG_ChangeEntityLocationRiskEventTest {

	@testSetup static void setup(){

		Test.startTest();

		Portal_Applications__c pa = new Portal_Applications__c(
			Name = ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE
	   	);
		insert pa;

		AMS_ChangeCodes__c chgFin = new AMS_ChangeCodes__c();
		chgFin.Name = 'FIN-AMS';
		chgFin.Account_status_change__c = '9';
		chgFin.Billable__c = FALSE;
		chgFin.Bulletin_Memo_Text__c = 'Filled in by AMS_Utis';
		chgFin.Change_Code__c = 'FIN';
		chgFin.Reason_Code_Description__c = 'ACCREDITED-MEETS-STANDARDS';
		chgFin.Reason_Code__c = '91';
		chgFin.Integration_RecId__c = 'A';
		chgFin.Published_in_bulletin__c = TRUE;
		chgFin.Used_By_CNS__c = TRUE;

		AMS_ChangeCodes__c chgNew = new AMS_ChangeCodes__c();
		chgNew.Name = 'NEW-AMS';
		chgNew.Account_status_change__c = '2';
		chgNew.Billable__c = TRUE;
		chgNew.Bulletin_Memo_Text__c = 'New application in progress';
		chgNew.Change_Code__c = 'NEW';
		chgNew.Reason_Code_Description__c = 'NEW APPLICATION IN PROGRESS';
		chgNew.Reason_Code__c = '21';
		chgNew.Integration_RecId__c = 'A';
		chgNew.Billable_Location_Class__c = 'P;C;D;R;T;I';

		insert new List<AMS_ChangeCodes__c>{chgNew, chgFin};

		ANG_Risk_Event_Type__c authCashEvent = new ANG_Risk_Event_Type__c(Name = 'Auth. Cash Payment', ANG_Risk_ID__c = '1', ANG_Expiration__c = 24,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=true);
		ANG_Risk_Event_Type__c changeHeLocEvent = new ANG_Risk_Event_Type__c(Name = 'Change HE location', ANG_Risk_ID__c = '8', ANG_Expiration__c = 12,ANG_Delay_Cash_Condition__c=null,Limit_Cash_conditions__c=false);

		insert new List<ANG_Risk_Event_Type__c>{authCashEvent, changeHeLocEvent};

		Id riskEventRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Event_Configuration__c', 'RISK_EVENT_CONFIG');

		ANG_Risk_Event_Configuration__c chgOfEntityLocationCfg = new ANG_Risk_Event_Configuration__c();
		chgOfEntityLocationCfg.RecordTypeId = riskEventRecTypeId;
		chgOfEntityLocationCfg.ANG_Risk_Event_Type__c = changeHeLocEvent.Id;
		chgOfEntityLocationCfg.ANG_Field01_Conditions__c = 'Equal to';
		chgOfEntityLocationCfg.ANG_Field01_Values__c = 'TRUE';
		chgOfEntityLocationCfg.ANG_Field01__c = 'Account__r.ANG_isNewGenAgency__c';
		chgOfEntityLocationCfg.ANG_Field02_Conditions__c = 'Equal to';
		chgOfEntityLocationCfg.ANG_Field02_Values__c = 'Authorize Approval';
		chgOfEntityLocationCfg.ANG_Field02__c = 'RPM_Approval__c';
		chgOfEntityLocationCfg.ANG_Field03_Conditions__c = 'Equal to today';
		chgOfEntityLocationCfg.ANG_Field03_Values__c = 'TRUE';
		chgOfEntityLocationCfg.ANG_Field03__c = 'Risk_Event_creation_date__c';
		chgOfEntityLocationCfg.ANG_Field04_Conditions__c = 'Equal to';
		chgOfEntityLocationCfg.ANG_Field04_Values__c = 'ANG.NEW.HE.STANDARD.1.0';
		chgOfEntityLocationCfg.ANG_Field04__c = 'Process__c';
		chgOfEntityLocationCfg.ANG_Field05_Conditions__c = 'Equal to';
		chgOfEntityLocationCfg.ANG_Field05_Values__c = 'TRUE';
		chgOfEntityLocationCfg.ANG_Field05__c = 'ANG_Change_Entity_Location__c';
		chgOfEntityLocationCfg.ANG_Field06_Conditions__c = 'Equal to';
		chgOfEntityLocationCfg.ANG_Field06_Values__c = 'FALSE';
		chgOfEntityLocationCfg.ANG_Field06__c = 'Change_of_Entity_Location_within_EU__c';
		chgOfEntityLocationCfg.ANG_Object_Record_Type__c = 'ANG_New_HE';
		chgOfEntityLocationCfg.ANG_Object_Type__c = 'AMS_OSCAR__c';
		chgOfEntityLocationCfg.ANG_Risk_Event_Status__c = 'Active';
		chgOfEntityLocationCfg.ANG_TargetAgency__c = 'Related Account';
		chgOfEntityLocationCfg.ANG_isUpdateOnly__c = FALSE;

		ANG_Risk_Event_Configuration__c authCashCfg = new ANG_Risk_Event_Configuration__c();
		authCashCfg.RecordTypeId = riskEventRecTypeId;
		authCashCfg.ANG_Risk_Event_Type__c = authCashEvent.Id;
		authCashCfg.ANG_Field01_Conditions__c = 'Equal to';
		authCashCfg.ANG_Field01_Values__c = 'TRUE';
		authCashCfg.ANG_Field01__c = 'Account__r.ANG_isNewGenAgency__c';
		authCashCfg.ANG_Field02_Conditions__c = 'Equal to';
		authCashCfg.ANG_Field02_Values__c = 'Authorize Approval';
		authCashCfg.ANG_Field02__c = 'RPM_Approval__c';
		authCashCfg.ANG_Field03_Conditions__c = 'Equal to today';
		authCashCfg.ANG_Field03_Values__c = 'ANG.NEW.HE.STANDARD.1.0';
		authCashCfg.ANG_Field03__c = 'Risk_Event_creation_date__c';
		authCashCfg.ANG_Field04_Conditions__c = 'Equal to';
		authCashCfg.ANG_Field04_Values__c = 'ANG.NEW.HE.STANDARD.1.0';
		authCashCfg.ANG_Field04__c = 'Process__c';
		authCashCfg.ANG_Field05_Conditions__c = 'Equal to';
		authCashCfg.ANG_Field05_Values__c = 'FALSE';
		authCashCfg.ANG_Field05__c = 'ANG_Change_Entity_Location__c';
		authCashCfg.ANG_Field06_Conditions__c = 'Equal to';
		authCashCfg.ANG_Field06_Values__c = 'FALSE';
		authCashCfg.ANG_Field06__c = 'Change_of_Entity_Location_within_EU__c';
		authCashCfg.ANG_Object_Record_Type__c = 'ANG_New_HE';
		authCashCfg.ANG_Object_Type__c = 'AMS_OSCAR__c';
		authCashCfg.ANG_Risk_Event_Status__c = 'Active';
		authCashCfg.ANG_TargetAgency__c = 'Related Account';
		authCashCfg.ANG_isUpdateOnly__c = FALSE;

		insert new List<ANG_Risk_Event_Configuration__c>{chgOfEntityLocationCfg, authCashCfg};

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true)  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='NewGenAgency',Short_Name__c='NewGenAgency');
		a1.Location_Type__c = AMS_Utils.HE;
		a1.Location_Class__c = 'D';
		insert a1;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NEWHESTANDARD, Account__c = a1.id, Is_using_credit_card__c = true);
		oscar.RecordTypeId = AMS_Utils.RECTYPE_NEWHE;

		insert oscar;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
		oscarCase.AccountId = a1.Id;
		oscarCase.ContactId = co1.Id;
		insert oscarCase;

		// Create the Staging area for the Account
		AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
			Account_Name__c = a1.Name,
			IATAcode__c = a1.IATAcode__c,
			Branch_Office_Country__c = a1.IATA_ISO_Country__c,
			SAAM_Case__c = oscarCase.Id,
			Remittance_frequency__c = 'M',
			Location_Class__c = 'D',
			Location_Type__c = AMS_Utils.HE,
			IATA_ISO_State__c = stt.Id,
			ISSP_AMS_GDS_with_signed_contract__c = 'Amadeus'
		);

		insert stagingArea;

		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		OSCAR.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;

		Attachment attc = new Attachment(
			OwnerId = UserInfo.getUserId(),
			IsPrivate = true,
			ParentId = oscar.Oscar_Communication_Case_Id__c,
			Body = Blob.valueOf('Test'),
			Name = 'test'
		);

		insert attc;

		AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
			Name= 'test owner',
			First_name__c = 'test',
			Last_name__c = 'owner',
			Email__c = 'owner.test@test.com',
			Phone__c = '123456789',
			Financial_interest__c = 100,
			AMS_Pax_Accreditation_Form__c = oscar.AMS_Online_Accreditation__c,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'),
			Agency_Owner__c = true
		);

		insert owner;

		Test.stopTest();

	}

	@isTest static void changeOfEntityLocationNewHEStandardTest(){

		AMS_OSCAR__c oscar =
			[SELECT
				Id,
				AMS_Online_Accreditation__c,
				Oscar_Communication_Case_Id__c,
				Account__r.ANG_isNewGenAgency__c
			 FROM
				AMS_OSCAR__c
			 LIMIT 1
			];

		oscar.ANG_Change_Entity_Location__c = true;
		oscar.Change_of_Entity_Location_within_EU__c = true;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.STEP6__c = AMS_Utils.PASSED;

		try {
			update oscar;
		}
		catch(Exception e){
			System.assert(e.getMessage().contains(ANG_OscarProcessHelper.NEW_HE_CHANGE_ENTITY_LOCATION_ERROR_MSG));
		}

		//It should be generated after the Step2 but to avoid
		//hiting the governor limits generates the change code before
		//just for the purpose of this test
		AMS_OSCAR_Webservice.createChangeCodeNEW(oscar.Id);

		Test.startTest();

		oscar.Change_of_Entity_Location_within_EU__c = false;
		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.STEP34__c = AMS_Utils.PASSED;
		oscar.STEP35__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		oscar.Bank_Guarantee_requested__c = Date.today();
		update oscar;

		Case oscarCase = new Case(Id = oscar.Oscar_Communication_Case_Id__c);

		ANG_RiskForecastPropertiesController pgNewHE = new ANG_RiskForecastPropertiesController(new ApexPages.StandardController(oscarCase));

		List<SelectOption> riskOptionsLst = pgNewHE.getriskOption();

		System.assert(!riskOptionsLst.isEmpty());
		System.assert(pgNewHE.riskOpt == '1');

		SelectOption so = riskOptionsLst.get(0);

		System.assert(so.getValue() == '8');
		System.assert(so.getLabel() == 'Change of Entity\'s location');

		ANG_RiskEventGenerator.skip = false;

		Test.stopTest();

		System.assertEquals(AMS_OSCAR_Webservice.createRiskEvent(oscar.Id), '1 Risk(s) Event(s) generated successfully');

	}

	@isTest static void changeOfEntityLocationWithinEuNewHEStandardTest(){

		AMS_OSCAR__c oscar =
			[SELECT
				Id,
				AMS_Online_Accreditation__c,
				Oscar_Communication_Case_Id__c,
				RecordType.DeveloperName,
				Account__r.ANG_isNewGenAgency__c
			 FROM
				AMS_OSCAR__c
			 LIMIT 1
			];

		oscar.ANG_Change_Entity_Location__c = true;
		oscar.Change_of_Entity_Location_within_EU__c = true;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.STEP6__c = AMS_Utils.PASSED;

		try {
			update oscar;
		}
		catch(Exception e){
			System.assert(e.getMessage().contains(ANG_OscarProcessHelper.NEW_HE_CHANGE_ENTITY_LOCATION_ERROR_MSG));
		}

		//It should be generated after the Step2 but to avoid
		//hiting the governor limits generates the change code before
		//just for the purpose of this test
		AMS_OSCAR_Webservice.createChangeCodeNEW(oscar.Id);

		Test.startTest();

		oscar.ANG_Change_Entity_Location__c = false;
		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.STEP34__c = AMS_Utils.PASSED;
		oscar.STEP35__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		oscar.Bank_Guarantee_requested__c = Date.today();
		update oscar;

		Case oscarCase = new Case(Id = oscar.Oscar_Communication_Case_Id__c);

		ANG_RiskForecastPropertiesController pgNewHE = new ANG_RiskForecastPropertiesController(new ApexPages.StandardController(oscarCase));

		List<SelectOption> riskOptionsLst = pgNewHE.getriskOption();

		System.assert(riskOptionsLst.isEmpty());
		System.assert(String.isBlank(pgNewHE.riskOpt));

		ANG_RiskEventGenerator.skip = false;

		Test.stopTest();

		System.assertEquals(AMS_OSCAR_Webservice.createRiskEvent(oscar.Id), 'No risk event is needed for this OSCAR.');

	}

	@isTest static void newHEStandardTest(){

		AMS_OSCAR__c oscar =
			[SELECT
				Id,
				AMS_Online_Accreditation__c,
				Oscar_Communication_Case_Id__c,
				Account__r.ANG_isNewGenAgency__c
			 FROM
				AMS_OSCAR__c
			 LIMIT 1
			];

		//It should be generated after the Step2 but to avoid
		//hiting the governor limits generates the change code before
		//just for the purpose of this test
		AMS_OSCAR_Webservice.createChangeCodeNEW(oscar.Id);

		Test.startTest();

		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.STEP2__c = AMS_Utils.PASSED;
		oscar.STEP34__c = AMS_Utils.PASSED;
		oscar.STEP35__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
		oscar.Bank_Guarantee_requested__c = Date.today();
		update oscar;

		Case oscarCase = new Case(Id = oscar.Oscar_Communication_Case_Id__c);

		ANG_RiskForecastPropertiesController pgNewHE = new ANG_RiskForecastPropertiesController(new ApexPages.StandardController(oscarCase));

		List<SelectOption> riskOptionsLst = pgNewHE.getriskOption();

		System.assert(!riskOptionsLst.isEmpty());
		System.assert(pgNewHE.riskOpt == '1');

		SelectOption so = riskOptionsLst.get(0);

		System.assert(so.getValue() == '1');
		System.assert(so.getLabel() == 'Auth. Cash Payment');

		ANG_RiskEventGenerator.skip = false;

		Test.stopTest();

		System.assertEquals(AMS_OSCAR_Webservice.createRiskEvent(oscar.Id), '1 Risk(s) Event(s) generated successfully');

	}

}
