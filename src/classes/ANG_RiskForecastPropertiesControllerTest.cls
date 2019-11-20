@isTest
private class ANG_RiskForecastPropertiesControllerTest {
    
    @testSetup static void testSetup(){

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true, Multicountry_Enabled__c = true);
        insert ctry ;

		Account accountGE = new Account();
		
        accountGE.Name = 'Multicountry GE';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.Location_Class__c = 'P';
		accountGE.IATA_ISO_Country__c = ctry.Id;
		accountGE.RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY;
		accountGE.IATACode__c = '99999999';
		accountGE.Reason__c = '91-ACCREDITED-MEET-STANDARDS';
		accountGE.Status__c = 'Approved';
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
        accountGE.Remittance_frequency__c = 'D';
        accountGE.Financial_Review_Result__c = 'Satisfactory - No Action';
                
        Account a1 = new Account(Remittance_frequency__c = 'S' , ANG_Accreditation_Model__c = 'Cash', Financial_Review_Result__c = 'Satisfactory - No Action' ,ANG_HE_CashCondition__c = false , ANG_HE_RiskStatus__c = 'B' , IATA_ISO_Country__c = ctry.id, RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY, IATACode__c='1234561',Location_Type__c='HE',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = 'Approved');
        
        insert new List<Account>{a1, accountGE};
        
        Case sidraLiteCase = new Case();
        sidraLiteCase.AccountId = a1.Id;
        sidraLiteCase.recordtypeId = AMS_Utils.RECTYPE_SIDRALITE;

        insert sidraLiteCase;



        list<ANG_Agency_Risk_Calculation__c> adjustmentList = new list<ANG_Agency_Risk_Calculation__c>();

        Id risk_Status_AssessmentRTId =RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Agency_Risk_Calculation__c', 'Risk_Status_Assessment');

        ANG_Agency_Risk_Calculation__c adj1= new ANG_Agency_Risk_Calculation__c(
            ANG_Financial_Review_Result__c = 'Satisfactory' ,
            ANG_Risk_History__c = 'B',
            ANG_Risk_History_Assessment__c = 'Failed',
            recordtypeId=risk_Status_AssessmentRTId   
            );
        adjustmentList.add(adj1);

        ANG_Agency_Risk_Calculation__c adj2= new ANG_Agency_Risk_Calculation__c(
            ANG_Financial_Review_Result__c = 'Unsatisfactory - New Financial Security' ,
            ANG_Risk_History__c = 'C',
            ANG_Risk_History_Assessment__c = 'Failed',
            recordtypeId=risk_Status_AssessmentRTId         
            );
        adjustmentList.add(adj2);

        ANG_Agency_Risk_Calculation__c adj3= new ANG_Agency_Risk_Calculation__c(
            ANG_Financial_Review_Result__c = 'Satisfactory - No Action' ,
            ANG_Risk_History__c = 'C',
            ANG_Risk_History_Assessment__c = 'Passed',
            recordtypeId=risk_Status_AssessmentRTId         
            );

        adjustmentList.add(adj3);

        insert adjustmentList;
        
        ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(
            name='Risk Event Test',
            ANG_Description__c='Risk Event Test',
            ANG_Expiration__c=24,
            ANG_Risk_ID__c='testRiskId',
            Limit_Cash_conditions__c = true,
            ANG_Agency_Risk_Calculation__c = adj3.Id
        );
        
        insert ret;
       
        List<ANG_Agency_Risk_Calculation__c> remittanceValuesLst = new List<ANG_Agency_Risk_Calculation__c>();
        
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

        remittanceValuesLst.add(nbrOfRemittancesMonthly);
        remittanceValuesLst.add(nbrOfRemittancesFortnightly);
        remittanceValuesLst.add(nbrOfRemittances4TimesPerMonth);
        remittanceValuesLst.add(nbrOfRemittancesEvery10Days);
        remittanceValuesLst.add(nbrOfRemittancesWeekly);
        remittanceValuesLst.add(nbrOfRemittancesEvery5Days);
        remittanceValuesLst.add(nbrOfRemittancesTwiceAWeek);
        remittanceValuesLst.add(nbrOfRemittancesEvery3Days);
        remittanceValuesLst.add(nbrOfRemittancesDaily);

        insert remittanceValuesLst;
        
    }

    static testMethod void test_CASE() {

       

        Test.startTest();
          ANG_Agency_Risk_Event__c are1= new ANG_Agency_Risk_Event__c(
            ANG_AccountId__c=[select id from account limit 1].get(0).id,
            ANG_Risk_Type__c=[select id from ANG_Risk_Event_Type__c limit 1].get(0).id,
            ANG_Issued_Date__c =System.today(),
            ANG_Event_Status__c='Inactive'
        );
        insert are1;
        PageReference pageRef = Page.ANG_RiskForecastPropertiesPage;

        Test.setCurrentPageReference(pageRef);
        
        Case sidraLiteCase = [Select Id from Case where RecordType.developerName='SIDRA_Lite'];

        ApexPages.StandardController sc = new ApexPages.StandardController(sidraLiteCase);
       
            ANG_RiskForecastPropertiesController pgController = new ANG_RiskForecastPropertiesController(sc);

            pgController.riskOpt = 'testRiskId';

            pgController.getriskOption();

            pgController.closePopup();

            pgController.getcanExecuteForecast();

            pgController.forecast();

            System.assertEquals('C',pgController.newRiskStatus);
            System.assertEquals(true,pgController.newCashCondition);
        Test.stopTest();
    }

    static testMethod void test_OSCAR() {
        
        Test.startTest();
        List<ANG_AgencyChangesConfig__c> customsettings = new List<ANG_AgencyChangesConfig__c>();
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeOwnership', TC_Ownership__c = true,
                            TC_Legal_status__c = false, TC_Location__c = false, TC_Location_type__c = false,
                            TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false,  TC_Hierarchy__c = false,
                            TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                            TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CWD', Valid_Accreditation_Models__c = 'ALL'));
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeAccreditationType', TC_Accreditation_Type__c = true,
                            TC_Legal_status__c = false, TC_Location__c = false, TC_Location_type__c = false,
                            TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
                            TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                            TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CWD', Valid_Accreditation_Models__c = 'Cash;Cashless;Legacy'));

        insert customsettings;

     

        Account a1 = [select id,IATACode__c,Location_Class__c,IATA_ISO_Country__c,Location_Type__c from account where Location_Type__c <> :AMS_Utils.GE].get(0);
                
        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
        insert co1;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = AMS_Utils.RECTYPE_NEWHE, Process__c = AMS_Utils.NEWHESTANDARD, Account__c = a1.id, Is_using_credit_card__c = true);
        insert oscar;

        Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

        

         // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
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
                VAT_Number_2__c = '111222333'
                );

        insert stagingArea;

        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        update oscar;

        

        ANG_RiskForecastPropertiesController pgNewHE = new ANG_RiskForecastPropertiesController(new ApexPages.StandardController(oscarCase));
        pgNewHE.getriskOption();

        System.assertEquals('1', pgNewHE.riskOpt);
        

        oscar.Process__c = AMS_Utils.NGCHANGES;
        oscar.RecordTypeId = AMS_Utils.RECTYPE_NGCHANGES;
        oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE;
        update oscar;

        ANG_RiskForecastPropertiesController pgChangesAccType = new ANG_RiskForecastPropertiesController(new ApexPages.StandardController(oscarCase));
        pgChangesAccType.getriskOption();
        System.assertEquals('1', pgChangesAccType.riskOpt);
     

        oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_OWNERSHIP;
        update oscar;

        ANG_RiskForecastPropertiesController pgChangesOwnership = new ANG_RiskForecastPropertiesController(new ApexPages.StandardController(oscarCase));
        pgChangesOwnership.getriskOption();

        System.assertEquals('6', pgChangesOwnership.riskOpt);

    }

    @isTest static void standardToMulticountryConversionForecastTest(){

        Account acct = 
            [SELECT
                Id,
                Name,
                IATACode__c,
                Iso_State__c,
                Location_Type__c,
                Location_Class__c,
                IATA_ISO_Country__c
             FROM Account
             WHERE
                Location_Type__c = :AMS_Utils.GE
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
			Process__c = AMS_Utils.NGCONVERSIONTOMULTICOUNTRY, 
			RecordTypeId = AMS_Utils.RECTYPE_NGCONVERSIONTOMULTICOUNTRY,
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

		oscar.AMS_Online_Accreditation__c = staging.Id;
        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;

		update oscar;

        ANG_RiskForecastPropertiesController riskForecastPropertiesCtrl = new ANG_RiskForecastPropertiesController(new ApexPages.StandardController(oscarCase));
        riskForecastPropertiesCtrl.getriskOption();

        System.assertEquals(ANG_RiskForecastPropertiesController.CONVERSION_TO_MULTICOUNTRY_OPT, riskForecastPropertiesCtrl.riskOpt, 'The forecast risk option must be: ' + ANG_RiskForecastPropertiesController.CONVERSION_TO_MULTICOUNTRY_OPT);

        riskForecastPropertiesCtrl.forecast();
        
        //According to the configuration record for the combination: Satisfactory - No Action + Passed
        System.assertEquals(riskForecastPropertiesCtrl.newRiskStatus, 'C', 'Risk status must be: C');

    }
    
}