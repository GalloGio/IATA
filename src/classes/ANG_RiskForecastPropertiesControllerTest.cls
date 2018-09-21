@isTest
private class ANG_RiskForecastPropertiesControllerTest {
    
    @testSetup static void testSetup(){

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        Account a1 = new Account(Remittance_frequency__c = 'S' , ANG_Accreditation_Model__c = 'Cash', Financial_Review_Result__c = 'Satisfactory - No Action' ,ANG_HE_CashCondition__c = false , ANG_HE_RiskStatus__c = 'B' , IATA_ISO_Country__c = ctry.id, RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY, IATACode__c='1234561',Location_Type__c='HE',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = 'Approved');
        insert a1;
        
        Case sidraLiteCase = new Case();
        sidraLiteCase.AccountId = a1.Id;
        sidraLiteCase.recordtypeId = AMS_Utils.RECTYPE_SIDRALITE;

        insert sidraLiteCase;



        list<ANG_Agency_Risk_Calculation__c> adjustmentList = new list<ANG_Agency_Risk_Calculation__c>();

        Id risk_Status_AssessmentRTId =RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_Agency_Risk_Calculation__c').get('Risk_Status_Assessment');

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

        List<ANG_Agency_Risk_Event__c> listAREs = new list<ANG_Agency_Risk_Event__c>();

       

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
                            TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeAccreditationType', TC_Accreditation_Type__c = true,
                            TC_Legal_status__c = false, TC_Location__c = false, TC_Location_type__c = false,
                            TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false, TC_Ownership__c = false, TC_Hierarchy__c = false,
                            TC_Major_Shareholding__c = false, TC_VMFR__c = false,
                            TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CWD'));

        insert customsettings;

     

        Account a1 = [select id,IATACode__c,Location_Class__c,IATA_ISO_Country__c,Location_Type__c from account].get(0);
                
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
    
}