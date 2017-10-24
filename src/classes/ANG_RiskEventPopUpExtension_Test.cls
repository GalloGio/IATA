@isTest
public class ANG_RiskEventPopUpExtension_Test{
	@testSetup static void testSetup(){

		ANG_Risk_Event_Type__c ret1= new ANG_Risk_Event_Type__c(
			name= 'Risk Type 1',
			ANG_Risk_ID__c='1',
			ANG_Expiration__c=12
		);
		insert ret1;

		Account acc = new Account(
			name='Test',
			Location_Type__c=AMS_Utils.HE,
			Location_Class__c=AMS_Utils.LC_PASSENGER,
			Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
			ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY
		);
		insert acc;
	}

	private static void generateRiskEvent(id accId, id riskEventTypeId, Date reDate,ID caseId){
		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
		ANG_AccountId__c=accId,
		ANG_HE_AccountId__c=accId,
		ANG_Risk_Type__c=riskEventTypeId,
		ANG_Issued_Date__c = reDate,
		ANG_CaseId__c=caseId
		);

		insert are;
	}
	static testmethod void testPageInitialization(){
 
		Account acc = [SELECT id,Location_Type__c FROM Account WHERE Name = 'Test'];
	
		generateRiskEvent(acc.id,[SELECT id FROM ANG_Risk_Event_Type__c WHERE Name = 'Risk Type 1'].id, system.today(),null);
		
		Test.startTest();
			ANG_RiskEventPopUpExtension con = new ANG_RiskEventPopUpExtension(new ApexPages.standardController([SELECT id, ANG_Source_Id__c, ANG_Risk_Type__c, ANG_Issued_Date__c, ANG_Event_Status__c, ANG_Risk_Id__c FROM ANG_Agency_Risk_Event__c]));
			System.assertEquals(1, con.getRiskEvents().size());
		Test.stopTest();
	}
}
