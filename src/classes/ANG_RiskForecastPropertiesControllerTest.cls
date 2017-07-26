@isTest
private class ANG_RiskForecastPropertiesControllerTest {
	

	@testSetup static void setup(){

		Id sIDRALiteRTId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA_Lite');

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account a1 = new Account(Remittance_frequency__c = 'Every 5 days' , ANG_Accreditation_Model__c = 'Cash', Financial_Review_Result__c = 'Satisfactory - No Action' ,ANG_HE_CashCondition__c = false , ANG_HE_RiskStatus__c = 'B' , IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P', Status__c = 'Approved');
        insert a1;
        
        Case sidraLiteCase = new Case();
        sidraLiteCase.AccountId = a1.Id;
        sidraLiteCase.recordtypeId = sIDRALiteRTId;

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

		ANG_Agency_Risk_Event__c are1= new ANG_Agency_Risk_Event__c(
			ANG_AccountId__c=a1.id,
			ANG_Risk_Type__c=ret.id,
			ANG_Issued_Date__c =System.today(),
			ANG_Event_Status__c='Inactive'
		);

		listAREs.add(are1);

		insert listAREs;

	}



	@isTest static void test_method_one() {

		PageReference pageRef = Page.ANG_RiskForecastPropertiesPage;

 		Test.setCurrentPageReference(pageRef);
 		
		Case sidraLiteCase = [Select Id from Case where RecordType.developerName='SIDRA_Lite'];

		ApexPages.StandardController sc = new ApexPages.StandardController(sidraLiteCase);

 		ANG_RiskForecastPropertiesController pgController = new ANG_RiskForecastPropertiesController(sc);

 		pgController.riskOpt = 'testRiskId';

 		pgController.getriskOption();

 		pgController.closePopup();

 		pgController.redirectPopup();

 		pgController.getcanExecuteForecast();

 		pgController.showPopup();

 		System.assertEquals('C',pgController.newRiskStatus);
 		System.assertEquals(true,pgController.newCashCondition);

 	}
	
}